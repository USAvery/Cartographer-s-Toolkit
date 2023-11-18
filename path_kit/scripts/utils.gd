## Uses Dungeondraft v1.1.0.0
##
## PathKit v0.2.0
## Author: Avery Berg
## 
## Utility Functions
##

class_name Utils
var script_class = "tool"


# ___________________UI Creation Functions___________________

func create_note(tool_panel, msg=""):
    ##
    ## Create and return a new note node
    ##
    tool_panel.CreateNote(msg)
    return tool_panel.Align.get_children()[-1]


func create_label(tool_panel=null, msg=""):
    ##
    ## Create and return a new label node
    ##
    if tool_panel:
        tool_panel.CreateLabel(msg)
        return tool_panel.Align.get_children()[-1]
    
    var label = Label.new()
    label.set_text(msg)
    return label


func create_separator(tool_panel):
    ##
    ## Create and return a new separator node
    ##
    tool_panel.CreateSeparator()
    return tool_panel.Align.get_children()[-1]


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
    ## Create and return a new HBoxContainer node
    ##
    var hbox = HBoxContainer.new()
    hbox.set_h_size_flags(3)
    if tool_panel:
        tool_panel.Align.add_child(hbox)
    return hbox


func create_action_hbox(caller, apply_callback, cancel_callback):
    ##
    ## Create and return an action hbox
    ## An hbox containing an apply and cancel button
    ##

    # Create the hbox
    var hbox = create_hbox()
    hbox.set_h_size_flags(3)

    # Add the "Apply" button
    var apply_button = create_button('Apply')
    apply_button.set_h_size_flags(3)
    apply_button.connect('pressed', caller, apply_callback)
    hbox.add_child(apply_button)

    # Create the "Cancel" menu
    var cancel_button = create_button('Cancel')
    cancel_button.set_h_size_flags(3)
    cancel_button.connect('pressed', caller, cancel_callback)
    hbox.add_child(cancel_button)

    return hbox


func create_labeled_dropdown(msg="", options=[], selected=null):
    ##
    ## Create and return a labeled dropdown
    ##

    # Create the hbox
    var hbox = create_hbox()
    hbox.set_h_size_flags(3)

    # Add the label
    var label = Label.new()
    label.set_text(msg)
    label.set_h_size_flags(1)
    hbox.add_child(label)

    # Create the dropdown menu
    var dropdown = OptionButton.new()
    dropdown.set_h_size_flags(3)

    # Add the specified options
    for option in options:
        dropdown.add_item(option)

    # Select the specified option
    for i in range(options.size()):
        if options[i] == selected:
            dropdown.select(i)
    
    hbox.add_child(dropdown)

    return dropdown


func create_slider(tool_panel=null, value=0.0, min_val=0.0, max_val=1.0, step=0.1):
    ##
    ## Create and return a horizontal slider node
    ## has a spinbox sibling
    ## contained in an hbox
    ##

    # Create the hbox
    var hbox = create_hbox(tool_panel)
    hbox.set_h_size_flags(3)

    # Create the slider
    var slider = HSlider.new()
    slider.set_min(min_val)
    slider.set_max(max_val)
    slider.set_step(step)
    slider.set_value(value)
    slider.set_h_size_flags(3)
    slider.set_v_size_flags(4)
    hbox.add_child(slider)

    # Create the spinbox
    var spin_box = SpinBox.new()
    spin_box.set_min(min_val)
    spin_box.set_max(max_val)
    spin_box.set_use_rounded_values(false)
    spin_box.set_step(0.1)
    spin_box.set_value(value)
    spin_box.set_h_size_flags(1)
    hbox.add_child(spin_box)

    # Connect the slider and spinbox
    slider.connect("value_changed", spin_box, "set_value")
    spin_box.connect("value_changed", slider, "set_value")

    return slider


func create_spacer(tool_panel, size):
    ##
    ## Create and return a new control node with a given minimum size
    ##
    var spacer = Control.new()
    spacer.set_custom_minimum_size(size)
    tool_panel.Align.add_child(spacer)
    return spacer


