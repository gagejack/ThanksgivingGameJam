extends CharacterBody2D

# Movement variables
@export var speed: float = 50.0
var run_multiplier: float = 2
var can_collide_with_bridges: bool = false

@onready var Health100 = $HealthBar/Health100
@onready var Health80  = $HealthBar/Health80
@onready var Health50  = $HealthBar/Health50
@onready var Health30  = $HealthBar/Health30
@onready var Health20  = $HealthBar/Health20
@onready var Health10  = $HealthBar/Health10

@onready var sprite = $AnimatedPlayerSprite


@onready var playerHealth = 100
@onready var maxHealth = 100

var has_gun

@onready var anim_sprite = $AnimatedPlayerSprite
var last_direction = Vector2.DOWN  # Track the last direction faced

func shake_sprite(intensity: float, duration: float):
	var original_position = sprite.position
	var shake_timer = 0.0
	
	while shake_timer < duration:
		sprite.position = original_position	 + Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		shake_timer += get_process_delta_time()
		await get_tree().process_frame
	sprite.position = original_position
	


func take_damage(damage):
	playerHealth = max(playerHealth - damage, 0)
	$Camera2D.shake(2.0,0.1) # Shake camera when taking damage
	shake_sprite(3.0,0.15) # Shake 3 pixels for 0.15 seconds
	update_health_bar()

func update_health_bar():
	var ratio = (float(playerHealth) / float(maxHealth))
	
	Health100.visible = ratio >= 0.8
	Health80.visible  = ratio >= 0.6 and ratio < 0.8
	Health50.visible  = ratio >= 0.5 and ratio < 0.6
	Health30.visible  = ratio >= 0.3 and ratio < 0.5
	Health20.visible  = ratio >= 0.2 and ratio < 0.3
	Health10.visible  = ratio < 0.2
	if ratio <= 0:
		Health10.visible = false
		
	print("Player Health: ", playerHealth)



func _ready():
	set_bridge_collision(false)
	Health100.visible = true
	Health80.visible = false
	Health50.visible = false
	Health30.visible = false
	Health20.visible = false
	Health10.visible = false
	
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
			anim_sprite.play("runLeft")
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
