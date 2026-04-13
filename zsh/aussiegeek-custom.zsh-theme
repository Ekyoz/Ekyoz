HOST_VALUE="${HOSTNAME:-${HOST:-}}"
HOST_SEGMENT="%m"
if [[ -n "${HOST_VALUE}" ]]; then
  HOST_SEGMENT="%{${fg[red]}%}%m"
fi

if [[ -n "${SSH_CONNECTION:-}${SSH_CLIENT:-}${SSH_TTY:-}" ]]; then
  if [[ -n "${DISPLAY:-}" ]]; then
    SSH_SEGMENT=" %{${fg_bold[blue]}%}(%{${fg[green]}%}SSH🖥️%{${fg_bold[blue]}%})"
  else
    SSH_SEGMENT=" %{${fg_bold[blue]}%}(%{${fg[green]}%}SSH%{${fg_bold[blue]}%})"
  fi
else
  SSH_SEGMENT=""
fi

PROMPT_TIME="%{${fg_bold[blue]}%}[%F{242}%T%f%{${fg_bold[blue]}%}]"
PROMPT_USER_HOST="%{${fg_bold[blue]}%} [%{${fg[red]}%}%n@%m${SSH_SEGMENT}%{${fg_bold[blue]}%}]"
PROMPT_PATH_INFO="%{${fg_bold[blue]}%} [%{${fg[red]}%}%~\$(git_prompt_info)%{${fg[yellow]}%}\$(ruby_prompt_info)%{${fg_bold[blue]}%}]"
PROMPT_USER_HOST_PATH="${PROMPT_USER_HOST}${PROMPT_PATH_INFO}%{$reset_color%}"
PROMPT="${PROMPT_TIME}${PROMPT_USER_HOST_PATH}%{$reset_color%}
 $ "

# git theming
ZSH_THEME_GIT_PROMPT_PREFIX="%{${fg_bold[green]}%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="✔"
ZSH_THEME_GIT_PROMPT_DIRTY="✗"
