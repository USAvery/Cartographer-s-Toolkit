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

# Globals

func _on_reload():
    print(" ")
    var select_tool = Global.Editor.Tools['SelectTool']
    # print(utils.dir_string(select_tool, 'save', true, true))
    # select_tool.ClearTransformSelection()

    var level = Global.World.levels[Global.World.CurrentLevelId]
    var objects = level.Objects.get_children()

    # for obj in objects:
    #     if obj in select_tool.Selected:
    #         obj.z_index = 100
    #         # print(obj.get_Texture().resource_path)
    # return

    # # TURN OFF ALL OBJECTS FIRST
    # for obj in level.Objects.get_children():
    #     obj.visible = false

    var layer1_objects = []
    var layer2_objects = []
    var layer3_objects = []
    var layer4_objects = []

    for obj in objects:
        var texture = obj.get_Texture()
        if not texture:
            continue

        var res_path = texture.resource_path
        if not res_path:
            continue
        
        if obj.z_index == 100:
            layer1_objects.append(obj)
        elif obj.z_index == 200:
            layer2_objects.append(obj)
        elif obj.z_index == 300:
            layer3_objects.append(obj)
        elif obj.z_index == 400:
            layer4_objects.append(obj)
        else:
            print('No matching layer for ' + str(obj.z_index))
    
    print('\nLayer 1: ' + str(layer1_objects.size()))
    print('Layer 2: ' + str(layer2_objects.size()))
    print('Layer 3: ' + str(layer3_objects.size()))
    print('Layer 4: ' + str(layer4_objects.size()))
    print(' ')
    
    
    var smoke_groups = []
    var shadow_groups = []
    var general_groups = []
    
    var cur_smoke_group = []
    var cur_shadow_group = []
    var cur_general_group = []
    
    var count = 1
    var selected = false

    for obj in layer1_objects:
        var texture = obj.get_Texture()
        var res_path = texture.resource_path
        var basename = res_path.split('/')[-1]

        if 'tree' in basename.to_lower() and not 'shad' in basename.to_lower() and not 'trunk' in basename.to_lower():
            if not obj in select_tool.Selected:
                obj.z_index = 400

        if 'smoke' in basename.to_lower():
            cur_smoke_group.append(obj)
        elif cur_smoke_group.size():
            print(str(count) + ' SMOKE')
            count += 1
            smoke_groups.append(cur_smoke_group)
            cur_smoke_group = []
            
        
        if 'shad' in basename.to_lower():
            cur_shadow_group.append(obj)
            # print(basename)
        elif cur_shadow_group.size():
            # print('\n')
            print(str(count) + ' SHADOW')
            count += 1
            shadow_groups.append(cur_shadow_group)
            cur_shadow_group = []

        if not 'smoke' in basename.to_lower() and not 'shad' in basename.to_lower():
            cur_general_group.append(obj)
            # print(basename)
        elif cur_general_group.size():
            # print('\n')
            print(str(count) + ' GENERAL')
            count += 1
            general_groups.append(cur_general_group)
            cur_general_group = []
    
    if cur_smoke_group:
        print(str(count) + ' SMOKE')
        count += 1
        smoke_groups.append(cur_smoke_group)
        cur_smoke_group = []
    
    if cur_shadow_group:
        print(str(count) + ' SHADOW')
        count += 1
        shadow_groups.append(cur_shadow_group)
        cur_shadow_group = []
    
    if cur_general_group:
        print(str(count) + ' GENERAL')
        count += 1
        general_groups.append(cur_general_group)
        cur_general_group = []
    
    

    print(' ')

    print('Smoke groups: ' + str(smoke_groups.size()))
    print('Shadow groups: ' + str(shadow_groups.size()))
    print('General groups: ' + str(general_groups.size()))
    
    print(' ')
    
    # LAYER 1
    # 2 Smoke groups
    # 5 Shadow groups
    # 5 General groups

    # LAYER 2
    # 1 General group

    # LAYER 3
    # 1 Smoke group

    # for obj in general_groups[4]:
    #     obj.z_index = 400

    # Make a group visible
    # for obj in shadow_groups[3]:
    # # for obj in general_groups[0]:
    #     # print('making obj visible ' + str(obj))
    #     obj.visible = true
    
    print('\n')

    # --------------- PATHS ---------------
    # print('\n---PATHS---\n')
    # for path in level.Pathways.get_children():
    #     path.visible = true

    # --------------- OTHER ---------------
    var pattern_shapes = []
    for pattern_layer in level.PatternShapes.get_children():
        for shape in pattern_layer.get_children():
            pattern_shapes.append(shape)
    
    print('Objects: ' + str(level.Objects.get_children().size()))
    print('Paths: ' + str(level.Pathways.get_children().size()))
    print('Pattern Shapes: ' + str(pattern_shapes.size()))
    print('Roofs: ' + str(level.Roofs.get_children().size()))
    print('Lights: ' + str(level.Lights.get_children().size()))
    print('Portals: ' + str(level.Portals.get_children().size()))

    print(' ')

    var obj_layers = []
    for obj in level.Pathways.get_children():
        if obj.z_index and not obj.z_index in obj_layers:
            obj_layers.append(obj.z_index)

    var path_layers = []
    for path in level.Pathways.get_children():
        if path.z_index and not path.z_index in path_layers:
            path_layers.append(path.z_index)
    
    print('Object Layers: ' + str(obj_layers))
    print('Path Layers: ' + str(path_layers))
    
    
    

    

    




func update(delta):
    ##
    ## Called once per tick
    ##
    # var cur_focus = Global.Editor.Toolset.get_focus_owner()

    # var reload_mods_button = Global.Editor.get_node("VPartition/MenuBar/MenuAlign/ReloadModsButton")
    # var pressed_signals = reload_mods_button.get_signal_connection_list('pressed')

    # if pressed_signals.size() <= 1:
    #     reload_mods_button.connect("pressed", self, "_on_reload")
    #     print('Connected reload mods button')


    # print()
    # print(utils.dir_string(reload_mods_button, 'sig'))
    # 

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
    var reload_mods_button = Global.Editor.get_node("VPartition/MenuBar/MenuAlign/ReloadModsButton")
    reload_mods_button.connect("pressed", self, "_on_reload")

    # var button2 = tool_panel.CreateButton("Randomize Asset", Global.Root + "icons/add.png")
    # button2.connect("pressed", self, "randomize_asset")

    