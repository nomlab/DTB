using System;
using System.Diagnostics;


public class TaskKill
{

　　static int Main(string[] args)
　　{

        string manual=""+
"TASKKILL { [/F] [/PID プロセスID | /IM イメージ名] }\r\n\r\n"+
"説明:\r\n"+
"    このコマンド ライン ツールは、プロセスを終了するために使われます。\r\n"+
"    プロセス ID またはイメージ名を使って終了できます。\r\n"+
"    Windows XP Home Edition 向けの簡易版TASKKILLです。\r\n\r\n"+
"パラメータ一覧:\r\n"+
"    /F                        プロセスの強制終了を指定します。\r\n\r\n\r\n"+
"    /PID   プロセスID         終了させるプロセスの PID を指定します。\r\n\r\n\r\n"+
"    /IM    イメージ名         終了させるプロセスのイメージ名を指定します。\r\n\r\n\r\n"+
"    /?                        このヘルプまたは使用法を表示します。\r\n\r\n"+
"例:\r\n"+
"    TASKKILL /IM notepad.exe\r\n"+
"    TASKKILL /PID 1230 /PID 1241 /PID 1253\r\n"+
"    TASKKILL /F /IM notepad.exe /IM mspaint.exe\r\n";



  　  　int fFlag   = 0;
        int imFlag  = 0;
        int pidFlag = 0;


　    　//構文解析 + マニュアル表示 + 強制終了フラグON

        for(int i=0;i<args.Length;i++)
        {
            if(args[i]=="/?")
            {
                 Console.WriteLine(manual);
                 return 0;
            }
            // /F（強制終了）オプションがあるかどうか
            if(args[i]=="/F" || args[i]=="/f")
            {
                fFlag=1;
            }
            else if(args[i]=="/IM" || args[i]=="/im")
            {
                if(i == args.Length-1){
                    Console.Write("エラー: 無効な構文です。'"+ args[i] +"' に値を指定してください。\r\n"
                                 +"\"TASKKILL /?\" と入力すると使用法が表示されます。\r\n");
                    return 1;
                }
                imFlag=1;
                i++;
            }
            else if(args[i]=="/PID" || args[i]=="/pid")
            {
                if(i == args.Length-1){
                    Console.Write("エラー: 無効な構文です。'"+ args[i] +"' に値を指定してください。\r\n"
                                 +"\"TASKKILL /?\" と入力すると使用法が表示されます。\r\n");
                    return 1;
                }
                try
                {
                    int.Parse(args[i+1]);
                }
                catch
                {
                    Console.Write("エラー: 無効な構文です。 /PID オプションには数値を指定してください。\r\n\r\n"
                                 +"\"TASKKILL /?\" と入力すると使用法が表示されます。\r\n");
                    return 1;
                }
                pidFlag=1;
                i++;
            }
            else
            {
                Console.WriteLine("エラー: 無効な引数/オプションです - '" + args[i] +"'。");
                return 1;
            }
        }


        if(imFlag==1 && pidFlag==1)
        {
            Console.Write("エラー: 無効な構文です。 /PID と /IM を同時に指定できません。"
                         +"\r\n\r\n\"TASKKILL /?\" と入力すると使用法が表示されます。\r\n");
            return 1;
        }

　    　//プロセス終了処理のループ
        //構文解析済みを前提

        for(int i=0;i<args.Length;i++)
        {
            if(args[i]=="/F" || args[i]=="/f")
            {
                // なにもしない
            }
            else if(args[i]=="/IM" || args[i]=="/im")
            {
                string strBefore = args[i+1];
                string strAfter;
                strAfter = strBefore.Replace(".exe", "");

                Process[] myProcesses = Process.GetProcessesByName(strAfter);
                foreach (Process myProcess in myProcesses)
                {
                    if (fFlag==0)
                    {
                        if(myProcess.CloseMainWindow()){
                           Console.Write("成功: プロセス \"" + myProcess.ProcessName 
                                       + ".exe\" (PID "+ myProcess.Id.ToString() +") は強制終了されました。\r\n");
                        }
                    }
                    else
                    {
                        myProcess.Kill();
                        Console.Write("成功: プロセス \"" + myProcess.ProcessName 
                                    + ".exe\" (PID "+ myProcess.Id.ToString() +") は強制終了されました。\r\n");
                    }
                 }
                 i++;
            }
            else if(args[i]=="/PID" || args[i]=="/pid")
            {
                try
                {
                    Process myProcess = Process.GetProcessById(int.Parse(args[i+1]));
                    if (fFlag==0)
                    {
                        if(myProcess.CloseMainWindow()){
                           Console.Write("成功: プロセス \"" + myProcess.ProcessName 
                                       + ".exe\" (PID "+ myProcess.Id.ToString() +") は強制終了されました。\r\n");
                        }
                    }
                    else
                    {
                        myProcess.Kill();
                        Console.Write("成功: プロセス \"" + myProcess.ProcessName 
                                    + ".exe\" (PID "+ myProcess.Id.ToString() +") は強制終了されました。\r\n");
                    }
                }
                catch
                {
                    Console.WriteLine("エラー: プロセス \"" + args[i+1] + "\" が見つかりませんでした。");
                }
                i++;
            }
        }
        return 0;
    }
}
