#Requires AutoHotkey v2.0

#Include <AquaHotkey>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\DLGTEMPLATE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\DLGITEMTEMPLATE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\WINDOW_STYLE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\HICON>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\PROPSHEETPAGEW>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\PROPSHEETHEADERW_V2>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>
#Include <AhkWin32Projection\Windows\Win32\System\LibraryLoader\Apis>
#Include <AhkWin32Projection\Windows\Win32\Graphics\Gdi\HBITMAP>
#Include <AhkWin32Projection\Windows\Win32\Graphics\Gdi\HPALETTE>

#Include <Tanuki\wip\AppendableBuffer>


class DialogTemplate extends AppendableBuffer {
    /**
     * Type: <b>DWORD</b>
     * 
     * The style of the dialog box. This member can be a combination of <a href="https://docs.microsoft.com/windows/desktop/winmsg/window-styles">window style values</a> (such as <b>WS_CAPTION</b> and <b>WS_SYSMENU</b>) and <a href="https://docs.microsoft.com/windows/desktop/dlgbox/dialog-box-styles">dialog box style values</a> (such as <b>DS_CENTER</b>).
     * 
     * If the style member includes the <b>DS_SETFONT</b> style, the header of the dialog box template contains additional data specifying the font to use for text in the client area and controls of the dialog box. The font data begins on the 
     * 						<b>WORD</b> boundary that follows the title array. The font data specifies a 16-bit point size value and a Unicode font name string. If possible, the system creates a font according to the specified values. Then the system sends a <a href="https://docs.microsoft.com/windows/desktop/winmsg/wm-setfont">WM_SETFONT</a> message to the dialog box and to each control to provide a handle to the font. If <b>DS_SETFONT</b> is not specified, the dialog box template does not include the font data. 
     * 
     * The <b>DS_SHELLFONT</b> style is not supported in the <b>DLGTEMPLATE</b> header.
     * @type {Integer}
     */
    style {
        get => NumGet(this, 0, "uint")
        set => NumPut("uint", value, this, 0)
    }

    /**
     * Type: <b>DWORD</b>
     * 
     * The extended styles for a window. This member is not used to create dialog boxes, but applications that use dialog box templates can use it to create other types of windows. For a list of values, see <a href="https://docs.microsoft.com/windows/desktop/winmsg/extended-window-styles">Extended Window Styles</a>.
     * @type {Integer}
     */
    dwExtendedStyle {
        get => NumGet(this, 4, "uint")
        set => NumPut("uint", value, this, 4)
    }

    /**
     * Type: <b>WORD</b>
     * 
     * The number of items in the dialog box.
     * @type {Integer}
     */
    cdit {
        get => NumGet(this, 8, "ushort")
        set => NumPut("ushort", value, this, 8)
    }

    /**
     * Type: <b>short</b>
     * 
     * The x-coordinate, in dialog box units, of the upper-left corner of the dialog box.
     * @type {Integer}
     */
    x {
        get => NumGet(this, 10, "short")
        set => NumPut("short", value, this, 10)
    }

    /**
     * Type: <b>short</b>
     * 
     * The y-coordinate, in dialog box units, of the upper-left corner of the dialog box.
     * @type {Integer}
     */
    y {
        get => NumGet(this, 12, "short")
        set => NumPut("short", value, this, 12)
    }

    /**
     * Type: <b>short</b>
     * 
     * The width, in dialog box units, of the dialog box.
     * @type {Integer}
     */
    cx {
        get => NumGet(this, 14, "short")
        set => NumPut("short", value, this, 14)
    }

    /**
     * Type: <b>short</b>
     * 
     * The height, in dialog box units, of the dialog box.
     * @type {Integer}
     */
    cy {
        get => NumGet(this, 16, "short")
        set => NumPut("short", value, this, 16)
    }

    /**
     * Creates a new dialog template, and initializes the style with
     * `WS_CHILD` and `WS_VISIBLE`.
     */
    __New() {
        super.__New(DLGTEMPLATE.sizeof, 0)
        this.style := WINDOW_STYLE.WS_CHILD | WINDOW_STYLE.WS_VISIBLE
    }

