#!/usr/bin/env bash

shopt -s globstar

readonly ARGS="$@"
readonly PWD_STORE_DIR=${PASSWORD_STORE_DIR-$HOME/.password-store}
declare -A RESERVED_NODE_DIR=( [Cemetery]=1 )

PREFIX_DIR=$PWD_STORE_DIR
ROOT_NODE=

cmdline() {
  if [[ $# -eq 1 ]]; then
    ROOT_NODE=$1
    PREFIX_DIR="$PWD_STORE_DIR/$ROOT_NODE"
  elif [[ $# -gt 1 ]]; then
    echo "Usage: $0 [ROOT_NODE]"
    exit 1
  fi
}

list_password_files() {
  local password_files=( $PREFIX_DIR/**/*.gpg )
  password_files=( "${password_files[@]#"$PREFIX_DIR"/}" )
  password_files=( "${password_files[@]%.gpg}" )
  printf '%s\n' ${password_files[@]}
}

main() {
  cmdline $ARGS
  run
}

menu() {
  declare -a password_nodes=("${!1}")

  declare -A menu_nodes
  for pwd_node in ${password_nodes[@]}; do
    local k=${pwd_node%%/*}
    local v=${pwd_node/$k/}

    [[ "$ROOT_NODE" != "" ]] \
      && k="$ROOT_NODE/$k"

    [[ "${RESERVED_NODE_DIR[$k]}" -ne 1 ]] \
      && menu_nodes[$k]=$v
  done

  for k in "${!menu_nodes[@]}"; do printf '[%s]=%s ' $k ${menu_nodes[$k]}; done
}

run(){
  local password_files=( $(list_password_files) )
  eval declare -A menu_list=( $(menu password_files[@]) )

  local node=$(printf '%s\n' "${!menu_list[@]}" | sort | rofi -dmenu "Password Store ")

  [[ "$node" == "" ]] \
    && exit 0

  if [[ "${menu_list[$node]}" != "" ]]; then
    exec $0 $node
  else
    printf '%s' "${node##*/}" | xclip -selection primary
    PASSWORD_STORE_CLIP_TIME=10 pass -c $node
  fi
}

main
