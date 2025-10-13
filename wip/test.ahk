#Requires AutoHotkey v2.1-alpha.16
#SingleInstance Force

#Include <AquaHotkey>
#Include <Tanuki\wip\Dialog>

#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\DLGTEMPLATE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\DLGITEMTEMPLATE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\WINDOW_STYLE>

class DLGTEMPLATEBuilder {
    static BUTTON := 0x0080
    static EDIT := 0x0081
    static STATIC := 0x0082
    
    __New() {
        this.buf := Buffer(8192, 0)
        this.pos := 0
        this.itemCount := 0
        this.itemCountPos := -1
    }
    
    AlignDWORD() {
        this.pos := (this.pos + 3) & ~3
    }
    
    PutWord(v) {
        NumPut("UShort", v & 0xFFFF, this.buf, this.pos)
        this.pos += 2
    }
    
    PutDWord(v) {
        NumPut("UInt", v & 0xFFFFFFFF, this.buf, this.pos)
        this.pos += 4
    }

    PutData(Ptr, Size) {
        Loop Size {
            Offset := (A_Index - 1)
            Num := NumGet(Ptr, Offset, "UChar")
            NumPut("UChar", Num, this.buf.ptr, this.Pos + Offset)
        }
        this.Pos += Size
    }
    
    PutWString(str) {
        if (str = "") {
            this.PutWord(0)
            return
        }
        chars := StrLen(str) + 1
        StrPut(str, this.buf.Ptr + this.pos, chars, "UTF-16")
        this.pos += chars * 2
    }
    
    PutResourceId(val) {
        if (Type(val) = "Integer") {
            this.PutWord(0xFFFF)
            this.PutWord(val & 0xFFFF)
        } else if (val = "" || val = 0) {
            this.PutWord(0)
        } else {
            this.PutWString(val)
        }
    }
    
    CreateDialog(x, y, cx, cy, style := 0x80C800C4, exStyle := 0, caption := "", fontName := "MS Shell Dlg", fontSize := 8) {
        this.pos := 0
        this.itemCount := 0
        
        if (fontName != "")
            style |= 0x40
        
        this.PutDWord(style)
        this.PutDWord(exStyle)
        this.itemCountPos := this.pos
        this.PutWord(0)
        this.PutWord(x)
        this.PutWord(y)
        this.PutWord(cx)
        this.PutWord(cy)
        
        this.PutWord(0)
        this.PutWord(0)
        this.PutWString(caption)
        
        if (fontName != "") {
            this.PutWord(fontSize)
            this.PutWString(fontName)
        }
        
        return this
    }

    Add(Dlg, ClassAtom, Text := "") {
        this.AlignDWORD()
        this.PutData(Dlg.Ptr, Dlg.Size)

        this.PutResourceId(classAtom)
        this.PutResourceId(text)
        
        this.PutWord(0)
        
        this.itemCount++
        return this
    }

    AddControl(Ctl) {
        this.AlignDWORD()
        Ctl.Build()

        this.PutData(Ctl.Ptr, Ctl.Pos)

        this.itemCount++
        return this
    }
    
    AddItem(classAtom, id, x, y, cx, cy, style, exStyle := 0, text := "") {
        this.AlignDWORD()
        
        this.PutDWord(style)
        this.PutDWord(exStyle)
        this.PutWord(x)
        this.PutWord(y)
        this.PutWord(cx)
        this.PutWord(cy)
        this.PutWord(id)
        
        this.PutResourceId(classAtom)
        this.PutResourceId(text)
        
        this.PutWord(0)
        
        this.itemCount++
        return this
    }
    
    Finalize() {
        if (this.itemCountPos >= 0)
            NumPut("UShort", this.itemCount, this.buf, this.itemCountPos)
        this.AlignDWORD()
        return this
    }
    
    Ptr() => this.buf.Ptr
    Size() => this.pos
}

DlgProc(hwnd, msg, wp, lp) {
    if (msg = 0x110)
        return 1
    if (msg = 0x111 && (wp & 0xFFFF) = 1) {
        DllCall("EndDialog", "ptr", hwnd, "int", 1)
        return 1
    }
    if (msg = 0x10) {
        DllCall("EndDialog", "ptr", hwnd, "int", 0)
        return 1
    }
    return 0
}

PropPageProc(hwnd, msg, wp, lp) {
    if (msg = 0x110)
        return 1
    return 0
}

class PropertySheetPage {
    __New(dlgTemplate, title := "Page") {
        this.template := dlgTemplate
        this.psp := Buffer(72, 0)
        this.callback := CallbackCreate(PropPageProc, "F", 4)
        
        NumPut("UInt", 72, this.psp, 0)
        NumPut("UInt", 0x00000800, this.psp, 4)
        NumPut("Ptr", 0, this.psp, 8)
        NumPut("Ptr", dlgTemplate.Ptr(), this.psp, 16)
        NumPut("Ptr", 0, this.psp, 24)
        NumPut("Ptr", StrPtr(title), this.psp, 32)
        NumPut("Ptr", this.callback, this.psp, 40)
        NumPut("Ptr", ObjPtr(this), this.psp, 48)
    }
    