    /**
     * Sets the style and extended style of the dialog template.
     * 
     * @param   {Integer}   Style    style
     * @param   {Integer?}  ExStyle  extended style
     * @returns {this}
     */
    Style(Style, ExStyle := 0) {
        this.style := Style
        this.dwExtendedStyle := ExStyle
        return this
    }

    /**
     * Sets the coordinates of the upper-left corner of the dialog box.
     * 
     * @param   {Integer}  x  x coordinate in dialog box units
     * @param   {Integer}  y  y coordinate in dialog box units
     * @returns {this}
     */
    Position(x, y) {
        this.x := x
        this.y := y
        return this
    }

    /**
     * Assigns the default small size of property sheets for the dialog
     * template.
     */
    Small() {
        this.cx := Controls.PROP_SM_CXDLG
        this.cy := Controls.PROP_SM_CYDLG
        return this
    }

    /**
     * Assigns the default medium size of property sheets for the dialog
     * template.
     */
    Medium() {
        this.cx := Controls.PROP_MED_CXDLG
        this.cy := Controls.PROP_MED_CYDLG
        return this
    }

    /**
     * Assigns the default large size of property sheets for the dialog
     * template.
     */
    Large() {
        this.cx := Controls.PROP_LG_CXDLG
        this.cy := Controls.PROP_LG_CYDLG
        return this
    }

    /**
     * Sets the size of the dialog template in dialog box units.
     * 
     * @param   {Integer}  Width   the width in dialog box units
     * @param   {Integer}  Height  the height in dialog box units
     * @returns {this}
     */
    Size(Width, Height) {
        this.cx := Width
        this.cy := Height
        return this
    }

    /**
     * 
     * 
     * @returns {this}
     */
    Font(FontName, FontSize) {
        this.IsBuilt := false
        if (!(FontName is String)) {
            throw TypeError("Expected a String",, Type(FontName))
        }
        this.DefineProp("__FontName", { Value: FontName })
        this.style |= WindowsAndMessaging.DS_SETFONT
        return this.DefineProp("__FontSize", { Value: FontSize & 0xFFFF })
    }

    /**
     * 
     */
    WindowClass(WindowClass) {
        this.IsBuilt := false
        if (WindowClass is String) {
            return this.DefineProp("__WindowClass", { Value: WindowClass })
        }
        return this.DefineProp("__WindowClass", { Value: WindowClass & 0xFFFF })
    }

    __Controls => Array()

    Control(Control) {
        this.IsBuilt := false
        if (!(Control is DialogTemplateItem)) {
            throw TypeError("Expected a DialogTemplateItem",, Type(Control))
        }
        Controls := this.__Controls
        Controls.Push(Control)
        return this.DefineProp("__Controls", { Value: Controls })
    }

    IsBuilt := false

    /**
     * 
     */
    Build() {
        if (this.IsBuilt) {
            return this.Size
        }

        this.Offset := DLGITEMTEMPLATE.sizeof

        ; menu
        this.AppendUShort(0)

        ; window class
        switch {
            case (!HasProp(this, "__WindowClass")):
                this.AppendUShort(0)
            case (this.__WindowClass is String):
                this.AppendString(this.__WindowClass)
            case (this.__WindowClass is Integer):
                this.AppendUShort(0xFFFF).AppendUShort(this.__WindowClass)
        }

        ; title
        if (HasProp(this, "__Title")) {
            this.AppendString(this.__Title)
        } else {
            this.AppendUShort(0)
        }

        ; font
        if (HasProp(this, "__FontName") && HasProp(this, "__FontSize")) {
            this.AppendUShort(this.__FontSize).AppendString(this.__FontName)
        }

        ; controls
        for Ctl in this.__Controls {
            ++this.cdit
            AppendControl(Ctl)
        }

        this.IsBuilt := Offset
        return Offset

        Append(Num, Nums*) {
            static sizeof_WORD := 2
            CheckSize(sizeof_WORD)
            NumPut("UShort", Num, this, Offset)
            Offset += sizeof_WORD

            for N in Nums {
                CheckSize(sizeof_WORD)
                NumPut("UShort", N, this, Offset)
                Offset += sizeof_WORD
            }
        }

        AppendStr(Str) {
            Size := StrPut(Str, "UTF-16")
            CheckSize(Size)
            StrPut(Str, this.Ptr + Offset, "UTF-16")
            Offset += Size
        }

        AppendControl(Ctl) {
            Size := Ctl.Build()
            Data := Ctl.Ptr
            CheckSize(Size)
            Loop Size {
                NumPut("UChar", NumGet(Data, "UChar"), this, Offset)
                Data++
                Offset++
            }
        }

        CheckSize(Size) {
            ; TODO this probably sucks, but it gets the job done
            while ((Offset + Size) > this.Size) {
                this.Size *= 2
            }
        }
        
        AlignDword() {
            Offset := (Offset + 3) & ~3
        }
    }
}

