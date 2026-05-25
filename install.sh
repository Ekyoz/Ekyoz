#!/usr/bin/env bash
# =============================================================================
# install.sh — Configuration zsh portable (Linux / macOS, sans sudo)
# Sert aussi d'updater : seules les actions réellement effectuées sont affichées
# (EKYOZ_VERBOSE=true pour voir aussi les "déjà à jour / déjà installé").
# Usage : curl -fsSL https://raw.githubusercontent.com/Ekyoz/Ekyoz/main/install.sh | bash
# =============================================================================
set -euo pipefail

REPO="Ekyoz/Ekyoz"
RAW_BASE="https://raw.githubusercontent.com/$REPO/main/zsh"
LOCAL_BIN="$HOME/.local/bin"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ekyoz-zsh"

# Empêche update.zsh (sourcé par les `zsh -ic` ci-dessous) de proposer/déclencher
# une mise à jour pendant que l'installeur tourne.
export EKYOZ_DISABLE_AUTO_UPDATE=true

# ── Affichage ─────────────────────────────────────────────────────────────────
# On ne montre que ce qui est RÉELLEMENT fait :
#   - step() diffère l'en-tête de section ; il n'est imprimé (_flush_step) que si
#     une action (info/warn/error) suit — les sections sans action disparaissent ;
#   - skip() = "déjà fait / à jour", silencieux sauf si EKYOZ_VERBOSE=true.
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
VERBOSE="${EKYOZ_VERBOSE:-false}"
_pending_step=""
_did_something=false

_flush_step() {
  [ -n "$_pending_step" ] || return 0
  echo -e "\n${BLUE}──────────────────────────────${NC}\n${BLUE}$_pending_step${NC}"
  _pending_step=""
}
step()  { _pending_step="$1"; }
info()  { _flush_step; _did_something=true; echo -e "${GREEN}[✔]${NC} $1"; }
warn()  { _flush_step; echo -e "${YELLOW}[!]${NC} $1"; }
error() { _flush_step; echo -e "${RED}[✘]${NC} $1"; exit 1; }
skip()  { [ "$VERBOSE" = "true" ] && { _flush_step; echo -e "${YELLOW}[=]${NC} $1"; }; return 0; }

_has_sudo() {
  groups | tr ' ' '\n' | grep -qE '^(sudo|wheel|admin)$'
}

# ── Détection OS ──────────────────────────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Linux*)   PLATFORM="linux" ;;
  Darwin*)  PLATFORM="macos" ;;
  *)        error "OS non supporté : $OS" ;;
esac
skip "Plateforme détectée : $PLATFORM"

# ── Vérification zsh ──────────────────────────────────────────────────────────
step "Vérification de zsh"
if ! command -v zsh &>/dev/null; then
  error "zsh n'est pas installé.\n  → Linux : sudo apt install zsh\n  → macOS : brew install zsh"
fi
skip "zsh $(zsh --version | awk '{print $2}') trouvé"

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
step "Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  skip "Oh My Zsh déjà installé"
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

# ── Plugins externes ──────────────────────────────────────────────────────────
step "Plugins externes"

clone_plugin() {
  local name="$1" url="$2" dest="$ZSH_CUSTOM/plugins/$1"
  if [ -d "$dest" ]; then
    skip "$name déjà présent"
  else
    info "Clonage de $name..."
    git clone --depth=1 -q "$url" "$dest"
  fi
}

clone_plugin "zsh-autosuggestions"     "https://github.com/zsh-users/zsh-autosuggestions"
clone_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"

# ── fzf ───────────────────────────────────────────────────────────────────────
step "fzf"
if [ -d "$HOME/.fzf" ]; then
  skip "fzf déjà installé"
else
  info "Installation de fzf..."
  git clone --depth=1 -q https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-bash --no-fish --no-update-rc >/dev/null 2>&1
  info "fzf installé"
fi

# ── fd (find amélioré) ────────────────────────────────────────────────────────
# Nom du binaire : `fd` (brew/cargo) ou `fdfind` (apt Debian/Ubuntu).
step "fd (find amélioré)"
if command -v fd &>/dev/null || command -v fdfind &>/dev/null; then
  skip "fd déjà installé"
elif [ "$PLATFORM" = "macos" ] && command -v brew &>/dev/null; then
  brew install fd >/dev/null 2>&1 && info "fd installé (brew)" || warn "Échec installation fd"
