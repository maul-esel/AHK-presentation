CreateAllParts(parts, gui)
{
	for i, part in parts
	{
		if (!part.created)
			gui.createPart(part)
		CreateAllParts(part.children, gui)
	}
}

SetRedraw(win, allow = false)
{
	static WM_SETREDRAW := 0x000B
	SendMessage, WM_SETREDRAW, allow, 0,, % "ahk_id " win.hwnd
}

SwitchBrowser()
{
	global gui
	static dest

	for name, ctrl in gui.currentPart.controls {
		if (ctrl.Type = "ActiveX") {
			alt_resource := ctrl._.XMLNode.getAttribute("alt-resource")
			, resource := ctrl._.XMLNode.getAttribute("resource")
			, ctrl.Navigate(dest := (!dest || dest = resource) ? alt_resource : resource)
			break
		}
	}
}

RunEditor()
{
	static script_file := A_ScriptDir . "\tmp\script.ahk"
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

	Run explorer.exe /select`,"%script_file%"
	sleep 3000
	Process, Close, %pid%
}