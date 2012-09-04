class Presentation
{
	__New()
	{
		this._doc.load(A_ScriptDir . "\presentation.xml")

		part_list := this._doc.selectNodes("/presentation/part/@name")
		Loop % part_list.length
			this.parts.Insert(part_list.item(A_Index - 1).value)

		localized := []
		for i, part in this.parts
			localized.Insert(Translator.getString(part))
		this.parts.localized := localized
	}

	_doc := ComObjCreate("MSXML2.DOMDocument")

	parts := []

	#include %A_ScriptDir%\Presentation.Part.ahk
}