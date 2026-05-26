# ============================================
# Zsh Options
# ============================================
setopt AUTO_CD              # cd by typing directory name
setopt AUTO_PUSHD           # push directories onto stack
setopt PUSHD_IGNORE_DUPS    # no duplicate dirs in stack
setopt CORRECT              # command spelling correction
setopt INTERACTIVE_COMMENTS # allow comments in shell
setopt GLOB_DOTS            # include dotfiles in globbing

# ============================================
# History configuration
# ============================================
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS  # no duplicate entries
setopt HIST_FIND_NO_DUPS     # no duplicates in search
setopt HIST_REDUCE_BLANKS    # remove extra blanks
setopt SHARE_HISTORY         # share between sessions
setopt APPEND_HISTORY        # append, don't overwrite
setopt INC_APPEND_HISTORY    # write immediately
setopt HIST_IGNORE_SPACE     # ignore commands starting with space

# ============================================
# PATH configuration (consolidated)
# ============================================
export GOPATH="$HOME/go"
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/Library/pnpm"

path=(
  "$PNPM_HOME"
  "$BUN_INSTALL/bin"
  "/usr/local/texlive/2023/bin/universal-darwin"
  "$HOME/go/bin"
  "$HOME/.zig"
  "$HOME/.local/bin"
  $path
)
typeset -U path  # Remove duplicates

# ============================================
# Completion system
# ============================================
FPATH=/usr/local/share/zsh-completions:$FPATH
autoload -Uz compinit
compinit -C  # -C skips security check for faster startup

# Completion styling
zstyle ':completion:*' menu select                       # arrow-key driven menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"  # colorized completions
zstyle ':completion:*' group-name ''                     # group by category
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*' squeeze-slashes true              # path/to//dir -> path/to/dir
zstyle ':completion:*' complete-options true
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always

# ============================================
# Init Oh My Posh
# ============================================
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/robin.json)"
fi

# ============================================
# Lazy loading for slow tools
# ============================================

# Lazy load NVM (saves ~300ms)
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm "$@"
}
node() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  node "$@"
}
npm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  npm "$@"
}
npx() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  npx "$@"
}
y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
# SDKMAN initialization (required for java/sbt candidates on PATH)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Lazy load kubectl (saves ~100ms)
kubectl() {
  unset -f kubectl
  if command -v /usr/local/bin/kubectl &>/dev/null; then
    source <(/usr/local/bin/kubectl completion zsh)
  fi
  /usr/local/bin/kubectl "$@"
}

# Lazy load docker completions
docker() {
  unset -f docker
  command docker "$@"
}

# ============================================
# Aliases
# ============================================
alias pip=pip3

# Directory listing (eza - modern ls)
alias l='eza -la --icons --git --group-directories-first'
alias ll='eza -l --icons --git --group-directories-first'
alias la='eza -a --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons --git'
alias ls='eza --icons --group-directories-first'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gb='git branch'
alias gst='git stash'

# Misc
alias cls='clear'
alias grep='grep --color=auto'

# Zellij
alias z='zellij'

# Open buffer line in editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# ============================================
# Plugins (sourced from Homebrew)
# ============================================
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf integration (Ctrl+R for history, Ctrl+T for files, Alt+C for cd)
source <(fzf --zsh)
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'

# zoxide (smart cd - use 'z' to jump to directories)
eval "$(zoxide init zsh --cmd cd)"

# zsh-syntax-highlighting (MUST be last plugin sourced)
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ============================================
# Environment variables
# ============================================
export PATH="/usr/local/opt/imagemagick-full/bin:$PATH"
