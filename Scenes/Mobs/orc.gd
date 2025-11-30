extends CharacterBody2D

@onready var player = get_node("/root/Game/Player")
@export var speed = 100

func _physics_process(delta: float) -> void:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
