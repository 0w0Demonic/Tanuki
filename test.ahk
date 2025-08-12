#Requires AutoHotkey v2
#Include "%A_LineFile%/../tanuki.ahk"
#Include <AquaHotkeyX>

class GuiProxy {
    class Edit {

    }
}

g := Gui("Theme:Catppuccin")

Pb := g.AddCommandLink(, "Download free RAM",
            "We speeding up your PC with this one 🔥")

LB := g.AddListBox("r4")
Et := g.AddEdit("r1 w400")

LV := g.AddListView(unset, Array("Hello", "World", "Foo", "Bar"))

LV.Add(unset, "Value1", "Value2", "Value3", "Value4")

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
