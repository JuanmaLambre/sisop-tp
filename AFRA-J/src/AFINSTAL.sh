#!/bin/bash

################ Variables y directorios predeterminados ################

GRUPO="Grupo2"
ARCHDIR="Archivos"
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
GRALOG="$ARCHDIR/GraLog.sh"
MOVERA="$ARCHDIR/MoverA.sh"
export CONFDIR="$GRUPO/conf"
ARRAY_DIR=( )


################ Archivos de tablas, maestros y scripts ################

ArchivosBIN=( "AFINI" "AFREC" "AFUMB" "AFLIST.pl" "GraLog.sh" "Detener.sh" "Arrancar.sh" "CrearDir.sh" "MoverA.sh")
ArchivosMAE=( "agentes.csv" "CdA.csv" "CdP.csv" "centrales.csv" "umbrales.csv" )


################ Mensajes predeterminados ################

MENSAJE_PERL_ERROR="\nPara ejecutar el sistema AFRA-J es necesario contar con Perl 5 o superior.
					\nEfectúe su instalación e inténtelo nuevamente.
					\nProceso de Instalación Cancelado"
MENSAJE_TERMS_Y_COND="\n***************************************************
					  \n*\t  Proceso de Instalación de \"AFRA-J\"   \t*
					  \n*\tTema J Copyright © Grupo 2 - Segundo Cuatrimestre 2015*
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
MENSAJE_DIR_ERROR="El directorio ya fue utilizado o ingresó un nombre incorrecto. Defina otro"
MENSAJE_ARCH_FALTANTES="Faltan archivos para continuar la instalación"
MENSAJE_NUM_INCORRECTO="Ingrese un numero correcto"
MENSAJE_SINO_INVALIDA="Ingrese una opcion valida (si - no):"
MENSAJE_GRALOG_INEXIST="El programa GraLog.sh no existe. Sin el no se puede continuar la instalación. Porfavor devolverlo al directorio perteneciente o al directorio Archivos"
MENSAJE_MOVERA_INEXIST="El programa MoverA.sh no existe. Sin el no se puede continuar la instalación. Porfavor devolverlo al directorio perteneciente o al directorio Archivos"


############### Funciones auxiliares ###############

# Imprime un mensaje por Stdin sin el salto de línea
function ImprimirMensaje {
	MENSAJE="$1"
	echo -e -n $MENSAJE" " >&0
}

# Valida que un directorio no haya sido utilizado anteriormente
function ValidarDirectorio {
	DIR_PREDET=$1
	shift
	DIRECTORIOS=("${@}")

	resultado='1'
	while [ "$resultado" != "0" ]
	do
		resultado='0'
		read DIR
		if [ "$DIR" = "" ]
		then
			DIR=$DIR_PREDET
		else
			for dir in ${DIRECTORIOS[*]}
			do
				if [ "$dir" = "$DIR" ]
				then
					ImprimirMensaje  "$MENSAJE_DIR_ERROR ($DIR_PREDET):"
					resultado='1'
				fi
			done
		fi
	done
	echo $DIR
}

# Lee un directorio, lo valida y graba la respuesta en un archivo de log
function DefinirDirectorio {
	MENSAJE=$1
	TIPO_LOG=$2
	DIR_PREDET=$3
	ImprimirMensaje "$MENSAJE ($DIR_PREDET):"

	DIR=$(ValidarDirectorio "$DIR_PREDET" "${ARRAY_DIR[@]}" )
	MENSAJE_LOG="$MENSAJE $DIR"
	bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_LOG`" "$TIPO_LOG"

	echo $DIR
}

# Lee una respuesta y valida que sea 'si' o 'no'
function ValidarRespuestaSiNo {
	MENSAJE=$1
	ImprimirMensaje "$MENSAJE"

	read RESPUESTA
	while [ "$RESPUESTA" = "" ] || [ $RESPUESTA != "si" -a $RESPUESTA != "no" ]
	do
		ImprimirMensaje "$MENSAJE_SINO_INVALIDA"
		read RESPUESTA
	done
	MENSAJE_LOG="$MENSAJE $RESPUESTA"
	bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_LOG`" "INFO"

	echo $RESPUESTA
}

