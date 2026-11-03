# ============================================================================
# XDG BASE DIRECTORIES
# ============================================================================

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"


# ============================================================================
# CORE SETTINGS
# ============================================================================

export LANG=en_US.UTF-8
export EDITOR="nvim"
export HOMEBREW_NO_ENV_HINTS=1
export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"
export BAT_THEME="tokyonight_night"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export USQL_HISTORY="$XDG_STATE_HOME/usql/history"
export BUN_INSTALL="$HOME/.local"

# True color support for iTerm2
export COLORTERM=truecolor

# Silence iTerm2 Shell Integration's blue mark indicator on every prompt line
export ITERM2_SQUELCH_MARK=1

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_SILENT

# Disable zsh's own "%" marker for unterminated previous output
unsetopt PROMPT_SP


# ============================================================================
# HISTORY (Dev optimized)
# ============================================================================

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=200000
SAVEHIST=200000

setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_expire_dups_first
setopt hist_reduce_blanks
setopt hist_verify


# ============================================================================
# PATH CLEANUP
# ============================================================================

typeset -U path PATH

# ~/.local/bin also holds bun binaries (BUN_INSTALL=$HOME/.local)
path=(
  $HOME/.local/bin
  /opt/homebrew/bin
  /opt/homebrew/opt/openjdk/bin
  $path
)


# ============================================================================
# FAST NVM LAZY LOADER
# ============================================================================

export NVM_DIR="$XDG_DATA_HOME/nvm"

# Add default nvm node to PATH immediately (without loading full nvm.sh)
if [[ -d "$NVM_DIR/versions/node" ]]; then
  # Resolve alias chain: default -> node -> v25.2.0 etc.
  _nvm_val=$(cat "$NVM_DIR/alias/default" 2>/dev/null)
  for _i in {1..5}; do
    case "$_nvm_val" in
      v[0-9]*)
        _nvm_node_dir="$NVM_DIR/versions/node/$_nvm_val"
        break
        ;;
      node|stable|unstable)
        # Latest installed — sort numerically (macOS-safe, no ls -v)
        _nvm_val=$(ls "$NVM_DIR/versions/node" 2>/dev/null \
          | sed 's/^v//' \
          | sort -t. -k1,1n -k2,2n -k3,3n \
          | tail -1 \
          | sed 's/^/v/')
        ;;
      *)
        # Might be another alias file (e.g. lts/iron)
        _nvm_next=$(cat "$NVM_DIR/alias/$_nvm_val" 2>/dev/null)
        [[ -z "$_nvm_next" ]] && break
        _nvm_val="$_nvm_next"
        ;;
    esac
  done
  [[ -d "${_nvm_node_dir}/bin" ]] && path=("${_nvm_node_dir}/bin" $path)
  unset _nvm_val _nvm_next _nvm_node_dir _i
fi

nvm() {
  unset -f nvm
  source /opt/homebrew/opt/nvm/nvm.sh
  source /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm 2>/dev/null
  nvm "$@"
}


# ============================================================================
# ZINIT (FAST BOOTSTRAP)
# ============================================================================

ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"

if [[ ! -d $ZINIT_HOME ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "$ZINIT_HOME/zinit.zsh"


# ============================================================================
# PROMPT (passion theme, sourced without full oh-my-zsh)
# ============================================================================

autoload -Uz colors && colors
zinit snippet OMZL::git.zsh
zinit snippet https://raw.githubusercontent.com/ChesterYue/ohmyzsh-theme-passion/master/passion.zsh-theme


# ============================================================================
# COMPLETION (ULTRA FAST CACHE)
# ============================================================================

autoload -Uz compinit

_zcompdump="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
if [[ -n $_zcompdump(#qN.mh+24) ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi
unset _zcompdump

# bun completions
[ -s "$XDG_DATA_HOME/bun/completions/_bun" ] && source "$XDG_DATA_HOME/bun/completions/_bun"


# ============================================================================
# PLUGINS (ASYNC LOAD)
# ============================================================================

zinit ice wait'0' lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions
zinit ice wait'0' lucid blockf
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab
zinit ice wait'0' lucid
zinit light joshskidmore/zsh-fzf-history-search
zinit light zdharma-continuum/fast-syntax-highlighting


# ============================================================================
# FZF CONFIG
# ============================================================================

export FZF_DEFAULT_OPTS="
--height 40%
--layout=reverse
--border
"


# ============================================================================
# ZSTYLE
# ============================================================================

zstyle ':completion:*' completer _complete _ignored _approximate

zstyle ':fzf-tab:*' switch-group '<' '>'

zstyle ':fzf-tab:complete:*:*' fzf-preview \
  '[ -f ${realpath} ] && bat --color=always --style=plain ${realpath} || eza -la ${realpath}'


# ============================================================================
# ALIASES
# ============================================================================

[[ -f "$XDG_CONFIG_HOME/zsh/aliases.zsh" ]] && source "$XDG_CONFIG_HOME/zsh/aliases.zsh"


# ============================================================================
# KEYBINDINGS
# ============================================================================

# Force emacs keymap — zsh auto-activates vi mode when EDITOR contains "vi" (nvim)
bindkey -e

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# Prefix-based history search with arrow keys
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# zoxide + fzf interactive jump (__zoxide_zi is defined by zoxide init below)
_zoxide_zi_widget() { BUFFER="__zoxide_zi"; zle accept-line; }
zle -N _zoxide_zi_widget
bindkey '^G' _zoxide_zi_widget


# ============================================================================
# SECRETS
# ============================================================================

# GitHub token for Claude Code's github MCP server.
# Exported to every process started from this shell.
export GITHUB_TOKEN=$(grep '^GITHUB_TOKEN=' "$HOME/.claude/.env" 2>/dev/null | cut -d= -f2)


# ============================================================================
# ZOXIDE (keep last — zoxide expects to be initialized at the end of zshrc)
# ============================================================================

[[ $- == *i* ]] && eval "$(zoxide init zsh)"

