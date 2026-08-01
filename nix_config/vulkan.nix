{ pkgs }:

pkgs.mkShell {
  name = "vulkan-dev";

  nativeBuildInputs = with pkgs; [
    cmake                  # only to populate CMAKE_PREFIX_PATH via Nix's setup hook
    pkg-config
    wayland-scanner
    vulkan-tools
  ];

  buildInputs = with pkgs; [
    # --- Vulkan SDK ---
    vulkan-headers
    vulkan-loader
    vulkan-validation-layers
    shaderc
    shaderc.static         # libshaderc_combined.a -> Vulkan::shaderc_combined
    glslang
    spirv-tools
    # --- GLFW (built from submodule) windowing deps ---
    wayland wayland-protocols libxkbcommon libGL
    xorg.libX11 xorg.libXrandr xorg.libXinerama xorg.libXcursor xorg.libXi
  ];

  shellHook = ''
    export VK_LAYER_PATH="${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d"
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
      pkgs.vulkan-loader pkgs.wayland pkgs.libxkbcommon pkgs.libGL
    ]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

    echo "vulkan-dev shell ready — try: vulkaninfo | head"
  '';
}
