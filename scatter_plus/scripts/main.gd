## Uses Dungeondraft v1.1.0.0
##
## Scatter Plus v1.2.0
## Author: Avery Berg
## 
## Adds additional functionality to the scatter tool
##

# Required Global
var script_class = "tool"

# External Scripts
var utils = null
var group_handler = null

# Globals
var scatter_tool = null
var tool_panel = null

# ___________________Test Functions___________________

func _on_reload():
    print(" ")


func _add_reload_callback():
    # Add reload callback
    var reload_mods_button = Global.Editor.get_node("VPartition/MenuBar/MenuAlign/ReloadModsButton")
    reload_mods_button.connect("pressed", self, "_on_reload")


# ___________________Base Functions___________________

func start():
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##

    print("Initializing scatter plus")

    # Load any external scripts
    utils = load(Global.Root + "scripts/utils.gd").new()
    group_handler = load(Global.Root + "scripts/group_handler.gd").new()

    # Initialize any external scripts
    utils.init(self)
    group_handler.init(self)

    # Cache the scatter tool and its panel
    scatter_tool = Global.Editor.Tools["ScatterTool"]
    tool_panel = Global.Editor.Toolset.GetToolPanel("ScatterTool")

    print("Adding group checkbox button")

    # Create and add the "Group" checkbox button
    tool_panel.Align.add_child(group_handler.group_checkbox)
    tool_panel.Align.move_child(group_handler.group_checkbox, 0)

    print("Adding the group container")

    # Create the group container
    tool_panel.Align.add_child(group_handler.group_container)
    tool_panel.Align.move_child(group_handler.group_container, 1)

    print("Creating the separator")

    # Create the separator
    var sep = utils.create_separator(tool_panel)
    tool_panel.Align.move_child(sep, 2)

    print("Creating the spacer")

    # Create and add a spacer to the scatter tool's panel
    var spacer = utils.create_spacer(tool_panel, Vector2(0, 100))

    print("Finished startup")

    _add_reload_callback()


func update(delta):
    ##
    ## Called once per tick
    ##
    group_handler.tick(delta)
