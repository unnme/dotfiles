mkcd() {
  mkdir -p "$1" && cd "$1"
}

brewfull() {
  brew update && brew upgrade && brew autoremove && brew cleanup
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

# Prompts until a valid y/n is given; Enter defaults to N; Ctrl-D counts as N.
_ask_yn() {
  local prompt=$1 reply
  while true; do
    if ! read -k 1 "reply?$prompt [y/N] "; then
      echo
      return 1
    fi
    echo
    case $reply in
      [YyНн]) return 0 ;;
      [NnТт]|"") return 1 ;;
      *) echo "please answer y or n" ;;
    esac
  done
}

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
      _ask_yn "Reconnect?" || break
    done
  else
    while true; do
      ssh "${ssh_opts[@]}" kali
      _ask_yn "Reconnect?" || break
    done
  fi

  trap - INT TERM
  tart stop kali
}
