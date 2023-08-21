## Uses Dungeondraft v1.1.0.0
##
## Utility Functions
## Author: Avery Berg
## 
##

# Required Global
var script_class = "tool"

var all_script_paths = [
    'res://scripts/framework/Global.cs',
    'res://scripts/framework/Master.cs',
    'res://scripts/framework/Camera.cs',
    'res://scripts/world/World.cs',
    'res://scripts/framework/GridMesh.cs',
    'res://scripts/world/WorldUI.cs',
    'res://scripts/framework/Editor.cs',
    'res://scripts/ui/Toolset.cs',
    'res://scripts/ui/ToolsetButton.cs',
    'res://scripts/ui/Toolbar.cs',
    'res://scripts/ui/ToolbarButton.cs',
    'res://scripts/ui/ToolPanel.cs',
    'res://scripts/ui/panels/SelectToolPanel.cs',
    'res://scripts/ui/panels/TextToolPanel.cs',
    'res://scripts/ui/panels/PrefabToolPanel.cs',
    'res://scripts/ui/panels/MapWizardPanel.cs',
    'res://scripts/ui/PreviewContainer.cs',
    'res://scripts/ui/panels/ObjectLibraryPanel.cs',
    'res://scripts/ui/elements/GridMenu.cs',
    'res://scripts/ui/Infobar.cs',
    'res://scripts/ui/windows/NewWindow.cs',
    'res://scripts/ui/windows/UnsavedChangesWindow.cs',
    'res://scripts/ui/windows/TagsBrowser.cs',
    'res://scripts/ui/elements/CustomList.cs',
    'res://scripts/ui/windows/TextEditWindow.cs',
    'res://scripts/ui/windows/NewLevelWindow.cs',
    'res://scripts/ui/windows/ExportWindow.cs',
    'res://scripts/ui/windows/PreferencesWindow.cs',
    'res://scripts/ui/windows/HelpWindow.cs',
    'res://scripts/ui/windows/CompareLevelsWindow.cs',
    'res://scripts/ui/windows/ChangeMapSizeWindow.cs',
    'res://scripts/ui/windows/AssetsWindow.cs',
    'res://scripts/ui/windows/AssetPackerWindow.cs',
    'res://scripts/ui/windows/WelcomeWindow.cs',
    'res://scripts/ui/windows/UpdateWindow.cs',
    'res://scripts/ui/Draw.cs',
    'res://scripts/ui/windows/NewTemplateWindow.cs',
    'res://scripts/ui/windows/MakePrefabWindow.cs',
    'res://scripts/ui/windows/MapInfoWindow.cs',
    'res://scripts/ui/windows/TerrainWindow.cs',
    'res://scripts/ui/panels/PathLibraryPanel.cs',
    'res://scripts/ui/WarnBox.cs',
    'res://scripts/ui/windows/ModsWindow.cs',
    'res://scripts/ui/panels/ModRightsidePanel.cs',
    'res://scripts/world/Level.cs',
    'res://scripts/world/FloorTileMap.cs',
    'res://scripts/world/FloorTileCamera.cs',
    'res://scripts/world/Terrain.cs',
    'res://scripts/world/CaveMesh.cs',
    'res://scripts/world/FloorShapes.cs',
    'res://scripts/world/WaterMesh.cs',
    'res://scripts/world/WaterPreMesh.cs',
    'res://scripts/world/PatternShapes.cs',
    'res://scripts/world/Pathways.cs',
    'res://scripts/world/Objects.cs',
    'res://scripts/world/Walls.cs',
    'res://scripts/world/Lights.cs',
    'res://scripts/world/Texts.cs',
    'res://scripts/world/Roofs.cs',
    'res://scripts/ui/panels/TagsPanel.cs',
    'res://scripts/ui/elements/RangeSlider.cs',
    'res://scripts/ui/elements/MinSlider.cs',
    'res://scripts/world/objects/Portal.cs',
    'res://scripts/world/objects/Text.cs'
]


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
        tool_panel.get_children()[-1].add_child(line_edit)
    return line_edit


func create_hbox(tool_panel=null):
    ##
    ## Create and return a new line edit node
    ##
    var hbox = HBoxContainer.new()
    if tool_panel:
        tool_panel.get_children()[-1].add_child(hbox)
    return hbox


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


func save_txt(txt, path):
    ##
    ## Save txt to a file
    ##

    # Open the file for writing
    var file = File.new()
    if file.open(path, File.WRITE) != OK:
        print("Failed to open file: " + path)
        return false
    
    print("Opened the file")

    # Save the presets dictionary to the file
    file.store_string(str(txt))

    # Close the file
    file.close()

    print("Saved the file")

    return true


func load_shader(path):
    ##
    ## Load a shader from a path
    ##

    # Open the file for reading
    var file = File.new()
    if file.open(path, File.READ) != OK:
        print("Failed to open the file: " + path)
        return
    
    var shader_code = file.get_as_text()

    # Close the file
    file.close()

    var shader = Shader.new()    
    shader.set_code(shader_code)
    
    return shader



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
