# RAILS_ENV=production bundle exec rails runner local/history_integrater.rb Emacs "2015/01/01 10:00:00" "2016/01/01 11:00:00"
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

unless ext = app_to_ext(ARGV.shift)
  puts "Error: Unrecognized APP_NAME."
  exit
end

# make durations
durs = []
ARGV.each_slice(2) do |s_time, e_time|
  durs << Duration.new(Time.zone.parse(s_time), Time.zone.parse(e_time))
end

case ext
when :other
  title = UnifiedHistory.arel_table[:title]
  uhs = UnifiedHistory.where.not(title.matches("%.pdf")).where.not(title.matches("%.xlsx")).where.not(title.matches("%.pptx")).file_histories
  uhs = uhs.overlap(durs) unless durs.blank?
  integrated_histories = uhs.group_by{|uh| uh.path}.map{|path, uhs| IntegratedHistory.new(uhs)}
else
  uhs = UnifiedHistory.extension(ext)
  uhs = uhs.overlap(durs) unless durs.blank?
  integrated_histories = uhs.group_by{|uh| uh.path}.map{|path, uhs| IntegratedHistory.new(uhs)}
end

integrated_histories.each do |h|
  puts h.path
end
