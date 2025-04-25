#Include "%A_LineFile%/../tanuki.ahk"


g        := Gui("Theme:Catppuccin")
Btn      := g.AddButton(unset, "Hello, world!")
DDLCtl   := g.AddDropDownList(unset, Array("this", "is", "a", "test"))

Edt      := g.AddEdit("r10 w380")

MonthCal := g.AddMonthCal()
SldrCtl  := g.AddSlider("r4 w350", 50)
RadioCtl := g.AddRadio(unset, "Click me?")
LVCtl    := g.AddListView(unset, StrSplit("Apple Banana Carrot Date Eggplant", A_Space))

g.Show()

; ...

Edt.WebSearch.Enable()
Edt.OnWebSearch((EditControl, EntryPoint, HasQuery, Success) {
    if (HasQuery && Success) {
        MsgBox("wow!!!")
    }
})

^y:: {
    Edt.WebSearch()
}

esc:: {
    ExitApp()
}
