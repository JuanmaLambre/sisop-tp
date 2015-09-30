#!/bin/bash

#Variables y directorios predeterminados
GRUPO="Grupo2"			
CONFDIR="$GRUPO/conf"
BINDIR="$GRUPO/bin"
MAEDIR="$GRUPO/mae"
NOVEDIR="$GRUPO/novedades"
DATASIZE="100"
ACEPDIR="$GRUPO/aceptadas"
PROCDIR="$GRUPO/sospechosas"
REPODIR="$GRUPO/reportes"
LOGDIR="$GRUPO/log"
LOGEXT="lg"
LOGSIZE="400"
RECHDIR="$GRUPO/rechazadas"

GRALOG="Archivos/GraLog.sh"

declare -a ARRAY_DIR

ArchivosBIN=( "AFINI.sh" "AFREC.sh" "AFUMB.sh" "AFLIST.pl" "MoverA.sh" "GraLog.sh" "Detener.sh" "Arrancar.sh" "CrearDir.sh" )
ArchivosMAE=( "agentes.csv" "CdA.csv" "CdP.csv" "centrales.csv" "umbrales.csv" )


#Mensajes predeterminados
MENSAJE_PERL_ERROR="\nPara ejecutar el sistema AFRA-J es necesario contar con Perl 5 o superior.
					\nEfectúe su instalación e inténtelo nuevamente.
					\nProceso de Instalación Cancelado"
MENSAJE_TERMS_Y_COND="\n***************************************************
					  \n*\t  Proceso de Instalación de \"AFRA-J\"   \t*
					  \n***************************************************
					  \n A T E N C I O N: Al instalar UD. expresa aceptar los términos y condiciones
					  \ndel \"ACUERDO DE LICENCIA DE SOFTWARE\" incluido en este paquete.
					  \nAcepta? (si – no):"
MENSAJE_CONFIRMAR_INST="\nIniciando Instalación. Esta Ud. seguro? (si - no):"
MENSAJE_CREANDO_ESTRUCTURAS="\nCreando Estructuras de directorio. . . "
MENSAJE_INST_PROGRAMAS="Instalando Programas y Funciones"
MENSAJE_INST_MAESTROS_TABLAS="Instalando Archivos Maestros y Tablas"
MENSAJE_ACTUALIZANDO_CONFIGURACION="Actualizando la configuración del sistema"
MENSAJE_INTALACION_TERMINADA="Instalación CONCLUIDA"
MENSAJE_DIR_ERROR="El directorio ya fue utilizado o ingresó un nombre incorrecto. Defina otro: "


#Funciones
function ImprimirMensaje {
	MENSAJE="$1"
	echo -e -n $MENSAJE" " >&0
}

function ValidarDirectorio { #CAMBIAR LA MANERA DE DEVOLVER
	DIRECTORIOS=("${@}")
	
	resultado='1'
	while [ "$resultado" != "0" ]
	do
		read DIR
		resultado='0'
		for dir in ${DIRECTORIOS[*]}
		do
			if [ "$dir" = "$DIR" ]
			then
				ImprimirMensaje "$MENSAJE_DIR_ERROR"
				resultado='1'
			fi
		done
	done
	echo $DIR
}

function DefinirDirecorio {
	MENSAJE=$1
	TIPO_LOG=$2
	ImprimirMensaje "$MENSAJE"
	
	DIR=$(ValidarDirectorio "${ARRAY_DIR[@]}" )
	MENSAJE_LOG="$MENSAJE $DIR"
	bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_LOG`" "$TIPO_LOG"
	
	echo $DIR
}
		
function ValidarRespuestaSiNo {
	MENSAJE=$1
	ImprimirMensaje "$MENSAJE"
	
	read RESPUESTA
	while [ $RESPUESTA != "si" -a $RESPUESTA != "no" ]
	do
		ImprimirMensaje "Ingrese una opcion valida (si - no):"
		read RESPUESTA
	done
	MENSAJE_LOG="$MENSAJE $RESPUESTA"
	bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_LOG`" "INFO"
	
	echo $RESPUESTA
}

