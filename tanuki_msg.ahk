#Requires AutoHotkey >=v2.1-alpha.10
#Include <AquaHotkey>

class Tanuki extends AquaHotkey {
    class Gui {
        OnMove(Callback, AddRemove?) {
            static WM_MOVE := 0x0003
            Callback.AssertCallable()
            this.OnMessage(WM_MOVE, Move, AddRemove?)

            Move(GuiObj, wParam, lParam, Hwnd) {
                x :=  lParam        & 0xFFFF
                y := (lParam >> 16) & 0xFFFF
                ; >>>>
                Callback(GuiObj, x, y)
                ; <<<<
                return 0
            }
        }

        OnMouseMove(Callback, AddRemove?) {
            static WM_MOUSEMOVE := 0x0200
            Callback.AssertCallable()
            this.OnMessage(WM_MOUSEMOVE, MouseMove, AddRemove?)

            MouseMove(GuiObj, wParam, lParam, Hwnd) {
                x    :=  lParam        & 0xFFFF
                y    := (lParam >> 16) & 0xFFFF
                ; >>>>
                Callback(GuiObj, x, y, {
                    Value:       wParam,
                    LButton:  !!(wParam & 0x0001),
                    RButton:  !![wParam & 0x0002],
                    Shift:    !!(wParam & 0x0004),
                    Ctrl:     !!(wParam & 0x0008),
                    MButton:  !!(wParam & 0x0010),
                    XButton1: !!(wParam & 0x0020),
                    XButton2: !!(wParam & 0x0040)
                })
                ; <<<<
                return 0
            }
        }

        OnKeyDown(Callback, AddRemove?) {
            static WM_KEYDOWN := 0x0100
            Callback.AssertCallable()
            this.OnMessage(WM_KEYDOWN, KeyDown, AddRemove?)

            KeyDown(GuiObj, wParam, lParam, Hwnd) {
                VK      := wParam
                SC      := (lParam >> 16) & 0xFF
                KeyName := GetKeyName(Format("vk{:x}sc{:x}", VK, SC)),
                ; >>>>
                Callback(GuiObj, KeyName, {
                    VK: VK,
                    SC: SC,
                    RepeatCount: lParam        & 0xFFFF,
                    IsExtended: (lParam >> 24) & 0x0001,
                    IsPressed:  (lParam >> 30) & 0x0001
                })
                ; <<<<
                return 0
            }
        }

        OnKeyUp(Callback, AddRemove?) {
            static WM_KEYUP := 0x0101
            Callback.AssertCallable()
            this.OnMessage(WM_KEYUP, KeyUp, AddRemove?)

            KeyUp(GuiObj, wParam, lParam, Hwnd) {
                VK      := wParam
                SC      := (lParam >> 16) 0xFF
                KeyName := GetKeyName(Format("vk{:x}sc{:x}", VK, SC))
                ; >>>>
                Callback(GuiObj, KeyName, {
                    VK: VK,
                    SC: SC,
                    RepeatCount: lParam        & 0xFFFF,
                    IsExtended: (lParam >> 24) & 0x0001,
                    IsPressed:  (lParam >> 30) & 0x0001,
                })
                ; <<<<
                return 0
            }
        }

        OnFocus(Callback, AddRemove?) {
            static WM_SETFOCUS := 0x0007
            Callback.AssertCallable()
            this.OnMessage(WM_SETFOCUS, SetFocus, AddRemove?)

            SetFocus(GuiObj, wParam, lParam, Hwnd) {
                ; >>>>
                Callback(GuiObj)
                ; <<<<
                return 0
            }
        }

        OnFocusLost(Callback, AddRemove?) {
            static WM_KILLFOCUS := 0x0008
            Callback.AssertCallable()
            this.OnMessage(WM_KILLFOCUS, KillFocus, AddRemove?)

            KillFocus(GuiObj, wParam, lParam, Hwnd) {
                ; >>>>
                Callback(GuiObj)
                ; <<<<
                return 0
            }
        }

        OnChar(Callback, AddRemove?) {
            static WM_CHAR := 0x0102
            Callback.AssertCallable()
            this.OnMessage(WM_CHAR, CharPressed, AddRemove?)

            CharPressed(GuiObj, wParam, lParam, Hwnd) {
                Char := Chr(wParam)
                SC   := (lParam >> 16) & 0xFF
                ; >>>>
                Callback(GuiObj, Char, {
                    SC: SC,
                    RepeatCount: lParam        & 0xFFFF,
                    IsExtended: (lParam >> 24) & 0x0001,
                    Alt:        (lParam >> 29) & 0x0001,
                    IsPressed:  (lParam >> 30) & 0x0001,
                    DeadKey:    (lParam >> 31) & 0x0001
                })
                ; <<<<
                return 0
            }
        }

