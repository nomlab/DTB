class UnifiedHistory < ActiveRecord::Base
  default_scope { order(created_at: :desc) }
  scope :in, ->(start_time, end_time) { where(["start_time >= ? and start_time <= ? or end_time >= ? and end_time <= ?",
                                               start_time, end_time, start_time, end_time]) }
  scope :file_histories, -> { where(type: "FileHistory") }
  scope :web_histories, -> { where(type: "WebHistory") }

  def duration
    return Duration.new(start_time, end_time)
  end

  def restore
    system "open #{self.path}"
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
