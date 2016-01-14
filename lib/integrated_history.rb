#
# Integrat histories about same file or web page.
#
class IntegratedHistory
  attr_reader :title, :path, :thumbnail, :durations, :representative_history

  def self.integrate(histories)
    grouped_histories = histories.group_by(&:path)
    grouped_histories.map { |_path, uhs| IntegratedHistory.new(uhs) }
  end

  # grouped_histories: Array of unified_history that has same path.
  def initialize(grouped_histories)
    @title                  = grouped_histories.first.title
    @path                   = grouped_histories.first.path
    @thumbnail              = grouped_histories.first.thumbnail
    @type                   = grouped_histories.first.type
    @durations              = grouped_histories.map(&:duration)
    @representative_history = grouped_histories.first
  end

  def duration
    @durations.reduce { |a, e| a.merge e }
  end

  def durations_of_day(date)
    date_duration = Duration.new(date.to_time, date.tomorrow.to_time)
    @durations.map { |duration| duration.slice(date_duration) }.compact
  end

  def importance
    length
  end

  def importance_of_day(date)
    length_of_day(date)
  end

  def length
    @durations.map(&:length).reduce(0, :+)
  end

  def length_of_day(date)
    durations_of_day(date).map(&:length).reduce(0, :+)
  end
end
