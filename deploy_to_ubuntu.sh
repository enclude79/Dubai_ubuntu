#!/bin/bash

# Скрипт для развёртывания PostgreSQL версии приложения на Ubuntu Server
# Запускать локально: bash deploy_to_ubuntu.sh

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

echo -e "${YELLOW}Начинаю развёртывание приложения на сервере ${SERVER_IP}...${NC}"

# Проверка наличия директории приложения
echo -e "${YELLOW}Проверка наличия директории ${APP_DIR}...${NC}"
ssh ${SERVER_USER}@${SERVER_IP} "if [ ! -d ${APP_DIR} ]; then mkdir -p ${APP_DIR}; echo 'Директория создана'; else echo 'Директория уже существует'; fi"

# Копирование файлов приложения
echo -e "${YELLOW}Копирование файлов приложения...${NC}"
scp fixed_streamlit_app.py ${SERVER_USER}@${SERVER_IP}:${APP_DIR}/streamlit_app_postgres.py
scp requirements-postgres.txt ${SERVER_USER}@${SERVER_IP}:${APP_DIR}/

# Создание .env файла на сервере
echo -e "${YELLOW}Создание .env файла с параметрами подключения...${NC}"
ssh ${SERVER_USER}@${SERVER_IP} "cat > ${APP_DIR}/.env << 'EOL'
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=EnPswFJWY1wa
DB_HOST=89.169.166.179
DB_PORT=5432
EOL"

# Установка зависимостей в виртуальное окружение
echo -e "${YELLOW}Установка зависимостей...${NC}"
ssh ${SERVER_USER}@${SERVER_IP} "${VENV_PATH}/bin/pip install -r ${APP_DIR}/requirements-postgres.txt"

# Создание systemd service файла для автозапуска
echo -e "${YELLOW}Создание systemd service файла...${NC}"
ssh ${SERVER_USER}@${SERVER_IP} "sudo bash -c 'cat > /etc/systemd/system/streamlit-postgres.service << EOL
[Unit]
Description=Streamlit App (PostgreSQL version)
After=network.target

[Service]
User=${SERVER_USER}
WorkingDirectory=${APP_DIR}
Environment=\"PATH=${VENV_PATH}/bin\"
ExecStart=${VENV_PATH}/bin/streamlit run ${APP_DIR}/streamlit_app_postgres.py
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOL'"

# Перезагрузка и запуск службы
echo -e "${YELLOW}Настройка автозапуска приложения...${NC}"
ssh ${SERVER_USER}@${SERVER_IP} "sudo systemctl daemon-reload && sudo systemctl enable streamlit-postgres.service && sudo systemctl start streamlit-postgres.service"

# Проверка статуса службы
echo -e "${YELLOW}Проверка статуса службы...${NC}"
ssh ${SERVER_USER}@${SERVER_IP} "sudo systemctl status streamlit-postgres.service"

echo -e "${GREEN}Развёртывание завершено!${NC}"
echo -e "${GREEN}Приложение доступно по адресу: http://${SERVER_IP}:8501${NC}"
echo ""
echo -e "${YELLOW}Полезные команды:${NC}"
echo -e "Просмотр логов: ${GREEN}ssh ${SERVER_USER}@${SERVER_IP} \"sudo journalctl -u streamlit-postgres.service -f\"${NC}"
echo -e "Перезапуск службы: ${GREEN}ssh ${SERVER_USER}@${SERVER_IP} \"sudo systemctl restart streamlit-postgres.service\"${NC}"
echo -e "Остановка службы: ${GREEN}ssh ${SERVER_USER}@${SERVER_IP} \"sudo systemctl stop streamlit-postgres.service\"${NC}" 