#!/usr/bin/env bash
#https://medium.com/@gchudnov/trapping-signals-in-docker-containers-7a57fdda7d86
set -x

pid=0

# SIGUSR1-handler
my_handler_return_to_the_begining_of_the_loop() {
  echo 'Bash should be worked again'
}


# SIGTERM-handler
term_handler() {
  # Scipt which gracefully shutdown database before container goes donw
  # Be aware that standard command "podman stop container" will wait only 10 second
  # If database need more time use e.g. for 100 sec: "podman stop container -t 100"
  ps -ef
  echo -e "\n STOPING DB..\n"
  pid=`pgrep -u postgres -d:|awk -F':' '{ print $1 }'`
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
trap 'kill ${!}; my_handler_return_to_the_begining_of_the_loop' SIGUSR1
trap 'kill ${!}; term_handler' SIGTERM

######################################
# SSHD service
/usr/sbin/sshd -D &

# POSTGRES service
ps -ef
sudo -i -u postgres -- sh -c '/usr/pgsql-14/bin/pg_ctl -D /postgresql start'
ps -ef

#####################################
#wait forever
echo -e "\nIF YOU EXIT FROM BASH, LET'S SAY YOU CAN DEBUG SCRIPT\nWHICH IS RESPONSIBLE FOR START AND STOP DB DURING UP AND DOWN CONTAINER\n"
while true
do
#  tail -f /dev/null & wait ${!}
  echo -e "\nSTARTING TTY WITH BASH..\n"
  /bin/bash ;\
  ps -ef;\
  echo -e  '\nTO REACTIVATE BASH:\nctrl+p,ctrl+1 TO RETURN TO HOST AND TYPE THE FOLLOWING COMMAND:\npodman kill --signal="SIGUSR1" container_name\npodman attach container_name\n\nTO SHUT DOWN CONTAINER WITH GRACEFULLY SHUTTING DOWN DB DO THE FOLLOWING COMMAND:\nctrl+p,ctrl+1 TO RETURN TO HOST AND TYPE THE FOLLOWING COMMAND:\npodman stop container_name -t <the_maximum_time_after_container_can_wait_for_db_to_be_shutdown>\n';\
  tail -f /dev/null & wait ${!}
done