# Append system pathways natively using Zsh's path array
path+=("$HOME/.local/bin" "$HOME/bin")
path+=("/usr/local/go/bin")
path+=("$HOME/.opencode/bin")
export PATH

# PNPM Package Manager (Fully XDG Standardized)
export PNPM_HOME="${XDG_DATA_HOME}/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
