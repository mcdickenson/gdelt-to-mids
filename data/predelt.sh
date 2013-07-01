cat CSV.header.historical.txt > predelt2.tsv
for i in {1979..1991}
do
    echo "$i" 
    gunzip "$i.tsv"
    wait
    cat "$i.tsv" >> predelt2.tsv
    wait
    gzip "$i.tsv"
done