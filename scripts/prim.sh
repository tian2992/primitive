# Example: /prim-mean.sh ber.jpg 2000 1024 2048 80 6 bertest
filename=${1%.*}

echo "prim.sh ${1} ${2} ${3} ${4} ${5} ${6}" > ${filename}-${5}-parms.txt

for i in $( eval echo {1..${6}} )
do
  primitive -rep 10 -a 0 -i ${1} -m 0 -n ${2} -r ${3} -s ${4} -mp ${5} -v -o ${filename}-${5}-mean${6}-tmp$i.png
  convert ${filename}-${5}-mean${6}-tmp*.png -average ${filename}-${5}-mean${6}.png
done

rm ${filename}-${5}-mean${6}-tmp*.png
