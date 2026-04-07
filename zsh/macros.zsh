# =============================================================================
# macros.zsh — Tes fonctions shell personnelles
# =============================================================================

# Créer un dossier et s'y déplacer immédiatement
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Changer l'éditeur par défaut avec détection dynamique
zsh-editor() {
  local _local_file="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/local.zsh"
  local -a _editors
  local -A _seen
  local _cmd _line _desktop _desktop_file _exec _choice _editor _tmp

  for _cmd in "${VISUAL%% *}" "${EDITOR%% *}"; do
    [[ -z "$_cmd" ]] && continue
    command -v "$_cmd" >/dev/null 2>&1 || continue
    [[ -n "${_seen[$_cmd]}" ]] && continue
    _editors+=("$_cmd")
    _seen[$_cmd]=1
  done

  if command -v update-alternatives >/dev/null 2>&1; then
    while IFS= read -r _line; do
      _cmd="${_line##*/}"
      [[ -z "$_cmd" ]] && continue
      command -v "$_cmd" >/dev/null 2>&1 || continue
      [[ -n "${_seen[$_cmd]}" ]] && continue
      _editors+=("$_cmd")
      _seen[$_cmd]=1
    done < <(update-alternatives --list editor 2>/dev/null || true)
  fi

  if command -v xdg-mime >/dev/null 2>&1; then
    _desktop="$(xdg-mime query default text/plain 2>/dev/null)"
    if [[ -n "$_desktop" ]]; then
      for _desktop_file in \
        "$HOME/.local/share/applications/$_desktop" \
        "/usr/local/share/applications/$_desktop" \
        "/usr/share/applications/$_desktop"; do
        [[ -f "$_desktop_file" ]] || continue
        _exec="$(awk -F= '/^Exec=/{print $2; exit}' "$_desktop_file" 2>/dev/null)"
        _cmd="${_exec%% *}"
        _cmd="${_cmd//\"/}"
        _cmd="${_cmd%%\%*}"
        _cmd="${_cmd##*/}"
        [[ -z "$_cmd" ]] && continue
        command -v "$_cmd" >/dev/null 2>&1 || continue
        [[ -n "${_seen[$_cmd]}" ]] && continue
        _editors+=("$_cmd")
        _seen[$_cmd]=1
        break
      done
    fi
  fi

  if [[ "${#_editors[@]}" -eq 0 ]] && command -v editor >/dev/null 2>&1; then
    _editors+=("editor")
  fi
  if [[ "${#_editors[@]}" -eq 0 ]] && command -v vi >/dev/null 2>&1; then
    _editors+=("vi")
  fi
  if [[ "${#_editors[@]}" -eq 0 ]]; then
    echo "Aucun éditeur détecté automatiquement."
    return 1
  fi

  echo "Éditeurs détectés :"
  local i=1
  for _cmd in "${_editors[@]}"; do
    echo "  $i) $_cmd"
    ((i++))
  done

  if [[ -t 0 ]]; then
    read "_choice?Votre choix (1-${#_editors[@]}) [1] : "
  elif [[ -r /dev/tty ]]; then
    read "_choice?Votre choix (1-${#_editors[@]}) [1] : " < /dev/tty || _choice=""
  else
    _choice="1"
    echo "Aucun terminal interactif détecté, éditeur par défaut: ${_editors[1]}"
  fi
  _choice="${_choice:-1}"

  # <-> : pattern zsh qui valide une chaîne composée uniquement de chiffres.
  if [[ "$_choice" != <-> ]] || (( _choice < 1 || _choice > ${#_editors[@]} )); then
    echo "Choix invalide."
    return 1
  fi

  _editor="${_editors[$_choice]}"
  touch "$_local_file"
  _tmp="$(grep -v '^export EDITOR=' "$_local_file" 2>/dev/null || true)"
  printf '%s\nexport EDITOR='"'"'%s'"'"'\n' "$_tmp" "$_editor" > "$_local_file"
  export EDITOR="$_editor"
  source "$_local_file"
  echo "Éditeur défini sur : $_editor (rechargement automatique effectué)"
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

wipef() {
  : > "$1"
}

# Ajoute tes fonctions ici
