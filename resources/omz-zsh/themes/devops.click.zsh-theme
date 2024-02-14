# DevOps.click Theme - Based on jonathan and fino-time Themes

short=true
debug=false

function theme_precmd {
  local TERMWIDTH=$(( $(tput cols) - ${ZLE_RPROMPT_INDENT:-1} ))

  PR_FILLBAR=""
  PR_PWDLEN=""

  # clean up the output of the git_prompt_info command (removing leading and trailing whitespace) and then finding the length of the cleaned-up string, storing it in the git_prompt_info variable.
  local git_prompt_info=${#${(%)$(git_prompt_info)}}
  local git_prompt_status=${#${(%)$(git_prompt_status)}}
  ##### zsh param expansion (${(%):...}), username (%n), hostname (%m), and terminal device (%l), separated by @ and : symbols, (%D{%H:%M:%S}) current time in the format HH:MM:SS, (%${PR_PWDLEN}<...<%<<) truncating or abbreviating the current working directory to fit within a specified length
  # local promptsize=${#${(%):---(%n@%m:%l)---(%D{%H:%M:%S})-(%SROOT.%s)-}} # TOPPPPP
  # local promptsize=${#${(%):-(%n@%m:%l)(%${PR_PWDLEN}<...<%<<)(!.%SROOT.%s)}}
  local promptsize=${#${(%):-(%n@%m:%l)(%${PR_PWDLEN}<...<%<<)(%D{%H:%M:%S})(!.%SROOT.%s)}} # Purrrfect
  # local promptsize=${#${(%):-(%n@%m:%l-%${PR_PWDLEN}<...<%<<)(%D{%H:%M:%S})(!.%SROOT.%s)}}
  #########################################################################################
  local rubypromptsize=${#${(%)$(ruby_prompt_info)}}
  local pwdsize=${#${(%):-%~}}
  # local usernamesize=${#USER} # size of $USER variable

  # Truncate the path if it's too long.
  if (( promptsize + rubypromptsize + pwdsize + git_prompt_info + git_prompt_status > TERMWIDTH )); then
    if [[ $short == true ]]; then
      [[ $debug == true ]] && echo "termsize too_long: short=true"
      (( PR_PWDLEN = TERMWIDTH - promptsize - git_prompt_info - git_prompt_status + 1 ))
    else
      [[ $debug == true ]] && echo "too_long: short=false"
      (( PR_PWDLEN = TERMWIDTH - promptsize - git_prompt_info - git_prompt_status - 1 ))
    fi
  elif [[ "${langinfo[CODESET]}" = UTF-8 ]]; then
    if [[ $short == true ]]; then
      [[ $debug == true ]] && echo "termsize elif utf8: short=true"
      PR_FILLBAR="\${(l:$(( TERMWIDTH - (promptsize + rubypromptsize + pwdsize + git_prompt_info + git_prompt_status - 1) ))::${PR_HBAR}:)}"
    else
      [[ $debug == true ]] && echo "termsize elif utf8: short=false"
      PR_FILLBAR="\${(l:$(( TERMWIDTH - (promptsize + rubypromptsize + pwdsize + git_prompt_info + git_prompt_status + 1) ))::${PR_HBAR}:)}" # if PR_HBAR on PROMPT
    fi
  else
    [[ $debug == true ]] && echo "termsize: else"
    PR_FILLBAR="${PR_SHIFT_IN}\${(l:$(( TERMWIDTH - (promptsize + rubypromptsize + pwdsize + git_prompt_info + git_prompt_status + 1) ))::${altchar[q]:--}:)}${PR_SHIFT_OUT}"
  fi
}

function theme_preexec {
  setopt local_options extended_glob
  if [[ "$TERM" = "screen" ]]; then
    local CMD=${1[(wr)^(*=*|sudo|-*)]}
    echo -n "\ek$CMD\e\\"
  fi
}

autoload -U add-zsh-hook
add-zsh-hook precmd  theme_precmd
add-zsh-hook preexec theme_preexec

# Set the prompt

# Need this so the prompt will work.
setopt prompt_subst

# See if we can use colors.
autoload zsh/terminfo
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE GREY; do
  typeset -g PR_$color="%{$terminfo[bold]$fg[${(L)color}]%}"
  typeset -g PR_LIGHT_$color="%{$fg[${(L)color}]%}"
done
PR_NO_COLOUR="%{$terminfo[sgr0]%}"

# Modify Git prompt
ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} %{%G✚%}"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} %{%G✹%}"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} %{%G✖%}"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} %{%G➜%}"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} %{%G═%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} %{%G✭%}"

# Use extended characters to look nicer if supported.
if [[ "${langinfo[CODESET]}" = UTF-8 ]]; then
  PR_SET_CHARSET=""
  PR_HBAR="─"
  PR_ULCORNER="┌"
  PR_LLCORNER="└"
  PR_LRCORNER="┘"
  PR_URCORNER="┐"
else
  typeset -g -A altchar
  set -A altchar ${(s..)terminfo[acsc]}
  # Some stuff to help us draw nice lines
  PR_SET_CHARSET="%{$terminfo[enacs]%}"
  PR_SHIFT_IN="%{$terminfo[smacs]%}"
  PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
  PR_HBAR="${PR_SHIFT_IN}${altchar[q]:--}${PR_SHIFT_OUT}"
  PR_ULCORNER="${PR_SHIFT_IN}${altchar[l]:--}${PR_SHIFT_OUT}"
  PR_LLCORNER="${PR_SHIFT_IN}${altchar[m]:--}${PR_SHIFT_OUT}"
  PR_LRCORNER="${PR_SHIFT_IN}${altchar[j]:--}${PR_SHIFT_OUT}"
  PR_URCORNER="${PR_SHIFT_IN}${altchar[k]:--}${PR_SHIFT_OUT}"
fi

# Decide if we need to set titlebar text.
case $TERM in
  xterm*)
    PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
    ;;
  screen)
    PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
    ;;
  *)
    PR_TITLEBAR=""
    ;;
