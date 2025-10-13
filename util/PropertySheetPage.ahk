#Include <Tanuki\wip\Dialog>
#Include <Tanuki\wip\DialogItem>
#Include <Tanuki\util\Buffers>

#Include <AhkWin32Projection\Windows\Win32\UI\Controls\PROPSHEETPAGEW>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\HICON>
#Include <AhkWin32Projection\Windows\Win32\System\LibraryLoader\Apis>

/**
 * A page used for property sheets, and a wrapper around the Win32
 * `PROPSHEETPAGEW` struct.
 */
class PropertySheetPage extends PROPSHEETPAGEW {
    /**
     * Creates a new `PropertySheetPage` and initializes it with the
     * appropriate `dwSize` and `hInstance` members.
     */
    __New() {
        static hInstance := LibraryLoader.GetModuleHandleW(0)
        super.__New()
        this.dwSize := PROPSHEETPAGEW.sizeof
        this.hInstance := hInstance
    }

    /**
     * Sets the dialog of the page.
     * 
     * @param   {Dialog}  Dlg  the dialog of the page
     * @returns {this}
     */
    Dialog(Dlg) {
        ; TODO use a defensive copy?
        if (!(Dlg is Dialog)) {
            throw TypeError("Expected a Dialog",, Type(Dlg))
        }
        Dlg.Build() ; fully construct the dialog template

        this.dwFlags |= Controls.PSP_DLGINDIRECT
        this.pResource := Dlg.Ptr
        this.__pResource := Dlg
        return this
    }

    /**
     * Defines the window procedure to be used by the page.
     * 
     * @param   {Func}  Fn  the window procedure
     * @returns {this}
     */
    DialogProc(Fn) {
        this.pfnDlgProc := CallbackCreate(GetMethod(Fn), "Fast")
        return this
    }

    /**
     * Sets the title of the page. This title overrides the title specified
     * in the dialog template.
     * 
     * @param   {String}  Title  title of the page
     * @returns {this}
     */
    Title(Title) {
        this.__Title := Buffers.FromString(Title)
        this.pszTitle := this.__Title.Ptr
        this.dwFlags |= Controls.PSP_USETITLE
        return this
    }

    /**
     * Sets the icon in the tab of the page.
     * 
     * @param   {HICON}  Icon  the icon in the tab of the page
     * @returns {this}
     */
    Icon(Icon) {
        if (!(Icon is HICON)) {
            throw TypeError("Expected a HICON or an Integer",, Type(Icon))
        }
        this.hIcon := Icon.Value
        this.dwFlags |= Controls.PSP_USEHICON
        return this
    }

    /**
     * Sets the lParam passed during creation of the dialog box
     * (`WM_INITDIALOG`) to pass additional information to the procedure.
     * 
     * @param   {Integer}  lParam  custom information
     * @returns {this}
     */
    Param(lParam) {
        this.lParam := lParam
        return this
    }

    /**
     * Sets the title and (optionally) the subtitle of the header area.
     * 
     * @param   {String}   Title     title of the header area
     * @param   {String?}  SubTitle  subtitle of the header area
     * @returns {this}
     */
    HeaderTitle(Title, SubTitle?) {
        this.__pszHeaderTitle := Buffers.FromString(Title)
        this.pszHeaderTitle := this.__pszHeaderTitle.Ptr
        ; this.dwFlags |= Controls.PSP_USEHEADERTITLE

        if (!IsSet(SubTitle)) {
            return this
        }

        this.__pszHeaderSubTitle := Buffers.FromString(SubTitle)
        this.pszHeaderSubTitle := this.__pszHeaderSubTitle.Ptr
        ; this.dwFlags |= Controls.PSP_USEHEADERSUBTITLE
        return this
    }

    /**
     * Sets the header image to be used by the page (a bitmap handle).
     * This only works with Wizard97-style wizards.
     * 
     * @param   {HBITMAP}  Image  the image to be used
     * @returns {this}
     */
    HeaderImage(Image) {
        this.hbmHeader := Image.Value
        return this
    }

    /**
     * Sets a callback function that is called when the page is created and when
     * it is about to be destroyed
     * 
     * @param   {Func}  Fn  the function to be called
     * @returns {this}
     */
    OnCreateRelease(Fn) {
        this.pfnCallback := CallbackCreate(GetMethod(Fn), "Fast")
        this.dwFlags |= Controls.PSP_USECALLBACK
        return this
    }

    /**
     * Destructor that releases the two callback functions.
     */
    __Delete() {
        if (this.pfnDlgProc) {
            CallbackFree(this.pfnDlgProc)
        }
        if (this.pfnCallback) {
            CallbackFree(this.pfnCallback)
        }
    }
}