# Valida que el argumento sea un número
function ValidarNumero {
	NUM_PREDET=$1
	es_num='1'
	num='^[0-9]+$'
	while [ $es_num != '0' ]
	do
		read POSIBLE_NUM
		if [ "$POSIBLE_NUM" = "" ]
		then
			es_num='0'
			POSIBLE_NUM=$NUM_PREDET
		else

			if [[ $POSIBLE_NUM =~ $num ]]
			then
				es_num='0'
			else
				ImprimirMensaje "$MENSAJE_NUM_INCORRECTO ($NUM_PREDET):"
			fi
		fi
	done
	echo $POSIBLE_NUM
}

# Valida que un directorio posea todos los archivos que debería tener.
# Todos estos pasados por parámetro
function DirectorioCompleto {
	DIRECTORIO=$1
	shift
	ARCHIVOS=("${@}")

	dir_completo="si"

	for file in ${ARCHIVOS[*]}
	do
		if ! [ -f "$DIRECTORIO/$file" ]
		then
			dir_completo="no"
		fi
	done

	echo $dir_completo
}


# Valida que la extensión pasada por parámetro sea correcta (menor que 5 letras)
# e guarda la respuesta en un archivo de log.
function ValidarExtension {
	MENSAJE=$1
	TIPO_LOG=$2
	EXT_PREDET=$3

	ImprimirMensaje "$MENSAJE ($EXT_PREDET):"
	extension_valida='1'
	while [ $extension_valida != '0' ]
	do
		extension_valida='0'
		read EXT
		if [ "$EXT" = "" ]
		then
			EXT=$EXT_PREDET
		else
			TAM_EXTENCION=$(echo "$LOGEXT" | wc -c )
			if [ $TAM_EXTENCION -gt 5 ]
			then
				ImprimirMensaje "\nLa extension debe ser de 5 caracteres como máximo.
								 \nIntentelo nuevamente ($EXT_PREDET): "
				extension_valida='1'
			fi
		fi

	done
	MENSAJE_EXTENSION="$MENSAJE $LOGEXT"
	bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_EXTENSION`" "$TIPO_LOG"

	echo $EXT
}


################ AFINSTAL ################

let "INST_POINT = 1"

while [ $INST_POINT -ne 21 ]
do

case $INST_POINT in

	1)  #Punto 1: Verificar si está instalado AFRA_J
		clear
		if [ -f "$CONFDIR/AFINSTAL.cnfg" ]
		then
			let "INST_POINT = 2"
		else
			let "INST_POINT = 22"
		fi ;;

	2)  #Punto 2: Verificar si la instalación está completa

		#Recuperamos los directorios | sed 's-^.*AFRA\-J/\(.*\)$-\1-'
		maedir=$(grep "MAEDIR" "$CONFDIR/AFINSTAL.cnfg"   | sed 's-^[^=]*=.*AFRA\-J/\(.*\)=[^=]*=[^=]*$-\1-' )
		bindir=$(grep "BINDIR" "$CONFDIR/AFINSTAL.cnfg"   | sed 's-^[^=]*=.*AFRA\-J/\(.*\)=[^=]*=[^=]*$-\1-' )
		novedir=$(grep "NOVEDIR" "$CONFDIR/AFINSTAL.cnfg" | sed 's-^[^=]*=.*AFRA\-J/\(.*\)=[^=]*=[^=]*$-\1-' )
		acepdir=$(grep "ACEPDIR" "$CONFDIR/AFINSTAL.cnfg" | sed 's-^[^=]*=.*AFRA\-J/\(.*\)=[^=]*=[^=]*$-\1-' )
		procdir=$(grep "PROCDIR" "$CONFDIR/AFINSTAL.cnfg" | sed 's-^[^=]*=.*AFRA\-J/\(.*\)=[^=]*=[^=]*$-\1-' )
		repodir=$(grep "REPODIR" "$CONFDIR/AFINSTAL.cnfg" | sed 's-^[^=]*=.*AFRA\-J/\(.*\)=[^=]*=[^=]*$-\1-' )
		logdir=$(grep "LOGDIR" "$CONFDIR/AFINSTAL.cnfg"   | sed 's-^[^=]*=.*AFRA\-J/\(.*\)=[^=]*=[^=]*$-\1-' )
		rechdir=$(grep "RECHDIR" "$CONFDIR/AFINSTAL.cnfg" | sed 's-^[^=]*=.*AFRA\-J/\(.*\)=[^=]*=[^=]*$-\1-' )
		confdir=$(grep "CONFDIR" "$CONFDIR/AFINSTAL.cnfg" | sed 's-^[^=]*=.*AFRA\-J/\(.*\)=[^=]*=[^=]*$-\1-' )
		archdir="$ARCHDIR"

		#Verifico donde se encuentra GraLog	y MoverA, si no estan no puedo continuar
		if [ -f "$bindir/GraLog.sh" ]
		then
			GRALOG=$bindir/GraLog.sh
		elif ! [ -f "$ARCHDIR/GraLog.sh" ]
		then
			echo "$MENSAJE_GRALOG_INEXIST"
			exit
		fi

		if [ -f "$bindir/MoverA.sh" ]
		then
			MOVERA=$bindir/MoverA.sh
		elif ! [ -f "$ARCHDIR/MoverA.sh" ]
		then
			echo "$MENSAJE_MOVERA_INEXIST"
			exit
		fi


		#Vectores de archivos tanto faltantes como existentes
		ArchivosBINFaltantes=( )
		ArchivosMAEFaltantes=( )

		#Obtengo los archivos que no están en los directorios correspondientes
		InstalacionCompleta='0'
		for file in ${ArchivosBIN[*]}
		do
			if ! [ -f "$bindir/$file" ]
			then
				ArchivosBINFaltantes=( "${ArchivosBINFaltantes[@]}" "$file" )
				InstalacionCompleta='1'
			fi
		done

		for file in ${ArchivosMAE[*]}
		do
			if ! [ -f "$maedir/$file" ]
			then
				ArchivosMAEFaltantes=( "${ArchivosMAEFaltantes[@]}" "$file" )
				InstalacionCompleta='1'
			fi
		done


		#Estado de instalacion
		MENSAJE_ESTADO_INST="\nDirectorio de Configuración: $confdir. Archivos: $(ls -t $confdir)
							 \nDirectorio de Ejecutables: $bindir. Archivos: $(ls -t $bindir)
							 \nDirectorio de Maestros y Tablas: $maedir. Archivos: $(ls -t $maedir)
							 \nDirectorio de recepción de archivos de llamadas: $novedir
							 \nDirectorio de Archivos de llamadas Aceptados: $acepdir
							 \nDirectorio de Archivos de llamadas Sospechosas: $procdir
							 \nDirectorio de Archivos de Reportes de llamadas: $repodir
							 \nDirectorio de Archivos de Log: $logdir. Archivos: $(ls -t $logdir)
							 \nDirectorio de Archivos Rechazados: $rechdir"

		#Validamos si la instalacion esta completa
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

		if [ -f $GRALOG ]
		then
			bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_ESTADO_INST`" "INFO"
		fi
		;;

	3)  #Punto 3: Completar la instalación

		#Verifico que los archivos faltantes existan
		RESPUESTA=$(DirectorioCompleto "$ARCHDIR" "${ArchivosBINFaltantes[@]}" "${ArchivosMAEFaltantes[@]}")
		if [ "$RESPUESTA" = "no" ]
		then
			echo -e $MENSAJE_ARCH_FALTANTES
			if [ -f "$GRALOG" ]
			then
				bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_ESTADO_INST`" "INFO"
			fi
			exit
		fi

		#Ubico los archivos donde deban ir
		for file in ${ArchivosMAEFaltantes[*]}
		do
			bash $MOVERA "$archdir/$file" "$maedir"
		done

		for file in ${ArchivosBINFaltantes[*]}
		do
			bash $MOVERA "$archdir/$file" "$bindir"
		done


		#Estado de instalacion
		MENSAJE_ESTADO_INST="\nDirectorio de Configuración: $confdir. Archivos: $(ls -t $confdir)
							 \nDirectorio de Ejecutables: $bindir. Archivos: $(ls -t $bindir)
							 \nDirectorio de Maestros y Tablas: $maedir. Archivos: $(ls -t $maedir)
							 \nDirectorio de recepción de archivos de llamadas: $novedir
							 \nDirectorio de Archivos de llamadas Aceptados: $acepdir
							 \nDirectorio de Archivos de llamadas Sospechosas: $procdir
							 \nDirectorio de Archivos de Reportes de llamadas: $repodir
							 \nDirectorio de Archivos de Log: $logdir. Archivos: $(ls -t $logdir)
							 \nDirectorio de Archivos Rechazados: $rechdir
							 \nEstado de la instalación: COMPLETA
							 \nProceso de Instalación Finalizado"

		bash $bindir/GraLog.sh "AFINSTAL" "`echo -e $MENSAJE_ESTADO_INST`" "INFO"
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

		MENSAJE_DIR_INSTALACION="\nDefina el directorio de instalación de los ejecutables"
		BINDIR=$(DefinirDirectorio "$MENSAJE_DIR_INSTALACION" "INFO" "$BINDIR")
		ARRAY_DIR=("${ARRAY_DIR[@]}" "$BINDIR")

	    #Punto 7: Definir el directorio de instalación de los archivos maestros y tablas
		MENSAJE_DIR_MAESTROS_TABLAS="\nDefina directorio para maestros y tablas"
		MAEDIR=$(DefinirDirectorio "$MENSAJE_DIR_MAESTROS_TABLAS" "INFO" "$MAEDIR")
		ARRAY_DIR=("${ARRAY_DIR[@]}" "$MAEDIR")

	    #Punto 8: Definir el directorio de input del proceso AFREC
		MENSAJE_DIR_INPUT_AFREC="\nDefina el Directorio de recepción de archivos de llamadas"
		NOVEDIR=$(DefinirDirectorio "$MENSAJE_DIR_INPUT_AFREC"  "INFO" "$NOVEDIR")
		ARRAY_DIR=("${ARRAY_DIR[@]}" "$NOVEDIR")

	    #Punto 9: Definir el espacio mínimo libre para el arribo de novedades
		MENSAJE_ESPACIO_MINIMO_NOV="\nDefina espacio mínimo libre para la recepción de archivos de llamadas en Mbytes ($DATASIZE): "
		echo -n -e "$MENSAJE_ESPACIO_MINIMO_NOV"
		ESPACIO_LIBRE=$(pwd | df -P . | tail -1 | awk '{print $4}' )
		let "ESPACIO_LIBRE = ESPACIO_LIBRE/1024"
		DATASIZE=$(ValidarNumero $DATASIZE)

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
			DATASIZE=$(ValidarNumero $DATASIZE)
		done
		MENSAJE_ESPACIO_MINIMO_NOV="$MENSAJE_ESPACIO_MINIMO_NOV $DATASIZE"
		bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_ESPACIO_MINIMO_NOV`" "INFO"

	    #Punto 11: Definir el directorio de input del proceso AFUMB
		MENSAJE_NOV_ACEPTADAS="\nDefina el directorio de grabación de los archivos de llamadas aceptadas"
		ACEPDIR=$(DefinirDirectorio "$MENSAJE_NOV_ACEPTADAS" "INFO" "$ACEPDIR")
		ARRAY_DIR=("${ARRAY_DIR[@]}" "$ACEPDIR")

	    #Punto 12: Definir el directorio de output del proceso AFUMB
		MENSAJE_REG_LLAM_SOSPECHOSAS="\nDefina el directorio de grabación de los registros de llamadas sospechosas"
		PROCDIR=$(DefinirDirectorio "$MENSAJE_REG_LLAM_SOSPECHOSAS" "INFO" "$PROCDIR")
		ARRAY_DIR=("${ARRAY_DIR[@]}" "$PROCDIR")

	    #Punto 13: Definir el directorio de trabajo principal del proceso AFLIST
		MENSAJE_DIR_REPORTES="\nDefina el directorio de grabación de los reportes"
		REPODIR=$(DefinirDirectorio "$MENSAJE_DIR_REPORTES" "INFO" "$REPODIR")
		ARRAY_DIR=("${ARRAY_DIR[@]}" "$REPODIR")

	    #Punto 14: Definir el nombre del directorio para depositar los archivos de log de los comandos
		MENSAJE_DIR_ARCH_DE_LOG="\nDefina el directorio para los archivos de log"
		LOGDIR=$(DefinirDirectorio "$MENSAJE_DIR_ARCH_DE_LOG" "INFO" "$LOGDIR")
		ARRAY_DIR=("${ARRAY_DIR[@]}" "$LOGDIR")

		#Punto 15: Definir la extensión para los archivos de log
		MENSAJE_EXTENSION_LOG="\nDefina el nombre para la extensión de los archivos de log"
		LOGEXT=$(ValidarExtension "$MENSAJE_EXTENSION_LOG" "INFO" "$LOGEXT")

	    #Punto 16: Definir el tamaño máximo para los archivos de log
		MENSAJE_TAM_MAXIMO_LOG="\nDefina el tamaño máximo para cada archivo de log en Kbytes ($LOGSIZE): "
		echo -n -e "$MENSAJE_TAM_MAXIMO_LOG"
		LOGSIZE=$(ValidarNumero "$LOGSIZE")
		MENSAJE_TAM_MAXIMO_LOG="$MENSAJE_TAM_MAXIMO_LOG $LOGSIZE"
		bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_TAM_MAXIMO_LOG`" "INFO"

	    #Punto 17: Definir repositorio de archivos rechazados
		MENSAJE_DIR_ARCH_RECHAZADOS="\nDefina el directorio de grabación de Archivos rechazados"
		RECHDIR=$(DefinirDirectorio "$MENSAJE_DIR_ARCH_RECHAZADOS" "INFO" "$RECHDIR")
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
			clear
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

		#Creo los directorios
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


		#Ubico los maestros y tablas
		echo "$MENSAJE_INST_MAESTROS_TABLAS"
		for file in ${ArchivosMAE[*]}
		do
			bash $MOVERA "$ARCHDIR/$file" "$MAEDIR"
		done

		#Ubico los scripts
		echo "$MENSAJE_INST_PROGRAMAS"
		for file in ${ArchivosBIN[*]}
		do
			bash $MOVERA "$ARCHDIR/$file" "$BINDIR"
		done


		#Guardo la configuracion actual
		echo "$MENSAJE_ACTUALIZANDO_CONFIGURACION"
		DATE=`date +"%y-%m-%d %H:%M"`

		#Calculo la ruta completa de cada directorio
		GRUPO=$(readlink   -f $GRUPO)
		CONFDIR=$(readlink -f $CONFDIR)
		BINDIR=$(readlink  -f $BINDIR)
		MAEDIR=$(readlink  -f $MAEDIR)
		NOVEDIR=$(readlink -f $NOVEDIR)
		ACEPDIR=$(readlink -f $ACEPDIR)
		PROCDIR=$(readlink -f $PROCDIR)
		REPODIR=$(readlink -f $REPODIR)
		LOGDIR=$(readlink  -f $LOGDIR)
		RECHDIR=$(readlink -f $RECHDIR)


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

	22) #Punto 22 (extra): Verificar si se posee todos los archivos para continuar la instalacion
		RESPUESTA=$(DirectorioCompleto "$ARCHDIR" "${ArchivosBIN[@]}" "${ArchivosMAE[@]}")
		if [ "$RESPUESTA" = "si" ]
		then
			let "INST_POINT = 4"
		else
			echo -e $MENSAJE_ARCH_FALTANTES
			if [ -f "$GRALOG" ]
			then
				bash $GRALOG "AFINSTAL" "`echo -e $MENSAJE_ARCH_FALTANTES`" "ERR"
			fi
			let "INST_POINT = 21"
		fi
		;;
esac
done
