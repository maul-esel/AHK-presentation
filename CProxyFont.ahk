class CProxyFont
{
	FontChanged := new EventHandler()

	__New(handler = "")
	{
		if (handler)
			this.FontChanged := handler
		this.Insert("_", {})
	}

	__Get(property)
	{
		if property in Font,Options,Size
			return this._[property]
	}

	__Set(property, value)
	{
		if property in Font,Options,Size
		{
			this._[property] := value
			, this.FontChanged.(property, value)
			return value
		}
	}
}