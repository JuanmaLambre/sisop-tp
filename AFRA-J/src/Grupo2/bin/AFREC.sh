#!/bin/bash

# AFREC.sh
# mastanca

# FALTA CAMBIAR EL mv POR EL MoverA
# FALTA CAMBIAR LOS echo POR EL GraLog

RECHAZADOS=$(pwd)/rech
ACEPTADOS=$(pwd)/acep
NOVEDADES=$(pwd)/noved

# Devuelve en la variable cantidad_archivos
# la cantidad en el directorio
function hay_archivos() {
  cantidad_archivos=$(ls -1 $1 | wc -l)
}


# Valida que sean archivos de texto , los que hay en el directorio $NOVEDADES
# Los que no los mueve a $RECHAZADOS
function validar_tipo_archivos (){
	for archivo in $(ls -1 "$NOVEDADES");do
		if [ $(file "$NOVEDADES/$archivo" | grep -c "text") = 0 ];then
      mv "$NOVEDADES/$archivo" $RECHAZADOS
			#Escribir log
			echo "$archivo no es de texto"
		fi
	done
}

#Guarda los codigos de centrales en el array COD_CENTRALES
function obtener_codigos_centrales() {
 COD_CENTRALES=($(cat centrales.csv | cut -d \; -f 1))
 # for codigo in $codigos;do
 #    COD_CENTRALES[$codigo]=1
 # done
}

# Chequea que el codigo de central este en el archivo de centrales
function validar_codigo_central() {
  case "${COD_CENTRALES[@]}" in
      *"$codigo_a_validar"*)
        #Si el codigo es invalido sigo
        echo "Codigo Valido!"
      ;;
      *)
        # Si el codigo es invalido lo muevo a rechazados
        mv "$NOVEDADES/$file" "$RECHAZADOS"
        $resultado=1
      ;;
  esac
}

# Chequea que la fecha sea valida
# No chequea bisiestos ni esas cosas
function validar_fecha() {
  #Valido fecha del archivo
  fecha_a_validar=$(echo $file | sed 's/^.*_//' | sed 's/\.[^.]*$//')
  anio_a_validar=$(echo ${fecha_a_validar} | cut -c1-4)
  mes_a_validar=$(echo ${fecha_a_validar} | cut -c5-6)
  dia_a_validar=$(echo ${fecha_a_validar} | cut -c7-8)

  if [ $anio_a_validar -lt "1900" -o $anio_a_validar -gt `date +'%Y'` ]; then
    echo "Anio invalido"
    mv "$NOVEDADES/$file" "$RECHAZADOS"
    let "resultado = 1"
  else
    echo "Anio valido"
  fi

  if [ $mes_a_validar -lt "01" -o $mes_a_validar -gt "12" ]; then
    echo "Mes invalido"
    mv "$NOVEDADES/$file" "$RECHAZADOS"
    let "resultado = 1"
  else
    echo "Mes valido"
  fi

  if [ $dia_a_validar -lt "01" -o $dia_a_validar -gt "31" ]; then
    echo "Dia invalido"
    mv "$NOVEDADES/$file" "$RECHAZADOS"
    let "resultado = 1"
  else
    echo "Dia valido"
  fi
}

# Chequea que no sea de hace mas de un anio
# SOLO ESTA CHEQUEANDO ANIO
function validar_antiguedad() {
  anio_actual=$(date +'%Y')
  let "antiguedad = anio_actual - anio_a_validar"
  if [ $antiguedad -lt "0" ]; then
    echo "Archivo viejo"
    let "resultado = 1"
    mv "$NOVEDADES/$file" "$RECHAZADOS"
  else
    echo "antiguedad ok"
  fi
}

# Valida que la fecha sea menor o igual a la de hoy
function validar_menor_o_igual_a_hoy() {
  anio_actual=$(date +'%Y')
  mes_actual=$(date +'%m')
  dia_actual=$(date +'%d')

  if [ $anio_a_validar -le $anio_actual ]; then
    echo "Anio ok"
  else
    if [ $mes_a_validar -le $mes_actual ]; then
      echo "Mes ok"
    else
      if [ $dia_a_validar -le $dia_actual ]; then
        echo "Dia ok"
      else
        let "resultado = 1"
        mv "$NOVEDADES/$file" "$RECHAZADOS"
      fi
    fi
  fi

}


# DEBERIA SER CORRIDO EN BACKGROUND YA QUE ES UN DAEMON
TIEMPO_SLEEP_SEGUNDOS="1"
# Mensajes
MENSAJE_NUMERO_CICLO="AFREC ciclo nro. $NUMERO_CICLO"
MENSAJE_ARCHIVO_ACEPTADO="Archivo $NOMBRE_ARCHIVO aceptado, movido a $PATH_ACEPTADO"
MENSAJE_TIPO_INVALIDO="Tipo de archivo invalido"
MENSAJE_FECHA_INVALIDA="Fecha invalida"
MENSAJE_FECHA_FUERA_DE_RANGO="Fecha fuera de rango"
MENSAJE_CENTRAL_INEXISTENTE="Central inexistente"
MENSAJE_ERROR_DESCONOCIDO="Error desconocido"
MENSAJE_AFUMB_INICIADO="AFUMB corriendo bajo el no.: $PID"
MENSAJE_AFUMB_OCUPADO="Invocacion de AFUMB pospuesta para el siguiente ciclo"

