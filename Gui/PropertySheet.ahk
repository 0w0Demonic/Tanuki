#Include <Tanuki\Gui\Wizard>
#Include <Tanuki\Util\Buffers>
#Include <Tanuki\Util\AppendableBuffer>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\PROPSHEETHEADERW_V2>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\PROPSHEETPAGEW>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>
#Include <AhkWin32Projection\Windows\Win32\System\LibraryLoader\Apis>

/**
 * Defines the frame and pages of a property sheet.
 */
class PropertySheet extends PROPSHEETHEADERW_V2 {
    /**
     * Creates a new `PropertySheet`, initialized with appropriate `dwSize`
     * and `hInstance`.
     */
    __New() {
        static hInstance := LibraryLoader.GetModuleHandleW(0)
        super.__New()
        this.dwSize := PROPSHEETHEADERW_V2.sizeof
        this.hInstance := hInstance
    }

    /**
     * Sets the property sheet's owner window.
     * 
     * @param   {Integer}  Hwnd  hwnd of the parent window
     * @returns {this}
     */
    Parent(Hwnd) {
        this.hwndParent := Hwnd
        return this
    }

    /**
     * Sets the title of the property sheet.
     * 
     * @param   {String}  Title  the title of the property sheet
     * @returns {this}
     */
    Title(Title) {
        this.__pszCaption := Buffers.FromString(Title)
        this.pszCaption := this.__pszCaption.Ptr
        return this
    }

    /**
     * Sets the icon to use in the title bar of the property sheet.
     * 
     * @param   {HICON}  Icon  the icon handle
     * @returns {this}
     */
    Icon(Icon) {
        this.hIcon := Icon
        this.dwFlags |= Controls.PSP_USEHICON
        return this
    }

    /**
     * Sets the initial page that appears when the property sheet is created.
     * 
     * @param   {Integer/String}  1-based index or name of the page
     * @returns {this}
     */
    StartPage(Start) {
        if (IsObject(Start)) {
            throw TypeError("Expected a String or an Integer",, Type(Start))
        }
        if (Start is Integer) {
            if (Start < 1) {
                throw ValueError("Invalid start page",, Start)
            }
            this.nStartPage := (Start - 1)
            return this
        }
        this.__pStartPage := Buffers.FromString(Start)
        this.pStartPage := this.__pStartPage.Ptr
        this.dwFlags |= Controls.PSH_USEPSTARTPAGE
        return this
    }

    /**
     * Sets a callback function that is called when certain events occur.
     * 
     * @param   {Func}  Fn  the function to be called
     * @returns {this}
     */
    OnEvent(Fn) {
        this.pfnCallback := CallbackCreate(GetMethod(Fn), "Fast")
        this.dwFlags |= Controls.PSH_USECALLBACK
        return this
    }

    /**
     * Sets the pages of the property sheet.
     * 
     * @param   {PropertySheetPage*}  Page  the pages to be displayed
     * @returns {this}
     */
    Pages(Pages*) {
        if (!Pages.Length) {
            throw UnsetError("No pages are set")
        }
        if (Pages.Length > Controls.MAXPROPPAGES) {
            throw ValueError("Too many pages",, Pages.Length)
        }
        Buf := AppendableBuffer(Pages.Length * A_PtrSize, 0)
        for Page in Pages {
            if (!(Page is PROPSHEETPAGEW)) {
                throw TypeError("Expected a PROPSHEETPAGEW",, Type(Page))
            }
            Handle := Controls.CreatePropertySheetPageW(Page)
            if (!Handle) {
                throw Error("Unable to create page #" . A_Index)
            }
            Buf.AddPtr(Handle)
        }

        this.__Pages  := Pages
        this.nPages   := Pages.Length

        this.__phpage := Buf
        this.phpage   := Buf.Ptr
        return this
    }

    /**
     * Enables a help button to be displayed when the page is created. If any
     * of the property sheet pages enable a help button, this flag is set
     * automatically.
     * 
     * @returns {this}
     */
    HasHelp() {
        if (this is AeroWizard) {
            throw TypeError("Help button is unsupported for Aero wizards", -2)
        }
        this.dwFlags |= Controls.PSH_HASHELP
        return this
    }

    /**
     * Removes the apply button. This is not supported for aero wizards.
     * 
     * @returns {this}
     */
    NoApplyButton() {
        if (this is AeroWizard) {
            throw TypeError("Cannot remove Apply button on Aero wizards", -2)
        }
        this.dwFlags |= Controls.PSH_NOAPPLYNOW
        return this
    }

    /**
     * Removes the context help, which is usually present on the caption bar of
     * property sheets.
     * 
     * @returns {this}
     */
    NoContextHelp() {
        if (this is AeroWizard) {
            throw TypeError("Cannot remove context help on Aero wizards", -2)
        }
        this.dwFlags |= Controls.PSH_NOCONTEXTHELP
        return this
    }

    /**
     * Sets the property sheet to right-to-left reading order.
     * 
     * @returns {this}
     */
    RightToLeft() {
        this.dwFlags |= Controls.PSH_RTLREADING
        return this
    }

    /**
     * Cleanup.
     */
    __Delete() {
        if (this.pfnCallback) {
            CallbackFree(this.pfnCallback)
        }
    }
}