function ValidarNumero {
	es_num='1'
	num='^[0-9]+$'
	while [ $es_num != '0' ]
	do
		read POSIBLE_NUM
		if [[ $POSIBLE_NUM =~ $num ]]
		then
			es_num='0'
		else
			ImprimirMensaje "Ingrese un numero correcto:"
		fi
	done
	echo $POSIBLE_NUM
}


#AFINSTAL
let "INST_POINT = 1"

while [ $INST_POINT -ne 21 ]
do

case $INST_POINT in

	1)  #Punto 1: Verificar si está instalado AFRA_J
																			 
		if [ -f "$CONFDIR/AFINSTAL.cnfg" ]    								 
		then
			let "INST_POINT = 2"
		else
			let "INST_POINT = 4"
		fi ;;
		
	2)  #Punto 2: Verificar si la instalación está completa
	
		#Recuperamos los directorios
		maedir=$(grep "MAEDIR" "$CONFDIR/AFINSTAL.cnfg"   | sed 's-^[^=]*=\([^=]*\)=[^=]*=[^=]*$-\1-' )
		bindir=$(grep "BINDIR" "$CONFDIR/AFINSTAL.cnfg"   | sed 's-^[^=]*=\([^=]*\)=[^=]*=[^=]*$-\1-' )
		novedir=$(grep "NOVEDIR" "$CONFDIR/AFINSTAL.cnfg" | sed 's-^[^=]*=\([^=]*\)=[^=]*=[^=]*$-\1-' )
		acepdir=$(grep "ACEPDIR" "$CONFDIR/AFINSTAL.cnfg" | sed 's-^[^=]*=\([^=]*\)=[^=]*=[^=]*$-\1-' )
		procdir=$(grep "PROCDIR" "$CONFDIR/AFINSTAL.cnfg" | sed 's-^[^=]*=\([^=]*\)=[^=]*=[^=]*$-\1-' )
		repodir=$(grep "REPODIR" "$CONFDIR/AFINSTAL.cnfg" | sed 's-^[^=]*=\([^=]*\)=[^=]*=[^=]*$-\1-' )
		logdir=$(grep "LOGDIR" "$CONFDIR/AFINSTAL.cnfg"   | sed 's-^[^=]*=\([^=]*\)=[^=]*=[^=]*$-\1-' )
		rechdir=$(grep "RECHDIR" "$CONFDIR/AFINSTAL.cnfg" | sed 's-^[^=]*=\([^=]*\)=[^=]*=[^=]*$-\1-' )
		confdir="$CONFDIR"
		
		InstalacionCompleta='0'
		
		ArchivosBINFaltantes=( )
		ArchivosBINExistentes=( )
		ArchivosMAEFaltantes=( )
		ArchivosMAEExistentes=( )
		
		#Obtengo los archivos que no están en los directorios correspondientes
		for file in ${ArchivosBIN[*]}
		do
			if ! [ -f "$bindir/$file" ]
			then
				ArchivosBINFaltantes=( "${ArchivosBINFaltantes[@]}" "$file" )
				InstalacionCompleta='1'
			else
				ArchivosBINExistentes=( "${ArchivosBINExistentes[@]}" "$file" )
			fi
		done
		
		for file in ${ArchivosMAE[*]}
		do
			if ! [ -f "$maedir/$file" ]
			then
				ArchivosMAEFaltantes=( "${ArchivosMAEFaltantes[@]}" "$file" )
				InstalacionCompleta='1'
			else
				ArchivosMAEExistentes=( "${ArchivosMAEExistentes[@]}" "$file" )
			fi
		done
		
		MENSAJE_ESTADO_INST="\nDirectorio de Configuración: $confdir. Archivos: $(ls -f $confdir/*)
							 \nDirectorio de Ejecutables: $bindir. Archivos: ${ArchivosBINExistentes[*]}
							 \nDirectorio de Maestros y Tablas: $maedir. Archivos: ${ArchivosMAEExistentes[*]}
							 \nDirectorio de recepción de archivos de llamadas: $novedir
							 \nDirectorio de Archivos de llamadas Aceptados: $acepdir
							 \nDirectorio de Archivos de llamadas Sospechosas: $procdir
							 \nDirectorio de Archivos de Reportes de llamadas: $repodir
							 \nDirectorio de Archivos de Log: $logdir. Archivos: $(ls -f $logdir/)
							 \nDirectorio de Archivos Rechazados: $rechdir"

		if [ "$InstalacionCompleta" = '0' ]
		then
			MENSAJE_ESTADO_INST+="\nEstado de la instalación: COMPLETA
								  \nProceso de Instalación Finalizado"
			echo -e $MENSAJE_ESTADO_INST
			let "INST_POINT = 21"
		else
			MENSAJE_ESTADO_INST+="\nEstado de la instalación: INCOMPLETA
								  \nComponentes faltantes: ${ArchivosBINFaltantes[*]} ${ArchivosMAEFaltantes[*]}
								  \nDesea completar la instalación? (si – no): "
			
			RESPUESTA=$(ValidarRespuestaSiNo "$MENSAJE_ESTADO_INST")
			if [ $RESPUESTA = "no" ]
			then
				let "INST_POINT = 21"
			else
				let "INST_POINT = 3"
			fi
		fi
		bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_ESTADO_INST`" "INFO"														
		;;
		
	3)  #Punto 3: Completar la instalación
		
		for file in ${ArchivosMAEFaltantes[*]}
		do
			#MoverA
			mv "Archivos/$file" "$maedir"
		done
		ArchivosMAEExistentes=( "${ArchivosMAEExistentes[@]}" "${ArchivosMAEFaltantes[@]}" )
		
		for file in ${ArchivosBINFaltantes[*]}
		do
			#MoverA
			mv "Archivos/$file" "$bindir"
		done
		ArchivosBINExistentes=( "${ArchivosBINExistentes[@]}" "${ArchivosBINFaltantes[@]}" )
		
		MENSAJE_ESTADO_INST="\nDirectorio de Configuración: $confdir. Archivos: $(ls -f $confdir/*)
							 \nDirectorio de Ejecutables: $bindir. Archivos: ${ArchivosBINExistentes[*]}
							 \nDirectorio de Maestros y Tablas: $maedir. Archivos: ${ArchivosMAEExistentes[*]}
							 \nDirectorio de recepción de archivos de llamadas: $novedir
							 \nDirectorio de Archivos de llamadas Aceptados: $acepdir
							 \nDirectorio de Archivos de llamadas Sospechosas: $procdir
							 \nDirectorio de Archivos de Reportes de llamadas: $repodir
							 \nDirectorio de Archivos de Log: $logdir. Archivos: $(ls -f $logdir/)
							 \nDirectorio de Archivos Rechazados: $rechdir
							 \nEstado de la instalación: COMPLETA\
							 nProceso de Instalación Finalizado"
							 
		bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_ESTADO_INST`" "INFO"
		let "INST_POINT = 21"
		;;

	4)	#Punto 4: Verificar si está instalado PERL										
																			 
		PERL_INST=$(dpkg -s perl | grep -c "Status: install ok installed") 	
		PERL_ERR="0"
		if [ $PERL_INST -eq 1 ]
		then
			PERL_VERSION=$( dpkg -s perl | grep "Version:" | sed 's-^[^:]*: \([0-9]\)\..*$-\1-' )
			if [ $PERL_VERSION -ge 5 ]
			then
				MENSAJE_PERL="\nPerl Version: $(perl -v)" 
				TIPO_LOG="INFO"
				let "INST_POINT = 5"
			else
				let "PERL_ERR = 1"
			fi
		else
			let "PERL_ERR = 1"
		fi
		
		if [ $PERL_ERR -eq 1 ]
		then
			MENSAJE_PERL="$MENSAJE_PERL_ERROR"
			TIPO_LOG="ERR"
			let "INST_POINT = 21"
		fi 
		echo -e $MENSAJE_PERL
		bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_PERL`" "$TIPO_LOG"
		;;
	
	5)  #Punto 5: Aceptación de términos y condiciones

		RESPUESTA=$(ValidarRespuestaSiNo "$MENSAJE_TERMS_Y_COND")
		
		if [ "$RESPUESTA" = "si" ] 
		then 
			let "INST_POINT = 6"
		else
			let "INST_POINT = 21"
		fi 
		;;
	
	6)  #Punto 6: Definir el directorio de los ejecutables
		ARRAY_DIR=("$GRUPO" "$CONFDIR") #Directorio de validacion de nombres de archivos
		
		MENSAJE_DIR_INSTALACION="\nDefina el directorio de instalación de los ejecutables ($BINDIR):"
		BINDIR=$(DefinirDirecorio "$MENSAJE_DIR_INSTALACION" "INFO")
		ARRAY_DIR=("${ARRAY_DIR[@]}" "$BINDIR")
		
	    #Punto 7: Definir el directorio de instalación de los archivos maestros y tablas
		MENSAJE_DIR_MAESTROS_TABLAS="\nDefina directorio para maestros y tablas ($MAEDIR):"
		MAEDIR=$(DefinirDirecorio "$MENSAJE_DIR_MAESTROS_TABLAS" "INFO")
		ARRAY_DIR=("${ARRAY_DIR[@]}" "$MAEDIR")

	    #Punto 8: Definir el directorio de input del proceso AFREC
		MENSAJE_DIR_INPUT_AFREC="\nDefina el Directorio de recepción de archivos de llamadas ($NOVEDIR):"
		NOVEDIR=$(DefinirDirecorio "$MENSAJE_DIR_INPUT_AFREC"  "INFO")
		ARRAY_DIR=("${ARRAY_DIR[@]}" "$NOVEDIR")

	    #Punto 9: Definir el espacio mínimo libre para el arribo de novedades
		MENSAJE_ESPACIO_MINIMO_NOV="\nDefina espacio mínimo libre para la recepción de archivos de llamadas en Mbytes ($DATASIZE): "
		echo -n -e "$MENSAJE_ESPACIO_MINIMO_NOV"
		
		ESPACIO_LIBRE=$(pwd | df | sed -n '2p' | sed 's-^.* .* .* \([0-9]*\) .* .* .*$-\1-' )
		let "ESPACIO_LIBRE = ESPACIO_LIBRE/1024"
		DATASIZE=$(ValidarNumero)
		
		#Punto 10: Verificar espacio en disco
		while [ $ESPACIO_LIBRE -lt $DATASIZE ]
		do
			MENSAJE_ESPACIO_INSUF="\nInsuficiente espacio en disco.
								   \nEspacio disponible: $ESPACIO_LIBRE Mb.
								   \nEspacio requerido $DATASIZE Mb
								   \nInténtelo nuevamente. "
			DATASIZE="100"
			echo -n -e $MENSAJE_ESPACIO_INSUF
			echo -n -e $MENSAJE_ESPACIO_MINIMO_NOV
			bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_ESPACIO_INSUF`" "ERR"
			DATASIZE=$(ValidarNumero)
		done
		MENSAJE_ESPACIO_MINIMO_NOV="$MENSAJE_ESPACIO_MINIMO_NOV $DATASIZE"
		bash GraLog.sh "AFINSTAL" "`echo -e $MENSAJE_ESPACIO_MINIMO_NOV`" "INFO"
		
	    #Punto 11: Definir el directorio de input del proceso AFUMB
		MENSAJE_NOV_ACEPTADAS="\nDefina el directorio de grabación de los archivos de llamadas aceptadas ($ACEPDIR):"
		ACEPDIR=$(DefinirDirecorio "$MENSAJE_NOV_ACEPTADAS" "INFO")
		ARRAY_DIR=("${ARRAY_DIR[@]}" "$ACEPDIR")
		
	    #Punto 12: Definir el directorio de output del proceso AFUMB
		MENSAJE_REG_LLAM_SOSPECHOSAS="\nDefina el directorio de grabación de los registros de llamadas sospechosas ($PROCDIR):"
		PROCDIR=$(DefinirDirecorio "$MENSAJE_REG_LLAM_SOSPECHOSAS" "INFO")
		ARRAY_DIR=("${ARRAY_DIR[@]}" "$PROCDIR")

	    #Punto 13: Definir el directorio de trabajo principal del proceso AFLIST
		MENSAJE_DIR_REPORTES="\nDefina el directorio de grabación de los reportes ($REPODIR):"
		REPODIR=$(DefinirDirecorio "$MENSAJE_DIR_REPORTES" "INFO")
		ARRAY_DIR=("${ARRAY_DIR[@]}" "$REPODIR")
		
	    #Punto 14: Definir el nombre del directorio para depositar los archivos de log de los comandos
		MENSAJE_DIR_ARCH_DE_LOG="\nDefina el directorio para los archivos de log ($LOGDIR):"
		LOGDIR=$(DefinirDirecorio "$MENSAJE_DIR_ARCH_DE_LOG" "INFO")
		ARRAY_DIR=("${ARRAY_DIR[@]}" "$LOGDIR")

		#Punto 15: Definir la extensión para los archivos de log
		MENSAJE_EXTENSION_LOG="\nDefina el nombre para la extensión de los archivos de log ($LOGEXT): "
		echo -n -e "$MENSAJE_EXTENSION_LOG"
		read LOGEXT
		TAM_EXTENCION=$(echo "$LOGEXT" | wc -c )
		while [ $TAM_EXTENCION -gt 5 ]
		do 
			echo -e -n "\nLa extension debe ser de 5 caracteres como máximo.
						\nIntentelo nuevamente: "
			read LOGEXT
			TAM_EXTENCION=$(echo "$LOGEXT" | wc -c )
		done
		MENSAJE_EXTENSION_LOG="$MENSAJE_EXTENSION_LOG $LOGEXT"
		bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_EXTENSION_LOG`" "INFO"
		
	    #Punto 16: Definir el tamaño máximo para los archivos de log
		MENSAJE_TAM_MAXIMO_LOG="\nDefina el tamaño máximo para cada archivo de log en Kbytes ($LOGSIZE): "
		echo -n -e "$MENSAJE_TAM_MAXIMO_LOG"
		LOGSIZE=$(ValidarNumero)
		MENSAJE_TAM_MAXIMO_LOG="$MENSAJE_TAM_MAXIMO_LOG $LOGSIZE"
		bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_TAM_MAXIMO_LOG`" "INFO"

	    #Punto 17: Definir repositorio de archivos rechazados
		MENSAJE_DIR_ARCH_RECHAZADOS="\nDefina el directorio de grabación de Archivos rechazados ($RECHDIR):"
		RECHDIR=$(DefinirDirecorio "$MENSAJE_DIR_ARCH_RECHAZADOS" "INFO")
		ARRAY_DIR=("${ARRAY_DIR[@]}" "$DIR")
		
		#Punto 18: Mostrar Parámetros configurados y definir si volver o no atrás
		MENSAJE_PARAM_CONFIGURADOS="\nDirectorio de Ejecutables: $BINDIR
									\nDirectorio de Maestros y Tablas: $MAEDIR
									\nDirectorio de recepción de archivos de llamadas: $NOVEDIR
									\nEspacio mínimo libre para arribos: $DATASIZE Mb
									\nDirectorio de Archivos de llamadas Aceptados: $ACEPDIR
									\nDirectorio de Archivos de llamadas Sospechosas: $PROCDIR
									\nDirectorio de Archivos de Reportes de llamadas: $REPODIR
									\nDirectorio de Archivos de Log: $LOGDIR
									\nExtensión para los archivos de log: $LOGEXT
									\nTamaño máximo para los archivos de log: $LOGSIZE Kb
									\nDirectorio de Archivos Rechazados: $RECHDIR
									\nEstado de la instalación: LISTA
									\nDesea continuar con la instalación? (si - no) "
									
		RESPUESTA=$(ValidarRespuestaSiNo "$MENSAJE_PARAM_CONFIGURADOS")

		if [ $RESPUESTA == "si" ]
		then
			let "INST_POINT = 19"
		else
			let "INST_POINT = 6"
		fi
		;;
	
	19) #Punto 19: Confirmar inicio de instalación
		RESPUESTA=$(ValidarRespuestaSiNo "$MENSAJE_CONFIRMAR_INST")

		if [ $RESPUESTA == "si" ]
		then
			let "INST_POINT = 20"
		else
			let "INST_POINT = 21"
		fi 
		;;
	
	20) #Punto 20: Instalación
		echo -e "$MENSAJE_CREANDO_ESTRUCTURAS"
		
		bash Archivos/CrearDir.sh "$BINDIR"
		bash Archivos/CrearDir.sh "$MAEDIR"
		bash Archivos/CrearDir.sh "$NOVEDIR"
		bash Archivos/CrearDir.sh "$ACEPDIR"
		bash Archivos/CrearDir.sh "$PROCDIR"
		bash Archivos/CrearDir.sh "$PROCDIR/proc"
		bash Archivos/CrearDir.sh "$REPODIR"
		bash Archivos/CrearDir.sh "$LOGDIR"
		bash Archivos/CrearDir.sh "$RECHDIR"
		bash Archivos/CrearDir.sh "$RECHDIR/llamadas"
	
		echo "$MENSAJE_INST_PROGRAMAS"
		
		for file in ${ArchivosBIN[*]}
		do
			#MoverA
			mv "Archivos/$file" "$BINDIR"
		done
		
		echo "$MENSAJE_INST_MAESTROS_TABLAS"	
		
		for file in ${ArchivosMAE[*]}
		do
			#MoverA
			mv "Archivos/$file" "$MAEDIR"
		done
		
		echo "$MENSAJE_ACTUALIZANDO_CONFIGURACION"
		
		DATE=`date +"%y-%m-%d %H:%M"`
		
		echo "GRUPO=$GRUPO=$USER=$DATE" >> "$CONFDIR/AFINSTAL.cnfg" 
		echo "CONFDIR=$CONFDIR=$USER=$DATE" >> "$CONFDIR/AFINSTAL.cnfg" 
		echo "BINDIR=$BINDIR=$USER=$DATE" >> "$CONFDIR/AFINSTAL.cnfg" 
		echo "MAEDIR=$MAEDIR=$USER=$DATE" >> "$CONFDIR/AFINSTAL.cnfg" 
		echo "NOVEDIR=$NOVEDIR=$USER=$DATE" >> "$CONFDIR/AFINSTAL.cnfg" 
		echo "DATASIZE=$DATASIZE=$USER=$DATE" >> "$CONFDIR/AFINSTAL.cnfg" 
		echo "ACEPDIR=$ACEPDIR=$USER=$DATE" >> "$CONFDIR/AFINSTAL.cnfg" 
		echo "PROCDIR=$PROCDIR=$USER=$DATE" >> "$CONFDIR/AFINSTAL.cnfg" 
		echo "REPODIR=$REPODIR=$USER=$DATE" >> "$CONFDIR/AFINSTAL.cnfg" 
		echo "LOGDIR=$LOGDIR=$USER=$DATE" >> "$CONFDIR/AFINSTAL.cnfg" 
		echo "LOGEXT=$LOGEXT=$USER=$DATE" >> "$CONFDIR/AFINSTAL.cnfg" 
		echo "LOGSIZE=$LOGSIZE=$USER=$DATE" >> "$CONFDIR/AFINSTAL.cnfg" 
		echo "RECHDIR=$RECHDIR=$USER=$DATE" >> "$CONFDIR/AFINSTAL.cnfg" 
		
		echo -e "$MENSAJE_INTALACION_TERMINADA\n"
		
		let "INST_POINT = 21"
		;;
esac
done