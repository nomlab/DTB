integrated_histories = IntegratedHistory.integrate(UnifiedHistory.all)

puts "タイトル,パス,重要度,成果物あるいは参考資料か"
integrated_histories.each do |h|
  puts "#{h.title},#{h.path},#{h.importance},"
end
