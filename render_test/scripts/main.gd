## Uses Dungeondraft v1.1.0.0
##
## Toggle Layers v1.0.0
## Author: Avery Berg
## Allows developers to render the map programatically
## 
## TODO: Description
##

# Required Globals
var script_class = "tool"

# External Scripts
var utils = null
var Renderer
var Render

var renderer = null

var tool_panel = null
var render_tool = null

var is_cursor_set = false

var water_render_shader = null
var water_default_shader = null

var boost_amount = 3.0

var layer_map = {
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

func print_args(arg1=null, arg2=null, arg3=null, arg4=null):
    var args = [arg1, arg2, arg3, arg4]
    print('args: ' + str(args))


func layer_has_content(z_index):
    # print('Setting layer ' + str(z_index) + ' to ' + str(visible))
    var level = Global.World.GetLevelByID(Global.World.CurrentLevelId)

    # Check water
    # TODO: Figure this out later
    if z_index == 0:
        return true
    
    # Check terrain
    if z_index == -500:
        return true

    # Check objects
    for obj in level.Objects.get_children():
        if obj.z_index == z_index:
            return true
    
    # Check paths
    for path in level.Pathways.get_children():
        if path.z_index == z_index:
            return true
    
    # Check pattern shapes
    for layer in level.PatternShapes.get_children():
        if layer.z_index == z_index:
            if layer.get_children().size():
                return true
            break
    
    # Check roofs
    if z_index == 800 and level.Roofs.get_children().size():
        return true
    
    # Check lights
    if z_index == 9999 and level.Lights.get_children().size():
        return true
    
    # Check portals
    if z_index == 500 and level.Portals.get_children().size():
        return true
    
    return false


func set_layer_visibility(z_index, visible):
    # print('Setting layer ' + str(z_index) + ' to ' + str(visible))
    var level = Global.World.GetLevelByID(Global.World.CurrentLevelId)

    # Toggle objects
    for obj in level.Objects.get_children():
        if obj.z_index == z_index:
            obj.visible= visible
    
    # Toggle paths
    for path in level.Pathways.get_children():
        if path.z_index == z_index:
            path.visible = visible
    
    # Toggle pattern shapes
    for layer in level.PatternShapes.get_children():
        if layer.z_index != z_index:
            continue
        for pattern_shape in layer.get_children():
            pattern_shape.visible = visible
    
    # Toggle roofs
    if z_index == 800:
        for roof in level.Roofs.get_children():
            roof.visible = visible
    
    # Toggle lights
    if z_index == 9999:
        for light in level.Lights.get_children():
            light.visible = visible
    
    # Toggle portals
    if z_index == 500:
        for portal in level.Portals.get_children():
            portal.visible = visible
    
    # Toggle water
    if z_index == 0:
        level.WaterMesh.visible = visible
    
    # Toggle terrain
    if z_index == -500:
        level.Terrain.visible = visible


func set_grid_visibility(visible):
    Global.World.get_GridMesh().visible = visible


func set_viewport_transparency(is_transparent):
    # var is_transparent = !visible

    # Get the viewports
    var viewport = Global.Editor.get_viewport()
    var viewport_b = Global.Editor.owner.get_Viewport()
    
    # Make the viewport transparent
    viewport.transparent_bg = is_transparent
    viewport_b.transparent_bg = is_transparent

    # Hide the terrain and water
    # var level = Global.World.GetLevelByID(Global.World.CurrentLevelId)
    # level.Terrain.visible = visible
    # level.WaterMesh.visible = visible


func show_only(z_indices):
    # Ensure z_indices is a list
    if not typeof(z_indices) == 19:
        z_indices = [z_indices]
    
    for layer_index in layer_map.keys():
        set_layer_visibility(layer_index, layer_index in z_indices)
    
    set_grid_visibility(false)

    set_viewport_transparency(true)


func show_all():
    for z_index in layer_map.keys():
        set_layer_visibility(z_index, true)

    set_viewport_transparency(false)


func on_layer_render_scan(delta, z_index):
    show_only(z_index)


func on_layer_render_finish(rendered_img):
    show_all()


func on_water_terrain_render_finish(water_terrain_img, water_mask_img, frame):
    show_all()

    var dest_dir = '/Users/Avery/Documents/Dungeondraft/Renders'
    var dest_basename = 'dd_render_water_' + '%03d' % frame + '.png'
    var dest_path = dest_dir + '/' + dest_basename

    var water_img = null
    var image_size = water_terrain_img.get_size()
    var image_rect = Rect2(0, 0, image_size.x, image_size.y)
    
    if water_mask_img:
        # Create the water image
        water_img = Image.new()
        water_img.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)

        # Apply the water mask to the water terrain and store it in the water image
        water_img.blit_rect_mask(water_terrain_img, water_mask_img, image_rect, Vector2(0, 0))
    else:
        water_img = water_terrain_img

    # Add the water image to the export queue
    renderer.export_image(water_img, dest_path)

    # Reset the water shader to default
    var level = Global.World.get_Level()
    var water_material = level.WaterMesh.material

    water_material.set_shader(water_default_shader)


