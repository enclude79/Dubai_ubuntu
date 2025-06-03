#!/bin/bash

# Скрипт для проверки доступности приложения на сервере
# Запускать локально: bash check_server.sh

# Параметры подключения
SERVER_USER="enclude"
SERVER_IP="89.169.166.179"
APP_DIR="~/streamlit_app"
VENV_PATH="/opt/wealthcompas/venv"

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Проверка состояния сервера ${SERVER_IP}...${NC}"

# Проверка доступности сервера
echo -e "${YELLOW}Проверка SSH-подключения...${NC}"
ssh -q ${SERVER_USER}@${SERVER_IP} "echo -e '${GREEN}SSH-подключение работает${NC}'" || echo -e "${RED}Ошибка SSH-подключения${NC}"

# Проверка директории приложения
echo -e "${YELLOW}Проверка директории приложения...${NC}"
ssh ${SERVER_USER}@${SERVER_IP} "if [ -d ${APP_DIR} ]; then echo -e '${GREEN}Директория ${APP_DIR} существует${NC}'; ls -la ${APP_DIR}; else echo -e '${RED}Директория ${APP_DIR} не существует${NC}'; fi"

# Проверка виртуального окружения
echo -e "${YELLOW}Проверка виртуального окружения...${NC}"
ssh ${SERVER_USER}@${SERVER_IP} "if [ -d ${VENV_PATH} ]; then echo -e '${GREEN}Виртуальное окружение ${VENV_PATH} существует${NC}'; ${VENV_PATH}/bin/pip list | grep -E 'streamlit|psycopg2'; else echo -e '${RED}Виртуальное окружение ${VENV_PATH} не существует${NC}'; fi"

# Проверка статуса службы
echo -e "${YELLOW}Проверка статуса службы...${NC}"
ssh ${SERVER_USER}@${SERVER_IP} "sudo systemctl status streamlit-postgres.service || echo -e '${RED}Служба не запущена или не существует${NC}'"

# Проверка сетевого порта
echo -e "${YELLOW}Проверка сетевого порта...${NC}"
ssh ${SERVER_USER}@${SERVER_IP} "sudo netstat -tulpn | grep 8501 || echo -e '${RED}Порт 8501 не используется${NC}'"

# Проверка доступности базы данных
echo -e "${YELLOW}Проверка подключения к PostgreSQL...${NC}"
ssh ${SERVER_USER}@${SERVER_IP} "if command -v psql &> /dev/null; then psql -h 89.169.166.179 -U postgres -d postgres -c 'SELECT 1;' -W; else echo -e '${RED}Утилита psql не установлена${NC}'; fi"

echo -e "${GREEN}Проверка завершена!${NC}" 