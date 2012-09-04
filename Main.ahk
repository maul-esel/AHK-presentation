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

#include %A_ScriptDir%\Canvas
#include Canvas.ahk

#include %A_ScriptDir%\ahk_library\lib
#include lib_CORE.ahk

#include %A_ScriptDir%
#include Translator.ahk
#include Presentation.ahk
#include PresentationWindow.ahk
;*********** </INCLUDES> **********

#R::Reload

#Z::gui.continue()
#Y::gui.back()