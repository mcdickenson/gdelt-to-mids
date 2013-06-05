filename = 'test'
input = filename+'.csv'
output = File.new(filename+'clean.csv', 'w')

# IO.foreach doesn't read the entire file into memory at once, which is good since a standard FasterCSV.parse on this file can take an hour or more
IO.foreach(input) do |line|
  date = line[0..3]
  if date=="1998"
    next 
  else 
    output.write(line)
  end 
end

