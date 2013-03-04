REM CrenaHtml2jpg.exeを直接実行する場合
REM CrenaHtml2jpg.exe -otest.jpg -fjpeg -w800x600 -s117x90 -q92 -t25 -u"http://www.yahoo.co.jp"
REM -uのURLを"で囲んでも良い。


CrenaHtml2jpg.exe -otest.jpg -fjpeg -w800x600 -s117x90 -q92 -t25 -uhttp://www.yahoo.co.jp
echo %ERRORLEVEL%



REM URLに＆等が含まれる場合。-uのURLは、"で囲むこと。

CrenaHtml2jpg.exe -otest.jpg -fjpeg -w800x600 -s800x600 -q92 -t25 -u"http://www.google.co.jp/search?hl=ja&lr=lang_ja&num=10&q=%e3%83%86%e3%82%b9%e3%83%88"
echo %ERRORLEVEL%

REM CrenaHtml2jpg.exeをproccmdから呼び出す場合:わざとエラー。参考
proccmd -w 30 -c "CrenaHtml2jpg.exe -owwwgooglecojp.jpg -fjpeg -w800x600 -s117x90 -q92 -t25 -uhttp://aaa.yahoo.co.jp"
echo %ERRORLEVEL%

REM 以下,ファイル名に空白、ＵＲＬに空白を含む例
REM -----------------------------------------------------------------
REM CrenaHtml2jpg.exe -o"C:\Documents and Settings\test test1.jpg" -fjpeg -w800x600 -s117x90 -q92 -t25 -uhttp://www.yahoo.co.jp
REM CrenaHtml2jpg.exe -o"teseeerrrt yyy.jpg" -fjpeg -w800x600 -s117x90 -q92 -t25 -u"http://www.picolix.jp/ver sion.html"
REM -----------------------------------------------------------------

REM proccmd（他プログラムから呼び出し）にファイル名に空白、ＵＲＬに&を含む文字列を渡す場合。
REM ---------------------------------------------------------------------
REM proccmd -w 30 -c "CrenaHtml2jpg.exe -o\"C:\Documents and Settings\test.jpg\" -fjpeg -w800x600 -s117x90 -q92 -t25 -u""http://www.google.co.jp/search?hl=ja&lr=lang_ja&q=検索
"""
REM -----------------------------------------------------------------
