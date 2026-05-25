# History Rules (Stored safely inside the Zsh XDG directory)
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_find_no_dups

# UI Shell Behaviors
setopt autocd
setopt nobeep
setopt numeric_glob_sort

# Terminal Autocomplete Compliancy Styles
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
