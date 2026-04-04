function disk-mount -d "Mount/unmount homelab network shares"
    # Config loaded from ~/.config/fish/include/ignore/disks.fish
    # Format: "name|type|source" (type: nfs or smb)
    if not set -q _disk_config; or test (count $_disk_config) -eq 0
        echo "No disks configured. Add entries to ~/.config/fish/include/ignore/disks.fish"
        return 1
    end

    set -l names
    for entry in $_disk_config
        set -la names (string split '|' $entry)[1]
    end

    set -l name $argv[1]
    set -l action $argv[2]

    if test -z "$name"
        echo "Usage: disk-mount <name> [mount|unmount|status]"
        echo "Available: $names"
        for d in $names
            set -l mp /Volumes/$d
            if mount | grep -q "$mp"
                echo "  $d  mounted at $mp"
            else
                echo "  $d  not mounted"
            end
        end
        return 0
    end

    if not contains -- $name $names
        echo "Unknown disk: $name"
        echo "Available: $names"
        return 1
    end

    # Find the matching config entry
    set -l dtype
    set -l source
    for entry in $_disk_config
        set -l parts (string split '|' $entry)
        if test "$parts[1]" = "$name"
            set dtype $parts[2]
            set source $parts[3]
            break
        end
    end

    set -l mountpoint /Volumes/$name

    switch "$action"
        case "" mount
            if mount | grep -q "$mountpoint"
                echo "$name already mounted at $mountpoint"
                return 0
            end
            switch $dtype
                case nfs
                    sudo mkdir -p $mountpoint
                    sudo mount -t nfs -o resvport,rw,nolock $source $mountpoint
                case smb
                    open $source
            end
            and echo "Mounted $name at $mountpoint"
        case unmount umount
            if not mount | grep -q "$mountpoint"
                echo "$name is not mounted"
                return 0
            end
            sudo umount $mountpoint
            and echo "Unmounted $name"
        case status
            if mount | grep -q "$mountpoint"
                echo "$name is mounted at $mountpoint"
                df -h $mountpoint
            else
                echo "$name is not mounted"
            end
        case '*'
            echo "Usage: disk-mount $name [mount|unmount|status]"
    end
end
