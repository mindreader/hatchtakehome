{
  description = "Hatch Takehome Test";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:

  let

    pkgs = nixpkgs.legacyPackages.x86_64-linux;

    test = {
      type = "app";
      program =
        let elixir = pkgs.elixir;
        in (pkgs.writeShellScript "hatch-start" ''
            ${elixir}/bin/mix deps.get
            ${elixir}/bin/mix test
        '').outPath;
    };

    start = {
      type = "app";
      program =
        let elixir = pkgs.elixir;
        in (pkgs.writeShellScript "hatch-start" ''
            ${elixir}/bin/mix deps.get
            ${elixir}/bin/iex -S ${elixir}/bin/mix phx.server
        '').outPath;
    };
  in with pkgs; {


    # nix run
    apps.x86_64-linux.default = start;
    apps.armv7a-darwin.default = start; # I don't have a mac to test this on, but it might work.

    # nix run .#start
    apps.x86_64-linux.start = start;

    # nix run .#test
    apps.x86_64-linux.test = test;

    # nix develop
    devShells.x86_64-linux.default = pkgs.mkShell {

      name = "elixir-shell";
      packages = with pkgs; [ elixir elixir-ls inotify-tools sqlite ];
    };
  };
}
