## Инструкция по развертыванию облачного сервера TRS

### Исходные требования
1. Установленный дистрибутив Ubuntu 20.04 
2. Права админимтратора
3. Доступ по SSH

Все настройки далее производятся от имени аминистратора, для их получения необходимо ввести 
```
sudo su
```
<br/><br/>

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

<br/><br/>

### Установка веб-сервера APACHE2
1. Установка непосредственно apache2
```
apt update
apt install apache2
systemctl status apache2
```
2. Настройка виртуальных хостов.	
- восстанавливаем структуру каталога /var/www
- восстанавливаем структуру каталога конфигураций /etc/apache2/sites-available
- применяем конфигурации 
```
a2ensite iotronic.cloud.conf
a2ensite m1.iotronic.cloud.conf
a2ensite www.iotronic.cloud.conf
a2ensite tmrsystems.ru.conf
```
3. Команды управления сервером 
```
systemctl stop apache2
systemctl start apache2
systemctl restart apache2
```
<br/><br/>

### Получение сертификатов Let'sEncrypt
1. Устанавливаем sertbot и плагин для apache2
```
apt install certbot python3-certbot-apache
``` 
2. Запускаем процедуру получения сертификатов. Отвечаем на вопросы интерактивной установки.
Принимаем предложение сделать редирект всех запросов на 443 ssl порт.
```
certbot --apache
```
3. Прверяем планировщик обновлений сертификата
```
systemctl status certbot.timer
```
4. Повторный запуск sertbot в тестовом режиме для проверки валидности установки 
```
certbot renew --dry-run
```
<br/><br/>

### Установка Webmin
1. Добавляем репозиторий webmin в систему
```
echo "deb http://download.webmin.com/download/repository sarge contrib"   | tee -a /etc/apt/sources.list
```
2. Устанавливаем пакет для защищенной связи и хранения данных gnupg
```
apt install gnupg
```
3. Устанавливаем ключ репозитория и обновляем список пакетов
```
wget -q -O- http://www.webmin.com/jcameron-key.asc | sudo apt-key add
apt update
```
4. Устанавливаем непосредственно webmin
```
apt install webmin
```
5. Проверяем доступ по адресу https://your_domain:10000
<br/><br/>

### Установка сервера БД MySQL
По умолчанию в дистрибутив Ubuntu 20.04 включен пакет MySQL 8.0 Ввиду его прожорливости и
недостаточного тестирования совместно с плагином emqx_auth_mysql, принято решение использовать 
версию MySQL 5.7
1. Добавляем репозиторий с MySQL 5.7
```
wget https://dev.mysql.com/get/mysql-apt-config_0.8.12-1_all.deb
dpkg -i mysql-apt-config_0.8.12-1_all.deb
```
Выбираем в списке Ubuntu Bionic, затем опцию MySQL Server & Cluster и mysql-5.7

2. Обновляем список пакетов в репозиториях, добавляем ключ репозитория с mysql-5.7 и снова обновляем список
```
apt update
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29
apt update
```

<br/><br/>
### Установка средства администрирования БД phpMyAdmin
<br/><br/>
### Сохранение и восстановление базы данных пользователей MQTT брокера
<br/><br/>
### Установка и настройка MQTT брокера EMQX
<br/><br/>
### Установка сервера БД PostgreSQL 
<br/><br/>
### Восстановление базы данных Chirpstack LoRaWAN сервера
<br/><br/>
### Установка и настройка ChirpstackNetworkServer и ChirpstackApplicationServer
<br/><br/>
### Установка и настройка PPP VPN сервера