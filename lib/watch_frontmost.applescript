# Output frontmost window log
#
# Author:  Takuya Okada
# Created: 2014-5-28
# Updated: 2014-5-28
#
# log format
#    stratTime|pid|pName

# property of script
property aLogDirPath : "/Users/okada/Dropbox/Nomlab/home/admin/misc/DTB/lib/"
property aLogFilePath : "/Users/okada/Dropbox/Nomlab/home/admin/misc/DTB/lib/frontmost.log"
property aLogFileName : "frontmost.log"
property LF : ASCII character (10)

# subroutine
# return new frontmost unix id and name
on newFrontmostProcessIDAndName()
    tell application "System Events"
        set currentProcess to (processes whose frontmost is true)
        repeat
            delay 1 #sec
            if not (currentProcess = (processes whose frontmost is true)) then
                return {unix id, name} of (item 1 of (processes whose frontmost is true))
                exit repeat
            end if
        end repeat
    end tell
end newFrontmostProcessIDAndName

# return "YYYY-MM-DD" hh:mm:ss from Date object
# http://piyocast.com/as/archives/1373
on makeDateStr(aDate)
    set yStr to (year of aDate) as string
    set mStr to (month of aDate as number) as string
    set dStr to (day of aDate) as string
    set hhStr to ((time of (aDate)) div 3600) as string
    set mmStr to ((time of (aDate)) mod 3600 div 60) as string
    set ssStr to ((time of (aDate)) mod 3600 mod 60) as string

    set y2Str to retZeroPaddingText(yStr, 4) of me
    set m2Str to retZeroPaddingText(mStr, 2) of me
    set d2Str to retZeroPaddingText(dStr, 2) of me
    set hh2Str to retZeroPaddingText(hhStr, 2) of me
    set mm2Str to retZeroPaddingText(mmStr, 2) of me
    set ss2Str to retZeroPaddingText(ssStr, 2) of me

    return (y2Str & "-" & m2Str & "-" & d2Str & " " & hh2Str & ":" & mm2Str & ":" & ss2Str)
end makeDateStr

on retZeroPaddingText(aNum, aLen)
    set tText to ("0000000000" & aNum as text)
    set tCount to length of tText
    set resText to text (tCount - aLen + 1) thru tCount of tText
    return resText
end retZeroPaddingText

on isEmptyFile(unixFilePath)
    set aFile to unixFilePath as POSIX file

    open for access aFile with write permission
    set aEOF to get eof of aFile
    close access aFile

    if aEOF = 0 then return true
    return false
end isEmptyFile

on addStrToFile(aString, unixFilePath)
    set aFile to unixFilePath as POSIX file

    open for access aFile with write permission
    set aEOF to get eof of aFile
    try
        write aString starting at (aEOF + 1) to aFile
    on error aErrorText
        display dialog aErrorText
    end try
    close access aFile
end addStrToFile

on getOldestLogFileName()
    return do shell script "ls -alrtT " & aLogDirPath & " | grep " & aLogFileName & " | tail -n 1 | awk '{print $10}'"
end getOldestLogFileName

on createBackUpLogFile()
    set oldestLog to getOldestLogFileName()
    if oldestLog = "" then return
    if oldestLog = aLogFileName then
        return do shell script "mv " & aLogFilePath & " " & aLogFilePath & ".1"
    else
        return #ログローテートする処理を書く
    end if
end createBackUpLogFile

# main
repeat
    set {pid, pName} to newFrontmostProcessIDAndName()
    set startTime to get makeDateStr(current date) of me

    set logString to startTime & "|" & pid & "|" & pName & LF
    addStrToFile(logString, aLogFilePath)
end repeat