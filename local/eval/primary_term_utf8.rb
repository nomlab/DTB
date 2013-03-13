# -*- coding:utf-8 -*-
# M1の研修会幹事の，4月から9月までの作業状態っぽいもの
require "csv"
require "kconv"

`rm db/development.sqlite3`
`touch db/development.sqlite3`
`rake db:migrate`

require "./config/environment"

FileUtils.rm_rf("repository")
FileUtils.rm_rf("app/assets/images/thumbnail")
Dir::mkdir("repository")
Dir::mkdir("app/assets/images/thumbnail")
Dir::chdir("repository"){
  FileUtils.touch "erase_me"
  `git init`
  repo = Grit::Repo.new "."
  new_blob = Grit::Blob.create(repo, {:name => "erase_me",
                                 :data => File.read("erase_me")})
  repo.add(new_blob.name.force_encoding(Encoding::Windows_31J))
  repo.commit_index "initial commit."
}

# * Ruby勉強会
Work.create(:name => "Ruby勉強会") # id: 1
  Task.create(:name => "スライド作成", :work_id => 1)
    Bookmark.create(:name => "スライド作成", :start_time => Time.parse("2011/04/15 16:00"), :end_time => Time.parse("2011/04/15 18:00"), :task_id => 1)
    Bookmark.create(:name => "スライド作成2", :start_time => Time.parse("2011/04/28 10:00"), :end_time => Time.parse("2011/04/28 12:00"), :task_id => 1)
    Bookmark.create(:name => "スライド作成3", :start_time => Time.parse("2011/05/13 10:00"), :end_time => Time.parse("2011/05/13 12:00"), :task_id => 1)
    Bookmark.create(:name => "スライド作成と統合", :start_time => Time.parse("2011/05/13 13:00"), :end_time => Time.parse("2011/05/13 19:00"), :task_id => 1)
  Task.create(:name => "会場の準備", :work_id => 1)
    Bookmark.create(:name => "Railsインストーラの準備", :start_time => Time.parse("2011/05/12 13:00"), :end_time => Time.parse("2011/05/12 14:00"), :task_id => 2)
    Bookmark.create(:name => "無線LANの設定", :start_time => Time.parse("2011/05/12 14:00"), :end_time => Time.parse("2011/05/12 16:00"), :task_id => 2)

