class LabelReference
{
	__New(name)
	{
		if (!IsLabel(name))
			throw Exception("Unknown label name '" . name . "'!", -1)
		this.name := name
	}

	__Call(p*)
	{
		;if (p.maxIndex())
		;	throw Exception("Cannot pass parameters to label!", -1)
		; >>>>> ignore parameters <<<<<<
		Gosub % this.name
	}
}

Label(name)
{
	return new LabelReference(name)
}