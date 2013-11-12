cat CSV.header.historical.txt > postdelt2.tsv
for i in {2006..2012}
do
	for j in 01 02 03 04 05 06 07 08 09 10 11 12
	do
	  echo "$i$j"
    unzip "$i$j.zip"
    wait
    cat "$i$j.csv" >> postdelt2.tsv
    wait
    mv "$i$j.csv" "$i$j.tsv"
    gzip "$i$j.tsv"
    rm "$i$j.zip"
	done  
done