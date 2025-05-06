#Requires AutoHotkey v2
#Include "%A_LineFile%/../tanuki.ahk"
#Include <AquaHotkeyX>

g := Gui()

Pb := g.AddCommandLink(Gui.Button.Style.PushLike, "Download free RAM",
            "We speeding up your PC with this one 🔥")

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