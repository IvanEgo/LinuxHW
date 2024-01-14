# Занятие 1. Vagrant-стенд для обновления ядра и создания образа системы
## Цель домашнего задания:  
Научиться обновлять ядро в Linux. Получение навыков работы с Vagrant, Packer и публикацией готовых образов в Vagrant Cloud.  
## Описание домашнего задания  
1) Обновить ядро ОС из репозитория ELRepo  
2) Создать Vagrant box c помощью Packer  
3) Загрузить Vagrant box в Vagrant Cloud  

Задание было выполнено согласно шагам из методички:  
https://docs.google.com/document/d/12sC884LuLGST3-tZYQBDPvn6AH8AGJCK/edit#heading=h.a8d50mrzdnhi  

За основу был взят код из следующего репозитория:  
https://github.com/Nickmob/vagrant_kernel_update  

Были внесены следующие изменения в centos.json:  
iso_checksum изменена в соответствии с https://mirror.linux-ia64.org/centos/8-stream/isos/x86_64/CHECKSUM  
ssh_timeout установлен в 90m  
memory увеличена до 2048  
увеличены пауза и таймаут в настройках provisioners (иначе были ошибки при сборке)  
      "pause_before": "120s",  
      "start_retry_timeout": "3m"  

Установлены следующие плагины packer:  
packer plugins install github.com/hashicorp/virtualbox  
packer plugins install github.com/hashicorp/vagrant  

Сборка бокса завершилась за 1 час 15 мин:  
packer build centos.json  
Build 'virtualbox-iso.centos-8stream' finished after 1 hour 15 minutes.  
==> Builds finished. The artifacts of successful builds are:  
--> virtualbox-iso.centos-8stream: 'virtualbox' provider box: centos-8-kernel-6-x86_64-Minimal.box  

Получившийся бокс был добавлен в Vagrant и запущен, чтобы убедиться, что версия ядра была обновлена:  
vagrant init centos8-kernel6  
vagrant box list  
centos8-kernel6  (virtualbox, 0)  
generic/centos8s (virtualbox, 4.3.4, (amd64))  
vagrant up  
vagrant ssh  
uname -r  
6.6.11-1.el8.elrepo.x86_64  

Загрузка образа в Vagrant Cloud доходила до 100% и завершалась ошибкой:  
vagrant cloud publish --release ivanegorov/centos8-kernel6 1.0 virtualbox centos-8-kernel-6-x86_64-Minimal.box  
You are about to publish a box on Vagrant Cloud with the following options:  
ivanegorov/centos8-kernel6:   (v1.0) for provider 'virtualbox'  
Automatic Release:     true  
Box Architecture:      amd64  
Do you wish to continue? [y/N]y  
Saving box information...  
Uploading provider with file /home/ivan/Otus/Lesson1/packer/centos-8-kernel-6-x86_64-Minimal.box  
Failed to create box ivanegorov/centos8-kernel6  
Vagrant Cloud request failed  
При этом он отображался в моем кабинете (ivanegorov/centos8-kernel6), но не находился в поиске доступных образов.  

В итоге загрузил через сайт.  
https://app.vagrantup.com/ivanegorov/boxes/centos8-kernel6

