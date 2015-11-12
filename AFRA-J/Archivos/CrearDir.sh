#!/bin/bash

ESTRUCTURA_COMPLETA=$1
ESTRUCTURA_ACTUAL=""

IFS='/' read -ra ADDR <<< "$ESTRUCTURA_COMPLETA"
	
for i in "${ADDR[@]}"
do
	ESTRUCTURA_ACTUAL="$ESTRUCTURA_ACTUAL""$i"/
	
    if ! [ -d $ESTRUCTURA_ACTUAL ]
    then
		mkdir $ESTRUCTURA_ACTUAL
	fi
done


