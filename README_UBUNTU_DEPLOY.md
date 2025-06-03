# Развертывание приложения на Ubuntu Server

Данная инструкция описывает процесс развертывания приложения анализа недвижимости в Дубае на Ubuntu Server.

## Предварительные требования

- Доступ к серверу Ubuntu по SSH
- Установленный Python 3.8+ на сервере
- Sudo права для установки пакетов и настройки служб

## Быстрое развертывание

Для быстрого развертывания приложения выполните следующую команду:

```bash
bash deploy_to_ubuntu.sh
```

Скрипт выполнит все необходимые шаги:
1. Создаст директорию для приложения (если она не существует)
2. Скопирует файлы приложения на сервер
3. Создаст .env файл с параметрами подключения
4. Установит зависимости
5. Настроит systemd службу для автозапуска
6. Запустит приложение

После успешного выполнения скрипта приложение будет доступно по адресу:
`http://89.169.166.179:8501`

## Ручное развертывание

Если вы хотите развернуть приложение вручную, выполните следующие шаги:

### 1. Подключение к серверу

```bash
ssh enclude@89.169.166.179
```

### 2. Создание директории для приложения

```bash
mkdir -p ~/streamlit_app
```

### 3. Копирование файлов приложения

```bash
# Выполните локально
scp fixed_streamlit_app.py enclude@89.169.166.179:~/streamlit_app/streamlit_app_postgres.py
scp requirements-postgres.txt enclude@89.169.166.179:~/streamlit_app/
```

### 4. Создание .env файла

```bash
# На сервере
cat > ~/streamlit_app/.env << 'EOL'
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=EnPswFJWY1wa
DB_HOST=89.169.166.179
DB_PORT=5432
EOL
```

### 5. Установка зависимостей

```bash
# На сервере
/opt/wealthcompas/venv/bin/pip install -r ~/streamlit_app/requirements-postgres.txt
```

### 6. Создание systemd службы

```bash
# На сервере (с sudo правами)
sudo bash -c 'cat > /etc/systemd/system/streamlit-postgres.service << EOL
[Unit]
Description=Streamlit App (PostgreSQL version)
After=network.target

[Service]
User=enclude
WorkingDirectory=/home/enclude/streamlit_app
Environment="PATH=/opt/wealthcompas/venv/bin"
ExecStart=/opt/wealthcompas/venv/bin/streamlit run /home/enclude/streamlit_app/streamlit_app_postgres.py
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOL'
```

### 7. Запуск службы

```bash
# На сервере (с sudo правами)
sudo systemctl daemon-reload
sudo systemctl enable streamlit-postgres.service
sudo systemctl start streamlit-postgres.service
```

### 8. Проверка статуса

```bash
# На сервере
sudo systemctl status streamlit-postgres.service
```

## Проверка развертывания

Для проверки состояния развертывания выполните:

```bash
bash check_server.sh
```

## Резервное копирование и восстановление

### Создание резервной копии

```bash
bash backup_restore.sh backup
```

### Восстановление из резервной копии

```bash
bash backup_restore.sh restore ./backups/streamlit_app_backup_YYYYMMDD_HHMMSS.tar.gz
```

## Полезные команды

### Просмотр логов

```bash
ssh enclude@89.169.166.179 "sudo journalctl -u streamlit-postgres.service -f"
```

### Перезапуск службы

```bash
ssh enclude@89.169.166.179 "sudo systemctl restart streamlit-postgres.service"
```

### Остановка службы

```bash
ssh enclude@89.169.166.179 "sudo systemctl stop streamlit-postgres.service"
```

## Устранение неполадок

### Проблема: Служба не запускается

Проверьте логи службы:
```bash
sudo journalctl -u streamlit-postgres.service -n 50
```

### Проблема: Ошибки подключения к базе данных

Проверьте параметры подключения в .env файле:
```bash
cat ~/streamlit_app/.env
```

Проверьте доступность базы данных:
```bash
psql -h 89.169.166.179 -U postgres -d postgres -c 'SELECT 1;'
```

### Проблема: Порт 8501 уже используется

Найдите процесс, использующий порт:
```bash
sudo netstat -tulpn | grep 8501
```

Остановите конфликтующий процесс:
```bash
sudo kill <PID>
``` 