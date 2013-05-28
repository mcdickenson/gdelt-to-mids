for i in {1990..2001}
do
    echo "$i" 
    unzip "$i.zip"
    wait
    gzip "$i.csv"
    mv "$i.zip" zips 
done