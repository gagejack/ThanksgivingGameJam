extends CharacterBody2D

@onready var player = get_node("/root/Game/Player")
@export var speed = 50
var attack_range = 25
var attackDamage = 20

@onready var anim_sprite = $AnimatedOrc2D

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	var distanceFromPlayer = global_position.distance_to(player.global_position)
	
	if distanceFromPlayer > 15:
		velocity = direction * speed
		move_and_slide()
		
	if distanceFromPlayer <= attack_range and not $AnimationPlayer.is_playing():
		attack()

	# Handle Animations
	if direction != Vector2.ZERO:
		if direction.x < 0:
			anim_sprite.flip_h = true   # Face left
		else:
			anim_sprite.flip_h = false  # Face right
		anim_sprite.play("run")
		
func attack():
	$AnimationPlayer.play("swing")
	$Weapon/Area2D.monitoring = true # turns on sword hitbox
	await $AnimationPlayer.animation_finished
	$Weapon/Area2D.monitoring = false # turn off sword hitbox
