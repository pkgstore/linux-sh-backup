#!/usr/bin/bash

(( EUID == 0 )) &&
  { echo >&2 "This script should not be run as root!"; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# Get options.
# -------------------------------------------------------------------------------------------------------------------- #

tar=$( command -v tar )

OPTIND=1

while getopts "d:h" opt; do
  case ${opt} in
    d)
      directory="${OPTARG}"; IFS=';' read -ra directory <<< "${directory}"
      ;;
    h|*)
      echo "-d '[dir_1;dir_2;dir_3]'"
      exit 2
      ;;
  esac
done

shift $(( OPTIND - 1 ))

(( ! ${#directory[@]} )) && exit 1

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

timestamp() {
  timestamp=$( date -u '+%Y-%m-%d.%H-%M-%S' )
  echo "${timestamp}"
}

for i in "${directory[@]}"; do
  timestamp=$( timestamp )
  backup_name="${i}"

  echo "" && echo "--- Open: ${i}"
  ${tar} -cJf "${backup_name}.tar.xz" "${backup_name}"
  echo "" && echo "--- Done: ${i}" && echo ""
done

# -------------------------------------------------------------------------------------------------------------------- #
# Exit.
# -------------------------------------------------------------------------------------------------------------------- #

exit 0