{ pkgs, ... }:

{
  # Set system state version
  system.stateVersion = "24.11";

  # Networking
  networking.firewall.allowedTCPPorts = [ 22 80 443 6901 ];

  # SSH
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true; # For PoC simplicity
  services.openssh.settings.PermitRootLogin = "yes";

  # Docker/Podman
  virtualisation.docker.enable = true;

  # KasmVNC Container
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.kasmvnc = {
    image = "kasmweb/core-xfce-desktop:1.15.0";
    ports = [ "6901:6901" ];
    environment = {
      VNC_PW = "nixypoc";
      KASM_USER = "nixy";
      KASM_PW = "nixypoc";
    };
    extraOptions = [ "--shm-size=512m" ];
  };

  # Nginx Reverse Proxy
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."localhost" = {
      locations."/" = {
        proxyPass = "https://127.0.0.1:6901";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_ssl_verify off; # KasmVNC uses self-signed certs by default
        '';
      };
    };
  };

  # Users
  users.users.nixy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    password = "nixy";
    openssh.authorizedKeys.keys = [
      # User can add their SSH key here later
    ];
  };

  # Enable sudo for the nixy user
  security.sudo.wheelNeedsPassword = false;

  # Base packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    docker-compose
  ];

  # GCE image settings
  virtualisation.googleComputeImage.diskSize = 10240; # 10GB
}
