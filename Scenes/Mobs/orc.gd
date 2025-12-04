extends CharacterBody2D
@onready var player = get_node("/root/Game/Player")
@export var speed = 50
@export var push_force = 80  # Force to push away from player
var attack_range = 25
var min_distance = 20  # Minimum distance to maintain from player
var attackDamage = 20
var mobHealth = 100
@onready var anim_sprite = $AnimatedOrc2D
@onready var anim_player = get_node("Weapon/AnimationPlayer")
var lastDirection = Vector2.DOWN

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	var distanceFromPlayer = global_position.distance_to(player.global_position)
	
	# Update last direction if moving
	if direction != Vector2.ZERO:
		lastDirection = direction
	
	# Movement logic with push-back
	if distanceFromPlayer > attack_range:
		# Move toward player
		velocity = direction * speed
		play_walk_animation(direction)
	elif distanceFromPlayer < min_distance:
		# Too close - push away from player
		velocity = -direction * push_force
		play_walk_animation(-direction)
	else:
		# In attack range - stop and attack
		velocity = Vector2.ZERO
		play_idle_animation(lastDirection)
		if not anim_player.is_playing():
			attack()
	
	move_and_slide()
	
	# Additional push-back if colliding with player
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == player:
			# Push away from player
			var push_dir = global_position.direction_to(player.global_position)
			velocity = -push_dir * push_force
			break

func take_damage(damage):
	mobHealth = max(mobHealth - damage, 0)
	print(mobHealth)
	# $Camera2D.shake(2.0,0.1) # Shake camera when taking damage
	# shake_sprite(3.0,0.15) # Shake 3 pixels for 0.15 seconds
	
func play_walk_animation(dir: Vector2):
	# Determine which direction is dominant
	if abs(dir.x) > abs(dir.y):
		# Horizontal movement is dominant
		if dir.x > 0:
			anim_sprite.play("walkRight")
		else:
			anim_sprite.play("walkLeft")
	else:
		# Vertical movement is dominant
		if dir.y > 0:
			anim_sprite.play("walkDown")
		else:
			anim_sprite.play("walkUp")

func play_idle_animation(dir: Vector2):
	# Determine which direction is dominant
	if abs(dir.x) > abs(dir.y):
		# Horizontal direction is dominant
		if dir.x > 0:
			anim_sprite.play("idleRight")
		else:
			anim_sprite.play("idleLeft")
	else:
		# Vertical direction is dominant
		if dir.y > 0:
			anim_sprite.play("idleDown")
		else:
			anim_sprite.play("idleUp")
		
func attack():
	anim_player.play("swingSword")
	$Weapon/Area2D.monitoring = true # turns on sword hitbox
	
	await anim_player.animation_finished # need to make this turn monitoring false when sword is swung once, not on return animation.
	$Weapon/Area2D.monitoring = false # turn off sword hitbox
