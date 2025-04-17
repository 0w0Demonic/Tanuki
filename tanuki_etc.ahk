

class Tanuki {

}

class Gdi32_DLL extends DLL {
    static FilePath => "gdi32.dll"

    static TypeSignatures => {
        SetBkColor:       "Ptr, UInt",
        SetTextColor:     "Ptr, UInt",
        CreateSolidBrush: "UInt, Ptr",
        DeleteObject:     "Ptr"
    }
}

class Gdi32 extends Gdi32_DLL {
    class DeviceContext {
        __New(Ptr) {
            this.DefineProp("Ptr", {
                Get: (Instance) => Ptr
            })
        }

        BackColor {
            set {
                Color := Tanuki.Swap_RGB_BGR(value)
                Gdi32_DLL.SetBkColor(this, Color)
            }
        }

        TextColor {
            set {
                Color := Tanuki.Swap_RGB_BGR(value)
                Gdi32_DLL.SetTextColor(this, Color)
            }
        }

        __Delete() {
            Gdi32_DLL.DeleteObject(this)
        }
    }

    class SolidBrush {
        __New(Color) {
            Color := Tanuki.Swap_RGB_BGR(value)
        }

        __Delete() {
            Gdi32_DLL.DeleteObject(this)
        }
    }
}

class RECT {
    Left   : i32
    Top    : i32
    Right  : i32
    Bottom : i32

    __New(Left := 0, Top := 0, Right := 0, Bottom := 0) {
        this.Left   := Left
        this.Top    := Top
        this.Right  := Right
        this.Bottom := Bottom
    }

    Width  => Abs(this.Bottom - this.Top)
    Height => Abs(this.Right  - this.Left)

    static CopyFrom(Ptr) {
        
    }
}