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
var qutils = null
var class_a = null

var elapsed_time = 0.0
var wave_frame = 0

var levels = []

# Globals


func _on_reload():
    print(' ')
    var level = Global.World.get_Level()
    # print()
    # print(utils.dir_string(level.WaterMesh.material))
    # print(level.WaterMesh.material.shader.code)
    # level.WaterMesh.visible = true
    # for child in level.WaterMesh.get_parent().get_children():
    #     print(child)
    # utils.print_ancestors(level.WaterMesh)
    # print()
    # print(utils.dir_string(level))
    # print(utils.dir_string())
    # utils.save_txt(level.WaterMesh.material.shader.code, Global.Root + 'shaders/water.shader')
    var water_material = level.WaterMesh.material
    water_material.set_shader_param('current_rotation', 0.0)
    water_material.set_shader(utils.load_shader(Global.Root + 'shaders/water_rotation.shader'))

    # print(utils.load_shader(Global.Root + 'shaders/water.shader').code)
    var is_triangle = false
    if is_triangle:
        # Frequency Formula:    frequency = 1.0 / period
        var period = 40.0
        var frequency = 2 * PI / period
        var amplitude = 1.0

        # var wave_pos = amplitude * sin(frequency * float(wave_frame))
        var wave_pos = 0
        if wave_frame < 0.25 * period:
            wave_pos = amplitude * wave_frame
        elif wave_frame < 0.75 * period:
            wave_pos = (-amplitude * wave_frame) + (2.0 * amplitude)
        else:
            wave_pos = (amplitude * wave_frame) - (4.0 * amplitude)

        water_material.set_shader_param('wave_pos', wave_pos)

        water_material.set_shader(utils.load_shader(Global.Root + 'shaders/water.shader'))



func update(delta):
    ##
    ## Called once per tick
    ##
    elapsed_time += delta

    var water_material = Global.World.get_Level().WaterMesh.material

    var rotation_step = (2.0 * PI) / 2000.0
    var cur_rotation = water_material.get_shader_param('current_rotation')
    water_material.set_shader_param('current_rotation', cur_rotation + rotation_step)

    var is_triangle = false
    if is_triangle:
        water_material.set_shader_param('time', elapsed_time)

        var period = 1000.0
        var frequency = 2 * PI / period
        var amplitude = 10.0


        if wave_frame >= period:
            wave_frame = 0

        # var wave_pos = amplitude * sin(frequency * float(wave_frame))
        var wave_pos = 0
        if wave_frame <= 0.25 * period:
            # wave_pos = amplitude * wave_frame
            wave_pos = (amplitude / (0.25 * period)) * wave_frame
            # print('a: ' + str(wave_pos))
        elif wave_frame < 0.75 * period:
            # wave_pos = (-amplitude * wave_frame) + (2.0 * amplitude)
            wave_pos = (-amplitude / (0.25 * period)) * (wave_frame - (0.5 * period))
            # print('b: ' + str(wave_pos))
        else:
            # wave_pos = (amplitude * wave_frame) - (4.0 * amplitude)
            wave_pos = (amplitude / (0.25 * period)) * (wave_frame - period)
            # print('c: ' + str(wave_pos))
        
        water_material.set_shader_param('wave_pos', wave_pos)
    
    # print(wave_frame)
    # print(wave_pos)
    
    wave_frame += 1

    
    
    # print(elapsed_time)

    var do_stuff = false

    if do_stuff:
        var cur_focus = Global.Editor.Toolset.get_focus_owner()

        var level = Global.World.levels[Global.World.CurrentLevelId]
        var viewport = Global.Editor.get_viewport()
        var master = Global.Editor.owner

        var tile_cam = level.FloorTileCamera
        var master_cam = master.get_Camera()
        # print(master_cam.get_global_position())
        # print(tile_cam.get_global_position())
        # print(' ')

        # if Input.is_mouse_button_pressed(BUTTON_LEFT):
        #     print(cur_focus)
        #     utils.print_ancestors(cur_focus)
        #     print(" ")


func start():
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##

    # Load any external scripts
    print("Loading utils")
    utils = load(Global.Root + "scripts/utils.gd").new()

    qutils = load(Global.Root + "scripts/utils.gd").new()
    qutils.init(self)

    # Add reload callback
    var reload_mods_button = Global.Editor.get_node("VPartition/MenuBar/MenuAlign/ReloadModsButton")
    reload_mods_button.connect("pressed", self, "_on_reload")

    # Create the new tool
    var category = "Settings"
    var id = "water_test"
    var name = "Water Test"
    var icon = Global.Root + "icons/water_test.png"

    var tool_panel = Global.Editor.Toolset.CreateModTool(self, category, id, name, icon)
    # tool_panel.UsesObjectLibrary = true
    tool_panel.CreateLabel("Water Test")
    # tool_panel.CreateLabel("Objects")

    # var names = ["All"]
    # for z_index in layer_names.keys():
    #     if layers[z_index]:
    #         names.append(layer_names[z_index])

    # layer_dropdown = tool_panel.CreateDropdownMenu("Layers", names, names[0])

    # var button1 = tool_panel.CreateButton("Hide", Global.Root + "icons/question.png")
    # button1.connect("pressed", self, "on_click_hide")

    # var button2 = tool_panel.CreateButton("Show", Global.Root + "icons/question.png")
    # button2.connect("pressed", self, "on_click_show")

    # var button3 = tool_panel.CreateButton("Toggle Background", Global.Root + "icons/question.png")
    # button3.connect("pressed", self, "toggle_background")

    # var button2 = tool_panel.CreateButton("Randomize Asset", Global.Root + "icons/add.png")
    # button2.connect("pressed", self, "randomize_asset")

    