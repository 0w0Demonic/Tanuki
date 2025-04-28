/** Yet another wrapper for the Gdi32 graphics library. */
class Gdi {
    /**
     * A device context is a structure that defines a set of graphic objects
     * and their associated attributes, as well as the graphic moddes that
     * affect input.
     */
    class DeviceContext {
        static BeginPaint(Hwnd, &PaintInfo?) {
            if (IsObject(Hwnd)) {
                Hwnd := Hwnd.Hwnd
            }
            if (!IsInteger(Hwnd)) {
                throw TypeError("Expected an Object or an Integer",, Type(Hwnd))
            }
            PaintInfo := PAINTSTRUCT()
            hDC := DllCall("BeginPaint", "Ptr", Hwnd, PAINTSTRUCT, PaintInfo)
            return this.FromHandle(hDC)
        }

        static EndPaint(Hwnd, &PaintInfo?) {
            if (IsObject(Hwnd)) {
                Hwnd := Hwnd.Hwnd
            }
            if (!IsInteger(Hwnd)) {
                throw TypeError("Expected an Object or an Integer",, Type(Hwnd))
            }
            DllCall("EndPaint", "Ptr", Hwnd, PAINTSTRUCT, PaintInfo)
        }


        /**
         * Creates a device context from the given handle.
         * 
         * @param   {Object/Integer}  Handle  handle of the device context
         * @return  {Gdi.DeviceContext}
         */
        static FromHandle(Handle) {
            DC := Object()

            if (!IsInteger(Handle)) {
                throw TypeError("Expected an Integer",, Type(Handle))
            }
            ObjSetBase(DC, this.Prototype)
            DC.DefineProp("Ptr", {
                Get: (Instance) => Handle
            })
            return DC
        }

        FillRect(Rc, Brush) {
            ; TODO make Brush a new type?
            DllCall("FillRect", "Ptr", this.Ptr, RECT, Rc, "Ptr", Brush)
            return this
        }

        BrushColor {
            set {
                DllCall("SetDCBrushColor",
                        "Ptr", this.Ptr,
                        "UInt", Gdi.Swap_RGB_BGR(value))
            }
        }

        BackgroundMode {
            set {
                DllCall("SetBkMode", "Ptr", this.Ptr, "UInt", value)
            }
        }

        BackgroundColor {
            set {
                DllCall("SetBkMode", "Ptr", this.Ptr, "UInt", Gdi.Swap_RGB_BGR(value))
            }
        }

        Cancel() {
            DllCall("CancelDC", "Ptr", this.Ptr)
        }

        ; ChangeDisplaySettings
        ; ChangeDisplaySettingsEx

        CreateCompatibleDC() {
            return DllCall("CreateCompatibleDC", "Ptr", this.Ptr)
        }

        static Create(Driver, Device, Port, DevMode) {

        }

        Delete() {

        }

        DrawEscape(Escape, Input) {

        }

        Release(Hwnd) {
            DllCall("ReleaseDC", "Ptr", Hwnd, "Ptr", this)
        }
    }

    class Palette {

    }

    class Pen {

    }

    class Brush {

    }

    class Bitmap {

    }

    class Path {
        __New(hDC) {
            if (IsObject(hDc)) {
                hDC := hDC.Ptr
            }
            if (!Integer(hDC)) {
                throw TypeError("Expected an Integer or an Object",, Type(hDC))
            }
            this.DefineProp("Ptr", {
                Get: (Instance) => hDC
            })
        }

        Begin() {
            if (!DllCall("BeginPath", "Ptr", this.Ptr)) {
                throw OSError()
            }
            ; TODO approp. message
        }

        Arc() {

        }

        Bezier() {

        }

        Close() {

        }

        End() {

        }

        Stroke() {

        }

        Fill() {

        }

        StrokeAndFill() {

        }

        __Delete() {

        }
    }

    class Font {

    }

    class Region {

    }

    static SolidBrush(Color) {
        return DllCall("CreateSolidBrush", "UInt", Gdi.Swap_RGB_BGR(Color))
    }

    static Swap_RGB_BGR(Color) => ((Color & 0x00FF0000) >> 16)
                                | ((Color & 0x0000FF00)      )
                                | ((Color & 0x000000FF) << 16)

    static DCBrush {
        get {
            static DC_BRUSH := 18
            return DllCall("GetStockObject", "UInt", DC_BRUSH)
        }
    }

    static InformationContext(Driver, Device, Port, DevMode) {

    }

    DeviceCapabilities(Device, Port, Capability, DevMode) {

    }

    class DisplayDevices {
        static __Enum() {

        }
    }

    class DisplaySettings {
        static __New() {

        }
    }

    class DisplaySettingsEx {
        static __New() {

        }
    }
}

class ABC {
    abcA : i32
    abcB : u32
    abcC : i32
}

class ABCFLOAT {
    abcfA : f32
    abcfB : f32
    abcfC : f32
}

