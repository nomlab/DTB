# diffをとる
`lib\\diff.exe lib\\PrivateServerLog.txt lib\\tmplog.txt`.each do |line|
  if /^< (.*)$/ =~ line
    puts $1
  end
end
`copy lib\\PrivateServerLog.txt lib\\tmplog.txt`