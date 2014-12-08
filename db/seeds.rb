unless State.find_by(name: "TODO")
  default = State.find_by(default: true).nil?
  State.create( name: "TODO",
                color: "#e65757",
                position: 1,
                default: default )
end
unless State.find_by(name: "DONE")
  State.create( name: "DONE",
                color: "#00ff40",
                position: 2,
                default: false )
end
