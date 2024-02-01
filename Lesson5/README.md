# Занятие 5. Работа с mdadm

## Цель домашнего задания:  
Научиться использовать утилиту для управления программными RAID-массивами в Linux.

## Описание домашнего задания:  
- Добавить в Vagrantfile еще дисков
- собрать R0/R5/R10 на выбор
- прописать собранный рейд в конф, чтобы рейд собирался при загрузке
- сломать/починить raid
- создать GPT раздел и 5 партиций и смонтировать их на диск

Задание было выполнено согласно шагам из методички:  
https://drive.google.com/file/d/1phsvBYkiRPVrDG0EXagy-TF4P5y9XOAX/view

В изначальный Vagrant файл были добавлены два диска:  
   :sata5 => {  
      :dfile => './sata5.vdi',  
      :size => 250, # Megabytes  
      :port => 5  
   ,  
   sata6=> {  
      :dfile => './sata6.vdi',  
      :size => 250, # Megabytes  
      :port => 6  
   }  

vagrant up  
vagrant ssh  
[vagrant@otuslinux ~]$ sudo lsblk  
_NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT  
sda      8:0    0   40G  0 disk  
`-sda1   8:1    0   40G  0 part /  
sdb      8:16   0  250M  0 disk  
sdc      8:32   0  250M  0 disk  
sdd      8:48   0  250M  0 disk  
sde      8:64   0  250M  0 disk  
sdf      8:80   0  250M  0 disk  
sdg      8:96   0  250M  0 disk_  

### Создаем RAID:  

Зануляем суперблоки:  
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}  

Создаем RAID10 на 6 дисках:  
mdadm --create --verbose /dev/md0 -l 10 -n 6 /dev/sd{b,c,d,e,f,g}  

cat /proc/mdstat  
_d0 : active raid10 sdg[5] sdf[4] sde[3] sdd[2] sdc[1] sdb[0]  
      761856 blocks super 1.2 512K chunks 2 near-copies [6/6] [UUUUUU]  
      [===========>.........]  resync = 59.5% (453888/761856) finish=0.2min speed=18912K/sec_  

mdadm -D /dev/md0  
  _Version : 1.2  
     Creation Time : Thu Feb  1 13:25:09 2024  
        Raid Level : raid10  
        Array Size : 761856 (744.00 MiB 780.14 MB)  
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)  
      Raid Devices : 6  
     Total Devices : 6  
       Persistence : Superblock is persistent  
   Number   Major   Minor   RaidDevice State  
       0       8       16        0      active sync set-A   /dev/sdb  
       1       8       32        1      active sync set-B   /dev/sdc  
       2       8       48        2      active sync set-A   /dev/sdd  
       3       8       64        3      active sync set-B   /dev/sde  
       4       8       80        4      active sync set-A   /dev/sdf  
       5       8       96        5      active sync set-B   /dev/sdg_  

### Прописываем рейд в конф:  
sudo mkdir /etc/mdadm  
echo "DEVICE partitions" | sudo tee /etc/mdadm/mdadm.conf  
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' | sudo tee --append /etc/mdadm/mdadm.conf  

cat /etc/mdadm/mdadm.conf  
   _DEVICE partitions  
   ARRAY /dev/md0 level=raid10 num-devices=6 metadata=1.2 name=otuslinux:0 UUID=309d00c7:1932ac5f:134fa753:446dbd21_  

### Ломаем-чиним RAID:  
mdadm /dev/md0 --fail /dev/sde  

cat /proc/mdstat  
Personalities : [raid10]  
md0 : active raid10 sdg[5] sdf[4] sde[3](F) sdd[2] sdc[1] sdb[0]  
      761856 blocks super 1.2 512K chunks 2 near-copies [6/5] [UUU_UU]  

mdadm -D /dev/md0  
...
    Number   Major   Minor   RaidDevice State   
       0       8       16        0      active sync set-A   /dev/sdb  
       1       8       32        1      active sync set-B   /dev/sdc  
       2       8       48        2      active sync set-A   /dev/sdd  
       -       0        0        3      **removed**  
       4       8       80        4      active sync set-A   /dev/sdf  
       5       8       96        5      active sync set-B   /dev/sdg  
       3       8       64        -      **faulty   /dev/sde**   

Удаляем сломанный диск из массива:  
mdadm /dev/md0 --remove /dev/sde  
mdadm: hot removed /dev/sde from /dev/md0  

Добавляем новый диск:  
mdadm /dev/md0 --add /dev/sde  
mdadm: added /dev/sde  

Проверяем:  
mdadm -D /dev/md0  
... **[6/6] [UUUUUU]**  

### Создаем GPT раздел, пять партиций и монтируем их на диск:  

Создаем раздел GPT на RAID:  
parted -s /dev/md0 mklabel gpt  

Создаем партиции:  
parted /dev/md0 mkpart primary ext4 0% 20%  
parted /dev/md0 mkpart primary ext4 20% 40%  
parted /dev/md0 mkpart primary ext4 40% 60%  
parted /dev/md0 mkpart primary ext4 60% 80%  
parted /dev/md0 mkpart primary ext4 80% 100%  

fdisk -l  
...  
         Start          End    Size  Type            Name  
 1         3072       304127    147M  Microsoft basic primary  
 2       304128       608255  148.5M  Microsoft basic primary  
 3       608256       915455    150M  Microsoft basic primary  
 4       915456      1219583  148.5M  Microsoft basic primary  
 5      1219584      1520639    147M  Microsoft basic primary 

Создаем файловую систему:  
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done   

И монтируем по каталогам:  
mkdir -p /raid/part{1,2,3,4,5}  
for i in $(seq 1 5); do sudo mount /dev/md0p$i /raid/part$i; done  

df -h  
Filesystem      Size  Used Avail Use% Mounted on  
devtmpfs        912M     0  912M   0% /dev  
tmpfs           919M     0  919M   0% /dev/shm  
tmpfs           919M  8.6M  911M   1% /run  
tmpfs           919M     0  919M   0% /sys/fs/cgroup  
/dev/sda1        40G  4.7G   36G  12% /  
tmpfs           184M     0  184M   0% /run/user/1000  
tmpfs           184M     0  184M   0% /run/user/0  
/dev/md0p1      139M  1.6M  127M   2% /raid/part1  
/dev/md0p2      140M  1.6M  128M   2% /raid/part2  
/dev/md0p3      142M  1.6M  130M   2% /raid/part3  
/dev/md0p4      140M  1.6M  128M   2% /raid/part4  
/dev/md0p5      139M  1.6M  127M   2% /raid/part5   
