class UnifiedHistory < ActiveRecord::Base
  default_scope { order(created_at: :desc) }
  scope :file_histories, -> { where(type: "FileHistory") }
  scope :web_histories, -> { where(type: "WebHistory") }
  scope :extension, -> (ext) { where("path like '%.#{ext}'") }

  before_save :set_importance

  def self.in(duration)
    duration = Duration.new(nil, nil) if duration.nil?
    where(["start_time >= ? and start_time <= ? or end_time >= ? and end_time <= ?",
           duration.start_time, duration.end_time,
           duration.start_time, duration.end_time])
  end

  def duration
    return Duration.new(start_time, end_time)
  end

  def restore
    system "open #{self.path}"
  end

  private
  def set_importance
    self.importance = duration.length
  end
end

class WebHistory < UnifiedHistory
  def extension
    return "html"
  end
end

class FileHistory < UnifiedHistory
  def extension
    return self.path.split("/").last.split(".").last
  end

  # TODO: restore file by git
  # def restore
  # end
end
