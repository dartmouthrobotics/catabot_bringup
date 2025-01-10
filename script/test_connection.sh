#!/bin/bash

function check_ipaddr
{
  # Here we look for an IP(v4|v6) address when doing ip addr
  # Note we're filtering out 127.0.0.1 and ::1/128 which are the "localhost" ip addresses
  # I'm also removing fe80: which is the "link local" prefix

  ip addr | \
  grep -v 127.0.0.1 | \
  grep -v '::1/128' | \
  grep -v 'inet6 fe80:' | \
  grep -E "inet [[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+|inet6" | \
  wc -l
}

function wait_for_ip
{
  while ! ping -c 1 -n -w 1 $1 &> /dev/null
    do
      echo "Ping fail $1"
      sleep 1
  done
  echo "Ping success $1
  "
}


function wait_for_process
{
  while ! ps aux | grep -v grep | grep "$1" > /dev/null; do
    sleep 1 # Wait for 1 second before checking again
  done

  echo "Process '$1' has started!"
}