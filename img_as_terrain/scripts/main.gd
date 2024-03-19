## Uses Dungeondraft v1.1.0.0
##
## Image as Terrain v1.0.0
## Author: Avery Berg
## 
## Import an image as the base layer of terrain. 
## Opens up a 'Terrain Baking' workflow when combined with the 'Toggle Layers' mod.
##

# Required Global
var script_class = "tool"

# External Scripts
var utils = null
var terrain_handlers = []

# Globals
var terrain_brush = null
var file_input = null
var stretch_button = null

var terrain_shaders = {
    'image': null,
    'image_smooth': null,
    'image_alpha': null,
    'image_alpha_smooth': null
}

# var terrain_item_list = null

var image_terrain_shader = null
var image_terrain_smooth_shader = null

var prev_terrain_01 = null
var prev_path = null
var prev_smooth_state = false


func load_shader(path):
    ##
    ## Load a shader from a path
    ##

    # Open the file for reading
    var file = File.new()
    if file.open(path, File.READ) != OK:
        print("Failed to open the file: " + path)
        return
    
    var shader_code = file.get_as_text()

    # Close the file
    file.close()

    var shader = Shader.new()
    shader.set_code(shader_code)

    return shader


func get_current_level():
    ##
    ## Get the current level
    ##
    return Global.World.GetLevelByID(Global.World.CurrentLevelId)


# ___________________Shader Functions___________________

func set_terrain_shader(shader):
    ##
    ## Set the terrain shader
    ##
    var level = get_current_level()
    level.Terrain.ShaderMaterial.set_shader(shader)

    # level.Terrain.normalShader
    # level.Terrain.smoothShader


func reload_default_terrain_shader():
    print('Reloading default terrain shader')
    var is_smooth = terrain_brush.get_SmoothBlending()
    if is_smooth:
        set_terrain_shader(terrain_shaders['image_smooth'])
    else:
        set_terrain_shader(terrain_shaders['image'])


func _on_reload():
    print('Reloaded img_as_terrain mod')
    print('MAP DATA: ' + str(Global.ModMapData['img_as_terrain']))
    var tool_panel = Global.Editor.Toolset.GetToolPanel("TerrainBrush")
    var level = get_current_level()
    print('\n\n')



func on_change_smooth_state(is_smooth):
    ##
    ## Callback function for the smooth state being changed
    ##
    print('Changed smooth state')

    if is_smooth:
        set_terrain_shader(terrain_shaders['image_smooth'])
    else:
        set_terrain_shader(terrain_shaders['image'])


func load_shaders():
    print('Loading shaders')
    terrain_shaders['default'] = load_shader(Global.Root + 'shaders/default.shader')
    terrain_shaders['default_smooth'] = load_shader(Global.Root + 'shaders/default_smooth.shader')
    terrain_shaders['image'] = load_shader(Global.Root + 'shaders/image_terrain.shader')
    terrain_shaders['image_smooth'] = load_shader(Global.Root + 'shaders/image_terrain_smooth.shader')
    terrain_shaders['no_image'] = load_shader(Global.Root + 'shaders/no_image_terrain.shader')
    terrain_shaders['no_image_smooth'] = load_shader(Global.Root + 'shaders/no_image_terrain_smooth.shader')
    terrain_shaders['test'] = load_shader(Global.Root + 'shaders/test.shader')


func update(delta):
    ##
    ## Called once per tick
    ##
    for terrain_handler in terrain_handlers:
        terrain_handler.tick(delta)

    var cur_smooth_state = terrain_brush.get_SmoothBlending()
    if cur_smooth_state != prev_smooth_state and prev_smooth_state != null:
        on_change_smooth_state(cur_smooth_state)

    prev_smooth_state = cur_smooth_state


func start():
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##
    print('MAP DATA: ' + str(Global.ModMapData['img_as_terrain']))

    # Load any external scripts
    print('Loading external scripts')
    utils = load(Global.Root + "scripts/utils.gd").new()
    for i in range(4):
        terrain_handlers.append(load(Global.Root + "scripts/terrain_handler.gd").new())

    # Load the shaders
    load_shaders()

    terrain_brush = Global.Editor.Tools["TerrainBrush"]
    var tool_panel = Global.Editor.Toolset.GetToolPanel("TerrainBrush")

    # Add reload callback
    var reload_mods_button = Global.Editor.get_node("VPartition/MenuBar/MenuAlign/ReloadModsButton")
    reload_mods_button.connect("pressed", self, "_on_reload")

    # Create the file input
    file_input = utils.create_file_input(tool_panel)
    tool_panel.Align.move_child(file_input.get_parent(), 0)

    # Create the stretch toggle
    stretch_button = utils.create_checkbutton(tool_panel, 'Stretch')
    tool_panel.Align.move_child(stretch_button, 1)

    # Initialize external scripts
    for i in range(terrain_handlers.size()):
        terrain_handlers[i].init(self, i, file_input, stretch_button)

    # terrain_item_list = tool_panel.Align.get_children()[8].get_children()[0]
    Global.Editor.Toolset.Quickswitch("TerrainBrush")

    on_change_smooth_state(terrain_brush.get_SmoothBlending())
    # set_terrain_shader(terrain_shaders['image_smooth'])

