class Presentation
{
	__New()
	{
		this._doc.load(A_ScriptDir . "\presentation.xml")
		, this._doc.setProperty("SelectionLanguage", "XPath")

		this.parts := new Presentation.PartCollection(this)
		, part_list := this._doc.selectNodes("/presentation/part")
		Loop % part_list.length
			this.parts.Add(new Presentation.Part(part_list.item(A_Index - 1)))
	}

	getPart(name)
	{
		for i, part in this.parts
			if (part.name = name)
				return part
		throw Exception("Part not found!", -1)
	}

	getPartIndex(part)
	{
		if (i := Obj.in(this.parts, part))
			return i
		throw Exception("Part index not found!", -1)
	}

	_doc := ComObjCreate("MSXML2.DOMDocument")

	parts := ""

	#include %A_ScriptDir%\Presentation.Part.ahk
	#include %A_ScriptDir%\Presentation.PartCollection.ahk
}