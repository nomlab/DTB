class UnifiedHistory < ActiveRecord::Base
  class WebHistory < UnifiedHistory
  end

  class Filehistory < UnifiedHistory
  end
end
