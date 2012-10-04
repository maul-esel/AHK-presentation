class QuickEditWindow extends CGUI
{
	QuickEdit := this.AddControl("HiEdit", "QuickEdit", "x5 y30")

	btn_Undo := this.AddControl("Button", "btn_Undo", "x5 y5 w100 h20", Translator.getString("undo"))
	btn_Redo := this.AddControl("Button", "btn_Redo", "x110 y5 w100 h20", Translator.getString("redo"))
	btn_Execute := this.AddControl("Button", "btn_Execute", "x100 y5 w100 h20", Translator.getString("execute"))

	Caption := false
	Transparent := 225
	Title := "QuickEdit"
	ToolWindow := true

	DestroyOnClose := true
	OwnerAutoClose := true

	WindowWidth := (1/3) * A_ScreenWidth
	WindowHeight := 0.84 * A_ScreenHeight
	Position := { "X" : A_ScreenWidth - this.WindowWidth - 5, "Y" : A_ScreenHeight - this.WindowHeight - 5 }
	Region := "0-0 W" this.WindowWidth " H" this.WindowHeight " R10-10"

	static color_set := { "Back" : "black", "Text" : "white", "SelBarBack" : "black", "LineNumber" : "red", "Number" : "red" }

	__New(parent)
	{
		Base.__New()

		this.Color("black", "black")
		, this.Owner := parent.Hwnd

		this.QuickEdit.Size := { "Width" : this.Width - 10, "Height" : this.Height - 30 - 5 }
		, this.QuickEdit.Hilight := true
		, this.QuickEdit.LineNumbersBarState := "show"
		, this.QuickEdit.SelectionBarWidth := 15
		, this.QuickEdit.LineNumbersWidth := 20
		, this.QuickEdit.Font.Font := "Consolas"
		, this.QuickEdit.Font.Options := "s24"
		, this.QuickEdit.KeywordFile := A_ScriptDir "\resources\Keywords.hes"

		for property, color in QuickEditWindow.color_set
		{
			this.QuickEdit.colors[property] := color
		}

		this.btn_Execute.X := this.Width - 105
	}

	btn_Undo_Click()
	{
		this.QuickEdit.Undo()
	}

	btn_Redo_Click()
	{
		this.QuickEdit.Redo()
	}

	btn_Execute_Click()
	{
		static temp_file := A_ScriptDir . "\temp.ahk"

		if (FileExist(temp_file))
			FileDelete %temp_file%
		FileAppend % this.QuickEdit.Text, %temp_file%
		Run %A_ScriptDir%\AutoHotkey.exe "%temp_file%"
	}

	SlideIn()
	{
		static AW_SLIDE := 0x00040000, AW_HOR_NEGATIVE := 0x00000002
		DllCall("AnimateWindow", "Ptr", this.hwnd, "UInt", 300, "UInt", AW_SLIDE|AW_HOR_NEGATIVE, "UInt")
		this.QuickEdit.Text := this.QuickEdit.Text
	}

	SlideOut()
	{
		static AW_SLIDE := 0x00040000, AW_HOR_POSITIVE := 0x00000001, AW_HIDE := 0x00010000
		DllCall("AnimateWindow", "Ptr", this.hwnd, "UInt", 300, "UInt", AW_SLIDE|AW_HOR_POSITIVE|AW_HIDE, "UInt")
	}
}