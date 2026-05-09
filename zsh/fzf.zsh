# =============================================================================
# fzf.zsh — Configuration fzf
# =============================================================================

# ── Binaire ───────────────────────────────────────────────────────────────────
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# ── Commandes ─────────────────────────────────────────────────────────────────
if command -v fdfind &>/dev/null; then
  _fzf_files='fdfind --type f --follow --exclude .git'
  _fzf_files_h='fdfind --type f --hidden --follow --exclude .git'
  _fzf_dirs='fdfind --type d --follow --exclude .git'
  _fzf_dirs_h='fdfind --type d --hidden --follow --exclude .git'
else
  _fzf_files='find . -mindepth 1 -name ".*" -prune -o -type f -not -path "*/.git/*" -print'
  _fzf_files_h='find . -type f -not -path "*/.git/*"'
  _fzf_dirs='find . -mindepth 1 -name ".*" -prune -o -type d -not -path "*/.git/*" -print'
  _fzf_dirs_h='find . -type d -not -path "*/.git/*"'
fi

export FZF_DEFAULT_COMMAND="$_fzf_files"
export FZF_CTRL_T_COMMAND="$_fzf_files"
export FZF_ALT_C_COMMAND="$_fzf_dirs"

# ── Preview ───────────────────────────────────────────────────────────────────
if command -v bat &>/dev/null; then
  _fzf_preview_file='bat --color=always --style=numbers --line-range=:200 {}'
else
  _fzf_preview_file='cat {}'
fi

if command -v tree &>/dev/null; then
  _fzf_preview_dir='tree -C -L 2 {}'
else
  _fzf_preview_dir='ls -la --color=always {}'
fi

# ── Options globales ──────────────────────────────────────────────────────────
# Couleurs : bordures/layout terminal par défaut, éléments dans le style aussiegeek
# rouge=pointer, bleu=hl/prompt, vert=marker, jaune=info
export FZF_DEFAULT_OPTS="
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt='❯ '
  --pointer='▶'
  --marker='✓'
  --info=inline
  --preview-window=right:55%:wrap
  --bind='ctrl-/:toggle-preview'
  --bind='ctrl-u:preview-half-page-up'
  --bind='ctrl-d:preview-half-page-down'
  --color=bg:-1,bg+:-1,fg:-1,fg+:-1,border:-1
  --color=hl:4,hl+:4,info:3,prompt:4
  --color=pointer:1,marker:2,spinner:3,header:1
"

# ── CTRL+F → fichiers | ALT+H : cachés ON | ALT+MAJ+H : cachés OFF ───────────
export FZF_CTRL_T_OPTS="
  --preview '$_fzf_preview_file'
  --header='CTRL+/ : preview  |  ALT+H : toggle hidden  |  hidden: OFF'
  --bind='alt-h:transform:
    if [[ \$FZF_HEADER == *\"hidden: ON\"* ]]; then
      echo \"reload($_fzf_files)+change-header(CTRL+/ : preview  |  ALT+H : toggle hidden  |  hidden: OFF)\"
    else
      echo \"reload($_fzf_files_h)+change-header(CTRL+/ : preview  |  ALT+H : toggle hidden  |  hidden: ON)\"
    fi'
"

export FZF_ALT_C_OPTS="
  --preview '$_fzf_preview_dir'
  --header='CTRL+/ : preview  |  ALT+H : toggle hidden  |  hidden: OFF'
  --bind='alt-h:transform:
    if [[ \$FZF_HEADER == *\"hidden: ON\"* ]]; then
      echo \"reload($_fzf_dirs)+change-header(CTRL+/ : preview  |  ALT+H : toggle hidden  |  hidden: OFF)\"
    else
      echo \"reload($_fzf_dirs_h)+change-header(CTRL+/ : preview  |  ALT+H : toggle hidden  |  hidden: ON)\"
    fi'
"

# ── CTRL+R → historique ───────────────────────────────────────────────────────
export FZF_CTRL_R_OPTS="
  --preview='echo {}'
  --preview-window=down:3:wrap
  --header='CTRL+/ : toggle preview'
"

# ── Widget CTRL+F custom ──────────────────────────────────────────────────────
fzf-file-widget-smart() {
  local file
  file="$(eval "$FZF_CTRL_T_COMMAND" | fzf ${=FZF_CTRL_T_OPTS})"
  [ -z "$file" ] && zle redisplay && return

  if [ -z "$BUFFER" ]; then
    ${EDITOR:-vim} "$file"
    zle reset-prompt
  else
    LBUFFER+="$file"
  fi
}
zle -N fzf-file-widget-smart

# ── Remapping ─────────────────────────────────────────────────────────────────
bindkey '^F' fzf-file-widget-smart
bindkey '^T' fzf-cd-widget
bindkey -r '^[c' 2>/dev/null

unset _fzf_files _fzf_files_h _fzf_dirs _fzf_dirs_h
unset _fzf_preview_file _fzf_preview_dir