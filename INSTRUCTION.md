### Исходные требования

1. Установленный дистрибутив Ubuntu 20.04 
2. Права админимтратора
3. Доступ по SSH

Все настройки далее производятся от имени аминистратора, для их получения необходимо ввести 
```
sudo su
```

### Предварительная настройка iptables

1. Устанавливаем пакет для сохранения временных настроек iptables
```
apt-get install iptables-persistent
```
2. Выполняем скрипт 
https://github.com/userbogd/trs-cloud-server/blob/main/iptables.sh
Скрипт содержит все правила фильтрации и маршрутизации, необходимые на начальном этапе конфигурирования

3. Сохраняем для применения после перезагрузки
```
/sbin/iptables-save > /etc/iptables/rules.v4
/sbin/iptables-save > /etc/iptables/rules.v6
```
4. Для работы форвардинга необходимо в файле /etc/sysctl.conf установить 
```
net.ipv4.ip_forward=1
```
и перезапустить сетевые службы или перезагрузить сервер

### Установка веб-сервера APACHE2
1. Установка непосредственно apache2
```
apt update
apt install apache2
systemctl status apache2
```
2. Настройка виртуальных хостов.
	- создаем каталоги с содержимым сайтов:
	```
	mkdir /var/www/html/tmrsystems.ru
	mkdir /var/www/html/iotronic.cloud
	```
3.  

