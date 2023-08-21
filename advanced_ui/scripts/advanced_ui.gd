## Uses Dungeondraft v1.1.0.0
##
## Advanced UI v1.0.0
## Author: Avery Berg
## 
## TODO: Description
##

# Required Global
var script_class = "tool"

# External Scripts
var utils = null

# Globals
var scatter_tool = null
var sg_item_list = null
var DEFAULT_TOOLS = [
    "FloorShapeTool",
    "WallTool",
    "PortalTool",
    "CaveBrush",
    "PatternShapeTool",
    "RoofTool",
    "TerrainBrush",
    "WaterBrush",
    "MaterialBrush",
    "PathTool",
    "ObjectTool",
    "ScatterTool",
    "Environment",
    "LightTool",
    "MapSettings",
    "LevelSettings",
    "TraceImage"
]


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


func build_item_list():
    print("Building item list")
    sg_item_list.clear()

    var obj_menu = Global.Editor.ObjectLibraryPanel.objectMenu
    var lookup = obj_menu.get_Lookup()

    var new_index = 0
    for res_path in lookup.keys():
        var icon = obj_menu.get_item_icon(lookup[res_path])
        var tool_tip = obj_menu.get_item_tooltip(lookup[res_path])

        sg_item_list.add_icon_item(icon)
        sg_item_list.set_item_metadata(new_index, res_path)
        sg_item_list.set_item_tooltip(new_index, tool_tip)

        new_index += 1
    
    print("Finished building item list")


func test_item_list():

    var new_menu = ItemList.new()

    var obj_menu = Global.Editor.ObjectLibraryPanel.objectMenu

    print("-----Object Menu-----")
    print(utils.dir_string(obj_menu, null, true))

    print("-----New Menu-----")
    print(utils.dir_string(new_menu, null, true))


func get_toolbars():
    var anchor = Global.Editor.get_node("VPartition/Panels/Tools/Anchor")
    var toolbars = []

    for child in anchor.get_children():
        if "Toolbar" in str(child.name):
            toolbars.append(child)
    
    return toolbars


func get_toolbar_buttons(toolbar):
    var buttons = []
    for child in toolbar.get_node("Divider/Buttons").get_children():
        if utils.get_attr_safe(child, "Tool"):
            buttons.append(child)
    
    return buttons


func get_all_tool_buttons():
    ##
    ## Get a list containing the buttons from each toolbar
    ## Add buttons from mods to the bottom
    ##
    var default_buttons = []
    var mod_buttons = []

    for toolbar in get_toolbars():
        for button in get_toolbar_buttons(toolbar):
            if button.Tool in DEFAULT_TOOLS:
                default_buttons.append(button)
            else:
                mod_buttons.append(button)
    
    return default_buttons + mod_buttons


func expand_tool_tray():
    var tool_tray = Global.Editor.get_node("VPartition/Panels/Tools/Anchor/Toolset")
    for child in tool_tray.get_children():
        if child is Button:
            child.visible = false
        elif child is HBoxContainer:
            child.visible = true


func collapse_tool_tray():
    var tool_tray = Global.Editor.get_node("VPartition/Panels/Tools/Anchor/Toolset")
    for child in tool_tray.get_children():
        if child is Button:
            child.visible = true
        elif child is HBoxContainer:
            child.visible = false


func quick_swap_no_sidebar(tool_name):
    Global.Editor.Toolset.Quickswitch(tool_name)
    for toolbar in get_toolbars():
        toolbar.get_node("Divider/Buttons").visible = false



func create_expanded_tray():
    var tool_tray = Global.Editor.get_node("VPartition/Panels/Tools/Anchor/Toolset")
    var buttons = get_all_tool_buttons()
    var hboxes = []
    
    for i in range(buttons.size()):
        if i % 2 == 0:
            hboxes.append(HBoxContainer.new())
        
        var new_button = Button.new()
        new_button.set_button_icon(buttons[i].get_button_icon())
        new_button.connect("pressed", self, "quick_swap_no_sidebar", [buttons[i].Tool])
        # new_button.connect("pressed", Global.Editor.Toolset, "Quickswitch", [buttons[i].Tool])

        hboxes[-1].add_child(new_button)
    
    for hbox in hboxes:
        tool_tray.add_child(hbox)


