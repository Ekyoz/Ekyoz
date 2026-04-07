PROMPT="%{${fg_bold[blue]}%}[ %{${fg[black]}%}%T %{${fg_bold[blue]}%}] %{${fg_bold[blue]}%}[ %{${fg[red]}%}%n%{${fg_bold[blue]}%}@%{${fg[red]}%}%m%{${fg_bold[blue]}%}:%~\$(git_prompt_info)%{$reset_color%}"

# git theming
ZSH_THEME_GIT_PROMPT_PREFIX="%{${fg_bold[green]}%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="✔"
ZSH_THEME_GIT_PROMPT_DIRTY="✗"
