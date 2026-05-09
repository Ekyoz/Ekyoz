# =============================================================================
# fzf.zsh — Configuration fzf
# =============================================================================

# ── Binaire ───────────────────────────────────────────────────────────────────
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# ── Commandes (sans cachés par défaut) ────────────────────────────────────────
if command -v fd &>/dev/null; then
  _fzf_files='fd --type f --follow --exclude .git'
  _fzf_files_h='fd --type f --hidden --follow --exclude .git'
  _fzf_dirs='fd --type d --follow --exclude .git'
  _fzf_dirs_h='fd --type d --hidden --follow --exclude .git'
else
  _fzf_files='find . -type f -not -path "*/.git/*" -not -name ".*"'
  _fzf_files_h='find . -type f -not -path "*/.git/*"'
  _fzf_dirs='find . -type d -not -path "*/.git/*" -not -name ".*"'
  _fzf_dirs_h='find . -type d -not -path "*/.git/*"'
fi

# FZF_CTRL_T_COMMAND → utilisé par fzf-file-widget (CTRL+F)
# FZF_ALT_C_COMMAND  → utilisé par fzf-cd-widget    (CTRL+T)
export FZF_DEFAULT_COMMAND="$_fzf_files"
export FZF_CTRL_T_COMMAND="$_fzf_files"
export FZF_ALT_C_COMMAND="$_fzf_dirs"

# ── Preview ───────────────────────────────────────────────────────────────────
_fzf_bin_dir="$(dirname "$(command -v fzf)")"
if [ -f "$_fzf_bin_dir/fzf-preview.sh" ]; then
  _fzf_preview_file="$_fzf_bin_dir/fzf-preview.sh {}"
elif command -v bat &>/dev/null; then
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
export FZF_DEFAULT_OPTS="
  --style=full
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
  --color=fg:#cdd6f4,fg+:#cdd6f4,bg:-1,bg+:-1
  --color=hl:#89b4fa,hl+:#89dceb,info:#cba6f7,prompt:#89b4fa
  --color=pointer:#f38ba8,marker:#a6e3a1,spinner:#f5c2e7,border:#6c7086
"

# ── CTRL+F → fichiers | ALT+H toggle cachés ───────────────────────────────────
export FZF_CTRL_T_OPTS="
  --preview '$_fzf_preview_file'
  --bind='focus:transform-header:file --brief {} 2>/dev/null || echo {}'
  --bind='alt-h:transform:[[ \$FZF_PROMPT == *\"[+H]\"* ]] \
    && echo \"reload($_fzf_files)+change-prompt(fichiers ❯ )\" \
    || echo \"reload($_fzf_files_h)+change-prompt(fichiers [+H] ❯ )\"'
"

# ── CTRL+T → dossiers | ALT+H toggle cachés ──────────────────────────────────
export FZF_ALT_C_OPTS="
  --preview '$_fzf_preview_dir'
  --bind='alt-h:transform:[[ \$FZF_PROMPT == *\"[+H]\"* ]] \
    && echo \"reload($_fzf_dirs)+change-prompt(dossiers ❯ )\" \
    || echo \"reload($_fzf_dirs_h)+change-prompt(dossiers [+H] ❯ )\"'
"

# ── CTRL+R → historique ───────────────────────────────────────────────────────
export FZF_CTRL_R_OPTS="
  --preview='echo {}'
  --preview-window=down:3:wrap
  --header='CTRL+/ : toggle preview'
"

# ── Remapping (après chargement des widgets fzf) ──────────────────────────────
bindkey '^F' fzf-file-widget   # CTRL+F → fichiers
bindkey '^T' fzf-cd-widget     # CTRL+T → dossiers
bindkey -r '^[c' 2>/dev/null   # supprime ALT+C

unset _fzf_files _fzf_files_h _fzf_dirs _fzf_dirs_h
unset _fzf_preview_file _fzf_preview_dir _fzf_bin_dir