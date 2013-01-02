class Item extends CCompoundControl
{
	Font := new CProxyFont(new Delegate(this, "UpdateFont"))

	__New(GUI, list, item_node, index)
	{
		this.Insert("_", { "list" : list, "GUI" : GUI })
		, this.Node := item_node
		, content := GUI.GetElementContent(item_node)
		, GUI.ProcessStyles(item_node, font, font_opt, opt)
		, this.Step := (t := item_node.getAttribute("step")) ? t : index
		, this.Index := index

		Random r
		this._.r := r
		if (content == item_node) ; has subcontrols
		{
			children := item_node.selectNodes("*")
			Loop % children.length
			{
				ctrl_node := children.item(A_Index - 1)
				, ctrl := GUI.CreateControl(ctrl_node, name := "list_item" . r . "_" . A_Index)
				, this.Container.Insert(name, ctrl)
			}
		}
		else ; is pure text item
		{
			this.AddContainerControl(GUI, "Text", "list_item" . r, opt, this._.text := content)
		}

		if (font)
			this.Font.Font := font
		if (font_opt)
			this.Font.Options := font_opt
		list.Font.FontChanged.Handler := new Delegate(this, "UpdateFont")
	}

	Next()
	{
		handled := false
		for name, ctrl in this.Container
		{
			if (ctrl.canIterate)
				handled := ctrl.Next() || handled
		}
		return handled
	}

	Previous()
	{
		handled := false
		for name, ctrl in this.Container
		{
			if (ctrl.canIterate)
				handled := handled || ctrl.Previous()
		}
		return handled
	}

	GetRequiredHeight(w)
	{
		if (!this._.hasKey("text"))
		{
			max_height := 0
			for name, ctrl in this.Container
			{
				ctrl.AutoSize()
				max_height += ctrl.Height
			}
			return max_height
		}
		font := this.Container["list_item" this._.r].Font
		return MeasureTextHeight(this._.text, w, font.Options, font.font)
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
			content_area := new ContentArea(x, y, w, h)
			for name, ctrl in this.Container
			{
				pos := this._.GUI.ProcessPosition(ctrl._.XMLNode, Viewbox.FromNode(ctrl._.XMLNode), content_area)
				for key, value in { "x" : "x", "y" : "y", "width" : "w", "height" : "h" }
				{
					ctrl[key] := pos[value]
				}
			}
		}
	}

	; @callback
	UpdateFont(property, value)
	{
		; TODO: only update if a real change happened (e.g. local font has priority over list font changes)

		font := this.Font.Font ? this.Font.Font : this._.list.Font.Font
		, font_opt := this.Font.Options ? this.Font.Options : this._.list.Font.Options

		; pass font settings to sub-controls
		for name, ctrl in this.Container
		{
			ctrl.Font.Font := font
			, ctrl.Font.Options := font_opt
		}

		this._.list.UpdatePositions()
	}
}