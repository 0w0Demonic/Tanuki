#Requires AutoHotkey >=v2.0.5
#Include <AquaHotkey>

#DllLoad  "uxtheme.dll"
#Include  "%A_LineFile%/../theme_catppuccin.ahk"

/**
 * Tanuki allows easy customization of GUIs by using themes and hundreds
 * of new, user-friendly methods and properties added to the GUI and its
 * controls.
 */
class Tanuki extends AquaHotkey
{
    /**
     * This class saves a snapshot of the previous state of `Gui()`,
     * which is required to save e.g. its the old `__New()` method.
     */
    class Gui_Old extends AquaHotkey_Backup {
        static Class => Gui
    }

    /**
     * Defines new properties and methods added to the built-in `Gui` type.
     */
    class Gui {
        /**
         * Constructs a new Gui, optionally applying a theme given in the form
         * of a class name or file path to a JSON.
         * @example
         * 
         * g := Gui("Theme:src/themes/DarkMode.json")
         * 
         * @example
         * 
         * g := Gui("Theme:Catppuccin")
         * 
         * class Catppuccin {
         * 
         * }
         * 
         * @param   {String?}  Opt       additional options
         * @param   {String?}  Title     title of the Gui
         * @param   {Object}   EventObj  event sink of the Gui
         */
        __New(Opt := "", Title?, EventObj?) {
            HasTheme := Tanuki.ParseGuiOptions(&Opt, &Theme)
            (Tanuki.Gui_Old.Prototype.__New)(this, Opt, Title?, EventObj?)
            (HasTheme && (this.Theme := Theme))
        }

        /**
         * Sets various options and styles for the appearance and behaviour of
         * the window, now supporting Gui themes.
         * 
         * @example
         * 
         * g := Gui("Theme:src/themes/DarkMode.json")
         * 
         * @example
         * 
         * g := Gui("Theme:Catppuccin")
         * 
         * class Catppuccin {
         * 
         * }
         * 
         * @param   {String}  Options  zero or more options and styles
         */
        Opt(Options) {
            HasTheme := Tanuki.ParseGuiOptions(&Options, &Theme)
            (Tanuki.Gui_Old.Prototype.Opt)(this, Options)
            (HasTheme && (this.Theme := Theme))
        }

        #Include "%A_LineFile%/../Gui.Control.ahk"

        /**
         * Adds a control to the Gui, optionally applying a Gui theme.
         * 
         * @param   {String}   ControlType  type of the Gui control to add
         * @param   {String?}  Opt          additional options
         * @param   {String?}  Txt          text to display in the control
         * @return  {Gui.Control}
         */
        Add(ControlType, Opt := "", Txt?) {
            Ctl := (Tanuki.Gui_Old.Prototype.Add)(this, ControlType, Opt, Txt?)
            Ctl.ApplyTheme(this.Theme)
            return Ctl
        }

        #Include "%A_LineFile%/../Gui.Button.ahk"
        #Include "%A_LineFile%/../Gui.CheckBox.ahk"

        /**
         * Adds a ComboBox control to the Gui.
         * 
         * @param   {String?}  Gui    additional options
         * @param   {Array?}   Items  a list of items
         * @return  {Gui.ComboBox}
         */
        AddComboBox(Opt?, Items?) => this.Add("ComboBox", Opt?, Items?)

        /**
         * Adds a DateTime control to the Gui.
         * 
         * @param   {String?}  Opt     additional options
         * @param   {String?}  Format  format string
         * @return  {Gui.DateTime}
         */
        AddDateTime(Opt?, Format?) => this.Add("DateTime", Opt?, Format?)

        /**
         * Adds a group box control to the Gui.
         * 
         * @param   {String?}  Opt  additional options
         * @param   {String?}  Txt  text to display in the group box
         * @return  {Gui.GroupBox}
         */
        AddGroupBox(Opt?, Txt?) => this.Add("GroupBox", Opt?, Txt?)

        /**
         * Adds a hotkey control to the Gui.
         * 
         * @param   {String?}  Opt  additional options
         * @param   {String?}  Txt  the text to display
         * @return  {Gui.Hotkey}
         */
        AddHotkey(Opt?) => this.Add("Hotkey", Opt?)

        /**
         * Adds a text control to the Gui which can contain links.
         * 
         * @param   {String?}  Opt  additional options
         * @param   {String?}  Txt  the text to display
         * @return  {Gui.Link}
         */
        AddLink(Opt?, Txt?) => this.Add("Link", Opt?, Txt?)

