/*
** Buggy-Mouse.ahk - Fix a buggy mouse. Stop it from double-clicking when you try to single-click.
**
**  	NOTE: Please use this URL when linking to Buggy Mouse: r.secsrv.net/AutoHotkey/Scripts/Buggy-Mouse
**
**   Updated: Thu, Nov 1, 2012 --- 11/1/12, 10:19:19am EDT
**  Location: r.secsrv.net/AutoHotkey/Scripts/Buggy-Mouse
**
**  Keywords: mouse double clicks when I click once
**  Keywords: mouse double clicks when I single click
**  Keywords: mouse double clicks on its own
**  Keywords: mouse double clicks with one click
**  Keywords: mouse double clicks on single click
**  Keywords: mouse double clicks on one click
**  Keywords: mouse double-clicking when you single-click
**  Keywords: set mouse minimum double click speed
**  Keywords: debounce mouse
**
**    Author: JSLover - r.secsrv.net/JSLover - r.secsrv.net/JSLoverAHK
**
**  	NOTE: Please use AutoHotkey 1.1+ for this script!
**  			AHKScript.net/download/ahk-install.exe
**  			AHKScript.net/download
**  			AHKScript.net/boards
**  			AHKScript.net
**
**  	NOTE: Compiled version available here: r.secsrv.net/AutoHotkey/Scripts/Buggy-Mouse.exe
**
*/
#SingleInstance force
OnExit, OnExit

;// **************************** Settings ****************************

;// Minimum double-click time. Any lower & it will be blocked (as being inhumanly fast).
DoubleClickMin_ms:=90

;// *** DISABLED *** ;// Minimum click after mouse-up time. Any lower & it will be blocked (as being inhumanly fast).
;// *** DISABLED *** ClickAfterMouseUpMin_ms:=100

;// **************************** /Settings ****************************

;// **************************** Advanded Settings ****************************

;// Enable logging if you need to report a bug.
;// Default (Disabled): Log=0
Log=0

;// Enable debugging if you want to see blocked/allowed clicks.
;// Default (Disabled): Debug=0
Debug=0

;// Enable this if you only want to see blocked clicks (when debugging is enabled).
;// Default (Enabled): Debug_OnlyBlocked=1
;// Note: Requires Debug (above) to be enabled (or no debugging will happen at all)
Debug_OnlyBlocked=1

;// **************************** /Advanded Settings ****************************

Gosub, OnStartup

;// *** Build Tray Menu ***

Text_ClicksBlocked=Clicks Blocked
Text_Debug=Debug
Text_Debug_OnlyBlocked=Debug (only blocked)

Menu, Tray, Add, %Text_ClicksBlocked%, BuggyMouse_MenuSelect_ClicksBlocked
	Text_ClicksBlocked_MenuCurrent:=Text_ClicksBlocked
	Menu, Tray, Default, %Text_ClicksBlocked%
Menu, Tray, Add, %Text_Debug%, BuggyMouse_MenuSelect_Debug
Menu, Tray, Add, %Text_Debug_OnlyBlocked%, BuggyMouse_MenuSelect_Debug_OnlyBlocked
	Menu, Tray, Disable, %Text_Debug_OnlyBlocked%

Menu, Tray, MainWindow
Menu, Tray, NoStandard
Menu, Tray, Add
Menu, Tray, Standard

;// *** /Build Tray Menu ***

;// BuggyMouse_Debug:=1
;// BuggyMouse_Debug_OnlyBlocked:=1
if (Debug) {
	Gosub, BuggyMouse_MenuSelect_Debug
}

if (Debug_OnlyBlocked) {
	Gosub, BuggyMouse_MenuSelect_Debug_OnlyBlocked
}
return

OnStartup:
logdir=%A_ScriptDir%
logfilename=%A_ScriptName%.log
logfile=%logdir%\%logfilename%

time:=time()
logmsg=
(LTrim
	%A_ScriptName%   Started`t`t%time%
	`  Status`t`tUpDn`t  Key`t`t`tReason`t`t`t`tWindow`n
)
log(logmsg)
return

