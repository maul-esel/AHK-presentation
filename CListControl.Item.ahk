class Item extends CCompoundControl
{
	Font := new CProxyFont(new Delegate(this, "UpdateFont"))

	__New(GUI, list, item_node, index)
	{
		this.Insert("_", { "list" : list })
		, this.Node := item_node
		, content := GUI.GetElementContent(item_node)
		, GUI.ProcessStyles(item_node, font, font_opt, opt)

		if (content == item_node && (children := item_node.selectNodes("*")).length > 0) ; has > 0 subcontrols
		{
			; ...
		}
		else ; is pure text item
		{
			Random r
			, this.AddContainerControl(GUI, "Text", "list_item" (this._.r := r), opt, this._.text := content)
		}

		this.Update()

		if (font)
			this.Font.Font := font
		if (font_opt)
			this.Font.Options := font_opt
		list.Font.FontChanged.Handler := new Delegate(this, "UpdateFont")
	}

	GetRequiredHeight(w)
	{
		font := this.Container["list_item" this._.r].Font
		return this._.hasKey("text") ? MeasureTextHeight(this._.text, w, font.Options, font.font) : this.Boundaries.H
	}

	Move(x, y, w, h)
	{
		if (this._.hasKey("text"))
		{
			ctrl := this.Container["list_item" this._.r]
			, ctrl.x := x
			, ctrl.y := y
			, ctrl.Width := w
			, ctrl.Height := h
		}
		else
		{
			this.X := x, this.Y := y
			; ...
		}
	}

	Update()
	{
		font := this.Font.Font ? this.Font.Font : this._.list.Font.Font
		, font_opt := this.Font.Options ? this.Font.Options : this._.list.Font.Options

		for name, ctrl in this.Container
		{
			ctrl.Font.Font := font
			, ctrl.Font.Options := font_opt
		}

		this._.list.UpdatePositions()
	}

	; @callback
	UpdateFont(property, value)
	{
		; pass font settings to sub-controls
		; if text-only, resize sub-control accordingly
		; only update if a real change happened (e.g. local font has priority over list font changes)

		this.Update()
	}
}