func _on_reload():
    print(" ")
    var toolbar = get_toolbars()[0]
    var back_button = toolbar.get_node("Divider/Buttons").get_children()[-1]

    # toolbar.print_tree_pretty()
    return

    # print(utils.dir_string(back_button, "sig"))
    # print(back_button.name)
    # back_button.emit_signal("pressed")
    # print("pressed")
    # print(back_button.get_signal_connection_list("pressed"))
    # for signal_name in
    # [{binds:[], flags:0, method:OnBackButtonClicked, signal:pressed, source:BackButton:[Button:32863], target:[VBoxContainer:31754]}]

    # for sig in back_button.get_signal_list():
    #     var conns = back_button.get_signal_connection_list(sig.name)
    #     if conns:
    #         print(sig.name + ": " + str(conns))
    #         print(" ")
    # print()



    # var button = Button.new()
    # print(utils.dir_string(button, "icon"))
    # var new_theme = Theme.new()
    # new_theme.set_icon("Button", "normal", "icon_min_size", Vector2(2, 2))

    # var tool_tray = Global.Editor.get_node("VPartition/Panels/Tools/Anchor/Toolset")
    # print(utils.dir_string(tool_tray, "size"))
    # print(Global.Editor.get_node("VPartition/Panels/Tools/Anchor/Toolset").get_h_size_flags())
    # for hbox in tool_tray.get_children():
    #     if not hbox is HBoxContainer:
    #         continue
        
    #     hbox.set_h_size_flags(1)
    #     hbox.set_v_size_flags(1)
    #     hbox.set_size(Vector2(92, 40))
    #     for button in hbox.get_children():
    #         button.set_h_size_flags(1)
    #         button.set_v_size_flags(1)
        
        # print(utils.dir_string(hbox, "size"))
        # hbox.set_size(Vector2(92, 40))
        # print(hbox.get_h_size_flags())
        # (92, 40)
        # set_custom_minimum_size(Vector2(180, 5)
        # print("hello")
        # for button in tray_child.get_children():
            # button.rect_min_size = Vector2(22, 20)
            # print(button.get_size())

            # print(button.get_size())
            # button.set_size(Vector2(2, 2))
            # child.set_theme(new_theme)
            
            # print(child.get_theme())
            # print(child.get("Theme Overrides"))
            # print(get_attr_safe(child, "Theme Overrides"))
            # print(utils.dir_string(child, "size"))
            # child.separation = 20
    

    # var godot_version = "Godot " + version_info.major + "." + version_info.minor + "." + version_info.patch
    # print()
    
    # sg_item_list.set_size(Vector2(170, 500))
    
    # build_item_list()

    # print("asdf: " + str(obj_menu.asdf(0)))
    # get_item_count
    # get_item_custom_bg_color
    # get_item_custom_fg_color
    # get_item_icon
    # get_item_icon_modulate
    # get_item_icon_region
    # get_item_metadata
    # get_item_tag_icon
    # get_item_text
    # get_item_tooltip

    # for res_path in lookup.keys():
    #     var index = lookup[res_path]


func update(delta):
    ##
    ## Called once per tick
    ##
    var cur_focus = Global.Editor.Toolset.get_focus_owner()

    if Input.is_mouse_button_pressed(BUTTON_LEFT):
        print(cur_focus)
        utils.print_ancestors(cur_focus)
    pass

func start():
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##

    # Load any external scripts
    utils = load(Global.Root + "scripts/utils.gd").new()

    scatter_tool = Global.Editor.Tools["ScatterTool"]

    # Add reload callback
    var reload_mods_button = Global.Editor.get_node("VPartition/MenuBar/MenuAlign/ReloadModsButton")
    reload_mods_button.connect("pressed", self, "_on_reload")

    var tool_panel = Global.Editor.Toolset.GetToolPanel("ScatterTool")

    # Create a new VBoxContainer
    var vbox = VBoxContainer.new()

    # Create a new ItemList node
    # sg_item_list = ItemList.new()
    sg_item_list = clone_node(Global.Editor.ObjectLibraryPanel.objectMenu)

    # vbox.add_child(sg_item_list)

    tool_panel.get_children()[-1].add_child(sg_item_list)
    tool_panel.Align.move_child(sg_item_list, 0)


    # Create expanded tool tray
    # create_expanded_tray()
    # expand_tool_tray()


