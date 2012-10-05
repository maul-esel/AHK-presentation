#include %A_ScriptDir%\CGUI\Parse.ahk
#include %A_ScriptDir%\CGUI\CCompoundControl.ahk

class CExecutableCodeControl extends CCompoundControl
{
	static registration := CGUI.RegisterControl("ExecutableCode", CExecutableCodeControl)

	__New(Name, Options, Code, GUINum)
	{
		GUI := CGUI.GUIList[GUINum]
		, Parse(Options, "x* y* w* h*", x, y, w, h)

		this.AddContainerControl(GUI, "HiEdit", "CodeEdit", "x" x " y" y " w" (w - 100) " h" h, Code)
		, hiEdit := this.Container.CodeEdit
		, hiEdit.Hilight := true
		, hiEdit.KeywordFile := A_ScriptDir "\resources\Keywords.hes"
		, hiEdit.LineNumbersBarState := "show"
		, hiEdit.SelectionBarWidth := 15
		, hiEdit.LineNumbersWidth := 20

		for name, color in PresentationWindow.HiEdit_ColorSet
			hiEdit.Colors[name] := color

		this.AddContainerControl(GUI, "Button", "ExecButton", "xp+" (w - 100) " y" y " w100 h" h, Translator.getString("execute"))
		, this.Container.ExecButton.Click.Handler := new Delegate(this, "Execute")

		return Name
	}

	__Get(name)
	{
		if (name = "code")
			return this.Container.CodeEdit.Text
		else if (name = "font")
			return this.Container.CodeEdit.Font
	}

	__Set(name, value)
	{
		if (name = "code")
			return this.Container.CodeEdit.Text := value
	}

	Execute(b)
	{
		static temp_file := A_ScriptDir . "\temp.ahk"

		if (FileExist(temp_file))
			FileDelete %temp_file%
		FileAppend % this.Code, %temp_file%
		Run %A_ScriptDir%\AutoHotkey.exe "%temp_file%"
	}
}