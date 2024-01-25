#!/usr/bin/sh

get_ssh_agent_pid() {
  ps -u $(whoami) -o pid,comm | awk '$2=="ssh-agent"{print $1}'
}

get_ssh_agent_socket() {
  ls $HOME/tmp/ssh-agent/agent.*
}

run_ssh_agent() {
  rm -f $HOME/tmp/ssh-agent/agent.*
  eval $(ssh-agent -a $HOME/tmp/ssh-agent/agent.$$)
}

main() {
  local ssh_agent_pid=$(get_ssh_agent_pid)
  if [[ -z "$ssh_agent_pid" ]]; then
    run_ssh_agent
  else
    local ssh_agent_socket=$(get_ssh_agent_socket)
    export SSH_AGENT_PID="$ssh_agent_pid"
    export SSH_AUTH_SOCK="$ssh_agent_socket"
  fi
}

main
