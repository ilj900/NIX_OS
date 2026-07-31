{ pkgs, ... }:

let

  vulkan-sdk = pkgs.symlinkJoin {
    name = "vulkan-sdk";
    paths = with pkgs; [
      vulkan-headers              # <vulkan/vulkan.h>, vk.xml
      vulkan-loader               # libvulkan.so + dev
      vulkan-tools                # vulkaninfo, vkcube, vkcubepp
      vulkan-tools-lunarg         # vkconfig, via
      vulkan-validation-layers    # VK_LAYER_KHRONOS_validation
      vulkan-utility-libraries    # helper libs some layers/samples need
      vulkan-extension-layer      # optional extension emulation layers
      shaderc                     # glslc (GLSL -> SPIR-V)
      glslang                     # glslangValidator
      spirv-tools                 # spirv-dis / spirv-val / spirv-opt
      spirv-cross                 # SPIR-V -> GLSL/HLSL/MSL
    ];
  };
in
{
  environment.systemPackages = with pkgs; [
    vulkan-sdk
    renderdoc                     # GUI frame debugger (standalone app)
  ];

  environment.variables = {
    VULKAN_SDK = "${vulkan-sdk}";
    # Makes validation discoverable even where XDG_DATA_DIRS isn't set
    # (e.g. inside CLion's run env). Optional but robust.
    VK_LAYER_PATH = "${vulkan-sdk}/share/vulkan/explicit_layer.d";
  };
}
