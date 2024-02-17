yum update
yum install nfs-utils

# включаем firewall
systemctl enable firewalld --now

# добавляем в /etc/fstab строку
echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab

# перезагружаем конфигурации юнитов systemd и перезапускаем юнит remote-fs.target
systemctl daemon-reload
systemctl restart remote-fs.target