# silica-kernel

CachyOS 커널(`linux-cachyos-latest`, Clang ThinLTO, x86-64-v3)과 그 커널용 NVIDIA open 모듈을
GitHub Actions 에서 직접 빌드해 내 Cachix 캐시에 올리는 저장소입니다.

- 커널 소스, 패치, 설정: CachyOS 공식 릴리스
- Nix 빌드 코드: [xddxdd/nix-cachyos-kernel](https://github.com/xddxdd/nix-cachyos-kernel) (`release` 브랜치)
- 빌드와 바이너리: 이 저장소의 Actions → 남의 바이너리 캐시를 신뢰하지 않아도 된다

## 동작

| 계기 | 하는 일 |
|---|---|
| 매일 03:00 (KST) | `nix-cachyos-kernel` 을 갱신해 보고, 바뀌었으면 빌드 → 캐시 업로드 → `flake.lock` 커밋 |
| `flake.nix`/`flake.lock`/워크플로 push | 현재 잠긴 버전 그대로 빌드 |
| 수동 실행 (Actions → build-kernel → Run workflow) | 선택에 따라 갱신 후 빌드 |

빌드 시간과 디스크 사용량은 각 실행의 Summary 에 기록됩니다.

## 캐시 연결 (Cachix)

1. https://app.cachix.org 에서 공개 캐시를 만들고, 쓰기 권한 토큰을 발급
2. 이 저장소 Settings → Secrets and variables → Actions
   - Variables: `CACHIX_CACHE` = 캐시 이름
   - Secrets: `CACHIX_AUTH_TOKEN` = 토큰
3. 둘 다 있으면 다음 실행부터 빌드 결과가 캐시에 올라간다 (없으면 빌드만 한다)

## nixos-config 에서 쓰기

같은 `nix-cachyos-kernel` 리비전을 써야 캐시가 적중하므로, 이 저장소를 입력으로 받아 `follows` 한다.

```nix
inputs = {
  kernel-builder.url = "github:Silica96/silica-kernel";
  nix-cachyos-kernel.follows = "kernel-builder/nix-cachyos-kernel";
};
```

```nix
nix.settings = {
  substituters = [ "https://<캐시 이름>.cachix.org" ];
  trusted-public-keys = [ "<캐시 이름>.cachix.org-1:<공개키>" ];
};
boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
```
