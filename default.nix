{ lib
, rustPlatform
, pkg-config
, cmake
, protobuf
, elfutils
, zlib
, linuxHeaders
, llvmPackages
, glibc
}:

rustPlatform.buildRustPackage {
  pname = "systing";
  version = "1.26.5";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./.cargo
      ./Cargo.lock
      ./Cargo.toml
      ./build.rs
      ./crates
      ./heap
      ./protos
      ./src
    ];
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "blazesym-0.2.6" = "sha256-bQVzLUgwiUqsPGJKgvWnwyNu6iyuKPFWtsR+2BcWclI=";
    };
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    protobuf
    llvmPackages.clang
  ];

  buildInputs = [
    elfutils
    zlib
    linuxHeaders
  ];

  SYSTING_BPF_CLANG = "${llvmPackages.clang-unwrapped}/bin/clang";
  CPATH = "${linuxHeaders}/include:${glibc.dev}/include";

  # Integration tests require root / BPF privileges
  doCheck = false;

  meta = with lib; {
    description = "A libbpf based tracer to figure out what an application is doing";
    homepage = "https://github.com/EstAK/systing";
    license = licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" "riscv64-linux" ];
    mainProgram = "systing";
  };
}
