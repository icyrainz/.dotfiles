- Mount disk to host (for /mnt/disk2)
    - mount -o rw /dev/nvme1n1p1 disk2
    - Equivalent item in /fstab
        - /dev/nvme1n1p1 /disk2 ext4 rw 0 2

- Edit lxc config to add new mountpoint:
    - mp0: /mnt/disk2/,mp=/disk2

- Mount SAMBA (cifs) path to mnt
    - mount -t cifs -o username=akio //192.168.0.183/wd_game_data /mnt/wd_game_data

- Passthrough proxmox disk to VM
    - lshw -class disk -class storage
    - Find the product: /dev/disk/by-id/ata-xxxxxxxxx-xxxxx_xxx
    - qm set 100 -scsi5 /dev/disk/by-id/ata-xxxxxxxxx-xxxxx_xxx
    - Update the serial number: virtio1: /dev/disk/by-id/ata-WDC_xxxxxxx-xxxxxxxxxxxxxx,size=xxxxxxK,serial=xxxxxx-xxxxxxx

