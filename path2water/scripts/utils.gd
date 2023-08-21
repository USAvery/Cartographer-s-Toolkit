class_name Utils
var script_class = "tool"

# ___________________UI Creation Functions___________________

func create_note(tool_panel, msg):
    ##
    ## Create and return a new note node
    ##
    tool_panel.CreateNote(msg)
    return tool_panel.get_children()[-1].get_children()[-1]


func create_label(tool_panel, msg):
    ##
    ## Create and return a new label node
    ##
    tool_panel.CreateLabel(msg)
    return tool_panel.get_children()[-1].get_children()[-1]


func create_separator(tool_panel):
    ##
    ## Create and return a new separator node
    ##
    tool_panel.CreateSeparator()
    return tool_panel.get_children()[-1].get_children()[-1]


func create_line_edit(tool_panel):
    ##
    ## Create and return a new line edit node
    ##
    var line_edit = LineEdit.new()
    tool_panel.get_children()[-1].add_child(line_edit)
    return tool_panel.get_children()[-1].get_children()[-1]


func create_spacer(tool_panel, size):
    ##
    ## Create and return a new control node with a given minimum size
    ##
    var spacer = Control.new()
    spacer.set_custom_minimum_size(size)
    tool_panel.get_children()[-1].add_child(spacer)
    return spacer


func create_slider(tool_panel=null, value=0.0, min_val=0.0, max_val=1.0, step=0.1):
    ##
    ## Create and return a horizontal slider node
    ##
    var slider = HSlider.new()
    slider.set_min(min_val)
    slider.set_max(max_val)
    slider.set_step(step)
    slider.set_value(value)
    if tool_panel:
        tool_panel.get_children()[-1].add_child(slider)
    return slider


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
