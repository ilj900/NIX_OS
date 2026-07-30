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
  ];

  users.users."ilj900".extraGroups = [ "video" "render" ];
}