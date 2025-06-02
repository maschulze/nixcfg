{ ... }:
{
  # Configure storage devices using disko
  disko.devices = {
    disk = {
      nixos = {
        type = "disk"; # This defines a physical disk
        device = "/dev/sda"; # The device path for the disk

        content = {
          type = "gpt"; # Use a GPT partition table
          partitions = {
            # BIOS Boot Partition, required for GRUB in BIOS mode with GPT
            boot = {
              size = "1M";
              type = "EF02"; # Partition type EF02 is for BIOS boot (GRUB MBR)
            };

            # EFI System Partition, required for UEFI boot
            ESP = {
              size = "512M"; # 512 MB for the EFI System Partition
              type = "EF00"; # Partition type EF00 is for EFI System Partition
              content = {
                type = "filesystem";
                format = "vfat"; # EFI partitions must be FAT32/vfat
                mountpoint = "/boot"; # Mount at /boot for bootloader and kernels
              };
            };

            # Root partition for the main filesystem
            root = {
              size = "100%"; # Use the remaining disk space
              content = {
                type = "filesystem";
                format = "ext4"; # Use ext4 filesystem for root
                mountpoint = "/"; # Mount at root
              };
            };
          };
        };
      };
    };
  };
}