# BEGIN
let "NUMERO_CICLO = 0"
#while true; do
  #archivo_centrales="$1"
  #directorio_novedades="$2"
  MENSAJE_NUMERO_CICLO="AFREC ciclo nro. $NUMERO_CICLO"
  echo $MENSAJE_NUMERO_CICLO
  #./GraLog.sh $MENSAJE_NUMERO_CICLO
  let "NUMERO_CICLO = NUMERO_CICLO + 1"

  hay_archivos $NOVEDADES
  if [ $cantidad_archivos -gt 0 ];then
    validar_tipo_archivos
    obtener_codigos_centrales
    listaArchivos=$(ls $NOVEDADES)

    for file in $listaArchivos ;do

      # Si resultado llega a ser distinto de 0 es porque alguna validacion fallo
      let "resultado = 0"

      if [ $resultado -eq "0" ]; then
      # Valido codigo centrales
      codigo_a_validar=$(echo $file | sed 's/_.*//' )
      validar_codigo_central "$codigo_a_validar"
      fi

      if [ $resultado -eq "0" ]; then
      # Valido formato fecha
      validar_fecha
      fi

      if [ $resultado -eq "0" ]; then
      # Valido antiguedad
      validar_antiguedad
      fi

      if [ $resultado -eq "0" ]; then
      # Valido que sea menor o igual a la fecha del dia
      validar_menor_o_igual_a_hoy
      fi

      #### SI LLEGO HASTA ACA MOVER A ACEPTADOS
      mv "$NOVEDADES/$file" "$ACEPTADOS"
    done

  fi

  if [ $cantidad_archivos -eq 0 ];then
    for file in $(ls -1 "$ACEPTADOS");do
      echo $(ls -1 "$ACEPTADOS")
      cantidad=`hay_archivos $ACEPTADOS`
      if [ $cantidad -gt 0 ];then
        ProcesosCorriendo=$(ps ax | grep -v $$ | grep -v "grep" | grep -v "gedit" | grep "AFUMB.sh")
        PID=$(echo "$ProcesosCorriendo" | sed 's-\(^ *\)\([0-9]*\)\(.*$\)-\2-g')
        if [ "$PID" = "" ]; then
          #Arrancar.sh AFUMB.sh
          echo "ARRANCA AFUMB!"
          ProcesosCorriendo=$(ps ax | grep -v $$ | grep -v "grep" | grep -v "gedit" | grep "AFUMB.sh")
          PID=$(echo "$ProcesosCorriendo" | sed 's-\(^ *\)\([0-9]*\)\(.*$\)-\2-g')
        else
          #GraLog.sh "AFREC" "$MENSAJE_AFUMB_OCUPADO" INFO
          echo "AFUMB OCUPADO"
        fi
        #Glog.sh "AFREC" "$MENSAJE_AFUMB_INICIADO" INFO
        echo "ARRANCA AFUMB"
        break
      fi
    done
  fi


sleep "$TIEMPO_SLEEP_SEGUNDOS"


#done
# Recibe 2 argumentos, MAEDIR/CdC.mae y el directorio NOVEDIR

# Grabar con el GraLog el numero de ciclo

# Recorre la carpeta NOVEDIR en busca de archivos

# Si hay archivos agarrar uno y chequear que sea .txt

# Chequear si tiene el nombre valido <cod_central>_<aniomesdia> sino lo mando a RECHDIR

# El nombre para ser valido debe:

#       COD_CENTRAL estar dentro de CdC.mae

#       ANIOMESDIA debe ser una fecha valida

#       ANIOMESDIA debe ser a lo sumo de un anio de antiguedad

#       ANIOMESDIA debe ser menor o igual a la fecha del dia

# Si el archivo es valido:

#       Mover con el MoverA a ACEPDIR

#       Grabar en el log el mensaje de archivo aceptado con el nombre y el path

# Si el archivo no es valido, esta vacio o no es un .txt rechazarlo:

#       Moverlo a RECHDIR

#       Grabar en el log el nombre y el motivo (tipo invalido, fecha invalida,

#                                               fecha outofrange, central no existe, otros)

# Cuando no hay mas archivos en NOVEDIR, ver si hay en ACEPDIR y llamar a AFUMB si no esta corriendo

# Si se pudo invocar a AFUMB grabar en el log (ver mensaje en pdf)

# Si AFUMB esta ocupado continuar y grabar en el log que se pospuso

# Si se da algun error loguearlo

# Dormir x cantidad de tiempo y volver a empezar
