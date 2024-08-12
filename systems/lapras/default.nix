{ config, lib, pkgs, flake, ... }:
with lib;
{
  imports = [
    ./hardware.nix
    flake.nixosModules.default
    flake.home-manager.nixosModules.home-manager
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "22.05";

  time.timeZone = "America/New_York";

  users.users.slabity = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  home-manager = {
    extraSpecialArgs = { inherit flake; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.slabity = {
      imports = [
        flake.homeManagerModules.default
      ];
      home.stateVersion = "22.05";

      fullName = "${flake.secrets.personal.fullName}";
      email = "${flake.secrets.personal.email}";
    };
  };

  services.openssh.enable = true;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    interfaceName = "wg0";
    extraSetFlags = [
      "--advertise-exit-node"
      "--advertise-routes=192.168.200.0/24"
      "--snat-subnet-routes=false"
    ];
  };

  networking = {
    hostName = "lapras";

    useDHCP = false;
    nat.enable = false;
    firewall.enable = false;
    useNetworkd = true;

    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
          # Allows all packets sent by the router itself
          chain output {
            type filter hook output priority 100; policy accept;
          }

          chain input {
            type filter hook input priority filter; policy drop;

            # Accept all access from these trusted interfaces
            iifname {
              "lo",
              "br-lan0",
              "wg0",
            } counter accept

            # Allow returning traffic from wan0 and drop everthing else
            iifname "wan0" ct state { established, related } counter accept
            iifname "wan0" drop
          }

          # Enable flow offloading for better throughput
          #flowtable f {
          #  hook ingress priority 0;
          #  devices = { wan0, br-lan0 };
          #}

          chain forward {
            type filter hook forward priority filter; policy drop;

            # enable flow offloading for better throughput
            #ip protocol { tcp, udp } flow offload @f

            # Allow trusted network WAN access
            iifname {
              "br-lan0",
              "wg0",
              "lo",
            } oifname {
              "wan0",
              "br-lan0",
              "wg0",
              "lo",
            } counter accept comment "Allow trusted LAN to WAN"

            # Allow established WAN to return
            iifname {
              "wan0",
            } oifname {
              "br-lan0",
              "wg0",
              "lo",
            } ct state established,related counter accept comment "Allow established back to LANs"
          }
        }

        table ip nat {
          chain prerouting {
            type nat hook output priority filter; policy accept;
          }

          # Setup NAT masquerading on the wan0 and wg0 interfaces
          chain postrouting {
            type nat hook postrouting priority filter; policy accept;
            oifname {
              "wan0",
              "wg0"
            } masquerade
          }
        }
      '';
    };
  };

  systemd.network = {
    enable = true;

    links = {
      "40-wan0" = {
        linkConfig.Name = "wan0";
        matchConfig.MACAddress = "00:e2:69:5c:75:b9";
      };
      "40-lan0" = {
        linkConfig.Name = "lan0";
        matchConfig.MACAddress = "00:e2:69:5c:75:ba";
      };
      "40-lan1" = {
        linkConfig.Name = "lan1";
        matchConfig.MACAddress = "00:e2:69:5c:75:bb";
      };
      "40-lan2" = {
        linkConfig.Name = "lan2";
        matchConfig.MACAddress = "00:e2:69:5c:75:bc";
      };
    };

    netdevs = {
      br-lan0 = {
        netdevConfig = {
          Name = "br-lan0";
          Kind = "bridge";
        };
      };
    };

    networks = {
      wan0 = {
        name = "wan0";
        DHCP = "yes";
        dhcpV4Config = {
          UseDNS = true;
        };
        linkConfig.RequiredForOnline = true;
      };

      lan0 = {
        name = "lan0";
        DHCP = "no";
        bridge = [ "br-lan0" ];
        linkConfig.RequiredForOnline = false;
      };

      lan1 = {
        name = "lan1";
        DHCP = "no";
        bridge = [ "br-lan0" ];
        linkConfig.RequiredForOnline = false;
      };

      lan2 = {
        name = "lan2";
        DHCP = "no";
        bridge = [ "br-lan0" ];
        linkConfig.RequiredForOnline = false;
      };

      br-lan0 = {
        name = "br-lan0";
        DHCP = "yes";
        address = [ "192.168.200.1/24" ];
        networkConfig = {
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = false;
      };
    };
  };

  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;

    # If you want to use it for ipv6
    "net.ipv6.conf.all.forwarding" = true;

    # On WAN, allow IPv6 autoconfiguration and tempory address use.
    "net.ipv6.conf.wan0.accept_ra" = 2;
    "net.ipv6.conf.wan0.autoconf" = 1;
  };

  services.resolved = {
    enable = true;
    extraConfig = "DNSStubListener=no";
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      interface = [ "br-lan0" ];

      domain-needed = true;
      domain = "lan";
      local = "/lan/";

      bogus-priv = true;
      dhcp-range = [ "192.168.200.20, 192.168.200.249" ];

      no-hosts = true;
      expand-hosts = true;

      addn-hosts = ''
        ${pkgs.writeText "dnsmasq-addn-hosts.conf" ''
          192.168.200.1 lapras
        ''}
      '';

      cache-size = 1000;
      server = [
        "1.1.1.1"
        "8.8.8.8"
        "8.8.4.4"
      ];
    };
  };

  # Use avahi for mDNS support
  services.avahi = {
    enable = true;
    reflector = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      userServices = true;
      workstation = true;
    };
    wideArea = true;
    allowInterfaces = [
      "br-lan0"
      "wg0"
    ];
  };

  environment.systemPackages = with pkgs; [
    ethtool
    tcpdump
    conntrack-tools
    inetutils
    bind
  ];
}
