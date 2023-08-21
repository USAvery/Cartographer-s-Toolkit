## Uses Dungeondraft v1.1.0.0
##
## Blank v1.0.0
## Author: Avery Berg
## 
## TODO: Description
##

# Required Global
var script_class = "export_format"
var export_format_name = "Custom Export Format"
var export_file_extension = "myexport"
var export_image_format = "webp"
var show_quality_slider = true

# External Scripts
var utils = null
var class_a = null

# Globals
var select_tool = null


# this method is required. it is called just image export.
func process(path : String, image : File, ppi : int):
    var imageAsText = Marshalls.raw_to_base64(image.get_buffer((image.get_len())))
    var data = {
        "title" : Global.World.Title,
        "pixel_size" : [ Global.World.WoxelDimensions.x, Global.World.WoxelDimensions.y ],
        "creation_timestamp" : OS.get_unix_time(),
        "image" : imageAsText
    }
    var file = File.new()
    var error = file.open(path, File.WRITE);
    file.store_line(JSON.print(data, "\t"));
    file.close();

func _on_reload():
    print(" ")
    


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

    Global.Editor.Toolset.Quickswitch("SelectTool")