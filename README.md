[PASTE THE ENHANCED README CONTENT FROM ABOVE]



# 🚀 Cyberpunk DevOps API

![Python](https://img.shields.io/badge/Python-3.10+-blue)
![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-green)
![MariaDB](https://img.shields.io/badge/MariaDB-10.6+-red)
![Ansible](https://img.shields.io/badge/Ansible-2.15+-orange)
![Nginx](https://img.shields.io/badge/Nginx-1.18+-brightgreen)

Неоновое веб-приложение в стиле Cyberpunk 2077 с REST API для демонстрации DevOps навыков. Статическая главная страница + динамические API эндпоинты с MariaDB.

## ✨ Функционал
- `/health` - Health check с информацией об ОС `{"server": "Linux", "status": "OK"}`
- `/` - Главная страница в cyberpunk стиле с информацией об авторе
- `/courses` - Список IT курсов из MariaDB (fallback JSON при ошибке БД)
- `/docs` - Автогенерируемая Swagger документация FastAPI

## 🛠 Технологический стек
- **Frontend**: HTML5 + Cyberpunk CSS + Orbitron/VT323 шрифты
- **Backend**: Python 3.10+ FastAPI + Uvicorn
- **Database**: MariaDB 10.6+
- **Web Server**: Nginx 1.18+
- **Deployment**: Bash Script / Ansible

## ⚙ Конфигурация
| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| DB_HOST | localhost | Хост MariaDB |
| DB_USER | cyberpunk | Пользователь БД |
| DB_PASSWORD | SecurePass2025! | Пароль БД |
| DB_NAME | cyberpunk_db | Имя базы |

## 🚀 Deployment Options

### Option 1: Bash Script (Quick & Simple)
```bash
# Clone repository
git clone https://github.com/vaiz1982/cyberpunk-devops.git
cd cyberpunk-devops

# Run deployment script
chmod +x deploy.sh
sudo ./deploy.sh


Option 2: Ansible (Advanced & Scalable)
# Install Ansible
sudo apt install ansible -y

# Clone repository
git clone https://github.com/vaiz1982/cyberpunk-devops.git
cd cyberpunk-devops/ansible

# Edit inventory.yml with your server IP
nano inventory.yml

# Deploy
ansible-playbook -i inventory.yml playbook.yml



Ansible Structure
ansible/
├── playbook.yml          # Main playbook
├── inventory.yml         # Server inventory
├── group_vars/all.yml    # Configuration variables
└── roles/cyberpunk-api/  # Modular role structure
    ├── tasks/main.yml
    ├── handlers/main.yml
    └── templates/




🧪 Quick Test
# After deployment, test the endpoints:
curl http://your-server-ip/health
curl http://your-server-ip/courses
# Should return JSON with 5 courses





🌐 URLs
http://[IP]/ - Главная страница

http://[IP]/health - Health check

http://[IP]/courses - API курсов (5 курсов DevOps)

http://[IP]/docs - Swagger документация

http://[IP]/redoc - ReDoc документация





🔧 Maintenance Commands
# Monitor application
sudo systemctl status cyberpunk-api
sudo journalctl -u cyberpunk-api -f
sudo tail -f /opt/cyberpunk-api/logs/app.log

# Manage services
sudo systemctl restart cyberpunk-api  # Restart application
sudo systemctl reload nginx           # Reload Nginx configuration

# Database access
sudo mysql cyberpunk_db               # Access database console





🔧 Troubleshooting
Common issues:
Port 80 already in use: sudo systemctl stop apache2 (if Apache running)

Database connection error: Check MariaDB service: sudo systemctl status mariadb

Permission denied: Ensure proper ownership: sudo chown -R www-data:www-data /opt/cyberpunk-api

Git clone fails: Check network connectivity: curl -I https://github.com






Verify deployment:
# Check all services are running
sudo systemctl status cyberpunk-api nginx mariadb

# Check application logs
sudo tail -f /opt/cyberpunk-api/logs/app.log

# Test database connection
sudo mysql -uroot -proot_password -e "USE cyberpunk_db; SELECT COUNT(*) FROM courses;"






📁 Project Structure
cyberpunk-devops/
├── ansible/                    # Ansible deployment configuration
├── api/                        # FastAPI application
│   └── main.py                 # Main application file
├── static/                     # Frontend files
│   └── index.html              # Cyberpunk styled homepage
├── db_scripts/                 # Database scripts
├── deploy.sh                   # Bash deployment script
└── README.md                   # This file






🎯 Проект демонстрирует навыки DevOps: автоматизация развертывания, инфраструктура как код, CI/CD, мониторинг







## **Updates made:**
1. ✅ **Added badges** for visual appeal
2. ✅ **Added installation commands** with `git clone`
3. ✅ **Added quick test section**
4. ✅ **Added troubleshooting section**
5. ✅ **Added project structure**
6. ✅ **Improved formatting**
7. ✅ **Added author info**

## **Push to GitHub:**
```bash
cd ~/cyberpunk-devops
cat > README.md << 'EOF'
[PASTE THE ABOVE CONTENT]
