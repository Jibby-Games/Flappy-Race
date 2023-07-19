extends Control


func _ready() -> void:
	if not ProjectSettings.get_setting("application/config/debug_tools"):
		hide()
		# Disable processing if not enabled
		set_physics_process(false)
		return
	# Show items with number keys
	var i := 1
	for item in Items.items:
		var debug_key := Button.new()
		debug_key.text = "%d" % i
		debug_key.icon = item.icon
		$HBoxContainer.add_child(debug_key)
		i += 1
	# Populate info container
	var inst = Label.new()
	inst.name = "Distance"
	$InfoContainer.add_child(inst)


func _physics_process(_delta: float) -> void:
	if Globals.client_world:
		$InfoContainer/Distance.text = "Distance to leader: %f" % get_distance_to_leader()


func get_distance_to_leader() -> float:
	var lead_player: CommonPlayer = Globals.client_world.get_lead_player()
	if (
		lead_player == null
		or not is_instance_valid(lead_player)
		or Globals.client_world.current_player == null
		or not is_instance_valid(Globals.client_world.current_player)
	):
		return 0.0
	return lead_player.global_position.x - Globals.client_world.current_player.global_position.x
