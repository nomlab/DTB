class Task < ActiveRecord::Base
  has_many :time_entries
  belongs_to :mission
end
