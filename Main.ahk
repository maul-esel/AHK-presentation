;*********** <SETTINGS> ***********
#NoEnv
#SingleInstance Force
#KeyHistory 0

SetBatchLines -1
SetWorkingDir %A_ScriptDir%
;*********** </SETTINGS> **********

String.init()

pres := new Presentation()
gui := new PresentationWindow(pres)

gui.Maximize()
gui.Show()

return

;*********** <INCLUDES> ***********
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
#include PresentationWindow.ahk
#include QuickEditWindow.ahk
#Include LabelReference.ahk
#include misc.ahk

#Include MeasureText.ahk
;*********** </INCLUDES> **********

^!R::Reload
^!C::gui.QuickEdit.Visible ? gui.QuickEdit.SlideOut() : gui.QuickEdit.SlideIn()

^!Z::gui.continue()
^!Y::gui.back()