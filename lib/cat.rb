file_name = ARGV.shift
File.foreach(file_name) do |line|
  print line
end
