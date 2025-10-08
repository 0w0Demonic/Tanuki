#Requires AutoHotkey v2.0
#Include <AquaHotkey>
#Include <AhkWin32Projection\CStyleArray>
#Include <AhkWin32Projection\Windows\Win32\Foundation\HWND>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\HICON>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\DLGTEMPLATE>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\HPROPSHEETPAGE>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\PROPSHEETPAGEW>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\PROPSHEETHEADERW_V1>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\PROPSHEETHEADERW_V2>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>
#Include <AhkWin32Projection\Windows\Win32\Graphics\Gdi\HBITMAP>
#Include <AhkWin32Projection\Windows\Win32\Graphics\Gdi\HPALETTE>
#Include <AhkWin32Projection\Windows\Win32\System\LibraryLoader\Apis>

;@region DLGTEMPLATE
class Tanuki_DLGTEMPLATE extends AquaHotkey_MultiApply {
    static __New() => super.__New(DLGTEMPLATE)

    Style(Style, ExStyle := 0) {
        this.style := Style
        this.dwExtendedStyle := ExStyle
        return this
    }

    Dimension(x, y, cx, cy) {
        this.x := x
        this.y := y
        this.cx := cx
        this.cy := cy
        return this
    }

    Rect(Left, Top, Right, Bottom) {
        this.x := Left
        this.y := Top
        this.cx := Right - Left
        this.cy := Bottom - Top
        return this
    }

    ; TODO deal with this absolute undocumented hell that's going on beyond
    ; the struct boundary
}
;@endregion

;@region PROPSHEETPAGEW
class Tanuki_PROPSHEETPAGEW extends AquaHotkey_MultiApply {
    static __New() => super.__New(PROPSHEETPAGEW)

    __New() {
        (Win32Struct.Prototype.__New)(this)
        this.dwSize := PROPSHEETPAGEW.sizeof
        this.hInstance := LibraryLoader.GetModuleHandleW(0)
    }

    Resource(Resource) {
        if (!(Resource is DLGTEMPLATE)) {
            throw TypeError("Expected a DLGTEMPLATE",, Type(Resource))
        }

        this.dwFlags |= Controls.PSP_DLGINDIRECT
        this.pResource := Resource.Ptr
        this.__pResource := Resource
        return this
    }

    DialogProc(Fn) {
        GetMethod(Fn)
        this.pfnDlgProc := CallbackCreate(Fn, "Fast")
        return this
    }

    Title(Title) {
        Buf := Buffer(StrPut(Title, "UTF-16"), 0)
        StrPut(Title, Buf, "UTF-16")
        this.__Title := Buf
        this.pszTitle := Buf.Ptr
        this.dwFlags |= Controls.PSP_USETITLE
        return this
    }

    Icon(Icon) {
        if (!(Icon is HICON)) {
            throw TypeError("Expected a HICON or an Integer",, Type(Icon))
        }
        this.hIcon := Icon.Value
        this.dwFlags |= Controls.PSP_USEHICON
        return this
    }

    Param(lParam) {
        this.lParam := lParam
        return this
    }

    Header(Title?, Subtitle?) {
        if (IsSet(Title)) {
            TitleBuf := Buffer(StrPut(Title, "UTF-16"), 0)
            StrPut(Title, TitleBuf, "UTF-16")
            this.pszHeaderTitle := TitleBuf.Ptr
            this.__pszHeaderTitle := TitleBuf
            this.dwFlags |= Controls.PSP_USEHEADERTITLE
        }
        if (IsSet(SubTitle)) {
            SubTitleBuf := Buffer(StrPut(SubTitle, "UTF-16"), 0)
            StrPut(SubTitle, SubTitleBuf, "UTF-16")
            this.pszHeaderSubTitle := SubTitleBuf.Ptr
            this.__pszHeaderSubTitle := SubTitleBuf
            this.dwFlags |= Controls.PSP_USEHEADERSUBTITLE
        }
        return this
    }

    HeaderImage(Bitmap) {
        if (!(Bitmap is HBITMAP)) {
            throw TypeError("Expected an HBITMAP",, Type(Bitmap))
        }
        this.hbmHeader := Bitmap.Value
        return this
    }

    Callback(Fn) {
        GetMethod(Fn)
        this.pfnCallback := CallbackCreate(Fn, "Fast")
        return this
    }

    __Delete() {
        if (this.pszTitle) {
            this.__Title := unset
        }
        if (this.pfnDlgProc) {
            CallbackFree(this.pfnDlgProc)
        }
        if (this.pfnCallback) {
            CallbackFree(this.pfnCallback)
        }
        if (this.pszHeaderTitle) {
            this.__pszHeaderTitle := unset
        }
        if (this.pszHeaderSubTitle) {
            this.__pszHeaderSubTitle := unset
        }
    }
}
;@endregion

;@region PROPSHEETHEADERW
; TODO V1
class Tanuki_PROPSHEETHEADERW extends AquaHotkey_MultiApply {
    static __New() => super.__New(PROPSHEETHEADERW_V2)

    __New() {
        (Win32Struct.Prototype.__New)(this)
        this.dwSize := PROPSHEETHEADERW_V2.sizeof
        this.hInstance := A_ScriptHwnd
        this.hwndParent := A_ScriptHwnd
    }

