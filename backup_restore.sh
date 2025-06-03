#!/bin/bash

# Скрипт для резервного копирования и восстановления приложения
# Запускать локально: bash backup_restore.sh backup|restore

# Параметры подключения
SERVER_USER="enclude"
SERVER_IP="89.169.166.179"
APP_DIR="~/streamlit_app"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для создания резервной копии
backup() {
    echo -e "${YELLOW}Создание резервной копии приложения с сервера ${SERVER_IP}...${NC}"
    
    # Создание локальной директории для резервных копий
    mkdir -p ${BACKUP_DIR}
    
    # Создание архива приложения на сервере
    ssh ${SERVER_USER}@${SERVER_IP} "cd ${APP_DIR} && tar -czf /tmp/streamlit_app_backup_${TIMESTAMP}.tar.gz ."
    
    # Копирование архива на локальный компьютер
    scp ${SERVER_USER}@${SERVER_IP}:/tmp/streamlit_app_backup_${TIMESTAMP}.tar.gz ${BACKUP_DIR}/
    
    # Удаление временного архива на сервере
    ssh ${SERVER_USER}@${SERVER_IP} "rm /tmp/streamlit_app_backup_${TIMESTAMP}.tar.gz"
    
    echo -e "${GREEN}Резервная копия создана: ${BACKUP_DIR}/streamlit_app_backup_${TIMESTAMP}.tar.gz${NC}"
}

# Функция для восстановления из резервной копии
restore() {
    if [ -z "$1" ]; then
        echo -e "${RED}Ошибка: Не указан файл резервной копии${NC}"
        echo "Использование: $0 restore <файл_резервной_копии>"
        exit 1
    fi
    
    BACKUP_FILE="$1"
    
    if [ ! -f "${BACKUP_FILE}" ]; then
        echo -e "${RED}Ошибка: Файл резервной копии не найден: ${BACKUP_FILE}${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Восстановление приложения из резервной копии ${BACKUP_FILE}...${NC}"
    
    # Копирование архива на сервер
    scp ${BACKUP_FILE} ${SERVER_USER}@${SERVER_IP}:/tmp/streamlit_app_restore.tar.gz
    
    # Остановка службы
    ssh ${SERVER_USER}@${SERVER_IP} "sudo systemctl stop streamlit-postgres.service || true"
    
    # Очистка директории приложения и восстановление из архива
    ssh ${SERVER_USER}@${SERVER_IP} "rm -rf ${APP_DIR}/* && mkdir -p ${APP_DIR} && tar -xzf /tmp/streamlit_app_restore.tar.gz -C ${APP_DIR}"
    
    # Удаление временного архива на сервере
    ssh ${SERVER_USER}@${SERVER_IP} "rm /tmp/streamlit_app_restore.tar.gz"
    
    # Запуск службы
    ssh ${SERVER_USER}@${SERVER_IP} "sudo systemctl start streamlit-postgres.service"
    
    echo -e "${GREEN}Восстановление завершено!${NC}"
}

# Основная логика скрипта
case "$1" in
    backup)
        backup
        ;;
    restore)
        restore "$2"
        ;;
    *)
        echo -e "${RED}Ошибка: Неизвестная команда${NC}"
        echo "Использование: $0 backup|restore [файл_резервной_копии]"
        exit 1
        ;;
esac 