{
  description = "Nativum 公式サイト (サンプル) — nativum.css による静的サイト";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # 公式 Release (v0.1.0) を固定参照。更新はタグを上げて nix flake update
    nativum.url = "github:hnkNkm/nativum/v0.1.0";
  };

  outputs = { self, nixpkgs, flake-utils, nativum }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # 公式 Release の成果物 (dist/nativum.css) は git 管理されているため、
        # nativum パッケージのビルドを経ずにソースから直接取得する。
        # パッケージビルドは Nix sandbox (Linux) で /usr/bin/env 不在のため失敗する。
        nativum-css = "${nativum}/dist/nativum.css";
      in
      {
        # サイト本体: public/ のコンテンツ + 公式 Release の nativum.css を組み立てる
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "nativum-site";
          version = "0.1.0";

          src = ./public;

          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp -r . $out/
            cp ${nativum-css} $out/assets/css/nativum.css
            runHook postInstall
          '';
        };

        apps.serve = {
          type = "app";
          program = toString (pkgs.writeShellScript "nativum-site-serve" ''
            cd ${self.packages.${system}.default}
            exec ${pkgs.python3}/bin/python3 -m http.server "''${1:-8000}"
          '');
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            python3
            nixpkgs-fmt
          ];

          shellHook = ''
            echo "nativum-site dev shell — serve: nix run .#serve / local: http://localhost:8000"
          '';
        };
      });
}
