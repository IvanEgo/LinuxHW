# Создаём 4 пула из двух дисков в режиме RAID 1:  
zpool create zpool1 mirror /dev/sdb /dev/sdc
zpool create zpool2 mirror /dev/sdd /dev/sde
zpool create zpool3 mirror /dev/sdf /dev/sdg
zpool create zpool4 mirror /dev/sdh /dev/sdi

# Добавляем разные алгоритмы сжатия в каждую файловую систему:  
Алгоритм lzjb: zfs set compression=lzjb zpool1
Алгоритм lz4:  zfs set compression=lz4 zpool2
Алгоритм gzip: zfs set compression=gzip-9 zpool3
Алгоритм zle:  zfs set compression=zle zpool4