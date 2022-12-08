## Инструкция по развертыванию облачного сервера TRS

### Исходные требования
1. Установленный дистрибутив Ubuntu 20.04 
2. Права админиcтратора
3. Доступ по SSH

Все настройки далее производятся от имени аминистратора, для их получения необходимо ввести: 
```
sudo su
```
<br/><br/>

### Настройка доступа по SSH
1. В файле /etc/ssh/sshd_config меняем строку #PermitRootLogin prohibit-password на:
```
PermitRootLogin yes
```
<br/><br/>


### Предварительная настройка iptables
1. Устанавливаем пакет для сохранения временных настроек iptables:
```
apt-get install iptables-persistent
```
2. Выполняем скрипт 
https://github.com/userbogd/trs-cloud-server/blob/main/iptables.sh
Скрипт содержит все правила фильтрации и маршрутизации, необходимые на начальном этапе конфигурирования

3. Сохраняем для применения после перезагрузки:
```
/sbin/iptables-save > /etc/iptables/rules.v4
/sbin/iptables-save > /etc/iptables/rules.v6
```
4. Для работы форвардинга необходимо в файле /etc/sysctl.conf установить: 
```
net.ipv4.ip_forward=1
```
и перезапустить сетевые службы или перезагрузить сервер

<br/><br/>


### Установка Webmin
1. Добавляем репозиторий Webmin в систему:
```
echo "deb http://download.webmin.com/download/repository sarge contrib"   | tee -a /etc/apt/sources.list
```
2. Устанавливаем пакет для защищенной связи и хранения данных gnupg:
```
apt install gnupg
```
3. Устанавливаем ключ репозитория и обновляем список пакетов:
```
wget -q -O- http://www.webmin.com/jcameron-key.asc | sudo apt-key add
apt update
```
4. Устанавливаем непосредственно Webmin:
```
apt install webmin
```
5. Проверяем доступ по адресу https://your_domain:10000
<br/><br/>


### Установка веб-сервера APACHE2
1. Установка непосредственно Apache2:
```
apt update
apt install apache2
systemctl status apache2
```

<details>
<summary>
2. Настройка виртуальных хостов (только для iotronic).	
</summary>

- восстанавливаем структуру каталога /var/www
- восстанавливаем структуру каталога конфигураций /etc/apache2/sites-available
- применяем конфигурации: 
  
```
a2ensite iotronic.cloud.conf
a2ensite m1.iotronic.cloud.conf
a2ensite www.iotronic.cloud.conf
a2ensite tmrsystems.ru.conf
```

</details>
</br><br>

  3. Команды управления сервером
   
```
systemctl stop apache2
systemctl start apache2
systemctl restart apache2
```
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

3. Проверяем наличие репозитория с MySQL 5.7 в списке
```
apt-cache policy mysql-server
```

4. Устанавливаем непосредственно сервер базы данных, в процессе устанавливаем пароль администратора базы 
```
apt install -f mysql-client=5.7* mysql-community-server=5.7* mysql-server=5.7*
```
<br/><br/>

### Установка PHP
1. Установка PHP
```
sudo apt install php libapache2-mod-php php-mysql
```
<br/><br/>

<details>
<summary>Let's encrypt installation</summary>

### Получение сертификатов Let'sEncrypt (Только при наличии реального доменного имени)

1. Устанавливаем sertbot и плагин для apache2
```
apt install certbot python3-certbot-apache
``` 
2. Запускаем процедуру получения сертификатов. Отвечаем на вопросы интерактивной установки.
Принимаем предложение сделать редирект всех запросов на 443 ssl порт.
```
certbot --apache
```
3. Проверяем планировщик обновлений сертификата
```
systemctl status certbot.timer
```
4. Повторный запуск sertbot в тестовом режиме для проверки валидности установки 
```
certbot renew --dry-run
```
</details>

<br/><br/>

### Установка средства администрирования БД phpMyAdmin
1. Обновляем пакеты и ставим  phpMyAdmin вместе с зависимостями, перезапускаем apache2
```
apt update
apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl
systemctl restart apache2
```
2. Веб-интерфейс доступен по адресу https://domain_name/phpmyadmin. Можно заходить с учетной
записью администратора БД, созданного при установке сервера MySQL. Далее нужно создать отдельного 
пользователя для phpMyAdmin, напрмер <b>'phpmyadmin'</b>, и для mqtt брокера, например <b>'emq'</b>. Это удобно сделать через оснастку webmin. 
Для того чтобы появилась оснастка, необходимо в webmin надо нажать Refresh Modules в главном меню 
и дальше заходить в Servers->MySQL Database Server. 

<br/><br/>


### Создание, сохранение и восстановление базы данных пользователей MQTT брокера
Права доступа пользователей к MQTT брокеру (используем брокер EMQX) содержатся в базе данных MySQL и
используются брокером через плагин emqx_auth_mysql, который устанавливается автоматически вместе с брокером.
Для его работы нужна либо пустая база с заранее сформированной структурой, либо восстановленная база от предыдущего 
рабочего сервера.
1. Пустую базу можно создать с помощью phpMyAdmin с помощью опции главного меню "Создать БД". Имя базы можно задать 
любое, которое будет потом использоваться в настройках плагина, например  <b>mqttUsersDB</b>. После создания базы, необходимо
создать в ней структуру. Для этого надо в ней выполнить скрипт emqx_mysql_db.sql из этого репозитория, но лучше взять скрипт из
рекомендаций по настройке текущей версии плагина, т.к. структура базы может меняться при крупных обновлениях плагина.
Наконец ранее созданному пользователю БД <b>emq</b>, надо назначить права к этой базе на SELECT,INSERT,UPDATE,DELETE
2. Если необходимо перенести существующую базу данных, то это делается из верхнего меню phpMyAdmin функциями "Экспорт" и "Импорт".
Соответственно на рабочей базе делается "Экспорт" можно вместе со структурой, тогда её не нужно будет создавать на новой базе.
Либо только данные, тогда структура должна быть предварительно создана как в пункте 1. На новой пустой базе необходимо выполнить 
"Импорт" либо, если экспортировались только данные, то предварительно надо выполнить скрипт формирующий структуру базы.
Так же как в п.1 необходимо назначить привилегии пользователю <b>emq</b>.
 
 
<br/><br/>
### Установка и настройка MQTT брокера EMQX
<br/><br/>
### Установка сервера БД PostgreSQL 
1. Обновляем пакеты и устанавливаем сервер БД
```
apt update
apt install postgresql postgresql-contrib
```
2. В процессе установки создается системный пользователь с именем postgres, который связан с ролью Postgres в БД. От его имени и 
необходимо проводить все мероприятия с БД.
3. Создание пользователей бэкап и восстановление удобно делать через модуль webmin. Для того чтобы появилась оснастка, необходимо 
в webmin надо нажать Refresh Modules в главном меню и дальше заходить в Servers->PostgreSQL Database Server. 

<br/><br/>
### Восстановление базы данных Chirpstack LoRaWAN сервера

<br/><br/>
### Установка и настройка ChirpstackNetworkServer и ChirpstackApplicationServer
<br/><br/>
### Установка и настройка PPP VPN сервера