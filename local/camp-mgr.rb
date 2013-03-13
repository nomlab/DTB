# -*- coding: utf-8 -*-
# CSVファイルを読み込んで，仕事・作業・作業状態を登録するスクリプト．
# CSVの書式：仕事,仕事(中),仕事(小),作業
# 例1：研修会運営,会場の決定,,候補の選定
# 例2：研修会運営,研修内容の決定,研究発表,発表者の募集

require "csv"
require "kconv"

def valid_argument?
  (ARGV[0].to_s =~ /\.csv/) ? true : false
end

# main
unless valid_argument?
  puts "please specify CSV file at first argument."
  exit
end

`rm db/development.sqlite3`
`touch db/development.sqlite3`
`rake db:migrate`

require "./config/environment"

# clear repository
FileUtils.rm_rf("repository")
Dir::mkdir("repository") rescue nil
Dir::chdir("repository"){
  FileUtils.touch "erase_me"
  `git init`
  repo = Grit::Repo.new "."
  new_blob = Grit::Blob.create(repo, {:name => "erase_me",
                                 :data => File.read("erase_me")})
  repo.add(new_blob.name.force_encoding(Encoding::Windows_31J))
  repo.commit_index "initial commit."
}

csv = File.open(ARGV[0], "r")
source = csv.read
csv.close

source = source.toutf8.gsub(/\r?\n/, "\n")
parsed_source = CSV.parse(source)
parsed_source.delete_at(0)

parsed_source.each do |source|
  print "--- #{source} ---\n"
  name1, name2, name3, name4 = source
  parent = nil
  # parent work
  unless work1 = Work.find_by_name(name1)
    work1 = Work.create(:name => name1)
  end
  parent = work1
  # 1st child work
  if !(name2.blank?) && !(work2 = Work.find_by_name(name2))
    work2 = Work.create(:name => name2, :parent_id => parent.id)
  end
  parent = work2 if name2 
  # 2nd child work
  if !(name3.blank?) && !(work3 = Work.find_by_name(name3))
    work3 = Work.create(:name => name3, :parent_id => parent.id)
  end
  parent = work3 if name3
  # task
  if !(name4.blank?) && !(task = Task.find_by_name(name4))
    task = Task.create(:name => name4, :work_id => parent.id)
  end
end
