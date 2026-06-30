# Journal IA - Test de sélection DevOps

## Prompt 1 : Génération du docker-compose.yml

**Prompt utilisé :**
> "Génère un docker-compose.yml pour Odoo 17 avec PostgreSQL 15, un réseau privé isolé pour PostgreSQL, et un reverse proxy Nginx. Utilise un fichier .env pour les secrets, des volumes nommés pour la persistance, et expose Odoo sur le port 8069 et Nginx sur le port 80."

**Ce que l'IA a généré :**
Un fichier docker-compose.yml complet avec 3 services (db, odoo, nginx), un réseau bridge dédié, des volumes nommés, et les dépendances entre services.

**Ce que j'ai modifié :**
- Ajout d'un healthcheck sur PostgreSQL pour que Odoo attende que la base soit prête
- Correction du chemin du volume pour la config Odoo
- Ajout du champ `container_name` pour simplifier les références dans les scripts

**Pourquoi :**
Le healthcheck évite les erreurs de connexion au démarrage, et les noms explicites facilitent l'écriture des scripts de backup.

---

## Prompt 2 : Script de sauvegarde automatisé

**Prompt utilisé :**
> "Écris un script Bash qui fait un pg_dump via docker exec et une copie du filestore Odoo, compresse le tout en tar.gz horodaté, avec logging dans /var/log/backup.log. Inclure une entrée cron pour une exécution quotidienne à 2h du matin."

**Ce que l'IA a généré :**
Un script backup.sh avec pg_dump, docker cp, tar.gz, gestion des logs, et une ligne crontab.

**Ce que j'ai modifié :**
- Ajout de `set -euo pipefail` pour une gestion stricte des erreurs
- Ajout d'un trap pour le nettoyage des fichiers temporaires
- La vérification de succès après création de l'archive

**Pourquoi :**
La robustesse est cruciale pour un script de production. Les guards évitent une corruption silencieuse des backups.

---

## Prompt 3 : Procédure de restauration et documentation

**Prompt utilisé :**
> "Rédige un runbook de restauration Odoo après crash total (volumes supprimés) avec les étapes de restauration de la base PostgreSQL via psql et du filestore, dans un format markdown."

**Ce que l'IA a généré :**
Un guide de restauration structuré avec les étapes de restitution après sinistre.

**Ce que j'ai modifié :**
- Ajout d'une liste de vérification finale (checklist)
- Réorganisation des étapes pour coller au scénario de test du crash (Partie 2.2)
- Ajout des commandes exactes pour la restauration après `docker compose down -v`

**Pourquoi :**
Le runbook doit pouvoir être suivi par un tiers sans connaissances préalables. La checklist garantit qu'aucune étape n'est oubliée.

---

## Ce que j'ai appris aujourd'hui

J'ai consolidé ma compréhension du cycle de vie complet d'une application conteneurisée : du déploiement initial avec Docker Compose, à la gestion des secrets et de la persistance, jusqu'à la sauvegarde et la restauration après sinistre. L'utilisation de healthchecks pour gérer les dépendances entre services Docker était un point nouveau que je vais réutiliser systématiquement.
