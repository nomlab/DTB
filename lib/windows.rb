# -*- coding:utf-8 -*-
require 'Win32API'
require 'win32ole'
require 'dl/import'
require "kconv"
require "time"

=begin

= Win32APIを宣言するクラス

Win32APIを叩く際には，Win32APIを宣言する必要があるので，LibAPIモジュールで一括して宣言している．
LibAPIモジュールからWin32APIを叩くことで，Windows固有の機能を実現する．

使用例：

  LibAPI.getWindow(hWnd, gw_HWNDFIRST)

=end
module LibAPI
  extend DL::Importer

  # kernel32.dll, user32.dll, gdi32.dllをロード
  dlload "kernel32.dll","user32.dll","gdi32.dll","psapi"

  typealias "HDC","unsigned long"
  typealias "HBITMAP","unsigned long" 

  # screen_capture 内で呼び出すWin32APIのextern宣言
  extern "HDC GetWindowDC(int)"
  extern "HDC CreateCompatibleDC(HDC)"
  extern "HBITMAP CreateCompatibleBitmap(HDC, int, int)"
  extern "long SelectObject(HDC, HBITMAP)"
  extern "long StretchBlt(HDC, long, long, long, long, HDC, long, long, long, long, long)"
  extern "void* GlobalAlloc(long, long)"
  extern "void* GlobalLock(void*)"
  extern "long GetDIBits(HDC, HBITMAP, long, long, void*, void*, long)"
  extern "long GlobalUnlock(void*)"
  extern "long GlobalFree(void*)"
  extern "long DeleteObject(unsigned long)"
  extern "long DeleteDC(HDC)"
  extern "long ReleaseDC(long, HDC)"
  extern "int PrintWindow(int, HDC, unsigned int)"
  extern "long GetWindowRect(int, long*)"
  extern "void ShowWindow(int, int)"
  extern "void SetForegroundWindow(int)"
  # get_task 内で呼び出すWin32APIのextern宣言
  extern "long GetForegroundWindow()"
  extern "long GetClassLongA(long, long)"
  extern "long GetWindow(long, long)"
  extern "long GetWindowTextA(long, void*, long)"
  extern "long IsWindowVisible(long)"
  extern "long GetWindowLongA(long, long)"
  extern "long GetParent(long)"
  extern "long GetDesktopWindow(void)"
  extern "long GetWindowTextLengthA(long)"
  # get_exefile 内で呼び出すWin32APIのextern宣言
  #extern "long GetWindowThreadProcessId(long, long*)"
  extern "long OpenProcess(long, long, long)"
  #extern "long EnumProcessModules(long, long*, long, void*)"
  #extern "long GetModuleFileNameEx(long, long, void*, long)"
  
  # test 内で呼び出すWin32APIのextern宣言
  extern "long OpenClipboard(long)"
  extern "long GetClipboardData(long)"
  extern "int GetObject(long, int, void*)"
  extern "long EmptyClipboard()"
  extern "long CloseClipboard()"
end

=begin

= Windows固有の機能をまとめたクラス

デスクトップブックマークは全てのOSに機能を提供することを目的としているが，現在はWindowsのみの対応となっている．
Windows固有のコマンドを利用する機能は，このクラスに集約している．
デスクトップブックマークからは，このクラスを用いてOS固有の機能を利用する．

使用例：

  WindowsLibs.get_task

