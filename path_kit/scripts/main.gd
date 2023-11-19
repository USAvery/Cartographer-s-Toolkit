## Uses Dungeondraft v1.1.0.0
##
## Path2Water v1.0.0
## Author: Avery Berg
## 
## Adds more options for manipulating paths in the Select Tool
##

# Required Global
var script_class = "tool"
var _global = null


# External Scripts
var utils = null

var path2water = null
var simplify = null
var grow_and_shrink = null
var path2path = null
var shape2path = null

# Globals
var select_tool = null
var path_kit_section = null

var sub_sections = {}


# ___________________Test Functions___________________

func _on_reload():
    print('\n\n')


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
    path2water = load(Global.Root + "scripts/path2water.gd").new()
    simplify = load(Global.Root + "scripts/simplify.gd").new()
    grow_and_shrink = load(Global.Root + "scripts/grow_and_shrink.gd").new()
    path2path = load(Global.Root + "scripts/path2path.gd").new()
    shape2path = load(Global.Root + "scripts/shape2path.gd").new()

    plog('Building subsections dictionary')

    # Load the subsection objects into a dictionary
    sub_sections = {
        'path2water': path2water,
        'simplify': simplify,
        'grow_and_shrink': grow_and_shrink,
        'path2path': path2path,
        'shape2path': shape2path
    }

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
