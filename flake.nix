{
  description = "systing - a libbpf based system tracer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { 
	self,
	nixpkgs, 
	rust-overlay 
  }:
  let 
 	eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ]; 
  in 
  {
    packages = eachSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
      in
      {
        systing = pkgs.callPackage ./default.nix { };
        default = self.packages.${system}.systing;
      }
    );

    devShells = eachSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
      in
      {
        default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.systing ];

          nativeBuildInputs = with pkgs; [
            cargo
            rustc
            rustfmt
            clippy
          ];

          buildInputs = with pkgs; [
            antigravity-cli
            tmux
          ];

          shellHook = ''
            export CPATH="${pkgs.linuxHeaders}/include:${pkgs.glibc.dev}/include''${CPATH:+:$CPATH}"
            export SYSTING_BPF_CLANG="${pkgs.llvmPackages.clang-unwrapped}/bin/clang"
          '';
        };
      }
    );
  };
}
