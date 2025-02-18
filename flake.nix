{
  description = "Hatch Takehome Test";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:

  let

    pkgs = nixpkgs.legacyPackages.x86_64-linux;

    start = {
      type = "app";
      program = (pkgs.writeShellScript "hatch-start" ''
        ${pkgs.elixir}/bin/iex -S ${pkgs.elixir}/bin/mix
      '').outPath;
    };
  in with pkgs; {

    # nix run .#start
    apps.x86_64-linux.default = start;
    apps.x86_64-linux.start = start;

    # nix develop
    devShells.x86_64-linux.default = pkgs.mkShell {

      name = "elixir-shell";
      packages = with pkgs; [ elixir elixir-ls inotify-tools sqlite ];
    };
  };
}
