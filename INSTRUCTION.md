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


### Установка сервера БД MySQL

### Установка средства администрирования БД phpMyAdmin

### Сохранение и восстановление базы данных пользователей MQTT брокера

### Установка и настройка MQTT брокера EMQX

### Установка сервера БД PostgreSQL 

### Восстановление базы данных Chirpstack LoRaWAN сервера

### Установка и настройка ChirpstackNetworkServer и ChirpstackApplicationServer

### Установка и настройка PPP VPN сервера