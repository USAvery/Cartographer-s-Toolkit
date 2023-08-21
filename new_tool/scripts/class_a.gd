## Uses Dungeondraft v1.1.0.0
##
## Blank v1.0.0
## Author: Avery Berg
## 
## TODO: Description
##

# Required Globals
var script_class = "tool"
var _global = null

# External Scripts
var utils = null

func print_vars():
    print("utils: " + str(utils))
    print("Global: " + str(Global))

func init(caller):
    # print("Loading utils in class a")
    _global = caller.Global
    utils = load(_global.Root + "scripts/utils.gd").new()
    # print("Loaded utils in Class A")

func start():
    ##
    ## Called immediately after the script is loaded
    ##
    pass