esac

# Decide whether to set a screen title
if [[ "$TERM" = "screen" ]]; then
  PR_STITLE=$'%{\ekzsh\e\\%}'
else
  PR_STITLE=""
fi

function virtualenv_info {
  [ $CONDA_DEFAULT_ENV ] && echo "($CONDA_DEFAULT_ENV) "
  [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
}

function prompt_char {
  git branch >/dev/null 2>/dev/null && echo '⠠⠵' && return
  echo '○'
}

# function box_name {
#   local box="${SHORT_HOST:-$HOST}"
#   [[ -f ~/.box-name ]] && box="$(< ~/.box-name)"
#   echo "${box:gs/%/%%}"
# }

# TODO: Get Arrow Boxes from agnoster
# TODO: Fix boxes when address is ~/Documents/GitHub/docli/resources/omz-zsh/themes
if [[ $short == true ]]; then
[[ $debug == true ]] && echo "PROMPT: short=true"
PROMPT='${PR_SET_CHARSET}${PR_STITLE}${(e)PR_TITLEBAR}\
${PR_CYAN}${PR_ULCORNER}${PR_GREY}(\
${PR_GREEN}%${PR_PWDLEN}<...<%~%<<${PR_GREY})\
${PR_CYAN}${PR_HBAR}\
$(ruby_prompt_info)${PR_GREY}[\
${PR_CYAN}%(!.%SROOT%s.%n)${PR_GREY}@${PR_GREEN}%m:%l${PR_GREY}]\
${PR_CYAN}${PR_HBAR}${PR_GREY}(${PR_LIGHT_BLUE}%{$reset_color%}$(git_prompt_info)$(git_prompt_status)${PR_GREY})${PR_CYAN}${(e)PR_FILLBAR}\
${PR_GREY}(${PR_YELLOW}%D{%H:%M:%S}${PR_GREY})\
${PR_CYAN}${PR_URCORNER}\

'"╰\$(virtualenv_info)\$(prompt_char) "''
else
[[ $debug == true ]] && echo "PROMPT: short=false"
PROMPT='${PR_SET_CHARSET}${PR_STITLE}${(e)PR_TITLEBAR}\
${PR_CYAN}${PR_ULCORNER}${PR_HBAR}${PR_GREY}(\
${PR_GREEN}%${PR_PWDLEN}<...<%~%<<${PR_GREY})\
${PR_CYAN}${PR_HBAR}\
$(ruby_prompt_info)${PR_GREY}[\
${PR_CYAN}%(!.%SROOT%s.%n)${PR_GREY}@${PR_GREEN}%m:%l${PR_GREY}]\
${PR_CYAN}${PR_HBAR}${PR_GREY}(${PR_LIGHT_BLUE}%{$reset_color%}$(git_prompt_info)$(git_prompt_status)${PR_GREY})${PR_CYAN}${(e)PR_FILLBAR}\
${PR_GREY}(${PR_YELLOW}%D{%H:%M:%S}${PR_GREY})\
${PR_CYAN}${PR_HBAR}${PR_URCORNER}\

'"╰─\$(virtualenv_info)\$(prompt_char) "''
fi

# display exitcode on the right when > 0
return_code="%(?..%{$fg[red]%}%? ↵ %{$reset_color%})"

if [[ $short == true ]]; then
RPROMPT=' $return_code${PR_CYAN}${PR_BLUE}\
(${PR_YELLOW}%D{%a,%b%d}${PR_BLUE})${PR_CYAN}${PR_LRCORNER}${PR_NO_COLOUR}'
else
RPROMPT=' $return_code${PR_CYAN}${PR_HBAR}${PR_BLUE}\
(${PR_YELLOW}%D{%a,%b%d}${PR_BLUE})${PR_CYAN}${PR_HBAR}${PR_LRCORNER}${PR_NO_COLOUR}'
fi

PS2='${PR_CYAN}${PR_HBAR}\
${PR_BLUE}${PR_HBAR}(\
${PR_LIGHT_GREEN}%_${PR_BLUE})${PR_HBAR}\
${PR_CYAN}${PR_HBAR}${PR_NO_COLOUR} '

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$FG[239]%}on%{$reset_color%} %{$fg[255]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$FG[202]%}✘✘✘"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$FG[040]%}✔"
ZSH_THEME_RUBY_PROMPT_PREFIX=" %{$FG[239]%}using%{$FG[243]%} ‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%{$reset_color%}"
