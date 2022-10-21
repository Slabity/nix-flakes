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

  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;

    # If you want to use it for ipv6
    "net.ipv6.conf.all.forwarding" = true;

    # source: https://github.com/mdlayher/homelab/blob/master/nixos/routnerr-2/configuration.nix#L52
    # By default, not automatically configure any IPv6 addresses.
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;

    # On WAN, allow IPv6 autoconfiguration and tempory address use.
    "net.ipv6.conf.enp2s0.accept_ra" = 2;
    "net.ipv6.conf.enp2s0.autoconf" = 1;
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
            } tcp dport { llmnr } counter accept


            # Accept all access from these trusted interfaces
            iifname {
              "lo",
              "br-lan0",
              "wg0",
            } counter accept


            # Allow certain ports access to the router
            iifname "enp2s0" tcp dport { ssh } counter accept
            iifname "enp2s0" udp dport {
              ${builtins.toString flake.secrets.wireguard.lapras.port}
            } counter accept

            # Allow returning traffic from enp2s0 and drop everthing else
            iifname "enp2s0" ct state { established, related } counter accept
            iifname "enp2s0" drop
          }

          # Enable flow offloading for better throughput
          flowtable f {
            hook ingress priority 0;
            devices = { enp2s0, enp3s0, enp4s0, enp5s0 };
          }

          chain forward {
            type filter hook forward priority filter; policy drop;

            # enable flow offloading for better throughput
            ip protocol { tcp, udp } flow offload @f

            # Allow trusted network WAN access
            iifname {
                    "br-lan0",
                    "wg0",
                    "lo",
            } oifname {
                    "enp2s0",
            } counter accept comment "Allow trusted LAN to WAN"

            # Allow established WAN to return
            iifname {
                    "enp2s0",
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

          # Setup NAT masquerading on the enp2s0 interface
          chain postrouting {
            type nat hook postrouting priority filter; policy accept;
            oifname {
              "enp2s0"
            } masquerade
          }
        }
      '';
    };
  };

  systemd.network = {
    enable = true;

    wait-online = {
      timeout = 10;
      ignoredInterfaces = [
        "wlan0"
        "wlan1"
        "wlp1s0"
      ];
    };

    netdevs = {
      br-lan0 = {
        netdevConfig = {
          Name = "br-lan0";
          Kind = "bridge";
        };
      };

      wg0 = {
        netdevConfig = {
          Name = "wg0";
          Kind = "wireguard";
        };

        wireguardConfig = {
          PrivateKeyFile = flake.secrets.wireguard.lapras.privateKey;
          ListenPort = flake.secrets.wireguard.lapras.port;
        };

        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = flake.secrets.wireguard.mew.publicKey;
              AllowedIPs = "10.100.0.0/24";
            };
          }
          {
            wireguardPeerConfig = {
              PublicKey = flake.secrets.wireguard.pichu.publicKey;
              AllowedIPs = "10.100.0.0/24";
            };
          }
        ];
      };
    };

    networks = {
      enp2s0 = {
        name = "enp2s0";
        DHCP = "yes";
        dhcpV4Config = {
          UseDNS = false;
        };
      };

      enp3s0 = {
        name = "enp3s0";
        DHCP = "no";
        bridge = [ "br-lan0" ];
      };

      enp4s0 = {
        name = "enp4s0";
        DHCP = "no";
        bridge = [ "br-lan0" ];
      };

      enp5s0 = {
        name = "enp5s0";
        DHCP = "no";
        bridge = [ "br-lan0" ];
      };

      wlan1 = {
        name = "wlan1";
        DHCP = "no";
      };

      wlp1s0 = {
        name = "wlp1s0";
        DHCP = "no";
      };

      br-lan0 = {
        name = "br-lan0";
        DHCP = "no";
        address = [ "192.168.200.1/24" ];
        networkConfig = {
          ConfigureWithoutCarrier = true;
          DHCPServer = true;
        };
        dhcpServerConfig = {
          PoolOffset = 20;
          DNS = [ "192.168.200.1" ];
        };
      };

      wg0 = {
        name = "wg0";
        DHCP = "no";
        address = [ "10.100.0.1/24" ];
      };
    };
  };

  services.resolved.enable = true;
  services.resolved.extraConfig = "DNSStubListener=no";

  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [
          "::"
          "0.0.0.0"
        ];
        access-control = [
          "0.0.0.0/0 allow"
          "::0/0 allow"
        ];
      };
      forward-zone = [
        {
          name = ".";
          forward-addr = [
            "1.1.1.1"
            "1.0.0.1"
          ];
        }
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
    interfaces = [
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
