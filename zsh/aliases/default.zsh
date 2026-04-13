# =============================================================================
# aliases/default.zsh — Aliases partagés
# =============================================================================

#------- ZSH -------#
alias zsh-config='$EDITOR ~/.zshrc'
alias zsh-alias='$EDITOR $ZSH_CUSTOM/aliases/local.zsh'
alias zsh-macros='$EDITOR $ZSH_CUSTOM/macros/local.zsh'
alias zsh-export='$EDITOR $ZSH_CUSTOM/export.zsh'
alias zsh-update="curl -fsSL https://raw.githubusercontent.com/Ekyoz/Ekyoz/main/install.sh | bash"

#------- MAIN -------#
alias reload='source ~/.zshrc'
alias e='$EDITOR'

#------ UTILITIES ------#
alias cls='clear'
