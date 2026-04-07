PROMPT="%{${fg_bold[blue]}%}[ %{${fg[red]}%}%T %{${fg_bold[blue]}%}] %{${fg_bold[blue]}%}[ %{${fg[green]}%}%n%{${fg_bold[blue]}%}@%{${fg[magenta]}%}%m%{${fg_bold[blue]}%}:%~\$(git_prompt_info)%{${fg[yellow]}%}\$(ruby_prompt_info)%{${fg_bold[blue]}%} ]%{$reset_color%}\n$ "

# git theming
ZSH_THEME_GIT_PROMPT_PREFIX="%{${fg_bold[green]}%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="✔"
ZSH_THEME_GIT_PROMPT_DIRTY="✗"