func on_water_terrain_render_scan(delta, frame, z_index):
    on_layer_render_scan(delta, z_index)

    var level = Global.World.get_Level()
    var water_material = level.WaterMesh.material

    water_material.set_shader_param('time', 0.042*float(frame))
    water_material.set_shader(water_render_shader)
    water_material.set_shader_param('time', 0.042*float(frame))


func on_water_terrain_render_start(frame):
    var level = Global.World.get_Level()
    var water_material = level.WaterMesh.material

    print('here!')
    print('Water material: ' + str(water_material))

    print('Setting the shader param')
    water_material.set_shader_param('time', 0.042*float(frame))
    print('Setting the shader')
    water_material.set_shader(water_render_shader)
    water_material.set_shader_param('time', 0.042*float(frame))

    print('Set the water shader')


func on_water_render_mask_finish(water_mask_img, water_ppi):
    show_all()

    var frame_range = 4
    for frame in range(frame_range):
        var water_terrain_render = Render.new(self, null, water_ppi, boost_amount)
        water_terrain_render.connect('scan_started', self, 'on_water_terrain_render_start', [frame+10])
        water_terrain_render.connect('scanning', self, 'on_water_terrain_render_scan', [frame+10, [0, -500]])
        water_terrain_render.connect('scan_finished', self, 'on_water_terrain_render_finish', [water_mask_img, frame+10])
        renderer.submit(water_terrain_render)


func on_frame_render_finish(rendered_img, frame):
    var dest_dir = '/Users/Avery/Documents/Dungeondraft/Renders'
    var dest_basename = 'dd_render_anim_' + '%03d' % frame + '.png'
    var dest_path = dest_dir + '/' + dest_basename

    # Add the water image to the export queue
    renderer.export_image(rendered_img, dest_path)

    # Reset the water shader to default
    var level = Global.World.get_Level()
    var water_material = level.WaterMesh.material

    water_material.set_shader(water_default_shader)


func on_frame_render_scan(delta, frame):
    var level = Global.World.get_Level()
    var water_material = level.WaterMesh.material

    water_material.set_shader_param('time', 0.042*float(frame))
    water_material.set_shader(water_render_shader)
    water_material.set_shader_param('time', 0.042*float(frame))


func on_frame_render_start(frame):
    var level = Global.World.get_Level()
    var water_material = level.WaterMesh.material

    water_material.set_shader_param('time', 0.042*float(frame))
    water_material.set_shader(water_render_shader)
    water_material.set_shader_param('time', 0.042*float(frame))


func export_frames(frame_range):
    for frame in range(10, frame_range+10):
        var frame_render = Render.new(self, null, 256, boost_amount)
        frame_render.connect('scan_started', self, 'on_frame_render_start', [frame])
        frame_render.connect('scanning', self, 'on_frame_render_scan', [frame])
        frame_render.connect('scan_finished', self, 'on_frame_render_finish', [frame])
        renderer.submit(frame_render)


