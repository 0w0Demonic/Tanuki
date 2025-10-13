#Requires AutoHotkey v2.0

class AppendableBuffer extends Buffer {
    Offset := 0

    ; TODO add more
    AppendUShort(Value) => this.Append("UShort", 2, Value)

    AppendPtr(Value) => this.Append("Ptr", 8, Value)

    Append(DataType, Size, Value) {
        if (!(DataType is String)) {
            throw TypeError("Expected a String",, Type(DataType))
        }
        if (!IsInteger(Size)) {
            throw TypeError("Expected an Integer",, Type(Size))
        }
        this.EnsureCapacity(Size)
        NumPut(DataType, Value, this, this.Offset)
        this.Offset += Size
        return this
    }

    AppendData(Mem, Size := Mem.Size) {
        this.EnsureCapacity(Size)
        Loop Size {
            Num := NumGet(Mem, A_Index - 1, "UChar")
            NumPut("UChar", Num, this, this.Offset + (A_Index - 1))
        }
        this.Offset += Size
        return this
    }

    AppendString(Str, Encoding := "UTF-16") {
        if (!(Str is String)) {
            throw TypeError("Expected a String",, Type(Str))
        }
        Size := StrPut(Str, Encoding)
        this.EnsureCapacity(Size)
        StrPut(Str, this.Ptr + this.Offset)
        this.Offset += Size
        return this
    }

    Align(Size) {
        ; asserts that this is a 2^n integer
        if (Size & (Size - 1)) {
            throw ValueError("Expected a power of 2",, Size)
        }
        Mask := (Size - 1)
        this.Offset := (this.Offset + Mask) & ~Mask ; evil bit hack
        return this
    }

    /**
     * 
     */
    EnsureCapacity(Size) {
        while ((this.Offset + Size) > this.Size) {
            this.Size *= 2
        }
        return this
    }
}