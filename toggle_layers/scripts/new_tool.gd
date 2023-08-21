## Uses Dungeondraft v1.1.0.0
##
## Toggle Layers v1.0.0
## Author: Avery Berg
## Uses functions from Layers Mod
## 
## TODO: Description
##

# Required Globals
var script_class = "tool"

# External Scripts
var utils = null
var class_a = null

# Globals
var layer_dropdown = null


# Dict of all standard layer names to whether the layer is user editable.
var layers = {
  -500: false,
  -400: true,
  -300: false,
  -200: false,
  -100: true,
  0: false,
  100: true,
  200: true,
  300:true,
  400: true,
  # 500 is portals. Not user editable, but assets are selectable.
  500: true,
  600: false,
  700: true,
  # 800 is roofs. Not user editable, but assets are selectable.
  800: true,
  900: true,
  # 9999 is lights. Not user editable, but assets are selectable.
  9999: true
}

var layer_names = {
  -500: "Terrain",
  -400: "Below Ground",
  -300: "Caves",
  -200: "Floor",
  -100: "Below Water",
  0: "Water",
  100: "User Layer 1",
  200: "User Layer 2",
  300: "User Layer 3",
  400: "User Layer 4",
  500: "Portals",
  600: "Walls",
  700: "Above Walls",
  800: "Roofs",
  900: "Above Roofs",
  9999: "Lights"
}


# The next set of helpers extracts the properties we need from selectable nodes. Patterns are treated
# differently from objects and paths.
func get_object_data(level):
    var objects = level.Objects.get_children()
  
    var object_data = []
    for object in objects:
      var data = get_standard_data(object)
      # TODO: class instead of dict
      if data.node_id:
        object_data.push_back(data)
  
    return object_data

func get_path_data(level):
    var paths = level.Pathways.get_children()

    var path_data = []
    for path in paths:
        var data = get_standard_data(path)
        # TODO: class instead of dict
        path_data.push_back(data)

    return path_data

# The standard data for objects and paths.
func get_standard_data(object):
    var z_index = String(object.z_index)
    var texture_path = String(object.Texture.resource_path)
    var node_id = String(get_meta_safe(object, "node_id"))
    var prefab_id = String(get_meta_safe(object, "prefab_id"))

    return { "z_index": z_index, "texture_path": texture_path, "node_id": node_id, "prefab_id": prefab_id }

# The data for patterns is stored slightly differently.
func get_pattern_data(level):
    var pattern_data = []
    for layer in level.PatternShapes.get_children():
        var z_index = String(layer.z_index)

        for pattern_shape in layer.get_children():
            var texture_path = String(pattern_shape.get__Texture().resource_path)
            var node_id = String( get_meta_safe(pattern_shape, "node_id"))
            var prefab_id = String(get_meta_safe(pattern_shape,"prefab_id"))

            pattern_data.push_back({ "z_index": z_index, "texture_path": texture_path, "node_id": node_id, "prefab_id": prefab_id })

    return pattern_data

# Roof data is also stored differently
func get_roof_data(level):
    var roof_data = []
    for roof in level.Roofs.get_children():
        # Roofs are hard-coded 800 z-index and cannot be changed.
        var z_index = "800"
        var node_id = String(get_meta_safe(roof, "node_id"))

        # Prefabs don't support roofs through the save file but we do this anyway just in case.
        # They are supported _until_ saving, so that's likely a prefab bug & will be fixed eventually.
        var prefab_id = String(get_meta_safe(roof, "prefab_id"))

        var tile_texture_path = roof.get_TilesTexture().resource_path

        # Tile texture has a bit a different format - it always ends in `tiles.png`. So we manually extract
        # the relevant path segment and just return that.
        var texture_path = tile_texture_path.split("/")[-2]

        roof_data.push_back({ "z_index": z_index, "texture_path": texture_path, "node_id": node_id, "prefab_id": prefab_id})

    return roof_data

