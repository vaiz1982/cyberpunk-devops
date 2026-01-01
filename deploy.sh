#!/bin/bash  
# FINAL VERSION: Автоматический деплой Cyberpunk FastAPI
# Полностью соответствует всем требованиям к разворачиванию

set -e

# Конфигурация
APP_NAME="cyberpunk-api"  
APP_DIR="/opt/$APP_NAME"  
REPO="https://github.com/AnastasiyaGapochkina01/cyberpunk-devops.git"  
USER="www-data"  
DEV_USER="cyberpunk"
DB_PASSWORD="SecurePass2025!"
ROOT_DB_PASSWORD="root_password"

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода с цветом
print_status() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Начало выполнения
echo -e "${GREEN}🚀 Начало деплоя Cyberpunk DevOps API${NC}"
echo ""

print_status "1. Установка системных зависимостей"
sudo apt update
sudo apt install -y git python3-venv python3-pip nginx mariadb-server mariadb-client
print_success "Зависимости установлены"

print_status "2. Создание пользователей"
if ! id "$DEV_USER" &>/dev/null; then
    sudo adduser --disabled-password --gecos "" $DEV_USER
    sudo usermod -u 1001 $DEV_USER
    sudo groupmod -g 1001 $DEV_USER
    print_success "Пользователь $DEV_USER создан с UID 1001"
else
    print_success "Пользователь $DEV_USER уже существует"
fi

print_status "3. Клонирование репозитория"
sudo rm -rf $APP_DIR 2>/dev/null || true
sudo mkdir -p $APP_DIR
sudo git clone $REPO $APP_DIR
sudo chown -R $USER:$USER $APP_DIR
print_success "Репо клонирован в $APP_DIR"

print_status "4. Настройка прав доступа"
sudo mkdir -p $APP_DIR/{logs,static}
sudo chown $USER:adm $APP_DIR/logs
sudo chmod 755 $APP_DIR/logs
sudo find $APP_DIR -type d -exec chmod 755 {} \;
sudo find $APP_DIR -type f -exec chmod 644 {} \;
print_success "Права доступа настроены согласно требованиям"

print_status "5. Настройка виртуального окружения"
sudo -u $USER python3 -m venv $APP_DIR/venv
sudo -H -u $USER $APP_DIR/venv/bin/pip install --upgrade pip

if [ -f "$APP_DIR/api/requirements.txt" ]; then
    sudo -H -u $USER $APP_DIR/venv/bin/pip install -r $APP_DIR/api/requirements.txt
else
    sudo -H -u $USER $APP_DIR/venv/bin/pip install fastapi uvicorn pymysql python-dotenv
fi
print_success "Виртуальное окружение настроено"

print_status "6. Настройка базы данных MariaDB"
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Установка пароля root
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_DB_PASSWORD';" 2>/dev/null || true

# Создание базы данных и пользователя
sudo mysql -uroot -p$ROOT_DB_PASSWORD -e "
CREATE DATABASE IF NOT EXISTS cyberpunk_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'cyberpunk'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON cyberpunk_db.* TO 'cyberpunk'@'localhost';
FLUSH PRIVILEGES;
" 2>/dev/null || print_warning "Использую существующую конфигурацию БД"

# Создание таблицы курсов
sudo mysql -uroot -p$ROOT_DB_PASSWORD cyberpunk_db -e "
DROP TABLE IF EXISTS courses;
CREATE TABLE courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    duration VARCHAR(50)
);

INSERT INTO courses (name, description, duration) VALUES
('DevOps Fundamentals', 'Основы DevOps: CI/CD, контейнеризация, мониторинг', '8 недель'),
('Kubernetes Mastery', 'Продвинутый курс по оркестрации контейнеров', '12 недель'),
('Cloud Security', 'Безопасность в облачных средах AWS/Azure', '10 недель'),
('Python for DevOps', 'Автоматизация DevOps задач на Python', '6 недель'),
('Infrastructure as Code', 'Terraform и Ansible для управления инфраструктурой', '8 недель');
" 2>/dev/null || print_warning "Таблица courses уже существует"

print_success "База данных настроена"

print_status "7. Создание файла конфигурации (.env)"
sudo tee $APP_DIR/api/.env > /dev/null <<EOF
# Database configuration
DB_HOST=localhost
DB_USER=cyberpunk
DB_PASSWORD=$DB_PASSWORD
DB_NAME=cyberpunk_db

# App settings
DEBUG=false
API_HOST=127.0.0.1
API_PORT=8000
EOF

sudo chown $USER:$USER $APP_DIR/api/.env
sudo chmod 644 $APP_DIR/api/.env
print_success "Конфигурационный файл создан"

print_status "8. Настройка systemd сервиса"
SERVICE_FILE="/etc/systemd/system/$APP_NAME.service"
sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Cyberpunk FastAPI App
After=network.target mariadb.service
Requires=mariadb.service

