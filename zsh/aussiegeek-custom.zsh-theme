HOST_VALUE="${HOSTNAME:-${HOST:-}}"
HOST_SHORT="${HOST_VALUE%%.*}"
HOST_COLOR="red"
case "${HOST_SHORT}" in
  Coxyz)
    HOST_COLOR="yellow"
    ;;
  Aixyz)
    HOST_COLOR="cyan"
    ;;
esac
HOST_SEGMENT="%F{$HOST_COLOR}%m"

if [[ -n "${SSH_CONNECTION:-}${SSH_CLIENT:-}${SSH_TTY:-}" ]]; then
  if [[ -n "${DISPLAY:-}" ]]; then
    SSH_SEGMENT=" %{${fg_bold[blue]}%}(%F{22}SSH🖥️%{${fg_bold[blue]}%})"
  else
    SSH_SEGMENT=" %{${fg_bold[blue]}%}(%F{22}SSH%{${fg_bold[blue]}%})"
  fi
else
  SSH_SEGMENT=""
fi

USER_COLOR="242"
case "${USER}" in
  opxyz)
    USER_COLOR="red"
    ;;
  minecraft)
    USER_COLOR="green"
    ;;
esac

python_venv_prompt_info() {
  if [[ -n "${VIRTUAL_ENV:-}" ]]; then
    echo "%{${fg_bold[blue]}%}[%{${fg[white]}%}$(basename "${VIRTUAL_ENV}")%{${fg_bold[blue]}%}]"
  fi
}

PROMPT_TIME="%{${fg_bold[blue]}%}[%F{242}%T%f%{${fg_bold[blue]}%}]"
PROMPT_USER_HOST="%{${fg_bold[blue]}%} [%F{$USER_COLOR}%n%{${fg_bold[blue]}%}@${HOST_SEGMENT}${SSH_SEGMENT}%{${fg_bold[blue]}%}]"
PROMPT_PATH_INFO="%{${fg_bold[blue]}%} [%{${fg[red]}%}%~\$(git_prompt_info)%{${fg[yellow]}%}\$(ruby_prompt_info)%{${fg_bold[blue]}%}]"
PROMPT_VENV=" \$(python_venv_prompt_info)"
PROMPT_USER_HOST_PATH="${PROMPT_USER_HOST}${PROMPT_PATH_INFO}${PROMPT_VENV}%{$reset_color%}"
PROMPT="${PROMPT_TIME}${PROMPT_USER_HOST_PATH}%{$reset_color%}
 $ "

# git theming
ZSH_THEME_GIT_PROMPT_PREFIX="%{${fg_bold[green]}%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="✔"
ZSH_THEME_GIT_PROMPT_DIRTY="✗"
