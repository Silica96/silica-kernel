# silica-kernel

kernel.org 공식 커널 소스에 CachyOS 패치를 적용한 커널(Clang ThinLTO, x86-64-v3)과
그 커널용 NVIDIA open 모듈을 GitHub Actions 에서 빌드해 내 Cachix 캐시에 올리는 저장소입니다.

| 구성 요소 | 출처 | 위치 |
|---|---|---|
| 커널 소스 | kernel.org 공식 tarball (서명 검증 후 해시 고정) | `kernel/source.json` |
| CachyOS 패치 | CachyOS 릴리스 트리와 kernel.org 소스의 차이 | `kernel/cachyos.patch` |
| 패치 내역 | CachyOS 릴리스 노트 (적용된 브랜치와 커밋 목록) | `kernel/cachyos-release.md` |
| 커널 설정 | CachyOS 공식 `linux-cachyos/config` + PKGBUILD 기본 옵션 | `nix-cachyos-kernel` |
| Nix 빌드 코드 | [xddxdd/nix-cachyos-kernel](https://github.com/xddxdd/nix-cachyos-kernel) (`release` 브랜치) | `flake.lock` |

## 패치를 만드는 방법

CachyOS 는 7.x 부터 기본 패치를 파일로 따로 배포하지 않고, 업스트림 커널에 패치 브랜치를 합친
[CachyOS/linux](https://github.com/CachyOS/linux) 트리를 릴리스합니다.
`scripts/update-source.sh` 는 그 차이를 직접 뽑아 냅니다.

1. kernel.org 의 `linux-<버전>.tar.xz` 를 받아 kernel.org 개발자 서명(WKD 의 Linus/Greg/Sasha 키)으로 검증
2. 같은 버전의 CachyOS 릴리스 tarball 을 받아 CachyOS PKGBUILD 의 `validpgpkeys` 서명과
   nix-cachyos-kernel 이 고정한 해시로 검증
3. 두 트리의 차이를 `kernel/cachyos.patch` 로 저장 (이름 변경, 권한 변경도 GNU patch 형식으로 포함)
4. kernel.org 트리에 패치를 적용한 결과가 CachyOS 트리와 내용, 권한까지 같은지 확인

빌드할 때는 kernel.org 소스에 이 패치를 먼저 적용하고, 그 뒤에 NixOS 공통 패치 2개를 적용합니다.
결과 소스는 CachyOS tarball 을 쓰던 이전 빌드와 바이트 단위로 같습니다 (7.3.4 에서 NAR 해시로 확인).

직접 다시 만들려면 (nix, curl, gpg, xz, jq, openssl, git, patch 필요):

```sh
FORCE=1 ./scripts/update-source.sh
git diff --stat kernel/
```

## 동작

| 계기 | 하는 일 |
|---|---|
| 매일 03:00 (KST) | `nix-cachyos-kernel` 을 갱신해 보고, CachyOS 릴리스가 바뀌었으면 소스/패치를 다시 만들어 빌드 → 캐시 업로드 → 커밋 |
| `flake.nix`/`flake.lock`/`kernel/`/`scripts/`/워크플로 push | 현재 고정된 버전 그대로 빌드 |
| 수동 실행 (Actions → build-kernel → Run workflow) | 선택에 따라 갱신 후 빌드 |

- 결과물이 이미 캐시에 있으면 빌드를 건너뜁니다.
- 갱신 내용은 빌드가 성공했을 때만 커밋하므로, 이 저장소의 최신 커밋은 항상 캐시에 있습니다.
- `kernel/source.json` 이 `nix-cachyos-kernel` 의 CachyOS 릴리스와 어긋나면 평가 단계에서 멈춥니다.

빌드 시간과 디스크 사용량은 각 실행의 Summary 에 기록됩니다.

## 캐시 연결 (Cachix)

1. 캐시: https://app.cachix.org/cache/silica-kernel (공개). 쓰기 권한 토큰을 발급
2. 이 저장소 Settings → Secrets and variables → Actions
   - Variables: `CACHIX_CACHE` = `silica-kernel`
   - Secrets: `CACHIX_AUTH_TOKEN` = 토큰
3. 둘 다 있으면 다음 실행부터 빌드 결과가 캐시에 올라간다 (없으면 빌드만 한다)

## nixos-config 에서 쓰기

커널 집합을 이 저장소에서 그대로 가져와야 캐시가 적중합니다 (`follows` 하지 않음).

```nix
inputs.kernel-builder.url = "github:Silica96/silica-kernel";
```

```nix
nix.settings = {
  substituters = [ "https://silica-kernel.cachix.org" ];
  trusted-public-keys = [ "silica-kernel.cachix.org-1:Cs5YEmxBcazT+pcFz2kB7k3QrsqksebJOtmYKoZPM30=" ];
};
boot.kernelPackages = inputs.kernel-builder.legacyPackages.x86_64-linux.linuxPackages;
```
