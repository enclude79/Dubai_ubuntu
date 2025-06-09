# Процесс обновления приложения Dubai

Данная инструкция описывает полный процесс обновления приложения Dubai от внесения изменений на локальной машине до применения их на продуктовом сервере.

## 1. Внесение изменений локально

1. Клонируйте репозиторий, если он еще не скачан:
   ```bash
   git clone https://github.com/enclude79/Dubai_ubuntu.git
   cd Dubai_ubuntu
   ```

2. Внесите необходимые изменения в файлы приложения:
   - Для изменения параметра боковой панели: обновите `initial_sidebar_state` с "expanded" на "collapsed" в файле `streamlit_app_postgres.py`
   - Для отключения отладочной информации: закомментируйте строку с `st.sidebar.info`

## 2. Тестирование изменений локально

1. Запустите приложение локально для проверки изменений:
   ```bash
   streamlit run streamlit_app_postgres.py
   ```

2. Убедитесь, что все работает как ожидается.

## 3. Отправка изменений в GitHub

1. Добавьте изменения в индекс Git:
   ```bash
   git add streamlit_app_postgres.py
   ```

2. Зафиксируйте изменения:
   ```bash
   git commit -m "Сворачивание боковой панели по умолчанию и скрытие отладочной информации"
   ```

3. Отправьте изменения в удаленный репозиторий:
   ```bash
   git push origin main
   ```

## 4. Обновление на продуктовом сервере

### Вариант 1: Использование скриптов Git (если сервер имеет настроенный Git-репозиторий)

1. Подключитесь к серверу:
   ```bash
   ssh enclude@89.169.166.179
   ```

2. Перейдите в директорию приложения и выполните pull:
   ```bash
   cd /opt/dubai
   git pull origin main
   ```

3. Перезапустите приложение:
   ```bash
   pkill -f "/opt/dubai/streamlit_app_postgres.py"
   nohup /opt/wealthcompas/venv/bin/streamlit run /opt/dubai/streamlit_app_postgres.py --server.port=8502 > /tmp/streamlit.log 2>&1 &
   ```

### Вариант 2: Прямая загрузка файлов (текущий метод)

1. Скопируйте обновленный файл на сервер:
   ```bash
   scp streamlit_app_postgres.py enclude@89.169.166.179:/tmp/
   ```

2. Создайте скрипт обновления (если его еще нет):
   ```bash
   # Файл: update_dubai.sh
   #!/bin/bash
   # Скрипт для обновления файла streamlit_app_postgres.py на сервере

   # Сделать резервную копию
   cp /opt/dubai/streamlit_app_postgres.py /opt/dubai/streamlit_app_postgres.py.bak

   # Скопировать новый файл
   sudo cp /tmp/streamlit_app_postgres.py /opt/dubai/

   # Перезапустить процесс
   pkill -f "/opt/dubai/streamlit_app_postgres.py"

   echo "Обновление завершено!"
   ```

3. Скопируйте скрипт обновления на сервер:
   ```bash
   scp update_dubai.sh enclude@89.169.166.179:/tmp/
   ```

4. Выполните скрипт обновления:
   ```bash
   ssh enclude@89.169.166.179 "chmod +x /tmp/update_dubai.sh && bash /tmp/update_dubai.sh"
   ```

5. Запустите приложение, если оно не запустилось автоматически:
   ```bash
   ssh enclude@89.169.166.179 "nohup /opt/wealthcompas/venv/bin/streamlit run /opt/dubai/streamlit_app_postgres.py --server.port=8502 > /tmp/streamlit.log 2>&1 &"
   ```

## 5. Автоматизация проверки и запуска приложения

1. Создайте скрипт для проверки и автоматического запуска приложения:
   ```bash
   # Файл: restart_dubai.sh
   #!/bin/bash
   # Скрипт для проверки и перезапуска приложения Dubai

   # Проверяем, запущено ли приложение
   if pgrep -f "/opt/dubai/streamlit_app_postgres.py" > /dev/null; then
       echo "Приложение уже запущено."
   else
       echo "Приложение не запущено. Запускаем..."
       nohup /opt/wealthcompas/venv/bin/streamlit run /opt/dubai/streamlit_app_postgres.py --server.port=8502 > /tmp/streamlit.log 2>&1 &
       echo "Приложение запущено на порту 8502."
   fi
   ```

2. Загрузите скрипт на сервер и сделайте его исполняемым:
   ```bash
   scp restart_dubai.sh enclude@89.169.166.179:/opt/dubai/
   ssh enclude@89.169.166.179 "chmod +x /opt/dubai/restart_dubai.sh"
   ```

3. Добавьте скрипт в crontab для автоматического запуска после перезагрузки:
   ```bash
   ssh enclude@89.169.166.179 "crontab -e"
   ```
   
   Добавьте строку:
   ```
   @reboot /opt/dubai/restart_dubai.sh
   ```

## 6. Проверка статуса приложения

Для проверки, что приложение запущено и работает:

```bash
ssh enclude@89.169.166.179 "ps aux | grep streamlit"
```

## 7. Откат в случае проблем

Если возникли проблемы после обновления, вы можете восстановить приложение из резервной копии:

```bash
ssh enclude@89.169.166.179 "sudo cp /opt/dubai/streamlit_app_postgres.py.bak /opt/dubai/streamlit_app_postgres.py"
```

И перезапустить приложение:

```bash
ssh enclude@89.169.166.179 "pkill -f '/opt/dubai/streamlit_app_postgres.py' && /opt/dubai/restart_dubai.sh"
``` 