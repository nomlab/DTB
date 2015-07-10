# -*- coding: utf-8 -*-
DEMO_DIR = Rails.root.join('local').join('demo')
WEEK = 7
YEAR = 2015

todo = State.create( name: "TODO",
                     color: "#e65757",
                     position: 1,
                     default: true )
done = State.create( name: "DONE",
                     color: "#00ff40",
                     position: 2,
                     default: false )

m_p2 = Mission.create( name:        "Work of TA",
                       deadline:    DateTime.new(YEAR, 7, 30, 0, 0, 0, '+9'),
                       parent_id:   nil, # root mission
                       state_id:    todo.id)


(1..15).each do |n|
  m_lect = Mission.create( name:        "Work related to ##{n}",
                           deadline:    DateTime.new(YEAR, 4, 17, 0, 0, 0, '+9') + (WEEK * n-1),
                           parent_id:   m_p2.id,
                           state_id:    done.id )

  ##################### 講義資料の修正 #####################
  t_check = Task.create( name:        "Improving lecture material",
                         deadline:    DateTime.new(YEAR, 4, 17, 11, 55, 0, '+9') + (WEEK * n-1),
                         mission_id:  m_lect.id,
                         state_id:    done.id )
  TimeEntry.create( name:       "Improving lecture material",
                    start_time: DateTime.new(YEAR, 4, 17, 8, 40, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(YEAR, 4, 17, 8, 50, 0, '+9') + (WEEK * n-1),
                    task_id: t_check.id)
  TimeEntry.create( name:       "Improving lecture material",
                    start_time: DateTime.new(YEAR, 4, 17, 9, 00, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(YEAR, 4, 17, 9, 30, 0, '+9') + (WEEK * n-1),
                    task_id: t_check.id)
  UnifiedHistory.create( title:         "Programming courses",
                         path:          "https://www.swlab.cs.okayama-u.ac.jp/~nom/lect/p2/",
                         type:  "WebHistory",
                         start_time:    DateTime.new(YEAR, 4, 17, 8, 40, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(YEAR, 4, 17, 8, 50, 0, '+9') + (WEEK * n-1),
                         thumbnail:     "http://capture.heartrails.com/200x150/shadow/border?https://www.swlab.cs.okayama-u.ac.jp/~nom/lect/p2/" )
  UnifiedHistory.create( title:         "rivised.txt",
                         path:          DEMO_DIR.join("revise.txt").to_s,
                         type:  "FileHistory",
                         start_time:    DateTime.new(YEAR, 4, 17, 9, 00, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(YEAR, 4, 17, 9, 30, 0, '+9') + (WEEK * n-1),
                         )
  ##########################################################

  ##################### 学生への指導補助 #####################
  t_assist_teach = Task.create( name:        "Help students with programming",
                                description: "Help students with programming",
                                deadline:    DateTime.new(YEAR, 4, 17, 11, 55, 0, '+9') + (WEEK * n-1),
                                mission_id:  m_lect.id,
                                state_id:    done.id )
  TimeEntry.create( name:       "Help students with programming",
                    start_time: DateTime.new(YEAR, 4, 17, 8, 50, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(YEAR, 4, 17, 9, 00, 0, '+9') + (WEEK * n-1),
                    task_id: t_assist_teach.id)
  TimeEntry.create( name:       "Help students with programming",
                    start_time: DateTime.new(YEAR, 4, 17, 9, 30, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(YEAR, 4, 17, 9, 45, 0, '+9') + (WEEK * n-1),
                    task_id: t_assist_teach.id)
  ##########################################################

  ##################### 業務日誌の送付 #####################
  t_mail = Task.create( name:        "Sending a work report",
                        deadline:    DateTime.new(YEAR, 4, 17, 17, 0, 0, '+9') + (WEEK * n-1),
                        mission_id:  m_lect.id,
                        state_id:    done.id )
  TimeEntry.create( name:       "Sending a work report",
                    start_time: DateTime.new(YEAR, 4, 17, 13, 0, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(YEAR, 4, 17, 13, 10, 0, '+9') + (WEEK * n-1),
                    task_id: t_mail.id)
  UnifiedHistory.create( title:         "draft.org",
                         path:          DEMO_DIR.join("draft.org").to_s,
                         type:  "FileHistory",
                         start_time:    DateTime.new(YEAR, 4, 17, 13, 0, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(YEAR, 4, 17, 13, 1, 0, '+9') + (WEEK * n-1) )
  UnifiedHistory.create( title:         "HTML-Export-commands",
                         path:          "http://orgmode.org/manual/HTML-Export-commands.html#HTML-Export-commandss",
                         type:  "WebHistory",
                         start_time:    DateTime.new(YEAR, 4, 17, 13, 1, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(YEAR, 4, 17, 13, 2, 0, '+9') + (WEEK * n-1),
                         thumbnail:     "http://capture.heartrails.com/200x150/shadow/border?http://orgmode.org/manual/HTML-Export-commands.html#HTML-Export-commandss" )
  UnifiedHistory.create( title:         "Emacs: Permanently summing a column in Org-mode tables",
                         path:          "http://stackoverflow.com/questions/6688075/emacs-permanently-summing-a-column-in-org-mode-tables",
                         type:  "WebHistory",
                         start_time:    DateTime.new(YEAR, 4, 17, 13, 2, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(YEAR, 4, 17, 13, 3, 0, '+9') + (WEEK * n-1),
                         thumbnail:     "http://capture.heartrails.com/200x150/shadow/border?http://stackoverflow.com/questions/6688075/emacs-permanently-summing-a-column-in-org-mode-tables" )
  UnifiedHistory.create( title:         "report.eml",
                         path:          DEMO_DIR.join("draft.eml").to_s,
                         type:  "FileHistory",
                         start_time:    DateTime.new(YEAR, 4, 17, 13, 3, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(YEAR, 4, 17, 13, 10, 0, '+9') + (WEEK * n-1) )
  ##########################################################

  if(n == 7 || n == 15)
    t_mail = Task.create( name:        "Confirming submission of reports",
                          deadline:    DateTime.new(YEAR, 4, 17, 17, 0, 0, '+9') + (WEEK * n-1),
                          mission_id:  m_lect.id,
                          state_id:    done.id )
    TimeEntry.create( name:       "Confirming submission of reports",
                      start_time: DateTime.new(YEAR, 4, 17, 15, 0, 0, '+9') + (WEEK * n-1),
                      end_time: DateTime.new(YEAR, 4, 17, 15, 15, 0, '+9') + (WEEK * n-1),
                      task_id: t_mail.id)
    UnifiedHistory.create( title:         "submission_status.xlsx",
                           path:          DEMO_DIR.join("submission_status.xlsx").to_s,
                           type:  "FileHistory",
                           start_time:    DateTime.new(YEAR, 4, 17, 15, 10, 0, '+9') + (WEEK * n-1),
                           end_time:      DateTime.new(YEAR, 4, 17, 15, 15, 0, '+9') + (WEEK * n-1) )
    UnifiedHistory.create( title:         "09425601.pdf",
                           path:          DEMO_DIR.join("09425601.pdf").to_s,
                           type:  "FileHistory",
                           start_time:    DateTime.new(YEAR, 4, 17, 15, 0, 0, '+9') + (WEEK * n-1),
                           end_time:      DateTime.new(YEAR, 4, 17, 15, 2, 0, '+9') + (WEEK * n-1) )
    UnifiedHistory.create( title:         "09425602.pdf",
                           path:          DEMO_DIR.join("09425602.pdf").to_s,
                           type:  "FileHistory",
                           start_time:    DateTime.new(YEAR, 4, 17, 15, 2, 0, '+9') + (WEEK * n-1),
                           end_time:      DateTime.new(YEAR, 4, 17, 15, 4, 0, '+9') + (WEEK * n-1) )
    UnifiedHistory.create( title:         "09425603.pdf",
                           path:          DEMO_DIR.join("09425603.pdf").to_s,
                           type:  "FileHistory",
                           start_time:    DateTime.new(YEAR, 4, 17, 15, 4, 0, '+9') + (WEEK * n-1),
                           end_time:      DateTime.new(YEAR, 4, 17, 15, 6, 0, '+9') + (WEEK * n-1) )
    UnifiedHistory.create( title:         "09425604.pdf",
                           path:          DEMO_DIR.join("09425604.pdf").to_s,
                           type:  "FileHistory",
                           start_time:    DateTime.new(YEAR, 4, 17, 15, 6, 0, '+9') + (WEEK * n-1),
                           end_time:      DateTime.new(YEAR, 4, 17, 15, 8, 0, '+9') + (WEEK * n-1) )
    UnifiedHistory.create( title:         "09425605.pdf",
                           path:          DEMO_DIR.join("09425605.pdf").to_s,
                           type:  "FileHistory",
                           start_time:    DateTime.new(YEAR, 4, 17, 15, 8, 0, '+9') + (WEEK * n-1),
                           end_time:      DateTime.new(YEAR, 4, 17, 15, 10, 0, '+9') + (WEEK * n-1) )
  end

end
#---------------------------------------------------------------------