    Caption(Caption) {
        this.__Caption := Caption
        this.pszCaption := StrPtr(Caption)
    }

    Parent(Hwnd) {
        switch {
            case (Hwnd is HWND):
                Hwnd := Hwnd.Value
            case (IsObject(Hwnd)):
                Hwnd := Hwnd.Hwnd
            case (!IsInteger(Hwnd)):
                throw TypeError("Expected a HWND")
        }
        this.hwndParent := Hwnd
        return this
    }

    Title(Title) {
        TitleBuf := Buffer(StrPut(Title, "UTF-16"), 0)
        StrPut(Title, TitleBuf, "UTF-16")
        this.__pszCaption := TitleBuf
        this.pszCaption := TitleBuf.Ptr
        return this
    }

    Icon(Icon) {
        if (!(Icon is HICON)) {
            throw TypeError("Expected a HICON",, Type(Icon))
        }
        this.dwFlags |= Controls.PSP_USEHICON
        return this
    }

    StartPage(Start) {
        if (IsObject(Start)) {
            throw TypeError("Expected a String or an Integer",, Type(Start))
        }
        if (IsInteger(Start)) {
            if (Start < 1) {
                throw ValueError("Start < 1")
            }
            this.nStartPage := (Start - 1)
            return this
        }
        Buf := Buffer(StrPut(Start, "UTF-16"), 0)
        StrPut(Start, Buf, "UTF-16")

        MsgBox("hi")
        this.__pStartPage := Buf
        this.pStartPage := Buf.Ptr
        this.dwFlags |= Controls.PSH_USEPSTARTPAGE
        return this
    }

    Callback(Fn) {
        GetMethod(Fn)
        this.pfnCallback := CallbackCreate(Fn, "Fast")
        this.dwFlags |= Controls.PSH_USECALLBACK
        return this
    }

    Watermark(Bitmap, Palette?) {
        if (!(Bitmap is HBITMAP)) {
            throw TypeError("Expected an HBITMAP",, Type(Bitmap))
        }
        if (IsSet(Palette) && !(Palette is HPALETTE)) {
            throw TypeError("Expected an HPALETTE",, Type(Palette))
        }
        this.hbmWatermark := Bitmap.Value
        this.dwFlags |= Controls.PSH_USEHBMWATERMARK

        if (!IsSet(Palette)) {
            return this
        }

        this.hplWatermark := Palette.Value
        this.dwFlags |= Controls.PSH_USEHPLWATERMARK
        return this
    }

    Pages(Pages*) {
        if (!Pages.Length) {
            throw UnsetError("No pages set")
        }
        Buf := Buffer(Pages.Length * A_PtrSize, 0)

        for Page in Pages {
            if (!(Page is PROPSHEETPAGEW)) {
                throw TypeError("Expected a PROPSHEETPAGEW",, Type(Page))
            }
            Handle := Controls.CreatePropertySheetPageW(Page)
            if (!Handle) {
                throw Error("Unable to create page: " . A_Index)
            }

            NumPut("Ptr", Handle, Buf.Ptr, (A_Index - 1) * A_PtrSize)
        }
        this.nPages := Pages.Length
        this.__phpage := Buf
        MsgBox("before: " . this.pStartPage)
        this.phpage := Buf.Ptr
        MsgBox("after: " . Format("{:#x}", this.pStartPage))
        return this
    }

    Wizard() {
        Flags := this.dwFlags
        Flags |=  Controls.PSH_WIZARD
        Flags &= ~Controls.PSH_WIZARD97
        Flags &= ~Controls.PSH_WIZARD_LITE
        this.dwFlags := Flags
        return this
    }

    Wizard97() {
        Flags := this.dwFlags
        Flags &= ~Controls.PSH_WIZARD
        Flags |=  Controls.PSH_WIZARD97
        Flags &= ~Controls.PSH_WIZARD_LITE
        this.dwFlags := Flags
        return this
    }

    WizardLite() {
        Flags := this.dwFlags
        Flags &= ~Controls.PSH_WIZARD
        Flags &= ~Controls.PSH_WIZARD97
        Flags |=  Controls.PSH_WIZARD_LITE
        this.dwFlags := Flags
        return this
    }

    HeaderImage(Bitmap) {
        if (!(Bitmap is HBITMAP)) {
            throw TypeError("Expected an HBITMAP",, Type(Bitmap))
        }
        this.hbmHeader := Bitmap.Value
        this.dwFlags |= Controls.PSH_USEHBMHEADER
        return this
    }

    __Delete() {
        this.__Caption := unset
        if (this.pfnCallback) {
            CallbackFree(this.pfnCallback)
        }
        this.__pStartPage := unset
        this.__phpage := unset
    }
}
;@endregion

#Include <Tanuki\util\Dump>

Page := PROPSHEETPAGEW()
Handle := Controls.CreatePropertySheetPageW(Page)
if (!Handle) {
    MsgBox("Unable to create page")
}

Header := PROPSHEETHEADERW_V2()
    .Pages(Page)
    .Wizard()
    .Title("My Property Sheet")


MsgBox(Header.HexDump())
MsgBox(Header.DumpProps())

MsgBox(Controls.PropertySheetW(Header))

^+a:: {
    ExitApp()
}