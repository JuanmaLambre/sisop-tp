#!/bin/bash

function grabar_en_el_log {

	#echo "$1" >> logAFUMB.txt
	#${BINDIR}GraLog.sh "AFUMB.sh" "$1" "INFO" 
	${BINDIR}GraLog.sh "AFUMB" "$1" "INFO"

}

function mover_archivo {

	#echo "Se mueve el archivo $1 a la carpeta $2" >> logAFUMB.txt
	${BINDIR}MoverA.sh $1 $2
}






function rechazar_registro {

	Motivo=$1
	((Cantidad_llamadas_rechazadas++))

	ID_central=${Archivo_llamadas##*/}
        ID_central=${ID_central%_*}

	Archivo_rechazados="${ID_central}.rech"

	echo "$Archivo_llamadas;$Motivo;$llamada" >> "${RECHDIR}llamadas/$Archivo_rechazados"
}













function guardar_llamada_sospechosa {

	#4.4 GRABAR LLAMADA SOSPECHOSA

	((Cantidad_llamadas_sospechosas++))


	ID_central=${Archivo_llamadas##*/}
	ID_central=${ID_central%_*}
	
	ID_umbral=$(echo "$umbral_aplicable" | cut -d ";" -f 1)
	
	Fecha_del_archivo=${Archivo_llamadas##*_}
	Fecha_del_archivo=${Fecha_del_archivo%%.*}
	
	Oficina=$(grep "^.*;.*;$AgenteID;.*" -m 1 $Archivo_agentes | cut -d ";" -f 4)

	Anio_mes_llamada=$(echo "$Inicio_llamada"| sed 's=^../\(..\)/\(....\) .*$=\2\1=')

	Nombre_archivo_sospechosos="$PROCDIR${Oficina}_${Anio_mes_llamada}"

	echo "$ID_central;$AgenteID;$ID_umbral;$Tipo;$Inicio_llamada;$Duracion;$AreaA;$LineaA;$PaisB;$AreaB;$LineaB;$Fecha_del_archivo" >> "$Nombre_archivo_sospechosos"

}



function analizar_umbrales {

	#4.3 Determinar si la llamada debe ser considerada como sospechosa.

	#1ro busco una lista con la misma Area, Linea y Tipo; y que este activo, obviamente
	#umbrales comparables son los umbrales que coincidan con el AreaA, LineaA y Tipo
	umbrales_comparables=$(grep "^.*;$AreaA;$LineaA;$Tipo;.*;.*;Activo$" $Archivo_umbrales)

	if [[ $umbrales_comparables != "" ]]; then

		((Cantidad_llamadas_con_umbral++))

		#De los umbrales comparables me tengo que fijar primero si hay alguno con codigo destino vacio
		umbral_aplicable=$(echo "$umbrales_comparables" | grep ";;.*;.*$" -m1 | cut -d ";" -f 1)		

		if [[ $umbral_aplicable != "" ]]; then
			guardar_llamada_sospechosa
		else

			#Entra aca si hay umbrales comparables pero ninguno tiene el codigo destino vacio
			#de los umbrales comparables busco los que coincidan con el codigo destino

			if [[ $Tipo == DDI ]];then
				codigo_destino=$PaisB
			else
				codigo_destino=$AreaB
			fi
	
		        umbral_aplicable=$(echo "$umbrales_comparables" | grep ";$codigo_destino;.*;.*$" -m1)
		
		        if [[ $umbral_aplicable != "" ]]; then

				#Comparo el tope con la duracion
		                if [ $(echo "$umbral_aplicable" | cut -d ";" -f 6 ) -lt $Duracion ]; then
					guardar_llamada_sospechosa
		                fi
		        fi
		fi
	fi
}
	



function validar_numero_B {

	#4.1 Validar los campos del registro

	Tipo=""
	PaisB=$(echo "$llamada" | cut -d ";" -f 6)
	AreaB=$(echo "$llamada" | cut -d ";" -f 7)	
	LineaB=$(echo "$llamada" | cut -d ";" -f 8)
	Duracion=$(echo "$llamada" | cut -d ";" -f 3)

	#4.2 Determinar el tipo de llamada
	#Ademas se validan PaisB y AreaB
	if [[ $PaisB != "" ]]; then
		if [[ $AreaB != "" ]]; then
			rechazar_registro "El numero B tiene codigo de pais y de area, imposibilidad de determinar el tipo de llamada" 
		else
			#Me fijo si el pais es valido
			if [[ $(echo "$Paises" | grep -o "^$PaisB$" | wc -l) == 0 ]]; then
				rechazar_registro "Codigo de pais del numero B es inexistente"

			else
				Tipo="DDI"
			fi
		fi
	else
		if [[ $AreaB == "" ]]; then
			rechazar_registro "El numero B no tiene ni codigo de pais ni de area, imposibilidad de determinar el tipo de la llamada"
		else
			#Me fijo si es un area valida
			if [[ $(echo "$Areas" | grep -o "^$AreaB$" | wc -l) == 0 ]]; then
				rechazar_registro "Area del numero B es inexistente"
			else 
				if [[ $AreaB != $AreaA ]]; then
					Tipo="DDN"
				else
					Tipo="LOC"
				fi
			fi
		fi
	fi

	#Validacion de la LineaB solo si el tipo fue definido
	if [[ $Tipo != "" ]]; then
		if [[ $LineaB == "" ]]; then
			rechazar_registro "Numero de linea del numero B se encuentra vacia"
		else
			if [[ ( $Tipo == "DDN" || $Tipo == "LOC" ) && ( $(echo -n "$AreaB$LineaB" | wc -m ) != 10 ) ]]; then
				rechazar_registro "Se rechaza porque la llamada es de tipo $Tipo pero el area y el numero de linea del numero B no suman 10 digitos"
			else
				if [ $Duracion -lt 0 ]; then
					rechazar_registro "Duracion de la llamada es negativa"
				else
					analizar_umbrales
				fi
			fi
		fi
	fi
}



























#ACEPDIR=acep/
#PROCDIR=proc/
#RECHDIR=rech/
#MAEDIR=mae
#BINDIR=./


Archivo_agentes=$MAEDIR/agentes.csv
Archivo_areas=$MAEDIR/CdA.csv
Archivo_paises=$MAEDIR/CdP.csv
Archivo_umbrales=$MAEDIR/umbrales.csv #en el enunciado dice MAEDIR/umbral.tab pero el archivo que nos pasaron se llama umbrales.csv

ID_Agentes=$(cut -d ";" -f 3 $Archivo_agentes)
Areas=$(cut -d ";" -f 2 $Archivo_areas)
Paises=$(cut -d ";" -f 1 $Archivo_paises)






#1. Procesar todos los archivos
#Obtengo la lista de archivos a procesar y la ordeno del mas antiguo al mas reciente
Lista_archivos=$(ls -1 $ACEPDIR)
Lista_archivos=$(echo "$Lista_archivos" | sort -t_ -nk2)

grabar_en_el_log "Inicio de AFUMB
Cantidad de archivos a procesar: $(ls -1 $ACEPDIR|wc -l)"



Cantidad_archivos_procesados=0
Cantidad_archivos_rechazadas=0

#2. Procesar Un Archivo
for Archivo_llamadas in $Lista_archivos
do
	#2.1 Verificar que no sea un archivo duplicado
	if [ -f "${PROCDIR}proc/$Archivo_llamadas" ]; then				
		grabar_en_el_log "Se rechaza el archivo $Archivo_llamadas por estar DUPLICADO"
		mover_archivo  $ACEPDIR$Archivo_llamadas $RECHDIR
		((Cantidad_archivos_rechazadas++))
	else
		#2.2 Verificar la cantidad de campos del primer registro
		Archivo_llamadas_path=$ACEPDIR$Archivo_llamadas
		if [ $(head -n 1 $Archivo_llamadas_path | sed 's/[^;]//g' | wc -m) != 8 ]; then
			grabar_en_el_log "Se rechaza el archivo: $Archivo_llamadas porque su estructura no se corresponde con el formato esperado"
			mover_archivo $Archivo_llamadas_path $RECHDIR			
			((Cantidad_archivos_rechazadas++))
		else
			#3. Si se puede procesar el archivo grabar en el log
			grabar_en_el_log "Archivo a procesar: $Archivo_llamadas"
			((Cantidad_archivos_procesados++))
			
			#Contadores
			#7. Llevar a cero todos los contadores de registros
			Cantidad_llamadas=0
			Cantidad_llamadas_rechazadas=0
			Cantidad_llamadas_con_umbral=0
			Cantidad_llamadas_sospechosas=0


			while read -r llamada
			do
				#4. Procesar un registro
				((Cantidad_llamadas++))

				#4.1 Validar los campos del registro
				AgenteID=$(echo "$llamada" | cut -d ";" -f 1)
				Inicio_llamada=$(echo "$llamada"|cut -d ";" -f 2)
				if [[ $(echo "$ID_Agentes" | grep -o "^$AgenteID$" | wc -l) == 0 ]]; then
					rechazar_registro "ID del agente es inexistente"
		
				else
					AreaA=$(echo "$llamada" | cut -d ";" -f 4)
					if [[ $(echo "$Areas" | grep -o "^$AreaA$" | wc -l) == 0 ]]; then
						#Si entro aca es porque NO se encontro el area
						rechazar_registro "Area del numero A es inexistente"
					else
						LineaA=$(echo "$llamada" | cut -d ";" -f 5)
						if [[ $(echo -n "$AreaA$LineaA"|wc -m) != 10 ]]; then
							rechazar_registro "Se rechaza porque el area y el numero de linea del numero A no suman 10 digitos"
						else
							validar_numero_B 
						fi
					fi
				fi		
			#5. Repetir hasta que se termine el archivo.
			done < $Archivo_llamadas_path

			#6. Fin de Archivo
			mover_archivo $Archivo_llamadas_path ${PROCDIR}proc
		
			grabar_en_el_log "Cantidad de llamadas = $Cantidad_llamadas: Rechazadas $Cantidad_llamadas_rechazadas, Con umbral = $Cantidad_llamadas_con_umbral, Sin umbral $((Cantidad_llamadas-Cantidad_llamadas_con_umbral-Cantidad_llamadas_rechazadas))"
			grabar_en_el_log "Cantidad de llamadas sospechosas $Cantidad_llamadas_sospechosas, no sospechosas $((Cantidad_llamadas_con_umbral-Cantidad_llamadas_sospechosas))"
		fi
	fi
	#8. Continuar con el siguiente archivo
	#9. Repetir hasta que se terminen todos los archivos.
done

#10. Fin Proceso
grabar_en_el_log "Cantidad de archivos procesados: $Cantidad_archivos_procesados"
grabar_en_el_log "Cantidad de archivos rechazados: $Cantidad_archivos_rechazadas"
grabar_en_el_log "Fin de AFUMB"



