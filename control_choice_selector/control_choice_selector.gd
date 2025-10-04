extends HBoxContainer
class_name ControlChoiceSelector

var selected_index := -1

signal on_selection_change(new_selection: int, is_final: bool)

var is_selection_enable: bool = false
var is_hover_enable: bool = false

var other_player_choices: Dictionary[Player, int] = {}
var other_player_final_choices: Dictionary[Player, int] = {}

enum SELECTION_STATE {UNSELECTED, LOCAL_HOVER, LOCAL_CHOICE, REMOTE_HOVER, REMOTE_CHOICE}
var children_states: Dictionary = {}
var selection_state_color_modulation: Dictionary[SELECTION_STATE, Color] = {
	SELECTION_STATE.UNSELECTED: Color.WHITE,
	SELECTION_STATE.LOCAL_HOVER: Color(0.827, 0.878, 0.592, 1.0),
	SELECTION_STATE.LOCAL_CHOICE: Color(0.808, 0.933, 0.933, 1.0),
	SELECTION_STATE.REMOTE_HOVER: Color(0.824, 0.772, 0.791, 0.682),
	SELECTION_STATE.REMOTE_CHOICE: Color(0.307, 0.307, 0.307, 0.651),
}

const CARD = preload("uid://booq1bvduv3ph")

func show_card_choice(board: Board):
	self.visible = true
	for card: Card in board.drawn_cards:
		var cardVisu: CardVisu = CARD.instantiate()
		cardVisu.set_card(card)
		self.add_child(cardVisu)
		

func reset(board: Board):
	for child in get_children():
		child.free()
	
	show_card_choice(board)
	
	_local_reset()
	
	refresh_children_link()

func _local_reset():
	children_states = {}
	for i in get_child_count():
		children_states[i] = [SELECTION_STATE.UNSELECTED] 
	other_player_choices = {}
	other_player_final_choices = {}
	is_hover_enable = true

func enable_selection():
	is_selection_enable = true
	is_hover_enable = true

func refresh_children_link():
	
	# Register click handlers for all children
	for i in get_child_count():
		var child = get_child(i)
		if child is Control:
			child.gui_input.connect(_on_child_input.bind(i))
			
func _on_child_input(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		select(index, true)
	elif event is InputEventMouseMotion:
		select(index, false)

func select(index: int, is_final: bool):
	if index > get_child_count():
		push_warning("Index greater than child count")
		return
	if index in other_player_final_choices.values():
		return
	if not is_hover_enable:
		return
	# Reset old selection
	var old_selection = selected_index
	
	# Apply new selection
	if is_final and is_selection_enable:
		on_selection_change.emit(index, true)
		is_selection_enable = false
		is_hover_enable = false
		_set_selected_style(index, SELECTION_STATE.LOCAL_CHOICE)
	elif selected_index != index: 
		on_selection_change.emit(index, false)
		_set_selected_style(index, SELECTION_STATE.LOCAL_HOVER)
		
	selected_index = index
	
	if old_selection != -1:
		_set_selected_style(old_selection, _get_child_status(old_selection))

func _set_selected_style(index: int, selection_kind: SELECTION_STATE):
	# Example: highlight with a color, or swap a style
	get_child(index).modulate = selection_state_color_modulation[selection_kind]

func _get_child_status(index: int) -> SELECTION_STATE:
	# First handle the final choices
	if index == selected_index:
		if not is_hover_enable:
			# If is hover enable is false, then choice has been made, so it was final
			return SELECTION_STATE.LOCAL_CHOICE
	if index in other_player_final_choices.values():
		return SELECTION_STATE.REMOTE_CHOICE
	# then check for local hover
	if index == selected_index:
		return SELECTION_STATE.LOCAL_HOVER
	if index in other_player_choices.values():
		return SELECTION_STATE.REMOTE_HOVER
		
	return SELECTION_STATE.UNSELECTED

func set_external_choice(player: Player, index: int, is_final: bool):
	if index > get_child_count():
		return
	if other_player_choices.has(player):
		var old_index = other_player_choices[player]
		other_player_choices[player] = index
		_set_selected_style(old_index, _get_child_status(old_index))
	else:
		other_player_choices[player] = index
	
	if is_final:
		other_player_final_choices[player] = index
		_set_selected_style(index, SELECTION_STATE.REMOTE_CHOICE)
	else:
		if index != selected_index:
			_set_selected_style(index, SELECTION_STATE.REMOTE_HOVER)