# ソフトウェア開発法
Work.create(:name => "大学院の講義") # id: 2
  Work.create(:name => "ソフトウェア開発法", :parent_id => 2) # id: 3
    Task.create(:name => "練習問題", :work_id => 3)
      Bookmark.create(:name => "練習問題", :start_time => Time.parse("2011/04/15 12:00"), :end_time => Time.parse("2011/04/15 15:00"), :task_id => 3)
      Bookmark.create(:name => "練習問題のメール送信", :start_time => Time.parse("2011/04/18 17:00"), :end_time => Time.parse("2011/04/18 17:40"), :task_id => 3)
    Task.create(:name => "講義の議事録作成", :work_id => 3)
      Bookmark.create(:name => "議事録作成", :start_time => Time.parse("2011/04/27 16:00"), :end_time => Time.parse("2011/04/27 19:00"), :task_id => 4)
      Bookmark.create(:name => "議事録作成2", :start_time => Time.parse("2011/05/17 17:50"), :end_time => Time.parse("2011/05/17 20:00"), :task_id => 4)
      Bookmark.create(:name => "議事録作成3", :start_time => Time.parse("2011/06/08 10:00"), :end_time => Time.parse("2011/06/08 13:00"), :task_id => 4)
    Task.create(:name => "設計", :work_id => 3)
      Bookmark.create(:name => "システム業務化一覧作成", :start_time => Time.parse("2011/04/27 16:00"), :end_time => Time.parse("2011/04/27 19:00"), :task_id => 5)
      Bookmark.create(:name => "業務定義書作成", :start_time => Time.parse("2011/05/09 14:30"), :end_time => Time.parse("2011/05/09 16:00"), :task_id => 5)
      Bookmark.create(:name => "業務定義書修正", :start_time => Time.parse("2011/05/13 16:00"), :end_time => Time.parse("2011/05/13 17:00"), :task_id => 5)
      Bookmark.create(:name => "資料作成1", :start_time => Time.parse("2011/05/19 12:00"), :end_time => Time.parse("2011/05/19 20:00"), :task_id => 5)
      Bookmark.create(:name => "資料作成2", :start_time => Time.parse("2011/05/23 10:00"), :end_time => Time.parse("2011/05/23 11:00"), :task_id => 5)
      Bookmark.create(:name => "資料修正", :start_time => Time.parse("2011/05/23 15:00"), :end_time => Time.parse("2011/05/23 17:00"), :task_id => 5)
      Bookmark.create(:name => "資料作成3", :start_time => Time.parse("2011/06/10 13:00"), :end_time => Time.parse("2011/06/10 18:00"), :task_id => 5)
      Bookmark.create(:name => "資料修正2", :start_time => Time.parse("2011/06/13 18:00"), :end_time => Time.parse("2011/06/13 20:00"), :task_id => 5)
      Bookmark.create(:name => "プログラム内処理定義書の修正", :start_time => Time.parse("2011/06/20 17:50"), :end_time => Time.parse("2011/06/20 19:25"), :task_id => 5)
      Bookmark.create(:name => "資料作成4", :start_time => Time.parse("2011/06/27 16:00"), :end_time => Time.parse("2011/06/27 18:00"), :task_id => 5)
    Task.create(:name => "実装", :work_id => 3)
      Bookmark.create(:name => "実装", :start_time => Time.parse("2011/06/30 10:00"), :end_time => Time.parse("2011/06/30 12:00"), :task_id => 6)
      Bookmark.create(:name => "実装2", :start_time => Time.parse("2011/06/30 13:00"), :end_time => Time.parse("2011/06/30 19:00"), :task_id => 6)
      Bookmark.create(:name => "実装3", :start_time => Time.parse("2011/06/30 20:00"), :end_time => Time.parse("2011/06/30 23:00"), :task_id => 6)
      Bookmark.create(:name => "実装4", :start_time => Time.parse("2011/07/01 00:00"), :end_time => Time.parse("2011/07/01 05:00"), :task_id => 6)
    Task.create(:name => "テスト", :work_id => 3)
      Bookmark.create(:name => "テスト", :start_time => Time.parse("2011/07/08 13:00"), :end_time => Time.parse("2011/07/08 16:00"), :task_id => 7)
    Task.create(:name => "デバッグ", :work_id => 3)
      Bookmark.create(:name => "ソースコード修正", :start_time => Time.parse("2011/07/12 13:00"), :end_time => Time.parse("2011/07/12 19:00"), :task_id => 8)
      Bookmark.create(:name => "ソースコード修正2", :start_time => Time.parse("2011/07/25 11:30"), :end_time => Time.parse("2011/07/25 12:00"), :task_id => 8)
    Task.create(:name => "その他", :work_id => 3)
      Bookmark.create(:name => "ソースコード提出", :start_time => Time.parse("2011/06/30 13:00"), :end_time => Time.parse("2011/06/30 17:00"), :task_id => 9)

  Work.create(:name => "システムプログラミング特論", :parent_id => 2)
    Task.create(:name => "紹介論文の選定", :work_id => 4)
      Bookmark.create(:name => "論文選び", :start_time => Time.parse("2011/04/21 12:00"), :end_time => Time.parse("2011/04/21 16:00"), :task_id => 10)
    Task.create(:name => "発表の準備", :work_id => 4)
      Bookmark.create(:name => "スライド作成1", :start_time => Time.parse("2011/06/05 00:00"), :end_time => Time.parse("2011/06/05 05:00"), :task_id => 11)
      Bookmark.create(:name => "スライド作成2", :start_time => Time.parse("2011/06/06 08:00"), :end_time => Time.parse("2011/06/06 24:00"), :task_id => 11)
      Bookmark.create(:name => "スライド作成3", :start_time => Time.parse("2011/06/07 00:00"), :end_time => Time.parse("2011/06/07 05:00"), :task_id => 11)
    Task.create(:name => "講義後の感想メール", :work_id => 4)
      Bookmark.create(:name => "感想提出", :start_time => Time.parse("2011/05/26 10:00"), :end_time => Time.parse("2011/05/26 13:00"), :task_id => 12)
      Bookmark.create(:name => "感想提出(6月15)", :start_time => Time.parse("2011/06/15 14:30"), :end_time => Time.parse("2011/06/15 16:00"), :task_id => 12)
      Bookmark.create(:name => "感想提出(6月22)", :start_time => Time.parse("2011/06/22 10:00"), :end_time => Time.parse("2011/06/22 12:00"), :task_id => 12)
      Bookmark.create(:name => "感想提出(7月12)", :start_time => Time.parse("2011/07/12 12:00"), :end_time => Time.parse("2011/07/12 13:00"), :task_id => 12)

  Work.create(:name => "プログラミング方法論", :parent_id => 2)
    Task.create(:name => "プロポーザルの作成", :work_id => 5)  
      Bookmark.create(:name => "プロポーザルの作成1", :start_time => Time.parse("2011/04/18 14:00"), :end_time => Time.parse("2011/04/18 18:00"), :task_id => 13)
      Bookmark.create(:name => "プロポーザルの作成2", :start_time => Time.parse("2011/04/19 10:00"), :end_time => Time.parse("2011/04/19 13:00"), :task_id => 13)
      Bookmark.create(:name => "プロポーザルの修正", :start_time => Time.parse("2011/04/25 10:00"), :end_time => Time.parse("2011/04/25 13:00"), :task_id => 13)
    Task.create(:name => "発表準備", :work_id => 5)
      Bookmark.create(:name => "スライド作成", :start_time => Time.parse("2011/04/28 10:00"), :end_time => Time.parse("2011/04/28 14:00"), :task_id => 14)
      Bookmark.create(:name => "スライド作成2", :start_time => Time.parse("2011/05/11 13:00"), :end_time => Time.parse("2011/05/11 18:00"), :task_id => 14)
      Bookmark.create(:name => "スライド修正", :start_time => Time.parse("2011/05/12 16:00"), :end_time => Time.parse("2011/05/12 20:00"), :task_id => 14)
    Task.create(:name => "質問への回答", :work_id => 5)
      Bookmark.create(:name => "質問への回答作成", :start_time => Time.parse("2011/06/14 17:50"), :end_time => Time.parse("2011/06/14 21:30"), :task_id => 15)
      Bookmark.create(:name => "質問への回答作成2", :start_time => Time.parse("2011/06/21 14:00"), :end_time => Time.parse("2011/06/21 19:00"), :task_id => 15)
    Task.create(:name => "議事録の作成", :work_id => 5)
      Bookmark.create(:name => "議事録作成", :start_time => Time.parse("2011/04/20 14:30"), :end_time => Time.parse("2011/04/20 16:00"), :task_id => 16)
      Bookmark.create(:name => "議事録作成2", :start_time => Time.parse("2011/04/27 14:30"), :end_time => Time.parse("2011/04/27 16:30"), :task_id => 16)

