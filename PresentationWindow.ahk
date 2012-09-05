class PresentationWindow extends CGUI
{
	__New(pres)
	{
		Base.__New()
		this.DestroyOnClose := true

		this.presentation := pres
		this.Title := Translator.getString("win-title")

		this.Color("white", "white")

		this.NavigationBox := this.AddControl("TreeView", "NavigationBox", "-Buttons x5 y110 w150 h" (0.78 * A_ScreenHeight))
		this._read_parts(this.NavigationBox.Items, this.presentation.parts)

		err := ComObjError(false)
		header := this.AddControl("ActiveX", "HeaderBar", "x5 y5 h90 w" (0.99 * A_ScreenWidth), "Shell.Explorer")
		ComObjError(err)
		header.Navigate(A_ScriptDir "\resources\localized\" Translator.Language "\header.html")
	}

	_read_parts(parent, collection)
	{
		for i, part in collection
		{
			item := parent.Add(part.localized_name, "Expand")
			this._read_parts(item, part.children)
			item.part := part
		}
	}

	loadPart(part)
	{
		if (!part.created)
		{
			this.createPart(part)
		}

		this.showPart(part)
		this.loaded := part

		this.NavigationBox.SelectedItem := this.NavigationBox.FindItemWithText(part.localized_name)
	}

	unloadPart()
	{
		this.hidePart(this.loaded)
		this.loaded.step := 0
		this.loaded := ""
	}

	createPart(part)
	{
		static CGUI_controls := ["text", "edit", "button", "checkbox", "radio", "listview", "combobox", "dropdownlist", "listbox", "treeview", "tab", "groupbox", "picture", "progress", "activex", "syslinkcontrol"]

		node := part.node

		ctrl_list := node.selectNodes("*")
		Loop % ctrl_list.length
		{
			ctrl_node := ctrl_list.item(A_Index - 1)
			ctrl_type := ctrl_node.nodeName

			this._process_styles(ctrl_node, ctrl_font, ctrl_font_opt, ctrl_opt)

			ctrl_options := "x" . (ctrl_node.getAttribute("x") + 170)
							. " y" . (ctrl_node.getAttribute("y") + 110)
							. " w" . (ctrl_node.getAttribute("w") * A_ScreenWidth)
							. " h" . (ctrl_node.getAttribute("h") * A_ScreenHeight)
							. " " . ctrl_opt
			, ctrl_opt := ""

			if (ctrl_type.in(CGUI_controls))
			{
				ctrl := this.AddControl(ctrl_type, part . A_Index, ctrl_options, Translator.getString(ctrl_node.getAttribute("content")))
				part.controls.Insert(ctrl.hwnd)

				if (ctrl_font)
				{
					ctrl.Font.Font := ctrl_font
					, ctrl_font := ""
				}
				if (ctrl_font_opt)
				{
					ctrl.Font.Options := ctrl_font_opt
					, ctrl_font_opt := ""
				}
			}
			else if (ctrl_type = "browser")
			{
				err := ComObjError(false)
				ctrl := this.AddControl("ActiveX", part . A_Index, ctrl_options, "Shell.Explorer")
				ComObjError(err)
				part.controls.Insert(ctrl.hwnd)

				is_localized := ctrl_node.getAttribute("localized") = "true"
				ctrl.Navigate(A_ScriptDir "\resources\" (is_localized ? "localized\" Translator.Language "\" : "") ctrl_node.getAttribute("resource"))
			}

			if (part.is_steps && ctrl_node.getAttribute("step") != 0)
			{
				ctrl.Hide()
			}
			ctrl := ""
		}

		part.created := true
	}

	showPart(part)
	{
		if (!part.is_steps)
		{
			for i, control in part.controls
				this.Controls[control].Show()
		}
	}

	_get_ctrls(part, step)
	{
		nodes := part.node.selectNodes("*")
		ctrls := []

		Loop % nodes.length
		{
			node := nodes.item(A_Index - 1)
			if (node.getAttribute("step") == step)
			{
				ctrl_hwnd := part.Controls[A_Index]
				ctrl := this.Controls[ctrl_hwnd]
				ctrls.Insert(ctrl)
			}
		}

		return ctrls
	}

	continue()
	{
		ctrls := this._get_ctrls(this.loaded, ++this.loaded.step)
		if (ctrls.maxIndex() > 0)
		{
			for i, ctrl in ctrls
				ctrl.Show()
		}
		else ; no more controls to show, load next part
		{
			coll := this.loaded.Collection
			, index := coll.IndexOf(this.loaded)
			, max_index := coll.Count()

			if (this.loaded.children.count() > 0) ; check for nested parts
			{
				part := this.loaded.children.Next("")
			}
			else if (index < max_index) ; check for parts on same level
			{
				part := coll.Next(this.loaded) ; load the next on this level
			}
			else if (index == max_index) ; already displayed last part on this level, so...
			{
				owner := coll.Owner
				if (owner == this.presentation) ; ... first check if we're already in the highest level.
					return ; if so, this was the last. Stop here.
				part := owner.Collection.Next(coll.Owner) ; else go up one level
			}

			this.unloadPart()
			this.loadPart(part) ; load next part in array
		}
	}

	back()
	{
		if (this.loaded.step == 0) ; there are no negative steps - load the previous part
		{
			coll := this.loaded.Collection
			, index := coll.IndexOf(this.loaded)

			if (index > 1)
			{
				part := coll.Previous(this.loaded)
			}
			else
			{
				owner := coll.Owner
				if (owner == this.presentation) ; ... first check if we're already in the highest level.
					return ; if so, this was the first part. Stop here.
				part := coll.Owner
			}
			this.unloadPart()
			this.loadPart(part) ; load previous part
		}
		else
		{
			ctrls := this._get_ctrls(this.loaded, this.loaded.step--)
			for i, ctrl in ctrls
				ctrl.Hide()
		}
	}

	hidePart(part)
	{
		for i, control in part.controls
			this.Controls[control].Hide()
	}

	_process_styles(node, byRef font, byRef font_opt, byRef opt)
	{
		if (style := node.getAttribute("style"))
		{
			style_node := node.ownerDocument.selectSingleNode("/presentation/styles/style[@name='" . style . "']")
			if (style_node)
			{
				if (t := style_node.getAttribute("font-name"))
					font := t
				if (t := style_node.getAttribute("font-opt"))
					font_opt := t
				if (t := style_node.getAttribute("options"))
					opt := t
			}
			else
			{
				throw Exception("Unknown style name", -1)
			}
		}

		if (t := node.getAttribute("font-name"))
			font := t
		if (t := node.getAttribute("font-style"))
			font_opt .= t
		if (t := node.getAttribute("options"))
			opt .= t
	}

	PostDestroy()
	{
		ExitApp
	}

	NavigationBox_ItemSelected(item)
	{
		this.unloadPart()
		this.loadPart(item.part)
	}
}