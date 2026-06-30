#!/bin/bash
#
# setup-cron.sh - Installation de l'entrée cron pour la sauvegarde Odoo
# RIF SAS - Test de sélection DevOps
#
# Usage : bash setup-cron.sh
# Exécuter avec les droits utilisateur (pas sudo)
#

CRON_JOB="0 2 * * * cd $(pwd) && bash backup.sh"

# Vérifier si l'entrée existe déjà
if crontab -l 2>/dev/null | grep -q "backup.sh"; then
    echo "L'entrée cron pour backup.sh existe déjà."
    crontab -l
    exit 0
fi

# Ajouter l'entrée cron
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "Entrée cron installée :"
echo "$CRON_JOB"
echo ""
echo "Vérification :"
crontab -l
