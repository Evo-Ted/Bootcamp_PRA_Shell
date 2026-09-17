#!/bin/bash
# ============================================================
#  backup_www.sh - Sauvegarde chiffrée de /var/www/html
# ============================================================

set -euo pipefail

# ---------- Configuration ----------
SOURCE_DIR="/var/www/html"
BACKUP_ROOT="/backup"                 # Dossier racine des sauvegardes
ARCHIVE_DIR="${BACKUP_ROOT}/archives"
KEY_DIR="${BACKUP_ROOT}/keys"
LOG_DIR="${BACKUP_ROOT}/logs"

# ---------- Fonctions utilitaires ----------
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"
}

die() {
    echo "[ERREUR] $*" >&2
    exit 1
}

# ---------- Vérifications ----------
[[ $EUID -eq 0 ]] || die "Ce script doit être exécuté en root (sudo)."
[[ -d "$SOURCE_DIR" ]] || die "Le dossier source $SOURCE_DIR n'existe pas."
command -v openssl >/dev/null || die "openssl n'est pas installé."
command -v tar >/dev/null || die "tar n'est pas installé."

mkdir -p "$ARCHIVE_DIR" "$KEY_DIR" "$LOG_DIR"

# ---------- Horodatage commun (clé + archive) ----------
BASENAME="$(date '+%Y%m%d_%H%M%S')"
ARCHIVE_PLAIN="${ARCHIVE_DIR}/${BASENAME}.tar.gz"
ARCHIVE_ENC="${ARCHIVE_DIR}/${BASENAME}.tar.gz.enc"
KEY_FILE="${KEY_DIR}/${BASENAME}.key"
LOG_FILE="${LOG_DIR}/${BASENAME}.log"
CHECKSUM_FILE="${ARCHIVE_DIR}/${BASENAME}.sha256"

log "=== Début de la sauvegarde : $BASENAME ==="

# ---------- Génération de la clé symétrique (256 bits) ----------
log "Génération de la clé AES-256..."
openssl rand -base64 32 > "$KEY_FILE"
chmod 600 "$KEY_FILE"
log "Clé générée : $KEY_FILE"

# ---------- Création de l'archive tar.gz ----------
log "Création de l'archive : $ARCHIVE_PLAIN"
tar -czf "$ARCHIVE_PLAIN" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"
log "Archive créée : $(du -h "$ARCHIVE_PLAIN" | cut -f1)"

# ---------- Chiffrement symétrique AES-256-CBC ----------
log "Chiffrement AES-256-CBC de l'archive..."
openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 \
    -in  "$ARCHIVE_PLAIN" \
    -out "$ARCHIVE_ENC" \
    -pass file:"$KEY_FILE"

log "Archive chiffrée : $ARCHIVE_ENC ($(du -h "$ARCHIVE_ENC" | cut -f1))"

# ---------- Calcul de l'empreinte SHA-256 ----------
log "Calcul de l'empreinte SHA-256..."
(cd "$ARCHIVE_DIR" && sha256sum "$ARCHIVE_ENC") > "$CHECKSUM_FILE"
chmod 644 "$CHECKSUM_FILE"
log "Empreinte générée : $CHECKSUM_FILE"

# ---------- Suppression de l'archive en clair ----------
rm -f "$ARCHIVE_PLAIN"
log "Archive non chiffrée supprimée."

log "=== Sauvegarde terminée avec succès ==="
echo
echo "Archive : $ARCHIVE_ENC"
echo "Clé     : $KEY_FILE"
echo "Log     : $LOG_FILE"