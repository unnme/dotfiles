for _aliases_file in "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliases"/*.zsh; do
  source "$_aliases_file"
done
unset _aliases_file
