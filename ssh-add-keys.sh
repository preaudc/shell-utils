#!/usr/bin/sh

# HERE: customized PK_LIST with your own private keys in $HOME/.ssh
readonly PK_LIST=(id_ed25519 id_rsa aquilae_id_ed25519)

main() {
  local pks="${PK_LIST[@]}"
  read -p "Enter passphrase for $pks (must be the same for all keys): " -s passphrase
  echo

  for pk in ${PK_LIST[@]}; do
    { sleep .1; echo $passphrase; } | script --quiet --log-out /dev/null --command "ssh-add $HOME/.ssh/$pk"
  done
}

main
