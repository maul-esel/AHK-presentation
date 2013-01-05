class SplashScreen extends CGUI
{
	DestroyOnClose := true
	AlwaysOnTop := true
	ToolWindow := true
	WindowWidth := 567
	WindowHeight := 150
	Title := Translator.getString("splashscreen-title")

	pic := this.AddControl("Picture", "pic", "x25 y10", A_ScriptDir "\resources\ahk_logo.png")
	load := this.AddControl("Text", "load", "w" . this.WindowWidth " h25 +0x1", Translator.getString("loading"))

	__New()
	{
		this.load.Font.Options := "s14 bold"
		this.Color("white", "white")
		this.Show("center")
	}
}