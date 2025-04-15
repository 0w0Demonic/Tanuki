#Requires AutoHotkey >=v2.0.5
#Include <AquaHotkey_Minimal>

/**
 * Tanuki is an extension that allows the use of Gui themes for
 * easy customization.
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

        /**
         * Defines new properties and methods for class `Gui.Control`.
         */
        class Control {
            /**
             * Sets various options and styles for the appearance and behaviour
             * of the control, additionally allowing the use of Gui themes.
             */
            Opt(Options) {
                HasTheme := Tanuki.ParseGuiOptions(&Options, &Theme)
                (Tanuki.Gui_Old.Control.Prototype.Opt)(this, Options)
                (HasTheme && (this.Theme := Theme))
            }

            /**
             * Sets the theme of the Gui control.
             * 
             * @param   {Object/String}  value  the theme to apply
             */
            Theme {
                set {
                    this.ApplyTheme(Tanuki.LoadTheme(value))
                }
            }

            /**
             * Shared `.ApplyTheme()` between Gui controls that does nothing.
             * 
             * @param   {Object}  Theme  the theme to apply
             */
            ApplyTheme(Theme) {
                return
            }
        }

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

        /**
         * 
         */
        AddCheckBox(Opt?, Txt?) => this.Add("CheckBox", Opt?, Txt?)

        /**
         * 
         */
        AddComboBox(Opt?, Items?) => this.Add("ComboBox", Opt?, Items?)

        /**
         * 
         */
        AddDateTime(Opt?, Date?) => this.Add("DateTime", Opt?, Date?)

        /**
         * 
         */
        AddGroupBox(Opt?, Txt?) => this.Add("GroupBox", Opt?, Txt?)

        /**
         * 
         */
        AddHotkey(Opt?) => this.Add("Hotkey", Opt?)

        /**
         * 
         */
        AddLink(Opt?, Txt?) => this.Add("Link", Opt?, Txt?)

        /**
         * 
         */
        AddListView(Opt?, Items?) => this.Add("ListView", Opt?, Items?)

        /**
         * 
         */
        AddMonthCal(Opt?, Date?) => this.Add("MonthCal", Opt?, Date?)

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

                ; set some general options like background color, font etc. here
                ; ...
                if (ObjHasOwnProp(Theme, "DarkMode")) {
                    this.DarkMode := Theme.DarkMode
                }
                if (ObjHasOwnProp(Theme, "Background")) {
                    this.BackColor := Theme.Background
                }

                ; and then loop through all controls
                for GuiControl in this {
                    GuiControl.ApplyTheme(Theme)
                }

                this.DefineProp("Theme", {
                    Get: (Instance) => Theme ; TODO do I need to .Clone() this?
                })
            }
        }

        /**
         * Activates or deactivates dark mode for this Gui.
         * 
         * @param   {Boolean}  value  switch dark mode on/off
         * @return  {Boolean}
         */
        DarkMode {
            get => false
            set {
                static DWMWA_USE_IMMERSIVE_DARK_MODE := (
                    19 + (VerCompare(A_OSVersion, "10.0.18985") >= 0)
                )
                
                OnOff := !!value
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Hwnd,
                        "Int", DWMWA_USE_IMMERSIVE_DARK_MODE,
                        "Int*", OnOff,
                        "UInt", 4)
                
                this.DefineProp("DarkMode", {
                    Get: (Instance) => OnOff
                })
            }
        }

        /**
         * Adds a new button to the Gui.
         * 
         * @param   {String?}  Opt  additional options
         * @param   {String?}  Txt  the text to display
         * @return  {Gui.Button}
         */
        AddButton(Opt?, Txt?) => this.Add("Button", Opt?, Txt?)

        /** Defines new properties and methods for `Gui.Button` controls */
        class Button {
            /**
             * Applies a theme to the button.
             * 
             * @param   {Object}  Theme  the theme to apply
             * @return  {Object}
             */
            ApplyTheme(Theme) {
                ; TODO background doesn't work
                Theme := Tanuki.PrepareSubTheme(Theme, "Button")
                Tanuki.ApplyFont(this, Theme)

                if (HasProp(Theme, "Background")) {
                    this.Opt("Background" . Theme.Background)
                }
                return Theme
            }
        }

        /** Defines new properties and methods for `Gui.CheckBox` controls */
        class CheckBox {
            /**
             * Applies a theme to the checkbox.
             * 
             * @param   {Object}  Theme  the theme to apply
             * @return  {Object}
             */
            ApplyTheme(Theme) {
                
            }
        }

        class ComboBox {
            ApplyTheme(Theme) {

            }
        }

        class DateTime {
            ApplyTheme(Theme) {

            }
        }

        /**
         * 
         */
        AddDropDownList(Opt?, Items?) => this.Add("DropDownList", Opt?, Items?)

        class DDL {
            ; TODO "upper part" not coloured
            ApplyTheme(Theme) {
                Theme := Tanuki.PrepareSubTheme(Theme, "DDL")
                Tanuki.ApplyFont(this, Theme)

                if (HasProp(Theme, "Background")) {
                    this.Opt("Background" . Theme.Background)
                }

                static WM_CTLCOLORLISTBOX := 0x0134
                this.OnMessage(WM_CTLCOLORLISTBOX, RenderListBox, false)
                this.OnMessage(WM_CTLCOLORLISTBOX, RenderListBox)
                return Theme
                
                RenderListBox(LbCtl, wParam, lParam, Hwnd) {
                    if (HasProp(Theme, "Foreground")) {
                        TextColor := Tanuki.Swap_RGB_BGR(Theme.Foreground)
                        DllCall("SetTextColor",
                                "Ptr", wParam,
                                "UInt", TextColor)
                    }
                    BackgroundColor := Tanuki.Swap_RGB_BGR(Theme.Background)
                    return DllCall("CreateSolidBrush", "UInt", BackgroundColor)
                }
            }
        }

        /**
         * 
         */
        AddEdit(Opt?, Txt?) => this.Add("Edit", Opt?, Txt?)

        /**
         * 
         */
        class Edit {
            ApplyTheme(Theme) {
                Theme := Tanuki.PrepareSubTheme(Theme, "Edit")
                Tanuki.ApplyFont(this, Theme)
                if (HasProp(Theme, "Background")) {
                    this.Opt("Background" . Theme.Background)
                }
            }
        }

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

        class ListView {
            ApplyTheme(Theme) {

            }
        }

        class MonthCal {
            ApplyTheme(Theme) {

            }
        }

        class Picture {
            ApplyTheme(Theme) {

            }
        }

        class Progress {
            ApplyTheme(Theme) {

            }
        }

        class Radio {
            ApplyTheme(Theme) {

            }
        }

        class Slider {
            ApplyTheme(Theme) {

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

    class RECT extends AquaHotkey_Ignore {
        Left   : i32
        Top    : i32
        Right  : i32
        Bottom : i32
    }

    class DRAWITEMSTRUCT extends AquaHotkey_Ignore {
        ControlType : u32
        ControlId   : u32
        ItemId      : u32
        ItemAction  : u32
        ItemState   : u32
        HwndItem    : uPtr
        hDC         : uPtr
        Rect        : Tanuki.RECT
        ItemData    : uPtr
    }
}

; An object that is meant to hold all style settings. It can be a simple
; object instead of a class, but this way e.g. it cannot be overwritten
class Catppuccin {
    static Background => "0x1E1E2E"
    static DarkMode   => true

    class Button {
        static Background => "0xa600ff"
    }

    class Edit {
        static Background => "0x1E1E2E"
    }

    class Text {
        static Background => "0x260a2e"

        class Font {
            static Color   => "0xbdd5a9"
            static Name    => "Segoe UI"
            static Size    => 10
            static Format  => "bold italic"
            static Quality => "Default"
        }
    }

    class DDL {
        static Background => "0x202020"
    }
}

; probably the easiest way to do it.
; "Catppuccin" refers to the class above. It can be any object at all, or a
; path to a JSON file.
g := Gui("Theme:Catppuccin")

; load a JSON like this (not finished yet... I can't find a good JSON lib for
; some reason (do you know one?))
;     
;     ; you need to use double quotes `"`, because files can contain
;     ; single quotes.
;     g := Gui('Theme:"file/to/myTheme.json"')
; 
Btn := g.AddButton("w50 h50", "Hello, world!")

; alternatively, set themes like this:
; 
;     g.Theme := "Catppuccin"
;     g.Theme := "path/to/myTheme.json"
;     g.Theme := { Background: ... }
;     ; ----
;     EditCtl.Theme := "Dark"
;     EditCtl.Theme := "path/to/darkMode.json"
;     EditCtl.Theme := { Background: ... }
g.Show("w100 h100")

