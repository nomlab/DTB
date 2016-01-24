class Duration
  attr_reader :start_time, :end_time

  def self.make_from_date(date)
    s_time = Time.zone.local(date.year, date.month, date.day)
    tomorrow = date.tomorrow
    e_time = Time.zone.local(tomorrow.year, tomorrow.month, tomorrow.day)
    new(s_time, e_time)
  end

  def initialize(s_time = Time.current, e_time = Time.current)
    s_time ||= Time.current
    e_time ||= Time.current
    @start_time = s_time
    @end_time = e_time
  end

  def ==(other)
    @start_time == other.start_time && @end_time == other.end_time
  end

  def in?(other)
    other.start_time <= @start_time && @end_time <= other.end_time
  end

  # rertun partial duration sliced by other
  def slice(other)
    return nil unless overlap?(other)
    s_time = @start_time < other.start_time ? other.start_time : @start_time
    e_time = other.end_time < @end_time ? other.end_time : @end_time
    Duration.new(s_time, e_time)
  end

  def merge(other)
    s_time = @start_time < other.start_time ? @start_time : other.start_time
    e_time = @end_time > other.end_time ? @end_time : other.end_time
    Duration.new(s_time, e_time)
  end

  def overlap?(other)
    @start_time < other.end_time && other.start_time < @end_time
  end

  def range
    (@start_time.to_date)..(@end_time.to_date)
  end

  def to_seconds
    (@end_time - @start_time).to_i
  end

  def to_s(option = :duration)
    case option
    when :duration
      "#{@start_time} - #{@end_time}"
    when :hour
      h, m, s = calc_hour_minutes_and_seconds(to_seconds)
      format('%02d:%02d:%02d', h, m, s)
    when :minute
      m, s = calc_minutes_and_seconds(to_seconds)
      format('%02d:%02d', m, s)
    when :second
      "#{to_seconds}"
    else
      fail 'Unknown option.'
    end
  end

  alias_method :s_time, :start_time
  alias_method :e_time, :end_time
  alias_method :length, :to_seconds

  private

  def calc_hour_minutes_and_seconds(sec)
    hour, mod = sec.divmod(3600)
    minutes, seconds = calc_minutes_and_seconds(mod)
    [hour, minutes, seconds]
  end

  def calc_minutes_and_seconds(sec)
    sec.divmod(3600)
  end
end
