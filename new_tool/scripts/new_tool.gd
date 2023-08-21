## Uses Dungeondraft v1.1.0.0
##
## Blank v1.0.0
## Author: Avery Berg
## 
## TODO: Description
##

# Required Global
var script_class = "tool"

# External Scripts
var utils = null
var class_a = null

# Globals
var select_tool = null
# var sg_item_list = null


func clone_node(original_node: Node) -> Node:
    # Pack the original node into a PackedScene
    var packed_scene = PackedScene.new()
    packed_scene.pack(original_node)

    # Instance a new node from the packed scene
    var duplicate_node = packed_scene.instance()

    # Set the name and position of the duplicate node
    duplicate_node.name = original_node.name + "_clone"
    duplicate_node.position = original_node.position

    # Copy script variables
    duplicate_node.script = original_node.script

    return duplicate_node


func save_txt(txt, path):
    ##
    ## Save txt to a file
    ##

    # Open the file for writing
    var file = File.new()
    if file.open(path, File.WRITE) != OK:
        print("Failed to open file: " + path)
        return false
    
    print("Opened the file")

    # Save the presets dictionary to the file
    file.store_string(str(txt))

    # Close the file
    file.close()

    print("Saved the file")

    return true


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



func _on_reload():
    print(" ")
    # class_a.print_vars()
    # print(Global.World.levels[0])
    # var level = Global.World.GetLevelByID(Global.World.CurrentLevelId)
    # var objects = level.Objects.get_children()
    # var paths = level.Pathways.get_children()
    # var terrain = level.Terrain


    # var transparent_tx = utils.load_tx(Global.Root + "icons/transparent.png")

    # # print(transparent_tx)

    # terrain.textures[0] = utils.load_tx(Global.Root + "icons/transparent.png")

    # print(terrain.textures)

    # Get the top viewport
    var viewport = Global.Editor.get_viewport()

    # Make the viewport transparent
    # viewport.transparent_bg = true
    # Global.Editor.get_tree().get_root().set_transparent_background(true)

    # Get the Master Node
    var master_node = viewport.get_children()[-1]

    # Get the Viewport2D Node
    var vp2d = master_node.ViewportContainer2D.get_children()[0]    
    # vp2d.transparent_bg = true

    # Get the main node
    var main_node = vp2d.get_children()[1]

    # Parse the main node's children
    var grid = main_node.get_children()[0]
    var bounds = main_node.get_children()[2]
    var level_ground = main_node.get_children()[4]

    # bounds.visible = false

    # Get the terrain
    var terrain = level_ground.get_children()[1]

    # Replace terrain shader
    var shad = terrain.get_ShaderMaterial()

    print(utils.dir_string(terrain, 'shad'))

    var world_size_px = Global.World.TileSize * Vector2(Global.World.Width, Global.World.Height)

    var ollie_tx = utils.load_tx("/Users/Avery/Pictures/Ollie.png")
    var uv_tx = utils.load_tx(Global.Root + 'data/uv_test.jpg')



    # print(Vector2(Global.World.Width, Global.World.Height))

    # print(world_vec/Vector2(Global.World.Width, Global.World.Height))

    var shad2 = load_shader(Global.Root + 'shaders/terrain_smooth.shader')
    shad.set_shader(shad2)

    # 
    shad.set_shader_param('texture_1', uv_tx)

    # print(utils.dir_string(shad, "shad"))

    # print('\nBlend Step: ')
    # print(shad.get_shader_param('blend_step'))

    print('\nMap Size: ')
    print(shad.get_shader_param('map_size'))

    # print('\nSplat: ')
    # print(shad.get_shader_param('splat'))

    # print('\nTextures 1-4: ')
    # print(shad.get_shader_param('texture_1'))
    # print(shad.get_shader_param('texture_2'))
    # print(shad.get_shader_param('texture_3'))
    # print(shad.get_shader_param('texture_4'))
    # blend_step
    # map_size
    # splat
    # texture_1
    # texture_2
    # texture_3
    # texture_4

    # print(shad.shader.code)
    # save_txt(shad.shader.code, '/Users/Avery/Desktop/terrain.shader')
    # print(shad.get('shader_param/texture_1'))
    # var transparent_tx = utils.load_tx(Global.Root + "icons/transparent.png")
    # var ollie_tx = utils.load_tx("/Users/Avery/Pictures/Ollie.png")
    # ollie_tx.set_flags(2)
    # ollie_tx.set_size_override(vp2d.get_size())

    # shad.set_shader_param('texture_1', ollie_tx)
    # shad.set_shader_param('texture_2', transparent_tx)
    # shad.set_shader_param('texture_3', transparent_tx)
    # shad.set_shader_param('texture_4', transparent_tx)
    # shad.set_shader_param('splat', transparent_tx)

    # print(utils.dir_string(ollie_tx))

    # print(utils.dir_string(vp2d))
    # print(vp2d.get_size())
    
    
    # for a in utils.dir_string(terrain).split('\n'):
    #     if a.to_lower() != a:
    #         print(a)

    # print(shad.get_shader_param('splat'))
    # shad.set_shader_param('splat', transparent_tx)
    # print()

    # var img = terrain.splatTexture.get_data()
    # img.save_png("/Users/Avery/Desktop/dd_rip.png")
    # terrain.splatTexture = 
    # terrain.splatTexture = transparent_tx
    # terrain.UpdateSplat()
    # print(terrain.splatTexture)
        
    #Properties:
