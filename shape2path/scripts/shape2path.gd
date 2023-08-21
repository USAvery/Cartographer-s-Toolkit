## Uses Dungeondraft v1.1.0.0
##
## Path Plus v1.0.0
## Author: Avery Berg
## 
## Adds additional functionality to the select tool
## Allows the user to match pattern shapes' shapes to path shapes
##

# Required Global
var script_class = "tool"

# Globals
var select_tool = null
var shape2path_button = null
var allow_open_paths = true


func get_selected_items():
    ##
    ## Get the selected items
    ##
    var select_tool = Global.Editor.Tools["SelectTool"]
    var selected_items = select_tool.Selected
    
    return selected_items


func get_patterns():
    ##
    ## Get all the pattern shapes
    ##
    var cur_level = Global.World.levels[Global.World.CurrentLevelId]
    var patterns = []

    # Iterate through the layers
    for layer in cur_level.PatternShapes.get_children():
        
        # Iterate through the pattern shapes
        for pattern_shape in layer.get_children():
            patterns.append(pattern_shape)
    
    return patterns


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


func get_selected_pattern_shape():
    ##
    ## Get the selected pattern shape
    ##
    var pattern_shapes = get_patterns()

    for item in get_selected_items():
        if item in pattern_shapes:
            return item
    
    return null


func shape2path():
    ##
    ## Make the selected pattern shape's shape match
    ## the shape of the selected path
    ##
    var shape = get_selected_pattern_shape()
    var path = get_selected_path()

    if not shape or not path:
        print("Unable to run shape2path. Must select a Path and PatternShape")
        return
    
    # Make the pattern shape fill the path
    shape.set_polygon(path.points)
    
    # Copy the path's transforms to the shape
    shape.set_global_position(path.get_global_position())
    shape.set_global_rotation(path.get_global_rotation())
    shape.set_global_scale(path.get_global_scale())


func can_use_tool():
    ##
    ## Determine whether the tool is usable for the current selection
    ##
    var path = get_selected_path()
    if not path:
        return false
    
    if not path.loop and not allow_open_paths:
        return false
    
    var shape = get_selected_pattern_shape()
    if not shape:
        return false
    
    return true


func update(delta):
    ##
    ## Called every tick
    ##
    if select_tool == Global.Editor.ActiveTool:
        shape2path_button.visible = can_use_tool()


func start():
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##
    select_tool = Global.Editor.Tools["SelectTool"]
    var tool_panel = Global.Editor.Toolset.GetToolPanel("SelectTool")

    # Create and add the shape2path button
    shape2path_button = tool_panel.CreateButton("shape 2 path", Global.Root + "icons/ditto.png")
    shape2path_button.connect("pressed", self, "shape2path")




func dir_string(obj, filter=null):
    # Get the methods and member variables of an object
    # Return as a string
    var str_result = ""
    var methods = []
    var properties = []

    # Get the methods
    for method in obj.get_method_list():
        if filter == null or filter.to_lower() in method.name.to_lower():
            methods.append(method.name)

    # Get the member variables
    for prop in obj.get_property_list():
        # if prop.type == 3:
        if filter == null or filter.to_lower() in prop.name.to_lower():
            properties.append(prop.name)

    methods.sort()
    properties.sort()

    str_result += "Properties:\n"
    for prop in properties:
        str_result += "   " + prop + "\n"

    str_result += "Methods:\n"
    for method in methods:
        str_result += "   " + method + "\n"

    return str_result