{
  users.users.git = {
    isNormalUser = true;
    useDefaultShell = true;
    home = "/home/git";
    uid = 1500;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEPu4d15Bpe4aismAmXTrndwdXImNV8vsoLqhvwg754kGku8Fi8duamaTXdDftVG8cbS+1rA3u+tR+aFUqxaBtMO9jgwPlEAMMyMUj+jcrjGRlHe+XJgDVWFFdPbxHR7b9gYSahzzCHz1h5vAc3WTLUDIdz7EkG2LYERgR3FVHZ6v5Q8CSwWd741DiezkDGbhu8TBVrekKtLH6XC49J6mU03nJUe0oKk5mTbqYZFcn4IeFX98G068aYAQMuJQ9sjGYp5OlqPp1A3jHL755sjrrnBef2pJl0cd5wwgyUX0IxUdpjF8SR5RFZG1YNJDgGY4cCHCQvzw+lx0cLJHMDK5R lagos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBI2qx9/prfNZ+SzatkRncojXfDlUNrp7Iw7myA7qpK2 lagos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMuIgouw4tmR/OhZchYUyWKGTJL0AMTLXEOxRwqvHm41 tugboat"
    ];
  };
}
