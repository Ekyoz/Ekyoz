# ── Oh My Zsh ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="aussiegeek-custom"

# ── Plugins ───────────────────────────────────────────────────────────────────
# Note : zsh-syntax-highlighting doit toujours être en dernier
plugins=(
  git
  docker
  docker-compose
  npm
  node
  python
  pip
  sudo
  z
  fzf
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ── PATH ──────────────────────────────────────────────────────────────────────
# Binaires installés sans sudo (eza, fd, fzf...) : ~/.local/bin prioritaire
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# ── Langue & format horaire ───────────────────────────────────────────────────
# LC_TIME=C.UTF-8 : format 24h neutre, disponible partout (évite l'AM/PM)
export LANG=fr_FR.UTF-8
export LC_TIME=C.UTF-8

# ── Historique ────────────────────────────────────────────────────────────────
HISTSIZE=20000
SAVEHIST=20000
setopt HIST_IGNORE_DUPS    # pas de doublons consécutifs
setopt HIST_IGNORE_SPACE   # exclure les commandes précédées d'un espace
setopt SHARE_HISTORY       # partager l'historique entre sessions

# ── Comportement ──────────────────────────────────────────────────────────────
setopt AUTO_CD             # taper un dossier = cd automatique
setopt CORRECT             # correction automatique des typos

# ── Couleur autosuggestions ───────────────────────────────────────────────────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666"

# ── Éditeur ───────────────────────────────────────────────────────────────────
export EDITOR='vim'
command -v nvim >/dev/null 2>&1 && export EDITOR='nvim'

# ── Fichiers custom partagés + locaux ─────────────────────────────────────────
for _zsh_file in \
  "$ZSH_CUSTOM/fzf.zsh" \
  "$ZSH_CUSTOM/aliases/default.zsh" \
  "$ZSH_CUSTOM/aliases/local.zsh" \
  "$ZSH_CUSTOM/macros/default.zsh" \
  "$ZSH_CUSTOM/macros/local.zsh"; do
  [[ -f "$_zsh_file" ]] && source "$_zsh_file"
done
unset _zsh_file

# ── Overrides locaux (exports propres à la machine) ───────────────────────────
[[ -f "$ZSH_CUSTOM/export.zsh" ]] && source "$ZSH_CUSTOM/export.zsh"

# ── Auto-update (après export.zsh pour respecter les réglages EKYOZ_*) ─────────
[[ -f "$ZSH_CUSTOM/update.zsh" ]] && source "$ZSH_CUSTOM/update.zsh"