OnExit:
time:=time()
logmsg=
(LTrim
	%A_ScriptName%    Exited`t`t%time%`n`n
)
log(logmsg)
ExitApp

*LButton::
*MButton::
*RButton::

A_ThisHotkey_VarSafe:=Hotkey_MakeVarSafe(A_ThisHotkey, "*")
A_ThisHotkey_NoModifiers:=Hotkey_RemoveModifiers(A_ThisHotkey)
;// A_ThisHotkey_Modifiers:=Hotkey_GetModifiers(A_ThisHotkey)
A_ThisHotkey_KeyName:=Hotkey_GetKeyName(A_ThisHotkey)

log_key:="Down`t" A_ThisHotkey "`t"
Critical
di++

TimeSinceLastMouseDown:=A_TickCount-LastMouseDown_ts

;// TimeSinceLastMouseUp:=A_TickCount-LastMouseUp_ts

DoubleClickTooFast:=TimeSinceLastMouseDown<=DoubleClickMin_ms

;// *** DISABLED *** ClickAfterMouseUpTooSoon:=(ClickAfterMouseUpMin_ms!="" && TimeSinceLastMouseUp<=ClickAfterMouseUpMin_ms)
;// if ((A_ThisHotkey==LastMouseDown && DoubleClickTooFast) || ClickAfterMouseUpTooSoon) {
if (A_ThisHotkey==LastMouseDown && (DoubleClickTooFast || ClickAfterMouseUpTooSoon)) {
;// if (A_TimeSincePriorHotkey<=DoubleClickMin_ms) {
	reason:=DoubleClickTooFast ? "DoubleClickTooFast" "(" TimeSinceLastMouseDown ")" "(" DoubleClickMin_ms ")"
			: ClickAfterMouseUpTooSoon ? "ClickAfterMouseUpTooSoon" "(" TimeSinceLastMouseUp ")" "(" ClickAfterMouseUpMin_ms ")"
			: "Unknown"
	msg=`nblocked (%reason%)
	blockeddown:=1
	BlockedCount_Down++
	BlockedCount_%A_ThisHotkey_VarSafe%++
	Gosub, BuggyMouse_UpdateStatus_ClicksBlocked

	log_action:="BLOCKED`t"
} else {
	reason:=""
	Send, {Blind}{%A_ThisHotkey_KeyName% DownTemp}
	msg=`nSent, {Blind}{%A_ThisHotkey_KeyName% DownTemp}`n`n
	(LTrim C
		if (%A_ThisHotkey%==%LastMouseDown% && (%DoubleClickTooFast% || %ClickAfterMouseUpTooSoon%))
	)

	log_action:="`tallowed"
}
	BuggyMouse_DebugMsg_down=%di%: %A_ThisHotkey%(%TimeSinceLastMouseDown%)%LastMouseDown%%msg%
	msg=
	Gosub, BuggyMouse_Debug
LastMouseDown:=A_ThisHotkey
LastMouseDown_ts:=A_TickCount

wininfo:=WinGetInfo("a")
log(log_action "`t`t" log_key "`t`t" reason "`t`t`t`t`t" wininfo "`n")
return

*LButton up::
*MButton up::
*RButton up::

A_ThisHotkey_VarSafe:=Hotkey_MakeVarSafe(A_ThisHotkey, "*")
A_ThisHotkey_NoModifiers:=Hotkey_RemoveModifiers(A_ThisHotkey)
;// A_ThisHotkey_Modifiers:=Hotkey_GetModifiers(A_ThisHotkey)
A_ThisHotkey_KeyName:=Hotkey_GetKeyName(A_ThisHotkey)

