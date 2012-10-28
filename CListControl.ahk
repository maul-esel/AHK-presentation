#include %A_ScriptDir%\CGUI\Parse.ahk
#include %A_ScriptDir%\CGUI\CCompoundControl.ahk

class CListControl extends CCompoundControl
{
	; ===== iterator control =====
	initialIndex := 1
	canIterate := true

	Next()
	{
		handled := this.Items[this._.currIndex].Next()
		if (!handled && this._.currIndex < this._.item_count)
		{
			this._.currIndex++
			if (this.Visible)
				this.ShowCurrent()
			return true
		}
		return handled
	}

	Previous()
	{
		handled := this.Items[this._.currIndex].Previous()
		if (!handled && this._.currIndex > this.initialIndex)
		{
			this._.currIndex--
			if (this.Visible)
				this.ShowCurrent()
			return true
		}
		return handled
	}

	ShowCurrent()
	{
		Loop % this._.item_count
		{
			if (visible := A_Index <= this._.currIndex)
				this.Items[A_Index].Show()
			else
				this.Items[A_Index].Hide()
			this.Container["marker" A_Index].Visible := visible
		}
	}
	; ============================

	static registration := CGUI.RegisterControl("List", CListControl)

	Items := []
	Font := new CProxyFont()

	__New(Name, Options, self, GUINum)
	{
		GUI := CGUI.GUIList[GUINum]
		, Parse(Options, "x* y* w* h*", x, y, w, h)
		, this.Insert("_", { "x" : x, "y" : y, "w" : w, "h" : h, "currIndex" : this.initialIndex, "node" : self, "GuiNum" : GUINum, "item_count" : 0 })
		, content := self.selectNodes("item")

		Loop % content.length
		{
			item := content.item(A_Index - 1)
			, this.Items[A_Index] := new CListControl.Item(GUI, this, item, A_Index)
			, this._.item_count++ ; increase step by step to avoid looping through non-existent items in UpdatePositions() (might be called from CListControl.Item constructor)

			, opt := ""
			, GUI.ProcessStyles(item, "", "", opt)
			, this.AddContainerControl(GUI, "Text", "marker" A_Index, "x" x " y" y " w" w " h" h A_Space opt, this._get_marker(A_Index))
			; do not care for position or fonts now, as these are later to be handled by the UpdatePositions() method or the CListControl.Item class itself.
		}
		this.UpdatePositions() ; do initial repositioning

		return Name
	}

	Show()
	{
		this.Visible := true
		, this.ShowCurrent()
	}

	Hide()
	{
		Base.Hide()
		for i, item in this.Items
			item.Hide()
	}

	UpdatePositions()
	{
		static marker_margin := 5, item_padding := 5
		local item_heights := [], markers := [], max_marker_width := 0, height_offset := 0, GUI := CGUI.GUIList[this._.GUINum], y := this._.y, total_item_height := 0, item_width := 0
			,  m, w, h, x, i, item_margin, font, font_opt

		this._markers(markers, max_marker_width)
		, item_width := this._.w - max_marker_width
		, this._heights(item_width, item_heights, total_item_height)

		item_margin := this._.item_count > 1 ? (this._.h - total_item_height) / (this._.item_count - 1) : 0

		x := this._.x + max_marker_width + marker_margin
		Loop % this._.item_count
		{
			; move items
			this.Items[A_Index].Move(x, y, item_width, item_heights[A_Index])

			; move and update markers
			font := font_opt := ""
			, GUI.ProcessStyles(this.Items[A_Index].Node, font, font_opt, "") ; options are only set on startup

			marker := this.Container["marker" A_Index]
			, marker.Font.Font := font ? font : this.Font.Font
			, marker.Font.Options := font_opt ? font_opt : this.Font.Options
			, marker.Width := max_marker_width
			, marker.Y := y
			, marker.X := this._.x

			y += item_heights[A_Index] + item_margin
		}
	}

	_heights(width, byRef list, byRef total_height)
	{
		local h
		static item_padding := 5

		list := [], total_height := 0
		Loop % this._.item_count
		{
			; calculate items positions
			h := list[A_Index] := this.Items[A_Index].GetRequiredHeight(width) + item_padding
			, total_height += h
		}
	}

	_markers(byRef list, byRef max_width)
	{
		local m, w

		list := []
		Loop % this._.item_count
		{
			; get each marker and the maximum width
			m := list[A_Index] := this._get_marker(A_Index)
			, max_width := (w := MeasureText(m, this.Font.Options, this.Font.Font).W) > max_width ? w : max_width
		}
	}

	_get_marker(i)
	{
		static ul_markers := { "bullet" : Chr(0x2022), "white-bullet" : Chr(0x25E6), "triangle" : Chr(0x2023), "arrow" : Chr(0x2192), "double-arrow" : Chr(0x21D2) }, default_marker := "bullet"

		marker := (marker := this._.node.getAttribute("marker")) ? marker : default_marker
		, marker_prefix := this._.node.getAttribute("marker-prefix")
		, marker_suffix := this._.node.getAttribute("marker-suffix")

		if (ul_markers.hasKey(marker))
			return marker_prefix . ul_markers[marker] . marker_suffix
		else if (marker = "number")
			return marker_prefix . i . marker_suffix

		return marker_prefix . marker . marker_suffix ; fallback: the specified string itself is the marker
	}

	#Include CListControl.Item.ahk
}