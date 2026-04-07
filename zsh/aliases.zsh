# =============================================================================
# aliases.zsh — Aliases personnels
# =============================================================================

#------- ZSH -------#
alias zsh-config='$EDITOR ~/.zshrc'
alias zsh-alias='$EDITOR $ZSH_CUSTOM/aliases.zsh'
alias zsh-macros='$EDITOR $ZSH_CUSTOM/macros.zsh'
alias zsh-local='$EDITOR $ZSH_CUSTOM/local.zsh'
alias zsh-update="curl -fsSL https://raw.githubusercontent.com/Ekyoz/Ekyoz/main/install.sh | bash"

# Changer l'éditeur par défaut et le persister dans local.zsh
zsh-editor() {
  echo "Choisissez votre éditeur par défaut :"
  echo "  1) nano"
  echo "  2) vim"
  echo "  3) nvim"
  echo "  4) code (VSCode)"
  echo "  5) Autre"
  read "choice?Votre choix (1-5) : "
  case "$choice" in
    1) _editor="nano" ;;
    2) _editor="vim" ;;
    3) _editor="nvim" ;;
    4) _editor="code" ;;
    5) read "_editor?Entrez le nom de l'éditeur : " ;;
    *) echo "Choix invalide."; return 1 ;;
  esac
  local _local_file="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/local.zsh"
  touch "$_local_file"
  # Supprimer l'ancienne ligne EDITOR puis ajouter la nouvelle
  local _tmp; _tmp="$(grep -v '^export EDITOR=' "$_local_file")"
  printf '%s\nexport EDITOR='"'"'%s'"'"'\n' "$_tmp" "$_editor" > "$_local_file"
  export EDITOR="$_editor"
  echo "Éditeur défini sur : $_editor (rechargez avec : reload)"
}

#------- MAIN -------#
alias reload='source ~/.zshrc'

#------ UTILITIES ------#
alias cls='clear'

# Ajoute tes aliases ici
