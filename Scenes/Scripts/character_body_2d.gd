extends CharacterBody2D

# Movement variables
@export var speed: float = 100.0
@export var run_multiplier: float = 2.5
@export var can_collide_with_bridges: bool = false

@onready var anim_sprite = $AnimatedSprite2D
var last_direction = Vector2.DOWN  # Track the last direction faced



func _physics_process(delta: float) -> void:
	# Get input direction
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("Left", "Right")
	input_vector.y = Input.get_axis("Up", "Down")
	
	# Calculate speed with run
	var current_speed = speed
	var is_running = Input.is_action_pressed("Run")
	if is_running:
		current_speed *= run_multiplier
	
	# Apply velocity
	velocity = input_vector * current_speed
	
	# Move the character
	move_and_slide()
	
	# Handle animations
	if input_vector != Vector2.ZERO:
		# Update last direction
		last_direction = input_vector.normalized()
		
		var direction = get_direction_string(input_vector)

		# --- ONLY flip runRight to act as runLeft ---
		if is_running and direction == "Right":
			anim_sprite.flip_h = true
			anim_sprite.play("runRight")
		else:
			anim_sprite.flip_h = false
			var anim_prefix = "run" if is_running else "walk"
			anim_sprite.play(anim_prefix + direction)
		# -------------------------------------------

	else:
		var direction = get_direction_string(last_direction)
		anim_sprite.play("idle" + direction)


func get_direction_string(dir: Vector2) -> String:
	# Normalize to ensure consistent angle calculations
	dir = dir.normalized()
	
	# Calculate angle in degrees (0 = right, 90 = down, 180 = left, 270 = up)
	var angle = rad_to_deg(dir.angle())
	
	# Adjust angle to be 0-360
	if angle < 0:
		angle += 360
	
	# Determine 8-directional movement based on angle ranges
	if angle >= 337.5 or angle < 22.5:
		return "Right"
	elif angle >= 22.5 and angle < 67.5:
		return "RightDown"
	elif angle >= 67.5 and angle < 112.5:
		return "Down"
	elif angle >= 112.5 and angle < 157.5:
		return "LeftDown"
	elif angle >= 157.5 and angle < 202.5:
		return "Left"
	elif angle >= 202.5 and angle < 247.5:
		return "LeftUp"
	elif angle >= 247.5 and angle < 292.5:
		return "Up"
	else:  # 292.5 to 337.5
		return "RightUp"

var on_highGround := false

func set_bridge_collision(highGround: bool):
	on_highGround = highGround
	
	if highGround:
		# walking ON the bridge
		collision_mask = 1 | 2
		z_index = 3
	else:
		# walking UNDER the bridge
		collision_mask = 1
		z_index = 1
