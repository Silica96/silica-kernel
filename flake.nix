{
  description = "CachyOS 커널(Clang ThinLTO, x86-64-v3)과 NVIDIA open 모듈을 직접 빌드하는 저장소";

  # 커널 소스/패치/설정은 CachyOS 공식 릴리스, Nix 빌드 코드는 xddxdd/nix-cachyos-kernel.
  # 이 저장소는 그 결과물을 남의 캐시 대신 직접(GitHub Actions) 빌드한다.
  inputs.nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

  outputs =
    { nix-cachyos-kernel, ... }:
    let
      # nixos-config 의 overlays.pinned 와 같은 패키지 집합 → derivation 이 같아 캐시가 적중한다
      kernelPackages =
        nix-cachyos-kernel.legacyPackages.x86_64-linux.linuxPackages-cachyos-latest-lto-x86_64-v3;
    in
    {
      packages.x86_64-linux = {
        kernel = kernelPackages.kernel;
        nvidia-open = kernelPackages.nvidiaPackages.stable.open;
      };
    };
}
