#!/usr/local/bin python

import optparse
import sys
from datetime import *

def aggregate():
  p = optparse.OptionParser()
  p.add_option('--start', '-s', default="1900", type="int", help="Just aggregate data starting with this year.")
  p.add_option('--end', '-e', default="3000", type="int", help="Just aggregate data up to this year.")
  p.add_option('--limit_rows', '-l', default=None, type="int", help="Just parse a fixed number of rows.")
  options, arguments = p.parse_args()


  headers = []
  date_ix = None

  ix = 0
  counts = {}
  for line in sys.stdin:
    # Get the headers
    line = line.replace('"','').replace("\n", '').split(",")
    if len(headers) == 0:
      headers = line
      date_ix = headers.index('date')
      actor1_geo_country_code_ix = headers.index('Actor1Geo_CountryCode')
      actor2_geo_country_code_ix = headers.index('Actor2Geo_CountryCode')
      root_code_ix = headers.index('EventRootCode')
      continue

    # Parse some dates
    this_date = datetime.strptime(line[date_ix], "%Y-%m-%d")
    country_1 = line[actor1_geo_country_code_ix]
    country_2 = line[actor2_geo_country_code_ix]
    event_root_code = line[root_code_ix]
    # Is this in our window tp aggregate?
    if this_date.year >= options.start and this_date.year <= options.end:

      # Lazy init hashes
      if this_date.year not in counts.keys():
        counts[this_date.year] = {}
      if this_date.month not in counts[this_date.year].keys():
        counts[this_date.year][this_date.month] = {}
      if country_1 not in counts[this_date.year][this_date.month].keys():
        counts[this_date.year][this_date.month][country_1] = {}
      if country_2 not in counts[this_date.year][this_date.month][country_1].keys():
        counts[this_date.year][this_date.month][country_1][country_2] = {}
      if event_root_code not in counts[this_date.year][this_date.month][country_1][country_2].keys():
        counts[this_date.year][this_date.month][country_1][country_2][event_root_code] = 0

      counts[this_date.year][this_date.month][country_1][country_2][event_root_code] += 1

    ix += 1
    if options.limit_rows and ix > options.limit_rows:
      break
  print counts

if __name__ == '__main__':
  aggregate()