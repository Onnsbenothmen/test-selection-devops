# Runbook de Restauration - Stack Odoo RIF SAS

## Prérequis

- Docker Engine v24+ et Docker Compose v2+
- Archive de backup disponible dans `/backup/`
- Fichier `.env` configuré à la racine de `apps/`

## Procédure de restauration complète

### Étape 1 : Identifier le backup à restaurer

```bash
ls -la /backup/
```

Choisir l'archive la plus récente : `backup_YYYYMMDD_HHMMSS.tar.gz`

### Étape 2 : Extraire l'archive

```bash
BACKUP_FILE="/backup/backup_YYYYMMDD_HHMMSS.tar.gz"
TMP_DIR=$(mktemp -d)
tar -xzf "$BACKUP_FILE" -C "$TMP_DIR"
```

### Étape 3 : Restaurer la base PostgreSQL

```bash
cd apps
docker compose up -d db
docker cp "$TMP_DIR/odoo_db.sql" odoo-db:/tmp/odoo_db.sql
docker exec odoo-db psql -U odoo -d odoo -f /tmp/odoo_db.sql
```

### Étape 4 : Restaurer le filestore Odoo

```bash
docker cp "$TMP_DIR/filestore/." odoo-app:/var/lib/odoo/
```

### Étape 5 : Redémarrer la stack

```bash
docker compose up -d
```

### Étape 6 : Vérification

1. Accéder à http://localhost:8069 ou http://erp.local
2. Vérifier que le module **Ventes** est toujours installé
3. Vérifier les logs : `docker compose logs odoo`

## Restauration après crash total (volumes supprimés)

```bash
# 1. Backup existant ?
ls /backup/

# 2. Supprimer tout l'existant
docker compose down -v

# 3. Recreate les volumes vides
docker compose up -d db
docker compose up -d odoo

# 4. Restaurer la base
docker cp /backup/backup_XXXX.tar.gz odoo-db:/tmp/
docker exec odoo-db tar -xzf /tmp/backup_XXXX.tar.gz -C /tmp/
docker exec odoo-db psql -U odoo -d odoo -f /tmp/odoo_db.sql

# 5. Restaurer le filestore
docker compose up -d odoo
docker cp /tmp/filestore/. odoo-app:/var/lib/odoo/

# 6. Monter tout
docker compose up -d
```

## Vérification finale

- [ ] Odoo accessible sur http://localhost:8069
- [ ] Module Ventes présent
- [ ] Les données historiques sont visibles
- [ ] Aucune erreur dans les logs (`docker compose logs --tail=50`)
