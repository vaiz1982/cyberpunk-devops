# Cyberpunk DevOps API

## Deployment
- Bash script: `./deploy.sh`
- Ansible: `ansible-playbook -i inventory.yml playbook.yml`

## URLs
- http://[IP]/ - Main page
- http://[IP]/docs - API documentation

## 🚀 Ansible Deployment

For automated multi-server deployment:

```bash
cd ansible
# Edit inventory.yml with your server IPs
ansible-playbook -i inventory.yml playbook.yml

## 🔧 Maintenance Commands
```bash
sudo systemctl status cyberpunk-api
sudo journalctl -u cyberpunk-api -f
```