Work.create(:name => "GN検討打合せ")
  Work.create(:name => "第78回", :parent_id => 6)
    Task.create(:name => "資料作成", :work_id => 7)
      Bookmark.create(:name => "資料作成", :start_time => Time.parse("2011/04/20 10:00"), :end_time => Time.parse("2011/04/20 11:30"), :task_id => 17)
      Bookmark.create(:name => "資料作成2", :start_time => Time.parse("2011/04/20 14:30"), :end_time => Time.parse("2011/04/20 18:00"), :task_id => 17)
      Bookmark.create(:name => "資料作成3", :start_time => Time.parse("2011/04/21 10:00"), :end_time => Time.parse("2011/04/21 12:30"), :task_id => 17)
  Work.create(:name => "第79回", :parent_id => 6)
    Task.create(:name => "資料作成", :work_id => 8)
      Bookmark.create(:name => "資料作成", :start_time => Time.parse("2011/05/09 10:00"), :end_time => Time.parse("2011/05/09 12:30"), :task_id => 18)
    Task.create(:name => "議事録", :work_id => 8)
      Bookmark.create(:name => "議事録作成", :start_time => Time.parse("2011/05/10 17:00"), :end_time => Time.parse("2011/05/10 20:00"), :task_id => 19)
      Bookmark.create(:name => "議事録作成2", :start_time => Time.parse("2011/05/11 10:00"), :end_time => Time.parse("2011/05/11 12:00"), :task_id => 19)
      Bookmark.create(:name => "議事録修正", :start_time => Time.parse("2011/05/11 18:30"), :end_time => Time.parse("2011/05/11 19:34"), :task_id => 19)
  Work.create(:name => "第81回", :parent_id => 6)
    Task.create(:name => "議事録", :work_id => 9)
      Bookmark.create(:name => "議事録作成", :start_time => Time.parse("2011/06/09 14:00"), :end_time => Time.parse("2011/06/09 19:00"), :task_id => 20)
  Work.create(:name => "第83回", :parent_id => 6)
    Task.create(:name => "議事録", :work_id => 10)
      Bookmark.create(:name => "議事録作成", :start_time => Time.parse("2011/07/13 14:30"), :end_time => Time.parse("2011/04/13 17:00"), :task_id => 21)
  Work.create(:name => "第85回", :parent_id => 6)
    Task.create(:name => "議事録", :work_id => 11)
      Bookmark.create(:name => "議事録作成", :start_time => Time.parse("2011/08/23 10:00"), :end_time => Time.parse("2011/08/23 12:30"), :task_id => 22)
