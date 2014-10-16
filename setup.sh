#!/bin/bash

set -efu -o pipefail

source $(dirname $0)/utils.inc

readonly SRC_DIR=git_hooks/
readonly TARGET_DIR=.git/hooks/

preExistCheck() {
  local FILE=$(basename ${1} .py)
  local TARGET=${TARGET_DIR}${FILE}
  local FILE_BAK=${FILE}.bak
  local TARGET_BAK=${TARGET}.bak
  echo ${TARGET}
  if [[ -e ${TARGET} || -L ${TARGET} ]]; then
    printf "$(focus ${FILE}) already exists! Backing up to $(focus ${FILE_BAK})..."
    mv ${TARGET} ${TARGET_BAK}

    if [[ -e ${TARGET_BAK} || -L ${TARGET_BAK} ]]; then
      echo_success
    else
      echo_failure "An error occurred while trying to backup $(focus ${FILE})." 
    fi
  fi  
}

linkHooks() {
  local SRC_FILE=${1}
  local TARGET_FILE=$(basename ${SRC_FILE} .py)
  local TARGET=${TARGET_DIR}${TARGET_FILE}

  printf "Setting up %s git hook..." $(focus ${TARGET_FILE})
  ln -s ${SRC_DIR}${SRC_FILE} ${TARGET}
  if [[ ! -L ${TARGET} ]]; then
    echo_failure "An error occurred while trying to link $(focus ${TARGET_FILE})."
  fi
  echo_success
}

# makeExec() {
#   if [ -e ${TARGET} ]; then
#     echo_success
#     printf "Making %s executable..." $(focus ${TARGET_FILE})
#     chmod 755 ${TARGET}
#     echo_success
#   else
#     echo_failure "An error occurred while trying to create %s." $(focus ${TARGET_FILE})
#   fi

#   printf "Making %s executable..." $(focus ${SRC_FILE})
#   if [ -e ${SRC} ]; then
#     chmod 755 ${TARGET}
#     echo_success
#   else
#     echo_failure "%s has been moved or deleted" $(focus ${SRC})
#   fi  
# }

# installDeps() {
#   printf "Confirming %s is installed..." $(focus "Node")
#   if hash npm 2>/dev/null; then
#     echo_success
#     printf "Installing %s dependencies...\n" $(focus "NPM")
#     npm install
#   else
#     echo_failure "%s must be installed" $(focus"Node")
#   fi
# }

for file in $(ls git_hooks/); do
  preExistCheck ${file}
  linkHooks ${file}
  # makeExec ${file}
  # installDeps ${file}
done

printf "${GREEN}Setup Successful!${NORMAL}"