# Анализ недвижимости в Дубае (PostgreSQL)

Приложение для анализа данных о недвижимости в Дубае, разработанное на Streamlit с использованием PostgreSQL в качестве базы данных.

![Анализ недвижимости в Дубае](https://i.ibb.co/FWzXz5X/dubai-property.jpg)

## Функциональные возможности

- Поиск недвижимости по цене и площади
- Визуализация объектов на интерактивной карте
- Фильтрация по районам и типам недвижимости
- Отображение детальной информации о объектах
- Анализ средних цен по районам

## Требования

- Python 3.8+
- PostgreSQL 12+
- Streamlit 1.33.0+
- psycopg2-binary 2.9.9+
- Другие зависимости, указанные в requirements-postgres.txt

## Установка и запуск

### Локальный запуск (Windows)

1. Клонируйте репозиторий
2. Установите зависимости:
   ```
   pip install -r requirements-postgres.txt
   ```
3. Запустите приложение:
   ```
   streamlit run fixed_streamlit_app.py
   ```
   
   Или используйте скрипт:
   ```
   run_locally.bat
   ```

### Установка на сервере Ubuntu

Подробная инструкция по установке на сервере Ubuntu содержится в файле [README_UBUNTU_DEPLOY.md](README_UBUNTU_DEPLOY.md).

Быстрое развертывание:
```bash
bash deploy_to_ubuntu.sh
```

## Структура проекта

- `fixed_streamlit_app.py` - Основной скрипт приложения
- `requirements-postgres.txt` - Зависимости для работы с PostgreSQL
- `deploy_to_ubuntu.sh` - Скрипт для развертывания на Ubuntu Server
- `check_server.sh` - Скрипт для проверки состояния сервера
- `backup_restore.sh` - Скрипт для резервного копирования и восстановления
- `run_locally.bat` - Скрипт для запуска на Windows

## Параметры подключения к PostgreSQL

По умолчанию приложение использует следующие параметры:
- Хост: 89.169.166.179
- База данных: postgres
- Пользователь: postgres
- Пароль: EnPswFJWY1wa
- Порт: 5432

Эти параметры можно изменить, создав файл `.env` в корне проекта.

## Обслуживание

### Резервное копирование

```bash
bash backup_restore.sh backup
```

### Восстановление

```bash
bash backup_restore.sh restore ./backups/streamlit_app_backup_YYYYMMDD_HHMMSS.tar.gz
```

## Устранение неполадок

См. раздел "Устранение неполадок" в файле [README_UBUNTU_DEPLOY.md](README_UBUNTU_DEPLOY.md).

## Лицензия

MIT 