# nixos-configs

This flake contains configs for my NixOS machines and my in-progress ports and modules. Through multiple hardware changes (including the upgrade to 64-bit), some version of these configs has supported my computing needs. Flakeification of all the things happened in early 2022. ~~I'll try to keep this current with my true config, but the two will differ until I figure out what to do with some private info.~~ 2025 update: Secrets have been moved to a module in a private flake. See [modules/secrets.nix](modules/secrets.nix) for the attributes it sets. The secrets module is mostly a thin wrapper around [sops-nix](https://github.com/Mic92/sops-nix).

### shanghai

My media server, a 2009 Dell Desktop PC. Hosts Samba, Jellyfin, an IRC bouncer, and a few misc. services still in Docker land. btrfs has only failed me once.

### suez

The cheapest box you can get through Amazon Lightsail. Hosts a WireGuard VPN and an ad-blocking DNS.

### lagos

Small partition on my laptop for Linux development. User is managed with [home-manager](https://github.com/nix-community/home-manager). bcachefs because btrfs wasn't cool enough.

## References

This repository is brought to you by [Mic92/dotfiles](https://github.com/Mic92/dotfiles), [Xe/nixos-configs](https://github.com/Xe/nixos-configs) (and their fantastic [blog](https://xeiaso.net/blog)), [hlissner/dotfiles](https://github.com/hlissner/dotfiles), [utdemir/dotfiles-nix](https://github.com/utdemir/dotfiles-nix), [colemickens/nixos-flake-example](https://github.com/colemickens/nixos-flake-example), [Eelco Dolstra's flake introduction](https://www.tweag.io/blog/2020-05-25-flakes/), and too many hours of my life spent staring at the [nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/).

<br />

#### License

<sup>
Copyright (C) jae beller, 2019-2025.
</sup>
<br />
<sup>
Released under the <a href="https://www.gnu.org/licenses/gpl-3.0.txt">GNU General Public License, Version 3</a> or later. See <a href="LICENSE">LICENSE</a> for more information.
</sup>
