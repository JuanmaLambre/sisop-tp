#!/bin/bash

#Si solamente esta presente en:
#   1 - el proceso Arrancar
#   2 - en el ps
#   3 - el grep
#es porque nadie lo habia lanzado

number=$(ps aux | grep -c $1)
if [[ $number = 3 ]]
then 
    $1 $2 $3 $4 $5 $6 $7 $8 $9 &
    exit 0
fi
echo "Ya hay un proceso $1 corriendo"

#Sino, no lanzo nada porque ya esta corriendo
