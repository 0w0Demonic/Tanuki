/**
 * Adds a text control to the Gui which can contain links.
 * 
 * @param   {String?}  Opt  additional options
 * @param   {String?}  Txt  the text to display
 * @return  {Gui.Link}
 */
AddLink(Opt?, Txt?) => this.Add("Link", Opt?, Txt?)

class Link {
    ApplyTheme(Theme) {

    }

    class Style {
        static Transparent    => 0x0001
        static IgnoreReturn   => 0x0002
        static NoPrefix       => 0x0004
        static UseVisualStyle => 0x0008
        static UseCustomText  => 0x0010
        static Right          => 0x0020
    }
}