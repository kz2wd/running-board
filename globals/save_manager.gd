extends Node

var save_path: String

func _init():
	save_path = "user://default/"
	for arg in OS.get_cmdline_args():
		if arg.begins_with("user://profile"):
			save_path = arg
	
	DirAccess.make_dir_recursive_absolute(save_path)
