class Translator
{
	static Language := "de"

	getString(name)
	{
		Translator.load()
		return Translator._doc.selectSingleNode("/lang/translation[@lang='" . Translator.Language . "']/string[@name='" . name . "']").text
	}

	load()
	{
		if (!Translator._doc)
		{
			Translator._doc := ComObjCreate("MSXML2.DOMDocument")
		}
		if (Translator._doc.url == "")
		{
			Translator._doc.load(A_ScriptDir . "/lang.xml")
		}
	}

	static _doc := ComObjCreate("MSXML2.DOMDocument")
}