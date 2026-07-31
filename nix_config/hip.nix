{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.rocmPackages.clr.icd ];
  };

  systemd.tmpfiles.rules = [
    "L+ /opt/rocm - - - - ${pkgs.rocmPackages.clr}"
  ];

  environment.systemPackages = with pkgs.rocmPackages; [
    rocminfo
    rocm-smi
    clr
    rocm-runtime
    rocblas
    hipblas
    rocm-device-libs
    hipcc
    rocm-cmake
    llvm.clang
  ];

  environment.variables = {
    ROCM_PATH = "/opt/rocm";
    HIP_PATH = "/opt/rocm";
    HIP_DEVICE_LIB_PATH = "${pkgs.rocmPackages.rocm-device-libs}/amdgcn/bitcode";
  };

  users.users."ilj900".extraGroups = [ "video" "render" ];
}
