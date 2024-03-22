# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config,lib, pkgs, ... }:








###
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

nix.distributedBuilds= true;

###############

      



#services.emacs.enable= true;

#services.emacs.enable= true;


###############
# services.emacs.defaultEditor= true;


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define Your Hostname.
  # Networking.Wireless.Enable = True;  # Enables Wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };


# Remove sound.enable or set it to false if you had it set previously, as sound.enable is only meant for ALSA-based configurations

# rtkit is optional but recommended
security.rtkit.enable = true;
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
  # If you want to use JACK applications, uncomment this
  #jack.enable = true;
};



###
services.xserver.windowManager.bspwm.configFile = "/home/murat/.config/bspwm/bspwmrc";
services.xserver.windowManager.bspwm.package = pkgs.bspwm;
services.xserver.windowManager.bspwm.enable = true;
services.xserver.windowManager.bspwm.sxhkd.package = pkgs.sxhkd;
services.xserver.windowManager.bspwm.sxhkd.configFile = "/home/murat/.config/sxhkd/sxhkdrc";

services.picom.settings = { enable = true; settings = {
 };
  config = "/home/murat/.config/picom/picom.conf";  # Optional, include if needed
};

###
services.xserver.enable= true;
services.xserver.displayManager.startx.enable= true;
#services.xserver.windowManager.dwm.enable = true;
#programs.zsh.enable= true;  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.murat = {
    isNormalUser = true;
    description = "murat";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
 # programs.zsh.ohMyZsh.enable= true;
  users.defaultUserShell= pkgs.zsh;

programs = {
   zsh = {
      enable = true;
      autosuggestions.enable = true;
      zsh-autoenv.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
         enable = true;
         theme = "robbyrussell";
         plugins = [
           "git"
           "npm"
           "history"
           "node"
           "rust"
           "deno"
         ];
      };
   };
};

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
   pkgs.vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  pkgs.wget
#pkgs.dmenu
#pkgs.st
pkgs.firefox
pkgs.neofetch
pkgs.google-chrome
pkgs.htop
pkgs.rclone
pkgs.vlc
pkgs.zsh
pkgs.oh-my-zsh
pkgs.git
pkgs.rclone
pkgs.xorg.xorgserver
pkgs.xorg.xf86inputlibinput
pkgs.feh
pkgs.android-studio
pkgs.ripgrep
pkgs.emacs
pkgs.xorg.xrandr
pkgs.emacsPackages.doom
pkgs.fd
pkgs.emacsPackages.doom-modeline
pkgs.emacsPackages.doom-themes
pkgs.gnumake42
    pkgs.pkg-config
pkgs.qemu_full
pkgs.coreutils
pkgs.clang
pkgs.screen
pkgs.lux
pkgs.qutebrowser
pkgs.kitty
pkgs.alacritty
pkgs.xterm
pkgs.dunst
pkgs.nitrogen
pkgs.sxhkd
pkgs.nitrogen
pkgs.bspwm
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