elif [ "$PLATFORM" = "linux" ] && _has_sudo && command -v apt-get &>/dev/null; then
  sudo apt-get install -y fd-find >/dev/null 2>&1 && info "fd installé (apt)" || warn "Échec installation fd"
else
  warn "fd non installé (pas de gestionnaire de paquets dispo) — skip"
fi

# ── eza (ls amélioré) ─────────────────────────────────────────────────────────
install_eza_prebuilt() {
  # Télécharge un binaire eza pré-compilé dans ~/.local/bin (sans sudo).
  local arch target url tmp
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64)  target="x86_64-unknown-linux-musl" ;;
    aarch64|arm64) target="aarch64-unknown-linux-gnu" ;;
    *) warn "Architecture non gérée pour eza pré-compilé : $arch"; return 1 ;;
  esac
  url="https://github.com/eza-community/eza/releases/latest/download/eza_${target}.tar.gz"
  mkdir -p "$LOCAL_BIN"
  tmp="$(mktemp -d)" || return 1
  if curl -fsSL "$url" -o "$tmp/eza.tar.gz" && tar -xzf "$tmp/eza.tar.gz" -C "$tmp" && [ -f "$tmp/eza" ]; then
    mv "$tmp/eza" "$LOCAL_BIN/eza"
    chmod +x "$LOCAL_BIN/eza"
    rm -rf "$tmp"
    return 0
  fi
  rm -rf "$tmp"
  return 1
}

step "eza (ls amélioré)"
if command -v eza &>/dev/null; then
  skip "eza déjà installé"
else
  case "$PLATFORM" in
    macos)
      if command -v brew &>/dev/null; then
        brew install eza >/dev/null 2>&1 && info "eza installé (brew)" || warn "Échec installation eza via brew"
      else
        warn "Homebrew absent — installe eza manuellement : brew install eza"
      fi
      ;;
    linux)
      if _has_sudo && command -v apt-get &>/dev/null && apt-cache show eza &>/dev/null; then
        sudo apt-get install -y eza >/dev/null 2>&1 && info "eza installé (apt)" || warn "Échec installation eza via apt"
      else
        info "Installation d'eza (binaire pré-compilé, sans sudo)..."
        if install_eza_prebuilt; then
          info "eza installé dans $LOCAL_BIN"
        else
          warn "Échec installation eza — les alias retomberont sur ls"
        fi
      fi
      ;;
  esac
fi

# ── Téléchargement des fichiers zsh ───────────────────────────────────────────
step "Téléchargement des fichiers zsh"

download() {
  local src="$1" dest="$2" tmp_file=""

  mkdir -p "$(dirname "$dest")"
  tmp_file="$(mktemp)" || error "Impossible de créer un fichier temporaire"

  if curl -fsSL "$src" -o "$tmp_file"; then
    if [ -f "$dest" ] && cmp -s "$dest" "$tmp_file"; then
      rm -f "$tmp_file"
      skip "$(basename "$dest") déjà à jour"
      return 0
    fi
    mv "$tmp_file" "$dest"
    info "$(basename "$dest") mis à jour"
    return 0
  fi

  rm -f "$tmp_file"
  error "Impossible de télécharger : $src"
}

download_if_missing() {
  local src="$1" dest="$2" label="${3:-$(basename "$dest")}"
  if [ -f "$dest" ]; then
    skip "$label déjà présent — conservé"
    return 0
  fi
  download "$src" "$dest"
}

# Fichiers partagés : toujours synchronisés avec le dépôt
download "$RAW_BASE/.zshrc"                      "$HOME/.zshrc"
download "$RAW_BASE/aliases/default.zsh"         "$ZSH_CUSTOM/aliases/default.zsh"
download "$RAW_BASE/macros/default.zsh"          "$ZSH_CUSTOM/macros/default.zsh"
download "$RAW_BASE/fzf.zsh"                     "$ZSH_CUSTOM/fzf.zsh"
download "$RAW_BASE/update.zsh"                  "$ZSH_CUSTOM/update.zsh"
download "$RAW_BASE/aussiegeek-custom.zsh-theme" "$ZSH_CUSTOM/themes/aussiegeek-custom.zsh-theme"

