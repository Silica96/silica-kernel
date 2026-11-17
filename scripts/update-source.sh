#!/usr/bin/env bash
# kernel.org 공식 소스와 CachyOS 패치를 nix-cachyos-kernel(flake.lock 에 잠긴 리비전)이 가리키는
# CachyOS 릴리스에 맞춘다.
#
#   1. kernel.org 의 linux-<버전>.tar.xz 를 받아 kernel.org 개발자 서명(WKD)으로 검증
#   2. CachyOS 릴리스 tarball 을 받아 PKGBUILD 의 validpgpkeys 서명과 nix-cachyos-kernel 의 해시로 검증
#   3. 두 트리의 차이를 kernel/cachyos.patch 로 저장
#   4. kernel.org 트리에 패치를 적용한 결과가 CachyOS 트리와 똑같은지 확인
#   5. kernel/source.json, kernel/cachyos-release.md 갱신
#
# 환경 변수: NIX (nix 명령, 기본 nix), FORCE=1 (같은 릴리스여도 다시 생성),
#            GITHUB_TOKEN (GitHub API 요청 한도 완화, 선택)
set -euo pipefail

NIX=${NIX:-nix}
root=$(git rev-parse --show-toplevel)
cd "$root"

log() { printf '==> %s\n' "$*" >&2; }
die() { printf '오류: %s\n' "$*" >&2; exit 1; }
sri() { printf 'sha256-%s' "$(openssl dgst -sha256 -binary "$1" | base64 -w0)"; }
fetch() { curl -fsSL --retry 3 --retry-delay 5 -o "$1" "$2"; }