=begin
* GN開発打合せ
  2011/04/21 17:00 - 19:30 LastNote開発(第37回GN開発打合せ)
  2011/04/22 12:30 - 15:30 LastNote開発(第38回GN開発打合せ)
  2011/05/16 10:00 - 12:40 LastNote開発(第39回GN開発打合せ)
=end
Work.create(:name => "計算機幹事")
  Task.create(:name => "議事録作成", :work_id => 12)
    Bookmark.create(:name => "議事録作成", :start_time => Time.parse("2011/06/08 12:00"), :end_time => Time.parse("2011/06/08 15:00"), :task_id => 23)

Work.create(:name => "研修会運営") # id: 13
  Task.create(:name => "出欠確認", :work_id => 13)
    Bookmark.create(:name => "研修会の出欠確認", :start_time => Time.parse("2011/05/29 08:30"), :end_time => Time.parse("2011/05/29 09:30"), :task_id => 24)
  Task.create(:name => "食物アレルギーの調査", :work_id => 13)
    Bookmark.create(:name => "研修会前の食物アレルギーの調査", :start_time => Time.parse("2011/06/13 17:00"), :end_time => Time.parse("2011/06/13 18:00"), :task_id => 25)
  Task.create(:name => "談話会についての連絡", :work_id => 13)
    Bookmark.create(:name => "談話会の一品についてのメール送信", :start_time => Time.parse("2011/07/18 15:00"), :end_time => Time.parse("2011/07/18 15:40"), :task_id => 26)
  Task.create(:name => "反省会", :work_id => 13)
    Bookmark.create(:name => "反省会の議事録作成", :start_time => Time.parse("2011/08/31 12:30"), :end_time => Time.parse("2011/08/31 13:00"), :task_id => 27)
  Work.create(:name => "会場と日程の決定", :parent_id => 13)
    Work.create(:name => "会場の決定", :parent_id => 14)
      Task.create(:name => "会場の候補選び", :work_id => 15)
        Bookmark.create(:name => "研修会会場の候補選び", :start_time => Time.parse("2011/04/25 15:00"), :end_time => Time.parse("2011/04/25 17:00"), :task_id => 28)
  Work.create(:name => "下見", :parent_id => 13)
    Task.create(:name => "写真と録音データの共有", :work_id => 16)    
      Bookmark.create(:name => "下見の写真と録音データの置き場について連絡", :start_time => Time.parse("2011/05/14 10:00"), :end_time => Time.parse("2011/05/14 11:00"), :task_id => 29)

  Work.create(:name => "研修の準備", :parent_id => 13)
    Work.create(:name => "研究発表", :parent_id => 17)
      Task.create(:name => "発表希望者の調査", :work_id => 18)
        Bookmark.create(:name => "発表希望者の確認メールの送信", :start_time => Time.parse("2011/05/29 08:30"), :end_time => Time.parse("2011/05/29 09:30"), :task_id => 30)
    Work.create(:name => "ディベート", :parent_id => 17)
      Task.create(:name => "ディベートテーマ案の募集", :work_id => 19)
        Bookmark.create(:name => "ディベートの準備(テーマ案の募集)", :start_time => Time.parse("2011/07/04 10:00"), :end_time => Time.parse("2011/07/04 10:40"), :task_id => 31)
      Task.create(:name => "テーマ案の査定", :work_id => 19)
        Bookmark.create(:name => "テーマ案の査定", :start_time => Time.parse("2011/07/17 10:00"), :end_time => Time.parse("2011/07/17 12:00"), :task_id => 32)
      Task.create(:name => "投票の告知", :work_id => 19)
        Bookmark.create(:name => "テーマ案の投票通知", :start_time => Time.parse("2011/07/18 11:00"), :end_time => Time.parse("2011/07/18 11:20"), :task_id => 33)
      Task.create(:name => "投票結果の報告", :work_id => 19)
        Bookmark.create(:name => "投票結果の通知メールの送信", :start_time => Time.parse("2011/07/30 16:00"), :end_time => Time.parse("2011/07/30 17:00"), :task_id => 34)
  Work.create(:name => "レクリエーションの準備", :parent_id => 13)
    Work.create(:name => "晴天時の準備", :parent_id => 20)
      Task.create(:name => "ルール作成", :work_id => 21)
        Bookmark.create(:name => "レクリエーションのルール作成", :start_time => Time.parse("2011/08/01 10:00"), :end_time => Time.parse("2011/08/01 11:00"), :task_id => 35)
      Task.create(:name => "用具の確保", :work_id => 21)
        Bookmark.create(:name => "用具の確保", :start_time => Time.parse("2011/05/22 10:00"), :end_time => Time.parse("2011/05/22 12:00"), :task_id => 36)
    Work.create(:name => "雨天時の準備", :parent_id => 20)
      Task.create(:name => "クイズ問題の作成依頼", :work_id => 22)
        Bookmark.create(:name => "クイズの作成依頼", :start_time => Time.parse("2011/07/07 17:00"), :end_time => Time.parse("2011/07/07 17:30"), :task_id => 37)
      Task.create(:name => "クイズ問題の統合", :work_id => 22)
        Bookmark.create(:name => "クイズ問題の統合", :start_time => Time.parse("2011/08/25 10:00"), :end_time => Time.parse("2011/08/25 14:00"), :task_id => 38)
  Task.create(:name => "しおりの作成", :work_id => 13)
    Bookmark.create(:name => "しおりの草案作成", :start_time => Time.parse("2011/06/29 10:00"), :end_time => Time.parse("2011/06/29 14:00"), :task_id => 39)
    Bookmark.create(:name => "しおりの草案作成2", :start_time => Time.parse("2011/06/29 14:30"), :end_time => Time.parse("2011/06/29 16:00"), :task_id => 39)
    Bookmark.create(:name => "しおり草案修正", :start_time => Time.parse("2011/07/03 14:00"), :end_time => Time.parse("2011/07/03 14:30"), :task_id => 39)
    Bookmark.create(:name => "しおり草案修正2", :start_time => Time.parse("2011/07/06 17:30"), :end_time => Time.parse("2011/07/06 18:00"), :task_id => 39)
    Bookmark.create(:name => "しおりの修正(ディベートについて)", :start_time => Time.parse("2011/07/30 17:00"), :end_time => Time.parse("2011/07/30 17:20"), :task_id => 39)
    Bookmark.create(:name => "しおりの修正(部屋割り，必要機材)", :start_time => Time.parse("2011/08/07 12:00"), :end_time => Time.parse("2011/08/07 14:00"), :task_id => 39)
    Bookmark.create(:name => "しおりの修正(旅程)", :start_time => Time.parse("2011/08/21 09:00"), :end_time => Time.parse("2011/08/21 10:00"), :task_id => 39)
    Bookmark.create(:name => "しおりの配布について連絡", :start_time => Time.parse("2011/08/22 17:00"), :end_time => Time.parse("2011/08/22 17:30"), :task_id => 39)
    Bookmark.create(:name => "しおりの修正(チーム分け)", :start_time => Time.parse("2011/08/23 10:00"), :end_time => Time.parse("2011/08/23 11:00"), :task_id => 39)
    Bookmark.create(:name => "しおりの修正(旅程，研修内容)", :start_time => Time.parse("2011/08/24 14:30"), :end_time => Time.parse("2011/08/24 15:30"), :task_id => 39)
  Work.create(:name => "会計関係", :parent_id => 13)
    Task.create(:name => "見積書の作成", :work_id => 23)
      Bookmark.create(:name => "研修会の見積もりの作成", :start_time => Time.parse("2011/07/23 09:00"), :end_time => Time.parse("2011/07/23 10:30"), :task_id => 40)
    Task.create(:name => "領収書の内訳報告", :work_id => 23)
      Bookmark.create(:name => "研修会の領収書の内訳作成", :start_time => Time.parse("2011/08/31 11:00"), :end_time => Time.parse("2011/08/31 12:00"), :task_id => 41)
    Task.create(:name => "会計幹事に明細を報告", :work_id => 23)
      Bookmark.create(:name => "研修会の明細を会見幹事に報告", :start_time => Time.parse("2011/08/31 12:00"), :end_time => Time.parse("2011/08/31 12:30"), :task_id => 42)
    Work.create(:name => "補助金", :parent_id => 23)
      Task.create(:name => "研修会の参加者名簿の作成", :work_id => 24)
        Bookmark.create(:name => "研修会参加者名簿の作成", :start_time => Time.parse("2011/09/14 10:00"), :end_time => Time.parse("2011/09/14 12:00"), :task_id => 43)
      Task.create(:name => "補助金の受け取り", :work_id => 24)
        Bookmark.create(:name => "研修会の補助金の受け取り", :start_time => Time.parse("2011/11/14 14:30"), :end_time => Time.parse("2011/11/14 15:00"), :task_id => 44)
      Task.create(:name => "補助金の返還", :work_id => 24)
        Bookmark.create(:name => "研修会の補助金の返金連絡", :start_time => Time.parse("2011/11/19 14:00"), :end_time => Time.parse("2011/11/19 15:00"), :task_id => 45)


