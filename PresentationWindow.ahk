class PresentationWindow extends CGUI
{
	DestroyOnClose := true
	Caption := false
	Title := Translator.getString("win-title")

	static HiEdit_ColorSet := { "Back" : "black", "Text" : "white", "SelBarBack" : "black", "LineNumber" : "red", "Number" : "red" }

	__New(pres)
	{
		Base.__New()
		, this.presentation := pres
		, this.Color("white", "white")

		this.NavigationBox := this.AddControl("TreeView", "NavigationBox", "-Buttons x5 y110 w275 h" (0.78 * A_ScreenHeight))
		, this.NavigationBox.Font.Options := "s12"
		, this._read_parts(this.NavigationBox.Items, this.presentation.parts)

		err := ComObjError(false)
		, this.HeaderBar := this.AddControl("ActiveX", "HeaderBar", "x5 y5 h90 w" (0.99 * A_ScreenWidth), "Shell.Explorer")
		, ComObjError(err)
		, this.HeaderBar.Navigate(A_ScriptDir "\resources\localized\" Translator.Language "\header.html")

		for i, part in this.presentation.parts
			this.createPart(part)

		this.QuickEdit := new QuickEditWindow(this)
	}

	_read_parts(parent, collection)
	{
		for i, part in collection
		{
			item := parent.Add(part.localized_name, "Expand")
			, this._read_parts(item, part.children)
			, item.part := part
		}
	}

	_get_viewbox(node)
	{
		box := node.selectSingleNode("viewbox")
		if (box)
		{
			return { "width" : box.getAttribute("width")
					, "height" : box.getAttribute("height")
					, "margin" : {  "left" : (t := box.getAttribute("margin-left"))   ? t : 0
								,  "right" : (t := box.getAttribute("margin-right"))  ? t : 0
								,    "top" : (t := box.getAttribute("margin-top"))    ? t : 0
								, "bottom" : (t := box.getAttribute("margin-bottom")) ? t : 0 } }
		}
		if (node.parentNode)
			return this._get_viewbox(node.parentNode)
	}

	_process_position(ctrl_node)
	{
		static static_margin := 10

		WinGetPos, , , w_win, h_win, % "ahk_id " this.hwnd ; get window dimensions
		viewbox := this._get_viewbox(ctrl_node) ; get viewbox dimensions
		, panel := { "x" : (x_panel := this.NavigationBox.x + this.NavigationBox.width + static_margin + viewbox.margin.left)
					, "y" : (y_panel := this.HeaderBar.y + this.HeaderBar.height + static_margin + viewbox.margin.top)
					, "w" : w_win - x_panel - 2 * static_margin - viewbox.margin.right
					, "h" : h_win - y_panel - 2 * static_margin - viewbox.margin.bottom }

		ctrl := {}
		for i, opt in ["x", "y", "w", "h"]
		{
			if ((t := ctrl_node.getAttribute(opt)) != "")
				ctrl[opt] := t
		}

		pos := {}
		if (ctrl.HasKey("x"))
		{
			pos.x := floor(ctrl.x / viewbox.width * panel.w + panel.x)
		}
		if (ctrl.HasKey("y"))
		{
			pos.y := floor(ctrl.y / viewbox.height * panel.h + panel.y)
		}
		if (ctrl.HasKey("w"))
		{
			pos.w := floor(ctrl.w / viewbox.width * panel.w)
		}
		if (ctrl.HasKey("h"))
		{
			pos.h := floor(ctrl.h / viewbox.height * panel.h)
		}
		return pos
	}

	loadPart(part)
	{
		if (!part.created)
		{
			this.createPart(part)
		}

		this.showPart(part)
		, this.loaded := part

		, this.NavigationBox.SelectedItem := this.NavigationBox.FindItemWithText(part.localized_name)
	}

	unloadPart()
	{
		this.hidePart(this.loaded)
		, this.loaded.step := 0
		, this.loaded := ""
	}

	createPart(part)
	{
		static CGUI_controls := Obj.keys(CGUI.RegisteredControls)
		static READYSTATE_COMPLETE := 4

		node := part.node

		ctrl_list := node.selectNodes("*")
		Loop % ctrl_list.length
		{
			exec_button := false
			, ctrl_node := ctrl_list.item(A_Index - 1)
			, ctrl_type := ctrl_node.nodeName

			this._process_styles(ctrl_node, ctrl_font, ctrl_font_opt, ctrl_opt)
			, pos := this._process_position(ctrl_node)

			if (ctrl_type.in(["edit", "hiedit"]) && ctrl_node.getAttribute("execute").in(["true", "1"]))
			{
				exec_button := true
				, pos.w -= 100
			}

			ctrl_options := ""
			for property, value in pos
			{
				ctrl_options .= property . value . A_Space
			}
			ctrl_options .= ctrl_opt
			, ctrl_opt := ""

			if (ctrl_type.in(CGUI_controls))
			{
				content := ctrl_node.getAttribute("content")
				if (!content)
					content := ctrl_node.text
				else
					content := Translator.getString(content)

				ctrl := this.AddControl(ctrl_type, part . A_Index, ctrl_options, content)
				part.controls.Insert(ctrl.hwnd)

				if (ctrl_type = "hiedit")
				{
					for property, color in PresentationWindow.HiEdit_ColorSet
						ctrl.Colors[property] := color
					if (!ctrl_node.getAttribute("highlight").in([0, "false"]))
					{
						ctrl.hilight := true
						, ctrl.KeywordFile := A_ScriptDir "\resources\Keywords.hes"
					}
				}

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

				if (exec_button)
				{
					button := this.AddControl("Button", part . A_Index . "exec", "w100 x" (pos.x + pos.w) " y" pos.y " h" pos.h, Translator.getString("execute"))
					, ctrl.exec_button := button, button.code_edit := ctrl
					, button.Click.Handler := new Delegate(this, "ExecEditCode")
				}
			}
			else if (ctrl_type = "browser")
			{
				err := ComObjError(false)
				, ctrl := this.AddControl("ActiveX", part . A_Index, ctrl_options, "Shell.Explorer")
				, ComObjError(err)
				, part.controls.Insert(ctrl.hwnd)

				, is_localized := ctrl_node.getAttribute("localized") = "true"
				, ctrl.Navigate(A_ScriptDir "\resources\" (is_localized ? "localized\" Translator.Language "\" : "") ctrl_node.getAttribute("resource"))

				while (ctrl.busy || ctrl.readyState != READYSTATE_COMPLETE)
					sleep 100
			}

			event_list := ctrl_node.selectNodes("event")
			Loop % event_list.length
			{
				event_node := event_list.item(A_Index - 1)
				, event_name := event_node.getAttribute("name")
				, event_handler := event_node.getAttribute("handler")
				, event_handler_type := event_node.getAttribute("handler-type")

				if event_handler_type not in function,label
				{
					throw Exception("Unknown event handler type!", -1)
				}
				else if (event_handler_type = "function")
				{
					if (!IsFunc(event_handler))
						throw Exception("Unknown function '" . event_handler . "' called!", -1)
					event_handler := Func(event_handler)
				}
				else if (event_handler = "label")
					event_handler := Label(event_handler)

				ctrl[event_name].handler := event_handler
			}

			if (part.is_steps && ctrl_node.getAttribute("step") != 0)
			{
				ctrl.Hide()
				if (exec_button)
					ctrl.exec_button.Hide()
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
		, ctrls := []

		Loop % nodes.length
		{
			node := nodes.item(A_Index - 1)
			if (node.getAttribute("step") == step)
			{
				ctrl_hwnd := part.Controls[A_Index]
				, ctrl := this.Controls[ctrl_hwnd]
				, ctrls.Insert(ctrl)
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
			{
				ctrl.Show()
				if (ctrl.exec_button)
					ctrl.exec_button.Show()
			}
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
			, this.loadPart(part) ; load next part in array
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
			, this.loadPart(part) ; load previous part
		}
		else
		{
			ctrls := this._get_ctrls(this.loaded, this.loaded.step--)
			for i, ctrl in ctrls
			{
				ctrl.Hide()
				if (ctrl.exec_button)
					ctrl.exec_button.Hide()
			}
		}
	}

	hidePart(part)
	{
		for i, control in part.controls
		{
			this.Controls[control].Hide()
			if (this.Controls[control].exec_button)
				this.Controls[control].exec_button.Hide()
		}
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
		, this.loadPart(item.part)
	}

	ExecEditCode(button)
	{
		static temp_file := A_ScriptDir . "\temp.ahk"

		if (FileExist(temp_file))
			FileDelete %temp_file%
		FileAppend % button.code_edit.Text, %temp_file%
		Run %A_ScriptDir%\AutoHotkey.exe "%temp_file%"
	}
}