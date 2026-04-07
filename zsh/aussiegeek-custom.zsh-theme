HOST_SEGMENT="%m"
if [[ -n "${HOSTNAME:-${HOST:-}}" ]]; then
  HOST_SEGMENT="%{${fg[red]}%}%m"
fi

PROMPT="%{${fg_bold[blue]}%}[ %F{242}%T%f %{${fg_bold[blue]}%}] %{${fg_bold[blue]}%}[ %{${fg[red]}%}%n%{${fg_bold[red]}%}@${HOST_SEGMENT}%{${fg_bold[blue]}%}:%~\$(git_prompt_info) %{${fg_bold[blue]}%}]%{$reset_color%}"

# git theming
ZSH_THEME_GIT_PROMPT_PREFIX="%{${fg_bold[green]}%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="✔"
ZSH_THEME_GIT_PROMPT_DIRTY="✗"
