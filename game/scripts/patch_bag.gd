extends Interactable

const PATCH_SCENE := preload("res://scenes/band_aid.tscn")

@export var patches_left: int = 2

func _ready() -> void:
	interacted.connect(_on_interacted)
	_update_prompt()

func _on_interacted(player: Node) -> void:
	if patches_left <= 0:
		return
	if player == null or player.get_held_item_id() != "":
		return

	var hand_slot: Marker3D = player.get_node_or_null("Head/Camera3D/HandSlot")
	if hand_slot == null or hand_slot.get_child_count() > 0:
		return

	var patch := PATCH_SCENE.instantiate() as RigidBody3D
	patch.freeze = true
	patch.collision_layer = 0
	patch.collision_mask = 0

	var inter := patch.get_node_or_null("Interactable") as Interactable
	if inter != null:
		inter.monitoring = false
		inter.monitorable = false
		inter.collision_layer = 0

	hand_slot.add_child(patch)
	patch.position = Vector3.ZERO
	patch.rotation = Vector3.ZERO
	player.set_held_item_id("epoxy_patch")

	patches_left -= 1
	_update_prompt()

func _update_prompt() -> void:
	if patches_left > 0:
		prompt_text = "Take Epoxy Patch (%d)" % patches_left
	else:
		prompt_text = ""
		collision_layer = 0
