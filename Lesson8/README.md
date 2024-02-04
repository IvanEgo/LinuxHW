# Занятие 8. ZFS

## Цель домашнего задания:  
Научится самостоятельно устанавливать ZFS, настраивать пулы, изучить основные возможности ZFS.  

## Описание домашнего задания:  
1. Определить алгоритм с наилучшим сжатием:
- Определить какие алгоритмы сжатия поддерживает zfs (gzip, zle, lzjb, lz4);
- создать 4 файловых системы на каждой применить свой алгоритм сжатия;
- для сжатия использовать либо текстовый файл, либо группу файлов.

2. Определить настройки пула.  
С помощью команды zfs import собрать pool ZFS.  
Командами zfs определить настройки:  
- размер хранилища;
- тип pool;
- значение recordsize;
- какое сжатие используется;
- какая контрольная сумма используется.

3. Работа со снапшотами:
- скопировать файл из удаленной директории;
- восстановить файл локально. zfs receive;
- найти зашифрованное сообщение в файле secret_message.

Задание было выполнено согласно шагам из методички:  
https://docs.google.com/document/d/1xursgUsGDVTLh4B_r0XGw_flPzd5lSJ0nfMFL-HQmFs/view  

Создаем и запускаем виртуальную машину с установленным ZFS, используя предоставленный Vagrantfile.  
vagrant up  
vagrant ssh  

## Определение алгоритма с наилучшим сжатием

Создаём 4 пула из пар дисков в режиме RAID-1:  
zpool create zpool1 mirror /dev/sdb /dev/sdc  
zpool create zpool2 mirror /dev/sdd /dev/sde  
zpool create zpool3 mirror /dev/sdf /dev/sdg  
zpool create zpool4 mirror /dev/sdh /dev/sdi   

Устаналиваем разные алгоритмы сжатия для каждого пула:  
zfs set compression=lzjb zpool1  
zfs set compression=lz4 zpool2  
zfs set compression=gzip-9 zpool3  
zfs set compression=zle zpool4  

Проверяем примененные настройки компрессии:  
**zfs get compression**  
  zpool1  compression  lzjb      local  
  zpool2  compression  lz4       local  
  zpool3  compression  gzip-9    local  
  zpool4  compression  zle       local  

Скачивааем один и тот же текстовый файл во все пулы:  
for i in {1..4}; do wget -P /zpool$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done  

**zfs list**  
  NAME     USED  AVAIL     REFER  MOUNTPOINT  
  zpool1  21.6M   330M     21.6M  /zpool1  
  zpool2  17.7M   334M     17.6M  /zpool2  
  zpool3  10.8M   341M     **10.7M**  /zpool3  
  zpool4  39.2M   313M     39.2M  /zpool4  

**zfs get compressratio**  
  NAME    PROPERTY       VALUE  SOURCE  
  zpool1  compressratio  1.81x  -  
  zpool2  compressratio  2.22x  -  
  zpool3  compressratio  **3.65x**  -  
  zpool4  compressratio  1.00x  -  

Видим, что меньше всего места занимает файл, сжатый алгоритмом gzip-9.  

## Определение настроек пула

Скачиваем архив в домашний каталог и распаковываем его:  
wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'  
tar -xzvf archive.tar.gz  

Импортируем пул:  
zpool import -d zpoolexport/ otus  

Получаем параметры пула и файловой системы:  

zpool get **size** otus  
  NAME  PROPERTY  VALUE  SOURCE  
  otus  size      **480M**   -  

zfs get **recordsize** otus  
  NAME  PROPERTY    VALUE    SOURCE  
  otus  recordsize  **128K** local  

zfs get **compression** otus  
  NAME  PROPERTY     VALUE     SOURCE  
  otus  compression  **zle**   local  

zfs get **checksum** otus  
  NAME  PROPERTY  VALUE      SOURCE  
  otus  checksum  **sha256** local  

## Работа со снапшотом, поиск сообщения от преподавателя

Скачиваем файл со снапшотом:  
wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download  

Восстанавливаем файловую систему из снапшота:  
zfs receive otus/test@today < otus_task2.file  
  2024-02-04 18:52:37 (3.46 MB/s) - 'otus_task2.file' saved [5432736/5432736]  

zfs list
  NAME             USED  AVAIL     REFER  MOUNTPOINT  
  otus            4.94M   347M       25K  /otus  
  otus/hometask2  1.88M   347M     1.88M  /otus/hometask2  
  otus/test       2.83M   347M     2.83M  /otus/test  
  zpool1          21.7M   330M     21.6M  /zpool1  
  zpool2          17.7M   334M     17.6M  /zpool2  
  zpool3          10.8M   341M     10.7M  /zpool3  
  zpool4          39.3M   313M     39.2M  /zpool4  

find /otus/test -name "secret_message"  
  /otus/test/task1/file_mess/secret_message  

cat /otus/test/task1/file_mess/secret_message  
  **https://otus.ru/lessons/linux-hl/**  