=end
class WindowsLibs
  
  # 現在タスクバー上にあるAPを取得するクラスメソッド
  # 戻り値：[hWnd, exefileのパス]の配列
  def self.get_task
    # 定数の設定
    gw_OWNER     = 4
    gw_HWNDFIRST = 0
    gw_HWNDLAST  = 1
    gw_HWNDNEXT  = 2
    gw_HWNDPREV  = 3
    ws_EX_APPWINDOW = 0x00040000
    ws_EX_TOOLWINDOW = 0x00000080
    
    # 配列の初期化
    strBuff = "\0" * 200
    result  = []
    
    # フォアグラウンドウィンドウのウィンドウハンドルを取得
    hWnd = LibAPI.GetForegroundWindow()
    
    # 順序が始めのウィンドウと最後のウィンドウのウィンドウハンドルを取得
    hWnd     = LibAPI.GetWindow(hWnd, gw_HWNDFIRST)
    hWndLast = LibAPI.GetWindow(hWnd, gw_HWNDLAST)
    
    # 順序が始めのものから最後のものまで検索する
    while hWnd != hWndLast
      # ウィンドウタイトル取得の際，エラーが起こるか否か確認
      # 上手くいってないです．Rubyでどうやってポインタ渡すのか不明
      if LibAPI.GetWindowTextA(hWnd, strBuff, strBuff.size) != 0
        # ウィンドウハンドルの拡張ウィンドウハンドルを取得
        lExStyle = LibAPI.GetWindowLongA(hWnd, (-20))
        
        # 最小化されているAPは表示
        if (lExStyle & ws_EX_APPWINDOW) == ws_EX_APPWINDOW
          strBuff = "\0" * 200
          result << [hWnd, get_exefile(hWnd)]
        # タスクバー上のAPは非表示
        elsif (lExStyle & ws_EX_TOOLWINDOW) == ws_EX_TOOLWINDOW
          ;
        # 通常のAPは以下の条件を満たすもののみ表示
        else
          # 親ウィンドウが存在する
          if LibAPI.GetWindow(hWnd, gw_OWNER) == 0
            # ウィンドウが表示されている状態である
            if LibAPI.IsWindowVisible(hWnd) != 0
              hParent = LibAPI.GetParent(hWnd)
              # オーナーウィンドウがない，もしくはデスクトップと同じ
              if hParent == 0 or hParent == LibAPI.GetDesktopWindow()
                strBuff = "\0" * 200
                result << [hWnd, get_exefile(hWnd)]
              end
            end
          end
        end
      end
      hWnd = LibAPI.GetWindow(hWnd, gw_HWNDNEXT)
    end
    # 結果の入った配列を返す
    result
  end
  
  # 与えられたウィンドウハンドルの実行ファイルを取得
  def self.get_exefile(hwnd)
    gpid= Win32API.new 'user32', 'GetWindowThreadProcessId', %w(l p), 'l'
    epm = Win32API.new 'psapi', 'EnumProcessModules', %w(l p l p), 'l'
    gmfn= Win32API.new 'psapi', 'GetModuleFileNameEx', %w(l l p l), 'l'
  
    processID = "\0\0\0\0"
    gpid.call(hwnd, processID)
    hProcess = LibAPI.OpenProcess(0x1F0FFF, 1, processID.unpack("I*")[0])
    hModule = "\0\0\0\0"
    epm.call(hProcess, hModule, 4, nil)
    lpFilename = "\0" * 200
    gmfn.call(hProcess, hModule.unpack("I*")[0], lpFilename, lpFilename.size)
    # 実行ファイルを返す
    lpFilename.split(/\0/)[0]
    
    # 本当はこんな感じにしたいのですが，上手くいってません．
    #processID = "\0\0\0\0"
    #LibAPI.getWindowThreadProcessId(hwnd, processID)
    #p processID
    #hProcess = LibAPI.openProcess(0x1F0FFF, 1, processID.unpack("I*")[0])
    #hModule = "\0\0\0\0"
    #LibAPI.enumProcessModules(hProcess, hModule, 4, nil)
    #lpFilename = "\0" * 200
    #LibAPI.getModuleFileNameEx(hProcess, hModule.unpack("I*")[0], lpFilename, lpFilename.size)
    #puts lpFilename.split(/\0/)[0]
  end
  
  # 与えられたウィンドウハンドルorURLのサムネイルを取得
  def self.screen_capture(filename, url, hWnd = 0)
    begin
      require 'rubygems'
      require 'RMagick'

      if hWnd == 0
        # IEコンポーネントのインスタンスの作成
        ie = WIN32OLE.new('InternetExplorer.Application')
        # ブラウズ先の指定
        ie.Navigate(url)
        # ツールバー非表示
        ie.ToolBar = false
        # メニューバー非表示
        ie.MenuBar = false
        # ステータスバー非表示
        ie.StatusBar = false
        # ウィンドウの横幅を1024pxに設定
        ie.Width = 1024
        # ウィンドウの縦幅を768pxに設定
        ie.Height = 768
        # 可視状態
        ie.Visible = true
        # IEが立ち上がるまで待機
        while ie.Busy
          sleep 1
          hWnd += 1
          if hWnd == 10
            break
          end
        end

        # 立ち上げたAPの縦幅，横幅を指定
        apWidth  = ie.Width
        apHeight = ie.Height

        # 立ち上げたIEのウィンドウハンドルを代入
        hWnd = ie.HWND

        # スクリーンの横幅、縦幅を指定
        # 使われないまま値が更新されてる？？
        screenWidth  = 800 #ie.Width / 2  # = 400 
        screenHeight = 600 #ie.Height / 2 # = 300
       
        # IE は最後に閉じる
        flag = true
      else
        # ウィンドウのサイズを求める
        x = [0, 0, 0, 0].pack('llll').to_ptr
        LibAPI.getWindowRect(hWnd, x)
        x = x.to_a('P').map{|s| s.to_i}
        apWidth  = x[2] - x[0]
        apHeight = x[3] - x[1]

        # スクリーンの横幅、縦幅を指定
        if apWidth > 800
          screenWidth = 320
        else
          screenWidth = apWidth
        end
        apWidth  += 1 if apWidth == 0
        apHeight += 1 if apHeight == 0
        screenHeight = (apHeight.to_f * screenWidth.to_f / apWidth.to_f).to_i

        # 区別のためのフラグ
        flag = false
      end

      # GetWindowDC関数でウィンドウのデバイスコンテキストを取得
      hScreenDC = LibAPI.getWindowDC(hWnd)
      # CreateCompatibleDC関数でメモリデバイスコンテキストを作成
      hmemDC1 = LibAPI.createCompatibleDC(hScreenDC)
      #hmemDC2 = LibAPI.createCompatibleDC(hScreenDC)

      # CreateCompatibleBitmap関数でビットマップオブジェクトを作成
      hmemBM1 = LibAPI.createCompatibleBitmap(hScreenDC, apWidth, apHeight)
      #hmemBM2 = LibAPI.createCompatibleBitmap(hScreenDC, screenWidth, screenHeight)
      # hmemDCとhmemBMを関連付ける
      LibAPI.selectObject(hmemDC1, hmemBM1)
      #LibAPI.selectObject(hmemDC2, hmemBM2)

      # ShowWindow関数でWindowを通常の状態へ
      LibAPI.showWindow(hWnd, 1)
      LibAPI.setForegroundWindow(hWnd)
      # PrintWindow関数でスクリーンショットを撮り，hmemDC1へビットブロックを転送
      LibAPI.printWindow(hWnd, hmemDC1, 0)

      # stretchBlt関数で画像をhmemDC1からhmemDC2へ縮小コピー
      #LibAPI.stretchBlt(hmemDC2, 0, 0, screenWidth, screenHeight,
      #                  hmemDC1, 0, 0, apWidth, apHeight, 0xCC0020) # SRCCOPY = 0xCC0020

      # デバッグ用
      screenWidth  = apWidth
      screenHeight = apHeight
      hmemDC2 = hmemDC1
      hmemBM2 = hmemBM1

      # バッファの1ラインの長さを計算
      if ((screenWidth * 3) % 4 == 0)
        screenLineLength = screenWidth * 3
      else
        screenLineLength = screenWidth * 3 + (4 - (screenWidth * 3) % 4)
      end

      # イメージデータ部のバッファを確保
      hpxldata = LibAPI.globalAlloc(0, screenLineLength * screenHeight) # GMEM_FIXED = 0
      lpvpxldata = LibAPI.globalLock(hpxldata)

      # BITMAPINFOを作成
      bmInfo = [
        40, 
        screenWidth, 
        screenHeight, 
        1, 
        24,
        0, 
        0, 
        0, 
        0, 
        0, 
        0, 
        0
      ].pack('LLLSSLLLLLLL').to_ptr
      # BITMAPFILEHEADERを作成
      bmFileHeader = [
        19778,
        (screenLineLength * screenHeight) + 40 + 14,
        0, 
        0, 
        54
      ].pack('SLSSL').to_ptr

      # GetDIBits関数でイメージデータをバッファに格納
      r = LibAPI.getDIBits(hmemDC2, hmemBM2, 0, screenHeight,
                           lpvpxldata, bmInfo, 0) # DIB_RGB_COLORS = 0

      # ファイルへデータを書き込む
      File::open(filename + ".bmp", "wb") { |bitmap|
        bitmap.print(bmFileHeader.to_s(14))
        bitmap.print(bmInfo.to_s(40))
        bitmap.print(lpvpxldata.to_s(screenLineLength * screenHeight))
      }

      # BITMAPイメージをJPEGイメージに変換
      begin
        img = Magick::ImageList.new(filename + ".bmp")
      rescue
        img = Magick::Image.new(100, 100)
      end
      img.format = "JPEG"
      width = 800
      height = (img.rows.to_f * width.to_f / img.columns.to_f).to_i
      if height > 600
        height = 600
        width  = (img.columns.to_f * height.to_f / img.rows.to_f).to_i
      end

      print "Width  is #{width}\n"
      print "Height is #{height}\n"
      if height < 1
        height = 100
      end
      # デバッグ用
      #if apWidth > 800
      #  width = 800
      #else
      #  width = apWidth
      #end
      #width  += 1 if apWidth == 0
      #height += 1 if apHeight == 0
      #height = (apHeight.to_f * width.to_f / apWidth.to_f).to_i

      img = img.resize(width, height)
      img.write(filename + ".jpg")
      File::delete(filename + ".bmp")

      # 後始末
      LibAPI.globalUnlock(hpxldata)
      LibAPI.globalFree(hpxldata)
      LibAPI.deleteObject(hmemBM1)
      LibAPI.deleteObject(hmemBM2)
      LibAPI.deleteDC(hmemDC1)
      LibAPI.deleteDC(hmemDC2)
      LibAPI.releaseDC(0, hScreenDC)

      if flag
        ie.Quit
      end
    rescue LoadError
      # 与えられたURLのサムネイルを取得(ウィンドウハンドルには未対応，フリーソフトに頼ってます)
      `lib\\CrenaHtml2jpg\\CrenaHtml2jpg.exe -t50 -fjpeg -w1024*768 -s250*200 -o\"#{filename}.jpg\" -u#{url}`
    rescue 
      `lib\\CrenaHtml2jpg\\CrenaHtml2jpg.exe -t50 -fjpeg -w1024*768 -s250*200 -o\"#{filename}.jpg\" -u#{url}`
    end
  end
  
