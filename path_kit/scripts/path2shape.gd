## Uses Dungeondraft v1.1.0.0
##
## PathKit v0.2.0
## Author: Avery Berg
## 
## Allows the user to snap a path to a shape
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
var focused_shape = null

var cached_shape_data = null
var cached_path_data = null


# ___________________Query Objects in Scene Functions___________________

func get_selected_items():
    ##
    ## Get the selected items
    ##    
    # print('get_selected_items')
    return select_tool.Selected


func get_patterns():
    ##
    ## Get all the pattern shapes
    ##
    # print('get_patterns')
    var cur_level = _global.World.levels[_global.World.CurrentLevelId]
    var patterns = []

    # Iterate through the layers
    for layer in cur_level.PatternShapes.get_children():
        
        # Iterate through the pattern shapes
        for pattern_shape in layer.get_children():
            patterns.append(pattern_shape)
    
    # print('patterns: ' + str(patterns))
    return patterns


func get_paths():
    ##
    ## Get all the path nodes
    ##
    # print('get_paths')
    var cur_level = _global.World.levels[_global.World.CurrentLevelId]
    return cur_level.Pathways.get_children()


func get_selected_path():
    ##
    ## Get the selected path
    ##
    # print('get_selected_path')
    var paths = get_paths()

    for item in get_selected_items():
        if item in paths:
            return item
    
    return null


func get_selected_pattern_shape():
    ##
    ## Get the selected pattern shape
    ##
    # print('get_selected_pattern_shape')
    var pattern_shapes = get_patterns()

    for item in get_selected_items():
        if item in pattern_shapes:
            return item
    
    return null


# ___________________Path Transformation Functions___________________

func path2shape():
    if not focused_path or not focused_shape:
        return
    
    focused_path.loop = true
    focused_path.SetEditPoints(focused_shape.get_polygon())
    focused_path.Smoothness = 0.0
    focused_path.Smooth()
    focused_path.Save()

    # Refresh the select tool's highlights
    select_tool.DehighlightSelected()


# ___________________Callback functions___________________

func apply():
    ##
    ## Exit the path2shape section and leave the path2shape transform applied
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


func reset_focused_shape():
    if focused_shape and cached_shape_data:
        print("Resetting focused shape")
        
        select_tool.DeselectAll()
        select_tool.ClearTransformSelection()

        # Delete the instance of the focused shape
        var new_node_id = _global.World.nextNodeID
        _global.World.SetNodeID(focused_shape, new_node_id)
        _global.World.DeleteNodeByID(new_node_id)
        _global.World.nextNodeID += 1
        
        # Load the cached shape data as a new shape
        var cur_level = _global.World.levels[_global.World.CurrentLevelId]
        cur_level.PatternShapes.LoadShape(cached_shape_data)

        # Refresh the select tool's highlights
        select_tool.DehighlightSelected()


func cancel():
    ##
    ## Exit the path2shape menu and reset the previously selected path
    ##
    reset_focused_path()
    reset_focused_shape()
    close_section()


func close_section():
    if is_open:
        print("path2shape: close_section")
    
    focused_path = null
    cached_path_data = null
    focused_shape = null
    cached_shape_data = null
    is_open = false
    section.set_visible(is_open)


func open_section():
    ##
    ## Callback function for clicking the path2shape button
    ##
    print('path2shape: open_section')
    if is_open:
        return
    
    print('selected_path: ' + str(get_selected_path()))
    print('selected_shape: ' + str(get_selected_pattern_shape()))
    if not can_use_tool():
        print('Cannot use tool')
        return
    
    # Set the focused path and cache the path data
    var selected_path = get_selected_path()
    focused_path = selected_path
    cached_path_data = selected_path.Save(true)

    # Set the focused pattern shape and cache its data
    var selected_shape = get_selected_pattern_shape()
    focused_shape = selected_shape
    cached_shape_data = focused_shape.Save(true)

    
    path2shape()

    is_open = true


func can_use_tool():
    var selected_path = get_selected_path()
    var selected_shape = get_selected_pattern_shape()
    return bool(selected_path and selected_shape)


# ___________________Base Functions___________________

func tick(delta):
    ##
    ## Called once per tick
    ##
    if select_tool != _global.Editor.ActiveTool:
        cancel()
        return
    
    # If no path or pattern shape is selected, cancel the operation
    var selected_path = get_selected_path()
    var selected_shape = get_selected_pattern_shape()
    if not selected_path or not selected_shape:
        cancel()
        return
    
    # If the selected path has changed
    if focused_path and selected_path != focused_path:
        cancel()
    
    # If the selected pattern shape has changed
    if focused_shape and selected_shape != focused_shape:
        cancel()
    
    # Set the visibility of the simplify menu
    section.set_visible(is_open)


func init_ui():
    # Create the path2shape button
    open_button = utils.create_button("Path2Shape", _global.Root + "icons/ditto.png")

    # Create the path2shape submenu
    section = utils.create_vbox()

    # Create and add the "Apply" and "Cancel" buttons hbox
    var action_hbox = utils.create_action_hbox(self, 'apply', 'cancel')
    section.add_child(action_hbox)


func init(caller):
    ##
    ## Initialize
    ##
    print("Initializing path2shape.gd")

    # Assign Global reference
    _global = caller._global
    if not _global is Dictionary:
        _global = caller.Global

    print("Loading utils for path2shape.gd")

    # Load any external scripts
    utils = load(_global.Root + "scripts/utils.gd").new()
    
    # Load the tool
    select_tool = _global.Editor.Tools["SelectTool"]

    print("Finished initializing path2shape.gd")


func start():
    pass