func create_item_list(tool_panel=null):
    ##
    ## Create and return a new item list node
    ##
    var item_list = ItemList.new()
    item_list.set_fixed_icon_size(Vector2(32, 32))
    item_list.set_h_size_flags(3)
    item_list.set_v_size_flags(3)
    item_list.set_max_columns(32)
    item_list.add_color_override("guide_color", Color(0, 0, 0, 0.12549))
    item_list.set("custom_constants/vseparation", 4)
    item_list.set("custom_constants/line_separation", 0)
    item_list.set("custom_constants/hseparation", 4)
    item_list.set_custom_minimum_size(Vector2(100, 100))

    if tool_panel:
        tool_panel.Align.add_child(item_list)
    return item_list


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


func create_button(text=null, icon_path=null):
    ##
    ## Create and return a new Button node
    ##
    var button = Button.new()
    if text:
        button.set_text(text)
    
    if icon_path:
        button.icon = load_tx(icon_path)
    
    return button


func create_checkbutton(text=null):
    ##
    ## Create and return a new CheckButton node
    ##
    var checkbutton = CheckButton.new()
    if text:
        checkbutton.set_text(text)
    
    return checkbutton

# ___________________Query Functions___________________

func get_selected_items():
    ##
    ## Get the selected items
    ##
    var select_tool = Global.Editor.Tools["SelectTool"]
    var selected_items = select_tool.Selected
    
    return selected_items


func get_patterns():
    ##
    ## Get all the pattern shapes
    ##
    var cur_level = Global.World.levels[Global.World.CurrentLevelId]
    var patterns = []

    # Iterate through the layers
    for layer in cur_level.PatternShapes.get_children():
        
        # Iterate through the pattern shapes
        for pattern_shape in layer.get_children():
            patterns.append(pattern_shape)
    
    return patterns


func get_paths():
    ##
    ## Get all the path nodes
    ##
    var cur_level = Global.World.levels[Global.World.CurrentLevelId]
    return cur_level.Pathways.get_children()


func get_selected_path():
    ##
    ## Get the selected path
    ##
    var paths = get_paths()

    for item in get_selected_items():
        if item in paths:
            return item
    
    return null


func get_selected_pattern_shape():
    ##
    ## Get the selected pattern shape
    ##
    var pattern_shapes = get_patterns()

    for item in get_selected_items():
        if item in pattern_shapes:
            return item
    
    return null


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


func clear_note(note_obj):
    ##
    ## Clear the text in a note node
    ##
    note_obj.set_text(" ")


func random_bool() -> bool:
    ##
    ## Get a random bool value
    ##
    return randi() % 2 == 0


func array_join(list, sep=" "):
    var list_str = ""
    for item in list:
        list_str += str(item) + sep
    
    if list.size():
        list_str = list_str.left(list_str.length()-sep.length())

    return list_str


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


func get_method_info_string(method: Dictionary):
    var method_info = get_method_info(method)

    var info_string = ""
    info_string += method_info["name"] + "("
    info_string += array_join(method_info["args"], ", ") + ")"
    if method_info["return"] and method_info["return"] != "undefined":
        info_string += " => " + method_info["return"]
    return info_string


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


func script_dir_string(script, filter=null, show_values=false, show_method_info=false):
    ##
    ## Get the methods and member variables of an script
    ## Return as a string
    ##
    var str_result = ""
    var methods = []
    var properties = []

    # Get the methods
    for method in script.get_script_method_list():
        if filter == null or filter.to_lower() in method.name.to_lower():
            if show_method_info:
                methods.append(get_method_info_string(method))
            else:
                methods.append(method.name)

    # Get the member variables
    for prop in script.get_script_property_list():
        # if prop.type == 3:
        if filter == null or filter.to_lower() in prop.name.to_lower():
            var prop_value = script.get(prop.name)
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


func search_down(obj, filter=null, camel_only=false, display_ancestors=false):
    if not obj:
        return

    var dir_str = dir_string(obj, filter)

    # Also look for signals
    # for sig in obj.get_signal_list():
    #     if filter.lower() in sig.name.lower():
    #         dir_str += sig.name + '\n'

    var camel_size = 0

    for line in dir_str.split('\n'):
        if camel_only and line.to_lower() != line:
            camel_size += 1

    if not camel_only or camel_size > 3:
        if dir_str.split('\n').size() > 3:            
            print('\n---' + str(obj) + '---')
            for line in dir_str.split('\n'):
                if camel_only and line.to_lower() == line:
                    continue
                print(line)
            if display_ancestors:
                print(' ')
                print_ancestors(obj)
    
    for child in obj.get_children():
        search_down(child, filter, camel_only, display_ancestors)


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


func start():
    pass