=begin
  # Alt+PrintScreenでキャプチャする(未解決)
  def alt_printscreen(filename)
    shell_obj = WIN32OLE.new("WScript.Shell")
    shell_obj.sendKeys('%{PRTSC}')
    
    hWnd = LibAPI.getForegroundWindow()
    LibAPI.openClipboard(hWnd)
    
    # GetWindowDC関数でウィンドウのデバイスコンテキストを取得
    hScreenDC = LibAPI.getWindowDC(hWnd)
    
    hmemDC = LibAPI.createCompatibleDC(hScreenDC)
    
    hmemBM = LibAPI.getClipboardData(2) # CF_BITMAP = 2
    
    # hmemDCとhmemBMを関連付ける
    LibAPI.selectObject(hmemDC, hmemBM)
     
    # BITMAPINFOを作成
    bmInfo = [
              40, 
              0, 
              0, 
              1, 
              24,
              0, 
              0, 
              0, 
              0, 
              0, 
              0, 
              0
             ].pack('LLLSSLLLLLLL').to_ptr
    
    #ビットマップハンドルから情報を取り出します
    nBit = LibAPI.getObject(hmemBM, bmInfo.to_s.size, bmInfo)
    
    # パレットエントリ数を判定します
    screenWidth  = bmInfo.to_a('P')[1].to_i
    screenHeight = bmInfo.to_a('P')[2].to_i
    
        # バッファの1ラインの長さを計算
    if ((screenWidth * 3) % 4 == 0)
      screenLineLength = screenWidth * 3
    else
      screenLineLength = screenWidth * 3 + (4 - (screenWidth * 3) % 4)
    end
    
    # イメージデータ部のバッファを確保
    hpxldata = LibAPI.globalAlloc(0, screenLineLength * screenHeight) # GMEM_FIXED = 0
    lpvpxldata = LibAPI.globalLock(hpxldata)

    # BITMAPINFOを作成
    bmInfo = [
              40, 
              screenWidth, 
              screenHeight, 
              1, 
              24,
              0, 
              0, 
              0, 
              0, 
              0, 
              0, 
              0
             ].pack('LLLSSLLLLLLL').to_ptr
    # BITMAPFILEHEADERを作成
    bmFileHeader = [
                    19778,
                    (screenLineLength * screenHeight) + 40 + 14,
                    0, 
                    0, 
                    54
                   ].pack('SLSSL').to_ptr
    
    # GetDIBits関数でイメージデータをバッファに格納
    r = LibAPI.getDIBits(hmemDC, hmemBM, 0, screenHeight,
                            lpvpxldata, bmInfo, 0) # DIB_RGB_COLORS = 0
    
    # ファイルへデータを書き込む
    File::open(filename + ".bmp", "w") { |bitmap|
      bitmap.print(bmFileHeader.to_s(14))
      bitmap.print(bmInfo.to_s(40))
      bitmap.print(lpvpxldata.to_s(screenLineLength * screenHeight))
    }
    
    # BITMAPイメージをJPEGイメージに変換
    begin
      img = Magick::ImageList.new(filename + ".bmp")
    rescue
      img = Magick::Image.new(100, 100)
    end
    img.format = "JPEG"
    width = 200
    height = (img.rows.to_f * width.to_f / img.columns.to_f).to_i
    if height > 150
      height = 150
      width  = (img.columns.to_f * height.to_f / img.rows.to_f).to_i
    end
    if height < 1
      height = 100
    end
    
    img = img.resize(width, height)
    img.write(filename + ".jpg")
    File::delete(filename + ".bmp")
    
    # 後始末
    LibAPI.globalUnlock(hpxldata)
    LibAPI.globalFree(hpxldata)
    LibAPI.deleteObject(hmemBM)
    LibAPI.deleteDC(hmemDC)
    LibAPI.releaseDC(0, hScreenDC)
    
    LibAPI.emptyClipboard()
    LibAPI.closeClipboard()
  end
