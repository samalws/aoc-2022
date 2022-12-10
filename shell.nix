{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = [ pkgs.nasm pkgs.ghc pkgs.python3 pkgs.gdb ];
}
