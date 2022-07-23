{
  hosts.suez = {
    ip_addr = "34.237.46.36";
    ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEaBHM1yjujL13+bMkRUTnNSxWjODSRszYfGgaR+tHIm";
    wireguard = {
      address.ipv4 = "10.131.0.1";
      address.ipv6 = "fd3b:fe0b:d86b:a5ec::1";
      port = 51820;
      publicKey = "tvkyo5f79SRK2k6opO4mwmreT9i6XnnR/imhpkHKSR8=";
    };
  };

  hosts.shanghai = {
    ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMuIgouw4tmR/OhZchYUyWKGTJL0AMTLXEOxRwqvHm41";
  };

  hosts.tugboat = {
    ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMuIgouw4tmR/OhZchYUyWKGTJL0AMTLXEOxRwqvHm41";
    wireguard = {
      address.ipv4 = "10.131.0.3";
      address.ipv6 = "fd3b:fe0b:d86b:a5ec::3";
      publicKey = "eEic9W7lQfNqR1TH36RSpfryZxLgN9+Is+vwEKUpIXk=";
    };
  };

  hosts.lagos = {
    ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBI2qx9/prfNZ+SzatkRncojXfDlUNrp7Iw7myA7qpK2";
    wireguard = {
      address.ipv4 = "10.131.0.4";
      address.ipv6 = "fd3b:fe0b:d86b:a5ec::4";
      publicKey = "fliR33PGLx4j0yCtRzfR1n+G7CVJEGUxsTqhtPgawDw=";
    };
  };

  hosts.paris = {
    ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKgvU8qHvL3jDg8Y58kAI0Ve9+oFwGEcYYt1VEg4kmnY";
    wireguard = {
      address.ipv4 = "10.131.0.5";
      address.ipv6 = "fd3b:fe0b:d86b:a5ec::5";
      publicKey = "RECd660P9pboF3RzR7fXTNDscoDsv2oyXrjTx5Fvp10=";
    };
  };

  hosts.carrier-1.wireguard = {
    address.ipv4 = "10.131.0.6";
    address.ipv6 = "fd3b:fe0b:d86b:a5ec::6";
    publicKey = "Wv72IMOYBx9B4xG1czdiJohWjSFZm4VcmP1hCyIhQCU=";
  };
  hosts.carrier-2.wireguard = {
    address.ipv4 = "10.131.0.7";
    address.ipv6 = "fd3b:fe0b:d86b:a5ec::7";
    publicKey = "tY2meLnHuaQun2TK9aueXA4/xOOIcEjuN/hk0QD3+lw=";
  };
  hosts.carrier-3.wireguard = {
    address.ipv4 = "10.131.0.8";
    address.ipv6 = "fd3b:fe0b:d86b:a5ec::8";
    publicKey = "xWnoOElw7Y+9H/RjKt47WZO11Q0DY12Hc4nCe1GlLgA=";
  };
  hosts.carrier-4.wireguard = {
    address.ipv4 = "10.131.0.9";
    address.ipv6 = "fd3b:fe0b:d86b:a5ec::9";
    publicKey = "0M0j8DZtcsW2959yQIMIzgKjUZR8PJTBDM9dlefESQw=";
  };
}
