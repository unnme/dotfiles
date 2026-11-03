# eza
alias ls="eza --icons"
alias ll="eza -l --icons --git"
alias la="eza -la --icons --git"
alias lt="eza --tree --icons -a --git-ignore"

alias iip="ipconfig getifaddr en0"
alias oip="curl https://ipinfo.io/ip"

alias cat="bat --paging=never"
alias df='df -h'

alias vi="nvim"
alias sudo='sudo '

# SSH tunnels
alias ss-tunnel='ssh -fNL 33611:localhost:33611 skystark-root && echo "https://localhost:33611/whereisxur/panel/"'
alias ss-tunnel-close='pkill -f "ssh -fNL 33611"'

# superseedr
alias ssdr="superseedr"
