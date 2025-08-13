; class Tanuki {

/**
 * Utility class used for handling and parsing theme objects.
 */
class Theme extends AquaHotkey_Ignore {
    ; TODO
    static Load(Theme) {
        if (IsObject(Theme)) {
            return Theme
        }

        static Deref1(a) => %a%
        static Deref2(b) => %b%

        try return (Theme != "a" ? Deref1(Theme) : Deref2(Theme))

        if (!FileExist(Theme)) {
            throw TargetError("Unable to find Gui theme",, Theme)
        }
        ; TODO get a JSON lib somewhere
    }

    ; TODO
    static Parse(&OptionStr, &Theme) {
        static Pattern := "
        (
        ix)
        Theme: ( " [^"]++ "
               | ' [^']++ '
               |     \S++ )
        )"
        if (RegExMatch(OptionStr, Pattern, &Match)) {
            Theme  := Match[1]
            Before := SubStr(OptionStr, 1, Match.Pos[0] - 1)
            After  := SubStr(OptionStr, Match.Pos[0] + Match.Len[0])
            OptionStr := Before . After
            return true
        }
        return false
    }
}

; TODO code gen for this based on a bunch of default methods and constants
/**
 * Utility class for the Desktop Window Manager API.
 */
class Dwm extends AquaHotkey_Ignore {
    /**
     * Value of the immersive dark mode window attribute, which is either
     * 19 or 20 based on the current Windows version.
     */
    static DarkMode => (19 + (VerCompare(A_OSVersion, "10.0.18985") >= 0))

    /** Value of corner rounding pref window attribute. */
    static Corners  => 33

    /** Contains window attribute constants that relate to coloring. */
    class Color {
        static Border  => 34
        static Caption => 35
        static Text    => 36
    }

    /** Represents the DWM corner rounding preference enum. */
    class CornerPreference extends Tanuki.Enum {
        static Default    => 0
        static DoNotRound => 1
        static Round      => 2
        static RoundSmall => 3
    }

    /**
     * Retrieves a window attribute from the given HWND.
     * 
     * @param   {Integer/Object}  Target  HWND, or object with `HWND` prop
     * @param   {Integer}         Attr    DWM window attribute to retrieve
     * @param   {Integer?}        Size    size of the output in bytes
     * @return  {Primitive}
     */
    static Get(Target, Attr, Size := 4) {
        ; TODO method that retrieves Hwnd regardless of type?
        Hwnd := IsObject(Target) ? Target.Hwnd : Target
        Result := DllCall("dwmapi\DwmGetWindowAttribute",
                "Ptr", Hwnd,
                "Int", Attr,
                "Int*", &(Result := 0),
                "UInt", Size)
        if (Result) {
            throw OSError(Result)
        }
        return Result
    }

    /**
     * Sets a window attribute of the given HWND.
     * 
     * @param   {Integer/Object}  Target  HWND, or object with `HWND` prop
     * @param   {Integer}         Attr    DWM window attribute to set
     * @param   {Primitive}       Value   new value to set
     * @param   {Integer?}        Size    size in bytes
     */
    static Set(Target, Attr, Value, Size := 4) {
        Hwnd := IsObject(Target) ? Target.Hwnd : Target
        Result := DllCall("dwmapi\DwmSetWindowAttribute",
                "Ptr", Hwnd,
                "Int", Attr,
                "Int*", Value,
                "UInt", Size)
        if (Result) {
            throw OSError(Result,, Format("
            (
            Hwnd: {1}
            AttributeType: {2}
            Value: {3}
            Size: {4}
            )", Hwnd, Attr, Value, Size))
        }
        return this ; allows chaining calls together
    }
}

/**
 * Utility that generates useful methods for classes that are meant to be
 * used as enums.
 */
class Enum extends AquaHotkey_Ignore {
    /**
     * Static init. Adds all read-only static members of the class into two
     * maps `Name` and `Value`, which return the name or value of the enum
     * member.
     */
    static __New() {
        static GetOwnPropDesc := (Object.Prototype.GetOwnPropDesc)
        static Define := (Object.Prototype.DefineProp)

        if (this == Tanuki.Enum) {
            return
        }

        Names := Map()
        Values := Map()
        Names.CaseSense := false
        Values.CaseSense := false

        for Name in ObjOwnProps(this) {
            PropDesc := GetOwnPropDesc(this, Name)
            if (ObjOwnPropCount(PropDesc) != 1) {
                continue
            }
            if (!ObjHasOwnProp(PropDesc, "Get")) {
                continue
            }

            Value := (PropDesc.Get)(this)
            Values.Set(Name, Value)
            Values.Set(Value, Value)
            Names.Set(Name, Name)
            Names.Set(Value, Name)
        }

        Define(this, "Value", { Get: (_, Key) => Values.Get(Key) })
        Define(this, "Name",  { Get: (_, Key) => Names.Get(Key)  })
    }
}

/**
 * 
 */
class Color extends AquaHotkey_Ignore {
    static SwapRB(ColorRGB) {
        return ((ColorRGB & 0xFF0000) >> 16)
             | ((ColorRGB & 0x00FF00)      )
             | ((ColorRGB & 0x0000FF) << 16)
    }

    ; TODO Brighter / Darker
}

; } class Tanuki