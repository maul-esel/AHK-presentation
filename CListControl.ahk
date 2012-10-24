#include %A_ScriptDir%\CGUI\Parse.ahk
#include %A_ScriptDir%\CGUI\CCompoundControl.ahk

class CListControl extends CCompoundControl
{
	; ===== iterator control =====
	initialIndex := 1
	canIterate := true

	Next()
	{
		if (this._.currIndex < this._.item_count)
		{
			this._.currIndex++
			if (this.Visible)
				this.ShowCurrent()
			return true
		}
		return false
	}

	Previous()
	{
		if (this._.currIndex > this.initialIndex)
		{
			this._.currIndex--
			if (this.Visible)
				this.ShowCurrent()
			return true
		}
		return false
	}

	Show()
	{
		this.Visible := true
		, this.ShowCurrent()
	}

	ShowCurrent()
	{
		Loop % this._.item_count
		{
			this.Container["marker" A_Index].visible := A_Index <= this._.currIndex
			, this.Container["item" A_Index].visible := A_Index <= this._.currIndex
		}
	}
	; ============================

	static registration := CGUI.RegisterControl("List", CListControl)

	__New(Name, Options, self, GUINum)
	{
		GUI := CGUI.GUIList[GUINum]
		, Parse(Options, "x* y* w* h*", x, y, w, h)
		, this.Insert("_", { "x" : x, "y" : y, "w" : w, "h" : h, "currIndex" : this.initialIndex, "node" : self })
		, this.Font := new CListControl.CListFont(this, this._update)

		content := self.selectNodes("item")
		Loop % this._.item_count := content.length
		{
			item := content.item(A_Index - 1)

			; don't care about positions as this is handled by the _update() method.
			, this.AddContainerControl(GUI, "Text", "marker" A_Index, "x" x " y" y " w" w " h" h, this._get_marker(A_Index))
			, this.AddContainerControl(GUI, "Text", "item" A_Index,   "x" x " y" y " w" w " h" h, Translator.getString(item.getAttribute("content")))
		}
		this._update() ; do initial repositioning

		return Name
	}

	_update()
	{
		static marker_margin := 5

		; ===== get all markers + widths =====
		markers := [], marker_widths := []
		Loop % this._.item_count
		{
			markers[A_Index] := this._get_marker(A_Index)
			, marker_widths[A_Index] := MeasureText(markers[A_Index], this.Font.Options, this.Font.Font).W
		}

		; ===== get maximum marker width => item width =====
		max_marker_width := Math.maxObj(marker_widths)
		, item_width := this._.w - max_marker_width

		; ===== calculate item heights =====
		items := [], item_heights := [], total_item_height := 0
		Loop % this._.item_count
		{
			items[A_Index] := this.Container["item" A_Index].Text
			, item_heights[A_Index] := MeasureTextHeight(items[A_Index], item_width, this.Font.Options, this.Font.Font)
			, total_item_height += item_heights[A_Index]
		}

		; ===== calculate margin between items =====
		item_margin := (this._.h - total_item_height) / (this._.item_count - 1)

		; ===== change fonts and reposition =====
		height_offset := 0
		Loop % this._.item_count
		{
			marker := this.Container["marker" A_Index]
			, marker.Font.Font := this.Font.Font
			, marker.Font.Options := this.Font.Options
			, marker.Width := max_marker_width
			, marker.Y := this._.y + height_offset
			, marker.X := this._.x

			item := this.Container["item" A_Index]
			, item.Font.Font := this.Font.Font
			, item.Font.Options := this.Font.Options
			, item.Width := item_width
			, item.Height := item_heights[A_Index]
			, item.Y := this._.y + height_offset
			, item.X := this._.x + max_marker_width + marker_margin

			height_offset += item_heights[A_Index] + item_margin
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

		return marker_prefix . marker . marker_suffix ; fallback: the specified string itself is the marker
	}

	class CListFont
	{
		__New(ctrl, changeCallback)
		{
			this.Insert("_", { "changeCallback" : changeCallback, "ctrl" : ctrl })
		}

		__Get(property)
		{
			return this._[property]
		}

		__Set(property, value)
		{
			this._[property] := value
			, this._.changeCallback.(this._.ctrl)
			return value
		}
	}
}