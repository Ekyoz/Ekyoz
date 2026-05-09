#!/usr/bin/env bash
# =============================================================================
# install.sh — Configuration zsh portable (Linux / macOS, sans sudo)
# Usage : curl -fsSL https://raw.githubusercontent.com/Ekyoz/Ekyoz/main/install.sh | bash
# =============================================================================
set -e

RAW_BASE="https://raw.githubusercontent.com/Ekyoz/Ekyoz/main/zsh"

# ── Couleurs ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()  { echo -e "${GREEN}[✔]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✘]${NC} $1"; exit 1; }
step()  { echo -e "\n${BLUE}──────────────────────────────${NC}\n${BLUE}$1${NC}"; }

# ── Détection OS ──────────────────────────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Linux*)   PLATFORM="linux" ;;
  Darwin*)  PLATFORM="macos" ;;
  *)        error "OS non supporté : $OS" ;;
esac
info "Plateforme détectée : $PLATFORM"

# ── Vérification zsh ──────────────────────────────────────────────────────────
step "Vérification de zsh"
if ! command -v zsh &>/dev/null; then
  error "zsh n'est pas installé.\n  → Linux : sudo apt install zsh\n  → macOS : brew install zsh"
fi
info "zsh $(zsh --version | awk '{print $2}') trouvé"

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
step "Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  warn "Oh My Zsh déjà installé — skip"
else
  info "Installation silencieuse de Oh My Zsh..."
  if curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | \
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -s -- --unattended >/dev/null 2>&1; then
    info "Oh My Zsh installé"
  else
    error "Échec de l'installation silencieuse de Oh My Zsh"
  fi
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
BACKUP_DIR="$HOME/.oh-my-zsh/backups"

# ── Plugins externes ──────────────────────────────────────────────────────────
step "Plugins externes"

clone_plugin() {
  local name="$1" url="$2" dest="$ZSH_CUSTOM/plugins/$1"
  if [ -d "$dest" ]; then
    warn "$name déjà présent — skip"
  else
    info "Clonage de $name..."
    git clone --depth=1 -q "$url" "$dest"
  fi
}

clone_plugin "zsh-autosuggestions"   "https://github.com/zsh-users/zsh-autosuggestions"
clone_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"

# ── fzf ───────────────────────────────────────────────────────────────────────
if [ -d "$HOME/.fzf" ]; then
  warn "fzf déjà installé — skip"
else
  info "Installation de fzf..."
  git clone --depth=1 -q https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-bash --no-fish --no-update-rc >/dev/null 2>&1
  info "fzf installé"
fi

# ── fd ────────────────────────────────────────────────────────────────────────
step "fd (find amélioré)"
if command -v fd &>/dev/null; then
  warn "fd déjà installé — skip"
elif sudo -n true 2>/dev/null; then
  info "Installation de fd..."
  if [ "$PLATFORM" = "macos" ]; then
    brew install fd >/dev/null 2>&1 && info "fd installé" || warn "Échec installation fd"
  else
    apt-get install -y fd-find >/dev/null 2>&1 && info "fd installé" || warn "Échec installation fd"
  fi
else
  warn "fd non installé et pas de droits sudo — skip"
fi

# ── Téléchargement des fichiers zsh ───────────────────────────────────────────
step "Téléchargement des fichiers zsh"

ask_backup_if_different() {
  local dest="$1" answer="" timestamp="" rel_path="" backup_name=""
  [ -f "$dest" ] || return 0

  warn "$(basename "$dest") diffère de la version distante"
  if [ -r /dev/tty ]; then
    read -r -p "Créer une sauvegarde avant remplacement ? [y/N] " answer < /dev/tty
  else
    warn "Aucun terminal interactif détecté, pas de sauvegarde demandée"
    return 0
  fi

  case "$answer" in
    [yY]|[yY][eE][sS]|[oO]|[oO][uU][iI])
      timestamp="$(date +%Y%m%d%H%M%S)"
      mkdir -p "$BACKUP_DIR"
      rel_path="${dest#"$HOME/"}"
      backup_name="${rel_path//\//__}.bak.$timestamp"
      cp "$dest" "$BACKUP_DIR/$backup_name"
      info "Sauvegarde créée : $BACKUP_DIR/$backup_name"
      ;;
    *)
      info "Pas de sauvegarde, remplacement direct"
      ;;
  esac
}

download() {
  local src="$1" dest="$2" optional="${3:-false}" with_backup="${4:-true}" tmp_file=""

  mkdir -p "$(dirname "$dest")"
  tmp_file="$(mktemp)" || error "Impossible de créer un fichier temporaire"

  if curl -fsSL "$src" -o "$tmp_file"; then
    if [ -f "$dest" ] && cmp -s "$dest" "$tmp_file"; then
      rm -f "$tmp_file"
      info "$(basename "$dest") déjà à jour"
      return 0
    fi

    [ "$with_backup" = "true" ] && ask_backup_if_different "$dest"
    mv "$tmp_file" "$dest"
    info "$(basename "$dest") téléchargé"
    return 0
  fi

  rm -f "$tmp_file"

  if [ "$optional" = "true" ]; then
    warn "$(basename "$dest") introuvable dans le dépôt distant"
    return 1
  fi

  error "Impossible de télécharger : $src"
}

