# Занятие 3. Первые шаги с Ansible  

## Описание домашнего задания  
Подготовить стенд на Vagrant как минимум с одним сервером. На этом сервере используя Ansible необходимо развернуть nginx со следующими условиями:  
    необходимо использовать модуль yum/apt;   
    конфигурационные файлы должны быть взяты из шаблона jinja2 с перемененными;  
    после установки nginx должен быть в режиме enabled в systemd;  
    должен быть использован notify для старта nginx после установки;  
    сайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible.  

Задание было выполнено согласно шагам из методички:  
https://drive.google.com/file/d/1uxni7F8V4M5uUPkgrVXKkN5Jg13Tut9a/view

Управляемый хост создан при помощи Vagrant, используя приложенный Vagrantfile командой vagrant up.

Inventory файл, описывающий управляемый хост, создан и размещен по пути staging/hosts.

nginx.yml создан согласно описанию в методичке и применен с помощью команды ansible-playbook nginx.yml  

PLAY RECAP *********************************************************************  
nginx                      : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

Сайт доступен:
curl http://192.168.56.10:8080/  

    <!DOCTYPE html>  
    <html>  
    <head>  
    <title>Welcome to nginx!</title>  