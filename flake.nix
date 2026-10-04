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
          nativeBuildInputs = with pkgs; [
            # rustToolchain
            pkg-config
            cmake
            protobuf
            #clangBpfWrapper
          ];

          buildInputs = with pkgs; [
            elfutils     # libelf, libdw - needed by libbpf-sys and blazesym
            zlib         # needed by libbpf-sys
            linuxHeaders # kernel headers (asm/, linux/) for BPF compilation
	    antigravity-cli
            tmux
          ];
          };
        }
      );


  };
}
