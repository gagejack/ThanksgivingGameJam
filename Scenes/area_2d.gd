extends Area2D

@onready var bridge_layer = get_parent().get_node("BridgeLayer")

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("set_bridge_collision"):
		var flip_state = !body.on_highGround
		body.set_bridge_collision(flip_state)
		
		print("bridge collision set to:", flip_state)