        /**
         * 
         */
        AddPicture(Opt?, FileName?) => this.Add("Picture", Opt?, FileName?)

        /**
         * 
         */
        AddProgress(Opt?, StartVal?) => this.Add("Progress", Opt?, StartVal?)

        /**
         * 
         */
        AddRadio(Opt?, Txt?) => this.Add("Radio", Opt?, Txt?)

        /**
         * 
         */
        AddSlider(Opt?, StartVal?) => this.Add("Slider", Opt?, StartVal?)

        /**
         * 
         */
        AddStatusBar(Opt?, Txt?) => this.Add("StatusBar", Opt?, Txt?)

        /**
         * 
         */
        AddTab(Opt?, Items?) => this.Add("Tab", Opt?, Items?)

        /**
         * 
         */
        AddTab2(Opt?, Items?) => this.Add("Tab2", Opt?, Items?)

        /**
         * 
         */
        AddTab3(Opt?, Items?) => this.Add("Tab3", Opt?, Items?)

        /**
         * 
         */
        AddTreeView(Opt?) => this.Add("TreeView", Opt?)

        /**
         * ; TODO allow nested objects
         * 
         * Applies a theme to the Gui. Valid arguments include
         * 1. Any object
         * 2. The name of an object at global scope (preferably a class object)
         * 3. The path to a JSON file
         * 
         * @param   {Object/String}  value  object, name of object or JSON file
         */
        Theme {
            set {
                Theme := Tanuki.LoadTheme(value)

                if (HasProp(Theme, "DarkMode")) {
                    this.DarkMode := Theme.DarkMode
                }

                if (HasProp(Theme, "Background")) {
                    this.BackColor := Theme.Background
                }

                if (HasProp(Theme, "Title")) {
                    if (HasProp(Theme.Title, "Background")) {
                        this.TitleColor := Theme.Title.Background
                    }
                    if (HasProp(Theme.Title, "Foreground")) {
                        this.TitleTextColor := Theme.Title.Foreground
                    }
                }

                ; and then loop through all controls
                for GuiControl in this {
                    GuiControl.ApplyTheme(Theme)
                }

                this.DefineProp("Theme", {
                    Get: (Instance) => Theme.Clone()
                })
            }
        }

