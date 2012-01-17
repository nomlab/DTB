`ruby getlnk.rb > savelnk.txt`
`diff.exe startlnk.txt savelnk.txt`.each do |line|
  if /^> (\d\d\d\d\/\d\d\/\d\d \d\d:\d\d) ([\S ]*)/ =~ line
    if $2 != ""
      print $1 + " " + $2 + "\n"
    end
  end
end
`copy savelnk.txt startlnk.txt`