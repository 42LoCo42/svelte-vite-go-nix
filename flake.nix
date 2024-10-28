{
  outputs = { flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; }; in rec {
        packages.default = (pkgs.buildGoModule rec {
          pname = "svelte-vite-go-nix";
          version = "0.0.1";
          src = ./.;

          ##### fetch #####

          pnpmDeps = pkgs.pnpm.fetchDeps {
            inherit pname version src;
            hash = "sha256-OGn8kjlLEmadvLnkd24b2rNuczLdvrnbQaQSxoqL8XE=";
          };

          vendorHash = "sha256-tbYafktlM84YLYZvhY2kaeYwlFrWGeFXGnKCEbpAYos=";

          ##### build #####

          nativeBuildInputs = with pkgs; [
            nodejs
            pnpm.configHook
          ];

          preBuild = "pnpm build";

          CGO_ENABLED = "0";
          ldflags = [ "-s" "-w" ];
          tags = [ "prod" ];
        }).overrideAttrs (old: {
          passthru = old.passthru // {
            overrideModAttrs = old: {
              nativeBuildInputs =
                pkgs.lib.remove
                  pkgs.pnpm.configHook
                  old.nativeBuildInputs;

              preBuild = "";
            };
          };
        });

        devShells.default = pkgs.mkShell {
          inputsFrom = [ packages.default ];
          packages = with pkgs; [
            air
            svelte-language-server
          ];
        };
      });
}
