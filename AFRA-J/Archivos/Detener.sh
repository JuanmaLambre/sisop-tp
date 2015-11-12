#!/bin/bash
cant=$(ps aux | grep -c " .*$1");

if [[ $cant < 4 ]]
then
	echo "No hay un proceso $1 corriendo";
	exit 0
fi

CONT=1;
for word in $(ps aux | grep " .*$1")
do
	if [[ $CONT == 1 ]]
    then
    	#ignoro el usuario
    	CONT=$((CONT+1));
    else
    	kill $word
    	exit 0
    fi
done

