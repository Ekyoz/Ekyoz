# =============================================================================
# fzf.zsh — Configuration fzf
# =============================================================================

# ── Binaire ──────────────────────────────────────────────────────────────────
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# ── Commande de recherche (fd si dispo, sinon find) ───────────────────────────
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
else
  export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/.git/*"'
  export FZF_ALT_C_COMMAND='find . -type d -not -path "*/.git/*"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# ── Preview (bat si dispo, sinon cat) ────────────────────────────────────────
if command -v bat &>/dev/null; then
  _fzf_preview_file='bat --color=always --style=numbers --line-range=:200 {}'
else
  _fzf_preview_file='cat {}'
fi

# ── Options globales ──────────────────────────────────────────────────────────
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
  --color=fg:#cdd6f4,fg+:#cdd6f4,bg:#1e1e2e,bg+:#313244
  --color=hl:#89b4fa,hl+:#89dceb,info:#cba6f7,prompt:#89b4fa
  --color=pointer:#f38ba8,marker:#a6e3a1,spinner:#f5c2e7,border:#6c7086
"

# ── CTRL+T  : fichiers avec preview ──────────────────────────────────────────
export FZF_CTRL_T_OPTS="
  --preview '$_fzf_preview_file'
  --header='CTRL+/ : toggle preview'
"

# ── ALT+C  : dossiers avec preview (tree si dispo) ───────────────────────────
if command -v tree &>/dev/null; then
  export FZF_ALT_C_OPTS="--preview 'tree -C -L 2 {}'"
else
  export FZF_ALT_C_OPTS="--preview 'ls -la --color=always {}'"
fi

# ── CTRL+R  : historique avec preview de la commande complète ────────────────
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window=down:3:wrap
  --header='CTRL+/ : toggle preview'
"

unset _fzf_preview_file