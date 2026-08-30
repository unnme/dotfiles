# eza
alias ls="eza --icons"
alias ll="eza -l --icons --git"
alias la="eza -la --icons --git"
alias lt="eza --tree --icons"

alias iip="ipconfig getifaddr en0"
alias oip="curl https://ipinfo.io/ip"

alias cat="bat --paging=never"

alias vi="nvim"
alias sudo='sudo '
alias cd="z"

# Brew
alias brewfull='brew update && brew upgrade && brew autoremove && brew cleanup'

# SSH tunnels
alias ss-tunnel='ssh -fNL 33611:localhost:33611 skystark-root && echo "https://localhost:33611/whereisxur/panel/"'
alias ss-tunnel-close='pkill -f "ssh -fNL 33611"'

# superseedr
alias ssdr="superseedr"
