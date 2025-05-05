#Requires AutoHotkey v2
#Include "%A_LineFile%/../tanuki.ahk"
#Include <AquaHotkeyX>

g        := Gui("Theme:Catppuccin")
Btn      := g.AddButton("h34.000", "Hello, world!")
DDLCtl   := g.AddDropDownList(unset, Array("this", "is", "a", "test"))

Edt      := g.AddEdit("r1 w380")

MonthCal := g.AddMonthCal()
SldrCtl  := g.AddSlider("r4 w350", 50)
RadioCtl := g.AddRadio(unset, "Click me?")
LVCtl    := g.AddListView(unset, StrSplit("Apple Banana Carrot Date Eggplant", A_Space))

Cl := g.AddCommandLink(, "Download free RAM", "I swear this is safe!")
Cl.ElevationRequired := true

Sb := g.AddSplitButton(, "Do something")
ReferenceButton := g.AddButton(, "Do something")
Sb.OnDropDown((ButtonControl, Rc) {
    m := Menu()
    for Str in Array("Option 1", "Option 2", "Option 3") {
        m.Add(Str, (*) => false, "")
    }
    m.Show()
})

; ...

Edt.WebSearch.Enable()
Edt.OnWebSearch((EditControl, EntryPoint, HasQuery, Success) {
    if (HasQuery && Success) {
        MsgBox("wow!!!")
    }
})

hIcon := LoadPicture(A_Desktop . "\icon.ico", "w20 h-1")
g.Show()

esc:: {
    ExitApp()
}

^x:: {
    Sb.DropDown()
}

class GuiProxy extends AquaHotkey_Backup {
    static __New() {
        (Tanuki) ; force a load
        super.__New(Gui)
    }

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

class Subclass {
    __New(Hwnd) {
        ; TODO error checks
        this.DefineProp("Hwnd", { Get: (Instance) => Hwnd })
    }

    ;static __New() => OnMessage(WM_TANUKIHOOK := 0x7FFF0000, this.Dispatcher)

    static Dispatcher(wParam, lParam, Msg, Hwnd) {
        ToolTip(wParam " " lParam " " Msg " " Hwnd)
        ; ...
        ;Output.DoDefault := ((Result == "") || (Result == Subclass.DoDefault))
        ;return Result
    }

    static DoDefault {
        get {
            static Obj := Object()
            return Obj
        }
    }

    static OnMessage(MsgNumber, Callback, AddRemove?) {

    }

    static OnNotify(NotifyNumber, Callback, AddRemove?) {
        
    }

    static OnCommand(NotifyNumber, Callback, AddRemove?) {

    }
}

class Injector extends DLL {
    static FilePath => A_LineFile "\..\injector.dll"
    static TypeSignatures => {
        Inject: "UInt, UInt, Str"
    }
}

class TanukiMessage {
    msg     : u32
    wParam  : uPtr
    lParam  : uPtr
    result  : uPtr
    handled : i32
}