download_without_backup() {
  local src="$1" dest="$2"
  download "$src" "$dest" "false" "false"
}

download_if_missing() {
  local src="$1" dest="$2" label="${3:-$(basename "$dest")}"
  if [ -f "$dest" ]; then
    info "$label déjà présent — conservé"
    return 0
  fi
  download "$src" "$dest" "false" "false"
}

download_without_backup "$RAW_BASE/.zshrc" "$HOME/.zshrc"
download_without_backup "$RAW_BASE/aliases/default.zsh" "$ZSH_CUSTOM/aliases/default.zsh"
download_without_backup "$RAW_BASE/aussiegeek-custom.zsh-theme" "$ZSH_CUSTOM/themes/aussiegeek-custom.zsh-theme"
download_without_backup "$RAW_BASE/macros/default.zsh" "$ZSH_CUSTOM/macros/default.zsh"
download_without_backup "$RAW_BASE/fzf.zsh" "$ZSH_CUSTOM/fzf.zsh"

download_if_missing "$RAW_BASE/aliases/local.zsh" "$ZSH_CUSTOM/aliases/local.zsh" "aliases/local.zsh"
download_if_missing "$RAW_BASE/macros/local.zsh" "$ZSH_CUSTOM/macros/local.zsh" "macros/local.zsh"
download_if_missing "$RAW_BASE/export.zsh" "$ZSH_CUSTOM/export.zsh" "export.zsh"

# ── Configuration zsh ──────────────────────────────────────────────────────────
step "Configuration zsh"

# Force format horaire 24h (évite AM/PM dans les prompts qui suivent LC_TIME)
if grep -q '^export LC_TIME=' "$HOME/.zshrc"; then
  _tmp_zshrc="$(mktemp)" || error "Impossible de créer un fichier temporaire"
  if ! sed 's|^export LC_TIME=.*|export LC_TIME=fr_FR.UTF-8|' "$HOME/.zshrc" > "$_tmp_zshrc"; then
    rm -f "$_tmp_zshrc"
    error "Impossible de mettre à jour LC_TIME dans .zshrc"
  fi
  if ! mv "$_tmp_zshrc" "$HOME/.zshrc"; then
    rm -f "$_tmp_zshrc"
    error "Impossible de remplacer .zshrc"
  fi
else
  printf '\n# Format horaire 24h\nexport LC_TIME=fr_FR.UTF-8\n' >> "$HOME/.zshrc"
fi
info "LC_TIME configuré en fr_FR.UTF-8 (format 24h)"

# ── Éditeur par défaut ────────────────────────────────────────────────────────
step "Configuration éditeur"
EXPORT_ZSH="$ZSH_CUSTOM/export.zsh"
MACROS_DEFAULT_FILE="$ZSH_CUSTOM/macros/default.zsh"
MACROS_LOCAL_FILE="$ZSH_CUSTOM/macros/local.zsh"
zsh_editor_runner="export ZSH_CUSTOM='$ZSH_CUSTOM'; [ -f '$MACROS_DEFAULT_FILE' ] && source '$MACROS_DEFAULT_FILE'; [ -f '$MACROS_LOCAL_FILE' ] && source '$MACROS_LOCAL_FILE'; typeset -f zsh-editor >/dev/null && zsh-editor"
zsh_editor_check_runner="export ZSH_CUSTOM='$ZSH_CUSTOM'; [ -f '$MACROS_DEFAULT_FILE' ] && source '$MACROS_DEFAULT_FILE'; [ -f '$MACROS_LOCAL_FILE' ] && source '$MACROS_LOCAL_FILE'; [ -f '$EXPORT_ZSH' ] && source '$EXPORT_ZSH'; print -r -- \"\${EDITOR%% *}\""

current_editor="$(zsh -ic "$zsh_editor_check_runner" 2>/dev/null | tail -n 1)"
if [ -n "$current_editor" ] && command -v "$current_editor" >/dev/null 2>&1; then
  info "Éditeur déjà configuré : $current_editor — skip"
elif zsh -ic "$zsh_editor_runner"; then
  info "Configuration de l'éditeur effectuée via zsh-editor"
else
  warn "Impossible d'exécuter zsh-editor, fallback sur vim"
  _tmp="$(grep -v '^export EDITOR=' "$EXPORT_ZSH" 2>/dev/null || true)"
  printf '%s\nexport EDITOR='"'"'%s'"'"'\n' "$_tmp" "vim" > "$EXPORT_ZSH"
  info "EDITOR='vim' enregistré dans $EXPORT_ZSH"
fi

# ── Shell par défaut ──────────────────────────────────────────────────────────
step "Shell par défaut"
if [ "$(basename "$SHELL")" != "zsh" ]; then
  warn "Shell actuel : $SHELL"
  warn "Pour passer à zsh : chsh -s $(command -v zsh)"
else
  info "zsh est déjà ton shell par défaut"
fi

# ── Fin ───────────────────────────────────────────────────────────────────────
echo -e "\n${GREEN}════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ Setup terminé !${NC}"
echo -e "${GREEN}════════════════════════════════════${NC}"
echo -e "  Lance : ${YELLOW}reload${NC} ou ${YELLOW}exec zsh${NC}"
