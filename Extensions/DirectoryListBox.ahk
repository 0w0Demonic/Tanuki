#Requires AutoHotkey v2.0
#Include <AquaHotkey>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\DLG_DIR_LIST_FILE_TYPE>
/**
 * ```
 * class Gui
 * |- AddDirectoryListBox(Opt := "", Display?)
 * |
 * `- class DirectoryListBox extends Gui.ListBox
 *    |- Type { get; }
 *    |- Path { get; set; }
 *    |- Display { get; set; }
 *    |- Filter { get; set; }
 *    `- Select(Path, Filter := 0)
 * ```
 */
class Tanuki_DirectoryListBox extends AquaHotkey {
class Gui {
    /**
     * Adds a list box with the names of the subdirectories and files in a
     * specified directory. You can filter the names by specifying a set of
     * attributes (`DLG_DIR_LIST_FILE_TYPE`). The list can optionally include
     * mapped drives.
     * 
     * @example
     * DirListBox := G.AddDirectoryListBox("w350", Gui.AddText("w350"))
     * DirListBox.Select("C:\users\me\Desktop")
     * 
     * @param   {String?}    Opt      options string
     * @param   {Gui.Text?}  Display  text control to display directory in
     */
    AddDirectoryListBox(Opt := "", Display?) {
        LB := this.AddListBox(Opt)
        ObjSetBase(LB, Gui.DirectoryListBox.Prototype)
        if (IsSet(Display)) {
            LB.Display := Display
        }
        return LB
    }

    /**
     * A list box which lists the contents in a specified directory.
     */
    class DirectoryListBox extends Gui.ListBox {
        /**
         * Returns the name of the class.
         * 
         * @returns {String}
         */
        Type => "DirectoryListBox"

        /**
         * Gets or sets the currently listed directory path.
         * 
         * Setting this property calls `Select()` with the current attribute
         * filter.
         * 
         * @param   {String}  Value  the directory be moved into
         * @returns {String}
         */
        Path {
            get => ""
            set => this.Select(value)
        }

        /**
         * Gets and sets the text control used by the directory list box.
         * 
         * @param   {Gui.Text}  value  the text control to be used
         * @returns {Integer} control ID of the text control
         */
        Display {
            get => 0
            set {
                if (!(value is Gui.Text)) {
                    throw TypeError("Expected a Gui.Text",, Type(value))
                }
                Id := WindowsAndMessaging.GetDlgCtrlID(value.Hwnd)
                this.DefineProp("Display", { Get: (_) => Id })
                if (this.Path) {
                    this.Select(this.Path)
                }
            }
        }

        /**
         * Gets or sets the current attribute filter of the directory list box
         * (see `DLG_DIR_LIST_FILE_TYPE`).
         * 
         * Setting this property causes the list to be refreshed with the new
         * attribute filter.
         * 
         * @example
         * T := DLG_DIR_LIST_FILE_TYPE
         * 
         * ; directories only
         * DirListBox.Filter := T.DDL_DIRECTORY | T.DDL_EXCLUSIVE
         * 
         * @param   {Integer}  value  attribute flags
         * @returns {Integer}
         */
        Filter {
            get => 0
            set {
                if (!IsInteger(value)) {
                    throw TypeError("Expected an Integer",, Type(value))
                }
                this.DefineProp("Filter", { Get: (_) => value })
                if (this.Path) {
                    this.Select(this.Path)
                }
            }
        }

        ; TODO make using file attributes easier?

        /**
         * Replaces the context of the directory list box with the contents
         * of the specified directory.
         * 
         * The directory must exist, otherwise a `TargetError` is thrown.
         * 
         * When `Filter` is set, it will be taken as new attribute filter.
         * 
         * See also: [DlgDirListW](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-dlgdirlistw)
         * 
         * @example
         * T := DLG_DIR_LIST_FILE_TYPE
         * DirListBox.Select(A_ScriptDir, T.DDL_DIRECTORY | T.DDL_EXCLUSIVE)
         * 
         * @param   {String}    Path    absolute/relative path, or filename
         * @param   {Integer?}  Filter  attributes of files or dirs to be added
         */
        Select(Path, Filter?) {
            if (!(Path is String)) {
                throw TypeError("Expected a String",, Type(Path))
            }
            if (!DirExist(Path)) {
                throw TargetError("Directory does not exist",, Path)
            }
            if (IsSet(Filter)) {
                this.Filter := Filter
            }
            IdListBox := WindowsAndMessaging.GetDlgCtrlID(this.Hwnd)
            if (!Controls.DlgDirListW(
                    this.Gui.Hwnd, Path,
                    IdListBox, this.Display,
                    this.Filter)) {
                throw OSError(A_LastError)
            }
            this.DefineProp("Path", { Get: (_) => Path })
        }

        ; TODO add properties for getting the *full* path of current selection?
    }
} ; class Gui
} ; class Tanuki_DirectoryListBox extends AquaHotkey