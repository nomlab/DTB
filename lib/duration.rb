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

  def to_s(option = nil)
    if option == :hour
      h, mod = self.to_seconds.divmod(3600)
      m, s = mod.divmod(60).map do |num|
        num.to_s.rjust(2, "0")
      end
      return "#{h}:#{m}:#{s}"
    elsif option == :minute
      m, s = self.to_seconds.divmod(60)
      s.to_s.rjust(2, "0")
      return "#{m}:#{s}"
    elsif option == :second
      return "#{self.to_seconds}"
    end
    return "#{@start_time.to_s} - #{@end_time.to_s}"
  end
end