# Fichiers locaux : créés une fois puis jamais écrasés
download_if_missing "$RAW_BASE/aliases/local.zsh" "$ZSH_CUSTOM/aliases/local.zsh" "aliases/local.zsh"
download_if_missing "$RAW_BASE/macros/local.zsh"  "$ZSH_CUSTOM/macros/local.zsh"  "macros/local.zsh"
download_if_missing "$RAW_BASE/export.zsh"        "$ZSH_CUSTOM/export.zsh"        "export.zsh"

# ── Éditeur par défaut ────────────────────────────────────────────────────────
step "Configuration éditeur"
EXPORT_ZSH="$ZSH_CUSTOM/export.zsh"
MACROS_DEFAULT_FILE="$ZSH_CUSTOM/macros/default.zsh"
MACROS_LOCAL_FILE="$ZSH_CUSTOM/macros/local.zsh"
zsh_editor_runner="export ZSH_CUSTOM='$ZSH_CUSTOM'; [ -f '$MACROS_DEFAULT_FILE' ] && source '$MACROS_DEFAULT_FILE'; [ -f '$MACROS_LOCAL_FILE' ] && source '$MACROS_LOCAL_FILE'; typeset -f zsh-editor >/dev/null && zsh-editor"
zsh_editor_check_runner="export ZSH_CUSTOM='$ZSH_CUSTOM'; [ -f '$MACROS_DEFAULT_FILE' ] && source '$MACROS_DEFAULT_FILE'; [ -f '$MACROS_LOCAL_FILE' ] && source '$MACROS_LOCAL_FILE'; [ -f '$EXPORT_ZSH' ] && source '$EXPORT_ZSH'; print -r -- \"\${EDITOR%% *}\""

current_editor="$(zsh -ic "$zsh_editor_check_runner" 2>/dev/null | tail -n 1)"
if [ -n "$current_editor" ] && command -v "$current_editor" >/dev/null 2>&1; then
  skip "Éditeur déjà configuré : $current_editor"
elif zsh -ic "$zsh_editor_runner"; then
  info "Configuration de l'éditeur effectuée via zsh-editor"
else
  warn "Impossible d'exécuter zsh-editor, fallback sur vim"
  _tmp="$(grep -v '^export EDITOR=' "$EXPORT_ZSH" 2>/dev/null || true)"
  printf '%s\nexport EDITOR='"'"'%s'"'"'\n' "$_tmp" "vim" > "$EXPORT_ZSH"
  info "EDITOR='vim' enregistré dans $EXPORT_ZSH"
fi

# ── Version & cache (pour l'auto-update) ──────────────────────────────────────
step "Version & cache"
mkdir -p "$CACHE_DIR"
REMOTE_SHA="$(curl -fsSL --max-time 5 -H 'Accept: application/vnd.github.sha' \
  "https://api.github.com/repos/$REPO/commits/main" 2>/dev/null || true)"
if [ -n "$REMOTE_SHA" ]; then
  _old_sha=""
  [ -f "$CACHE_DIR/version" ] && _old_sha="$(<"$CACHE_DIR/version")"
  printf '%s\n' "$REMOTE_SHA" > "$CACHE_DIR/version"
  date +%s > "$CACHE_DIR/last_check"
  rm -f "$CACHE_DIR/update_available"
  if [ "$_old_sha" = "$REMOTE_SHA" ]; then
    skip "Version déjà à jour : ${REMOTE_SHA:0:7}"
  else
    info "Version installée : ${REMOTE_SHA:0:7}"
  fi
else
  warn "Version distante indisponible — l'auto-update se calera plus tard"
fi

# ── Shell par défaut ──────────────────────────────────────────────────────────
step "Shell par défaut"
if [ "$(basename "$SHELL")" != "zsh" ]; then
  warn "Shell actuel : $SHELL"
  warn "Pour passer à zsh : chsh -s $(command -v zsh)"
else
  skip "zsh est déjà ton shell par défaut"
fi

# ── Fin ───────────────────────────────────────────────────────────────────────
echo -e "\n${GREEN}════════════════════════════════════${NC}"
if [ "$_did_something" = "true" ]; then
  echo -e "${GREEN}  ✅ Terminé !${NC}"
  echo -e "${GREEN}════════════════════════════════════${NC}"
  echo -e "  Lance : ${YELLOW}reload${NC} ou ${YELLOW}exec zsh${NC}"
else
  echo -e "${GREEN}  ✅ Déjà à jour — rien à faire${NC}"
  echo -e "${GREEN}════════════════════════════════════${NC}"
fi