####################################
# 履歴情報の登録
History

# dir = WindowsLibs.make_path(["c:","Users","Fukuda", "Dropbox", "DTBの評価", "files"])
dir = File.dirname(File.expand_path(__FILE__))+"/files"
Dir::chdir(dir){
  bm = Bookmark.find_by_name "研修会の出欠確認"
  h = FileHistory.create(:path => dir+"/2012年度研修会の出欠と発表希望者の確認.txt",
                        :title => "2012年度研修会の出欠と発表希望者の確認.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
 
  bm = Bookmark.find_by_name "研修会前の食物アレルギーの調査"
  h = FileHistory.create(:path => dir+"/食物アレルギーの調査.txt", 
                         :title => "食物アレルギーの調査.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)

  bm = Bookmark.find_by_name "談話会の一品についてのメール送信"
  h = FileHistory.create(:path => dir+"/研修会の一品について.txt",
                        :title => "研修会の一品について.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  

  bm = Bookmark.find_by_name "反省会の議事録作成"
  h = FileHistory.create(:path => dir+"/2012年度研修会の反省報告.txt",
                         :title => "2012年度研修会の反省報告.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  
  
  bm = Bookmark.find_by_name "研修会会場の候補選び"
  #  h = FileHistory.create(:path => dir+"",
  #                        :title => "")
  #  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  
  
  bm = Bookmark.find_by_name "下見の写真と録音データの置き場について連絡"
#  h = FileHistory.create(:path => dir+"",
#                         :title => "")
#  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  
  
  bm = Bookmark.find_by_name "発表希望者の確認メールの送信"
  h = FileHistory.create(:path => dir+"/2012年度研修会の出欠と発表希望者の確認.txt",
                        :title => "2012年度研修会の出欠と発表希望者の確認.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  
 
 bm = Bookmark.find_by_name "ディベートの準備(テーマ案の募集)"
  h = FileHistory.create(:path => dir+"/ディベート/ディベートのテーマについて.txt",
                        :title => "ディベートのテーマについて.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  
  bm = Bookmark.find_by_name "テーマ案の投票通知"
  h = FileHistory.create(:path => dir+"/ディベート/研修会におけるディベートテーマの投票.txt",
                         :title => "研修会におけるディベートテーマの投票.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  

  bm = Bookmark.find_by_name "投票結果の通知メールの送信"
  h = FileHistory.create(:path => dir+"/ディベート/研修会におけるディベートテーマ案の投票結果について.txt",
                        :title => "研修会におけるディベートテーマ案の投票結果について.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  
  
  bm = Bookmark.find_by_name "レクリエーションのルール作成"
  h = FileHistory.create(:path => dir+"/レクリエーション/レクリエーションのルール案.txt",
                         :title => "レクリエーションのルール案.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  
  bm = Bookmark.find_by_name "用具の確保"
  h = FileHistory.create(:path => dir+"/レクリエーション/研修会に関する借用物について.txt",
                         :title => "研修会に関する借用物について.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  
  bm = Bookmark.find_by_name "クイズの作成依頼"
  h = FileHistory.create(:path => dir+"/レクリエーション/研修会で利用するクイズの作成のお願い.txt",
                         :title => "研修会で利用するクイズの作成のお願い.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  
  
  bm = Bookmark.find_by_name "クイズ問題の統合"
  h = FileHistory.create(:path => dir+"/レクリエーション/研修会のクイズ.txt",
                         :title => "研修会のクイズ.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  h = FileHistory.create(:path => dir+"/レクリエーション/研修会のクイズ問題.pdf",
                         :title => "研修会のクイズ問題.pdf")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  
  
  bm = Bookmark.find_by_name "しおりの草案作成"
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り1/研修会のしおりについて.txt",
                         :title => "研修会のしおりについて.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り1/2012年度研修会のしおり.doc",
                         :title => "2012年度研修会のしおり.doc")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り1/2012年度研修会のしおり.pdf",
                         :title => "2012年度研修会のしおり.pdf")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  
  
  bm = Bookmark.find_by_name "しおりの草案作成2"
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り2/研修会のしおり(案2)について.txt",
                         :title => "研修会のしおり(案2)について.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り2/2012年度研修会のしおり(案2).doc",
                         :title => "2012年度研修会のしおり(案2).doc")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り2/2012年度研修会のしおり(案2).pdf",
                         :title => "2012年度研修会のしおり(案2).pdf")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  
  
  bm = Bookmark.find_by_name "しおり草案修正"
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り3/研修会のしおり(案3)について.txt",
                         :title => "研修会のしおり(案3)について.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り3/2012年度研修会のしおり(案3).doc",
                         :title => "2012年度研修会のしおり(案3).doc")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り3/2012年度研修会のしおり(案3).pdf",
                         :title => "2012年度研修会のしおり(案3).pdf")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  
  bm = Bookmark.find_by_name "しおりの修正(ディベートについて)"
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り4/研修会のしおり(案4)について.txt",
                       :title => "研修会のしおり(案4)について.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り4/2012年度研修会のしおり(案4).doc",
                       :title => "2012年度研修会のしおり(案4).doc")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り4/2012年度研修会のしおり(案4).pdf",
                       :title => "2012年度研修会のしおり(案4).pdf")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  

  bm = Bookmark.find_by_name "しおりの修正(部屋割り，必要機材)"
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り5/2012年度研修会のしおり(8月7日).txt",
                        :title => "2012年度研修会のしおり(8月7日).txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り5/2012年度研修会のしおり-20120807.doc",
                        :title => "2012年度研修会のしおり-20120807.doc")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  

  bm = Bookmark.find_by_name "しおりの修正(旅程)"
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り6/2012年度研修会のしおり(8月21日).txt",
                        :title => "2012年度研修会のしおり(8月21日).txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り6/2012年度研修会のしおり-20120821.doc",
                        :title => "2012年度研修会のしおり-20120821.doc")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  

  bm = Bookmark.find_by_name "しおりの配布について連絡"
  h = FileHistory.create(:path => dir+"/しおりの作成/しおりの配布について.txt",
                        :title => "しおりの配布について.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  

  bm = Bookmark.find_by_name "しおりの修正(チーム分け)"
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り7/2012年度研修会のしおり(8月23日).txt",
                        :title => "2012年度研修会のしおり(8月23日).txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り7/2012年度研修会のしおり-20120823.doc",
                        :title => "2012年度研修会のしおり-20120823.doc")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  

  bm = Bookmark.find_by_name "しおりの修正(旅程，研修内容)"
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り8/2012年度研修会のしおり(8月24日).txt",
                        :title => "2012年度研修会のしおり(8月24日).txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  h = FileHistory.create(:path => dir+"/しおりの作成/しおり作り8/2012年度研修会のしおり-20120824.doc",
                        :title => "2012年度研修会のしおり-20120824.doc")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  

  bm = Bookmark.find_by_name "研修会の見積もりの作成"
  h = FileHistory.create(:path => dir+"/会計関連/見積書の作成/2012年度研修会の見積書.txt",
                         :title => "2012年度研修会の見積書.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  h = FileHistory.create(:path => dir+"/会計関連/見積書の作成/2012年度研修会-見積(仮).pdf",
                         :title => "2012年度研修会-見積(仮).pdf")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  

  bm = Bookmark.find_by_name "研修会の領収書の内訳作成"
  h = FileHistory.create(:path => dir+"/会計関連/領収書の内訳報告/2012年度研修会の領収書に関して.txt",
                        :title => "")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  

  bm = Bookmark.find_by_name "研修会の明細を会見幹事に報告"
  h = FileHistory.create(:path => dir+"/会計関連/明細/2012年度研修会の明細.txt",
                        :title => "2012年度研修会の明細.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  

  bm = Bookmark.find_by_name "研修会参加者名簿の作成"
  h = FileHistory.create(:path => dir+"/会計関連/研修会費の返還/2012年度研修会参加者名簿.xls",
                        :title => "2012年度研修会参加者名簿.xls")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  

  bm = Bookmark.find_by_name "研修会の補助金の受け取り"
  h = FileHistory.create(:path => dir+"/会計関連/研修会費の返還/研修会の補助金の受け取り.txt",
                        :title => "研修会の補助金の受け取り.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
  

  bm = Bookmark.find_by_name "研修会の補助金の返金連絡"
  h = FileHistory.create(:path => dir+"/会計関連/研修会費の返還/研修会費の返金のご連絡.txt",
                         :title => "研修会費の返金のご連絡.txt")
  Timeline.create(:bookmark_id => bm.id, :history_id => h.id)
}


Task.find(32).destroy
