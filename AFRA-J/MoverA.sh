#!/bin/bash

#HIPOTESIS:
# PARAMETRO OPCIONAL es un parametro que el usuario elige si pone o no, 
#       el desarrollador no elige el caso

#cargo parametros, chequeo numero:

if [ $# == 2 ] 
then
   archivo_fuente=$1
   nombre_archivo="${archivo_fuente##*/}"
   directorio_destino=$2
else
    if [ $# == 3 ] 
    then
        archivo_fuente=$1
        nombre_archivo="${archivo_fuente##*/}"
        directorio_destino=$2
        comando_que_me_invoca=$3
    else
        echo "Usage: MoverA origen destino [invocante]"
        exit 1
    fi
fi

#Si el origen y el destino son iguales, no mover y registrar en el log el error
if [ "$1" = "$2" ]
then
    echo "El origen y el destino son iguales, no se mueve el archivo"
    exit 2
fi

#echo "fuente: $archivo_fuente"
#Si el origen no existe, no mover y registrar en el log el error
if [ ! -f "$archivo_fuente" ]
then
    echo "El archivo de origen \"$archivo_fuente\" no existe, no se mueve nada"
    exit 3
fi

#echo "dest: $directorio_destino"
#Si el destino no existe, no mover y registrar en el log el error
if [ ! -d "$directorio_destino" ]
then
    echo "El directorio destino \"$directorio_destino\" no existe, no se mueve nada"
    exit 4
fi

#Si no es duplicado, lo muevo y salgo
if [ ! -f "$directorio_destino/$nombre_archivo" ]
then
    #mv "$archivo_fuente" "$directorio_destino"
    cp "$archivo_fuente" "$directorio_destino" #para probar, solamente lo copio
    exit 0
fi

 
echo "duplicado, man"

exit 0

