# Занятие 12. Systemd - создание unit-файлов  

## Цель домашнего задания:
Научиться редактировать существующие и создавать новые unit-файлы;  

Задания были выполнены согласно шагам из методички:  
https://docs.google.com/document/d/1wXZLFDG7NSsrmeSmL0qqec6H9CFAYIolDfiFbDa2WBU/view  

### Написать сервис, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова. Файл и слово должны задаваться в /etc/sysconfig

Создание watchlog.service и запускающего его раз в 30 сек watchlog.timer выполнено с помощью Ansible, см __ansible_watchlog.yml__, запускаемого как часть vagrant provisioning.   

Запускаем таймер и проверяем результат в логе:

systemctl start watchlog.timer  
tail -f /var/log/messages
```
Feb 29 20:21:18 10 systemd-logind: New session 5 of user vagrant.
Feb 29 20:21:43 10 systemd: Started Run watchlog script every 30 second.
Feb 29 20:22:21 10 systemd: Starting My watchlog service...
Feb 29 20:22:21 10 root: Thu Feb 29 20:22:21 UTC 2024: I found word, Master!
Feb 29 20:22:21 10 systemd: Started My watchlog service.
Feb 29 20:22:52 10 systemd: Starting My watchlog service...
Feb 29 20:22:52 10 root: Thu Feb 29 20:22:52 UTC 2024: I found word, Master!
```

### Переписать spawn-fcgi init-скрипт на unit-файл

Установка EPEL репозитория и необходимых пакетов, а также создание конфигурационнего файла и юнита spawnfcgi сервиса выполнено с помощью Ansible, см __ansible_spawnfcgi__  

Запускаем и проверяем,что сервис успешно запущен:  
systemctl start spawn-fcgi  
systemctl status spawn-fcgi  
```
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2024-02-29 20:27:53 UTC; 6s ago
 Main PID: 5303 (php-cgi)
   CGroup: /system.slice/spawn-fcgi.service
           ├─5303 /usr/bin/php-cgi
           ├─5304 /usr/bin/php-cgi
```

### Дополнить юнит-файл apache httpd возможностью запустить несколько инстансов сервера с разными конфигами

Создание шаблона httpd@.service, файлов окружения и конфигурации выполнено с помощью Ansible, см __ansible_httpd.yml__  

Запускаем сервисы и проверяем, какие порты слушаются:  
systemctl start httpd@first  
systemctl start httpd@second  
ss -tnulp | grep httpd  
```
tcp    LISTEN     0      128    [::]:8080               [::]:*                   users:(("httpd",pid=5374,fd=4),("httpd",pid=5373,fd=4),("httpd",pid=5372,fd=4),("httpd",pid=5371,fd=4),("httpd",pid=5370,fd=4),("httpd",pid=5369,fd=4),("httpd",pid=5368,fd=4))
tcp    LISTEN     0      128    [::]:80                 [::]:*                   users:(("httpd",pid=5361,fd=4),("httpd",pid=5360,fd=4),("httpd",pid=5359,fd=4),("httpd",pid=5358,fd=4),("httpd",pid=5357,fd=4),("httpd",pid=5356,fd=4),("httpd",pid=5355,fd=4))
```