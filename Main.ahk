;*********** <SETTINGS> ***********
#NoEnv
#SingleInstance Force
#KeyHistory 0

SetBatchLines -1
SetWorkingDir %A_ScriptDir%
;*********** </SETTINGS> **********

String.init()

s := new splashScreen() ; show splashscreen

, pres := new Presentation()
, gui := new PresentationWindow(pres)

, SetRedraw(gui, false)
, CreateAllParts(pres.parts, gui)
, SetRedraw(gui, true)
, gui.Redraw()

, gui.Maximize()
, gui.Show()

, s.Close() ; end splashscreen

return

;*********** <INCLUDES> ***********
#include %A_ScriptDir%\_Struct
#include sizeof.ahk
#Include _Struct.ahk
#include %A_ScriptDir%\CGUI
#include CGUI.ahk
#Include CHiEditControl.ahk

#include %A_ScriptDir%\Canvas
#include Canvas.ahk

#include %A_ScriptDir%\ahk_library\lib
#include lib_CORE.ahk

#include %A_ScriptDir%
#include Translator.ahk
#include Presentation.ahk

#Include LabelReference.ahk
#include misc.ahk

#include %A_ScriptDir%\UI
#Include Viewbox.ahk
#Include ContentArea.ahk

#Include CProxyFont.ahk
#Include CExecutableCodeControl.ahk
#Include CListControl.ahk

#include PresentationWindow.ahk
#include QuickEditWindow.ahk
#include SplashScreen.ahk

#Include MeasureText.ahk
;*********** </INCLUDES> **********

^!R::Reload
^!C::gui.QuickEdit.Visible ? gui.QuickEdit.SlideOut() : gui.QuickEdit.SlideIn()

^!Z::gui.continue()
^!Y::gui.back()

Esc::ExitApp