class Duration
  attr_reader :start_time, :end_time

  def initialize(s_time, e_time)
    @start_time = s_time
    @end_time = e_time
  end

  def ==(other)
    return false unless other.class == Duration
    return @start_time == other.start_time && @end_time == other.end_time
  end

  def in?(other)
    return false unless other.class == Duration
    return other.start_time <= @start_time && @end_time <= other.end_time
  end

  def merge(other)
    s_time = @start_time < other.start_time ? @start_time : other.start_time
    e_time = @end_time > other.end_time ? @end_time : other.end_time
    return Duration.new(s_time, e_time)
  end

  def to_seconds
    return (@end_time - @start_time).to_i
  end

  def to_s
    return "#{@start_time.to_s} - #{@end_time.to_s}"
  end
end
