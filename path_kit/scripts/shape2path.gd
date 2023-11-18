# ## Uses Dungeondraft v1.1.0.0
# ##
# ## PathKit v0.2.0
# ## Author: Avery Berg
# ## 
# ## Allows the user to snap a path to another path
# ##

# # Required Global
var script_class = "tool"
# var _global = null

# # External Scripts
# var utils = null

# # Globals
# var select_tool = null
# var open_button = null
# var section = null

# var is_open = false

# var focused_path = null
# var focused_shape = null

# var cached_shape_data = null
# var cached_path_data = null


# # ___________________Query Objects in Scene Functions___________________

# func get_selected_items():
#     ##
#     ## Get the selected items
#     ##    
#     return select_tool.Selected


# func get_patterns():
#     ##
#     ## Get all the pattern shapes
#     ##
#     var cur_level = Global.World.levels[Global.World.CurrentLevelId]
#     var patterns = []

#     # Iterate through the layers
#     for layer in cur_level.PatternShapes.get_children():
        
#         # Iterate through the pattern shapes
#         for pattern_shape in layer.get_children():
#             patterns.append(pattern_shape)
    
#     return patterns


# func get_paths():
#     ##
#     ## Get all the path nodes
#     ##
#     var cur_level = _global.World.levels[_global.World.CurrentLevelId]
#     return cur_level.Pathways.get_children()


# func get_selected_path():
#     ##
#     ## Get the selected path
#     ##
#     var paths = get_paths()

#     for item in get_selected_items():
#         if item in paths:
#             return item
    
#     return null


# func get_selected_pattern_shape():
#     ##
#     ## Get the selected pattern shape
#     ##
#     var pattern_shapes = get_patterns()

#     for item in get_selected_items():
#         if item in pattern_shapes:
#             return item
    
#     return null


# # ___________________Path Transformation Functions___________________

# func shape2path():
#     if not focused_path or not focused_shape:
#         return
    
#     print('Transforming focused shape')
    
#     # Make the pattern shape fill the path
#     focused_shape.set_polygon(focused_path.points)
    
#     # Copy the path's transforms to the shape
#     focused_shape.set_global_position(focused_path.get_global_position())
#     focused_shape.set_global_rotation(focused_path.get_global_rotation())
#     focused_shape.set_global_scale(focused_path.get_global_scale())

#     # Refresh the select tool's highlights
#     select_tool.DehighlightSelected()


# # ___________________Callback functions___________________

# func apply():
#     ##
#     ## Exit the path2path section and leave the path2path transform applied
#     ##
#     print("Apply")
#     close_section()


# func reset_focused_path():
#     if focused_path and cached_path_data:
#         print("Resetting focused path")

#         focused_path.Load(cached_path_data)
#         focused_path.Smooth()
#         focused_path.Save()

#         # Refresh the select tool's highlights
#         select_tool.DehighlightSelected()



# func reset_focused_shape():
#     if focused_shape and cached_shape_data:
#         print("Resetting focused shape")

#         # focused_shape.Load(cached_shape_data)
#         # focused_shape.Smooth()
#         # focused_shape.Save()

#         # Refresh the select tool's highlights
#         select_tool.DehighlightSelected()



# func change_focused_path():
#     print("Changing focused path")
#     # reset_focused_path()
#     # var selected_path = get_selected_path()
#     # focused_path = selected_path
#     # cached_path_data = selected_path.Save(true)
#     cancel()


# func cancel():
#     ##
#     ## Exit the path2path menu and reset the previously selected path
#     ##
#     reset_focused_path()
#     close_section()


# func close_section():
#     if is_open:
#         print("path2path: close_section")
    
#     focused_path = null
#     cached_path_data = null
#     is_open = false
#     section.set_visible(is_open)


# func open_section():
#     ##
#     ## Callback function for clicking the path2path button
#     ##
#     print('path2path: open_section')
#     if is_open:
#         return
    
#     var selected_paths = get_selected_paths()
#     if selected_paths.size() < 2:
#         return
    
#     var first_selected_path = selected_paths[0]
#     focused_path = first_selected_path
#     cached_path_data = first_selected_path.Save(true)

#     shape2path()

#     is_open = true


# # ___________________Base Functions___________________

# func tick(delta):
#     ##
#     ## Called once per tick
#     ##
#     if select_tool != _global.Editor.ActiveTool:
#         cancel()
#         return
    
#     # If no path is selected, cancel the operation
#     var selected_paths = get_selected_paths()
#     if selected_paths.size() < 2:
#         cancel()
#         return
    
#     # If the selected path has changed
#     if focused_path and selected_paths[0] != focused_path:
#         change_focused_path()
    
#     # Set the visibility of the simplify menu
#     section.set_visible(is_open)


# func init_ui():
#     # Create the path2path button
#     open_button = utils.create_button("Path2Path", _global.Root + "icons/ditto.png")

#     # Create the path2path submenu
#     section = utils.create_vbox()

#     # Create and add the "Apply" and "Cancel" buttons hbox
#     var action_hbox = utils.create_action_hbox(self, 'apply', 'cancel')
#     section.add_child(action_hbox)


# func init(caller):
#     ##
#     ## Initialize
#     ##
#     print("Initializing path2path.gd")

#     # Assign Global reference
#     _global = caller._global
#     if not _global is Dictionary:
#         _global = caller.Global

#     print("Loading utils for path2path.gd")

#     # Load any external scripts
#     utils = load(_global.Root + "scripts/utils.gd").new()
    
#     # Load the tool
#     select_tool = _global.Editor.Tools["SelectTool"]

#     print("Finished initializing path2path.gd")


func start():
    pass