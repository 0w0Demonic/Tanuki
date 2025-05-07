#Requires AutoHotkey v2
#Include "%A_LineFile%/../tanuki.ahk"
#Include <AquaHotkeyX>

g := Gui()

Pb := g.AddCommandLink(, "Download free RAM",
            "We speeding up your PC with this one 🔥")

LB := g.AddListBox("r4")

LB.IsDragList := true
LB.OnDragBegin((LbControl, Point) {
    ToolTip(String(Point))
    return true
})

LB.OnDrag((LbControl, Point) {
    ToolTip(String(Point))
})
LB.Add(Array(
    "Hello, world?",
    "Light's are on",
    "But no one's home",
    "Enough's enough",
    "Find your pearl",
    "And fall in love",
    "With a girl <3"))

Rad := g.AddRadio(unset, "Click me?")
g.Show()

esc:: {
    ExitApp()
}


class GuiProxy {

}


class TanukiMessage {
    msg     : u32
    wParam  : uPtr
    lParam  : uPtr
    result  : uPtr
    handled : i32
}
