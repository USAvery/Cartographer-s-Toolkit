## Uses Dungeondraft v1.1.0.0
##
## Path Kit v0.1.0
## Author: Avery Berg
## 
## Adds more options for manipulating paths in the Select Tool
##

# Required Global
var script_class = "tool"

# External Scripts
var utils = null

# Globals
var select_tool = null
var path_kit_section = null

var sub_sections = {
    'path2water': null,
    'simplify': null,
    'grow_and_shrink': null,
    'path2path': null,
    'shape2path': null,
    'path2shape': null,
    'width': null
}


# ___________________Test Functions___________________

func _on_reload():
    print('\n\n')
    print(sub_sections['width'].can_use_tool())
    var sel_path = get_selected_path()
    if sel_path:
        print(sel_path.Save(true).keys())
        # print(utils.dir_string(sel_path))


func _add_reload_callback():
    # Add reload callback
    var reload_mods_button = Global.Editor.get_node("VPartition/MenuBar/MenuAlign/ReloadModsButton")
    reload_mods_button.connect("pressed", self, "_on_reload")


# ___________________Query Objects in Scene Functions___________________

func get_selected_items():
    ##
    ## Get the selected items
    ##    
    return select_tool.Selected


func get_paths():
    ##
    ## Get all the path nodes
    ##
    var cur_level = Global.World.levels[Global.World.CurrentLevelId]
    return cur_level.Pathways.get_children()


func get_selected_path():
    ##
    ## Get the selected path
    ##
    var paths = get_paths()

    for item in get_selected_items():
        if item in paths:
            return item
    
    return null


func get_patterns():
    ##
    ## Get all the pattern shapes
    ##
    # print('get_patterns')
    var cur_level = Global.World.levels[Global.World.CurrentLevelId]
    var patterns = []

    # Iterate through the layers
    for layer in cur_level.PatternShapes.get_children():
        
        # Iterate through the pattern shapes
        for pattern_shape in layer.get_children():
            patterns.append(pattern_shape)
    
    # print('patterns: ' + str(patterns))
    return patterns


func get_selected_pattern_shape():
    ##
    ## Get the selected pattern shape
    ##
    # print('get_selected_pattern_shape')
    var pattern_shapes = get_patterns()

    for item in get_selected_items():
        if item in pattern_shapes:
            return item
    
    return null


# ___________________Base Functions___________________

func can_use_tool():
    ##
    ## Determine whether the tool is usable for the current selection
    ##
    var is_a_path_selected = get_selected_path() != null
    return is_a_path_selected


func open_section(section_name):
    ##
    ## Callback function for clicking a section's open button
    ##
    var section = sub_sections.get(section_name)
    if not section:
        return
    
    if section.is_open:
        return
    
    # Don't open if any other path kit sections are open
    for sibling_name in sub_sections.keys():
        if sibling_name == section_name:
            continue
        if sub_sections.get(sibling_name).is_open:
            var msg = 'Unable to open ' + section_name + '. '
            msg += sibling_name + ' is already open'
            print(msg)
            return
    
    print('Opening section ' + section_name)
    section.open_section()


func update(delta):
    ##
    ## Called once per tick
    ##
    # Call any external scripts' tick functions
    for subsec_name in sub_sections.keys():
        var subsec_obj = sub_sections.get(subsec_name)
        subsec_obj.tick(delta)

    if select_tool != Global.Editor.ActiveTool:
        return

    # Determine whether to make the path kit visible
    var do_show = can_use_tool()
    path_kit_section.set_visible(do_show)

    # Determine whether each subsection is visible in the path kit
    for subsec_name in sub_sections.keys():
        var subsec_obj = sub_sections.get(subsec_name)
        subsec_obj.open_button.set_visible(subsec_obj.can_use_tool())


func init_ui():
    plog('Initializing UI')

    var tool_panel = Global.Editor.Toolset.GetToolPanel("SelectTool")

    plog('Initializing UI of subsections')

    # Initialize the UI of any external scripts
    for subsec_name in sub_sections.keys():
        var subsec_obj = sub_sections.get(subsec_name)
        subsec_obj.init_ui()

    # Create the path kit section in the select tool's panel
    path_kit_section = utils.create_vbox(tool_panel.Align)

    plog('Adding subsections to path kit section')
    for subsec_name in sub_sections.keys():
        var subsec_obj = sub_sections.get(subsec_name)

        # Add the subsection's open button
        subsec_obj.open_button.connect('pressed', self, 'open_section', [subsec_name])
        path_kit_section.add_child(subsec_obj.open_button)

        # Add the subsection
        path_kit_section.add_child(subsec_obj.section)

    # Add a spacer at the bottom of the select tool's panel
    var spacer = utils.create_spacer(tool_panel, Vector2(0, 100))

    plog('Finished initializing UI')
    # tool_panel.Align.move_child(spacer, tool_panel.Align.get_children().size()-1)

func plog(msg):
    print('path_kit: ' + str(msg))


func start():
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##
    plog('Initializing')

    # Load any external scripts
    plog('Loading external scripts')
    utils = load(Global.Root + "scripts/utils.gd").new()

    plog('Building subsections dictionary')
    # Load the subsection scripts into a dictionary
    for subsec_name in sub_sections.keys():
        var subsec_script_path = "scripts/subsections/" + subsec_name + ".gd"
        sub_sections[subsec_name] = load(Global.Root + subsec_script_path).new()

    plog('Initializing subsections')
    # Initialize any external scripts
    for subsec_name in sub_sections.keys():
        var subsec_obj = sub_sections.get(subsec_name)
        subsec_obj.init(self)

    # Load the select tool
    select_tool = Global.Editor.Tools["SelectTool"]

    # Initialize the UI
    init_ui()

    plog('Finished initializing')

    # Add the reload callback for testing
    _add_reload_callback()