class DialogTemplateItem extends Buffer {
    /**
     * Type: <b>DWORD</b>
     * 
     * The style of the control. This member can be a combination of <a href="https://docs.microsoft.com/windows/desktop/winmsg/window-styles">window style values</a> (such as <b>WS_BORDER</b>) and one or more of the <a href="https://docs.microsoft.com/windows/desktop/Controls/common-control-styles">control style values</a> (such as <b>BS_PUSHBUTTON</b> and <b>ES_LEFT</b>).
     * @type {Integer}
     */
    style {
        get => NumGet(this, 0, "uint")
        set => NumPut("uint", value, this, 0)
    }

    /**
     * Type: <b>DWORD</b>
     * 
     * The extended styles for a window. This member is not used to create controls in dialog boxes, but applications that use dialog box templates can use it to create other types of windows. For a list of values, see <a href="https://docs.microsoft.com/windows/desktop/winmsg/extended-window-styles">Extended Window Styles</a>.
     * @type {Integer}
     */
    dwExtendedStyle {
        get => NumGet(this, 4, "uint")
        set => NumPut("uint", value, this, 4)
    }

    /**
     * Type: <b>short</b>
     * 
     * The 
     * 					<i>x</i>-coordinate, in dialog box units, of the upper-left corner of the control. This coordinate is always relative to the upper-left corner of the dialog box's client area.
     * @type {Integer}
     */
    x {
        get => NumGet(this, 8, "short")
        set => NumPut("short", value, this, 8)
    }

    /**
     * Type: <b>short</b>
     * 
     * The 
     * 					<i>y</i>-coordinate, in dialog box units, of the upper-left corner of the control. This coordinate is always relative to the upper-left corner of the dialog box's client area.
     * @type {Integer}
     */
    y {
        get => NumGet(this, 10, "short")
        set => NumPut("short", value, this, 10)
    }

    /**
     * Type: <b>short</b>
     * 
     * The width, in dialog box units, of the control.
     * @type {Integer}
     */
    cx {
        get => NumGet(this, 12, "short")
        set => NumPut("short", value, this, 12)
    }

    /**
     * Type: <b>short</b>
     * 
     * The height, in dialog box units, of the control.
     * @type {Integer}
     */
    cy {
        get => NumGet(this, 14, "short")
        set => NumPut("short", value, this, 14)
    }

    /**
     * Type: <b>WORD</b>
     * 
     * The control identifier.
     * @type {Integer}
     */
    id {
        get => NumGet(this, 16, "ushort")
        set => NumPut("ushort", value, this, 16)
    }

    __New() {
        super.__New(DLGTEMPLATE.sizeof, 0)
        this.style := WINDOW_STYLE.WS_CHILD
                    | WINDOW_STYLE.WS_VISIBLE
                    | WINDOW_STYLE.WS_TABSTOP
    }

    Style(Style, ExStyle := 0) {
        this.style := Style
        this.dwExtendedStyle := ExStyle
        return this
    }

