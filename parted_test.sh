#!/bin/bash -
PATH=/bin:sbin:/usr/bin:/usr/sbin
export PATH
i=1
while [ $i -lt 6 ]
    do
        j=`echo $i|awk '{printf "%c",97+$i}'`
        parted /dev/sd$j << EOF
        mklabel gpt
        mkpart primary 0 -1
        Ignore
        quit
        EOF
    echo "\n****/dev/sd${j} was parted waiting for 3 seconds ****\n"
    sleep 1s
    mkfs.ext4 /dev/sd${j}1
    if [ "$?"="0" ];then
        echo "sd${j}1 was formated,waiting for 5 seconds"
    fi
    let i+=1
    sleep 1s
    done

