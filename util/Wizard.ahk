#Include <Tanuki\util\PropertySheet>

class Wizard extends PropertySheet {
    __New() {
        super.__New()
        this.dwFlags |= Controls.PSH_WIZARD
    }

    HasFinish() {
        this.dwFlags |= Controls.PSH_WIZARDHASFINISH
        return this
    }
}

class WizardLite extends PropertySheet {
    __New() {
        super.__New()
        this.dwFlags |= Controls.PSH_WIZARD_LITE
    }
}

class Wizard97 extends PropertySheet {
    __New() {
        super.__New()
        this.dwFlags |= Controls.PSH_WIZARD97
    }

    /**
     * 
     */
    HeaderImage(hBitmap) {
        ; TODO make this work
        this.hbmHeader := hBitmap
        this.dwFlags |= Controls.PSH_USEHBMHEADER
        this.dwFlags |= Controls.PSH_HEADER
        return this
    }

    Watermark(Watermark, Palette?) {

    }

    HasFinish() {
        this.dwFlags |= Controls.PSH_WIZARDHASFINISH
        return this
    }
}

class AeroWizard extends PropertySheet {
    __New() {
        super.__New()
        this.dwFlags |= Controls.PSH_WIZARD | Controls.PSH_AEROWIZARD
    }

    Resizable() {
        this.dwFlags |= Controls.PSH_RESIZABLE
        return this
    }

    ; TODO handle PSH_HEADERBITMAP as resource
    HeaderImage() {

    }

    /**
     * 
     */
    NoMargin() {
        this.dwFlags |= Controls.PSH_NOMARGIN
        return this
    }

    /**
     * 
     */
    HasContextHelp() {
        this.dwFlags |= Controls.PSH_WIZARDCONTEXTHELP
        return this
    }

    HasFinish() {
        this.dwFlags |= Controls.PSH_WIZARDHASFINISH
        return this
    }
}

; TODO list:
; - PSH_HASHELP
; - PSH_MODELESS
; - PSH_PROPTITLE
; - PSH_STRETCHWATERMARK
; - PSH_USEICONID
; - PSH_USEPAGELANG
; - PSH_USESTARTPAGE
; - PSH_WATERMARK
