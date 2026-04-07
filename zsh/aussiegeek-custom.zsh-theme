HOST_VALUE="${HOSTNAME:-${HOST:-}}"
HOST_SEGMENT="%m"
if [[ -n "${HOST_VALUE}" ]]; then
  HOST_SEGMENT="%{${fg[red]}%}%m"
fi

PROMPT_TIME="%{${fg_bold[blue]}%}[ %F{242}%T%f %{${fg_bold[blue]}%}]"
PROMPT_USER_HOST_PATH="%{${fg_bold[blue]}%} [ %{${fg[red]}%}%n@%m:%~\$(git_prompt_info)%{${fg[yellow]}%}\$(ruby_prompt_info)%{${fg_bold[blue]}%} ]%{$reset_color%}
 $ "
PROMPT="${PROMPT_TIME} ${PROMPT_USER_HOST_PATH}%{$reset_color%}"

# git theming
ZSH_THEME_GIT_PROMPT_PREFIX="%{${fg_bold[green]}%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="✔"
ZSH_THEME_GIT_PROMPT_DIRTY="✗"
