# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    inputs.impermanence.nixosModules.default
    inputs.home-manager.nixosModules.default

    ./rnnoise.nix
  ];

  # Enable Flakes by default
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };
  # Enable nonfree packages
  nixpkgs.config.allowUnfree = true;
  home-manager.useGlobalPkgs = true;

  # Allow home config to use inputs
  home-manager.extraSpecialArgs = {inherit inputs;};

  # Turn on middle click scroll for Chrome and Discord
  nixpkgs.overlays = [
    (final: prev: {
      # Enable GameMode detection (NixOS/nixpkgs#317406)
      xivlauncher = prev.xivlauncher.overrideAttrs (prevAttrs: {
        postFixup = let
          steam-run =
            (pkgs.steam.override {
              extraPkgs = p: [p.libunwind p.xdg-utils] ++ lib.optional config.programs.gamemode.enable p.gamemode;
              extraProfile = "unset TZ";
            }).run;
        in ''
          substituteInPlace $out/bin/XIVLauncher.Core \
            --replace-fail 'exec' 'exec ${steam-run}/bin/steam-run'

          wrapProgram $out/bin/XIVLauncher.Core --prefix GST_PLUGIN_SYSTEM_PATH_1_0 ":" "$GST_PLUGIN_SYSTEM_PATH_1_0"

          mkdir -p $out/nix-support
          echo ${pkgs.aria2} >> $out/nix-support/depends
        '';
      });
    })
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the safe option for loading the ZFS pool
  boot.zfs.forceImportRoot = false;
  # Scrub every once in a while
  services.zfs.autoScrub.enable = true;

  # Symlink out of /persist for important context files
  environment.persistence."/persist" = {
    enable = true;
    # Prevent /persist from showing up as a mount in file managers
    hideMounts = true;
    directories = ["/etc/ssh"];
    files = ["/etc/machine-id"];
  };

  networking.hostName = "hydrogen"; # Define your hostname.
  networking.hostId = "05EAF00D";

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocales = [
    # Celsius
    "en_DK.UTF-8/UTF-8"
    # YYYY-MM-DD HH:MM:SS
    "en_US_iso.UTF-8/UTF-8"
  ];
  i18n.extraLocaleSettings = {
    LC_MEASUREMENT = "en_DK.UTF-8";
    LC_TIME = "en_US_iso.UTF-8";
  };
  i18n.glibcLocales = pkgs.glibcLocales.overrideAttrs (prevAttrs: {
    postPatch =
      (prevAttrs.postPatch or "")
      + ''
        cp ${./en-US-iso.locale.txt} localedata/locales/en_US_iso
        echo 'en_US_iso.UTF-8/UTF-8 \' >> localedata/SUPPORTED
      '';
  });

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable graphics for an AMD GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.graphics.extraPackages = with pkgs; [
    # OpenCL
    rocmPackages.clr.icd
  ];

  services.xserver.videoDrivers = ["amdgpu"];

  # Force high-power mode
  boot.kernelParams = [
    "amdgpu.aspm=0"
  ];
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", KERNEL=="card*", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="high"
  '';
  programs.gamemode.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  my.rnnoise.micNodeName = "alsa_input.usb-Logi_USB_Headset_Logi_USB_Headset-00.mono-fallback";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Logitech G600
  services.ratbagd.enable = true;
  systemd.services.ratbagd.serviceConfig.Restart = lib.mkForce "always";

  # Use Doas instead of Sudo
  security.doas.enable = true;
  security.sudo.enable = false;
  security.doas.extraRules = [
    # wheel is enabled by default
    {
      groups = ["wheel"];
      keepEnv = false;
      persist = false;
    }
    {
      users = ["aly"];
      keepEnv = true;
      # Allow multiple doas in a time window
      persist = true;
    }
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users.aly = {
    isNormalUser = true;
    extraGroups = [
      # Enable ‘sudo’ for the user.
      "wheel"
      # Manage Wifi
      "networkmanager"

      "gamemode"
    ];
    hashedPasswordFile = "/persist/password/aly.txt";
    shell = pkgs.fish;
  };
  home-manager.users.aly = import ./home.nix;

  programs.chromium = {
    enable = true;
    extensions = [
      "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
      "fkagelmloambgokoeokbpihmgpkbgbfm" # Indie Wiki Buddy
      "hkgfoiooedgoejojocmhlaklaeopbecg" # Picture-in-Picture
      "donbcfbmhbcapadipfkeojnmajbakjdc" # Ruffle
      "ndcooeababalnlpkfedmmbbbgkljhpjf" # ScriptCat
      "likgccmbimhjbgkjambclfkhldnlhbnn" # Yomitan
    ];
  };

  programs.fish = {enable = true;};

  programs.git = {enable = true;};

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    nano
    curl
    (google-chrome.override {
      commandLineArgs = "--enable-blink-features=MiddleClickAutoscroll";
    })

    vulkan-tools
    clinfo

    cosmic-ext-applet-sysinfo
    cosmic-ext-applet-clipboard-manager
    cosmic-monitor

    piper
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable COSMIC
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.desktopManager.cosmic.xwayland.enable = true;

  # Tell Electron apps (Discord, etc.) to use Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Allow programs in other environments to use the XDG portals (FFXIV /patchnote, etc)
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?
}
