## Uses Dungeondraft v1.1.0.0
##
## PathKit v0.2.0
## Author: Avery Berg
## 
## Allows the user to snap a selected path to a waterline
##

# Required Globals
var script_class = "tool"
var _global = null


# External Scripts
var utils = null

# Globals
var select_tool = null
var open_button = null
var dropdown_menu = null
var section = null

var is_open = false

var prev_num_bodies_of_water = 0
var prev_selected_index = null

var focused_path = null

var cached_path_data = null

var water_lines = []


# ___________________Path2Water Preview Path Functions___________________

func update_path2water_preview():
    if not focused_path:
        return

    # Update which water line is being previewed (if the selected index has changed)
    var selected_index = dropdown_menu.get_selected_id()
    if selected_index == prev_selected_index:
        return

    print("update_path2water_preview")
    focused_path.loop = true
    focused_path.set_global_scale(Vector2(1.0, 1.0))
    focused_path.SetEditPoints(water_lines[selected_index].get_points())
    focused_path.Save()

    # Refresh the select tool's highlights
    select_tool.DehighlightSelected()

    prev_selected_index = selected_index


# ___________________Misc Functions___________________

func clone_node(original_node: Node) -> Node:
    print("clone_node")

    # Pack the original node into a PackedScene
    var packed_scene = PackedScene.new()
    packed_scene.pack(original_node)

    # Instance a new node from the packed scene
    var duplicate_node = packed_scene.instance()

    # Set the name and position of the duplicate node
    duplicate_node.name = original_node.name + "_clone"
    duplicate_node.position = original_node.position

    # Copy script variables
    duplicate_node.script = original_node.script

    return duplicate_node


# ___________________Query Objects in Scene Functions___________________

func get_selected_items():
    ##
    ## Get the selected items
    ##    
    return select_tool.Selected


func get_paths():
    ##
    ## Get all the path nodes
    ##
    var cur_level = _global.World.levels[_global.World.CurrentLevelId]
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


func get_water_mesh():
    ##
    ## Get the water mesh
    ##
    var cur_level = _global.World.GetLevelByID(_global.World.CurrentLevelId)
    return cur_level.WaterMesh


func get_num_bodies_of_water():
    var water_mesh = get_water_mesh()
    return water_mesh.arrayMesh.get_surface_count()


func refresh_water_lines():
    ##
    ## Refresh the cloned list of water lines
    ##
    print('Refreshing water lines')
    
    var water_mesh = get_water_mesh()

    # Determine whether the water borders are disabled
    var borders_disabled = water_mesh.disableBorder

    # Enable the border and update so that we can get the water lines
    if borders_disabled:
        water_mesh.DisableBorder(false)
        water_mesh.UpdateLines()
    
    # Get the actual water lines
    var actual_water_lines = water_mesh.Lines

    # Clear the cloned node list
    if water_lines.size():
        for line_clone in water_lines:
            line_clone.queue_free()
        water_lines = []
    
    # Clone the water lines
    for water_line in actual_water_lines:
        water_lines.append(clone_node(water_line))
    
    # Restore the visibility state of the borders
    if borders_disabled:
        water_mesh.DisableBorder(true)


# ___________________Query/Edit Path Functions___________________

func path2waterline(path, surface_index):
    ##
    ## Align a path with a water line
    ##
    if surface_index >= water_lines.size():
        return
    
    var water_line = water_lines[surface_index]

    path.loop = true
    path.SetEditPoints(water_line.get_points())
    path.Smooth()
    path.Save()

    # Refresh the select tool's highlights
    select_tool.DehighlightSelected()


# ___________________Callback Functions___________________

func apply():
    ##
    ## Exit the path2water menu and apply the path2water transformation
    ##
    print("Apply")
    if focused_path:
        var index = dropdown_menu.get_selected_id()
        path2waterline(focused_path, index)
    close_section()


func reset_focused_path():
    if focused_path and cached_path_data:
        print("Resetting focused path")
        
        focused_path.Load(cached_path_data)
        focused_path.Smooth()
        focused_path.Save()

        # Refresh the select tool's highlights
        select_tool.DehighlightSelected()


func change_focused_path():
    print("Changing focused path")
    # reset_focused_path()
    # var selected_path = get_selected_path()
    # focused_path = selected_path
    # cached_path_data = selected_path.Save(true)
    cancel()


func cancel():
    ##
    ## Exit the path2water menu and reset the previously selected path
    ##
    # print("Cancel path2water")
    reset_focused_path()
    close_section()


func close_section():
    if is_open:
        print("close_section")
    
    focused_path = null
    cached_path_data = null
    prev_selected_index = null
    is_open = false
    section.set_visible(is_open)


func open_section():
    ##
    ## Callback function for clicking the path2water button
    ##
    if is_open:
        return
    
    # If no water, don't open
    if not get_num_bodies_of_water():
        return
    
    var selected_path = get_selected_path()
    if not selected_path:
        return
    
    focused_path = selected_path
    cached_path_data = selected_path.Save(true)
    
    is_open = true


# ___________________Base Functions___________________

func tick(delta):
    ##
    ## Called once per tick
    ##
    if select_tool != _global.Editor.ActiveTool:
        cancel()
        prev_num_bodies_of_water = 0
        return
    
    # If no path is selected, cancel the operation
    var selected_path = get_selected_path()
    if not selected_path:
        cancel()
        return
    
    # If the selected path has changed
    if focused_path and selected_path != focused_path:
        change_focused_path()
    
    # Update the dropdown menu list (if the number of water meshes has changed)
    var cur_num_water = get_num_bodies_of_water()
    if cur_num_water != prev_num_bodies_of_water:
        refresh_water_lines()
        dropdown_menu.clear()
        for i in range(water_lines.size()):
            dropdown_menu.add_item(i)
    
    if is_open:
        update_path2water_preview()
    
    # Set the visibility of the path2water menu
    section.set_visible(is_open)
    
    prev_num_bodies_of_water = cur_num_water


func init_ui():
    # Create the path2water button
    open_button = utils.create_button("Path 2 Water", _global.Root + "icons/path2water.png")

    # Create the path2water submenu
    section = utils.create_vbox()

    # Create and add the "Water Lines" dropdown menu
    dropdown_menu = utils.create_labeled_dropdown("Water Line", ["0"], "0")
    section.add_child(dropdown_menu.get_parent())

    # Create and add the "Apply" and "Cancel" buttons hbox
    var action_hbox = utils.create_action_hbox(self, 'apply', 'cancel')
    section.add_child(action_hbox)


func init(caller):
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##
    print("Initializing path2water.gd")

    # Assign Global reference
    _global = caller._global
    if not _global is Dictionary:
        _global = caller.Global
    
    print("Loaded global: " + str(_global))

    # Load any external scripts
    utils = load(_global.Root + "scripts/utils.gd").new()

    # Load the select tool
    select_tool = _global.Editor.Tools["SelectTool"]

    print("Finished initializing path2water.gd")


func start():
    pass
