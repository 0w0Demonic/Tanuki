/**
 * Adds a ComboBox control to the Gui.
 * 
 * @param   {String?}  Gui    additional options
 * @param   {Array?}   Items  a list of items
 * @return  {Gui.ComboBox}
 */
AddComboBox(Opt?, Items?) => this.Add("ComboBox", Opt?, Items?)

class ComboBox {
    ApplyTheme(Theme) {

    }

    class Style {
        static Simple            => 0x0001
        static DropDown          => 0x0002
        static DropDownList      => 0x0003
        static OwnerDrawFixed    => 0x0010
        static OwnerDrawVariable => 0x0020
        static AutoHScroll       => 0x0040
        static OEMConvert        => 0x0080
        static Sort              => 0x0100
        static HasStrings        => 0x0200
        static NoIntegralHeight  => 0x0400
        static DisableNoScroll   => 0x0800
        static UpperCase         => 0x2000
        static LowerCase         => 0x4000
    }
}
