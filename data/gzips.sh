for i in {1980..1991}
do
    echo "$i" 
    gzip "$i.tsv"
done