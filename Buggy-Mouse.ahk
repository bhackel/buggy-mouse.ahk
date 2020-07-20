/*
**    Buggy-Mouse.ahk - Fix a buggy mouse. Stop it from double-clicking when you try to single-click.
**    Authors: JSLover - Forked by bhackel
**    AutoHotkey 1.1+
**
*/
#SingleInstance force

;// **************************** Settings ****************************

;// Minimum double-click time. Any lower & it will be blocked (as being inhumanly fast).
DoubleClickMin_ms:=90


;// **************************** / Settings ****************************

;// *** Build Tray Menu ***

Text_ClicksBlocked=Clicks Blocked

Menu, Tray, Add, %Text_ClicksBlocked%, BuggyMouse_MenuSelect_ClicksBlocked
    Text_ClicksBlocked_MenuCurrent := Text_ClicksBlocked
Menu, Tray, Default, %Text_ClicksBlocked%

Menu, Tray, MainWindow
Menu, Tray, NoStandard
Menu, Tray, Add
Menu, Tray, Standard

;// *** /Build Tray Menu ***

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
    LastMouseDown:=A_ThisHotkey
    LastMouseDown_ts:=A_TickCount
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
    blockeddown=
    blockedup=
    LastMouseUp:=A_ThisHotkey
    LastMouseUp_ts:=A_TickCount
return

BuggyMouse_UpdateStatus_ClicksBlocked:
    BlockedCount_Total := BlockedCount_Down+BlockedCount_Up
    Text_ClicksBlocked_MenuNew = %Text_ClicksBlocked%: %BlockedCount_Total%
    Menu, Tray, Rename, %Text_ClicksBlocked_MenuCurrent%, %Text_ClicksBlocked_MenuNew%
    Text_ClicksBlocked_MenuCurrent := Text_ClicksBlocked_MenuNew
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

^+#!F9::Suspend
^+#!F12::ExitApp