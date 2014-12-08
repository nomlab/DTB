# -*- coding: utf-8 -*-
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

m_p2 = Mission.create( name:        "プログラミング演習TA",
                       description: "プログラミング演習TAに関する業務",
                       deadline:    DateTime.new(2014, 7, 28, 0, 0, 0, '+9'),
                       keyword:     "p2 TA",
                       parent_id:   0, # root mission
                       state_id:    todo.id)

m_record = Mission.create( name:        "成績採点補助",
                           description: "プログラミング演習TA中の成績採点補助に関する業務",
                           deadline:    DateTime.new(2014, 7, 25, 0, 0, 0, '+9'),
                           keyword:     "p2 TA 成績",
                           parent_id:   m_p2.id,
                           state_id:    todo.id)
t_table = Task.create( name:        "出欠確認表作成",
                       description: "出欠確認表作成業務",
                       deadline:    DateTime.new(2014, 7, 20, 0, 0, 0, '+9'),
                       keyword:     "成績",
                       mission_id:  m_record.id,
                       state_id:    todo.id )
TimeEntry.create( name:       "出欠確認表作成",
                  keyword:    "確認表 xlsx",
                  comment:    "もれが発生しないよう他のTAと協調作業すること",
                  start_time: DateTime.new(2014, 7, 17, 10, 0, 0, '+9'),
                  end_time: DateTime.new(2014, 7, 17, 11, 30, 0, '+9'),
                  task_id: t_table.id)
TimeEntry.create( name:       "出欠確認表作成",
                  keyword:    "確認表 xlsx",
                  comment:    "もれが発生しないよう他のTAと協調作業すること",
                  start_time: DateTime.new(2014, 7, 19, 13, 0, 0, '+9'),
                  end_time: DateTime.new(2014, 7, 19, 15, 10, 0, '+9'),
                  task_id: t_table.id)
TimeEntry.create( name:       "出欠確認表作成",
                  keyword:    "確認表 xlsx",
                  comment:    "もれが発生しないよう他のTAと協調作業すること",
                  start_time: DateTime.new(2014, 7, 20, 17, 20, 0, '+9'),
                  end_time: DateTime.new(2014, 7, 20, 18, 0, 0, '+9'),
                  task_id: t_table.id)

t_report = Task.create( name:        "レポート提出チェック",
                       description: "レポート提出チェック業務",
                       deadline:    DateTime.new(2014, 7, 25, 0, 0, 0, '+9'),
                       keyword:     "レポート",
                       mission_id:  m_record.id,
                        state_id:    todo.id )
TimeEntry.create( name:       "中間レポートチェック",
                  keyword:    "xlsx pdf",
                  comment:    "もれが発生しないよう他のTAと協調作業すること",
                  start_time: DateTime.new(2014, 7, 24, 10, 0, 0, '+9'),
                  end_time: DateTime.new(2014, 7, 24, 11, 30, 0, '+9'),
                  task_id: t_report.id)
TimeEntry.create( name:       "期末レポートチェック",
                  keyword:    "xlsx pdf",
                  comment:    "もれが発生しないよう他のTAと協調作業すること",
                  start_time: DateTime.new(2014, 7, 25, 15, 0, 0, '+9'),
                  end_time: DateTime.new(2014, 7, 25, 17, 0, 0, '+9'),
                  task_id: t_report.id)

