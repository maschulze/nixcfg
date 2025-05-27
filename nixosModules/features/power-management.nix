{ ... }:
{
  # boot.kernelParams = ["amd_pstate=guided"];

  # powerManagement = {
  #   enable = true;
  #   cpuFreqGovernor = "schedutil";
  # };

  # services = {
  #   auto-cpufreq.enable = true;
  # };

  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true; # Enable the TLP power management service

    settings = {
      # CPU governor settings for AC and battery
      CPU_SCALING_GOVERNOR_ON_AC = "performance"; # Use 'performance' governor when on AC power
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave"; # Use 'powersave' governor when on battery

      # CPU energy/performance policy
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance"; # Balanced policy on battery
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance"; # Favor performance on AC

      # CPU driver operation mode
      CPU_DRIVER_OPMODE_ON_AC = "active"; # Set CPU driver to 'active' mode on AC
      CPU_DRIVER_OPMODE_ON_BAT = "active"; # Set CPU driver to 'active' mode on battery

      # WiFi power saving
      WIFI_PWR_ON_AC = "on"; # Enable WiFi power saving on AC
      WIFI_PWR_ON_BAT = "on"; # Enable WiFi power saving on battery

      # Runtime power management for PCI devices
      RUNTIME_PM_ON_AC = "auto"; # Enable runtime PM on AC
      RUNTIME_PM_ON_BAT = "auto"; # Enable runtime PM on battery

      # CPU performance limits
      CPU_MIN_PERF_ON_AC = 10; # Minimum CPU performance percent on AC
      CPU_MAX_PERF_ON_AC = 90; # Maximum CPU performance percent on AC
      CPU_MIN_PERF_ON_BAT = 10; # Minimum CPU performance percent on battery
      CPU_MAX_PERF_ON_BAT = 50; # Maximum CPU performance percent on battery

      # CPU turbo/boost settings
      CPU_BOOST_ON_AC = 1; # Enable CPU turbo/boost on AC
      CPU_BOOST_ON_BAT = 0; # Disable CPU turbo/boost on battery
      CPU_HWP_DYN_BOOST_ON_AC = 1; # Enable HWP dynamic boost on AC
      CPU_HWP_DYN_BOOST_ON_BAT = 0; # Disable HWP dynamic boost on battery

      # Battery charging thresholds (for supported laptops)
      START_CHARGE_THRESH_BAT0 = 75; # Start charging when battery drops below 75%
      STOP_CHARGE_THRESH_BAT0 = 80; # Stop charging when battery reaches 80%

      # Memory sleep state
      MEM_SLEEP_ON_AC = "deep"; # Use 'deep' sleep state on AC
      MEM_SLEEP_ON_BAT = "deep"; # Use 'deep' sleep state on battery

      # Platform profile (if supported by hardware)
      PLATFORM_PROFILE_ON_AC = "performance"; # Set platform profile to performance on AC
      PLATFORM_PROFILE_ON_BAT = "low-power"; # Set platform profile to low-power on battery

      # Radeon GPU power management
      RADEON_DPM_STATE_ON_AC = "performance"; # Radeon: performance state on AC
      RADEON_DPM_STATE_ON_BAT = "battery"; # Radeon: battery state on battery
      RADEON_POWER_PROFILE_ON_AC = "high"; # Radeon: high power profile on AC
      RADEON_POWER_PROFILE_ON_BAT = "low"; # Radeon: low power profile on battery

      # Intel GPU minimum frequency (in MHz)
      INTEL_GPU_MIN_FREQ_ON_AC = 600; # Set Intel GPU min freq on AC
      INTEL_GPU_MIN_FREQ_ON_BAT = 600; # Set Intel GPU min freq on battery
    };
  };
}
