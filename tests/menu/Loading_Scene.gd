extends CanvasLayer

@export_file("*.tscn") var next_scene_path: String #Determines which scene file to load

func _ready():
	$Control/Node2D.hide()
	$AnimationPlayer.play("fade_in")
	await  get_tree().create_timer(2.2).timeout
	$Control/Node2D.show()
	$AnimationPlayer.play("loading")
	$Control/Node2D/bob.play("default")
	$Control/Node2D/warrior.play("default")
	ResourceLoader.load_threaded_request(next_scene_path)

func _process(_delta):
	
	$Control/Node2D.rotation_degrees += 25 * _delta
	
	var loader =  ResourceLoader.load_threaded_get_status(next_scene_path)
	if loader == 3:#ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false)
		await get_tree().create_timer(3).timeout
		var new_scene: PackedScene = ResourceLoader.load_threaded_get(next_scene_path)
		await get_tree().create_timer(5).timeout
		get_tree().change_scene_to_packed(new_scene)
		print("completed loading in scene")
	elif loader == 2 : #THREAD_LOAD_FAILED
		# handle your error
		print("error occured while loading chuncks of data")
		return
	elif loader == 1 : #THREAD_LOAD_IN_PROGRESS
		await get_tree().create_timer(1).timeout
		print("#THREAD_LOAD_IN_PROGRESS")
		return
	elif loader == 0 : #THREAD_LOAD_INVALID_RESOURCE
		# handle your error
		print("error occured while getting the scene")
		print("The resource is invalid, or has not been loaded with load_threaded_request().")
		return
	else:
		print("unknown error")
