{
  description = "kernel.org 공식 소스에 CachyOS 패치를 적용한 커널(Clang ThinLTO, x86-64-v3)과 NVIDIA open 모듈";

  # 소스: kernel.org 공식 tarball (kernel/source.json, 서명 검증 후 해시 고정)
  # 패치: CachyOS 릴리스와 kernel.org 소스의 차이 (kernel/cachyos.patch, scripts/update-source.sh 가 생성)
  # 설정과 빌드 코드: CachyOS 공식 config + xddxdd/nix-cachyos-kernel 의 mkCachyKernel
  inputs.nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

  outputs =
    { nix-cachyos-kernel, ... }:
    let
      system = "x86_64-linux";
      upstreamPackages = nix-cachyos-kernel.legacyPackages.${system};
      inherit (nix-cachyos-kernel.inputs.nixpkgs) lib;
      pkgs = nix-cachyos-kernel.inputs.nixpkgs.legacyPackages.${system};

      # nix-cachyos-kernel 이 따라가는 CachyOS 릴리스 (버전, CachyOS tarball, config)
      upstream = (lib.importJSON "${nix-cachyos-kernel}/kernel-cachyos/version.json").linux-cachyos;
      # 이 저장소가 고정한 kernel.org 소스와, 패치를 만든 CachyOS 릴리스
      source = lib.importJSON ./kernel/source.json;

      variant = "cachyos-latest-lto-x86_64-v3";

      kernel =
        assert lib.assertMsg (upstream.version == source.version && upstream.url == source.cachyos.url) ''
          kernel/source.json(${source.cachyos.url}) 이
          nix-cachyos-kernel(${upstream.url}) 과 다릅니다. scripts/update-source.sh 를 실행하세요.'';
        upstreamPackages."linux-${variant}".override {
          src = pkgs.fetchurl { inherit (source.kernelOrg) url hash; };
          # CachyOS 패치를 먼저 적용한다 (그 뒤에 NixOS 공통 패치가 붙는다)
          prePatch = ''
            patch -p1 --fuzz=0 --no-backup-if-mismatch --quiet -i ${./kernel/cachyos.patch}
          '';
        };

      # nix-cachyos-kernel 의 모듈 집합(NVIDIA 빌드 수정, LLVM 처리 포함)에서 커널만 바꾼다
      linuxPackages = upstreamPackages."linuxPackages-${variant}".extend (_: _: { inherit kernel; });
    in
    {
      # nixos-config: boot.kernelPackages = kernel-builder.legacyPackages.x86_64-linux.linuxPackages;
      legacyPackages.${system} = { inherit linuxPackages; };

      packages.${system} = {
        inherit kernel;
        nvidia-open = linuxPackages.nvidiaPackages.stable.open;
      };

      # scripts/update-source.sh 가 읽는다
      lib = { inherit upstream source; };
    };
}
