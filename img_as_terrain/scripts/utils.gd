## Uses Dungeondraft v1.1.0.0
##
## Utility Functions
## Author: Avery Berg
## 
##

# Required Global
var script_class = "tool"


# ___________________Required Functions___________________

func start():
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##
    print("Loaded utils")
    pass


# ___________________UI Creation Functions___________________

func create_note(tool_panel, msg=""):
    ##
    ## Create and return a new note node
    ##
    tool_panel.CreateNote(msg)
    return tool_panel.get_children()[-1].get_children()[-1]


func create_label(tool_panel=null, msg=""):
    ##
    ## Create and return a new label node
    ##
    if tool_panel:
        tool_panel.CreateLabel(msg)
        return tool_panel.get_children()[-1].get_children()[-1]
    
    var label = Label.new()
    label.set_text(msg)
    return label


func create_separator(tool_panel):
    ##
    ## Create and return a new separator node
    ##
    tool_panel.CreateSeparator()
    return tool_panel.get_children()[-1].get_children()[-1]


func create_line_edit(tool_panel=null):
    ##
    ## Create and return a new line edit node
    ##
    var line_edit = LineEdit.new()
    if tool_panel:
        tool_panel.Align.add_child(line_edit)
    return line_edit


func create_hbox(tool_panel=null):
    ##
    ## Create and return a new line edit node
    ##
    var hbox = HBoxContainer.new()
    if tool_panel:
        tool_panel.Align.add_child(hbox)
    return hbox


func create_vbox(parent=null, children=[]):
    ##
    ## Create and return a new VBoxContainer node
    ##
    var vbox = VBoxContainer.new()
    vbox.set_h_size_flags(3)
    vbox.set_v_size_flags(3)

    if parent:
        parent.add_child(vbox)

    for child in children:
        vbox.add_child(child)

    return vbox


func create_labeled_dropdown(msg="", options=[], selected=null):
    ##
    ## Create and return a labeled dropdown
    ##

    # Create the hbox
    var hbox = create_hbox()

    # Add the label
    var label = Label.new()
    label.set_text(msg)
    hbox.add_child(label)

    # Create the dropdown menu
    var dropdown = OptionButton.new()

    # Add the specified options
    for option in options:
        dropdown.add_item(option)

    # Select the specified option
    for i in range(options.size()):
        if options[i] == selected:
            dropdown.select(i)
    
    hbox.add_child(dropdown)

    return dropdown


func create_file_input(tool_panel):
    # file selection is special, and emits signals called on_file_selected and on_file_cleared automatically
    var win_img_filter = "All Images,*.png;*.jpg;*jpeg,PNG (*.png),*.png,JPEG (*.jpg),*.jpg;*jpeg";
    var osx_img_filter = "jpg,png";
    var linux_img_filter = "*.jpg *.png";
    var img_filter = null

    match OS.get_name():
        "Windows":
            img_filter = win_img_filter
        "OSX":
            img_filter = osx_img_filter
        "X11":
            img_filter = linux_img_filter
    
    tool_panel.CreateFileSelector("FileSelectorID", img_filter, OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP))
    return tool_panel.Align.get_children()[-1].get_children()[0]


func create_checkbutton(tool_panel=null, text=null, checked=false):
    ##
    ## Create and return a new CheckButton node
    ##
    var checkbutton = CheckButton.new()
    checkbutton.pressed = checked
    if text:
        checkbutton.set_text(text)

    if tool_panel:
        tool_panel.Align.add_child(checkbutton)

    return checkbutton


# ___________________Misc Functions___________________

func load_tx(file_path):
    ##
    ## Load a texture from a file path
    ## Return the texture object
    ##
    var image = Image.new()
    var err = image.load(file_path)
    if err != OK:
        print("Unable to load texture from path: '" + str(file_path) + "'")
        return null
    
    var texture = ImageTexture.new()
    texture.create_from_image(image, 0)

    return texture


func add_line_to_note(note_obj, msg):
    ##
    ## Add a line of text to a note node
    ##
    if note_obj != null:
        var out_text = note_obj.get_text()
        out_text += "\n" + str(msg)
        note_obj.set_text(out_text)
        return 1
    return 0


func random_bool() -> bool:
    return randi() % 2 == 0


func get_godot_version():
    var version_pattern = RegEx.new()
    version_pattern.compile("((?:\\d+\\.)+\\d+)")

    var version_match = version_pattern.search(Engine.get_version_info()["string"])

    if version_match:
        return version_match.get_string()
    
    return null