log_key:=" Up `t" A_ThisHotkey
Critical
ui++
TimeSinceLastMouseUp:=A_TickCount-LastMouseUp_ts
;// if (A_ThisHotkey=A_PriorHotkey && A_TimeSincePriorHotkey<=DoubleClickMin_ms) {
;// if (A_ThisHotkey=LastMouseUp && A_TimeSincePriorHotkey<=DoubleClickMin_ms) {
if (blockeddown) {
	msg=`nblocked
	blockedup:=1
	BlockedCount_Up++
	BlockedCount_%A_ThisHotkey_VarSafe%++
	Gosub, BuggyMouse_UpdateStatus_ClicksBlocked

	log_action:="BLOCKED`t"
} else {
	Send, {Blind}{%A_ThisHotkey_KeyName% up}
	msg=`nSent, {Blind}{%A_ThisHotkey_KeyName% up}
	log_action:="`tallowed"
}
;// if (BuggyMouse_Debug) {
	BuggyMouse_DebugMsg_up=%ui%: %A_ThisHotkey%(%TimeSinceLastMouseUp%)%LastMouseUp%%msg%
	msg=
	Gosub, BuggyMouse_Debug
;// }
blockeddown=
blockedup=
LastMouseUp:=A_ThisHotkey
LastMouseUp_ts:=A_TickCount

wininfo:=WinGetInfo("a")
log(log_action "`t`t" log_key "`t`t" reason "`t`t`t`t`t" wininfo "`n")
return

BuggyMouse_Debug_ShowLastMsg:
;// BuggyMouse_Debug_ShowLastMsg=1
BuggyMouse_Debug:
CoordMode, Tooltip
if (A_ThisLabel="BuggyMouse_Debug_ShowLastMsg"
		|| (BuggyMouse_Debug && (!BuggyMouse_Debug_OnlyBlocked
			|| (BuggyMouse_Debug_OnlyBlocked && (blockeddown||blockedup))))) {
	Tooltip, %BuggyMouse_DebugMsg_down%`n`n%BuggyMouse_DebugMsg_up%, 819, 619
} else {
	Tooltip
}
return

BuggyMouse_UpdateStatus_ClicksBlocked:
BlockedCount_Total:=BlockedCount_Down+BlockedCount_Up
Text_ClicksBlocked_MenuNew=%Text_ClicksBlocked%: %BlockedCount_Total%
Menu, Tray, Rename, %Text_ClicksBlocked_MenuCurrent%, %Text_ClicksBlocked_MenuNew%
Text_ClicksBlocked_MenuCurrent:=Text_ClicksBlocked_MenuNew
Menu, Tray, Tip, %Text_ClicksBlocked_MenuCurrent% - %A_ScriptName%
return

BuggyMouse_MenuSelect_ClicksBlocked:
msgbox, 64, ,
(LTrim C
	%Text_ClicksBlocked_MenuCurrent%

	Down(%BlockedCount_Down%)
	Up(%BlockedCount_Up%)

	LButton(%BlockedCount_LButton%)
	MButton(%BlockedCount_MButton%)
	RButton(%BlockedCount_RButton%)

	LButton up(%BlockedCount_LButton_up%)
	MButton up(%BlockedCount_MButton_up%)
	RButton up(%BlockedCount_RButton_up%)
)
return

BuggyMouse_MenuSelect_Debug:
BuggyMouse_Debug:=!BuggyMouse_Debug
Menu, Tray, ToggleCheck, %Text_Debug%
Menu, Tray, ToggleEnable, %Text_Debug_OnlyBlocked%
Tooltip
return

BuggyMouse_MenuSelect_Debug_OnlyBlocked:
BuggyMouse_Debug_OnlyBlocked:=!BuggyMouse_Debug_OnlyBlocked
Menu, Tray, ToggleCheck, %Text_Debug_OnlyBlocked%
Tooltip
return

Hotkey_MakeVarSafe(p_hotkey, p_ignorechars="") {
	replace:=p_hotkey

	StringReplace, replace, replace, $, % !InStr(p_ignorechars, "$") ? "KH_":""
	StringReplace, replace, replace, ~, % !InStr(p_ignorechars, "~") ? "PT_":""
	StringReplace, replace, replace, *, % !InStr(p_ignorechars, "*") ? "WC_":""

	StringReplace, replace, replace, <^>!, AltGr_
	StringReplace, replace, replace, <, L, a
	StringReplace, replace, replace, >, R, a
	StringReplace, replace, replace, &, and

	StringReplace, replace, replace, ^, Ctrl_, a
	StringReplace, replace, replace, +, Shift_, a
	StringReplace, replace, replace, #, Win_, a
	StringReplace, replace, replace, !, Alt_, a

	replace:=RegExReplace(replace, "i)[^a-z0-9_]", "_")

	p_hotkey:=replace

	return p_hotkey
}

