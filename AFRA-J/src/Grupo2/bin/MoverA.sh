#!/bin/bash

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
        ./GraLog.sh $comando_que_me_invoca "Usage: MoverA origen destino [invocante]" "ERR"
        exit 1
    fi
fi

#Si el origen y el destino son iguales, no mover y registrar en el log el error
if [ "$1" = "$2" ]
then
    echo "El origen y el destino son iguales, no se mueve el archivo"
    ./GraLog.sh $comando_que_me_invoca "El origen y el destino son iguales, no se mueve el archivo" "ERR"
    exit 2
fi

#echo "fuente: $archivo_fuente"
#Si el origen no existe, no mover y registrar en el log el error
if [ ! -f "$archivo_fuente" ]
then
    echo "El archivo de origen \"$archivo_fuente\" no existe, no se mueve nada"
    ./GraLog.sh $comando_que_me_invoca "'echo "El archivo de origen \"$archivo_fuente\" no existe, no se mueve nada"'" "ERR"
    exit 3
fi

#echo "dest: $directorio_destino"
#Si el destino no existe, no mover y registrar en el log el error
if [ ! -d "$directorio_destino" ]
then
    echo "El directorio destino \"$directorio_destino\" no existe, no se mueve nada"
    bash ./GraLog.sh $comando_que_me_invoca "'echo "El directorio destino \"$directorio_destino\" no existe, no se mueve nada"'" "ERR"
    exit 4
fi

#Si no es duplicado, lo muevo y salgo
if [ ! -f "$directorio_destino/$nombre_archivo" ]
then
    #mv "$archivo_fuente" "$directorio_destino"
    cp "$archivo_fuente" "$directorio_destino" #para probar, solamente lo copio
    exit 0
fi

#Si no hay carpeta de duplicados, la creo
if [ ! -d "$directorio_destino/duplicados" ]
then
    mkdir $directorio_destino/duplicados
fi

#Si no existe en duplicados, lo copio a duplicados y salgo
if [ ! -f "$directorio_destino/duplicados/$nombre_archivo" ]
then
    #mv "$archivo_fuente" "$directorio_destino/duplicados"
    cp "$archivo_fuente" "$directorio_destino/duplicados/$nombre_archivo" #para probar, solamente lo copio
    exit 0
fi

#FALTA PROGRAMAR ESTE CONTADOR
CONTADOR_DUPLICADOS=0
while [ -f "$directorio_destino/duplicados/$nombre_archivo.$CONTADOR_DUPLICADOS" ]
do
    CONTADOR_DUPLICADOS=$((CONTADOR_DUPLICADOS+1))
done

cp "$archivo_fuente" "$directorio_destino/duplicados/$nombre_archivo.$CONTADOR_DUPLICADOS"

exit 0

