## Uses Dungeondraft v1.1.0.0
##
## Scatter Plus v1.2.0
## Author: Avery Berg
## 
## Preset Handler
## Handles preset functionality for scatter groups
##
class_name PresetHandler

# Signals
signal changed_preset(selected_preset)

# Required Global
var script_class = "tool"
var _global = null

# External Scripts
var utils = null

# Globals
var preset_file_path = null
var scatter_tool = null

var on_icon = null
var off_icon = null

var preset_dropdown = null
var name_input = null
var save_button = null

var presets_dict = {}
var prev_preset = null


# ___________________I/O Functions___________________

func load_presets_dict():
    ##
    ## Load the presets dictionary from the external json file
    ##

    # Open the file for reading
    var file = File.new()
    if file.open(preset_file_path, File.READ) != OK:
        print("Failed to open the presets file: " + preset_file_path)
        return false
    
    var file_text = file.get_as_text()
    
    # Load the JSON data from the file
    print("Parsing file data into a JSON")
    presets_dict = parse_json(file_text)

    if not presets_dict:
        presets_dict = {}

    # Close the file
    file.close()

    print("Loaded the ScatterPlus presets")
    
    # Refresh the preset dropdown
    refresh_preset_dropdown()

    return true


func save_preset(name, scatter_group):
    ##
    ## Save a new preset to the presets json
    ##

    # Create a preset
    var preset = create_preset(name, scatter_group)
    if not preset:
        return false
    
    # Remove the preset if it has no resource paths
    var do_remove_preset = not preset["resource_paths"]

    # Open the file for writing
    var file = File.new()
    if file.open(preset_file_path, File.WRITE) != OK:
        print("Failed to open presets file: " + preset_file_path)
        return false
    
    print("Opened the presets file")
    
    # Add the preset to the file data
    # Remove the preset from the file data if blank
    if do_remove_preset:
        presets_dict.erase(preset["name"])
    else:
        presets_dict[preset["name"]] = preset

    # Save the presets dictionary to the file
    file.store_string(to_json(presets_dict))

    # Close the file
    file.close()

    print("Saved the presets file")

    # Refresh the preset dropdown menu
    refresh_preset_dropdown()

    return true


# ___________________Check Functions___________________

func is_valid_preset_name(name):
    ##
    ## Determine if a preset name is valid
    ##
    var stripped_name = name.strip_edges(true, true)
    if stripped_name and stripped_name != "Custom":
        return true
    
    return false


func in_custom_preset_mode():
    ##
    ## Check if the current preset is "Custom"
    ##
    if get_selected_preset() == "Custom":
        return true
    return false


# ___________________Misc Functions___________________

func create_preset(name, scatter_group):
    ##
    ## Create a preset
    ##
    if not is_valid_preset_name(name):
        return null
        # name = name_input.get_text()
        # if not is_valid_preset_name(name):
        #     return null
    var preset = {
        "name": name,
        "resource_paths": []
    }

    # Populate the resource paths
    for scatter_item in scatter_group:
        preset["resource_paths"].append(scatter_item.resource_path)
    
    return preset


func get_preset_data(name):
    ##
    ## Get the data needed for a preset
    ##
    if name == "Custom":
        return null
    
    return presets_dict.get(name)


func get_selected_preset():
    ##
    ## Get the name of the selected preset
    ##
    var index = preset_dropdown.get_selected_id()

    if index < preset_dropdown.get_item_count():
        return preset_dropdown.get_item_text(index)
    else:
        print("Index out of range.")
        return ""


func refresh_preset_dropdown():
    print("Refreshing ScatterPlus preset dropdown")
    
    preset_dropdown.clear()
    preset_dropdown.add_item("Custom")

    for key in presets_dict.keys():
        preset_dropdown.add_item(key)
    
    print("Finishing refreshing dropdown")


func load_needed_textures():
    ##
    ## Load in all textures used by saved presets
    ##
    print("Loading the needed textures for saved presets")

    var obj_menu = _global.Editor.ObjectLibraryPanel.objectMenu

    # Load in the textures used by saved presets
    var loaded_resource_paths = []
    for preset_name in presets_dict.keys():
        for res_path in presets_dict[preset_name]["resource_paths"]:
            if not loaded_resource_paths.has(res_path):
                var menu_index = obj_menu.Lookup.get(res_path)
                obj_menu.OnItemSelected(menu_index)
                loaded_resource_paths.append(res_path)
    
    # Reset the object menu's selection
    # obj_menu.select(0, true)
    obj_menu.OnItemSelected(0)


# ___________________Base Functions___________________

func tick(delta):
    ##
    ## Called once per tick
    ##

    if scatter_tool == _global.Editor.ActiveTool:
        var cur_preset = get_selected_preset()

        if cur_preset != prev_preset:
            print("Changed preset to " + str(cur_preset))
            emit_signal("changed_preset", cur_preset)
        
        prev_preset = cur_preset


func init(caller):
    ##
    ## Initialize the Preset Handler
    ##
    print("Initializing preset_handler")

    # Assign Global reference
    _global = caller._global
    if not _global is Dictionary:
        _global = caller.Global

    preset_file_path = _global.Root + "data/presets.json"

    print("Loading utils from preset handler")

    # Load any external scripts
    utils = load(_global.Root + "scripts/utils.gd").new()

    print("Initializing utils from preset handler")

    # Initialize any external scripts
    utils.init(self)

    # Cache the scatter tool
    scatter_tool = _global.Editor.Tools["ScatterTool"]

    print("Creating Dropdown")

    # Create the "Preset" dropdown menu
    preset_dropdown = utils.create_labeled_dropdown("Preset", ["Custom"], "Custom")
    
    print("Creating HBox")

    # Create the hbox
    var hbox = utils.create_hbox()

    print("Creating Label")

    # Add the group label
    var group_label = Label.new()
    group_label.set_text("Name")
    hbox.add_child(group_label)

    print("Creating LineEdit")

    # Create the "Name" line edit
    name_input = LineEdit.new()
    name_input.set_custom_minimum_size(Vector2(145, 5))
    hbox.add_child(name_input)

    print("Creating Button")

    # Create and add the "Save Preset" button
    save_button = Button.new()
    save_button.set_tooltip("Save as Preset")
    save_button.icon = utils.load_tx(_global.Root + "icons/save.png")
    hbox.add_child(save_button)

    # Load the presets
    load_presets_dict()

    prev_preset = get_selected_preset()

    # Load the needed textures
    load_needed_textures()

    print("Finished initializing preset_handler")


func start():
    pass
