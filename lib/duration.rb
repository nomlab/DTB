class Duration
  attr_reader :start_time, :end_time

  def initialize(s_time = Time.current, e_time = Time.current)
    s_time ||= Time.current
    e_time ||= Time.current
    @start_time = s_time
    @end_time = e_time
  end

  def ==(other)
    return false unless other.class == Duration
    @start_time == other.start_time && @end_time == other.end_time
  end

  def in?(other)
    return false unless other.class == Duration
    other.start_time <= @start_time && @end_time <= other.end_time
  end

  def merge(other)
    @end_time ||= @start_time
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

  def slice(other)
    if overlap?(other)
      s_time = @start_time < other.start_time ? other.start_time : @start_time
      e_time = other.end_time < @end_time ? other.start_time : @end_time
      return Duration.new(s_time, e_time)
    else
      return nil
    end
  end

  def to_seconds
    (@end_time - @start_time).to_i
  end

  def length
    to_seconds
  end

  def to_s(option = nil)
    if option == :hour
      h, mod = to_seconds.divmod(3600)
      m, s = mod.divmod(60).map do |num|
        num.to_s.rjust(2, '0')
      end
      return "#{h}:#{m}:#{s}"
    elsif option == :minute
      m, s = to_seconds.divmod(60)
      s.to_s.rjust(2, '0')
      return "#{m}:#{s}"
    elsif option == :second
      return "#{to_seconds}"
    end
    "#{@start_time} - #{@end_time}"
  end
end
