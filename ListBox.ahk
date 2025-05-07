/**
 * 
 */
AddListBox(Opt?, Items?) => this.Add("ListBox", Opt?, Items?)

class ListBox {
    ApplyTheme(Theme) {
        Theme := Tanuki.PrepareSubTheme(Theme, "ListBox")
        Tanuki.ApplyFont(this, Theme)
        if (HasProp(Theme, "Background")) {
            this.Opt("Background" . Theme.Background)
        }
    }

    ; LB_OKAY
    ; LB_ERR
    ; LB_ERRSPACE

    ; TODO OnOutOfMemory() will probably never fire in AHK to begin with

    OnOutOfMemory() {

    }

    OnClick(Callback, AddRemove?) {
        
    }

    OnDoubleClick() {

    }

    OnCancel() {

    }

    OnFocus() {

    }

    OnFocusLost() {

    }

    ; ...

    class Style {
        static Notify            => 0x0000
        static Sort              => 0x0000
        static NoRedraw          => 0x0000
        static MultipleSelection => 0x0000
        static OwnerDrawFixed    => 0x0000
        static OwnerDrawVariable => 0x0000
        static HasStrings        => 0x0000
        static UseTabStops       => 0x0000
        static NoIntegralHeight  => 0x0000
        static MultiColumn       => 0x0000
        static WantKeyboardInput => 0x0000
        static ExtendedSelection => 0x0000
        static DisableNoScroll   => 0x0000
        static NoData            => 0x0000
        static NoSelection       => 0x0000
        static ComboBox          => 0x0000
        static Standard          => 0x0000
    }
}