#!/usr/bin/env bash
#https://medium.com/@gchudnov/trapping-signals-in-docker-containers-7a57fdda7d86
set -x

pid=0

# SIGTERM-handler
term_handler() {
  # Scipt which gracefully shutdown database before container goes down
  # Be aware that standard command "docker stop container" will wait only 10 second
  # If database need more time use e.g. for 100 sec: "docker stop container -t 100"

  ps -ef
  echo -e "\n STOPING DB..\n"
  pid=`pgrep -u postgres -d:|awk -F':' '{ print $1 }'`
  ps --pid=$pid
  #kill -SIGTERM "$pid"
  sudo -i -u postgres -- sh -c '/usr/pgsql-14/bin/pg_ctl -D /postgresql stop -mf'
  if [ $pid -ne 0 ]; then
    while [ -e /proc/$pid ]
    do
      echo "Process: $pid is still running"
      ps --pid=$pid
      ps -ef
      sleep .6
    done
    echo "Process $PID has finished"
    ps --pid=$pid
  fi
  echo -e "\nTHE DB STOPPED\n"
  ps -ef

  pid=`pgrep sshd`
  ps --pid=$pid
  kill -SIGTERM "$pid"
  if [ $pid -ne 0 ]; then
    while [ -e /proc/$pid ]
    do
      echo "Process: $pid is still running"
      ps --pid=$pid
      ps -ef
      sleep .6
    done
    echo "Process $PID has finished"
    ps --pid=$pid
  fi
  echo -e "\nTHE SSHD STOPPED\n"
  # Killing PID=1 by exit command
  exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; term_handler' SIGTERM

######################################
# SSHD service
/usr/sbin/sshd -D &
ps -ef

# POSTGRES service
sudo -i -u postgres -- sh -c '/usr/pgsql-14/bin/pg_ctl -D /postgresql start'
ps -ef

#####################################
#wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
