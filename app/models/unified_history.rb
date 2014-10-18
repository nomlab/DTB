class UnifiedHistory < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  def duration
    return Duration.new(start_time, end_time)
  end

  def restore
    system "open #{self.path}"
  end
end

class WebHistory < UnifiedHistory
end

class FileHistory < UnifiedHistory
  def restore
    # restore file by git
  end
end
