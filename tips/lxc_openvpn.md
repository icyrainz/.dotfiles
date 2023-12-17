- Update the lxc config:
 
$ vi /etc/pve/lxc/123.conf

- Add or change the following lines:

 lxc.cgroup2.devices.allow: c 10:200 rwm
 lxc.mount.entry: /dev/net dev/net none bind,create=dir

- For your unprivileged container to be able to access the /dev/net/tun from your host, you need to set the owner by running
$ chown 100000:100000 /dev/net/tun

