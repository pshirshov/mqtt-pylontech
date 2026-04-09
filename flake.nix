{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        lib = pkgs.lib;
        rustManifest = lib.importTOML ./Cargo.toml;

        pylontechMqttAdapter = pkgs.rustPlatform.buildRustPackage {
          pname = rustManifest.package.name;
          version = rustManifest.package.version;
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs.buildPackages; [
            cargo
            rustc
            rustfmt
            clippy
            mosquitto
          ];
        };

        packages.default = pylontechMqttAdapter;

        apps.default = {
          type = "app";
          program = "${self.packages."${system}".default}/bin/pylontech-mqtt-adapter";
        };
      }
      );
}