# Light data is stored like roofs - hard-coded layer
func get_light_data(level):
    var light_data = []
    for light in level.Lights.get_children():
        var z_index = "9999"
        var node_id = String(get_meta_safe(light, "node_id"))

        # Lights aren't supported in prefabs
        var prefab_id = null
        var texture_path = light.get_texture().resource_path

        light_data.push_back({ "z_index": z_index, "texture_path": texture_path, "node_id": node_id, "prefab_id": prefab_id})

    return light_data

# Ditto with freestanding portals - hardcoded to layer 500
func get_portal_data(level):
    var portal_data = []
    for portal in level.Portals.get_children():
        var data = get_standard_data(portal)
        # All portals on layer 500
        data.z_index = "500"
        portal_data.push_back(data)

    return portal_data

func get_meta_safe(object, key, default = null):
    if object.has_meta(key):
        return object.get_meta(key)
    else:
        return default

func get_prop_data_list():
    var cur_level = Global.World.levels[Global.World.CurrentLevelId]
    var prop_data_list = []
    prop_data_list += get_object_data(cur_level)
    prop_data_list += get_path_data(cur_level)
    prop_data_list += get_pattern_data(cur_level)
    prop_data_list += get_roof_data(cur_level)
    prop_data_list += get_light_data(cur_level)
    prop_data_list += get_portal_data(cur_level)

    # Filter for props that have IDs
    var filtered_list = []
    for prop_data in prop_data_list:
        if not prop_data.node_id:
            continue
        filtered_list.append(prop_data)
    
    return filtered_list


func hide_layer(layer_name):
    ##
    ## Hide all props in a given layer
    ##
    for prop_data in get_prop_data_list():
        var prop_layer = layer_names.get(int(prop_data.z_index))
        if not prop_layer == layer_name:
            continue
        
        var node = Global.World.GetNodeByID(prop_data.node_id)
        node.visible = false


func show_layer(layer_name):
    ##
    ## Show all props in a given layer
    ##
    for prop_data in get_prop_data_list():
        var prop_layer = layer_names.get(int(prop_data.z_index))
        if not prop_layer == layer_name:
            continue
        
        var node = Global.World.GetNodeByID(prop_data.node_id)
        node.visible = true


func on_click_hide():
    var selected_layer = layer_dropdown.get_item_text(layer_dropdown.get_selected_id())
    if selected_layer != "All":
        hide_layer(selected_layer)
        return
    
    for i in layer_dropdown.get_item_count():
        if i == 1:
            continue
        var layer_name = layer_dropdown.get_item_text(i)
        hide_layer(layer_name)


func on_click_show():
    var selected_layer = layer_dropdown.get_item_text(layer_dropdown.get_selected_id())
    if selected_layer != "All":
        show_layer(selected_layer)
        return
    
    for i in layer_dropdown.get_item_count():
        if i == 1:
            continue
        var layer_name = layer_dropdown.get_item_text(i)
        show_layer(layer_name)


func toggle_background():
    print("Hiding Background")

    # Get the top viewport
    var viewport = Global.Editor.get_viewport()

    # Get the toggle state
    var alpha_state = !viewport.transparent_bg
    var visible_state = !alpha_state

    # Make the viewport transparent
    viewport.transparent_bg = alpha_state
    Global.Editor.get_tree().get_root().set_transparent_background(alpha_state)

    # Get the Master Node
    var master_node = viewport.get_children()[-1]

    # Get the Viewport2D Node
    var vp2d = master_node.ViewportContainer2D.get_children()[0]
    vp2d.transparent_bg = alpha_state
    

    # Get the main node
    var main_node = vp2d.get_children()[1]

    # Parse the main node's children
    var grid = main_node.get_children()[0]
    var bounds = main_node.get_children()[2]
    var level_ground = main_node.get_children()[4]

    bounds.visible = visible_state

    # Get the terrain
    var terrain = level_ground.get_children()[1]

    terrain.visible = visible_state

    # Get the water mesh
    var cur_level = Global.World.levels[Global.World.CurrentLevelId]
    var water_mesh = cur_level.WaterMesh
    
    water_mesh.visible = visible_state
    