=end
  
=begin
  # 起動時と現在との「最近開いたファイル」情報を比較
  def diff_lnk
    result = []
    `ruby lib\\getlnk.rb > lib\\savelnk.txt`
    `diff.exe lib\\startlnk.txt lib\\savelnk.txt`.each do |line|
      if /^> (\d\d\d\d\/\d\d\/\d\d \d\d:\d\d) ([\S ]*)/ =~ line
        if $2 != ""
          result = result + [$1 + " " + $2 + "\n"]
        end
      end
    end
    #`copy lib\\savelnk.txt lib\\startlnk.txt`
    result
  end
=end
  
  # 仕事開始時間から，仕事で使ったファイルを割り出すメソッド
  # 引数：仕事開始時刻(Timeオブジェクト)
  # 戻り値："2008/09/21 19:20 「ファイルのパス」"の形式の配列
  def self.get_lnk(start_time)
    objShell = WIN32OLE.new('WScript.shell')
    obj1 = Win32API.new 'shell32', 'SHGetFolderPath', %w(l l l l p), 'l'
    result = []
    
    # 最近使ったファイルの保存場所の特定
    strBuff = "\0" * 200
    obj1.call(0, 8, 0, 0, strBuff)
    strBuff.strip!

    # c:\\Documents and Settings\\<% USER %>\\Recent\\ <- デフォルト
    `dir /a:-d-s-h /-c /o:-d /t:a \"#{strBuff}\"`.toutf8.each_line do |line|
      if line =~ /(\d\d\d\d\/\d\d\/\d\d\s*\d\d:\d\d)\s*(<DIR>)?\s*(\d*)?\s*([\S ]*)/
        lnkPath = $4
        a = Time.parse($1)
        b = Time.at(start_time)
        if (a <=> b) > 0
          # c:\\Documents and Settings\\<% USER %>\\Recent\\#{lnkPath}
          begin
            strShortCut = objShell.CreateShortcut("#{strBuff}\\#{lnkPath}")
            if File.extname(strShortCut.TargetPath) != ""
              #result = result + [year + "/" + month + "/" + day + " " + hour + ":" + min + " " + strShortCut.TargetPath]
              result << strShortCut.TargetPath
            end
          rescue
          end
        end
      end
    end
    result
  end

  # データの再参照を行うメソッド
  # 引数：ファイルのパス，(フォーマット)
  def self.restore_ap(id, format)
    # 指定されたファイルに対して，指定された操作を実行する関数
    se  = Win32API.new 'shell32', 'ShellExecute', %w(l p p p p i), 'l'
    # フォアグラウンドウィンドウ（ 現在ユーザーが作業しているウィンドウ）のハンドルを返す関数
    gfw = Win32API.new 'user32',  'GetForegroundWindow', '', 'l'
    
    # 文字コードをSHIFT JISに
    path = NKF.nkf('-s', id)

    # 計算機内部のデータの再参照
    if format
      se.call(gfw.call, "open", path + "." + format, "", "", 1)
    else
      se.call(gfw.call, "open", path, "", "", 1)
    end
  end

  # ファイルに関連付けられているAPの実行ファイルのパスを割り出すメソッド
  # 引数：ファイルのパス
  # 戻り値：APの実行ファイルのパス
  def self.associate(path)
    fet = Win32API.new 'shell32', 'FindExecutable', %w(p p p), 'l'
    strBuff = "\0" * 200

    # 「現在起動しているAP」と「参照していたファイルの拡張子に関連付けられているAP」が同じならマークを付ける
    fet.call(path, nil, strBuff)
    rexe = strBuff.split(/\0/)[0]
  end

  # ディレクトリを削除するメソッド
  # 引数：ディレクトリのパス
  def self.delete_directory(filename)
    `rd /s /q #{filename}`
  end

  # ファイルをコピーするメソッド
  # 引数：ファイルのソースとデスティネーション
  def self.copy(src, dst)
    `copy #{src} #{dst}`
  end

  # Windows的なパスを生成するメソッド
  # 引数：パス配列
  def self.make_path(path)
    path.join("\\")
  end

  # ディレクトリを表示するメソッド
  # 引数：パス文字列
  def self.ls(path)
    `dir #{path}`
  end
  
  # 1時間に複数回仕事状態保存したか確かめるメソッド
  def self.exist_dir?(filename)
    `dir public\\images\\#{filename}`.each_line do |line|
      if /#{filename}/ =~ line
        return true
      end
    end
    return false
  end

  def self.start_count(f, count)
    if /(\d\d\d\d\/\d\d\/\d\d)\s*(\d\d:\d\d)\s*(<DIR>)?\s*\d?\d?\d,\d\d\d\s*([\S ]*)/ =~ f
      lnkDate = $4
      if /thumbnail(\d*).jpg/ =~ lnkDate
        count = $1.to_i + 1 if $1.to_i >= count
      end
    end
    return count
  end
end

# デバッグモード
if $0 == __FILE__
  #job_start_time = ""
  #time = "2008-10-30-20-02-18".split "-"
  #job_start_time = Time.mktime *time
  #
  #print WindowsLibs.get_lnk(job_start_time)
  WindowsLibs.screen_capture("test", "http://www.swlab.cs.okayama-u.ac.jp")
end
