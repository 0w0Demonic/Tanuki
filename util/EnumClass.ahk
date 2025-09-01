/**
 * Utility that generates useful methods for classes that are meant to be
 * used as enums.
 */
class EnumClass {
    static Transform(Target) {
        static GetOwnPropDesc := (Object.Prototype.GetOwnPropDesc)
        static Define := (Object.Prototype.DefineProp)
        if (!(Target is Class)) {
            throw TypeError("Expected a Class",, Type(Target))
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