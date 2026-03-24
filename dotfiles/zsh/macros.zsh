# =============================================================================
# macros.zsh — Tes fonctions shell personnelles
# =============================================================================

# Créer un dossier et s'y déplacer immédiatement
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Afficher les ports en écoute (Linux + macOS)
ports() {
  if command -v ss &>/dev/null; then
    ss -tuln
  else
    netstat -tuln
  fi
}

# Chercher dans l'historique
hist() {
  history | grep "$1"
}

# Extraire n'importe quelle archive
extract() {
  case "$1" in
    *.tar.bz2) tar xjf "$1"  ;;
    *.tar.gz)  tar xzf "$1"  ;;
    *.tar.xz)  tar xJf "$1"  ;;
    *.zip)     unzip "$1"    ;;
    *.gz)      gunzip "$1"   ;;
    *.rar)     unrar x "$1"  ;;
    *)         echo "Format non supporté : $1" ;;
  esac
}

# ── DEV HELPERS ──────────────────────────────────────────────────────────────

# Git: status + branches + derniers commits
gstl() {
  git status -sb
  echo "----"
  git branch --show-current
  echo "----"
  git log --oneline -n 8
}

# Git: commit rapide
gac() {
  # usage: gac "message"
  git add -A && git commit -m "$*"
}

# Git: nouvelle branche + push upstream
gnew() {
  # usage: gnew feature/ma-feature
  git checkout -b "$1" && git push -u origin "$1"
}

# Démarrer un projet JS/TS rapidement
devnode() {
  # usage: devnode mon-projet
  mkdir -p "$1" && cd "$1" || return 1
  npm init -y
  git init
  echo "node_modules/" > .gitignore
  echo ".env" >> .gitignore
  ${EDITOR:-vim} .
}

# Python: créer environnement virtuel .venv + activer
mkvenv() {
  # usage: mkvenv [python3|python]
  local py="${1:-python3}"
  "$py" -m venv .venv && source .venv/bin/activate
}

# Lancer un serveur HTTP local rapide
serve() {
  # usage: serve [port]
  local port="${1:-8000}"
  python3 -m http.server "$port"
}

# Trouver un process sur un port
pport() {
  # usage: pport 3000
  lsof -i :"$1"
}

# Kill process sur un port
kport() {
  # usage: kport 3000
  local pid
  pid="$(lsof -ti :"$1")"
  [ -n "$pid" ] && kill -9 "$pid" && echo "Killed PID $pid on port $1" || echo "Aucun process sur le port $1"
}

# Nettoyage branches locales mergées
gclean() {
  git branch --merged | grep -v "\*" | grep -vE "main|master|develop|dev" | xargs -r git branch -d
}

wipef() {
  : > "$1"
}

# Ajoute tes fonctions ici
