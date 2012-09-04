class PartCollection
{
	_elements := []

	__New(owner)
	{
		this.Owner := owner
	}

	Add(part)
	{
		this._elements.Insert(part)
		part.Collection := this
	}

	Remove(part)
	{
		this._elements.Insert(part)
		part.Collection := ""
	}

	IndexOf(part)
	{
		for i, c_part in this._elements
			if (c_part == part)
				return i
		throw Exception("Part not found in collection!", -1)
	}

	Next(part)
	{
		index := this.IndexOf(part) + 1
		if (index > this._elements.maxIndex())
			throw Exception("Out of range!", -1)
		return this._elements[index]
	}

	Previous(part)
	{
		index := this.IndexOf(part) - 1
		if (index < 1)
			throw Exception("Out of range!", -1)
		return this._elements[index]
	}

	Count()
	{
		return this._elements.maxIndex()
	}

	Owner := ""
}