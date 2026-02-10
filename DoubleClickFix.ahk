; AutoHotkey v2 — v2.2 FIXED: Better taskbar double-click reliability
; No more "stuck hold" requiring right-click reset
; Handles rapid doubles on taskbar previews/icons without desync

#SingleInstance Force
#Requires AutoHotkey v2.0+

threshold_ms := 35     ; 40-60 ms sweet spot
enabled := true
button_down_sent := false   ; renamed for clarity

$LButton::
{
    global threshold_ms, enabled, button_down_sent

    if !enabled {
        SendInput "{Blind}{LButton down}"
        return
    }

    ; Drop bounce presses
    if (A_TimeSincePriorHotkey != "" && A_TimeSincePriorHotkey < threshold_ms) {
        return
    }

    SendInput "{Blind}{LButton down}"
    button_down_sent := true
}

$LButton up::
{
    global enabled, button_down_sent

    if !enabled {
        SendInput "{Blind}{LButton up}"
        return
    }

    ; Always send up if we sent a down (prevents stuck)
    if button_down_sent {
        SendInput "{Blind}{LButton up}"
        button_down_sent := false
    }
    ; If no matching down → ignore (bounce up or desync recovery)
}

; Toggle with safety reset
^!s::
{
    global enabled, button_down_sent

    enabled := !enabled

    ; Force release if toggling off mid-hold
    if !enabled && button_down_sent {
        SendInput "{Blind}{LButton up}"
        button_down_sent := false
    }

    state := enabled ? "ACTIVE ✅" : "OFF ❌ (raw mouse)"
    ToolTip state " | threshold: " threshold_ms "ms | Taskbar fixed", 10, 10
    SetTimer(() => ToolTip(), -2500)
}

; Startup
ToolTip "G600 Debounce v2.2 – Taskbar doubles fixed`nCtrl+Alt+S toggle", 10, 10
SetTimer(() => ToolTip(), -4000)