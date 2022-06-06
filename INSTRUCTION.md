### Исходные требования

1. Установленный дистрибутив Ubuntu 20.04 
2. Права админимтратора
3. Доступ по SSH

### Предварительная настройка iptables

1. Устанавливаем пакет для сохранения временных настроек iptables
```
apt-get install iptables-persistent
```
2. Выполняем скрипт 
https://github.com/userbogd/trs-cloud-server/blob/main/iptables.sh

3. Сохраняем для применения после перезагрузки
```
/sbin/iptables-save > /etc/iptables/rules.v4
/sbin/iptables-save > /etc/iptables/rules.v6
```