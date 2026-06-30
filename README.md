# Test de Sélection DevOps - RIF SAS

Stack Odoo 17 conteneurisée avec PostgreSQL 15 et reverse proxy Nginx.

## Prérequis machine

- Ubuntu 20.04+ ou WSL2
- Docker Engine v24+ (`docker --version`)
- Docker Compose v2+ (`docker compose version`)
- Git v2+
- RAM libre : 4 Go minimum
- Disque libre : 5 Go minimum

## Démarrage rapide (5 commandes)

```bash
# 1. Cloner le dépôt
git clone <url-du-depot>
cd test-selection-devops

# 2. Configurer les variables d'environnement
cp apps/.env.example apps/.env
# Éditer apps/.env si nécessaire

# 3. Démarrer la stack
cd apps
docker compose up -d

# 4. Ajouter l'entrée hosts (si Nginx est utilisé)
echo "127.0.0.1 erp.local" | sudo tee -a /etc/hosts

# 5. Accéder à Odoo
# http://localhost:8069 ou http://erp.local
```

## Sauvegarde

```bash
# Exécution manuelle
cd apps
bash backup.sh

# L'archive est créée dans /backup/backup_YYYYMMDD_HHMMSS.tar.gz
# Les logs sont dans /var/log/backup.log
```

### Sauvegarde automatique (cron chaque nuit à 02h00)

```bash
# Installation automatique de l'entrée cron
cd apps
bash setup-cron.sh

# Vérification
crontab -l
# Doit afficher : 0 2 * * * cd /chemin/vers/apps && bash backup.sh
```

## Restauration

Voir [docs/restauration.md](docs/restauration.md) pour la procédure complète.

## Arborescence

```
test-selection-devops/
├── apps/
│   ├── docker-compose.yml
│   ├── .env.example
│   ├── backup.sh
│   └── nginx/
│       └── odoo.conf
├── docs/
│   ├── restauration.md
│   └── journal-ia.md
├── .gitignore
└── README.md
```

## Architecture

- **db** : PostgreSQL 15 (réseau privé, aucun port exposé)
- **odoo** : Odoo 17 (port 8069)
- **nginx** : Reverse proxy (port 80, hostname erp.local)
- Volumes nommés : `postgres-data`, `odoo-filestore`
