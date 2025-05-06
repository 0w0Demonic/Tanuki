/**
 *
 */
class CustomButton extends AquaHotkey_MultiApply {
    static __New() => super.__New(Tanuki.Gui.SplitButton,
                                  Tanuki.Gui.PushButton)
    /**
     * 
     * @param   {String}  Opt  a string containing GuiCtrl options
     */
    ApplySize(Opt) {
        static ContainsSizingOptions := "
        (
        Six)
        (?(DEFINE) (?<size> r | (?:w|h) (?: p(?:\+|-) )? )
                (?<integer> 0 | [1-9]\d*+ )
                (?<float> (?&integer)? \. \d++ )
                (?<number>  (?&integer) | (?&float) ))
        (?&size) (?&number)
        )"

        if (!(Opt ~= ContainsSizingOptions)) {
            ; TODO make this into:
            ; `Ctl.Size := Ctl.IdealSize`
            Sz := this.IdealSize
            ControlMove(unset, unset, Sz.cx // 2, Sz.cy, this)
        }
    }
}