#   <CaveMesh>k__BackingField
#   <Cloning>k__BackingField
#   <Data>k__BackingField
#   <DeferredLighting>k__BackingField
#   <FloorRT>k__BackingField
#   <FloorShapes>k__BackingField
#   <FloorTileCamera>k__BackingField
#   <ID>k__BackingField
#   <Label>k__BackingField
#   <Layers>k__BackingField
#   <LightPassBBC>k__BackingField
#   <LightPassRender>k__BackingField
#   <Lights>k__BackingField
#   <MaterialLayers>k__BackingField
#   <MaterialLookup>k__BackingField
#   <MaterialMeshes>k__BackingField
#   <MeshLookup>k__BackingField
#   <Objects>k__BackingField
#   <Pathways>k__BackingField
#   <PatternShapes>k__BackingField
#   <Portals>k__BackingField
#   <Roofs>k__BackingField
#   <Terrain>k__BackingField
#   <Texts>k__BackingField
#   <TileMap>k__BackingField
#   <Walls>k__BackingField
#   <WasLoaded>k__BackingField
#   <WaterMesh>k__BackingField
#   CanvasItem
#   CaveMesh
#   Cloning
#   Data
#   DeferredLighting
#   FloorRT
#   FloorShapes
#   FloorTileCamera
#   ID
#   Label
#   Layers
#   LightPassBBC
#   LightPassRender
#   Lights
#   LockedLayers
#   Material
#   MaterialLayers
#   MaterialLookup
#   MaterialMeshes
#   MeshLookup
#   Node
#   Node2D
#   Objects
#   Pathways
#   PatternShapes
#   Portals
#   Roofs
#   Script Variables
#   Terrain
#   Texts
#   TileMap
#   Transform
#   Visibility
#   Walls
#   WasLoaded
#   WaterMesh
#   Z Index
#   deferredLightingPath
#   floorRTPath
#   floorTileCameraPath
#   floorTileMap
#   lightPassBBCPath
#   lightPassRenderPath
#   singlePassLighting
#Methods:
#   AddMaterialLayer
#   CleanMaterialMeshes
#   CreateDefaultLockedLayers
#   CreateDefaultUserLayers
#   CreateFreestandingPortal
#   Deserialize
#   GetOrMakeMaterialMesh
#   GetSelectionRect
#   Instance
#   IsMeshEmpty
#   Load
#   LoadEnvironment
#   LoadFreestandingPortal
#   LoadFreestandingPortals
#   LoadLayers
#   LoadMaterialMeshes
#   Resize
#   Save
#   SaveEnvironment
#   SaveFreestandingPortals
#   SaveLayers
#   SaveMaterialMeshes
#   SetAllLightMasks
#   ToggleLighting
#   UpdateFloorRT
#   _EnterTree
#   _ExitTree
#   _Ready
#   get_CaveMesh
#   get_Cloning
#   get_Data
#   get_DeferredLighting
#   get_FloorRT
#   get_FloorShapes
#   get_FloorTileCamera
#   get_ID
#   get_Label
#   get_Layers
#   get_LightPassBBC
#   get_LightPassRender
#   get_Lights
#   get_MaterialLayers
#   get_MaterialLookup
#   get_MaterialMeshes
#   get_MeshLookup
#   get_Objects
#   get_Pathways
#   get_PatternShapes
#   get_Portals
#   get_Roofs
#   get_Terrain
#   get_Texts
#   get_TileMap
#   get_Walls
#   get_WasLoaded
#   get_WaterMesh
#   set_CaveMesh
#   set_Cloning
#   set_Data
#   set_DeferredLighting
#   set_FloorRT
#   set_FloorShapes
#   set_FloorTileCamera
#   set_ID
#   set_Label
#   set_Layers
#   set_LightPassBBC
#   set_LightPassRender
#   set_Lights
#   set_MaterialLayers
#   set_MaterialLookup
#   set_MaterialMeshes
#   set_MeshLookup
#   set_Objects
#   set_Pathways
#   set_PatternShapes
#   set_Portals
#   set_Roofs
#   set_Terrain
#   set_Texts
#   set_TileMap
#   set_Walls
#   set_WasLoaded
#   set_WaterMesh

    return
    # print(utils.dir_string(sg_item_list, "icon_size"))
    # sg_item_list.set_fixed_icon_size(Vector2(32, 32))
    # sg_item_list.rect_size = Vector2(236, 562)
    # sg_item_list.set_h_size_flags(3)
    # sg_item_list.set_v_size_flags(3)
    # sg_item_list.set_max_columns(32)
    # sg_item_list.add_color_override("guide_color", Color(0, 0, 0, 0.12549))
    # sg_item_list.set("custom_constants/vseparation", 4)
    # sg_item_list.set("custom_constants/line_separation", 0)
    # sg_item_list.set("custom_constants/hseparation", 4)
    # sg_item_list.set_margin(MARGIN_RIGHT, 236)
    # sg_item_list.set_margin(MARGIN_BOTTOM, 94)
    # sg_item_list.set_margin(MARGIN_TOP, 0)
    # print(utils.dir_string(sg_item_list, "margin"))
    # build_item_list()


