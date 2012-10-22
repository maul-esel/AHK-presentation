#include %A_ScriptDir%\CGUI\Parse.ahk
#include %A_ScriptDir%\CGUI\CCompoundControl.ahk

class CListControl extends CCompoundControl
{
	canIterate := true

	static registration := CGUI.RegisterControl("List", CListControl)

	__New(Name, Options, self, GUINum)
	{
		static margin_marker := 25, item_margin := 5

		GUI := CGUI.GUIList[GUINum]
		, Parse(Options, "x* y* w* h*", x, y, w, h)
		, this.Insert("_", {})

		content := self.selectNodes("item")
		Loop % content.length
		{
			item := content.item(A_Index - 1)

			this.AddContainerControl(GUI, "Text", "marker" A_Index, "x" x " y" y " w" margin_marker " h" h, this._get_marker(A_Index))
			this.AddContainerControl(GUI, "Text", "item" A_Index, "x" (x+margin_marker) " y" y " w" (w-margin_marker) " h" h, Translator.getString(item.getAttribute("content")))

			y += MeasureTextHeight(item.text, w-margin_marker) + item_margin
		}
		return Name
	}

	_get_marker(i)
	{
		return Chr(8226)
	}
}