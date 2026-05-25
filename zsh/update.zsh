# =============================================================================
# update.zsh — Vérification automatique des mises à jour (façon oh-my-zsh)
#
# Au démarrage du shell, compare (de façon throttlée et NON bloquante) le dernier
# commit de la branche `main` du dépôt avec la version installée localement.
# Quand une nouvelle version est détectée, propose de mettre à jour.
#
# Réglages — surchargeables dans export.zsh :
#   EKYOZ_REPO                  dépôt GitHub "owner/name"   (défaut : Ekyoz/Ekyoz)
#   EKYOZ_UPDATE_INTERVAL_DAYS  jours entre deux checks      (défaut : 1)
#   EKYOZ_DISABLE_AUTO_UPDATE   "true" pour tout désactiver  (défaut : false)
# =============================================================================

: ${EKYOZ_REPO:=Ekyoz/Ekyoz}
: ${EKYOZ_UPDATE_INTERVAL_DAYS:=1}
: ${EKYOZ_DISABLE_AUTO_UPDATE:=false}
: ${EKYOZ_INSTALL_URL:=https://raw.githubusercontent.com/$EKYOZ_REPO/main/install.sh}

_ekyoz_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/ekyoz-zsh"
_ekyoz_version_file="$_ekyoz_cache_dir/version"        # SHA actuellement installé
_ekyoz_lastcheck_file="$_ekyoz_cache_dir/last_check"   # timestamp du dernier check
_ekyoz_flag_file="$_ekyoz_cache_dir/update_available"  # SHA distant si MAJ dispo

# ── Mise à jour manuelle (réutilise l'installeur distant) ─────────────────────
zsh-update() {
  command -v curl >/dev/null 2>&1 || { print -u2 -- "curl introuvable"; return 1; }
  print -P "%F{blue}[ekyoz]%f Mise à jour en cours..."
  # EKYOZ_FROM_UPDATER=1 : l'installeur ne fait pas le exec lui-même, on s'en
  # charge ici pour recharger le shell courant (où la fonction tourne).
  if curl -fsSL "$EKYOZ_INSTALL_URL" | EKYOZ_FROM_UPDATER=1 bash; then
    rm -f "$_ekyoz_flag_file"
    print -P "%F{green}[ekyoz]%f Mise à jour terminée — rechargement du shell..."
    exec zsh
  else
    print -P "%F{red}[ekyoz]%f Échec de la mise à jour."
    return 1
  fi
}

# ── Check distant non-bloquant (lancé en arrière-plan) ────────────────────────
# Récupère le SHA du dernier commit via l'API GitHub (header sha = texte brut,
# pas de JSON à parser) et marque une MAJ si différent du SHA installé.
_ekyoz_check_remote() {
  local remote installed
  remote="$(curl -fsSL --max-time 5 -H 'Accept: application/vnd.github.sha' \
    "https://api.github.com/repos/$EKYOZ_REPO/commits/main" 2>/dev/null)" || return 0
  [[ -n "$remote" ]] || return 0

  installed=""
  [[ -f "$_ekyoz_version_file" ]] && installed="$(<"$_ekyoz_version_file")"
  if [[ -n "$installed" && "$remote" != "$installed" ]]; then
    print -r -- "$remote" > "$_ekyoz_flag_file"
  else
    rm -f "$_ekyoz_flag_file"
  fi
}

# ── Planifie un check si l'intervalle est écoulé ──────────────────────────────
_ekyoz_maybe_check() {
  [[ "$EKYOZ_DISABLE_AUTO_UPDATE" == "true" ]] && return 0
  command -v curl >/dev/null 2>&1 || return 0
  mkdir -p "$_ekyoz_cache_dir" 2>/dev/null || return 0

  local now last interval
  now=$(date +%s)
  interval=$(( EKYOZ_UPDATE_INTERVAL_DAYS * 86400 ))
  last=0
  [[ -f "$_ekyoz_lastcheck_file" ]] && last="$(<"$_ekyoz_lastcheck_file")"
  [[ "$last" == <-> ]] || last=0

  (( now - last < interval )) && return 0
  print -r -- "$now" > "$_ekyoz_lastcheck_file"
  # Sous-shell détaché : ne bloque pas le démarrage, pas de message de job.
  ( _ekyoz_check_remote & ) >/dev/null 2>&1
}

# ── Propose la MAJ si un check précédent a détecté un nouveau commit ──────────
_ekyoz_prompt_update() {
  [[ "$EKYOZ_DISABLE_AUTO_UPDATE" == "true" ]] && return 0
  [[ -o interactive && -t 0 ]] || return 0   # uniquement dans un vrai terminal
  [[ -f "$_ekyoz_flag_file" ]] || return 0

  local remote answer
  remote="$(<"$_ekyoz_flag_file")"
  print -P "%F{yellow}[ekyoz]%f Nouvelle version dispo (${remote[1,7]})."
  if read -q "answer?         Mettre à jour maintenant ? [y/N] "; then
    print ""
    zsh-update
  else
    print ""
  fi
}

# Ordre : on propose d'abord (flag du check précédent), puis on planifie le suivant.
_ekyoz_prompt_update
_ekyoz_maybe_check
