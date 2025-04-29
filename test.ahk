#Requires AutoHotkey v2
#Include "%A_LineFile%/../tanuki.ahk"

g        := Gui("Theme:Catppuccin")
Btn      := g.AddButton("0x0F", "Hello, world!")
DDLCtl   := g.AddDropDownList(unset, Array("this", "is", "a", "test"))

Edt      := g.AddEdit("r1 w380")

MonthCal := g.AddMonthCal()
SldrCtl  := g.AddSlider("r4 w350", 50)
RadioCtl := g.AddRadio(unset, "Click me?")
LVCtl    := g.AddListView(unset, StrSplit("Apple Banana Carrot Date Eggplant", A_Space))

Cl := g.AddCommandLink(, "Restart computer")
Cl.Note := "This might take a while (roughly 240.03 days)."

g.Show()

; ...

Edt.WebSearch.Enable()
Edt.OnWebSearch((EditControl, EntryPoint, HasQuery, Success) {
    if (HasQuery && Success) {
        MsgBox("wow!!!")
    }
})

class GuiProxy extends AquaHotkey_Backup {
    static Class => Gui

    ; force load the `Tanuki` class just to be sure
    static __New() => (Tanuki && super.__New())

    class Control {
        __New(Hwnd) {
            if (IsObject(Hwnd)) {
                Hwnd := Hwnd.Hwnd
            }
            if (!IsInteger(Hwnd)) {
                throw TypeError("Expected an Integer or Object",, Type(Hwnd))
            }
            this.DefineProp("Hwnd", { Get: (Instance) => Hwnd })
        }

        static From(Ctl?, WTitle?, WText?, NoTitle?, NoText?) {
            Hwnd := ControlGetHwnd(Ctl?, WTitle?, WText?, NoTitle?, NoText?)
            return this(Hwnd)
        }
    }

    /** Nested `Gui.Control` class which we need to specify base classes. */
    class Edit extends GuiProxy.Control {
    }
    class Button extends GuiProxy.Control {
    }
    class CommandLink extends GuiProxy.Button {
    }
    class SplitButton extends GuiProxy.Button {
    }
}


^x:: {
    
}

esc:: {
    ExitApp()
}

class SIZE {
    cx : i32
    cy : i32
}