        /**
         * Enables or disables dark mode for the window and its child controls.
         * When set to `true`, the system theme is overridden to use dark
         * styling.
         * 
         * Note: Requires Windows 10 1809+ (build 17763).
         * 
         * @param   {Boolean}  value  switch dark mode on/off
         * @return  {Boolean}
         */
        DarkMode {
            get {
                static DWMWA_USE_IMMERSIVE_DARK_MODE := (
                    19 + (VerCompare(A_OSVersion, "10.0.18985") >= 0)
                )

                DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", this.Hwnd,
                        "Int", DWMWA_USE_IMMERSIVE_DARK_MODE,
                        "Int*", &(Result := 0),
                        "UInt", 4)
                return !!Result
            }
            set {
                static DWMWA_USE_IMMERSIVE_DARK_MODE := (
                    19 + (VerCompare(A_OSVersion, "10.0.18985") >= 0)
                )
                
                OnOff := !!value
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Hwnd,
                        "Int", DWMWA_USE_IMMERSIVE_DARK_MODE,
                        "Int*", OnOff,
                        "UInt", 4)
            }
        }

        /**
         * Sets and retrieves the background color of the window's title bar.
         * This properties expects RGB values.
         * 
         * Requires Windows 11.
         * @param   {Integer}  value  RGB value of title bar background
         * @return  {Integer}
         */
        TitleColor {
            get {
                static DWMWA_CAPTION_COLOR := 0x0035
                DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", this.Hwnd,
                        "Int", DWMWA_CAPTION_COLOR,
                        "Int*", &(Result := 0),
                        "UInt", 4)
                return Result
            }
            set {
                static DWMWA_CAPTION_COLOR := 0x0035
                Color := Tanuki.Swap_RGB_BGR(value)
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Hwnd,
                        "Int", DWMWA_CAPTION_COLOR,
                        "Int*", Color,
                        "UInt", 4)
            }
        }

        /**
         * Sets and retrieves the text color of the window's title bar.
         * This property expected RGB values.
         * 
         * Requires Windows 11.
         * @param   {Integer}  value  RGB value of title bar text color
         * @return  {Integer}
         */
        TitleTextColor {
            get {
                static DWMWA_TEXT_COLOR := 0x0036               
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Hwnd,
                        "Int", DWMWA_TEXT_COLOR,
                        "Int*", &(Result := 0),
                        "UInt", 4)
                return Result
            }
            set {
                static DWMWA_TEXT_COLOR := 0x0036
                Color := Tanuki.Swap_RGB_BGR(value)
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Hwnd,
                        "Int", DWMWA_TEXT_COLOR,
                        "Int*", Color,
                        "UInt", 4)
            }
        }

        #Include "%A_LineFile%/../Gui.Button.ahk"

        class ComboBox {
            ApplyTheme(Theme) {

            }
        }

        class DateTime {
            ApplyTheme(Theme) {

            }
        }

        #Include %A_LineFile%/../Gui.DDL.ahk
        #Include %A_LineFile%/../Gui.Edit.ahk
        #Include %A_LineFile%/../Gui.ListView.ahk

        class GroupBox {
            ApplyTheme(Theme) {

            }
        }

        class Hotkey {
            ApplyTheme(Theme) {

            }
        }

        class Link {
            ApplyTheme(Theme) {

            }
        }

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
        }

        #Include "%A_LineFile%/../Gui.MonthCal.ahk"

        class Picture {
            ApplyTheme(Theme) {
                return
            }
        }

        class Progress {
            ApplyTheme(Theme) {

            }
        }

        ; TODO font doesn't change
        class Radio {
            ApplyTheme(Theme) {

            }
        }

        ; TODO still looks weird
        class Slider {
            ApplyTheme(Theme) {
                Theme := Tanuki.PrepareSubTheme(Theme, "Slider")

                if (HasProp(Theme, "Background")) {
                    this.Opt("Background" . Theme.Background)
                }
                if (HasProp(Theme, "Foreground")) {
                    this.Opt("c" . Theme.Foreground)
                }
            }
        }

        class StatusBar {
            ApplyTheme(Theme) {

            }
        }

        class Tab {
            ApplyTheme(Theme) {

            }
        }

        /**
         * 
         */
        AddText(Opt?, Txt?) => this.Add("Text", Opt?, Txt?)

        /**
         * 
         */
        class Text {
            /**
             * 
             */
            ApplyTheme(Theme) {
                Theme := Tanuki.PrepareSubTheme(Theme, "Text")
                Tanuki.ApplyFont(this, Theme)
                if (HasProp(Theme, "Background")) {
                    this.Opt("Background" . Theme.Background)
                }
                return Theme
            }
        }

        class TreeView {
            ApplyTheme(Theme) {

            }
        }

        /**
         * 
         */
        AddUpDown(Opt?, StartVal?) => this.Add("UpDown", Opt?, StartVal?)

        class UpDown {
            ApplyTheme(Theme) {
                Theme := Tanuki.PrepareSubTheme(Theme, "UpDown")
                Tanuki.ApplyFont(this, Theme)
                if (HasProp(Theme, "Background")) {
                    this.Opt("Background" . Theme.Background)
                }
                return Theme
            }
        }
    }

    /**
     * Returns an object which represents the GUI theme, associated
     * with the given class name or JSON file.
     * 
     * @param   {Object/String}  Theme  theme object, class name or JSON file
     */
    static LoadTheme(Theme) {
        if (IsObject(Theme)) {
            return Theme
        }

        static Deref1(a) => %a%
        static Deref2(b) => %b%
        try return (Theme != "a") ? Deref1(Theme) : Deref2(Theme)

        if (!FileExist(Theme)) {
            throw TargetError("unable to find Gui theme",, Theme)
        }
        ; TODO get a JSON lib somewhere
        ; return Json.Parse(FileRead(Theme))
    }

    /**
     * Finds and removes a theme from inside a string used for Gui options.
     * If the string contains a theme, this method will remove the argument from
     * the option string, outputting it into the `&Theme` variable. Returns
     * `true`, if a theme was found.
     * 
     * @example
     * 
     * ; name of an object
     * g := Gui("Theme:Obsidian")
     * 
     * ; file path to a JSON
     * g := Gui('Theme:"path/to/myTheme.json"')
     * 
     * @param   {&String}  Opt  zero or more Gui options
     * @return  {Boolean}
     */
    static ParseGuiOptions(&Opt, &Theme) {
        static Pattern := "ix) Theme: (?>  `" ([^`"]++) `" | (\S++) )"
        if (RegExMatch(Opt, Pattern, &Match)) {
            Theme := Match[1] || Match[2]
            Opt   := RegExReplace(Opt, Pattern, "", unset, 1)
            return true
        }
        return false
    }

    /**
     * Returns a modified version of the theme object that behaves in such a
     * way to allow subthemes to derive properties from the base theme.
     * @example
     * 
     * Obj := {
     *     Font: { Size: 10 }
     *     Edit: {
     *         ; `Obj.Edit.Font` inherits from `Obj.Font`
     *         Font: { Color: "0x202020" }
     *     }
     * }
     * 
     * @param   {Object}  Theme  the theme to prepare
     * @param   {String}  Name   the subtheme to resolve
     * @return  {Object}
     */
    static PrepareSubTheme(Theme, Name) {
        if (!HasProp(Theme, Name)) {
            return Theme.Clone()
        }

        BaseTheme := Theme.Clone()
        Theme     := Theme.%Name%.Clone()
        ObjSetBase(Theme, BaseTheme)

        ; if present in both objects, gather both `Font` properties, let the
        ; font of the subtheme inherit from the base theme, and then
        ; redefine the property of the theme.
        if (ObjHasOwnProp(Theme, "Font") && ObjHasOwnProp(BaseTheme, "Font"))
        {
            Font     := Theme.Font.Clone()
            BaseFont := BaseTheme.Font.Clone()
            ObjSetBase(Font, BaseFont)

            Theme.DefineProp("Font", { Get: (Instance) => Font })
        }
        return Theme
    }

    /**
     * Converts an RGB color into BGR and vice versa.
     * 
     * @param   {Integer}  Color  the color to convert
     * @return  {Integer}
     */
    static Swap_RGB_BGR(Color) => ((Color & 0xFF0000) >> 16)
                                | ((Color & 0x00FF00)      )
                                | ((Color & 0x0000FF) << 16)
    
    /**
     * Applies changes in font settings to a Gui or Gui control.
     * 
     * @param   {Gui/Gui.Control}  GuiObj  the target Gui or Gui control
     * @param   {Object}           Theme   the theme to apply
     */
    static ApplyFont(GuiObj, Theme) {
        if (!HasProp(Theme, "Font")) {
            return
        }
        Font := Theme.Font
        Name := unset
        Opt  := ""

        if (HasProp(Font, "Name")) {
            Name := Font.Name
        }
        if (HasProp(Font, "Color")) {
            Opt .= "c" . Font.Color . " "
        }
        if (HasProp(Font, "Format")) {
            Opt .= Font.Format . " "
        }
        if (HasProp(Font, "Size")) {
            Opt .= "s" . Font.Size . " "
        }
        if (HasProp(Font, "Weight")) {
            Opt .= "w" . Font.Weight . " "
        }
        if (HasProp(Font, "Quality")) {
            Quality := ResolveFontQuality(Font.Quality)
            Opt .= "q" . Quality . " "
        }
        GuiObj.SetFont(Opt, Name?)

        static ResolveFontQuality(Quality) {
            if (IsInteger(Quality)) {
                return Quality
            }
            if (IsObject(Quality)) {
                throw TypeError("invalid type",, Type(Quality))
            }
            switch (StrLower(Quality)) {
                case "default":        return 0
                case "draft":          return 1
                case "proof":          return 2
                case "nonantialiased": return 3
                case "antialiased":    return 4
                case "cleartype":      return 5
                default: throw ValueError("invalid font quality",, Quality)
            }
        }
    }
}

class HDITEM {
    mask       : u32
    cxy        : i32
    pszText    : uptr
    hbm        : uptr
    cchTextMax : i32
    fmt        : i32
    lParam     : uPtr
    iImage     : i32
    iOrder     : i32
    type       : u32
    pvFilter   : uPtr
}

#Include "%A_LineFile%/../RECT.ahk"
#Include "%A_LineFile%/../Gdi.ahk"

class NMHDR {
    hwndFrom : uptr
    idFrom   : uptr
    code     : i32
}

class NMCUSTOMDRAW {
    hdr         : NMHDR
    dwDrawStage : u32
    hdc         : uptr
    rc          : RECT
    dwItemSpec  : uptr
    uItemState  : u32
    lItemlParam : iptr
}

class POINTL {
    x : i32
    y : i32

    __New(x := 0, y := 0) {
        this.x := x
        this.y := y
    }
}

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

^y:: {
    MsgBox Edt.Zoom.Get()
}

esc:: {
    ExitApp()
}