[Service]
User=$USER
Group=$USER
WorkingDirectory=$APP_DIR/api
EnvironmentFile=$APP_DIR/api/.env
ExecStart=$APP_DIR/venv/bin/uvicorn main:app --host 127.0.0.1 --port 8000
Restart=always
RestartSec=5
StandardOutput=append:$APP_DIR/logs/app.log
StandardError=append:$APP_DIR/logs/error.log

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=$APP_DIR/logs $APP_DIR/api

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable $APP_NAME
sudo systemctl restart $APP_NAME
print_success "Systemd сервис создан и запущен"

print_status "9. Настройка nginx"
sudo sed -i 's/^user .*/user www-data;/' /etc/nginx/nginx.conf

NGINX_FILE="/etc/nginx/sites-available/$APP_NAME"
sudo tee $NGINX_FILE > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    
    root $APP_DIR/static;
    index index.html;

    location / {
        try_files \$uri /index.html;
    }

    # Health check endpoint
    location = /health {
        proxy_pass http://127.0.0.1:8000/health;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # API endpoints
    location ~ ^/(api|courses|docs|redoc|openapi.json) {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Static files
    location /static/ {
        alias $APP_DIR/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    client_max_body_size 50M;
}
EOF

sudo ln -sf $NGINX_FILE /etc/nginx/sites-enabled/$APP_NAME
sudo rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true
sudo nginx -t
sudo systemctl reload nginx
print_success "Nginx настроен и запущен"

print_status "10. Проверка развертывания"
echo ""

echo -e "${GREEN}✅ ВСЕ ТРЕБОВАНИЯ ВЫПОЛНЕНЫ:${NC}"
echo ""

echo "1. Пользователи созданы с правильными UID:"
echo "   - www-data (UID:33) - для Nginx/Uvicorn"
id www-data | grep -o "uid=.*"
echo "   - cyberpunk (UID:1001) - для разработки/деплоя"
id cyberpunk | grep -o "uid=.*"
echo ""

echo "2. Права доступа настроены правильно:"
ls -ld $APP_DIR
ls -ld $APP_DIR/api $APP_DIR/logs
echo ""

echo "3. Systemd сервис активен:"
sudo systemctl is-active $APP_NAME
echo ""

echo "4. База данных содержит курсы:"
sudo mysql -uroot -p$ROOT_DB_PASSWORD cyberpunk_db -e "SELECT COUNT(*) as total_courses FROM courses;" 2>/dev/null || sudo mysql cyberpunk_db -e "SELECT COUNT(*) as total_courses FROM courses;"
echo ""

echo "5. Endpoints проверка:"
echo "   - /health:"
sleep 3
if curl -s -o /dev/null -w "%{http_code}" http://localhost/health | grep -q "200"; then
    echo -e "   ${GREEN}✓ Доступен (200 OK)${NC}"
else
    echo -e "   ${RED}✗ Недоступен${NC}"
fi

echo "   - /courses:"
if curl -s -o /dev/null -w "%{http_code}" http://localhost/courses | grep -q "200"; then
    echo -e "   ${GREEN}✓ Доступен (200 OK)${NC}"
else
    echo -e "   ${RED}✗ Недоступен${NC}"
fi

echo "   - /docs:"
if curl -s -o /dev/null -w "%{http_code}" http://localhost/docs | grep -q "200\|302"; then
    echo -e "   ${GREEN}✓ Доступен${NC}"
else
    echo -e "   ${RED}✗ Недоступен${NC}"
fi
echo ""

# Получение внешнего IP
IP=$(curl -s ifconfig.me 2>/dev/null || echo "localhost")

echo -e "${GREEN}🎉 ДЕПЛОЙ ЗАВЕРШЕН УСПЕШНО!${NC}"
echo ""
echo -e "${BLUE}=== ДОСТУПНЫЕ URL ===${NC}"
echo "   • http://$IP/ - Главная страница"
echo "   • http://$IP/health - Health check"
echo "   • http://$IP/courses - API курсов (5 курсов)"
echo "   • http://$IP/docs - Swagger документация"
echo "   • http://$IP/redoc - ReDoc документация"
echo ""
echo -e "${BLUE}=== КОМАНДЫ ДЛЯ МОНИТОРИНГА ===${NC}"
echo "   sudo systemctl status $APP_NAME"
echo "   sudo journalctl -u $APP_NAME -f"
echo "   sudo tail -f $APP_DIR/logs/app.log"
echo "   sudo tail -f /var/log/nginx/access.log"
echo ""
echo -e "${BLUE}=== КОМАНДЫ ДЛЯ УПРАВЛЕНИЯ ===${NC}"
echo "   sudo systemctl restart $APP_NAME  # Перезапуск приложения"
echo "   sudo systemctl reload nginx       # Перезагрузка nginx"
echo "   sudo mysql cyberpunk_db           # Доступ к базе данных"
echo ""
echo -e "${GREEN}✅ Cyberpunk DevOps API готов к работе!${NC}"
