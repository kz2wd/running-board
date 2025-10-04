extends HBoxContainer
class_name ControlChoiceSelector

var selected_index := -1

signal on_selection_change(new_selection: int)

func refresh_children():
	# Register click handlers for all children
	for i in get_child_count():
		var child = get_child(i)
		if child is Control:
			child.gui_input.connect(_on_child_input.bind(i))
			
func _on_child_input(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		select(index)

func select(index: int):
	# Reset old selection
	if selected_index != -1:
		var old = get_child(selected_index)
		_set_selected_style(old, false)
	# Apply new selection
	if selected_index != index:
		on_selection_change.emit(index)
	selected_index = index
	var new = get_child(index)
	_set_selected_style(new, true)


func _set_selected_style(node: Control, selected: bool):
	# Example: highlight with a color, or swap a style
	node.modulate = Color(1, 1, 0.5) if selected else Color.WHITE
