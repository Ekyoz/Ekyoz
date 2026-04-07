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
  info "Installation de Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  info "Oh My Zsh installé"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

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

# ── Téléchargement des fichiers zsh ───────────────────────────────────────────
step "Configuration zsh (fichiers)"

ask_backup_if_exists() {
  local dest="$1" answer="" timestamp=""
  [ -f "$dest" ] || return 0

  warn "$(basename "$dest") existe déjà"
  if [ -r /dev/tty ]; then
    read -r -p "Créer une sauvegarde avant remplacement ? [y/N] " answer < /dev/tty
  else
    warn "Aucun terminal interactif détecté, pas de sauvegarde demandée"
    return 0
  fi

  case "$answer" in
    [yY]|[yY][eE][sS]|[oO]|[oO][uU][iI])
      timestamp="$(date +%Y%m%d%H%M%S)"
      cp "$dest" "$dest.bak.$timestamp"
      info "Sauvegarde créée : $dest.bak.$timestamp"
      ;;
    *)
      info "Pas de sauvegarde, remplacement direct"
      ;;
  esac
}

download() {
  local src="$1" dest="$2" optional="${3:-false}"

  mkdir -p "$(dirname "$dest")"
  ask_backup_if_exists "$dest"

  if curl -fsSL "$src" -o "$dest"; then
    info "$(basename "$dest") téléchargé"
    return 0
  fi

  if [ "$optional" = "true" ]; then
    warn "$(basename "$dest") introuvable dans le dépôt distant"
    return 1
  fi

  error "Impossible de télécharger : $src"
}

download "$RAW_BASE/.zshrc" "$HOME/.zshrc"
download "$RAW_BASE/aliases.zsh" "$ZSH_CUSTOM/aliases.zsh"
download "$RAW_BASE/aussiegeek-custom.zsh-theme" "$ZSH_CUSTOM/themes/aussiegeek-custom.zsh-theme"

# Force format horaire 24h (évite AM/PM dans les prompts qui suivent LC_TIME)
if grep -q '^export LC_TIME=' "$HOME/.zshrc"; then
  sed -i.bak 's|^export LC_TIME=.*|export LC_TIME=fr_FR.UTF-8|' "$HOME/.zshrc" 2>/dev/null || \
  sed -i ''   's|^export LC_TIME=.*|export LC_TIME=fr_FR.UTF-8|' "$HOME/.zshrc"
else
  printf '\n# Format horaire 24h\nexport LC_TIME=fr_FR.UTF-8\n' >> "$HOME/.zshrc"
fi
info "LC_TIME configuré en fr_FR.UTF-8 (format 24h)"

# macros.zsh (template vide si absent dans le repo)
MACROS_FILE="$ZSH_CUSTOM/macros.zsh"
if [ -f "$MACROS_FILE" ]; then
  MACROS_EXISTED=true
else
  MACROS_EXISTED=false
fi

if ! download "$RAW_BASE/macros.zsh" "$MACROS_FILE" "true"; then
  if [ "$MACROS_EXISTED" = "true" ]; then
    warn "macros.zsh local conservé"
  else
    warn "macros.zsh absent du repo — création d'un template vide"
    cat > "$MACROS_FILE" << 'MACROS'
# =============================================================================
# macros.zsh — Fonctions shell personnelles
# =============================================================================

# Créer un dossier et s'y déplacer
mkcd() { mkdir -p "$1" && cd "$1"; }
MACROS
  fi
fi

# ── Éditeur par défaut ────────────────────────────────────────────────────────
step "Configuration éditeur"
LOCAL_ZSH="$ZSH_CUSTOM/local.zsh"
touch "$LOCAL_ZSH"
zsh_editor_runner="export ZSH_CUSTOM='$ZSH_CUSTOM'; source '$MACROS_FILE'; typeset -f zsh-editor >/dev/null && zsh-editor"

if zsh -ic "$zsh_editor_runner"; then
  info "Configuration de l'éditeur effectuée via zsh-editor"
else
  warn "Impossible d'exécuter zsh-editor, fallback sur vim"
  _tmp="$(grep -v '^export EDITOR=' "$LOCAL_ZSH" 2>/dev/null || true)"
  printf '%s\nexport EDITOR='"'"'%s'"'"'\n' "$_tmp" "vim" > "$LOCAL_ZSH"
  info "EDITOR='vim' enregistré dans $LOCAL_ZSH"
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
echo -e "  Lance : ${YELLOW}exec zsh${NC}"
