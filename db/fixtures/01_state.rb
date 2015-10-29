State.seed do |s|
  s.id       = 1
  s.name     = "TODO"
  s.color    = "#e65757"
  s.position = 1
  s.default  = true
end
State.seed do |s|
  s.id       = 2
  s.name     = "STARTED"
  s.color    = "#00f5ff"
  s.position = 2
  s.default  = false
end
State.seed do |s|
  s.id       = 3
  s.name     = "WAIT"
  s.color    = "#4ad0b7"
  s.position = 3
  s.default  = false
end
State.seed do |s|
  s.id       = 4
  s.name     = "POSTPONE"
  s.color    = "#ff00ff"
  s.position = 4
  s.default  = false
end
State.seed do |s|
  s.id       = 5
  s.name     = "MAYBE"
  s.color    = "#ffe100"
  s.position = 5
  s.default  = false
end
State.seed do |s|
  s.id       = 6
  s.name     = "CANCELED"
  s.color    = "#ffdead"
  s.position = 6
  s.default  = false
end
State.seed do |s|
  s.id       = 7
  s.name     = "DONE"
  s.color    = "#9fffa6"
  s.position = 10000
  s.default  = false
end
