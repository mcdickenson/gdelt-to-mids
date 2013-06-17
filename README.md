gdelt-to-mids
=============

Code for recreating MIDS data from GDELT


To use the aggregator right now use the following syntax from the command line:

python aggregator.py < data/train-sampled.csv --limit_rows 10000 > outfile.csv

* --limit_rows can be removed, it just prevents parsing the whole file (for development)
* just pipe in the file you want to parse and pipe out the output
