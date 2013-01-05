; ======================================================================================================================
; Function:       Measures the single-line width and height of the passed text.
; AHK version:    1.1.05+
; Language:       English
; Tested on:      Win XPSP3 (U32)
; Version:        1.0.00.00/2012-06-28/just me
; Parameters:
;     Str         -  String to measure.
;     Optional       ---------------------------------------------------------------------------------------------------
;     FontOpts    -  Options used with the Gui, Font, ... command.
;                    Default: "" - Default GUI font options
;     FontName    -  Font name used with the Gui, Font, ... command.
;                    Default: "" - Default GUI font
; Return value:   Object containing two key/value pairs:
;                    W  -  measured width.
;                    H  -  measured height.
;
; Function by "just me" <http://www.autohotkey.com/community/viewtopic.php?f=13&t=88163>
; ======================================================================================================================
MeasureText(Str, FontOpts = "", FontName = "") {
	Static DT_FLAGS := 0x0520 ; DT_SINGLELINE = 0x20, DT_NOCLIP = 0x0100, DT_CALCRECT = 0x0400
	Static WM_GETFONT := 0x31

	Size := {}
	Gui, New
	If (FontOpts <> "") || (FontName <> "")
		Gui, Font, %FontOpts%, %FontName%
	Gui, Add, Text, hwndHWND
	SendMessage, WM_GETFONT, 0, 0, , ahk_id %HWND%
	HFONT := ErrorLevel
	HDC := DllCall("User32.dll\GetDC", "Ptr", HWND, "Ptr")
	DllCall("Gdi32.dll\SelectObject", "Ptr", HDC, "Ptr", HFONT)
	VarSetCapacity(RECT, 16, 0)
	DllCall("User32.dll\DrawText", "Ptr", HDC, "Str", Str, "Int", -1, "Ptr", &RECT, "UInt", DT_FLAGS)
	DllCall("User32.dll\ReleaseDC", "Ptr", HWND, "Ptr", HDC)
	Gui, Destroy
	Size.W := NumGet(RECT,  8, "Int")
	Size.H := NumGet(RECT, 12, "Int")
	Return Size
}

; function by maul.esel, inspired by above
MeasureTextHeight(Str, Width, FontOpts = "", FontName = "")
{
	Static DT_FLAGS := 0x0530 ; DT_SINGLELINE = 0x20, DT_NOCLIP = 0x0100, DT_CALCRECT = 0x0400, DT_WORDBREAK = 0x10
	Static WM_GETFONT := 0x31

	Gui, New
	If (FontOpts <> "") || (FontName <> "")
		Gui, Font, %FontOpts%, %FontName%
	Gui, Add, Text, hwndHWND

	SendMessage, WM_GETFONT, 0, 0, , ahk_id %HWND%
	HFONT := ErrorLevel
	, HDC := DllCall("User32.dll\GetDC", "Ptr", HWND, "Ptr")
	, DllCall("Gdi32.dll\SelectObject", "Ptr", HDC, "Ptr", HFONT)

	, VarSetCapacity(RECT, 16, 0)
	, NumPut(Width, RECT, 8, "Int")

	, DllCall("User32.dll\DrawText", "Ptr", HDC, "Str", Str, "Int", -1, "Ptr", &RECT, "UInt", DT_FLAGS)
	, DllCall("User32.dll\ReleaseDC", "Ptr", HWND, "Ptr", HDC)

	Gui, Destroy

	Return NumGet(RECT, 12, "Int")
}