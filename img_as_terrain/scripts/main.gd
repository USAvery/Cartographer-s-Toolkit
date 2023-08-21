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

# Globals
var terrain_brush = null
var file_input = null

var terrain_shaders = {
    'image': null,
    'image_smooth': null,
    'image_alpha': null,
    'image_alpha_smooth': null
} 

var image_terrain_shader = null
var image_terrain_smooth_shader = null

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


func get_selected_terrain_img():
    var level = get_current_level()
    return level.Terrain.get_Textures()[0]


func get_current_level():
    ##
    ## Get the current level
    ##
    return Global.World.GetLevelByID(Global.World.CurrentLevelId)


func set_terrain_img(texture):
    ##
    ## Set the base terrain image
    ##
    var level = get_current_level()
    level.Terrain.ShaderMaterial.set_shader_param('texture_1', texture)


func set_terrain_shader(shader):
    ##
    ## Set the terrain shader
    ##
    var level = get_current_level()
    level.Terrain.ShaderMaterial.set_shader(shader)


func _on_reload():
    print("Reloaded img_as_terrain mod")
    # print('\n')
    # var is_smooth = terrain_brush.get_SmoothBlending()
    # print(is_smooth)
    # print(utils.dir_string(level.Terrain))


func on_change_file(path):
    ##
    ## Callback function for the image file changing
    ##
    print('Changed file! ' + str(path))

    if not path:
        set_default_shaders()

    var texture = utils.load_tx(path)
    if not texture:
        return
    
    set_terrain_img(texture)


func on_change_smooth_state(is_smooth):
    ##
    ## Callback function for the smooth state being changed
    ##
    print('Changed smooth state')

    if not file_input.get_text():
        return

    if is_smooth:
        set_terrain_shader(terrain_shaders['image_smooth'])
    else:
        set_terrain_shader(terrain_shaders['image'])


func load_shaders():
    print('Loading shaders')
    terrain_shaders['image'] = load_shader(Global.Root + 'shaders/image_terrain.shader')
    terrain_shaders['image_smooth'] = load_shader(Global.Root + 'shaders/image_terrain_smooth.shader')
    terrain_shaders['no_image'] = load_shader(Global.Root + 'shaders/no_image_terrain.shader')
    terrain_shaders['no_image_smooth'] = load_shader(Global.Root + 'shaders/no_image_terrain_smooth.shader')


func update(delta):
    ##
    ## Called once per tick
    ##
    var cur_path = file_input.get_text()
    var cur_smooth_state = terrain_brush.get_SmoothBlending()

    if not cur_path:
        # Reset the base terrain image
        if prev_path:
            print("Using selected base terrain image")
            set_terrain_img(get_selected_terrain_img())
            prev_path = cur_path
        return

    if cur_path != prev_path:
        on_change_file(cur_path)
        on_change_smooth_state(cur_smooth_state)
    
    if cur_smooth_state != prev_smooth_state and prev_smooth_state != null:
        on_change_smooth_state(cur_smooth_state)
    
    prev_smooth_state = cur_smooth_state
    prev_path = cur_path


func start():
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##

    # Load any external scripts
    print("Loading utils")
    utils = load(Global.Root + "scripts/utils.gd").new()

    # Load the shaders
    load_shaders()

    terrain_brush = Global.Editor.Tools["TerrainBrush"]
    var tool_panel = Global.Editor.Toolset.GetToolPanel("TerrainBrush")
    

    # Add reload callback
    var reload_mods_button = Global.Editor.get_node("VPartition/MenuBar/MenuAlign/ReloadModsButton")
    reload_mods_button.connect("pressed", self, "_on_reload")

    
    file_input = utils.create_file_input(tool_panel)
    tool_panel.Align.move_child(file_input.get_parent(), 0)

    Global.Editor.Toolset.Quickswitch("TerrainBrush")

