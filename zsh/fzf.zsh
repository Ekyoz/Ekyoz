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
  --color=fg:-1,fg+:2,bg:-1,bg+:-1
  --color=hl:4,hl+:6,info:3,prompt:4
  --color=pointer:1,marker:2,spinner:3,border:4,header:1
"

# ── CTRL+F → fichiers | ALT+H toggle cachés ──────────────────────────────────
_fzf_hidden_flag_f='/tmp/fzf_hidden_files'
export FZF_CTRL_T_OPTS="
  --preview '$_fzf_preview_file'
  --header='CTRL+/ : preview  |  ALT+H : toggle hidden'
  --bind='alt-h:transform:
    if [ -f $_fzf_hidden_flag_f ]; then
      rm -f $_fzf_hidden_flag_f
      echo \"reload($_fzf_files)+change-prompt(fichiers ❯ )\"
    else
      touch $_fzf_hidden_flag_f
      echo \"reload($_fzf_files_h)+change-prompt(fichiers [+H] ❯ )\"
    fi'
"

# ── CTRL+T → dossiers | ALT+H toggle cachés ──────────────────────────────────
_fzf_hidden_flag_d='/tmp/fzf_hidden_dirs'
export FZF_ALT_C_OPTS="
  --preview '$_fzf_preview_dir'
  --header='CTRL+/ : preview  |  ALT+H : toggle hidden'
  --bind='alt-h:transform:
    if [ -f $_fzf_hidden_flag_d ]; then
      rm -f $_fzf_hidden_flag_d
      echo \"reload($_fzf_dirs)+change-prompt(dossiers ❯ )\"
    else
      touch $_fzf_hidden_flag_d
      echo \"reload($_fzf_dirs_h)+change-prompt(dossiers [+H] ❯ )\"
    fi'
"

# ── CTRL+R → historique ───────────────────────────────────────────────────────
export FZF_CTRL_R_OPTS="
  --preview='echo {}'
  --preview-window=down:3:wrap
  --header='CTRL+/ : toggle preview'
"

# ── Remapping ─────────────────────────────────────────────────────────────────
bindkey '^F' fzf-file-widget
bindkey '^T' fzf-cd-widget
bindkey -r '^[c' 2>/dev/null

unset _fzf_files _fzf_files_h _fzf_dirs _fzf_dirs_h
unset _fzf_preview_file _fzf_preview_dir
unset _fzf_hidden_flag_f _fzf_hidden_flag_d