class Presentation
{
	__New()
	{
		this._doc.load(A_ScriptDir . "\presentation.xml")

		part_list := this._doc.selectNodes("/presentation/part")
		Loop % part_list.length
			this.parts.Insert(new Presentation.Part(part_list.item(A_Index - 1)))

		localized := []
		for i, part in this.parts
		{
			localized.Insert(Translator.getString(part.name))
		}
		this.parts.localized := localized
	}

	getPart(name)
	{
		for i, part in this.parts
			if (part.name = name)
				return part
		throw Exception("Part not found!")
	}

	_doc := ComObjCreate("MSXML2.DOMDocument")

	parts := []

	#include %A_ScriptDir%\Presentation.Part.ahk
}