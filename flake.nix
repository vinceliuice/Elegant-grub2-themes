{
  description = "Elegant GRUB2 Theme as a Nix Flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.elegant-grub-theme =
      { config ? {
          variant = "float";
          side = "left";
          color = "dark";
          resolution = "1080p";
          background = "mojave";
          logo = false;
          info = false;
        }
      }:
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in
      pkgs.stdenv.mkDerivation {
        pname = "elegant-grub-theme";
        version = "latest";

        src = ./.;

        nativeBuildInputs = with pkgs; [ grub2 freetype ];

        buildPhase = ''
          cd common
          for font in *.ttf; do
            ${pkgs.grub2}/bin/grub-mkfont -s 32 -o "$(basename "$font" .ttf).pf2" "$font"
          done
          cd ..
        '';

        installPhase = ''
          mkdir -p $out/theme
          cp config/theme-${config.variant}-${config.side}-${config.color}-${config.resolution}.txt $out/theme/theme.txt
          cp backgrounds/backgrounds-${config.background}/background-${config.background}-${config.variant}-${config.side}-${config.color}.jpg $out/theme/background.jpg
          cp -r common/*.pf2 $out/theme/
          mkdir -p $out/theme/icons
          cp -r assets/assets-icons-${config.color}/icons-${config.color}-${config.resolution}/* $out/theme/icons/
          cp -r assets/assets-other/other-${config.resolution}/select_c-${config.background}-${config.color}.png $out/theme/select_c.png
          cp -r assets/assets-other/other-${config.resolution}/select_e-${config.background}-${config.color}.png $out/theme/select_e.png
          cp -r assets/assets-other/other-${config.resolution}/select_w-${config.background}-${config.color}.png $out/theme/select_w.png

          if ${config.logo}; then
            cp assets/assets-other/other-${config.resolution}/Nixos.png $out/theme/logo.png
          else
            cp assets/assets-other/other-${config.resolution}/Empty.png $out/theme/logo.png
          fi

          if ${config.info}; then
            cp assets/assets-other/other-${config.resolution}/${config.variant}-${config.side}.png $out/theme/info.png
          else
            cp assets/assets-other/other-${config.resolution}/Empty.png $out/theme/info.png
          fi
        '';
      };
  };
}
