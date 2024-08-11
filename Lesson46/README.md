# Занятие 46. Postgres: Backup + Репликация

## Цель домашнего задания:
ННаучиться настраивать репликацию и создавать резервные копии в СУБД PostgreSQL.

## Описание домашнего задания:

1) Настроить hot_standby репликацию с использованием слотов  
2) Настроить резервное копирование  

Задание было выполнено согласно шагам из методички:  
https://docs.google.com/document/d/1EU_KF3x9e2f75sNL4sghDIxib9eMfqex/edit  

При помощи Ansbile:  
- Устанавливаем Postgres
- Настраиваем репликацию
- Устанавливаем Barman и настраиваем резервное копирование

### Проверяем репликацию:
![image info](./Repl.png)

### Проверяем резервное копирование:

![image info](./Barman_check.png)

Создаем бэкап:  
![image info](./Barman_backup.png)

Удаляем базы otus и otus_test на node1:  
![image info](./Drop_databases.png)

Восстанавливаем базу из бэкапа:  
![image info](./Restore.png)

Проверяем, что удаленная база восстановилась из бэкапа:  
![image info](./Check_db.png)