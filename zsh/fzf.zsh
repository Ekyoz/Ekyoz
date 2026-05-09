# =============================================================================
# fzf.zsh — Configuration fzf
# =============================================================================

# ── Binaire ───────────────────────────────────────────────────────────────────
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# ── Commandes de base (sans fichiers cachés par défaut) ───────────────────────
if command -v fd &>/dev/null; then
  _fzf_cmd_files='fd --type f --follow --exclude .git'
  _fzf_cmd_files_hidden='fd --type f --hidden --follow --exclude .git'
  _fzf_cmd_dirs='fd --type d --follow --exclude .git'
  _fzf_cmd_dirs_hidden='fd --type d --hidden --follow --exclude .git'
else
  _fzf_cmd_files='find . -type f -not -path "*/.git/*" -not -name ".*"'
  _fzf_cmd_files_hidden='find . -type f -not -path "*/.git/*"'
  _fzf_cmd_dirs='find . -type d -not -path "*/.git/*" -not -name ".*"'
  _fzf_cmd_dirs_hidden='find . -type d -not -path "*/.git/*"'
fi

export FZF_DEFAULT_COMMAND="$_fzf_cmd_files"
export FZF_CTRL_T_COMMAND="$_fzf_cmd_dirs"   # CTRL+T → dossiers
export FZF_ALT_C_COMMAND="$_fzf_cmd_dirs"

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

# ── Options globales (bg:-1 = fond transparent) ───────────────────────────────
export FZF_DEFAULT_OPTS="
  --height 60%
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
  --color=fg:#cdd6f4,fg+:#cdd6f4,bg:-1,bg+:-1
  --color=hl:#89b4fa,hl+:#89dceb,info:#cba6f7,prompt:#89b4fa
  --color=pointer:#f38ba8,marker:#a6e3a1,spinner:#f5c2e7,border:#6c7086
"

# ── CTRL+F → fichiers (avec toggle hidden via ALT+H) ─────────────────────────
export FZF_CTRL_T_OPTS="
  --preview '$_fzf_preview_file'
  --header='CTRL+/ : preview  |  ALT+H : toggle hidden'
  --bind='alt-h:reload($_fzf_cmd_files_hidden)'
  --bind='alt-H:reload($_fzf_cmd_files)'
"

# ── CTRL+T → dossiers (avec toggle hidden via ALT+H) ─────────────────────────
export FZF_ALT_C_OPTS="
  --preview '$_fzf_preview_dir'
  --header='CTRL+/ : preview  |  ALT+H : toggle hidden'
  --bind='alt-h:reload($_fzf_cmd_dirs_hidden)'
  --bind='alt-H:reload($_fzf_cmd_dirs)'
"

# ── CTRL+R → historique ───────────────────────────────────────────────────────
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window=down:3:wrap
  --header='CTRL+/ : toggle preview'
"

# ── Remapping des touches (après chargement des widgets fzf) ──────────────────
# CTRL+F → fichiers  (ancien CTRL+T)
# CTRL+T → dossiers  (ancien ALT+C)
bindkey '^F' fzf-file-widget
bindkey '^T' fzf-cd-widget
bindkey -r '^[c' 2>/dev/null  # supprime ALT+C

unset _fzf_cmd_files _fzf_cmd_files_hidden _fzf_cmd_dirs _fzf_cmd_dirs_hidden
unset _fzf_preview_file _fzf_preview_dir