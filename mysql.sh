#!/usr/bin/bash

(( EUID == 0 )) &&
  { echo >&2 "This script should not be run as root!"; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# Get options.
# -------------------------------------------------------------------------------------------------------------------- #

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

mysqldump=$( command -v mysqldump )
tar=$( command -v tar )

timestamp() {
  timestamp=$( date -u '+%Y-%m-%d.%H-%M-%S' )
  echo "${timestamp}"
}

for i in "${database[@]}"; do
  timestamp=$( timestamp )
  backup_name="${i}.${timestamp}.sql"

  echo "" && echo "--- Open: '${i}'"
  ${mysqldump} -u "${user}" -p"${password}" --single-transaction "${i}" > "${backup_name}"  \
    && ${tar} -cJf "${backup_name}.tar.xz" "${backup_name}"                                 \
    && rm -f "${backup_name}"
  echo "" && echo "--- Done: '${i}'" && echo ""
done

# -------------------------------------------------------------------------------------------------------------------- #
# Exit.
# -------------------------------------------------------------------------------------------------------------------- #

exit 0