(1..15).each do |n|
  m_lect = Mission.create( name:        "第#{n}回講義に関する業務",
                           description: "プログラミング演習TAの第#{n}回講義に関する業務",
                           deadline:    DateTime.new(2014, 4, 17, 0, 0, 0, '+9') + (WEEK * n-1),
                           keyword:     "p2 TA 講義",
                           parent_id:   m_p2.id,
                           state_id:    done.id )

  t_prepare_lect = Task.create( name:        "講義準備",
                                description: "講義準備業務",
                                deadline:    DateTime.new(2014, 4, 17, 8, 40, 0, '+9') + (WEEK * n-1),
                                keyword:     "準備 講義",
                                mission_id:  m_lect.id,
                                state_id:    done.id )

  TimeEntry.create( name:       "講義準備",
                    keyword:    "講義",
                    comment:    "プロジェクタをつけ忘れないこと",
                    start_time: DateTime.new(2014, 4, 17, 8, 30, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(2014, 4, 17, 8, 40, 0, '+9') + (WEEK * n-1),
                    task_id: t_prepare_lect.id)

  t_shuttle = Task.create( name:        "シャトルシート配布",
                           description: "シャトルシート配布業務",
                           deadline:    DateTime.new(2014, 4, 17, 9, 0, 0, '+9') + (WEEK * n-1),
                           keyword:     "シャトルシート",
                           mission_id:  m_lect.id,
                           state_id:    done.id )
  TimeEntry.create( name:       "シャトルシート配布",
                    keyword:    "シャトルシート",
                    comment:    "2回配る事もあるので気をつける",
                    start_time: DateTime.new(2014, 4, 17, 8, 50, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(2014, 4, 17, 8, 55, 0, '+9') + (WEEK * n-1),
                    task_id: t_shuttle.id,)


  t_check = Task.create( name:        "講義資料確認",
                         description: "講義資料確認業務",
                         deadline:    DateTime.new(2014, 4, 17, 11, 55, 0, '+9') + (WEEK * n-1),
                         keyword:     "講義資料",
                         mission_id:  m_lect.id,
                         state_id:    done.id )
  TimeEntry.create( name:       "講義資料確認",
                    keyword:    "講義資料",
                    comment:    "誤字脱字をチェックする",
                    start_time: DateTime.new(2014, 4, 17, 8, 40, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(2014, 4, 17, 8, 50, 0, '+9') + (WEEK * n-1),
                    task_id: t_check.id)

  t_assist_teach = Task.create( name:        "学生への指導補助",
                                description: "学生への指導補助業務",
                                deadline:    DateTime.new(2014, 4, 17, 11, 55, 0, '+9') + (WEEK * n-1),
                                keyword:     "質問 回答",
                                mission_id:  m_lect.id,
                                state_id:    done.id )
  TimeEntry.create( name:       "学生への指導補助",
                    keyword:    "指導 質問",
                    comment:    "学生からの質問内容はメモしておく",
                    start_time: DateTime.new(2014, 4, 17, 8, 55, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(2014, 4, 17, 10, 10, 0, '+9') + (WEEK * n-1),
                    task_id: t_assist_teach.id)
  TimeEntry.create( name:       "学生への指導補助",
                    keyword:    "指導 質問",
                    comment:    "学生からの質問内容はメモしておく",
                    start_time: DateTime.new(2014, 4, 17, 10, 25, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(2014, 4, 17, 11, 50, 0, '+9') + (WEEK * n-1),
                    task_id: t_assist_teach.id)

  t_collect = Task.create( name:        "シャトルシートの回収",
                           description: "シャトルシートの回収業務",
                           deadline:    DateTime.new(2014, 4, 17, 11, 55, 0, '+9') + (WEEK * n-1),
                           keyword:     "シャトルシート",
                           mission_id:  m_lect.id,
                           state_id:    done.id )
  TimeEntry.create( name:       "シャトルシートの回収",
                    keyword:    "シャトルシート",
                    comment:    "特になし",
                    start_time: DateTime.new(2014, 4, 17, 11, 50, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(2014, 4, 17, 11, 55, 0, '+9') + (WEEK * n-1),
                    task_id: t_collect.id)

  t_clear = Task.create( name:        "講義片付け",
                         description: "講義片付け業務",
                         deadline:    DateTime.new(2014, 4, 17, 11, 55, 0, '+9') + (WEEK * n-1),
                         keyword:     "片付け ホワイトボード",
                         mission_id:  m_lect.id,
                         state_id:    done.id )
  TimeEntry.create( name:       "講義片付け",
                    keyword:    "ホワイトボード",
                    comment:    "ホワイトボードは消し忘れやすいので注意",
                    start_time: DateTime.new(2014, 4, 17, 11, 55, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(2014, 4, 17, 12, 0, 0, '+9') + (WEEK * n-1),
                    task_id: t_clear.id)

  t_data = Task.create( name:        "シャトルシートデータ化",
                        description: "シャトルシートデータ化業務",
                        deadline:    DateTime.new(2014, 4, 17, 12, 30, 0, '+9') + (WEEK * n-1),
                        keyword:     "シャトルシート データ化 pdf",
                        mission_id:  m_lect.id,
                        state_id:    done.id )
  TimeEntry.create( name:       "シャトルシートデータ化",
                    keyword:    "シャトルシート pdf",
                    comment:    "スキャナの電気を消し忘れないように",
                    start_time: DateTime.new(2014, 4, 17, 13, 0, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(2014, 4, 17, 13, 10, 0, '+9') + (WEEK * n-1),
                    task_id: t_data.id)

  t_mail = Task.create( name:        "業務日誌送信",
                        description: "業務日誌送信業務",
                        deadline:    DateTime.new(2014, 4, 17, 17, 0, 0, '+9') + (WEEK * n-1),
                        keyword:     "メール 業務日誌",
                        mission_id:  m_lect.id,
                        state_id:    done.id )
  TimeEntry.create( name:       "業務日誌送信",
                    keyword:    "メール",
                    comment:    "書いてないことをメールの冒頭に書かないこと",
                    start_time: DateTime.new(2014, 4, 17, 13, 0, 0, '+9') + (WEEK * n-1),
                    end_time: DateTime.new(2014, 4, 17, 13, 10, 0, '+9') + (WEEK * n-1),
                    task_id: t_mail.id)
  UnifiedHistory.create( title:         "draft.org",
                         path:          DEMO_DIR.join("draft.org").to_s,
                         history_type:  "file_history",
                         start_time:    DateTime.new(2014, 4, 17, 13, 0, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(2014, 4, 17, 13, 5, 0, '+9') + (WEEK * n-1) )
  UnifiedHistory.create( title:         "Org-mode による HTML 文書作成入門",
                         path:          "http://www.geocities.jp/km_pp1/org-mode/org-mode-document.html",
                         history_type:  "web_history",
                         start_time:    DateTime.new(2014, 4, 17, 13, 5, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(2014, 4, 17, 13, 6, 0, '+9') + (WEEK * n-1),
                         thumbnail:     "http://capture.heartrails.com/200x150/shadow?http://www.geocities.jp/km_pp1/org-mode/org-mode-document.html" )
  UnifiedHistory.create( title:         "org-mode + remember-mode で挿入される日付フォーマットを変更するには",
                         path:          "http://d.hatena.ne.jp/kyagi/20090606/1244285675",
                         history_type:  "web_history",
                         start_time:    DateTime.new(2014, 4, 17, 13, 6, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(2014, 4, 17, 13, 8, 0, '+9') + (WEEK * n-1),
                         thumbnail:     "http://capture.heartrails.com/200x150/shadow?http://d.hatena.ne.jp/kyagi/20090606/1244285675" )
  UnifiedHistory.create( title:         "report.eml",
                         path:          DEMO_DIR.join("draft.eml").to_s,
                         history_type:  "file_history",
                         start_time:    DateTime.new(2014, 4, 17, 13, 8, 0, '+9') + (WEEK * n-1),
                         end_time:      DateTime.new(2014, 4, 17, 13, 10, 0, '+9') + (WEEK * n-1) )
end
#---------------------------------------------------------------------
