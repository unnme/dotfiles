cl() {
  local file="$HOME/Library/CloudStorage/Dropbox/CL/PhoneBook.csv"
  if [[ $# -eq 0 ]]; then
    csvlens "$file"
  else
    csvlens --filter "$1" "$file"
  fi
}