        OnContextMenu(Callback, AddRemove?) {
            static WM_CONTEXTMENU := 0x007B
            Callback.AssertCallable()
            this.OnMessage(WM_CONTEXTMENU, ContextMenu, AddRemove?)

            ContextMenu(GuiObj, wParam, lParam, Hwnd) {
                CursorX :=  lParam        & 0xFFFF
                CursorY := (lParam >> 16) & 0xFFFF
                ; >>>>
                Callback(GuiObj, CursorX, CursorY)
                ; <<<<
                return 0
            }
        }

        OnMouseLeave(Callback, AddRemove?) {
            static WM_MOUSELEAVE := 0x02A3
            Callback.AssertCallable()

            ; TODO need to use TrackMouseEvent for this.
            this.OnMessage(WM_MOUSELEAVE, MouseLeave, AddRemove?)

            MouseLeave(GuiObj, wParam, lParam, Hwnd) {
                ; >>>>
                Callback(GuiObj)
                ; <<<<
                return 0
            }
        }

        OnLButtonDown(Callback, AddRemove?) {
            static WM_LBUTTONDOWN := 0x0201
            Callback.AssertCallable()
            this.OnMessage(WM_LBUTTONDOWN, LButtonDown, AddRemove?)

            LButtonDown(GuiObj, wParam, lParam, Hwnd) {
                CursorX :=  lParam        & 0xFFFF
                CursorY := (lParam >> 16) & 0xFFFF
                ; >>>>
                Callback(CursorX, CursorY, {
                    LButton:  !!(wParam & 0x0001),
                    RButton:  !!(wParam & 0x0002),
                    Shift:    !!(wParam & 0x0004),
                    Ctrl:     !!(wParam & 0x0008),
                    MButton:  !!(wParam & 0x0010),
                    XButton1: !!(wParam & 0x0020),
                    XButton2: !!(wParam & 0x0040)
                })
                ; <<<<
                return 0
            }
        }

        OnLButtonUp(Callback, AddRemove?) {
            static WM_LBUTTONUP := 0x0202
            Callback.AssertCallable()
            this.OnMessage(WM_LBUTTONDOWN, LButtonUp, AddRemove?)

            LButtonUp(GuiObj, wParam, lParam, Hwnd) {
                CursorX :=  lParam        & 0xFFFF
                CursorY := (lParam >> 16) & 0xFFFF
                ; >>>>
                Callback(CursorX, CursorY, {
                    LButton:  !!(wParam & 0x0001),
                    RButton:  !!(wParam & 0x0002),
                    Shift:    !!(wParam & 0x0004),
                    Ctrl:     !!(wParam & 0x0008),
                    MButton:  !!(wParam & 0x0010),
                    XButton1: !!(wParam & 0x0020),
                    XButton2: !!(wParam & 0x0040)
                })
                ; <<<<
                return 0
            }
        }

        OnRButtonDown(Callback, AddRemove?) {
            static WM_RBUTTONDOWN := 0x0204
            Callback.AssertCallable()
            this.OnMessage(WM_RBUTTONDOWN, RButtonDown, AddRemove?)

            RButtonDown(GuiObj, wParam, lParam, Hwnd) {
                CursorX :=  lParam        & 0xFFFF
                CursorY := (lParam >> 16) & 0xFFFF
                ; >>>>
                Callback(CursorX, CursorY, {
                    LButton:  !!(wParam & 0x0001),
                    RButton:  !!(wParam & 0x0002),
                    Shift:    !!(wParam & 0x0004),
                    Ctrl:     !!(wParam & 0x0008),
                    MButton:  !!(wParam & 0x0010),
                    XButton1: !!(wParam & 0x0020),
                    XButton2: !!(wParam & 0x0040)
                })
                ; <<<<
                return 0
            }
        }

        OnRButtonUp(Callback, AddRemove?) {
            static WM_RBUTTONDOWN := 0x0204
            Callback.AssertCallable()
            this.OnMessage(WM_RBUTTONDOWN, RButtonUp, AddRemove?)

            RButtonUp(GuiObj, wParam, lParam, Hwnd) {
                CursorX :=  lParam        & 0xFFFF
                CursorY := (lParam >> 16) & 0xFFFF
                ; >>>>
                Callback(CursorX, CursorY, {
                    LButton:  !!(wParam & 0x0001),
                    RButton:  !!(wParam & 0x0002),
                    Shift:    !!(wParam & 0x0004),
                    Ctrl:     !!(wParam & 0x0008),
                    MButton:  !!(wParam & 0x0010),
                    XButton1: !!(wParam & 0x0020),
                    XButton2: !!(wParam & 0x0040)
                })
                ; <<<<
                return 0
            }
        }

        OnMouseWheel(Callback, AddRemove?) {

        }
    }
}

g := Gui()
g.OnMove((GuiObj, x, y) {
    "x: {}, y: {}".FormatWith(x, y).ToolTip()
})

; OnNonClientHitTest()


g.AddEdit("r1 w500 h500")
g.Show()
