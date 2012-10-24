class SplashScreen extends CGUI
{
	DestroyOnClose := true
	AlwaysOnTop := true
	ToolWindow := true
	WindowWidth := 567
	WindowHeight := 150
	Title := "Loading the presentation..."

	pic := this.AddControl("Picture", "pic", "x25 y10", A_ScriptDir "\resources\ahk_logo.png")
	load := this.AddControl("Text", "load", "w" . this.WindowWidth " h25 +0x1", "Loading...")

	__New()
	{
		this.load.Font.Options := "s14 bold"
		this.Color("white", "white")
		this.Show("center")
	}
}