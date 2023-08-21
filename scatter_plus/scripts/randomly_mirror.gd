## Uses Dungeondraft v1.1.0.0
##
## Scatter Plus v1.2.0
## Author: Avery Berg
## 
## Adds additional functionality to the scatter tool
##

# Required Global
var script_class = "tool"

# External Scripts
var utils = null

# Globals
var scatter_tool = null
var mirror_checkbox = null
var in_random_mirror_mode = false
var on_icon = null
var off_icon = null


func on_mirror_checkbox_click():
    ##
    ## Callback function for clicking the mirror checkbox button
    ##
    in_random_mirror_mode = !in_random_mirror_mode

    # Set the group_checkbox icon
    if in_random_mirror_mode:
        mirror_checkbox.icon = on_icon
    else:
        mirror_checkbox.icon = off_icon
        scatter_tool.Preview.Mirror = false


func start():
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##

    # Load any external scripts
    utils = load(Global.Root + "scripts/utils.gd").new()

    # Cache the scatter tool to make it easier to reference in this script
    scatter_tool = Global.Editor.Tools["ScatterTool"]

    var tool_panel = Global.Editor.Toolset.GetToolPanel("ScatterTool")
    on_icon = utils.load_tx(Global.Root + "icons/on.png")
    off_icon = utils.load_tx(Global.Root + "icons/off.png")

    var panel_length = tool_panel.get_children()[-1].get_children().size()

    # Create and add the "Randomly Mirror" checkbox button
    mirror_checkbox = tool_panel.CreateButton("Randomly Mirror", Global.Root + "icons/off.png")
    mirror_checkbox.connect("pressed", self, "on_mirror_checkbox_click")
    tool_panel.Align.move_child(mirror_checkbox, panel_length-11)



func update(delta):
    ##
    ## Called once per tick
    ##
    var cur_focus = Global.Editor.Toolset.get_focus_owner()
    
    if scatter_tool == Global.Editor.ActiveTool:
        if Input.is_mouse_button_pressed(BUTTON_LEFT) and not cur_focus:
            if in_random_mirror_mode:
                scatter_tool.Preview.Mirror = utils.random_bool()
