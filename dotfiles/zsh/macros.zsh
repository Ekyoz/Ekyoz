# =============================================================================
# macros.zsh — Tes fonctions shell personnelles
# =============================================================================
 
# Créer un dossier et s'y déplacer immédiatement
mkcd() {
  mkdir -p "$1" && cd "$1"
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
 
# Ajoute tes fonctions ici