# func _on_reload():
#     print(" ")
#     # var ctrl = Node2D.new()
#     var viewport = Global.Editor.get_viewport()

#     # Make the viewport transparent
#     viewport.transparent_bg = true
#     Global.Editor.get_tree().get_root().set_transparent_background(true)

#     var master_node = viewport.get_children()[-1]

#     # for child in master_node.get_children():
#     #     # if child.name == "Background":
#     #         # child.visible = false
#     #         # print(child.visible)
#     #     print(child)
#     var vp2d = master_node.ViewportContainer2D.get_children()[0]
#     vp2d.transparent_bg = true
#     # print(utils.dir_string(vp2d))
#     var main_node = vp2d.get_children()[1]
#     # print(main_node.get_children())
#     # for child in main_node.get_children():
#     #     print(child.visible)
#     var grid = main_node.get_children()[0]
#     var bounds = main_node.get_children()[2]
#     var level_ground = main_node.get_children()[4]

#     bounds.visible = false
#     level_ground.visible = true

#     # var tile_map = level_ground.FloorRT.get_children()[0]

#     # tile_map.visible = true

#     # level_ground.FloorRT.get_children()[1].visible = true

#     var terrain = level_ground.get_children()[1]

#     for child in level_ground.get_children():
#         print(child)

#     level_ground.get_children()[1].visible = false
#     # print()
#     # print()
#     # print()
#     # print(utils.dir_string(viewport))
#     # print(viewport)
#     # print(utils.dir_string(Global.World, "lay"))
#     # var cur_level = Global.World.levels[Global.World.CurrentLevelId]

#     # var prop_ids = []

#     # for prop_data in get_prop_data_list():
#     #     var node = Global.World.GetNodeByID(prop_data.node_id)
#     #     node.visible = false
    
#     # for prop_id in prop_ids:
#     #     var node = Global.World.GetNodeByID(prop_id)
#     #     print(node)
#     return


func update(delta):
    ##
    ## Called once per tick
    ##
    var cur_focus = Global.Editor.Toolset.get_focus_owner()

    # if Input.is_mouse_button_pressed(BUTTON_LEFT):
    #     print(cur_focus)
    #     utils.print_ancestors(cur_focus)
    #     print(" ")
    pass

func start():
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##

    # Load any external scripts
    print("Loading utils")
    utils = load(Global.Root + "scripts/utils.gd").new()

    # # Add reload callback
    # var reload_mods_button = Global.Editor.get_node("VPartition/MenuBar/MenuAlign/ReloadModsButton")
    # reload_mods_button.connect("pressed", self, "_on_reload")

    # Create the new tool
    var category = "Settings"
    var id = "toggle_layers"
    var name = "Toggle Layers"
    var icon = Global.Root + "icons/toggle_layers.png"

    var tool_panel = Global.Editor.Toolset.CreateModTool(self, category, id, name, icon)
    # tool_panel.UsesObjectLibrary = true
    tool_panel.CreateLabel("Toggle Layer Visibility")
    tool_panel.CreateLabel("Layers")

    var names = ["All"]
    for z_index in layer_names.keys():
        if layers[z_index]:
            names.append(layer_names[z_index])

    layer_dropdown = tool_panel.CreateDropdownMenu("Layers", names, names[0])

    var button1 = tool_panel.CreateButton("Hide", Global.Root + "icons/question.png")
    button1.connect("pressed", self, "on_click_hide")

    var button2 = tool_panel.CreateButton("Show", Global.Root + "icons/question.png")
    button2.connect("pressed", self, "on_click_show")

    var button3 = tool_panel.CreateButton("Toggle Background", Global.Root + "icons/question.png")
    button3.connect("pressed", self, "toggle_background")

    # var button2 = tool_panel.CreateButton("Randomize Asset", Global.Root + "icons/add.png")
    # button2.connect("pressed", self, "randomize_asset")

    