#!/bin/bash
#
# backup.sh - Sauvegarde de la stack Odoo
# RIF SAS - Test de sélection DevOps
#
# Réalise :
#   1. pg_dump de la base Odoo (via docker exec, sans arrêter les conteneurs)
#   2. Archive tar.gz du filestore Odoo
#   3. Nom horodaté : backup_YYYYMMDD_HHMMSS.tar.gz
#   4. Log dans /var/log/backup.log
#

set -euo pipefail

# --- Configuration cron (désactivée par défaut) ---
# Activer la sauvegarde automatique chaque nuit à 02h00 :
#   crontab -e
#   ��� ajouter : 0 2 * * * cd /chemin/vers/apps && bash backup.sh
# Ou utiliser le script setup-cron.sh fourni.

BACKUP_DIR="/backup"
LOG_FILE="/var/log/backup.log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz"
DB_CONTAINER="odoo-db"
ODOO_CONTAINER="odoo-app"
DB_NAME="${ODOO_DB_NAME:-odoo}"
DB_USER="${ODOO_DB_USER:-odoo}"

# --- Fonctions ---
log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg" | tee -a "$LOG_FILE"
}

cleanup() {
    rm -rf "${TMP_DIR}"
}

# --- Préparation ---
TMP_DIR=$(mktemp -d)
trap cleanup EXIT

mkdir -p "$BACKUP_DIR"

log "=== Début de la sauvegarde ==="
log "Timestamp : ${TIMESTAMP}"

# --- 1. pg_dump de la base Odoo ---
log "Export de la base PostgreSQL (${DB_NAME})..."
docker exec "$DB_CONTAINER" pg_dump -U "$DB_USER" "$DB_NAME" > "${TMP_DIR}/odoo_db.sql"
log "pg_dump terminé avec succès (fichier : odoo_db.sql)"

# --- 2. Copie du filestore Odoo ---
log "Copie du filestore Odoo..."
docker cp "${ODOO_CONTAINER}:/var/lib/odoo" "${TMP_DIR}/filestore" > /dev/null 2>&1
log "Filestore copié avec succès"

# --- 3. Compression ---
log "Création de l'archive ${BACKUP_FILE}..."
tar -czf "$BACKUP_FILE" -C "$TMP_DIR" odoo_db.sql filestore
log "Archive créée avec succès"

# --- 4. Vérification ---
if [ -f "$BACKUP_FILE" ]; then
    FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    log "Sauvegarde terminée : ${BACKUP_FILE} (${FILE_SIZE})"
else
    log "ERREUR : L'archive n'a pas été créée"
    exit 1
fi

log "=== Sauvegarde terminée avec succès ==="
exit 0
