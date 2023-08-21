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
var follow_checkbox = null
var in_follow_mode = false
var prev_mouse_pos = null
var on_icon = null
var off_icon = null


func on_follow_checkbox_click():
    ##
    ## Callback function for clicking the follow stroke checkbox button
    ##
    in_follow_mode = !in_follow_mode

    # Set the follow checkbox icon
    if in_follow_mode:
        follow_checkbox.icon = on_icon
    else:
        follow_checkbox.icon = off_icon

    if not in_follow_mode and scatter_tool.Preview:
        scatter_tool.Preview.set_rotation(0)


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

    # Create and add the "Follow Stroke" checkbox button
    follow_checkbox = tool_panel.CreateButton("Follow Stroke", Global.Root + "icons/off.png")
    follow_checkbox.connect("pressed", self, "on_follow_checkbox_click")
    tool_panel.Align.move_child(follow_checkbox, panel_length-12)


func update(delta):
    ##
    ## Called once per tick
    ##
    if scatter_tool != Global.Editor.ActiveTool or not in_follow_mode:
        return

    var mouse_pos = Global.World.get_global_mouse_position()

    if prev_mouse_pos != null and prev_mouse_pos != mouse_pos:
        var rad_angle = prev_mouse_pos.angle_to_point(mouse_pos)
        
        # Rotate additionally by 90 degrees
        rad_angle += 1.5707963

        # Normalize the angle
        rad_angle = fmod(rad_angle, 6.2831853)
        if rad_angle < 0:
            rad_angle += 6.2831853

        if scatter_tool.Preview:
            scatter_tool.Preview.set_rotation(rad_angle)
    
    prev_mouse_pos = mouse_pos
