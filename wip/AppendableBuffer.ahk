#Requires AutoHotkey v2.0

class AppendableBuffer extends Buffer {
    Pos := 0

    Align(Align) {
        if (Align & (Align - 1)) {
            throw ValueError("Must be a power of 2",, Format("{:#X}", Align))
        }
        Mask := (Align - 1)
        NewPos := (this.Pos + Mask) & ~Mask
        Size := NewPos - this.Pos
        this.EnsureCapacity(Size)

        Loop (Size) {
            NumPut("UChar", 0, this, this.Pos)
        }
        this.Pos += Size
        return this
    }

    AddChar(Value)   => this.Add(Value, "Char", 1)
    AddUChar(Value)  => this.Add(Value, "UChar", 1)
    AddShort(Value)  => this.Add(Value, "Short", 2)
    AddUShort(Value) => this.Add(Value, "UShort", 2)
    AddInt(Value)    => this.Add(Value, "Int", 4)
    AddUInt(Value)   => this.Add(Value, "UInt", 4)
    AddInt64(Value)  => this.Add(Value, "Int64", 8)
    AddUInt64(Value) => this.Add(Value, "UInt64", 8)
    AddPtr(Value)    => this.Add(Value, "Ptr", A_PtrSize)
    AddUPtr(Value)   => this.Add(Value, "UPtr", A_PtrSize)

    AddData(Mem, Size := Mem.Size) {
        this.EnsureCapacity(Size)
        Loop Size {
            Offset := (A_Index - 1)
            Value := NumGet(Mem, Offset, "UChar")
            NumPut("UChar", Value, this, this.Pos + Offset)
        }
        this.Pos += Size
        return this
    }

    AddString(Str, Encoding := "UTF-16") {
        Size := StrPut(Str, Encoding)
        this.EnsureCapacity(Size)
        StrPut(Str, this.Ptr + this.Pos, Encoding)
        this.Pos += Size
        return this
    }

    Add(Value, DataType, Size) {
        this.EnsureCapacity(Size)
        NumPut(DataType, Value, this, this.Pos)
        this.Pos += Size
        return this
    }

    AddResource(Res := "") {
        if (Res is Integer) {
            return this.AddUShort(0xFFFF).AddUShort(Res & 0xFFFF)
        }
        return this.AddString(Res)
    }

    EnsureCapacity(Size) {
        while ((this.Pos + Size) > this.Size) {
            this.Size *= 2
        }
        return this
    }
}