    Position(x, y) {
        this.x := x
        this.y := y
        return this
    }

    Size(Width, Height) {
        this.cx := Width
        this.cy := Height
        return this
    }

    ControlId(Id) {
        this.id := Id
        return this
    }

    WindowClass(Atom) {
        this.IsBuilt := false
        if (Atom is String) {
            return this.DefineProp("__WindowClass", { Value: Atom })
        }
        return this.DefineProp("__WindowClass", { Value: Atom & 0xFFFF })
    }

    Title(Title) {
        this.IsBuilt := false
        if (!(Title is String)) {
            throw TypeError("Expected a String",, Type(Title))
        }
        return this.DefineProp("__Title", { Value: Title })
    }

    Data(Ptr, Size) {
        return this.DefineProp("__Ptr",  { Value: Ptr  & Ptr    })
                   .DefineProp("__Size", { Value: Size & 0xFFFF })
    }

    IsBuilt := false

    Build() {
        if (this.IsBuilt) {
            return this.Size
        }

        Offset := DLGTEMPLATE.sizeof

        ; window class
        switch {
            case (!HasProp(this, "__WindowClass")):
                Append(0)
            case (this.__WindowClass is String):
                AppendStr(this.__WindowClass)
            case (this.__WindowClass is Integer):
                Append(0xFFFF, this.__WindowClass)
        }

        ; title
        switch {
            case (!HasProp(this, "__Title")):
                Append(0)
            case (this.__Title is String):
                AppendStr(this.__Title)
            case (this.__Title is Integer):
                Append(0xFFFF, this.__Title)
        }

        ; data
        if (HasProp(this, "__Data") && HasProp(this, "__Size")) {
            Append(this.__Size && 0xFFFF)
            AppendData(this.__Data, this.__Size)
        } else {
            Append(0)
        }

        this.IsBuilt := true
        return Offset

        Append(Num, Nums*) {
            static sizeof_WORD := 2
            CheckSize(sizeof_WORD)
            NumPut("UShort", Num, this, Offset)
            Offset += sizeof_WORD

            for N in Nums {
                CheckSize(sizeof_WORD)
                NumPut("UShort", N, this, Offset)
                Offset += sizeof_WORD
            }
        }

        AppendStr(Str) {
            Size := StrPut(Str, "UTF-16")
            CheckSize(Size)
            StrPut(Str, this.Ptr + Offset, "UTF-16")
            Offset += Size
        }

        AppendData(Data, Size) {
            CheckSize(Size)
            Loop Size {
                NumPut("UChar", NumGet(Data, "UChar"), this, Offset)
                Data++
                Offset++
            }
        }

        CheckSize(Size) {
            ; TODO this probably sucks, but it gets the job done
            while ((Offset + Size) > this.Size) {
                this.Size *= 2
            }
        }
    }

    class Button extends DialogTemplateItem {
        __New() {
            super.__New()
            this.style |= WindowsAndMessaging.BS_PUSHBUTTON
            this.WindowClass(0x0080)
        }
    }

    ; TODO do the rest
    class Edit extends DialogTemplateItem {
        __New() => super.__New().id := 0x0081
    }

    class StaticClass extends DialogTemplateItem {
        __New() => super.__New().id := 0x0082
    }

    class ListBox extends DialogTemplateItem {
        __New() => super.__New().id := 0x0083
    }

    class ScrollBar extends DialogTemplateItem {
        __New() => super.__New().id := 0x0084
    }

    class ComboBox extends DialogTemplateItem {
        __New() => super.__New().id := 0x0085
    }
}

;@region PROPSHEETPAGEW
/**
 * ```
 * class PROPSHEETPAGEW
 * |- __New()
 * |- Resource(Resource)
 * |- DialogProc(Fn)
 * |- Title(Title)
 * |- Icon(Icon)
 * |- Param(lParam)
 * |- Header(Title?, SubTitle?)
 * |- HeaderImage(Bitmap)
 * |- OnError(Fn)
 * `- __Delete()
 * ```
 */
