class PresentationWindow extends CGUI
{
	DestroyOnClose := true
	Caption := false
	Title := Translator.getString("win-title")

	static HiEdit_ColorSet := { "Back" : "black", "Text" : "white", "SelBarBack" : "black", "LineNumber" : "red", "Number" : "red" }

	QuickEdit := new QuickEditWindow(this)
	NavigationBox := this.AddControl("TreeView", "NavigationBox", "-Buttons x5 y110 w275 h" (0.78 * A_ScreenHeight))
	DefaultContentArea := ""

	__New(pres)
	{
		Base.__New()
		, this.presentation := pres
		, this.Color("white", "white")

		, this.NavigationBox.Font.Options := "s12"
		, this._read_parts(this.NavigationBox.Items, this.presentation.parts)

		err := ComObjError(false)
		, this.HeaderBar := this.AddControl("ActiveX", "HeaderBar", "x5 y5 h90 w" (0.99 * A_ScreenWidth), "Shell.Explorer")
		, ComObjError(err)
		, this.HeaderBar.Navigate(A_ScriptDir "\resources\localized\" Translator.Language "\header.html")

		, this.DefaultContentArea := this.GetDefaultContentArea()
	}

	_find_latest_descendant(part)
	{
		if (i := part.children.Count())
			return this._find_latest_descendant(part.children.Previous())
		return part
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

	GetDefaultContentArea()
	{
		static static_margin := 10

		elem := this.presentation._doc.documentElement
		for i, prop in ["left", "top", "right", "bottom"]
			margin_%prop% := (t := elem.getAttribute("margin-" prop)) ? t : 0

		x := this.NavigationBox.x + this.NavigationBox.width + static_margin + margin_left
		, y := this.HeaderBar.y + this.HeaderBar.Height + static_margin + margin_top
		, w := this.WindowWidth - x - static_margin - margin_right
		, h := this.WindowHeight - y - static_margin - margin_bottom

		return new ContentArea(x, y, w, h)
	}

	ProcessPosition(ctrl_node, viewbox, content_area)
	{
		ctrl := {}
		for i, opt in ["x", "y", "w", "h"]
		{
			if ((t := ctrl_node.getAttribute(opt)) != "")
				ctrl[opt] := t
		}

		pos := {}
		if (ctrl.HasKey("x"))
			pos.x := floor(ctrl.x / viewbox.Width * content_area.Width + content_area.X)
		if (ctrl.HasKey("y"))
			pos.y := floor(ctrl.y / viewbox.Height * content_area.Height + content_area.Y)
		if (ctrl.HasKey("w"))
			pos.w := floor(ctrl.w / viewbox.Width * content_area.Width)
		if (ctrl.HasKey("h"))
			pos.h := floor(ctrl.h / viewbox.Height * content_area.Height)
		return pos
	}

	loadPart(part, step = 0)
	{
		if (!part.created)
			this.createPart(part)

		this.hidePart(part, step + 1) ; hide future steps (in case we're moving backwards)
		, this.showPart(part, step) ; show previous steps
		, this.currentPart := part
		, this.currentPart.currentStep := step
		, this.NavigationBox.SelectedItem := this.NavigationBox.FindItemWithText(part.localized_name) ; selection will not call loadPart() because it checks if the selected part is already loaded
	}

	unloadPart(step = -1)
	{
		this.hidePart(this.currentPart, step)
		, this.currentPart.currentStep := 0 ; reset part-internal step position
		, this.currentPart := "" ; clear current part reference
	}

	createPart(part)
	{
		ctrl_list := part.node.selectNodes("*")
		, name_prefix := RegExReplace(part.name, "(^[^a-zA-Z#_@\$]|[^\w#@\$])", "_")

		Loop % ctrl_list.length
		{
			ctrl_node := ctrl_list.item(A_Index - 1)
			, ctrl := this.CreateControl(ctrl_node, name_prefix . A_Index)
			, part.controls.Insert(ctrl)
			, ctrl.Hide() ; hide controls for now, later to be shown by <showPart()>
		}
		part.created := true
	}

	CreateControl(ctrl_node, name)
	{
		static CGUI_controls := Obj.keys(CGUI.RegisteredControls), READYSTATE_COMPLETE := 4
		local ctrl_type, content, ctrl, err, is_localized, event_list, event_name, event_handler, event_handler_type
			, ctrl_font := "", ctrl_font_opt := "", ctrl_opt := "", ctrl_options := "", property := "", value := "", color := ""

		ctrl_type := ctrl_node.nodeName
		, this.ProcessStyles(ctrl_node, ctrl_font, ctrl_font_opt, ctrl_opt)
		, pos := this.ProcessPosition(ctrl_node, Viewbox.FromNode(ctrl_node), this.DefaultContentArea)

		for property, value in pos
			ctrl_options .= property . value . A_Space
		ctrl_options .= ctrl_opt

		if (ctrl_type.in(CGUI_controls))
		{
			content := this.GetElementContent(ctrl_node)
			, ctrl := this.AddControl(ctrl_type, name, ctrl_options, content)

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
				ctrl.Font.Font := ctrl_font
			if (ctrl_font_opt)
				ctrl.Font.Options := ctrl_font_opt
		}
		else if (ctrl_type = "browser")
		{
			err := ComObjError(false)
			, ctrl := this.AddControl("ActiveX", name, ctrl_options, "Shell.Explorer")
			, ComObjError(err)

			, is_localized := ctrl_node.getAttribute("localized") = "true"
			, ctrl.Navigate(A_ScriptDir "\resources\" (is_localized ? "localized\" Translator.Language "\" : "") ctrl_node.getAttribute("resource"))

			while (ctrl.busy || ctrl.readyState != READYSTATE_COMPLETE)
				sleep 100
		}
		ctrl._.XMLNode := ctrl_node

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
		return ctrl
	}

	showPart(part, step = 0)
	{
		for i, ctrl in part.controls
		{
			if (step == 0 || step == "")
			{
				if (!(s := ctrl._.XMLNode.getAttribute("step")) || s == 0)
				{
					ctrl.Show()
				}
			}
			else if (step == -1)
			{
				ctrl.Show()
			}
			else
			{
				if (ctrl._.XMLNode.getAttribute("step") <= step)
				{
					ctrl.Show()
				}
			}
		}
	}

	hidePart(part, step = 0)
	{
		for i, ctrl in part.controls
		{
			if (step = 0 || step = "")
			{
				if (!(s := ctrl._.XMLNode.getAttribute("step")) || s == 0)
				{
					ctrl.Hide()
					if (ctrl.exec_button)
						ctrl.exec_button.Hide()
				}
			}
			else if (step == -1)
			{
				ctrl.Hide()
				if (ctrl.exec_button)
					ctrl.exec_button.Hide()
			}
			else
			{
				if (ctrl._.XMLNode.getAttribute("step") >= step)
				{
					ctrl.Hide()
				}
			}
		}
	}

	continue()
	{
		handled := false
		for i, ctrl in this.currentPart.controls
		{
			if (ctrl._.XMLNode.getAttribute("step") = this.currentPart.currentStep) ; filter controls in latest step
			{
				if (ctrl.canIterate) ; is it an iterator control?
				{
					handled := ctrl.Next() || handled ; if so, call Next(). If it really could step further, `handled` is `true` now
				}
			}
		}

		if (handled)
		{
			return
		}
		else if (this.currentPart.currentStep < this.currentPart.steps) ; just load the next step
		{
			this.loadPart(this.currentPart, ++this.currentPart.currentStep)
		}
		else ; no more controls to show, load next part
		{
			coll := this.currentPart.Collection
			, current_index := coll.IndexOf(this.currentPart)
			, max_index := coll.Count()

			if (this.currentPart.children.count() > 0) ; check for nested parts
				part := this.currentPart.children.Next("")
			else if (current_index < max_index) ; check for parts on same level
				part := coll.Next(this.currentPart) ; load the next on this level
			else if (current_index == max_index) ; already displayed last part on this level, so...
			{
				owner := coll.Owner
				if (owner == this.presentation) ; ... first check if we're already in the highest level.
					return ; if so, this was the last. Stop here.
				part := owner.Collection.Next(coll.Owner) ; else go up one level
			}

			this.unloadPart()
			, this.loadPart(part, 0) ; load next part
		}
	}

	back()
	{
		handled := false
		for i, ctrl in this.currentPart.controls
		{
			if (ctrl._.XMLNode.getAttribute("step") = this.currentPart.currentStep) ; filter controls in latest step
			{
				if (ctrl.canIterate) ; is it an iterator control?
				{
					handled := ctrl.Previous() || handled ; if so, call Previous(). If it really could step back, `handled` is `true` now
				}
			}
		}

		if (handled)
		{
			return
		}
		else if (this.currentPart.currentStep > 0) ; check for previous steps
		{
			this.loadPart(this.currentPart, --this.currentPart.currentStep)
		}
		else ; first step of this part already loaded - go to previous part
		{
			coll := this.currentPart.Collection
			, index := coll.IndexOf(this.currentPart)

			if (index > 1) ; get me the previous part, or its latest descendant
			{
				part := this._find_latest_descendant(coll.Previous(this.currentPart))
			}
			else ; no previous part, so ...
			{
				owner := coll.Owner
				if (owner == this.presentation) ; ... first check if we're already in the highest level.
					return ; if so, this was the first part. Stop here.
				part := coll.Owner ; else go one level up
			}

			this.unloadPart()
			this.loadPart(part, part.steps) ; load previous part, latest step
		}
	}

	ProcessStyles(node, byRef font, byRef font_opt, byRef opt)
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

	GetElementContent(node)
	{
		content := node.getAttribute("content")
		if (content)
			return Translator.getString(content)
		else if (node.selectNodes("*").length > 0) ; do not use childNodes as this includes attributes etc.
			return node
		else if (node.text)
			return node.text
	}

	PostDestroy()
	{
		ExitApp
	}

	NavigationBox_ItemSelected(item)
	{
		if (item.part != this.currentPart) ; only load if not already loaded
		{
			this.unloadPart()
			, this.loadPart(item.part)
		}
	}
}