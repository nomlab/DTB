# ARGV[0] : File extension (org, xlsx, pptx...)

if ARGV[0].nil?
  puts "Usage: history_integrater.rb FILE_EXTENSION # Display integrated histories of an FILE_EXTENSION"
  exit
end

integrated_histories = UnifiedHistory.extension(ARGV[0]).group_by{|uh| uh.path}.map{|path, uhs| IntegratedHistory.new(uhs)}
integrated_histories.each do |h|
  puts h.path
end