func export_water():
    var water_layers = [-500, -400, -300, -200, -100, 0]

    var water_terrain_render = Render.new(self, null, 256, boost_amount)
    water_terrain_render.connect('scan_started', self, 'on_water_terrain_render_start', [10])
    water_terrain_render.connect('scanning', self, 'on_water_terrain_render_scan', [10, water_layers])
    water_terrain_render.connect('scan_finished', self, 'on_water_terrain_render_finish', [null, 10])
    renderer.submit(water_terrain_render)


func export_all_layers():
    
    var render_folder = '/Users/Avery/Documents/Dungeondraft/Renders'

    for z_index in layer_map.keys():
        if not layer_has_content(z_index):
            continue
        
        var dest_path = render_folder + '/dd_render_' + str(z_index) + '.png'
        var new_render = Render.new(self, dest_path, 256, boost_amount)
        new_render.connect('scanning', self, 'on_layer_render_scan', [z_index])
        new_render.connect('scan_finished', self, 'on_layer_render_finish')
        renderer.submit(new_render)


func _on_reload():
    print(' ')

    return

    # # for z_index in layer_map.keys():
    # #     if not layer_has_content(z_index):
    # #         continue
        
    # #     var dest_path = render_folder + '/dd_render_' + str(z_index) + '.png'
    # #     var new_render = Render.new(self, dest_path)
    # #     new_render.connect('scanning', self, 'on_layer_render_scan', [z_index])
    # #     new_render.connect('scan_finished', self, 'on_layer_render_finish')
    # #     renderer.submit(new_render)
    
    # # Create and submit a render for the water
    # var water_ppi = 128
    # var water_mask_render = Render.new(self, null, water_ppi)
    # water_mask_render.connect('scanning', self, 'on_layer_render_scan', [0])
    # water_mask_render.connect('scan_finished', self, 'on_water_render_mask_finish', [water_ppi])
    # renderer.submit(water_mask_render)

    return


func update(delta):
    ##
    ## Called once per tick
    ##

    if renderer:
        renderer.tick(delta)
    
    if Global.Editor.ActiveTool == render_tool:

        # Ensure that the cursor is hidden for the render tool
        if not is_cursor_set:
            Global.World.get_node('WorldUI').set_CursorMode(0)
            is_cursor_set = true


func start():
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##

    # Load any external scripts
    print('Loading utils')
    utils = load(Global.Root + "scripts/utils.gd").new()

    print('Loading Renderer')
    Renderer = load(Global.Root + 'scripts/renderer.gd').new().Renderer

    print('Loading Render')
    Render = load(Global.Root + 'scripts/render.gd').new().Render

    print('Creating Renderer instance')
    renderer = Renderer.new(self)
    print('Created Renderer instance')

    # Load the shaders
    water_render_shader = utils.load_shader(Global.Root + 'shaders/water_render.shader')
    water_default_shader = utils.load_shader(Global.Root + 'shaders/water_default.shader')

    # Add reload callback
    var reload_mods_button = Global.Editor.get_node("VPartition/MenuBar/MenuAlign/ReloadModsButton")
    reload_mods_button.connect("pressed", self, "_on_reload")

    # Create the new tool
    var category = 'Settings'
    var id = 'render_test'
    var name = 'Render Test'
    var icon = Global.Root + 'icons/render_test.png'

    tool_panel = Global.Editor.Toolset.CreateModTool(self, category, id, name, icon)
    render_tool = tool_panel.Tool

    tool_panel.CreateLabel('Export Options')

    tool_panel.CreateButton()
    var export_button1 = utils.create_button('Export Layers')
    export_button1.connect('pressed', self, 'export_all_layers')
    tool_panel.Align.add_child(export_button1)

    var export_button2 = utils.create_button('Export Water')
    export_button2.connect('pressed', self, 'export_water')
    tool_panel.Align.add_child(export_button2)

    var export_button3 = utils.create_button('Export 128 Frames')
    export_button3.connect('pressed', self, 'export_frames', [128])
    tool_panel.Align.add_child(export_button3)
