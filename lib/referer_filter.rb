require "kconv"

class LogEntry
  def initialize(line)
    /^([^\s]+)[^\d]+(\d+)\s(\d+)\s([A-Z]+)\s([^\s]+)\s([^\s]+)\s([^\s]+)$/ =~ line
    @time = maketime($1)
    @content_type = $7
    @service = $2
    @res_byte =$3
    @referer = $5
    @url = $6
    @method = $4
  end

  def maketime(line)
    /(\d+)\/(.+)\/(\d+):(\d+):(\d+):(\d+)/ =~ line
    t = Time.mktime($3,$2,$1,$4,$5,$6)
  end  

  def time
    @time
  end
  
  def content_type
    @content_type
  end

  def service
    @service
  end
  
  def res_byte
    @res_byte
  end
  
  def referer
    @referer
  end
  
  def url
    @url
  end
end

class LogArray < Array
  def self.make_logentry(log = 'access.log')
    # Private Serverのログを読み込み，LogArrayにする
    lines = IO.readlines(log, "\n")
    logarray = self.new

    while line = lines.shift
      logarray << LogEntry.new(line.toutf8)
    end

    return logarray 
  end 

  def select_from_urls(urls)
    logarray = LogArray.new

    self.each do |entry|
      if urls.include?(entry.url)
        logarray << entry
      end
    end

    return logarray
  end

  def referer_urls
    array = []
    self.each { |entry|
      referer = entry.referer
      if referer and referer != '-'
        array << referer
      end
    }
    array.uniq
  end

  def first_access_urls
    array = []
    self.each { |entry|
      if entry.referer == '-'
        array << entry.url
      end
    }
    array.uniq
  end

  def difftime_filter(judge)
    old_time = Time.at(0) # はじまりの時刻
    logarray = LogArray.new

    self.each do |entry|
      new_time = entry.time
      dif_time = new_time - old_time
      if dif_time > judge
        logarray << entry
        old_time = new_time
      end
    end

    return logarray
  end

  def content_filter
    logarray = LogArray.new

    self.each do |entry|
      if ((entry.service == "200" and entry.content_type =~ /text\/html/) or entry.service == "304" ) and !(entry.url =~ /\.swf/) and !(entry.url =~ /\.ico/) 
        logarray << entry
      end
    end

    return logarray
  end

  def add_logarray(array)
    logarray = LogArray.new

    self.each do |entry|
      logarray << entry
    end

    array.each do |entry|
      logarray << entry
    end

    return logarray
  end

  def convert(logarray)
    result = Array.new

    logarray.each do |entry|
      if self.include?(entry)
        result << [entry.time, entry.url]
      end
    end

    return result
  end
end

def referer_filter(log = 'access.log', judge = 3.0)
  # 変数の初期化
  old_time = Time.at(0) # はじまりの時刻
  # ログファイルからLogArrayを作成する
  # サービスコードが200でcontent_typeがtext/htmlでないもの，content_typeが304でないものを，候補から除外する
  logarray_org = LogArray.make_logentry(log)
  ref = logarray_org.referer_urls
  logarray = logarray_org.content_filter

  # リファラとなっているURLを抽出し，そのリファラURLがリクエストされた時の履歴を候補とする
  candidate_logarray1 = logarray.select_from_urls(ref)
  # 1つ前の履歴との参照時間差を見て，両者を参照した時の時間差が2秒より小さい場合，候補から除外する
  candidate_logarray2 = candidate_logarray1.difftime_filter(judge)
  # リファラが'-'の時の履歴を候補に加える
  candidate_logarray3 = logarray.select_from_urls(logarray.first_access_urls)
  result_logarray = candidate_logarray3.add_logarray(candidate_logarray2)
  # 変換
  result = result_logarray.convert(logarray)

=begin
  candidate_urls = logarray.referer_urls + logarray.first_access_urls

  result_logarray = LogArray.new
  candidate_logarray.each do |entry|
    new_time = entry.time
    dif_time = new_time - old_time
    if dif_time > judge and (entry.service == "200" or entry.service == "304") and entry.content_type =~ /text\/html/
      result_logarray << [new_time, entry.url]
      old_time = new_time
    end
  end
=end
 
  return result

=begin
  # 条件判定
  # 条件1：サービス番号200
  # 条件2：拡張子が.cssではない
  # 条件3：前のページを参照してから5秒以上経過している
  # 条件4：Content-Typeがtext/html
  # 条件5：リファラとなっている(除外)
  array = []
  logarray.each { |entry|
    url = entry.url
    new_time = entry.time
    dif_time = new_time - old_time
    #if entry.service == "200" and not url =~ /.css/ and dif_time > judge and entry.content_type =~ /text\/html/# and referer_array.include?(url)
    if entry.service == "200" and not url =~ /.css/ and dif_time > judge and entry.content_type =~ /text\/html/# and referer_array.include?(url)
      array << [new_time, url]
      old_time = new_time
    end
  }
  return array
=end
end

#########################################
# 条件判定のための関数
# 条件：ページの閲覧時間が60秒以上
# ＜引数＞
# array = [time, url]の配列
# time_filter = 閾値
# ＜戻り値＞
# DTBの保存するデータのパス配列
def selection_data(array, time_filter = 60.0)
  result = []
  old_time = Time.new

  while entry = array.pop
    new_time = entry[0]
    dif_time = old_time - new_time
    if dif_time > time_filter and not result.include?(entry[1])
      result << entry[1]
    end
    old_time = new_time
  end

  result.reverse
  
end
  
# コマンドプロンプトから呼ばれたら実行
if $0 == __FILE__
=begin
  ######################################## 
  # デスクトップブックマークの評価用関数
  # 引数：DTBの取得したデータのパスの配列
  def hyoka(array2)
    # 利用者に有益なデータのパス
    array1 = [
      "http://www.mitsubishielectric.co.jp/business/itsolution/index.html",
      "http://www.mitsubishielectric.co.jp/business/itsolution/solution/index.html",
      "http://www.mitsubishielectric.co.jp/business/public/index.html",
      "http://www.mitsubishielectric.co.jp/corporate/review/jouhou/index.html",
      "http://www.mitsubishielectric.co.jp/corporate/csr/index.html",
      "http://www.mitsubishielectric.co.jp/corporate/gaiyo/rinen/index.html",
      "http://www.mitsubishielectric.co.jp/corporate/gaiyo/organization/chart.html"
    ]
    # 利用者に有益なデータのパス数
    a = array1.size.to_f
    # 利用者に有益なデータのうち，DTBの取得したパス数
    b = a - (array1 - array2).size.to_f
    # DTBの取得したデータのパス数
    c = array2.size.to_f
    # データの再現率 \t データの適合率
    puts (b / a).to_s + "\t" + (b / c).to_s
  end

  # i = データの選定に利用する閾値
  i = 0.0
  while i < 240.0
    hyoka selection_data(referer_filter("PrivateServerLog.txt"), i)
    i += 1
  end
=end
  #p selection_data(referer_filter)
  selection_data(referer_filter("lib\\access.log"), 0.0).each do |n|
    print n + "\n"
  end
end
