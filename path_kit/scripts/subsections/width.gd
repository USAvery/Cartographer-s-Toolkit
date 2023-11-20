## Uses Dungeondraft v1.1.0.0
##
## PathKit v0.2.0
## Author: Avery Berg
## 
## Allows the user to adjust the width of a selected path
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
var width_slider = null

var is_open = false

var focused_path = null
var cached_path_data = null


# ___________________Query Objects in Scene Functions___________________

func get_selected_items():
    ##
    ## Get the selected items
    ##    
    # print('get_selected_items')
    return select_tool.Selected


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


# ___________________Path Transformation Functions___________________

func transform_focused_path():
    if not focused_path:
        return
    
    focused_path.loop = true
    focused_path.SetWidthScale(width_slider.value)
    focused_path.Smooth()
    focused_path.Save()

    # Refresh the select tool's highlights
    select_tool.DehighlightSelected()


# ___________________Callback functions___________________

func on_change_width(slider_value):
    ##
    ## Callback function for changing the width value
    ##
    if not focused_path:
        return
    focused_path.Load(cached_path_data)
    focused_path.Smooth()
    transform_focused_path()


func apply():
    ##
    ## Exit the width section and leave the width transform applied
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


func cancel():
    ##
    ## Exit the width menu and reset the previously selected path
    ##
    reset_focused_path()
    close_section()


func close_section():
    if is_open:
        print("width: close_section")
    
    focused_path = null
    cached_path_data = null
    is_open = false
    section.set_visible(is_open)


func open_section():
    ##
    ## Callback function for clicking the width button
    ##
    print('width: open_section')
    if is_open:
        return
    
    print('selected_path: ' + str(get_selected_path()))
    if not can_use_tool():
        print('Cannot use tool')
        return
    
    # Set the focused path and cache the path data
    var selected_path = get_selected_path()
    focused_path = selected_path
    cached_path_data = selected_path.Save(true)
    

    var path_width_scale = float(focused_path.get_width()) / float(focused_path.get_texture().get_height())
    width_slider.set_value(path_width_scale)

    transform_focused_path(path_width_scale)

    is_open = true


func can_use_tool():
    var sel_path = get_selected_path()
    return sel_path != null


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
        cancel()
    
    # Set the visibility of the simplify menu
    section.set_visible(is_open)


func init_ui():
    print('width: initializing UI')
    # Create the width button
    open_button = utils.create_button("Width")

    # Create the width submenu
    section = utils.create_vbox()

    # Create the width slider
    width_slider = utils.create_slider(null, 1.0, 0.0, 1.0, 0.1)
    width_slider.connect("value_changed", self, "on_change_width")
    section.add_child(width_slider.get_parent())

    # Create and add the "Apply" and "Cancel" buttons hbox
    var action_hbox = utils.create_action_hbox(self, 'apply', 'cancel')
    section.add_child(action_hbox)

    print('width: finished initializing UI')


func init(caller):
    ##
    ## Initialize
    ##
    print("Initializing width.gd")

    # Assign Global reference
    _global = caller._global
    if not _global is Dictionary:
        _global = caller.Global

    print("Loading utils for width.gd")

    # Load any external scripts
    utils = load(_global.Root + "scripts/utils.gd").new()

    # Intitialize any external scripts
    utils.init(self)
    
    # Load the tool
    select_tool = _global.Editor.Tools["SelectTool"]

    print("Finished initializing width.gd")


func start():
    pass