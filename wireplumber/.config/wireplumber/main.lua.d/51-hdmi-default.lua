-- Set LG HDR 4K HDMI as default audio sink
rule = {
  matches = {
    {
      { "node.name", "matches", "alsa_output.pci-0000_0b_00.1.hdmi-stereo-extra1" },
    },
  },
  apply_properties = {
    ["node.priority.driver"] = 2000,
    ["node.priority.session"] = 2000,
  },
}

table.insert(alsa_monitor.rules, rule)