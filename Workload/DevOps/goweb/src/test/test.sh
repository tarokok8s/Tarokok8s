#!/bin/bash
fail=0
if curl -s localhost:8080 | grep "/ -> /opt/www" &>/dev/null; then
  echo "test / ok"
else
  echo "test / fail" && (( fail += 1 ))
fi

if curl -s localhost:8080/info | grep "Hostname" &>/dev/null; then
  echo "test /info ok"
else
  echo "test /info fail" && (( fail += 1 ))
fi

if curl -s localhost:8080/db | grep "call from mydb.sh" &>/dev/null; then
  echo "test /db ok"
else
  echo "test /db fail" && (( fail += 1 ))
fi

if curl -s localhost:8080/data | grep "call from mydata.sh" &>/dev/null; then
  echo "test /data ok"
else
  echo "test /data fail" && (( fail += 1 ))
fi

if [ "$fail" -gt "0" ]; then
  exit 1
fi