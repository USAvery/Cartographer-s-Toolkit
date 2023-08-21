## Uses Dungeondraft v1.1.0.0
##
## Pack Hints v1.0.0
## Author: Avery Berg
## 
## Shows the asset pack in object menu hints
##

# Required Global
var script_class = "tool"

var object_tool = null
var prev_menu_count = null


func get_pack_id_from_res_path(res_path):
    ##
    ## Get the id of an asset pack from an object's resource path
    ##
    var split_path = res_path.split(':')[-1].right(2).split('/')
    if not split_path.size() or split_path[0] != "packs":
        return null
    
    return split_path[1]


func get_asset_pack_name_from_id(pack_id):
    ##
    ## Get the name of an asset pack from it's id
    ##
    for asset_pack in Global.Header.get_AssetManifest():
        if asset_pack.get_ID() == pack_id:
            return asset_pack.get_Name()
    
    return null


func add_pack_source_to_menu():
    ##
    ## Add the name of the asset pack to the tooltip for objects in a menu
    ##

    var obj_menu = Global.Editor.ObjectLibraryPanel.objectMenu
    var lookup = obj_menu.get_Lookup()

    for res_path in lookup.keys():
        var pack_id = get_pack_id_from_res_path(res_path)
        var pack_name = get_asset_pack_name_from_id(pack_id)

        if not pack_name:
            continue
        
        var index = lookup[res_path]

        var new_tip = obj_menu.get_item_tooltip(index) + "\n" + pack_name
        obj_menu.set_item_tooltip(index, new_tip)


func update(delta):
    ##
    ## Called once per tick
    ##
    if Global.Editor.ObjectLibraryPanel.visible:
        var menu_count = Global.Editor.ObjectLibraryPanel.objectMenu.get_item_count()

        if menu_count != prev_menu_count:
            add_pack_source_to_menu()
        prev_menu_count = menu_count


func start():
    ##
    ## Initialize the mod
    ## Called immediately after the script is loaded
    ##
    object_tool = Global.Editor.Tools["ScatterTool"]
