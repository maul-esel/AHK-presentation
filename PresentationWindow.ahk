class PresentationWindow extends CGUI
{
	__New(pres)
	{
		Base.__New()
		this.DestroyOnClose := true

		this.presentation := pres
		this.Title := Translator.getString("win-title")

		this.Color("white", "white")

		tree := this.AddControl("TreeView", "NavigationBox", "-Buttons x5 y110 w150 h" (0.78 * A_ScreenHeight))
		for i, part in this.presentation.parts
		{
			item := tree.Items.Add(part.localized_name, "Expand")
		}

		err := ComObjError(false)
		header := this.AddControl("ActiveX", "HeaderBar", "x5 y5 h90 w" (0.99 * A_ScreenWidth), "Shell.Explorer")
		ComObjError(err)
		header.Navigate(A_ScriptDir "\resources\localized\" Translator.Language "\header.html")
	}

	loadPart(part_name)
	{
		part := this.presentation.getPart(part_name)
		if (!part.created)
		{
			this.createPart(part)
		}

		this.showPart(part)
		this.loaded := part
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

			ctrl_options := "x" . (ctrl_node.getAttribute("x") + 170)
							. " y" . (ctrl_node.getAttribute("y") + 110)
							. " w" . (ctrl_node.getAttribute("w") * A_ScreenWidth)
							. " h" . (ctrl_node.getAttribute("h") * A_ScreenHeight)
							. " " . ctrl_node.getAttribute("options")

			if (ctrl_type.in(CGUI_controls))
			{
				ctrl := this.AddControl(ctrl_type, part . A_Index, ctrl_options, Translator.getString(ctrl_node.getAttribute("content")))
				part.controls.Insert(ctrl.hwnd)

				if (ctrl_font := ctrl_node.getAttribute("font-name"))
				{
					ctrl.Font.Font := ctrl_font
				}
				if (ctrl_font_opt := ctrl_node.getAttribute("font-style"))
				{
					ctrl.Font.Options := ctrl_font_opt
				}
				if (part.is_steps)
				{
					ctrl.Hide()
				}
			}
			else if (ctrl_type = "browser")
			{
				err := ComObjError(false)
				ctrl := this.AddControl("ActiveX", part . A_Index, ctrl_options, "Shell.Explorer")
				part.controls.Insert(ctrl.hwnd)

				ctrl.Navigate(A_ScriptDir "\resources\localized\" Translator.Language "\" ctrl_node.getAttribute("resource"))
				ComObjError(err)
			}
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
			; TODO: support nested parts

			index := this.presentation.getPartIndex(this.loaded) ; first find current part in array
			if (index != this.presentation.parts.maxIndex()) ; do not load next part if this was already the last
			{
				this.unloadPart()
				this.loadPart(this.presentation.parts[index + 1].name) ; load next part in array
			}
		}
	}

	back()
	{
		if (this.loaded.step == 0) ; there are no negative steps - load the previous part
		{
			index := this.presentation.getPartIndex(this.loaded)
			if (index != 1) ; if we didn't already load the first part
			{
				this.unloadPart()
				this.loadPart(this.presentation.parts[index - 1].name) ; load previous part
			}
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

	PostDestroy()
	{
		ExitApp
	}
}