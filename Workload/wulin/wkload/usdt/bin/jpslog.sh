#!/bin/bash

[ -f /tmp/jlog.stop ] && sudo rm /tmp/jlog.stop
echo "[`hostname`]" > /tmp/jps-`hostname`.hdp.log

jid=""
while true; do

  [ -f /tmp/jlog.stop ] && break

  jps -v | grep -v Jps > /tmp/jps.txt
  jcid=$(cat /tmp/jps.txt | grep -v -E "DataNode|--|NodeManager" | cut -d ' ' -f1 | tr -d '\n')
  [ "$jcid" == "" ] && continue
  if [ "$jid" != "$jcid" ]; then
     jid="$jcid"
     d=$(date +%H:%M:%S)
     j=""
     for x in $(cat /tmp/jps.txt | cut -d ' ' -f1 | uniq)
     do
       a=$(cat /tmp/jps.txt | grep -e "^$x")
       echo $a | cut -d ' ' -f1,2 >/tmp/out
       n=$(cat /tmp/out | grep -v -E "DataNode|--|NodeManager")
       if [ "$n" != "" ]; then
          b=${a##*-Xmx}
          j="$j$n ${b%% *}\n"
       fi
     done

     [ "$j" != "" ] && echo -e "$d\n$j" >> /tmp/jps-`hostname`.hdp.log
  fi

done

