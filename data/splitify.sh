for i in {1999..2001}
do
    echo "$i" 
    gunzip "$i.csv.gz"
    wait
    total_lines=$(cat "$i.csv" | wc -l)
    echo $total_lines
    ((num_files = (total_lines + 2000000) / 2000000))
    split -l2000000 -a1 "$i.csv" "$i"

    for j in `seq 1 $num_files`
    do
    	((k=($j+96)))
    	c=$(printf \\$(printf '%03o' $k))
    	mv "$i$c" "$i$c.csv"
    	gzip "$i$c.csv"
    done
    rm "$i.csv"
done