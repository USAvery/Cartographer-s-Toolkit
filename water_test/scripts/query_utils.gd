
var script_class = 'tool'
var _global = null


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
    var cur_level = _global.World.levels[_global.World.CurrentLevelId]
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


func init(caller):
    # Assign Global reference
    _global = caller._global
    if not _global is Dictionary:
        _global = caller.Global

    