class Tanuki_PROPSHEETPAGEW extends AquaHotkey_MultiApply {
    static __New() => super.__New(PROPSHEETPAGEW)

    ; TODO this might be an issue because we're writing controls
    ; somewhere after the struct has ended.

    /**
     * Creates a new `PROPSHEETPAGEW` and initializes with default
     * values.
     * 
     */
    __New(lParam := 0) {
        (Win32Struct.Prototype.__New)(this, lParam)
        this.dwSize := PROPSHEETPAGEW.sizeof
        this.hInstance := LibraryLoader.GetModuleHandleW(0)
    }

    /**
     * Specifies a `DLGTEMPLATE` as resource to be used by the
     * `pResource`.
     * 
     * @param   {DialogTemplate}  Resource  the resource to be used
     * @returns {this}
     */
    Resource(Resource) {
        if (!(Resource is DialogTemplate)) {
            throw TypeError("Expected a DialogTemplate",, Type(Resource))
        }
        Resource.Build()

        this.dwFlags |= Controls.PSP_DLGINDIRECT
        this.pResource := Resource.Ptr
        this.__pResource := Resource
        return this
    }

    /**
     * Defines the procedure to be used by the property sheet page.
     * 
     * @param   {Func}  Fn  the function to be called
     * @returns {this}
     */
    DialogProc(Fn) {
        this.pfnDlgProc := CallbackCreate(GetMethod(Fn), "Fast")
        return this
    }

    /**
     * 
     * 
     * @param   {String}
     * @returns {this}
     */
    Title(Title) {
        if (!(Title is String)) {
            throw TypeError("Expected a String",, Type(Title))
        }
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

    OnError(Fn) {
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
; TODO write this in the form of a `class Wizard`, `class PropertySheet`, etc.
class Tanuki_PROPSHEETHEADERW extends AquaHotkey_MultiApply {
    static __New() => super.__New(PROPSHEETHEADERW_V2)

    __New() {
        (Win32Struct.Prototype.__New)(this)
        this.dwSize := PROPSHEETHEADERW_V2.sizeof
        this.hInstance := LibraryLoader.GetModuleHandleW(0)
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
        if (Pages.Length > Controls.MAXPROPPAGES) {
            throw Error("Too many pages",, Pages.Length)
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
        this.phpage := Buf.Ptr
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

Page := PROPSHEETPAGEW()
    .Resource(DialogTemplate()
        ;.Position(0, 0)
        ;.Small()
        ;.Font("Cascadia Code", 8)
        ;.Control(DialogTemplateItem.Button()
        ;    .Size(50, 100)
        ;    .ControlId(1)
        ;    .Title("Hello, world!")
        ;)
    )
    .Title("Cool Title")
    .Header("Header Title")
    .DialogProc((hwnd, msg, wparam, lparam) {
        if (msg == WindowsAndMessaging.WM_INITDIALOG) {
            return true
        }
        return false
    })

Handle := Controls.CreatePropertySheetPageW(Page)
if (!Handle) {
    MsgBox("Unable to create page")
}

PageTwo := Page.Clone()
PageTwo.Title("Page two")

Page.dwFlags |= Controls.PSP_HASHELP

Header := PROPSHEETHEADERW_V2()
    .Pages(Page, PageTwo)
    .Wizard97()
    .Title("My Property Sheet")
    ;.Watermark(Bitmap)

; Header.dwFlags |= Controls.PSH_MODELESS

Header.dwFlags |= Controls.PSH_HEADER
Header.dwFlags |= Controls.PSH_WIZARDHASFINISH

if (!(Header.dwFlags & Controls.PSH_WIZARD97)) {
    throw Error("Not wizard 97")
}
if (!(Page.dwFlags & Controls.PSP_USEHEADERTITLE)) {
    throw Error("Has no header")
}

; MsgBox(Page.DumpProps())
; MsgBox(Header.DumpProps())

Controls.PropertySheetW(Header)

^+a:: {
    ExitApp()
}