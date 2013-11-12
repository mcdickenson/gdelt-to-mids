cat CSV.header.historical.txt > postdelt.tsv
for i in {2002..2005}
do
    echo "$i" 
    # unzip "$i.zip"
    gunzip "$i.tsv"
    wait
    cat "$i.tsv" >> postdelt.tsv
    wait
    # mv "$i.csv" "$i.tsv"
    gzip "$i.tsv"
    # rm "$i.zip"
done