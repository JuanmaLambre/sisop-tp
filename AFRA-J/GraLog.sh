#!/bin/bash

usuario=`whoami`


checkMessagType(){
	if [ "$1" != "INFO" -a "$1" != "WAR" -a "$1" != "ERR" ];then
		echo "Error en Log: Tipo de mensaje invalido. Debe Ser de ERR, WAR, INFO"
		exit 2
	fi
}

#aca va la ruta es
getRuta(){
if [ "$1" = "AFINSTAL" ]
then
	 echo "$GRUPO/conf"
	 #echo "logdir"
else
	if [ ! -f "$BINDIR/$1" ]
	then
		echo "Comando no existente: $1"
		exit 3
	else
		echo "$LOGDIR"
	fi
fi

}



getExtension(){
if [ "$1" = "AFINSTAL" ]
then
	 echo "log"
else
	if [ ! -f "$BINDIR/$1" ]
	then
		echo "Comando no existente: $1"
		exit 3
	else
		echo "$LOGEXT"
	fi
fi

}


getFileSize(){
	#stat -f%z $1  #ufunca en mac 
	stat -c %s $1  #funca en linux
}

#comando , mensaje, tipo  ej:(AFINSTAL, hola todos, INFO)
#checkparam
	if [ "$#" -lt 2 ];then
		echo "Error en Log: Cantidad de parametros invalidos. Se deben proporcionar al menos 2 parametros"
		exit 1
	fi

#setdefault
	if [ "$#" -lt 3 ];then
		msgType="INFO"
	else
		msgType=$3
	fi

checkMessagType $msgType
ruta=$(getRuta $1)
extension=$(getExtension $1)

#Verifico si el log no fue creado
if [ ! -f "$ruta/$1.log" ]
then
	#Creo el log	
	touch "$1.log"
	mv "$1.log" "$ruta"
fi



#Obtengo el tam
size=$(getFileSize "$ruta/$1.$extension")
#echo $size

if [ "$size" -gt 3724 ] #Verifico si el tamaño excedio el limite
then	
	#Me quedo con las ultimas 50 lineas del log
	tail -n -50 "$ruta/$1.log" > "$ruta/$1.tmp"
	mv "$ruta/$1.tmp" "$ruta/$1.log"
	echo "`date +"%d/%m/%Y %H:%M"`-$usuario-$1-WAR-Log Excedido" >> "$ruta/$1.$extension"
fi

#Agrego la nueva linea
echo "`date +"%d/%m/%Y %H:%M"`-$usuario-$1-$3-$2" >> "$ruta/$1.$extension"







