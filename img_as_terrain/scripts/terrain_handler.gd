## Uses Dungeondraft v1.1.0.0
##
## Terrain Handler
## Author: Avery Berg
##
##

# Required Global
var script_class = "tool"
var _global = null

# External Scripts
var utils = null

# Globals
var terrain_brush = null
var tool_panel = null
var file_input = null
var stretch_button = null

var terrain_id = null

var was_open = false

var terrain_loaded = false
var time_elapsed = 0.0


# ___________________Required Functions___________________

func start():
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##
    print('Loaded terrain handler')
    pass


# ___________________Misc Functions___________________

func get_current_level():
    ##
    ## Get the current level
    ##
    return _global.World.GetLevelByID(_global.World.CurrentLevelId)


func get_selected_terrain_img():
    var level = get_current_level()
    return level.Terrain.get_Textures()[terrain_id]


func set_terrain_img(texture):
    ##
    ## Set the terrain image
    ##
    var level = get_current_level()
    var param_name = 'texture_' + str(terrain_id + 1)
    # level.Terrain.normalShader.set_shader_param(param_name, texture)
    # level.Terrain.smoothShader.set_shader_param(param_name, texture)
    level.Terrain.ShaderMaterial.set_shader_param(param_name, texture)
    terrain_brush.SetTextureFromWindow(texture, terrain_id)


func set_stretched(stretched):
    ##
    ## Set whether the terrain image stretches to fit the canvas
    ##
    print('Set stretched: ' + str(stretched))
    var level = get_current_level()
    var param_name = 'texture_' + str(terrain_id + 1) + '_stretch'
    # level.Terrain.normalShader.set_shader_param(param_name, stretched)
    # level.Terrain.smoothShader.set_shader_param(param_name, stretched)
    level.Terrain.ShaderMaterial.set_shader_param(param_name, stretched)


func get_terrain_data():
    # print('Getting terrain data')
    return _global.ModMapData.get('img_as_terrain', {}).get(str(terrain_id), {})


func _load_terrain():
    var texture_path = get_terrain_data().get('texture_path', '')
    var stretched = get_terrain_data().get('stretched', false)

    if texture_path:
        print('STARTED LOADING TERRAIN')
        _on_change_file(texture_path)
        print('FINISHED LOADING TERRAIN')

    set_stretched(stretched)


func _on_open():
    print('Opening terrain ' + str(terrain_id))
    file_input.set_text(get_terrain_data().get('texture_path', ''))
    stretch_button.pressed = get_terrain_data().get('stretched', false)


func _reset():
    # Reset the gui inputs
    file_input.set_text('')
    stretch_button.pressed = false

    # Reset the shader attributes
    set_terrain_img(get_selected_terrain_img())
    set_stretched(false)

    # Reset the mod map data
    _global.ModMapData['img_as_terrain'][str(terrain_id)]['texture_path'] = ''
    _global.ModMapData['img_as_terrain'][str(terrain_id)]['stretched'] = false


func _on_change_file(path) -> void:
    ##
    ## Callback function for the image file changing
    ##
    print('Changed file! ' + str(path))

    if not path:
        _reset()

    var texture = utils.load_tx(path)
    if not texture:
        return

    # Set flags to allow the texture to tile
    texture.set_flags(2)

    # Set the terrain image and update the mod map data
    set_terrain_img(texture)
    _global.ModMapData['img_as_terrain'][str(terrain_id)]['texture_path'] = path

func _on_change_stretch(stretched):
    print('Stretch changed to ' + str(stretched))
    set_stretched(stretched)
    _global.ModMapData['img_as_terrain'][str(terrain_id)]['stretched'] = stretched

# ___________________Base Functions___________________

func tick(delta) -> void:
    ##
    ## Called once per tick
    ##
    # Load the terrain if it's not yet loaded
    time_elapsed = time_elapsed + delta
    if not terrain_loaded and time_elapsed > 0.5:
        _load_terrain()
        terrain_loaded = true

    if terrain_brush != _global.Editor.ActiveTool:
        was_open = false
        return

    if terrain_brush.get_TerrainID() != terrain_id:
        was_open = false
        return

    # print('is open')
    if not was_open:
        _on_open()
        was_open = true
        return

    var terrain_data = get_terrain_data()

    var cur_path = file_input.get_text('texture_path', '')
    var prev_path = terrain_data.get('texture_path', '')
    var cur_stretched = stretch_button.pressed
    var prev_stretched = terrain_data.get('stretched', false)
    # var cur_smooth_state = terrain_brush.get_SmoothBlending()

    # Change the stretched attribute (User clicked the stretch button)
    if cur_stretched != prev_stretched:
        _on_change_stretch(cur_stretched)

    if not cur_path:
        # Reset the terrain (User cleared the file input)
        if prev_path:
            print('Resetting the terrain for id: ' + str(terrain_id))
            _reset()
        was_open = true
        return

    # Reset the terrain (User selected a different terrain material)
    if cur_path == prev_path and get_selected_terrain_img().resource_path:
        print('User selected a different terrain material')
        _reset()
        return

    # Change the terrain image (User chose a new external image using the file input)
    if cur_path != prev_path:
        _on_change_file(cur_path)

    was_open = true


func init(caller, index, file_node, stretch_node):
    ##
    ## Initialize
    ##
    print('Initializing terrain_handler.gd')

    # Assign Global reference
    _global = caller._global
    if not _global is Dictionary:
        _global = caller.Global

    terrain_id = index
    file_input = file_node
    stretch_button = stretch_node

    print('Loading utils for terrain_handler.gd')

    # Load any external scripts
    utils = load(_global.Root + 'scripts/utils.gd').new()

    # Load the tool
    terrain_brush = _global.Editor.Tools["TerrainBrush"]
    tool_panel = _global.Editor.Toolset.GetToolPanel("TerrainBrush")

    # Initialize the mod map data
    _global.ModMapData['img_as_terrain'] = _global.ModMapData.get('img_as_terrain', {})
    _global.ModMapData['img_as_terrain'][str(terrain_id)] = _global.ModMapData['img_as_terrain'].get(str(terrain_id), {})

    # Load the terrain
    # print('Loading terrain: ' + str(terrain_id))
    # _load_terrain()

    print('Finished initializing terrain_handler.gd')
