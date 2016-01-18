# RAILS_ENV=production bundle exec rails runner local/all_history_integrater.rb "2015/01/01 10:00:00" "2016/01/01 11:00:00"

# make durations
durs = []
ARGV.each_slice(2) do |s_time, e_time|
  durs << Duration.new(Time.zone.parse(s_time), Time.zone.parse(e_time))
end

uhs = UnifiedHistory.all
uhs = uhs.overlap(durs) unless durs.blank?

integrated_histories = IntegratedHistory.integrate(UnifiedHistory.all)

puts "タイトル,パス,重要度,成果物あるいは参考資料か"
integrated_histories.each do |h|
  puts "#{h.title},#{h.path},#{h.importance},"
end
