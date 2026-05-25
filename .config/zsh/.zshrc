ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d $ZINIT_HOME ] ; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

eval "$(oh-my-posh init zsh --config ${XDG_CACHE_HOME}/oh-my-posh/themes/custom.omp.json)"

# add zinit plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

# load completions
autoload -Uz compinit && compinit

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# options
source "$ZDOTDIR/options.zsh"

# alias
source "$ZDOTDIR/aliases.zsh"

# paths
source "$ZDOTDIR/env.zsh"
