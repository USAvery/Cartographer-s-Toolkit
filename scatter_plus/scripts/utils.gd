## Uses Dungeondraft v1.1.0.0
##
## Utility Functions
## Author: Avery Berg
## 
##
class_name Utils

# Required Global
var script_class = "tool"
var _global = null


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



func get_asset_pack_name_from_id(pack_id):
    ##
    ## Get the name of an asset pack from it's id
    ##
    for asset_pack in _global.Header.get_AssetManifest():
        if asset_pack.get_ID() == pack_id:
            return asset_pack.get_Name()
    
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


func get_pack_id_from_res_path(res_path):
    ##
    ## Get the id of an asset pack from an object's resource path
    ##
    var split_path = res_path.split(':')[-1].right(2).split('/')
    if not split_path.size() or split_path[0] != "packs":
        return null
    
    return split_path[1]


# ___________________Debug Functions___________________

func dir_string(obj, filter=null):
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
            methods.append(method.name)

    # Get the member variables
    for prop in obj.get_property_list():
        # if prop.type == 3:
        if filter == null or filter.to_lower() in prop.name.to_lower():
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


# ___________________Base Functions___________________

func init(caller):
    ##
    ## Initialize the script
    ##

    # Assign Global reference
    _global = caller._global
    if not _global is Dictionary:
        _global = caller.Global


func start():
    pass
