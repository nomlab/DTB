DEMO_DIR = Rails.root.join('local').join('demo')
WEEK = 7

todo = State.create( name: "TODO",
                     color: "#e65757",
                     position: 1,
                     default: true )
done = State.create( name: "DONE",
                     color: "#00ff40",
                     position: 2,
                     default: false )

m_p2 = Mission.create( name:        "TAの業務",
                       description: "プログラミング演習TAに関する業務",
                       deadline:    DateTime.new(2014, 7, 30, 0, 0, 0, '+9'),
                       keyword:     "p2 TA",
                       parent_id:   nil, # root mission
                       state_id:    todo.id)


(1..15).each do |n|
  m_lect = Mission.create( name:        "第#{n}回講義の業務",
                           description: "第#{n}回講義に関する業務",
                           deadline:    DateTime.new(2014, 4, 17, 0, 0, 0, '+9') + (WEEK * n-1),
                           keyword:     "p2 TA 講義",
                           parent_id:   m_p2.id,
                           state_id:    done.id )

  ##################### 講義資料の修正 #####################
  t_check = Task.create( name:        "講義資料の修正",
                         description: "講義資料の確認と修正",
                         deadline:    DateTime.new(2014, 4, 17, 11, 55, 0, '+9') + (WEEK * n-1),
                         keyword:     "講義資料",
                         mission_id:  m_lect.id,
                         state_id:    done.id )
  TimeEntry.create( name:       "講義資料の修正",
                    keyword:    "講義資料",
                    comment:    "誤字脱字をチェックする",
                    start_time: DateTime.new(2014, 4, 17, 8, 40, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(2014, 4, 17, 8, 50, 0, '+9') + (WEEK * n-1),
                    task_id: t_check.id)
  TimeEntry.create( name:       "講義資料の修正",
                    keyword:    "講義資料",
                    comment:    "誤字脱字をチェックする",
                    start_time: DateTime.new(2014, 4, 17, 9, 00, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(2014, 4, 17, 9, 30, 0, '+9') + (WEEK * n-1),
                    task_id: t_check.id)
  UnifiedHistory.create( title:         "2014年度 プログラミング演習",
                         path:          "https://www.swlab.cs.okayama-u.ac.jp/~nom/lect/p2/",
                         type:  "WebHistory",
                         start_time:    DateTime.new(2014, 4, 17, 8, 40, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(2014, 4, 17, 8, 50, 0, '+9') + (WEEK * n-1),
                         thumbnail:     "http://capture.heartrails.com/200x150/shadow/border?https://www.swlab.cs.okayama-u.ac.jp/~nom/lect/p2/" )
  UnifiedHistory.create( title:         "revise.txt",
                         path:          DEMO_DIR.join("revise.txt").to_s,
                         type:  "FileHistory",
                         start_time:    DateTime.new(2014, 4, 17, 9, 00, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(2014, 4, 17, 9, 30, 0, '+9') + (WEEK * n-1),
                         )
  ##########################################################

  ##################### 学生への指導補助 #####################
  t_assist_teach = Task.create( name:        "学生への指導補助",
                                description: "学生への指導補助",
                                deadline:    DateTime.new(2014, 4, 17, 11, 55, 0, '+9') + (WEEK * n-1),
                                keyword:     "質問 回答",
                                mission_id:  m_lect.id,
                                state_id:    done.id )
  TimeEntry.create( name:       "学生への指導補助",
                    keyword:    "指導 質問",
                    comment:    "学生からの質問内容はメモしておく",
                    start_time: DateTime.new(2014, 4, 17, 8, 50, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(2014, 4, 17, 9, 00, 0, '+9') + (WEEK * n-1),
                    task_id: t_assist_teach.id)
  TimeEntry.create( name:       "学生への指導補助",
                    keyword:    "指導 質問",
                    comment:    "学生からの質問内容はメモしておく",
                    start_time: DateTime.new(2014, 4, 17, 9, 30, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(2014, 4, 17, 9, 45, 0, '+9') + (WEEK * n-1),
                    task_id: t_assist_teach.id)
  ##########################################################

  ##################### 業務日誌の送付 #####################
  t_mail = Task.create( name:        "業務日誌の送付",
                        description: "業務日誌の作成と送付",
                        deadline:    DateTime.new(2014, 4, 17, 17, 0, 0, '+9') + (WEEK * n-1),
                        keyword:     "メール 業務日誌",
                        mission_id:  m_lect.id,
                        state_id:    done.id )
  TimeEntry.create( name:       "業務日誌の送付",
                    keyword:    "メール",
                    comment:    "書いてないことをメールの冒頭に書かないこと",
                    start_time: DateTime.new(2014, 4, 17, 13, 0, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(2014, 4, 17, 13, 10, 0, '+9') + (WEEK * n-1),
                    task_id: t_mail.id)
  UnifiedHistory.create( title:         "draft.org",
                         path:          DEMO_DIR.join("draft.org").to_s,
                         type:  "FileHistory",
                         start_time:    DateTime.new(2014, 4, 17, 13, 0, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(2014, 4, 17, 13, 1, 0, '+9') + (WEEK * n-1) )
  UnifiedHistory.create( title:         "Org-mode による HTML 文書作成入門",
                         path:          "http://www.geocities.jp/km_pp1/org-mode/org-mode-document.html",
                         type:  "WebHistory",
                         start_time:    DateTime.new(2014, 4, 17, 13, 1, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(2014, 4, 17, 13, 2, 0, '+9') + (WEEK * n-1),
                         thumbnail:     "http://capture.heartrails.com/200x150/shadow?http://www.geocities.jp/km_pp1/org-mode/org-mode-document.html" )
  UnifiedHistory.create( title:         "org-mode + remember-mode で挿入される日付フォーマットを変更するには",
                         path:          "http://d.hatena.ne.jp/kyagi/20090606/1244285675",
                         type:  "WebHistory",
                         start_time:    DateTime.new(2014, 4, 17, 13, 2, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(2014, 4, 17, 13, 3, 0, '+9') + (WEEK * n-1),
                         thumbnail:     "http://capture.heartrails.com/200x150/shadow?http://d.hatena.ne.jp/kyagi/20090606/1244285675" )
  UnifiedHistory.create( title:         "report.eml",
                         path:          DEMO_DIR.join("draft.eml").to_s,
                         type:  "FileHistory",
                         start_time:    DateTime.new(2014, 4, 17, 13, 3, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(2014, 4, 17, 13, 10, 0, '+9') + (WEEK * n-1) )
  ##########################################################

  if(n == 7 || n == 15)
    t_mail = Task.create( name:        "レポートの提出確認",
                          description: "レポートの誤字脱字チェック",
                          deadline:    DateTime.new(2014, 4, 17, 17, 0, 0, '+9') + (WEEK * n-1),
                          keyword:     "メール 業務日誌",
                          mission_id:  m_lect.id,
                          state_id:    done.id )
    TimeEntry.create( name:       "レポートの提出確認",
                      keyword:    "レポート",
                      comment:    "提出状況表を作成",
                      start_time: DateTime.new(2014, 4, 17, 15, 0, 0, '+9') + (WEEK * n-1),
                      end_time: DateTime.new(2014, 4, 17, 15, 15, 0, '+9') + (WEEK * n-1),
                      task_id: t_mail.id)
    UnifiedHistory.create( title:         "submission_status.xlsx",
                           path:          DEMO_DIR.join("submission_status.xlsx").to_s,
                           type:  "FileHistory",
                           start_time:    DateTime.new(2014, 4, 17, 15, 10, 0, '+9') + (WEEK * n-1),
                           end_time:      DateTime.new(2014, 4, 17, 15, 15, 0, '+9') + (WEEK * n-1) )
    UnifiedHistory.create( title:         "09425601.pdf",
                           path:          DEMO_DIR.join("09425601.pdf").to_s,
                           type:  "FileHistory",
                           start_time:    DateTime.new(2014, 4, 17, 15, 0, 0, '+9') + (WEEK * n-1),
                           end_time:      DateTime.new(2014, 4, 17, 15, 2, 0, '+9') + (WEEK * n-1) )
    UnifiedHistory.create( title:         "09425602.pdf",
                           path:          DEMO_DIR.join("09425602.pdf").to_s,
                           type:  "FileHistory",
                           start_time:    DateTime.new(2014, 4, 17, 15, 2, 0, '+9') + (WEEK * n-1),
                           end_time:      DateTime.new(2014, 4, 17, 15, 4, 0, '+9') + (WEEK * n-1) )
    UnifiedHistory.create( title:         "09425603.pdf",
                           path:          DEMO_DIR.join("09425603.pdf").to_s,
                           type:  "FileHistory",
                           start_time:    DateTime.new(2014, 4, 17, 15, 4, 0, '+9') + (WEEK * n-1),
                           end_time:      DateTime.new(2014, 4, 17, 15, 6, 0, '+9') + (WEEK * n-1) )
    UnifiedHistory.create( title:         "09425604.pdf",
                           path:          DEMO_DIR.join("09425604.pdf").to_s,
                           type:  "FileHistory",
                           start_time:    DateTime.new(2014, 4, 17, 15, 6, 0, '+9') + (WEEK * n-1),
                           end_time:      DateTime.new(2014, 4, 17, 15, 8, 0, '+9') + (WEEK * n-1) )
    UnifiedHistory.create( title:         "09425605.pdf",
                           path:          DEMO_DIR.join("09425605.pdf").to_s,
                           type:  "FileHistory",
                           start_time:    DateTime.new(2014, 4, 17, 15, 8, 0, '+9') + (WEEK * n-1),
                           end_time:      DateTime.new(2014, 4, 17, 15, 10, 0, '+9') + (WEEK * n-1) )
  end

end
#---------------------------------------------------------------------
