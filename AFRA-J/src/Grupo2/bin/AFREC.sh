#!/bin/bash

# AFREC.sh
# mastanca

# FALTA CAMBIAR EL mv POR EL MoverA
# FALTA CAMBIAR LOS echo POR EL GraLog

RECHAZADOS=$RECHDIR
ACEPTADOS=$ACEPDIR
NOVEDADES=$NOVEDIR

# DEBERIA SER CORRIDO EN BACKGROUND YA QUE ES UN DAEMON
TIEMPO_SLEEP_SEGUNDOS="1"
# Mensajes
MENSAJE_ARCHIVO_ACEPTADO="Archivo $NOMBRE_ARCHIVO aceptado, movido a $PATH_ACEPTADO"
MENSAJE_TIPO_INVALIDO="Tipo de archivo invalido"
MENSAJE_FECHA_INVALIDA="Fecha invalida"
MENSAJE_FECHA_FUERA_DE_RANGO="Fecha fuera de rango"
MENSAJE_CENTRAL_INEXISTENTE="Central inexistente"
MENSAJE_ERROR_DESCONOCIDO="Error desconocido"
MENSAJE_AFUMB_INICIADO="AFUMB corriendo bajo el no.: $PID"
MENSAJE_AFUMB_OCUPADO="Invocacion de AFUMB pospuesta para el siguiente ciclo"

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
      $GRALOG "AFREC" "$MENSAJE_TIPO_INVALIDO" INFO
      "$BINDIR/MoverA.sh" "$NOVEDADES/$file" "$RECHAZADOS"
     # mv "$NOVEDADES/$archivo" $RECHAZADOS
			#Escribir log
			#echo "$archivo no es de texto"
		fi
	done
}

#Guarda los codigos de centrales en el array COD_CENTRALES
function obtener_codigos_centrales() {
 COD_CENTRALES=($(cat "$MAEDIR/CdC.mae" | cut -d \; -f 1))
 # for codigo in $codigos;do
 #    COD_CENTRALES[$codigo]=1
 # done
}

# Chequea que el codigo de central este en el archivo de centrales
function validar_codigo_central() {
  case "${COD_CENTRALES[@]}" in
      *"$codigo_a_validar"*)
        #Si el codigo es invalido sigo
        #echo "Codigo Valido!"
        continue
      ;;
      *)
        # Si el codigo es invalido lo muevo a rechazados
        $GRALOG "AFREC" "$MENSAJE_CENTRAL_INEXISTENTE" INFO
        "$BINDIR/MoverA.sh" "$NOVEDADES/$file" "$RECHAZADOS"
        #mv "$NOVEDADES/$file" "$RECHAZADOS"
        let "resultado = 1"
      ;;
  esac
}

