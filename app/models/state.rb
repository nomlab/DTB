class State < ActiveRecord::Base
  has_many :missions
  has_many :tasks
  default_scope { order(position: :asc) }

  def self.states_for_options
    array = []
    all.find_each do |state|
      array << [state.name, state.id, { style: "color:#{state.color}" }]
    end
    array
  end
end
