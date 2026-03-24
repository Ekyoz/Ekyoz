# =============================================================================
# aliases.zsh — Aliases personnels
# =============================================================================

#------- MAIN -------#
alias zsh-config='$EDITOR ~/.zshrc'
alias zsh-alias='$EDITOR $ZSH_CUSTOM/aliases.zsh'
alias zsh-macros='$EDITOR $ZSH_CUSTOM/macros.zsh'
alias zsh-local='$EDITOR $ZSH_CUSTOM/local.zsh'
alias reload='source ~/.zshrc'

#------ UTILITIES ------#
alias cls='clear'
alias wipef=wipef() {
  : > "$1"
}

# Ajoute tes aliases ici