func update(delta):
    ##
    ## Called once per tick
    ##
    var cur_focus = Global.Editor.Toolset.get_focus_owner()

    # if Input.is_mouse_button_pressed(BUTTON_LEFT):
    #     print(cur_focus)
    #     utils.print_ancestors(cur_focus)
    pass

func start():
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##

    # Load any external scripts
    print("Loading utils")
    utils = load(Global.Root + "scripts/utils.gd").new()
    
    print("Loading class a")
    class_a = load(Global.Root + "scripts/class_a.gd").new()
    
    print("Initializing class a")
    class_a.init(self)

    select_tool = Global.Editor.Tools["SelectTool"]

    # Add reload callback
    var reload_mods_button = Global.Editor.get_node("VPartition/MenuBar/MenuAlign/ReloadModsButton")
    reload_mods_button.connect("pressed", self, "_on_reload")

    var tool_panel = Global.Editor.Toolset.GetToolPanel("SelectTool")

    # Create a new VBoxContainer
    # var vbox = VBoxContainer.new()

    # Create a new ItemList node
    # sg_item_list = ItemList.new()
    # sg_item_list = clone_node(Global.Editor.ObjectLibraryPanel.objectMenu)

    # vbox.add_child(sg_item_list)

    # tool_panel.get_children()[-1].add_child(sg_item_list)
    # tool_panel.Align.move_child(sg_item_list, 0)

    Global.Editor.Toolset.Quickswitch("SelectTool")