# Chequea si el anio a validar es bisiesto
function bisiesto() {
 YEAR=$1
 rem1=$((YEAR%4))
 rem2=$((YEAR%100))
 rem3=$((YEAR%400))
 let "es_bisiesto = 0"

 if [ ${rem2} = "0" -a ${rem3} != "0" ]
 then
        let "es_bisiesto = 1"
 fi

 if [ ${rem1} = "0" -a ${rem2} != "0" ]
 then
        let "es_bisiesto = 0"
 else
        let "es_bisiesto = 1"
 fi
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
    #echo "Anio invalido"
    $GRALOG "AFREC" "$MENSAJE_FECHA_INVALIDA" INFO
    "$BINDIR/MoverA.sh" "$NOVEDADES/$file" "$RECHAZADOS"
    #mv "$NOVEDADES/$file" "$RECHAZADOS"
    let "resultado = 1"
  else
    #echo "Anio valido"
    continue
  fi

  if [ $mes_a_validar -lt "01" -o $mes_a_validar -gt "12" ]; then
    #echo "Mes invalido"
    $GRALOG "AFREC" "$MENSAJE_FECHA_INVALIDA" INFO
    "$BINDIR/MoverA.sh" "$NOVEDADES/$file" "$RECHAZADOS"
    #mv "$NOVEDADES/$file" "$RECHAZADOS"
    let "resultado = 1"
  else
    #echo "Mes valido"
    continue
  fi

  if [ $dia_a_validar -lt "01" -o $dia_a_validar -gt "31" ]; then
    #echo "Dia invalido"
    $GRALOG "AFREC" "$MENSAJE_FECHA_INVALIDA" INFO
    "$BINDIR/MoverA.sh" "$NOVEDADES/$file" "$RECHAZADOS"
    #mv "$NOVEDADES/$file" "$RECHAZADOS"
    let "resultado = 1"
  else
   if [ $mes_a_validar -eq "02" ]; then
    if [ $dia_a_validar -gt "29" ]; then
     #echo "Dia invalido"
     $GRALOG "AFREC" "$MENSAJE_FECHA_INVALIDA" INFO
     "$BINDIR/MoverA.sh" "$NOVEDADES/$file" "$RECHAZADOS"
     #mv "$NOVEDADES/$file" "$RECHAZADOS"
     let "resultado = 1"
    else
     bisiesto $anio_a_validar
     if [ $dia_a_validar -gt "28" -a $es_bisiesto -eq "1" ]; then
      #echo "Dia invalido"
      $GRALOG "AFREC" "$MENSAJE_FECHA_INVALIDA" INFO
      "$BINDIR/MoverA.sh" "$NOVEDADES/$file" "$RECHAZADOS"
      #mv "$NOVEDADES/$file" "$RECHAZADOS"
      let "resultado = 1"
     fi
    fi
   fi
    #echo "Dia valido"
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
    $GRALOG "AFREC" "$MENSAJE_FECHA_FUERA_DE_RANGO" INFO
    #mv "$NOVEDADES/$file" "$RECHAZADOS"
    "$BINDIR/MoverA.sh" "$NOVEDADES/$file" "$RECHAZADOS"
  else
    #echo "antiguedad ok"
    continue
  fi
}

# Valida que la fecha sea menor o igual a la de hoy
function validar_menor_o_igual_a_hoy() {
  anio_actual=$(date +'%Y')
  mes_actual=$(date +'%m')
  dia_actual=$(date +'%d')

  if [ $anio_a_validar -le $anio_actual ]; then
    #echo "Anio ok"
    continue
  else
    if [ $mes_a_validar -le $mes_actual ]; then
      #echo "Mes ok"
      continue
    else
      if [ $dia_a_validar -le $dia_actual ]; then
        #echo "Dia ok"
        continue
      else
        let "resultado = 1"
        $GRALOG "AFREC" "$MENSAJE_FECHA_INVALIDA" INFO
        "$BINDIR/MoverA.sh" "$NOVEDADES/$file" "$RECHAZADOS"
        #mv "$NOVEDADES/$file" "$RECHAZADOS"
      fi
    fi
  fi

}

# BEGIN
let "NUMERO_CICLO = 0"
while true; do
  MENSAJE_NUMERO_CICLO="AFREC ciclo nro. $NUMERO_CICLO"
  #echo $MENSAJE_NUMERO_CICLO
  $GRALOG "AFREC" "$MENSAJE_NUMERO_CICLO" INFO
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
      if [ $resultado -eq "0" ]; then
       echo "$file aceptado"
       $GRALOG "AFREC" "Archivo $file aceptado, movido a $ACEPTADOS" INFO
       #mv "$NOVEDADES/$file" "$ACEPTADOS"
       "$BINDIR/MoverA.sh" "$NOVEDADES/$file" "$ACEPTADOS"
      fi
    done

  fi

  hay_archivos $NOVEDADES
  if [ $cantidad_archivos -eq 0 ];then
    for file in $(ls -1 "$ACEPTADOS");do
      echo $(ls -1 "$ACEPTADOS")
      hay_archivos $ACEPTADOS
      if [ $cantidad_archivos -gt 0 ];then
        PID=$(pgrep "AFUMB.sh")
        if [ "$PID" = "" ]; then
          "$BINDIR/Arrancar.sh" AFUMB.sh
          $PID=$(pgrep "AFUMB.sh")
          $GRALOG "AFREC" "AFUMB corriendo bajo el no.: $PID" INFO
        else
          $GRALOG "AFREC" "$MENSAJE_AFUMB_OCUPADO" WAR
        fi
        break
      fi
    done
  fi


sleep "$TIEMPO_SLEEP_SEGUNDOS"
done
