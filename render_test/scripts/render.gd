## Uses Dungeondraft v1.1.0.0
##
## Toggle Layers v1.0.0
## Author: Avery Berg
## Class for rendering the map & exporting the rendered image 
## 
## Info:
##      Top left corner of map is 0, 0 in global coordinates
##      Size of a bucket: Global.World.get_viewport_rect().size
##      Center of camera: master_cam.get_global_position()
##      World Size: Global.World.get_WorldRect().size
##
##      Number of horizontal buckets = world_size.x / cam_size.x
##      Number of vertical buckets = world_size.y / cam_size.y
##      Starting position: Vector2(0.0, 0.0) + (0.5*cam_size)
##
##      Default Scale is 256 px = 1 grid square = 256 global units 
##

var script_class = "tool"


func start():
    pass

class Render:
    signal scanning(delta_seconds)
    signal scan_started
    signal scan_finished(img)

    var rendered_image = null
    var dest_path = null
    var grid_ppi = 256
    var boost_amount = 1.0
    var state = null

    enum states{
        IDLE,
        SCAN_START,
        SCAN,
        SCAN_FINISHED,
        EXPORT_START,
        EXPORT,
        EXPORT_FINISHED
    }

    var _wait_timer = 0.0

    var _global = null
    var _viewport = null
    var _level = null

    var _world_size = null

    var _render_cam = null
    var _cam_zoom = null
    var _cam_size = null

    var _bucket_size = null
    var _bucket_rect = null
    var _h_bucket_count = null
    var _v_bucket_count = null

    var _render_resolution = null

    var _i = 0
    var _j = 0

    var verbose = false

    func _init(caller, file_path=null, ppi=256, boost=1.0):
        ##
        ## Initialize the render
        ##

        # Assign Global reference
        _global = caller._global
        if not _global is Dictionary:
            _global = caller.Global

        # Print the init message        
        var init_msg = 'Initializing render'
        if file_path:
            init_msg += ' with export path: "' + str(file_path) + '"'
        print(init_msg)

        rendered_image = Image.new()
        dest_path = file_path
        grid_ppi = ppi
        boost_amount = boost

        state = states.IDLE

        _wait_timer = -0.2

        _viewport = _global.Editor.get_viewport()
        _level = _global.World.get_Level()
        _world_size = _global.World.get_WorldRect().size
        _render_cam = _viewport.get_children()[-1].get_Camera()
        
        # TODO: Fix ppi (This is a temp bandaid)
        _cam_zoom = Vector2(256.0 / float(256.0), 256.0 / float(256.0))
        # _cam_zoom = Vector2(256.0 / float(ppi), 256.0 / float(ppi))

        _cam_size = OS.get_window_size() * boost_amount
        _bucket_size = _cam_size * _cam_zoom
        _bucket_rect = Rect2(0, 0, _bucket_size.x, _bucket_size.y)
        _h_bucket_count = ceil(_world_size.x / _bucket_size.x)
        _v_bucket_count = ceil(_world_size.y / _bucket_size.y)
        _render_resolution = _world_size / _cam_zoom
        
        print(' ')
        print('_h_buckets: ' + str(_world_size.x / _bucket_size.x))
        print('_v_buckets: ' + str(_world_size.y / _bucket_size.y))
        print('_h_bucket_count: ' + str(_h_bucket_count))
        print('_v_bucket_count: ' + str(_v_bucket_count))
        print(' ')
        
        _i = 0
        _j = 0
    
    func log_info():
        log('_global: ' + str(_global))
        log('_viewport: ' + str(_viewport))
        log('_level: ' + str(_level))
        log('_world_size: ' + str(_world_size))
        log('_render_cam: ' + str(_render_cam))
        log('_cam_zoom: ' + str(_cam_zoom))
        log('_cam_size: ' + str(_cam_size))
        log('_bucket_size: ' + str(_bucket_size))
        log('_bucket_rect: ' + str(_bucket_rect))
        log('_h_bucket_count: ' + str(_h_bucket_count))
        log('_v_bucket_count: ' + str(_v_bucket_count))
        log('_render_resolution: ' + str(_render_resolution))

    func log(msg):
        if verbose:
            print(msg)

    func export():
        if not state in [states.SCAN_FINISHED, states.EXPORT_START, states.EXPORT_FINISHED]:
            return
        # if not is_complete:
        #     return

        state = states.EXPORT
        
        print('Saving render')
        rendered_image.save_png(dest_path)
        print('Render saved')
        
        state = states.EXPORT_FINISHED

    func stop():
        print('Finished scanning')

        _global.Editor.get_node("VPartition").visible = true
        _global.Editor.get_node("Floatbar").visible = true

        print('Cropping the image')
        rendered_image.crop(_render_resolution.x, _render_resolution.y)

        # TODO: Fix ppi (This is a temp bandaid)
        print('Resizing the image')
        var scalar = grid_ppi / 256.0
        rendered_image.resize(_render_resolution.x * scalar, _render_resolution.y * scalar)

        # Restore the cached viewport size
        print('Unscaling the viewport')
        var scene_tree = _global.Editor.get_tree()
        _viewport.set_size(OS.get_window_size())
        scene_tree.set_screen_stretch(0, 0, OS.get_window_size(), 1)
        
        state = states.SCAN_FINISHED
        emit_signal('scan_finished', rendered_image)
            
    func get_progress_percentage():
        return 100.0 * float(_i + (_j * _h_bucket_count)) / float(_h_bucket_count * _v_bucket_count)

    func _render_bucket():
        log('Rendering bucket')
        var bucket_origin = Vector2(_i, _j) * _bucket_size
        var bucket_pos = bucket_origin + (0.5 * _bucket_size)

        var bucket_render = _viewport.get_texture().get_data()
        bucket_render.convert(Image.FORMAT_RGBA8)
        bucket_render.flip_y()

        rendered_image.blit_rect(bucket_render, _bucket_rect, bucket_origin)
        
        print(str(int(get_progress_percentage())) + '% done')
        
        log('Rendering at position: ' + str(bucket_pos))
    
    func step():
        log('Stepping')
        # Render the current bucket
        _render_bucket()

        # Step
        _i += 1
        if _i >= _h_bucket_count:
            _i = 0
            _j += 1

            # Stop when complete
            if _j >= _v_bucket_count:
                stop()
                return
        
        # Set the position and zoom for the next bucket
        var next_bucket_pos = Vector2(_i+0.5, _j+0.5) * _bucket_size
        _render_cam.set_global_position(next_bucket_pos)
        _render_cam.set_zoom(_cam_zoom)

        log('Set camera position to ' + str(next_bucket_pos))
        log('Finished step')

    func tick(delta):
        if not state in [states.SCAN_START, states.SCAN]:
            return
        
        emit_signal('scanning', delta)
        
        _wait_timer += delta

        if _wait_timer >= 0.0:
            step()
            _wait_timer = 0.0

    func start():
        print('Starting render')
        state = states.SCAN_START

        # Cache the viewport size
        print('Scaling the viewport')
        var scene_tree = _global.Editor.get_tree()
        scene_tree.set_screen_stretch(2, 0, OS.get_window_size(), 1)
        _viewport.set_size(_cam_size)

        emit_signal('scan_started')

        # Hide the UI and Cursor Preview
        _global.World.get_node('WorldUI').set_CursorMode(0)
        _global.Editor.get_node("VPartition").visible = false
        _global.Editor.get_node("Floatbar").visible = false
        
        # Set the initial position and zoom
        _render_cam.set_global_position(0.5 * _bucket_size)
        _render_cam.set_zoom(_cam_zoom)

        rendered_image.create(_bucket_size.x * _h_bucket_count, _bucket_size.y * _v_bucket_count, false, Image.FORMAT_RGBA8)
