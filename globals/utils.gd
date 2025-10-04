extends Node


func generate_uuid_v4() -> String:
	var bytes = PackedByteArray()
	bytes.resize(16)
	for i in range(16):
		bytes[i] = randi() & 0xFF
	
	# Set version bits (0100) in byte 6
	bytes[6] = (bytes[6] & 0x0F) | 0x40
	# Set variant bits (10xx) in byte 8
	bytes[8] = (bytes[8] & 0x3F) | 0x80
	
	return _bytes_to_uuid_string(bytes)

func _bytes_to_uuid_string(bytes: PackedByteArray) -> String:
	var s = ""
	for i in range(16):
		s += "%02x" % bytes[i]
		# insert dashes at positions 3, 5, 7, 9
		if i == 3 or i == 5 or i == 7 or i == 9:
			s += "-"
	return s.to_lower()
	
	
func change_scene_and_run(new_scene: PackedScene, after: Callable):
	get_tree().change_scene_to_packed(new_scene)
	await get_tree().scene_changed
	after.call(get_tree().current_scene)

func log(msg: String):
	print("[" + str(multiplayer.get_unique_id()) + "] " + msg)
