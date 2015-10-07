#!/bin/bash

# Constantes para los errores:
ERR_AMBIENTE_INICIADO=1
ERR_INSTALACION_INCOMPLETA=2
ERR_ARCHIVOS_FALTANTES=3
ERR_PERMISOS_DENEGADOS=4

# Seteo algunas variables predeterminadas
GRUPO="Grupo2"
CONFDIR="$GRUPO/conf"
AFINSTALCONF="$CONFDIR/AFINSTAL.cnfg"
GRALOG="Archivos/GraLog.sh"


# FUNCIONES:

function obtenerVariable {
    echo $(grep $1 "$CONFDIR/AFINSTAL.cnfg"   | sed 's-^[^=]*=\([^=]*\)=[^=]*=[^=]*$-\1-' )
}

function checkEnvSet() {
    # TODO: REFACTOR
    if ! [ -z $GRUPO -a -z $CONFDIR ] && ! [ -z $BINDIR -a -z $MAEDIR ] && ! [ -z $NOVEDIR -a -z $ACEPDIR ] && ! [ -z $PROCDIR -a -z $REPODIR ] && ! [ -z $LOGDIR -a -z $RECHDIR ]
    then
        echo "Ambiente ya inicializado. Para reiniciar termine la sesión e ingrese nuevamente."
        $GRALOG "AFINI" "Ambiente ya inicializado" "ERR"
        exit $ERR_AMBIENTE_INICIADO
    fi   
}

function checkInstalation() {
    # Hago la misma verificacion que AFINSTAL
    if [ ! -f "$GRUPO/AFINSTAL.cnfg" ]
    then
        echo "No se completo la instalacion. Por favor, ejecute AFINSTAL"
        $GRALOG "AFINI" "Instalacion no completada" "ERR"
        exit $ERR_INSTALACION_INCOMPLETA
    fi
}

function checkFilesExist() {
    # Chequeo que existan los archivos necesarios
    if [ ! [ -f "$CDP" -a -f "$CDA" -a -f "$CDC" -a -f "$AGENTES" -a -f "$TLLAMA" -a -f "$UMBRAL" ] ]
    then
        echo "Archivos faltantes. Por favor, ejecute AFINSTAL para continuar con la iniciacion"
        $GRALOG "AFINI" "Archivos de instalacion faltantes" "ERR"
        exit $ERR_ARCHIVOS_FALTANTES
    fi
}

function setRWPermissions {
    # Permisos para lectura:
    if [ ! -r $1 ]
    then
        chmod +r $1
        if [ $? -ne 0 ]
        then
            echo "No se pudieron modificar los permisos de lectura para $1"
            $GRALOG "AFINI" "$1 no tiene permisos de lectura" "ERR"
            exit $ERR_PERMISOS_DENEGADOS
        fi
    fi

    # Permisos para escritura:
    if [ ! +w $1 ]
    then
        chmod -w $1
        if [ $? -ne 0 ]
        then
            echo "No se pudieron modificar los permisos de escritura para $1"
            $GRALOG "AFINI" "$1 no tiene permisos de escritura" "ERR"
            exit $ERR_PERMISOS_DENEGADOS
        fi
    fi 
}

function setExePermissions {
    # Permisos para ejecucion:
    if [ ! -x $1 ]
    then
        chmod x $1
        if [ $? -ne 0 ]
        then
            echo "No se pudieron modificar los permisos de ejecucion para $1"
            $GRALOG "AFINI" "$1 no tiene permisos de ejecucion"  "ERR"
            exit $ERR_PERMISOS_DENEGADOS
        fi
    fi
}

# EJECUCION:

# (1) Verificar si el ambiente ya ha sido inicializado
checkEnvSet

# (2) Verificar que la instalacion está completa
checkInstalation

# Seteo el path de MAEDIR y sus archivos para checkear que existan
MAEDIR=$(obtenerVariable "MAEDIR")
CPD="$MAEDIR/CdP.mae"
CPA="$MAEDIR/CdA.mae"
CDC="$MAEDIR/CdC.mae"
AGENTES="$MAEDIR/agentes.mae"
TLLAMA="$MAEDIR/tllama.mae"
UMBRAL="$MAEDIR/umbral.mae"
checkFilesExist

# (3) Verificar y seteo los permisos de lectura y escritura
for file in `ls $MAEDIR`; do
    setRWPermissions $file
done

for script in `ls $BINDIR`; do
    setExePermissions $script
done

# (4) Inicializar el ambiente
# Inicializo variables globales de Grupo2/conf/AFINSTAL.cnfg
export GRUPO
export CONFDIR
export BINDIR=`obtenerVariable "BINDIR"`
export MAEDIR
export NOVEDIR=`obtenerVariable "NOVEDIR"`
export ACEPDIR=`obtenerVariable "ACEPDIR"`
export PROCDIR=`obtenerVariable "PROCDIR"`
export REPODIR=`obtenerVariable "REPODIR"`
export LOGDIR=`obtenerVariable "LOGDIR"`
export RECHDIR=`obtenerVariable "RECHDIR"`

# (5) Grabar en el log variables y contenido
$GRALOG "AFINI" "Directorio de Configuración: $CONFDIR" "INFO"
$GRALOG "AFINI" "Archivos en $CONFDIR: `ls -p $CONFDIR | grep -v /`" "INFO"
$GRALOG "AFINI" "Directorio de Ejecutables: $BINDIR" "INFO"
$GRALOG "AFINI" "Archivos en $BINDIR: `ls -p $BINDIR | grep -v /`" "INFO"
$GRALOG "AFINI" "Directorio de Maestros y Tablas: $MAEDIR" "INFO"
$GRALOG "AFINI" "Archivos en $MAEDIR: `ls -p $MAEDIR | grep -v /`" "INFO"
$GRALOG "AFINI" "Directorio de recepción de archivos de llamadas: $NOVEDIR" "INFO"
$GRALOG "AFINI" "Directorio de Archivos de llamadas Aceptados: $ACEPDIR" "INFO"
$GRALOG "AFINI" "Directorio de Archivos de llamadas Sospechosas: $PROCDIR" "INFO"
$GRALOG "AFINI" "Directorio de Archivos de Reportes de llamadas: $REPODIR" "INFO"
$GRALOG "AFINI" "Directorio de Archivos de Log: $LOGDIR" "INFO"
$GRALOG "AFINI" "Archivos en $LOGDIR: `ls -p $LOGDIR | grep -v /`" "INFO"
$GRALOG "AFINI" "Directorio de Archivos Rechazados: $RECHDIR" "INFO"
$GRALOG "AFINI" "Estado del Sistema: INICIALIZADO" "INFO"

# (6) Ver si desea arrancar AFREC
read -p "Desea correr AFREC? (s/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]
then
    if [[ $(ps -aux | grep -e "[0-9] [a-z]* AFREC") -ne "" ]]
    then
        bash $BINDIR/Arrancar.sh ./AFREC.sh &
        PID_AFREC=$!
        echo "Para detenerlo ejecute el archivo Detener.sh"
    else
        echo "AFREC ya esta corriendo"
        PID_AFREC=$( ps -x | grep -e "[0-9] [a-z]* AFREC" | sed 's:^ \([0-9]*\).*:\1:' )
    fi
    $GRALOG "AFINI" "AFREC corriendo bajo el no.: $PID_AFREC" "INFO"
else
    echo "Puede comenzar el demonio AFREC ejecutando \"Arrancar.sh AFREC.sh\""
fi


exit 0