## Uses Dungeondraft v1.1.0.0
##
## Path2Water v1.0.0
## Author: Avery Berg
## 
## Allows the user to snap selected paths to waterlines
##

# Required Global
var script_class = "tool"

# External Scripts
var utils = null

# Globals
var select_tool = null
var path2water_button = null
var dropdown_menu = null
var grow_slider = null
var simplify_button = null
var grow_label = null
var grow_button = null

var flip_button = null

var prev_size = 0


func get_selected_items():
    ##
    ## Get the selected items
    ##
    var select_tool = Global.Editor.Tools["SelectTool"]
    var selected_items = select_tool.Selected
    
    return selected_items


func get_paths():
    ##
    ## Get all the path nodes
    ##
    var cur_level = Global.World.levels[Global.World.CurrentLevelId]
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


func get_water_lines():
    ##
    ## Get the water lines
    ##
    var cur_level = Global.World.levels[Global.World.CurrentLevelId]
    var water_mesh = cur_level.WaterMesh
    return water_mesh.Lines


func path2waterline(path, surface_index):
    ##
    ## Align a path with a water line
    ##
    var water_lines = get_water_lines()

    if surface_index >= water_lines.size():
        return
    
    var water_line = water_lines[surface_index]

    path.loop = true
    path.SetEditPoints(water_line.get_points())

    path.Save()


func on_clicked_path2water_button():
    ##
    ## Callback function for clicking the path2water button
    ##
    var index = dropdown_menu.get_selected_id()
    var path = get_selected_path()
    if not path:
        return
    
    path2waterline(path, index)


func get_normal(pos_a, pos_b):
    var direction = (pos_b - pos_a).normalized()
    var normal = Vector2(-direction.y, direction.x)
    return normal


func get_path_point_positions(path):
    var positions = []
    for i in range(path.get_point_count()):
        positions.append(path.get_point_position(i))
    
    return positions


func set_path_point_positions(path, positions):
    for i in range(path.get_point_count()):
        if i < positions.size():
            path.set_point_position(i, positions[i])

    return positions


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
    path.Save()


func simplify_selected_path():
    var path = get_selected_path()
    if not path:
        return

    var edit_points = path.get_GlobalEditPoints()
    var threshold = 20000.0
    var new_points = []
    
    for edit_point in edit_points:
        if not new_points:
            new_points.append(edit_point)
            continue
        
        if edit_point.distance_squared_to(new_points[-1]) > threshold:
            new_points.append(edit_point)
    
    if not path.loop and new_points[-1] != edit_points[-1]:
        new_points.append(edit_points[-1])
    
    path.SetEditPoints(new_points)
    path.Save()
    

func on_click_grow():
    var path = get_selected_path()
    if not path:
        return
    
    print("Growing Path along normals")
    var grow_value = grow_slider.value * -10.0
    move_path_along_normals(path, grow_value)


func on_change_grow(value):
    ##
    ## Callback function for changing the grow value
    ##
    grow_label.set_text("Grow Amount: " + str(value))


func on_clicked_flip_button():
    ##
    ## Callback function for clicking the flip button
    ##
    var path = get_selected_path()
    if not path:
        return
    # var points = path.get_points()
    # points.invert()
    # path.SetEditPoints(points)
    # path.Save()


func on_select_preset_target(index):
    print("selected target")


func can_use_tool():
    ##
    ## Determine whether the tool is usable for the current selection
    ##
    if get_selected_items().size() != 1:
        # print("Nothing selected")
        return false
    
    var path = get_selected_path()
    if not path:
        # print("No path selected")
        return false

    # print("Can use tool")
    return true


func update(delta):
    ##
    ## Called once per tick
    ##

    if select_tool == Global.Editor.ActiveTool:
        var do_show = can_use_tool()
        path2water_button.visible = do_show
        dropdown_menu.get_parent().visible = do_show
        grow_slider.visible = do_show
        simplify_button.visible = do_show
        grow_label.visible = do_show
        grow_button.visible = do_show

        # Update the dropdown menu list
        var cur_size = get_water_lines().size()
        # print("Cur size: " + str(cur_size))
        if cur_size != prev_size:
            dropdown_menu.clear()
            for i in range(cur_size):
                dropdown_menu.add_item(i)

        prev_size = cur_size


func start():
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##

    # Load any external scripts
    utils = load(Global.Root + "scripts/utils.gd").new()

    select_tool = Global.Editor.Tools["SelectTool"]
    var tool_panel = Global.Editor.Toolset.GetToolPanel("SelectTool")

    var panel_length = tool_panel.get_children()[-1].get_children().size()

    # Create and add the path2water button
    path2water_button = tool_panel.CreateButton("path 2 water", Global.Root + "icons/ditto.png")
    path2water_button.connect("pressed", self, "on_clicked_path2water_button")
    tool_panel.Align.move_child(path2water_button, panel_length-4)

    dropdown_menu = tool_panel.CreateLabeledDropdownMenu("on_select_target", "Water Line", ["0"], "0")
    tool_panel.Align.move_child(tool_panel.get_children()[-1].get_children()[-1], panel_length-4)

    # Create the Simplify button
    simplify_button = tool_panel.CreateButton("Simplify", Global.Root + "icons/ditto.png")
    simplify_button.connect("pressed", self, "simplify_selected_path")
    tool_panel.Align.move_child(simplify_button, panel_length-2)

    grow_label = utils.create_label(tool_panel, "Grow Amount: 0.0")
    tool_panel.Align.move_child(grow_label, panel_length-1)

    # Create the grow slider
    grow_slider = utils.create_slider(tool_panel, 0.0, -5.0, 5.0, 0.1)
    grow_slider.connect("value_changed", self, "on_change_grow")
    tool_panel.Align.move_child(grow_slider, panel_length)

    # Create the grow button
    grow_button = tool_panel.CreateButton("Grow", Global.Root + "icons/ditto.png")
    grow_button.connect("pressed", self, "on_click_grow")
    tool_panel.Align.move_child(grow_button, panel_length+1)

    # Add a spacer to the select tool's panel
    var spacer = utils.create_spacer(tool_panel, Vector2(0, 40))