    CreatePage() {
        return DllCall("comctl32\CreatePropertySheetPageW", "ptr", this.psp, "ptr")
    }
    
    __Delete() {
        if (this.HasOwnProp("callback") && this.callback)
            CallbackFree(this.callback)
    }
}

class PropertySheetBuilder {
    __New(title := "Property Sheet") {
        this.pages := []
        this.title := title
    }
    
    AddPage(dlgTemplate, pageTitle) {
        page := PropertySheetPage(dlgTemplate, pageTitle)
        this.pages.Push(page)
        return this
    }
    
    Show(owner := 0) {
        hPages := Buffer(this.pages.Length * A_PtrSize, 0)
        
        for i, page in this.pages {
            hPage := page.CreatePage()
            NumPut("Ptr", hPage, hPages, (i-1) * A_PtrSize)
        }
        
        psh := Buffer(80, 0)
        NumPut("UInt", 80, psh, 0)
        NumPut("UInt", 0x00000040, psh, 4)
        NumPut("Ptr", owner, psh, 8)
        NumPut("Ptr", 0, psh, 16)
        NumPut("Ptr", StrPtr(this.title), psh, 24)
        NumPut("UInt", this.pages.Length, psh, 32)
        NumPut("Ptr", hPages.Ptr, psh, 48)
        
        return DllCall("comctl32\PropertySheetW", "ptr", psh, "int")
    }
}


#Include <AquaHotkey\Src\Builtins\Buffer>

TestDialog() {
    dlg := DLGTEMPLATEBuilder()
    dlg.CreateDialog(0, 0, 200, 100, 0x80C800C4, 0, "Test Dialog", "MS Shell Dlg", 8)

    dlg.AddControl(  DialogItem()
            .Position(10, 10)
            .Size(180, 12)
            .Style(0x50000000, 0)
            .Type(0x0082)
            .Id(1001)
            .Text("This is a DLGTEMPLATE test")
            .Build() )

    ;dlg.AddItem(0x0082, 1001, 10, 10, 180, 12, 0x50000000, 0, "This is a DLGTEMPLATE test")
    MsgBox(ClipboardAll(dlg.buf, dlg.pos).HexDump())


    ;dlg.AddItem(0x0080, 1, 70, 70, 60, 14, 0x50010001, 0, "OK")
    dlg.Finalize()
    
    cb := CallbackCreate(DlgProc, "F", 4)
    result := DllCall("DialogBoxIndirectParamW", "ptr", 0, "ptr", dlg.Ptr(), "ptr", 0, "ptr", cb, "ptr", 0, "int")
    CallbackFree(cb)
    
    MsgBox "Dialog result: " result
}

TestDialog2() {
    GetItem(x, y) {
        return DialogItem()
                .Position(x, y)
                .Size(180, 12)
                .Style(0x50000000, 0)
                .Type(0x0082)
                .Id(1001)
                .Text("This is a DLGTEMPLATE test")
                .Build()
    }

    Dlg := Dialog()
        .Position(0, 0)
        .Size(200, 100)
        .Style(0x80C800C4, 0)
        .Font("MS Shell Dlg", 8)
        .Title("Test Dialog")
        .Controls(GetItem(10, 10), GetItem(10, 50))
        .Build()
    
    MsgBox(ClipboardAll(dlg, dlg.pos).HexDump())

    cb := CallbackCreate(DlgProc, "F", 4)
    result := DllCall("DialogBoxIndirectParamW", "ptr", 0, "ptr", dlg, "ptr", 0, "ptr", cb, "ptr", 0, "int")
    CallbackFree(cb)
    
    MsgBox "Dialog result: " result

}

TestPropertySheet() {
    page1 := DLGTEMPLATEBuilder()
    page1.CreateDialog(0, 0, 252, 218, 0x00000004, 0, "", "MS Shell Dlg", 8)
    page1.AddItem(0x0082, 1001, 10, 10, 230, 12, 0x50000000, 0, "This is Page 1")
    page1.AddItem(0x0081, 1002, 10, 30, 230, 14, 0x50810000, 0, "Edit control")
    page1.Finalize()
    
    page2 := DLGTEMPLATEBuilder()
    page2.CreateDialog(0, 0, 252, 218, 0x00000004, 0, "", "MS Shell Dlg", 8)
    page2.AddItem(0x0082, 2001, 10, 10, 230, 12, 0x50000000, 0, "This is Page 2")
    page2.AddItem(0x0080, 2002, 10, 30, 60, 14, 0x50010003, 0, "Checkbox")
    page2.Finalize()
    
    sheet := PropertySheetBuilder("Test Property Sheet")
    sheet.AddPage(page1, "General")
    sheet.AddPage(page2, "Advanced")
    
    result := sheet.Show()
    MsgBox "Property Sheet result: " result
}

TestDialog()
TestDialog2()
TestPropertySheet()

ExitApp