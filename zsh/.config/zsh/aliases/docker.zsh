# containers
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dpsa="docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dsp="docker system prune -f"
alias dspv="docker system prune -a --volumes"

# compose
alias dcu="docker compose up"
alias dcud="docker compose up -d"
alias dcd="docker compose down"
alias dcdnv="docker compose down -v"
alias dcb="docker compose build"
alias dcr="docker compose restart"
alias dcl="docker compose logs -f"
