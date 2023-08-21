## Uses Dungeondraft v1.1.0.0
##
## Toggle Layers v1.0.0
## Author: Avery Berg
##
## Manage the execution of render submissions
##

var script_class = "tool"


func start():
    pass

class Renderer:
    extends Node

    # signal _render_tick(delta_seconds)

    var _global = null
    var Render = null
    
    var mutex
    var exit_thread

    var current_render

    var render_queue = []
    var render_counter
    var render_counter_b
    var render_semaphore
    var render_semaphore_b
    var render_thread

    # var export_queue = []
    # var export_counter
    # var export_semaphore
    # var export_thread

    var num_export_threads

    var export_queues = []
    var export_counters = []
    var export_semaphores = []
    var export_threads = []

    var verbose = false

    func _init(caller):
        ##
        ## Initialize the Renderer
        ##
        
        verbose = false

        log('Initializing the renderer')

        # Assign Global reference
        _global = caller._global
        if not _global is Dictionary:
            _global = caller.Global
        
        log('Global reference: ' + str(_global))
        
        # Load the render class
        Render = load(_global.Root + "scripts/render.gd").new().Render
        
        log('Render Class: ' + str(Render))
        
        mutex = Mutex.new()
        exit_thread = false

        current_render = null

        render_counter = 0
        render_counter_b = 0
        render_semaphore = Semaphore.new()
        render_semaphore_b = Semaphore.new()
        render_thread = Thread.new()
        render_thread.start(self, '_render_thread_run')
        
        # Post the second render semaphore since no render is currently running
        _finished_scan()
        
        num_export_threads = 3

        for i in range(num_export_threads):
            export_queues.append([])
            export_counters.append(0)
            export_semaphores.append(Semaphore.new())
            export_threads.append(Thread.new())
            export_threads[i].start(self, '_export_thread_run', i)

    func _notification(what):
        if what == NOTIFICATION_PREDELETE:
            # Object is being deleted
            _cleanup()
        
        # Call the parent's _notification() function
        # super._notification(what)
    
    func log(msg):
        if verbose:
            print(msg)

    func _cleanup():
        # Thread must be disposed (or "joined"), for portability

        # Set exit condition to true
        mutex.lock()
        exit_thread = true # Protect with Mutex
        mutex.unlock()

        # Unblock by posting threads
        for export_semaphore in export_semaphores:
            export_semaphore.post()
        render_semaphore_b.post()
        render_semaphore.post()

        # Wait until the threads exit
        for export_thread in export_threads:
            export_thread.wait_to_finish()
        render_thread.wait_to_finish()

        # Print the counters
        log('Render counter is: ' + str(render_counter))
        log('Render counter b is: ' + str(render_counter_b))
        for i in range(export_counters):
            log('Export counter ' + str(i) + ' is: ' + str(export_counters[i]))
    
    func submit(new_render):
        render_queue.append(new_render)
        _start_render()

    func submit_render(file_path, ppi=256):
        var new_render = Render.new(self, file_path, ppi)
        render_queue.append(new_render)
        _start_render()

    func export_image(img, file_path):
        ##
        ## Allow the user to export an image on the renderer's export thread
        ##
        var new_render = Render.new(self, file_path)
        new_render.state = Render.states.SCAN_FINISHED
        new_render.rendered_image = img
        new_render.dest_path = file_path
        render_queue.append(new_render)
        _start_render()
    
    func tick(delta):
        var is_scan_complete = false

        # Protect the current render
        mutex.lock()
        if current_render:
            current_render.tick(delta)
            # log('   state: ' + str(current_render.state))
            is_scan_complete = current_render.state == Render.states.SCAN_FINISHED
        mutex.unlock()

        if is_scan_complete:
            _finished_scan()
    
    func _finished_scan():
        render_semaphore_b.post() # Make the thread process.

    func _start_render():
        render_semaphore.post() # Make the thread process.        

    func _start_export(index):
        export_semaphores[index].post() # Make the thread process.

    func _get_index_of_smallest_export_queue():
        ##
        ## Get the index of the smallest export queue
        ## Lock the mutex before calling this method
        ##
        var min_index = 0
        var min_size = null
        log('Getting index of smalles export queue')

        for i in range(export_queues.size()-1, -1, -1):
            var cur_size = export_queues[i].size()
            if min_size == null or cur_size <= min_size:
                min_size = cur_size
                min_index = i

        return min_index

    func get_render_counter():
        # Copy counter, protect with Mutex.
        mutex.lock()
        var counter_value = render_counter
        mutex.unlock()
        return counter_value
        
    func get_export_counter(index):
        # Copy counter, protect with Mutex.
        mutex.lock()
        var counter_value = export_counters[index]
        mutex.unlock()
        return counter_value
  
    func _render_thread_run():
        while true:
            # Wait until render is finished before starting another
            render_semaphore_b.wait()
            
            log('Posted Render Semaphore B')

            mutex.lock()
            var export_index = _get_index_of_smallest_export_queue()
            log('Smallest queue: ' + str(export_index))
            var do_export = false

            if current_render and current_render.dest_path:
                current_render.state = Render.states.EXPORT_START
                print('Appending current render to export queue ' + str(export_index))
                export_queues[export_index].append(current_render)
                do_export = true
            current_render = null
            mutex.unlock()
            
            # Start exporting the completed render
            if do_export:
                print('Telling export queue ' + str(export_index) + ' to start an export when ready')
                _start_export(export_index)

            mutex.lock()
            render_counter_b += 1
            mutex.unlock()

            # Wait until posted
            render_semaphore.wait()

            log('Posted Render Semaphore')

            var should_exit = false
    
            # Protect render_queue and exit_thread with Mutex
            mutex.lock()
            if render_queue.size():
                current_render = render_queue.pop_back()
                if current_render.state != Render.states.SCAN_FINISHED:
                    current_render.start()
            should_exit = exit_thread
            mutex.unlock()

            # Increment the render counter
            mutex.lock()
            render_counter += 1
            mutex.unlock()

            if should_exit:
                break

    func _export_thread_run(index):
        while true:
            export_semaphores[index].wait() # Wait until posted.

            log('Posted Export Semaphore')

            var render_to_export = null
    
            # Protect export_queue and exit_thread with Mutex
            mutex.lock()
            log('Getting the render to export from the queue')
            log('Export queue: ' + str(export_queues[index]))
            if export_queues[index].size():
                render_to_export = export_queues[index].pop_back()
            var should_exit = exit_thread
            mutex.unlock()
    
            if render_to_export:
                log('Exporting render: ' + str(render_to_export))
                render_to_export.export()
    
            if should_exit:
                break
    
            mutex.lock()
            export_counters[index] += 1 # Increment counter, protect with Mutex.
            mutex.unlock()
