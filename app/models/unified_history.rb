class UnifiedHistory < ActiveRecord::Base

  def duration
    return {"start_time" => start_time, "end_time" => end_time}
  end

  class WebHistory < UnifiedHistory
  end

  class Filehistory < UnifiedHistory
  end
end