Hotkey_GetModifiers(p_hotkey) {
	return RegExReplace(p_hotkey, "i)[\w\s]+$")
}

Hotkey_RemoveModifiers(p_hotkey) {
	return RegExReplace(p_hotkey, "i)^[^a-z0-9_]+")
}

Hotkey_GetKeyName(p_hotkey) {

	p_hotkey:=Hotkey_RemoveModifiers(p_hotkey)

	;// Get string before 1st space...(removes "up" or "down" from name of key)
	Loop, Parse, p_hotkey, " "
	{
		p_hotkey:=A_LoopField
		break
	}

	return p_hotkey
}

log(p_msg, p_file="") {
	Global Log, logfile
	if (!Log) {
		return
	}
	if (p_file="") {
		p_file:=logfile
	}
	FileAppend, %p_msg%, %p_file%
}

time() {
	FormatTime, time, L1033, ddd, MMM d, yyyy --- M/d/yy h:mm:sstt
	return time
}

WinGetInfo(p_win, ByRef r_win_title="", ByRef r_win_class="") {
	WinGetTitle, win_title, %p_win%
	WinGetClass, win_class, %p_win%

	r_win_title:=(win_title ? win_title:"<no-title-info>")
	r_win_class:=(win_class ? win_class:"<no-class-info>")

	;// wininfo:=(win_title ? win_title:"<no-title-info>") " - " (win_class ? win_class:"<no-class-info>")
	wininfo:=(win_class ? win_class:"<no-class-info>") ": " (win_title ? win_title:"<no-title-info>")
	return wininfo
}

;// #ScrollLock::log("*** PROBLEM ***`n")
^+#!F8::Gosub, BuggyMouse_Debug_ShowLastMsg
^+#!F9::Suspend
^+#!F12::ExitApp

/* ;// **************************** Changelog / Version History ****************************
**
**   Created: Fri, Apr 11, 2008 --- 4/11/08, 11:19:19am
**  Modified: Sat, Apr 12, 2008 --- 4/12/08, 5:38:19am
**  Modified: Sun, Jul 10, 2011 --- 7/10/11, 3:19:19am EDT
**  	* Added blocking of "mouse down too soon after last mouse up"
**  Modified: Wed, Jul 20, 2011 --- 7/20/11, 1:19:19pm EDT
**  Modified: Thu, Aug 25, 2011 --- 8/25/11, 1:19:19am EDT
**  	* Temporarily disabled "mouse down too soon after last mouse up" blocking, until I get it working.
**  Modified: Thu, Aug 25, 2011 --- 8/25/11, 2:38:19am EDT
**  	* Updated Keywords for search engines
**  Modified: Sat, Aug 27, 2011 --- 8/27/11, 7:19:19am EDT
**  	* Added Logging
**  Modified: Sat, Aug 27, 2011 --- 8/27/11, 2:38:19pm EDT
**  	* Added Window Info to log
**  Modified: Sun, May 13, 2012 --- 5/13/12, 7:19:19pm EDT
**  	* Added support for blocking mouse clicks while holding down keyboard keys
**  Modified: Mon, May 14, 2012 --- 5/14/12, 10:19:19am EDT
**  	* Updated Hotkey_MakeVarSafe()
**  Modified: Tue, May 15, 2012 --- 5/15/12, 7:19:19am EDT
**  	* Hotkey_MakeVarSafe(): Fixed error msg/incompatibility with AutoHotkey < 1.1
**  Modified: Thu, Nov 1, 2012 --- 11/1/12, 10:19:19am EDT
**  	* Made Debugging default to Off
**  	* Added "Debug" & "Debug_OnlyBlocked" to Settings section, for easier toggling of the default state
**
*/ ;// **************************** /Changelog / Version History ****************************

+^f12::ExitApp