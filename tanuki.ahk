#Requires AutoHotkey >=v2.1-alpha.10
#Include <AquaHotkey>

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
            if (HasTheme) {
                this.Theme := Theme
            }
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
            if (HasTheme) {
                this.Theme := Theme
            }
        }

        /**
         * Defines new properties and methods for class `Gui.Control`.
         */
        class Control {
            /**
             * 
             */
            Opt(Options) {
                HasTheme := Tanuki.ParseGuiOptions(&Options, &Theme)
                (Tanuki.Gui_Old.Control.Prototype.Opt)(this, Options)
                if (HasTheme) {
                    this.Theme := Theme
                }
            }

            /**
             * Shared `Theme` property that does nothing.
             */
            Theme {
                set {
                    return
                }
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
            try Ctl.ApplyTheme(this.Theme)
            return Ctl
        }

        /**
         * 
         */
        AddButton(Opt?, Txt?) => this.Add("Button", Opt?, Txt?)

        /**
         * 
         */
        AddCheckBox(Opt?, Text?) => this.Add("CheckBox", Opt?, Txt?)

        /**
         * 
         */
        Theme {
            set {
                Theme := Tanuki.LoadTheme(value)

                ; set some general options like background color, font etc. here
                ; ...
                if (ObjHasOwnProp(Theme, "DarkMode")) {
                    this.DarkMode := Theme.DarkMode
                }
                if (ObjHasOwnProp(Theme, "BackColor")) {
                    this.BackColor := Theme.BackColor
                }

                ; and then loop through all controls
                for GuiControl in this {
                    try GuiControl.Theme := Theme
                }

                this.DefineProp("Theme", {
                    Get: (Instance) => Theme ; TODO do I need to .Clone() this?
                })
            }
        }

        /**
         * 
         */
        DarkMode {
            set {
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Hwnd,
                        "Int", 20, "Int*", !!value, "UInt", 4)
            }
        }

        class Button {
            ApplyTheme(Theme) {
                Theme := Tanuki.LoadTheme(Theme)

            }
        }

        class CheckBox {
            ApplyTheme(Theme) {

            }
        }

        ; TODO etc
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
     * 
     * @param   {&String}  Opt  
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
}


class Dark {
    static BackColor => 0x202020
    static FontColor => 0xE0E0E0
    static DarkMode  => true
}

g := Gui("Theme:Dark")
g.AddEdit("r1 w250")
g.Show()

