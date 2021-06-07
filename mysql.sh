#!/usr/bin/bash

(( EUID == 0 )) &&
  { echo >&2 "This script should not be run as root!"; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# Get options.
# -------------------------------------------------------------------------------------------------------------------- #

mysqldump=$( which mysqldump )
tar=$( which tar )
sleep="2"

OPTIND=1

while getopts "u:p:d:h" opt; do
  case ${opt} in
    u)
      user="${OPTARG}"
      ;;
    p)
      password="${OPTARG}"
      ;;
    d)
      database="${OPTARG}"; IFS=';' read -ra database <<< "${database}"
      ;;
    h|*)
      echo "-u '[user]' -p '[password]' -d '[db_1;db_2;db_3]'"
      exit 2
      ;;
  esac
done

shift $(( OPTIND - 1 ))

(( ! ${#database[@]} )) || [[ -z "${org}" ]] && exit 1

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

timestamp() {
  timestamp=$( date -u '+%Y-%m-%d.%T' )
  echo "${timestamp}"
}

for i in "${database[@]}"; do
  timestamp=$( timestamp )
  filename="${i}.${timestamp}.sql"

  echo "" && echo "--- Open: ${i}"
  ${mysqldump} -u "${user}" -p"${password}" --single-transaction "${i}" > "${filename}" \
  && ${tar} -cJf "${filename}.tar.xz" "${filename}"                                     \
  && rm -f "${filename}"
  echo "" && echo "--- Done: ${i}" && echo ""

  sleep ${sleep}
done

# -------------------------------------------------------------------------------------------------------------------- #
# Exit.
# -------------------------------------------------------------------------------------------------------------------- #

exit 0
