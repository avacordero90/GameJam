extends Node
## Thin wrapper around SceneTree scene switching so callers don't need to
## know about change_scene_to_file's error codes or unpause the tree
## themselves when leaving a paused scene.

signal scene_changed(scene_path: String)

var current_scene_path: String = ""


func change_scene(path: String) -> void:
	get_tree().paused = false
	var error := get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("SceneManager: failed to change scene to %s (error %d)" % [path, error])
		return
	current_scene_path = path
	scene_changed.emit(path)
