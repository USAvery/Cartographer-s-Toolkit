## Uses Dungeondraft v1.1.0.0
##
## Scatter Plus v1.2.0
## Author: Avery Berg
## 
## Group Handler
## Handles base functionality scatter groups
##

# Required Global
var script_class = "tool"
var _global = null

# External Scripts
var utils = null
var preset_handler = null

# Globals
var scatter_tool = null
var group_item_list = null
var group_checkbox = null
var speed_slider = null
var group_container = null

var scatter_group = []
var in_group_mode = false

var cur_texture = null

var time_since_random = 0.0


# ___________________Preset Functions___________________

func load_preset(name):
    ##
    ## Load a preset group
    ##
    print("Loading preset " + str(name))
    clear_group()
    if name == "Custom":
        preset_handler.name_input.set_text(" ")
        return
    
    var preset_data = preset_handler.get_preset_data(name)
    if not preset_data:
        return
    
    preset_handler.name_input.set_text(name)
    for resource_path in preset_data.get("resource_paths"):
        add_to_group(load(resource_path))
    
    randomize_asset()
    print("Loaded preset: " + name)


func save_preset():
    ##
    ## Callback function for clicking the save button
    ##
    preset_handler.save_preset(preset_handler.name_input.get_text(), scatter_group)


# ___________________Misc Functions___________________

func randomize_asset(delta=null):
    ##
    ## Select a random texture from the scatter group and
    ##   assign it to the scatter tool
    ##

    # Always randomize when delta is null
    if delta == null:
        delta = 99.0
    
    if scatter_group.size() == 0:
        return
    
    if speed_slider.get_value() == 0 and cur_texture:
        scatter_tool.Preview.Texture = cur_texture
        scatter_tool.PromoteCustomColor()
        return
    
    var time_needed = (-0.221 * speed_slider.get_value()) + 2.22
    
    if cur_texture and time_needed > time_since_random:
        time_since_random += delta
        scatter_tool.Preview.Texture = cur_texture
        scatter_tool.PromoteCustomColor()
        return
    
    var r_index : int = randi() % scatter_group.size()
    var random_tx = scatter_group[r_index]
    scatter_tool.Preview.Texture = random_tx
    scatter_tool.PromoteCustomColor()
    cur_texture = random_tx
    time_since_random = delta


# ___________________Group Mode Functions___________________

func clear_group():
    ##
    ## Clear the scatter group
    ## Clear the group item list
    ##
    group_item_list.clear()
    scatter_group.clear()


func add_to_group(new_texture=null):
    ##
    ## Add the current preview texture to the scatter group
    ##
    if not new_texture:
        new_texture = scatter_tool.Preview.Texture
        if not new_texture:
            return 

    scatter_group.append(new_texture)
    group_item_list.add_icon_item(new_texture)


func set_group_mode(value):
    ##
    ## Set the group mode
    ## Toggle the visibility of the group ui section
    ## Set or unset the scatter tool's texture
    ##
    print("Setting group mode to " + str(value))

    in_group_mode = value
    
    # Toggle the visibility of the group ui section
    group_container.visible = in_group_mode
    
    # Set or unset the scatter tool's texture
    if in_group_mode:
        randomize_asset()
    if not in_group_mode:
        var obj_menu = _global.Editor.ObjectLibraryPanel.objectMenu
        scatter_tool.Preview.Texture = obj_menu.get_Selected()
        scatter_tool.PromoteCustomColor()
    
    # Ensure the group_item_list doesn't remain collapsed
    group_item_list.set_custom_minimum_size(Vector2(100, 100))


# ___________________Callback Functions___________________

func on_group_checkbox_click():
    ##
    ## Callback function for clicking the group checkbox button
    ##
    set_group_mode(!in_group_mode)
    

func on_select_group_item(index):
    ##
    ## Callback function for selecting an item in the group item list
    ##
    print("Selected: " + str(index))

    var selected_texture = scatter_group[index]
    scatter_tool.Preview.Texture = selected_texture
    scatter_tool.PromoteCustomColor()
    cur_texture = selected_texture
    

func remove_group_item(index, position):
    ##
    ## Callback function for right clicking an item in the group item list
    ##
    print("Removing: " + str(index))

    scatter_group.remove(index)
    group_item_list.remove_item(index)

    randomize_asset()


# ___________________Base Functions___________________

func init(caller):
    ##
    ## Initialize the Group Handler
    ##
    print("Initializing group_handler")

    # Assign Global reference
    _global = caller._global
    if not _global is Dictionary:
        _global = caller.Global
    
    print("Loaded global: " + str(_global))

    # Load any external scripts
    utils = load(_global.Root + "scripts/utils.gd").new()
    preset_handler = load(_global.Root + "scripts/preset_handler.gd").new()

    # Initialize any external scripts
    utils.init(self)
    preset_handler.init(self)

    # Cache the scatter tool
    scatter_tool = _global.Editor.Tools["ScatterTool"]

    print("Creating the group container")

    # Create the group container
    group_container = utils.create_vbox()

    print("Creating the group checkbox button")

    # Create and add the "Group" checkbox button
    group_checkbox = utils.create_checkbutton("Group")
    group_checkbox.connect("pressed", self, "on_group_checkbox_click")

    print("Adding UI nodes from the preset_handler")

    # Add preset dropdown and save box to the tool panel
    group_container.add_child(preset_handler.preset_dropdown.get_parent())
    group_container.add_child(preset_handler.name_input.get_parent())

    # Add connections to the preset dropdown and save button
    preset_handler.connect("changed_preset", self, "load_preset")
    preset_handler.save_button.connect("pressed", self, "save_preset")
    
    print("Creating the item list")

    # Add the group item list
    group_item_list = utils.create_item_list()
    group_item_list.set_allow_rmb_select(true)
    group_container.add_child(group_item_list)

    # Add connections to the group item list
    group_item_list.connect("item_selected", self, "on_select_group_item")
    group_item_list.connect("item_rmb_selected", self, "remove_group_item")

    print("Creating the clear hbox")

    # Create the add and clear hbox
    var hbox_b = utils.create_hbox()
    group_container.add_child(hbox_b)

    # Create and add the "Clear Group" button
    var clear_button = utils.create_button("Clear", _global.Root + "icons/trash.png")
    clear_button.set_tooltip("Clear Group")
    clear_button.set_h_size_flags(3)
    hbox_b.add_child(clear_button)

    # Add connections to the "Clear" button
    clear_button.connect("pressed", self, "clear_group")

    # Create and add the "Add" button
    var add_button = utils.create_button("Add", _global.Root + "icons/add.png")
    add_button.set_h_size_flags(3)
    add_button.set_tooltip("Add to Group")
    hbox_b.add_child(add_button)

    # Add connections to the "Add" button
    add_button.connect("pressed", self, "add_to_group")
    
    # Create the speed label
    var speed_label = utils.create_label(null, "Speed")
    group_container.add_child(speed_label)

    print("Creating the speed slider")

    # Create the speed slider
    speed_slider = utils.create_slider(null, 10.0, 0.0, 10.0, 1.0)
    group_container.add_child(speed_slider.get_parent())

    # Set the group mode to false and hide the group ui section
    set_group_mode(false)

    print("Finished initializing group_handler")


func tick(delta):
    ##
    ## Called once per tick
    ##
    var cur_focus = _global.Editor.Toolset.get_focus_owner()
    
    if scatter_tool == _global.Editor.ActiveTool:
        if Input.is_mouse_button_pressed(BUTTON_LEFT) and not cur_focus:
            if in_group_mode:
                randomize_asset(delta)
    
    preset_handler.tick(delta)

func start():
    pass