# Scripting — Sauvegarde et restauration

Petit projet de scripts shell pour sauvegarder et restaurer des éléments du système.

Fichiers principaux
- `backup_www.sh` — sauvegarde des fichiers web.
- `restore_www.sh` — restauration des fichiers web.

- `backup_cron.sh` — sauvegarde des tâches cron.
- `restore_cron.sh` — restauration des tâches cron.

Prérequis
- Bash (Linux/macOS) ou environnement compatible shell
- Permissions d'exécution sur les scripts : `chmod +x *.sh`

Usage
1. Rendre les scripts exécutables :

   ```bash
   chmod +x *.sh
   ```

2. Lancer une sauvegarde :

   ```bash
   ./backup_www.sh
   ./backup_cron.sh
   ```

3. Restaurer depuis une sauvegarde :

   ```bash
   ./restore_www.sh
   ./restore_cron.sh
   ```

Personnalisation
- Éditez les scripts pour adapter les chemins, destinations de sauvegarde et options.

Support
- Pour toute question, ouvrez une issue ou contactez moi.

Licence
- Libre à utiliser et modifier.
