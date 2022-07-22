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
}
