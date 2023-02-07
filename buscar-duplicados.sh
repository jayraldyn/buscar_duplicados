#!/bin/bash

dir="$1"
if [ "$1"z == z ]; then
  echo "Uso: buscar-duplicados.sh <directorio>"
  exit 1
fi

# Primero recorremos el directorio. 
# Sólo ficheros de más de 50k
# Excluyo los de la carpeta de borrados
echo -n "Generando listado de ficheros a comprobar... "
f1=`mktemp`
find "$dir" -type f -size +50k -printf "%s|%p\n" | grep -v "#recycle" | sort -n > $f1
numf=`wc -l $f1 | cut -d " " -f 1`
echo $numf "ficheros."

# Creamos un fichero con sólo tamaños repetidos a partir del primero
echo -n "Comprobando tamaños repetidos..." 
f2=`mktemp`
awk ' BEGIN { FS="|"} { print $1 } ' $f1 | uniq -d > $f2
echo "hecho."

# Ahora filtramos los ficheros cuyo tamaño está en el fichero de tamaños repetidos
echo -n "Filtrando ficheros con tamaños repetidos... "
f3=`mktemp`
while read linea; do
  grep -e "^$linea\|*" $f1 
done < $f2 > $f3
numf=`wc -l $f3 | cut -d " " -f 1`
echo $numf "ficheros."

# Añadimos el MD5 a la lista de ficheros con tamaños repetidos
echo -n "Calculando MD5 con los candidatos a duplicados..."
f4=`mktemp`
while read linea; do
  t=`echo "$linea" | awk ' BEGIN { FS="|"} { print $1 } '`
  f=`echo "$linea" | awk ' BEGIN { FS="|"} { print $2 } '`
  m=`md5sum "$f" | awk ' { print $1 } '`
  echo "$m|$t|$f"
done < $f3 > $f4
echo "hecho."

# Extraemos el MD5 y tamaño a otro fichero para poder buscar
echo -n "Extrayendo cálculos MD5 para buscar el resultado... "
f5=`mktemp`
awk ' BEGIN { FS="|"} { print $1"|"$2"|" } ' $f4 | uniq -d > $f5
echo "hecho."

echo "Resultado:"
echo "-----------------------------------------------------------------------------------------------------------------"
# Y por último escribimos la lista de ficheros que tienen MD5 y tamaños duplicados
while read linea; do 
  grep ^$linea $f4
  echo "-----------------------------------------------------------------------------------------------------------------"
done < $f5

# Algo de limpieza
rm $f1 $f2 $f3 $f4 $f5

