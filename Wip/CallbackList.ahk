#Requires AutoHotkey v2.0

class CallbackList {
    M := Map()
    First := false
    Last := false

    __New(Callbacks*) {
        for Callback in Callbacks {
            this.AddLast(Callback)
        }
    }

    Call(Args*) {
        Result := unset
        for Callback in this {
            Result := Callback(Args*)
        }
        return Result
    }

    AddFirst(Callback) {
        GetMethod(Callback)
        if (this.M.Has(Callback)) {
            return
        }
        Node := { Previous: false, Value: Callback }

        if (!this.M.Count) {
            this.Last := Node
            Node.Next := false
        } else {
            Node.Next := this.First
            this.First.Previous := Node
        }
        this.M.Set(Callback, true)
        this.First := Node
    }

    AddLast(Callback) {
        GetMethod(Callback)
        if (this.M.Has(Callback)) {
            return
        }
        Node := { Next: false, Value: Callback }

        if (!this.M.Count) {
            this.First := Node
            Node.Previous := false
        } else {
            Node.Previous := this.Last
            this.Last.Next := Node
        }
        this.M.Set(Callback, true)
        this.Last := Node
    }

    RemoveFirst() {
        if (!this.M.Count) {
            throw UnsetItemError("this map is empty")
        }
        Node := this.First
        this.M.Delete(Node.Value)
        if (!this.M.Count) {
            this.First := false
            this.Last := false
        } else {
            this.First := Node.Next
        }
        return Node.Value
    }

    RemoveLast() {
        if (!this.M.Count) {
            throw UnsetItemError("this map is empty")
        }
        Node := this.Last
        this.M.Delete(Node.Value)
        if (!this.M.Count) {
            this.M.Clear()
            this.First := false
            this.Last := false
        } else {
            this.Last := Node.Previous
        }
        return Node.Value
    }

    __Enum(ArgSize) {
        return Enumer

        Enumer(&Value) {
            static Node := this.First
            if (!Node) {
                return false
            }
            Value := Node.Value
            Node := Node.Next
            return true
        }
    }
}

List := CallbackList()

Callback(*) => MsgBox("first")
List.AddFirst(Callback)
List.AddLast(Callback)
List()
