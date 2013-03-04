require 'win32ole'
require 'Win32API'

objShell = WIN32OLE.new('WScript.shell')
obj1 = Win32API.new 'shell32', 'SHGetFolderPath', %w(l l l l p), 'l'


strBuff = "\0" * 200

obj1.call(0, 8, 0, 0, strBuff)

# c:\\Documents and Settings\\<% USER %>\\Recent\\ <- デフォルト
`dir /a:-d-s-h /-c /o:d /t:w \"#{strBuff.split(/\0/)[0]}\"`.each do |line|
  if /(\d\d\d\d\/\d\d\/\d\d)\s*(\d\d:\d\d)\s*(<DIR>)?\s*(\d*)\s*([\S ]*)/ =~ line
    lnkDate = $1
    lnkTime = $2
    lnkPath = $5
    if /.lnk/ =~ lnkPath
      # c:\\Documents and Settings\\<% USER %>\\Recent\\#{lnkPath}
      strShortCut = objShell.CreateShortcut("#{strBuff.split(/\0/)[0]}\\#{lnkPath}")
      print lnkDate + " " + lnkTime + " " + strShortCut.TargetPath + "\n"
    end
  end
end
