sudo su

# Зануляем суперблоки:
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g} 

# Создаем RAID10 на 6 дисках:
mdadm --create --verbose /dev/md0 -l 10 -n 6 /dev/sd{b,c,d,e,f,g}

# Создаем раздел GPT на RAID:
parted -s /dev/md0 mklabel gpt

# Создаем партиции:
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%

# Создаем файловую систему:
for i in $(seq 1 5); do mkfs.ext4 /dev/md0p$i; done

# И монтируем по каталогам:
mkdir -p /raid/part{1,2,3,4,5}  
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done