upstream=$($NIX eval --json .#lib.upstream)
version=$(jq -r .version <<<"$upstream")
cachyos_url=$(jq -r .url <<<"$upstream")
cachyos_hash=$(jq -r .hash <<<"$upstream")
config_url=$(jq -r .configUrl <<<"$upstream")
tag=$(basename "$(dirname "$cachyos_url")") # .../releases/download/<tag>/<tag>.tar.gz

if [[ ${FORCE:-} != 1 && -f kernel/cachyos.patch && -f kernel/source.json ]] &&
  [[ $(jq -r .cachyos.url kernel/source.json) == "$cachyos_url" ]]; then
  log "이미 $tag 기준으로 맞춰져 있음"
  exit 0
fi

[[ $version != *rc* ]] || die "rc 버전은 kernel.org tarball 이 없어 지원하지 않음: $version"
[[ $cachyos_url == https://github.com/CachyOS/linux/releases/download/* ]] || die "예상과 다른 CachyOS 소스: $cachyos_url"
kver=${version%.0}
korg_url="https://cdn.kernel.org/pub/linux/kernel/v${kver%%.*}.x/linux-${kver}.tar.xz"
log "버전 $version, CachyOS 릴리스 $tag"

work=$(mktemp -d "${TMPDIR:-/tmp}/silica-kernel.XXXXXX")
trap 'rm -rf "$work"' EXIT
export GNUPGHOME="$work/gnupg"
mkdir -m 700 "$GNUPGHOME"

# 1. kernel.org
log "kernel.org 소스 받기: $korg_url"
fetch "$work/linux.tar.xz" "$korg_url"
fetch "$work/linux.tar.sign" "${korg_url%.xz}.sign"
gpg --batch --quiet --auto-key-locate clear,nodefault,wkd \
  --locate-keys torvalds@kernel.org gregkh@kernel.org sashal@kernel.org >/dev/null 2>&1 ||
  die "kernel.org 서명 키를 WKD 에서 받지 못함"
# .sign 은 압축을 푼 .tar 에 대한 서명이다
xz -cd "$work/linux.tar.xz" | gpg --batch --status-fd 3 --verify "$work/linux.tar.sign" - 3>"$work/korg.status" 2>/dev/null ||
  die "kernel.org tarball 서명 검증 실패"
grep -q '^\[GNUPG:\] VALIDSIG' "$work/korg.status" || die "kernel.org tarball 서명 검증 실패"
log "kernel.org 서명 확인: $(awk '/^\[GNUPG:\] GOODSIG/{$1=$2=$3="";print substr($0,4)}' "$work/korg.status")"
korg_hash=$(sri "$work/linux.tar.xz")

# 2. CachyOS
log "CachyOS 소스 받기: $cachyos_url"
fetch "$work/cachyos.tar.gz" "$cachyos_url"
fetch "$work/cachyos.tar.gz.asc" "$cachyos_url.asc"
[[ $(sri "$work/cachyos.tar.gz") == "$cachyos_hash" ]] || die "CachyOS tarball 해시가 nix-cachyos-kernel 과 다름"
# 서명 키는 makepkg 와 같이 같은 커밋의 PKGBUILD validpgpkeys 를 따른다
fetch "$work/PKGBUILD" "$(dirname "$config_url")/PKGBUILD"
mapfile -t keys < <(sed -n '/^validpgpkeys=(/,/)/p' "$work/PKGBUILD" | grep -oE '[0-9A-F]{40}')
((${#keys[@]})) || die "PKGBUILD 에서 validpgpkeys 를 찾지 못함"
gpg --batch --quiet --keyserver hkps://keyserver.ubuntu.com --recv-keys "${keys[@]}" >/dev/null 2>&1 ||
  die "CachyOS 서명 키를 받지 못함"
gpg --batch --status-fd 3 --verify "$work/cachyos.tar.gz.asc" "$work/cachyos.tar.gz" 3>"$work/cachy.status" 2>/dev/null ||
  die "CachyOS tarball 서명 검증 실패"
signer=$(awk '/^\[GNUPG:\] VALIDSIG/{print $NF}' "$work/cachy.status")
printf '%s\n' "${keys[@]}" | grep -qx "$signer" || die "CachyOS tarball 이 validpgpkeys 밖의 키($signer)로 서명됨"
log "CachyOS 서명 확인: $(awk '/^\[GNUPG:\] GOODSIG/{$1=$2=$3="";print substr($0,4)}' "$work/cachy.status")"

# 3. 차이를 패치로
log "두 트리 비교"
mkdir "$work/a" "$work/b"
tar -xJf "$work/linux.tar.xz" -C "$work/a" --strip-components=1
tar -xzf "$work/cachyos.tar.gz" -C "$work/b" --strip-components=1
# 사용자 git 설정의 영향을 받지 않게 하고, GNU patch 가 다룰 수 있는 형식(이름 변경 없이, 바이너리 없이)으로 만든다
status=0
(cd "$work" && GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 \
  git diff --no-index --no-prefix --no-renames --no-ext-diff --no-textconv --no-color a b) >"$work/cachyos.patch" || status=$?
((status == 1)) || die "git diff 실패 또는 차이 없음 (exit $status)"
if grep -qE '^(Binary files |GIT binary patch)' "$work/cachyos.patch"; then
  die "바이너리 파일 차이가 있어 패치로 옮길 수 없음"
fi

# 4. 적용 결과가 CachyOS 트리와 같은지
log "kernel.org 트리에 패치 적용 후 CachyOS 트리와 비교"
(cd "$work/a" && patch -p1 --fuzz=0 --no-backup-if-mismatch --quiet -i "$work/cachyos.patch")
diff -r --no-dereference "$work/a" "$work/b" >/dev/null || die "패치 적용 결과가 CachyOS 트리와 다름"
diff <(cd "$work/a" && find . -printf '%y %m %p\n' | sort) <(cd "$work/b" && find . -printf '%y %m %p\n' | sort) >/dev/null ||
  die "패치 적용 결과의 파일 종류/권한이 CachyOS 트리와 다름"

# 5. 저장
mkdir -p kernel
cp "$work/cachyos.patch" kernel/cachyos.patch
jq -n --arg version "$version" --arg tag "$tag" \
  --arg korg_url "$korg_url" --arg korg_hash "$korg_hash" \
  --arg cachyos_url "$cachyos_url" --arg cachyos_hash "$cachyos_hash" '{
    version: $version,
    kernelOrg: { url: $korg_url, hash: $korg_hash },
    cachyos: { tag: $tag, url: $cachyos_url, hash: $cachyos_hash }
  }' >kernel/source.json
auth=()
[[ -n ${GITHUB_TOKEN:-} ]] && auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
curl -fsSL --retry 3 "${auth[@]}" "https://api.github.com/repos/CachyOS/linux/releases/tags/$tag" |
  jq -r .body >kernel/cachyos-release.md || log "릴리스 노트를 받지 못함 (건너뜀)"

files=$(grep -c '^diff --git' kernel/cachyos.patch)
size=$(du -h kernel/cachyos.patch | cut -f1)
log "완료: linux-$kver + $tag, 패치 파일 ${files}개 변경 ($size)"
if [[ -n ${GITHUB_STEP_SUMMARY:-} ]]; then
  echo "- 커널 소스 갱신: \`linux-$kver\` (kernel.org) + \`$tag\` 패치, 파일 ${files}개 변경" >>"$GITHUB_STEP_SUMMARY"
fi
