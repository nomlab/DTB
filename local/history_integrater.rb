# ARGV[0] : File extension (org, xlsx, pptx...)

if ARGV[0].nil?
  puts "Usage: history_integrater.rb APP_NAME # Display integrated histories path of an APP_NAME"
  puts "APP_NAME list: Preview Excel Emacs"
  exit
end

def app_to_ext(app_name)
  table = {
    "Preview" => :pdf,
    "Excel"   => :xlsx,
    "Emacs"   => :other,
  }
  table[app_name]
end

unless ext = app_to_ext(ARGV[0])
  puts "Error: Unrecognized APP_NAME."
  exit
end

case ext
when :other
  title = UnifiedHistory.arel_table[:title]
  uhs = UnifiedHistory.where.not(title.matches("%.pdf")).where.not(title.matches("%.xlsx")).where.not(title.matches("%.pptx")).file_histories
  integrated_histories = uhs.group_by{|uh| uh.path}.map{|path, uhs| IntegratedHistory.new(uhs)}
else
  integrated_histories = UnifiedHistory.extension(ext).group_by{|uh| uh.path}.map{|path, uhs| IntegratedHistory.new(uhs)}
end

integrated_histories.each do |h|
  puts h.path
end
