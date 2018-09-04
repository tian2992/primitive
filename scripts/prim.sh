# Example: /prim.sh crayon2.jpg 1000 1024 1024 0 test.png

for i in {1..4}
do
  ~/go/bin/primitive -rep 30 -a 0 -m 0 -v -i $1 -n $2 -r $3 -s $4 -mp $5 -o $6-tmp$(date +%s).png
done

convert $6-tmp*.png -average $6-mean.png

rm $6-tmp*.png