func get_attr_safe(obj, attr_name):
    ##
    ## Safely get an attribute from an object (if it exists)
    ##
    if attr_name in obj:
        return obj.get(attr_name)
    else:
        return null


# ___________________Path Functions___________________

func get_split_path(src_path):
    ##
    ## Split a load path or resource path by the sep "/"
    ## Removes "res://" from the path before splitting
    ##
    return src_path.split(':')[-1].right(2).split('/')


func get_basename(src_path):
    ##
    ## Get the basename of a load path or resource path
    ##
    var split_path = get_split_path(src_path)
    if not split_path.size():
        return ""
    return split_path[-1]
    

func get_split_ext(src_path):
    var split = src_path.split('.')
    if not split.size() > 1:
        return [src_path, ""]
    
    var ext = split[-1]
    
    var left_side = ""
    for i in range(split.size()-1):
        left_side = left_side + split[i] + "."
    
    left_side = left_side.left(left_side.length()-1)
    return [left_side, ext]


func get_method_info(method: Dictionary):
    ##
    ## Parse the method dictionary
    ## Create a new method info dictionary with more readable info
    ##
    var method_info = {
        "_method": method,
        "name": method.name,
        "args": [],
        "return": match_type(method["return"].type)
    }
    
    for arg in method["args"]:
        var arg_str = arg["name"]

        var arg_type = match_type(arg["type"])
        if arg_type and arg_type != "undefined":
            if arg_type == "Object" and arg["class_name"]:
                arg_type = arg["class_name"]
            arg_str += ": " + arg_type
        
        method_info["args"].append(arg_str)

    return method_info


func array_join(list, sep=" "):
    var list_str = ""
    for item in list:
        list_str += str(item) + sep
    
    if list.size():
        list_str = list_str.left(list_str.length()-sep.length())

    return list_str


func get_method_info_string(method: Dictionary):
    var method_info = get_method_info(method)

    var info_string = ""
    info_string += method_info["name"] + "("
    info_string += array_join(method_info["args"], ", ") + ")"
    if method_info["return"] and method_info["return"] != "undefined":
        info_string += " => " + method_info["return"]
    return info_string


# ___________________Debug Functions___________________

func print_ancestors(obj, depth=0):
    if not obj:
        return
    
    if depth:
        print("   " + str(obj))
    else:
        print("Ancestors of " + str(obj))

    # Recurse
    print_ancestors(obj.get_parent(), depth+1)

    if not depth:
        print(" ")
        

func dir_string(obj, filter=null, show_values=false, show_method_info=false):
    ##
    ## Get the methods and member variables of an object
    ## Return as a string
    ##
    var str_result = ""
    var methods = []
    var properties = []

    # Get the methods
    for method in obj.get_method_list():
        if filter == null or filter.to_lower() in method.name.to_lower():
            if show_method_info:
                methods.append(get_method_info_string(method))
            else:
                methods.append(method.name)
            

    # Get the member variables
    for prop in obj.get_property_list():
        # if prop.type == 3:
        if filter == null or filter.to_lower() in prop.name.to_lower():
            var prop_value = obj.get(prop.name)
            if show_values:
                properties.append(prop.name + ": " + str(prop_value))
            else:
                properties.append(prop.name)

    methods.sort()
    properties.sort()

    str_result += "Properties:\n"
    for prop in properties:
        str_result += "   " + prop + "\n"

    str_result += "Methods:\n"
    for method in methods:
        str_result += "   " + method + "\n"

    return str_result


func match_type(numeral: int):
    match numeral:
        0:
            return "undefined"
        1:
            return "bool"
        2:
            return "int"
        3:
            return "float"
        4:
            return "String"
        5:
            return "Vector2"
        6:
            return "Rect2"
        7:
            return "Vector3"
        8:
            return "Transform2D"
        9:
            return "Plane"
        10:
            return "Quat"
        11:
            return "AABB"
        12:
            return "Basis"
        13:
            return "Transform"
        14:
            return "Color"
        15:
            return "NodePath"
        16:
            return "RID"
        17:
            return "Object"
        18:
            return "Dictionary"
        19:
            return "Array"
        20:
            return "PoolByteArray"
        21:
            return "PoolIntArray"
        22:
            return "PoolRealArray"
        23:
            return "PoolStringArray"
        24:
            return "PoolVector2Array"
        25:
            return "PoolVector3Array"
        26:
            return "PoolColorArray"
