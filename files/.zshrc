# Set up the prompt

autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# starship
eval "$(starship init zsh)"

# gt (goto) indexed directories
eval "$(goto-rs init)"

# Alias for 'thefuck helper tool 
eval "$(thefuck --alias tfk)"

# Alias for exa (replacement for ls)
alias lf='exa -alF'
alias lft='exa -alFT'

# Alias for listing amount of files in dir
alias af='lf | wc -l'

# add default color output for grep
alias grep='grep --color=always'

#add default color + side-by-side comparison for diff
alias diff='diff --colow=always -y'

# function for using du, (see used space for explicit folder)
uspace() {
   du -h -d1  --time $1
}

# Function for moving up through directories
gb() {
   cmd="cd "
   if [ -z $1 ]; then 
      return 
   fi
   for (( c=0; c<$1; c++ )) do 
      cmd=$cmd"../"
   done
   eval $cmd
   pwd
}

