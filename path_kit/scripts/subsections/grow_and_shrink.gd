## Uses Dungeondraft v1.1.0.0
##
## PathKit v0.2.0
## Author: Avery Berg
## 
## Allows the user to grow and shrink paths along their normals
##

# Required Global
var script_class = "tool"
var _global = null

# External Scripts
var utils = null

# Globals
var select_tool = null
var grow_slider = null
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

func get_normal(pos_a, pos_b):
    var direction = (pos_b - pos_a).normalized()
    var normal = Vector2(-direction.y, direction.x)
    return normal


func get_path_normals(path):
    var edit_points = path.get_GlobalEditPoints()

    if edit_points.size() <= 1:
        return [Vector2(0, 0)]

    # Get the best normal for each point
    var normals = []
    for i in range(edit_points.size()):
        var edit_point = edit_points[i]
        var normal = null

        # Get the best normal for the point
        if i > 0:
            if i < edit_points.size()-1:
                normal = get_normal(edit_points[i-1], edit_points[i+1])
            else:
                normal = get_normal(edit_points[i-1], edit_point)
        else:
            normal = get_normal(edit_point, edit_points[i+1])
        normals.append(normal)
    
    return normals


func move_path_along_normals(path, distance):
    var edit_points = path.get_GlobalEditPoints()
    var normals = get_path_normals(path)

    if edit_points.size() != normals.size():
        print("Error: point list and normal list are not the same size")
        return
    
    var new_points = []
    for i in range(edit_points.size()):
        var edit_point = edit_points[i]
        var normal = normals[i]

        var displacement = normal * distance
        var new_point = edit_point + displacement

        new_points.append(new_point)
    
    
    path.SetEditPoints(new_points)
    path.Smooth()
    path.Save()

    # Refresh the select tool's highlights
    select_tool.DehighlightSelected()


# ___________________Callback Functions___________________

func grow_focused_path():
    ##
    ## Grow the focused path
    ##
    if not focused_path:
        return
    
    print("Growing focused path along normals")
    var grow_value = grow_slider.value * -10.0
    move_path_along_normals(focused_path, grow_value)


func on_change_grow(value):
    ##
    ## Callback function for changing the grow value
    ##
    focused_path.Load(cached_path_data)
    focused_path.Smooth()
    grow_focused_path()


func apply():
    ##
    ## Exit the grow and leave the grow/shrink applied
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
    ## Exit the grow menu and reset the previously selected path
    ##
    reset_focused_path()
    close_section()


func close_section():
    if is_open:
        print("grow_and_shrink: close_section")
    
    focused_path = null
    cached_path_data = null
    is_open = false
    section.set_visible(is_open)


func open_section():
    ##
    ## Callback function for clicking the grow button
    ##
    print('grow_and_shrink: open_section')
    if is_open:
        return
    
    var selected_path = get_selected_path()
    if not selected_path:
        return
    
    focused_path = selected_path
    cached_path_data = selected_path.Save(true)

    grow_focused_path()
    
    is_open = true


func can_use_tool():
    var selected_path = get_selected_path()
    if selected_path:
        return true
    return false


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
    # Create the grow button
    open_button = utils.create_button("Grow / Shrink", _global.Root + "icons/grow_and_shrink.png")

    # Create the grow submenu
    section = utils.create_vbox()

    # Create the grow slider
    grow_slider = utils.create_slider(null, 0.0, -5.0, 5.0, 0.1)
    grow_slider.connect("value_changed", self, "on_change_grow")
    section.add_child(grow_slider.get_parent())

    # Create and add the "Apply" and "Cancel" buttons hbox
    var action_hbox = utils.create_action_hbox(self, 'apply', 'cancel')
    section.add_child(action_hbox)


func init(caller):
    ##
    ## Initialize
    ##
    print("Initializing grow_and_shrink.gd")

    # Assign Global reference
    _global = caller._global
    if not _global is Dictionary:
        _global = caller.Global

    print("Loading utils for grow_and_shrink.gd")

    # Load any external scripts
    utils = load(_global.Root + "scripts/utils.gd").new()

    # Intitialize any external scripts
    utils.init(self)
    
    # Load the tool
    select_tool = _global.Editor.Tools["SelectTool"]

    print("Finished initializing grow_and_shrink.gd")


func start():
    pass