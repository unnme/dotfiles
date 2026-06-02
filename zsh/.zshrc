# ============================================================================
# XDG BASE DIRECTORIES
# ============================================================================

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================
# CORE SETTINGS
# ============================================================================

export LANG=en_US.UTF-8
export EDITOR="nvim"
export HOMEBREW_NO_ENV_HINTS=1
export EZA_CONFIG_DIR="$HOME/.config/eza"
export BAT_THEME="tokyonight_night"
export DOCKER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/docker"
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/npm/npmrc"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export USQL_HISTORY="$XDG_STATE_HOME/usql/history"
export BUN_INSTALL="$HOME/.local"

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_SILENT


# ============================================================================
# HISTORY (Dev optimized)
# ============================================================================

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
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

path=(
  $HOME/.local/bin
  $HOME/bin
  /opt/homebrew/bin
  /opt/homebrew/opt/openjdk@21/bin
  $BUN_INSTALL/bin
  $path
)

[[ $- == *i* ]] && eval "$(zoxide init zsh)"


# ============================================================================
# FAST NVM LAZY LOADER
# ============================================================================

export NVM_DIR="$HOME/.local/share/nvm"

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

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d $ZINIT_HOME ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "$ZINIT_HOME/zinit.zsh"


# ============================================================================
# PROMPT
# ============================================================================

zinit ice depth=1
zinit light romkatv/powerlevel10k

[[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/p10k/p10k.zsh" ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/p10k/p10k.zsh"


# ============================================================================
# COMPLETION (ULTRA FAST CACHE)
# ============================================================================

autoload -Uz compinit

_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
if [[ -n $_zcompdump(#qN.mh+24) ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi
unset _zcompdump


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

[[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliases.zsh" ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliases.zsh"


# ============================================================================
# FUNCTIONS
# ============================================================================

tm() {
  if [[ -z "$1" ]]; then
    if [[ -z "$TMUX" ]]; then
      tmux new-session -A -s _main
    fi
    return
  fi
  local name="$1"
  if [[ ! "$name" =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]]; then
    echo "error: only letters, digits, _ and - allowed (must start with a letter or _)" && return 1
  fi
  if tmux has-session -t "$name" 2>/dev/null; then
    echo "session '$name' already exists" && return 1
  fi
  tmux new-session -d -s "$name" && echo "session '$name' created (detached)"
}

y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"

  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi

  rm -f -- "$tmp"
}


orb() {
  if [[ "$1" == "stop" ]]; then
    orbctl stop "${@:2}"
    osascript -e 'quit app "OrbStack"' 2>/dev/null
  else
    command orb "$@"
  fi
}

ff() {
  aerospace list-windows --all | fzf --bind 'enter:execute(bash -c "aerospace focus --window-id {1}")+abort'
}

pbp() {
  if [[ $# -eq 0 ]]; then
    pwd | pbcopy
  else
    realpath "$1" | pbcopy
  fi
}



# ============================================================================
# KALI
# ============================================================================

kali() {
  local mtp=0
  [[ "$1" == "-mtp" ]] && mtp=1

  trap 'tart stop kali 2>/dev/null; [[ -n $tart_pid ]] && kill $tart_pid 2>/dev/null; trap - INT TERM; return 1' INT TERM

  local shared=~/Documents/Shared

  if [[ -e $shared && ! -d $shared ]]; then
    echo "error: $shared exists but is not a directory" >&2
    return 1
  fi
  [[ ! -d $shared ]] && mkdir -p "$shared"

  local ssh_opts=(-o ConnectTimeout=2 -o StrictHostKeyChecking=no -o BatchMode=yes)

  if ! tart list 2>/dev/null | grep -q "^local  kali.*running"; then
    tart run kali --no-graphics --dir=mac:"$shared" &
    local tart_pid=$! attempts=0 max=30

    until ssh "${ssh_opts[@]}" -q kali exit 2>/dev/null; do
      if ! kill -0 "$tart_pid" 2>/dev/null; then
        echo "error: tart exited unexpectedly — VM failed to start" >&2
        return 1
      fi
      (( ++attempts >= max )) && {
        echo "error: timed out after ${max}s waiting for kali" >&2
        kill "$tart_pid" 2>/dev/null
        return 1
      }
      sleep 1
    done
  fi

  if (( mtp )); then
    # Connect with reverse tunnel: Kali localhost:1082 → Mac 127.0.0.1:1082 (Shadowrocket)
    echo "mitmweb UI → http://127.0.0.1:9081"
    while true; do
      ssh "${ssh_opts[@]}" -R 1082:127.0.0.1:1082 -L 9081:127.0.0.1:8081 kali
      read -k 1 "reply?Reconnect? [y/N] "; echo || break
      [[ $reply =~ ^[Yy]$ ]] || break
    done
  else
    while true; do
      ssh "${ssh_opts[@]}" kali
      read -k 1 "reply?Reconnect? [y/N] "; echo || break
      [[ $reply =~ ^[Yy]$ ]] || break
    done
  fi

  trap - INT TERM
  read -k 1 "reply?Stop kali VM? [y/N] "; echo
  [[ $reply =~ ^[Yy]$ ]] && tart stop kali
}


# ============================================================================
# KEYBINDINGS
# ============================================================================

# Force emacs keymap — zsh auto-activates vi mode when EDITOR contains "vi" (nvim)
bindkey -e

bindkey "^[[1;3D" backward-word
bindkey "^[[1;3C" forward-word
bindkey '^[^H' backward-kill-word
bindkey '^[d' kill-word
bindkey "^[[1;4D" beginning-of-line
bindkey "^[[1;4C" end-of-line

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# Prefix-based history search with arrow keys
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# zoxide + fzf interactive jump
_zoxide_zi_widget() { BUFFER="__zoxide_zi"; zle accept-line; }
zle -N _zoxide_zi_widget
bindkey '^G' _zoxide_zi_widget

# bun completions
[ -s "$HOME/.local/share/bun/completions/_bun" ] && source "$HOME/.local/share/bun/completions/_bun"

# True color support for iTerm2
export COLORTERM=truecolor
