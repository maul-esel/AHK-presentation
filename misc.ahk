CreateAllParts(parts, gui)
{
	for i, part in parts
	{
		gui.createPart(part)
		, CreateAllParts(part.children, gui)
	}
}

RunEditor()
{
	static script_file := A_ScriptDir . "\test.ahk"
		, script_text := "MsgBox Hallo Welt!"

	if (FileExist(script_file))
		FileDelete %script_file%

	Run, notepad.exe, , , pid
	WinWait ahk_pid %pid%
	WinActivate ahk_pid %pid%

	Loop, parse, script_text
	{
		SendRaw %A_LoopField%
		sleep 100
	}

	sleep 5000
	Send ^s
	sleep 1000
	Send %script_file%{Tab}{Right}{Down}{Enter}
	sleep 3000
	Send {Enter}
	sleep 2000

	Run explorer.exe /n`,/root`,"%A_ScriptDir%"`,/select`,"%script_file%"
	sleep 3000
	Process, Close, %pid%
}