{ pkgs }:

pkgs.mkShell {
  name = "hip-dev";

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    rocmPackages.rocm-cmake
    rocmPackages.hipcc
    rocmPackages.llvm.clang
    rocmPackages.rocminfo
    rocmPackages.rocm-smi
  ];

  buildInputs = with pkgs.rocmPackages; [
    clr              # HIP / OpenCL runtime
    rocm-runtime     # HSA runtime
    rocm-device-libs
    rocblas
    hipblas
  ];

  shellHook = ''
    export ROCM_PATH="${pkgs.rocmPackages.clr}"
    export HIP_PATH="${pkgs.rocmPackages.clr}"
    export HIP_DEVICE_LIB_PATH="${pkgs.rocmPackages.rocm-device-libs}/amdgcn/bitcode"
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
      pkgs.rocmPackages.clr
      pkgs.rocmPackages.rocm-runtime
      pkgs.rocmPackages.rocblas
      pkgs.rocmPackages.hipblas
    ]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

    echo "hip-dev shell ready — try: rocminfo | head"
  '';
}
