# Занятие 9. NFS

## Цель домашнего задания:  
Научиться самостоятельно разворачивать сервер NFS и подключаться к нему с клиента.  

## Описание домашнего задания:  
- `vagrant up` должен поднимать 2 настроенные виртуальные машины (сервер NFS и клиента) без дополнительных ручных действий;  
- на сервере NFS должна быть подготовлена и экспортирована директория;  
- в экспортированной директории должна быть поддиректория с именем __upload__ с правами на запись в неё;  
- экспортированная директория должна автоматически монтироваться на клиенте при старте виртуальной машины (systemd, autofs или fstab -  любым способом);   
- монтирование и работа NFS на клиенте должна быть организована с использованием NFSv3 по протоколу UDP;  
- firewall должен быть включен и настроен как на клиенте, так и на сервере.  

Задание было выполнено согласно шагам из методички:  
https://docs.google.com/document/d/1Xz7dCWSzaM8Q0VzBt78K3emh7zlNX3C-Q27B6UuVexI/edit?pli=1  

Настройка сервера NFS и клиента выполняется скриптами nfss_script.sh и nfsc_script.sh, вызываемых в рамках provisioning виртуальных машин при запуске их командой vagrant up.  

Проверяем работоспособность после запуска:  
vagrant ssh nfsc  
touch /srv/share/upload/server_file  

vagrant ssh nfsc  
ls /mnt/upload/  
  server_file  

mount | grep mnt  
  systemd-1 on /mnt type autofs (rw,relatime,fd=46,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=26063) 
  192.168.50.10:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.50.10,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.50.10)