{ pkgs, vulkanShell, hipShell, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    gitkraken
    claude-code
    jetbrains.clion
    clang
    clang-tools
    lldb
    llvmPackages.llvm
    cmake
    ninja

    (python313.withPackages (ps: with ps; [
      numpy
      matplotlib
    ]))

    (writeShellScriptBin "clion-vk" ''
        setsid nix develop "$HOME/NIX_OS/nix_config#vulkan" -c clion "$@" \
          >/dev/null 2>&1 < /dev/null &
      '')

    (writeShellScriptBin "clion-hip" ''
        setsid nix develop "$HOME/NIX_OS/nix_config#hip" -c clion "$@" \
          >/dev/null 2>&1 < /dev/null &
      '')
  ];

  system.activationScripts.devShellRoots.text = ''
    ln -sfn ${vulkanShell.inputDerivation} /nix/var/nix/gcroots/vulkan-dev
    ln -sfn ${hipShell.inputDerivation}    /nix/var/nix/gcroots/hip-dev
  '';
}
