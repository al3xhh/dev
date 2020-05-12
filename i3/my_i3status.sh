#!/bin/sh
# shell script to prepend i3status with more stuff

i3status | while :
do
        read line
        echo "$line | al3xhh | `hostname`" || exit 1
done
