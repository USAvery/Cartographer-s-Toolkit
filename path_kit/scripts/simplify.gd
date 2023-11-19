## Uses Dungeondraft v1.1.0.0
##
## PathKit v0.2.0
## Author: Avery Berg
## 
## Allows the user to simplify the amount of points in a path
##

# Required Global
var script_class = "tool"
var _global = null

# External Scripts
var utils = null

# Globals
var select_tool = null
var open_button = null
var section = null

var is_open = false

var focused_path = null
var cached_path_data = null


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


# ___________________Query/Edit Path Functions___________________

func simplify_focused_path():
    ##
    ## Simplify the focused path
    ##
    if not focused_path:
        return

    var edit_points = focused_path.get_GlobalEditPoints()
    var threshold = 20000.0
    var new_points = []
    
    for edit_point in edit_points:
        if not new_points:
            new_points.append(edit_point)
            continue
        
        if edit_point.distance_squared_to(new_points[-1]) > threshold:
            new_points.append(edit_point)
    
    if not focused_path.loop and new_points[-1] != edit_points[-1]:
        new_points.append(edit_points[-1])
    
    focused_path.SetEditPoints(new_points)
    focused_path.Save()

    # Refresh the select tool's highlights
    select_tool.DehighlightSelected()


# ___________________Callback Functions___________________

func apply():
    ##
    ## Exit the simplify and leave the simplification applied
    ##
    print("Apply")
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
    ## Exit the simplify menu and reset the previously selected path
    ##
    # print("Cancel simplify")
    reset_focused_path()
    close_section()


func close_section():
    if is_open:
        print("close_section")
    
    focused_path = null
    cached_path_data = null
    is_open = false
    section.set_visible(is_open)


func open_section():
    ##
    ## Callback function for clicking the simplify button
    ##
    print('simplify: open_section')
    if is_open:
        return
    
    var selected_path = get_selected_path()
    if not selected_path:
        return
    
    focused_path = selected_path
    cached_path_data = selected_path.Save(true)

    simplify_focused_path()
    
    is_open = true


func can_use_tool():
    var selected_path = get_selected_path()
    return bool(selected_path)


# ___________________Base Functions___________________

func tick(delta):
    ##
    ## Called once per tick
    ##
    if select_tool != _global.Editor.ActiveTool:
        cancel()
        return
    
    # If no path is selected, cancel the operation
    var selected_path = get_selected_path()
    if not selected_path:
        cancel()
        return
    
    # If the selected path has changed
    if focused_path and selected_path != focused_path:
        change_focused_path()
    
    # Set the visibility of the simplify menu
    section.set_visible(is_open)
    

func init_ui():
    # Create the simplify button
    open_button = utils.create_button("Simplify", _global.Root + "icons/simplify.png")

    # Create the simplify submenu
    section = utils.create_vbox()

    # Create and add the "Apply" and "Cancel" buttons hbox
    var action_hbox = utils.create_action_hbox(self, 'apply', 'cancel')
    section.add_child(action_hbox)


func init(caller):
    ##
    ## Initialize
    ##
    print("Initializing simplify.gd")

    # Assign Global reference
    _global = caller._global
    if not _global is Dictionary:
        _global = caller.Global

    print("Loading utils simplify.gd")

    # Load any external scripts
    utils = load(_global.Root + "scripts/utils.gd").new()
    
    # Load the select tool
    select_tool = _global.Editor.Tools["SelectTool"]

    print("Finished initializing simplify.gd")


func start():
    pass
