class State < ActiveRecord::Base
  has_many :missions
  has_many :tasks
  default_scope { order(position: :asc) }

  def self.states_for_options
    array = Array.new
    self.all.each do |state|
      array << [state.name, state.id, {style: "color:#{state.color}"}]
    end
    return array
  end
end
