extends CharacterBody2D

# Movement variables
@export var speed: float = 50.0
var run_multiplier: float = 2
var can_collide_with_bridges: bool = false
var on_highGround = false

@onready var Health100 = $HealthBar/Health100
@onready var Health80  = $HealthBar/Health80
@onready var Health50  = $HealthBar/Health50
@onready var Health30  = $HealthBar/Health30
@onready var Health20  = $HealthBar/Health20
@onready var Health10  = $HealthBar/Health10

@onready var SpriteIdle = $SpriteIdle
@onready var SpriteWalk = $SpriteWalk
@onready var SpriteRun = $SpriteRun
@onready var SpriteShooting = $SpriteShooting

@onready var shoot_sound = $AudioStreamPlayer2D

func spriteInvis(state):
	SpriteIdle.visible = !state
	SpriteWalk.visible = !state
	SpriteRun.visible = !state
	SpriteShooting.visible = !state
	
@onready var playerHealth = 100
@onready var maxHealth = 100

var has_gun = true
var is_shooting = false

var last_direction = Vector2.DOWN  # Track the last direction faced

func _ready():
	set_bridge_collision(false)
	Health100.visible = true
	Health80.visible = false
	Health50.visible = false
	Health30.visible = false
	Health20.visible = false
	Health10.visible = false
	spriteInvis(true)
	
func handle_movement_input() -> Dictionary:
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
	
	return {
		"input_vector": input_vector,
		"is_running": is_running
	}

func moveNoGun():
	var movement = handle_movement_input()
	var input_vector = movement["input_vector"]
	var is_running = movement["is_running"]
	
	# Handle animations
	if input_vector != Vector2.ZERO:
		# Update last direction
		last_direction = input_vector.normalized()
		
		var direction = get_direction_string(input_vector)
		
		if is_running:
			# Show only run sprite
			SpriteRun.visible = true
			SpriteWalk.visible = false
			SpriteIdle.visible = false
			SpriteRun.play("run" + direction)
		else:
			# Show only walk sprite
			SpriteWalk.visible = true
			SpriteRun.visible = false
			SpriteIdle.visible = false
			SpriteWalk.play("walk" + direction)
	else:
		# Show only idle sprite
		SpriteIdle.visible = true
		SpriteWalk.visible = false
		SpriteRun.visible = false
		
		var direction = get_direction_string(last_direction)
		SpriteIdle.play("idle" + direction)

func moveWithGun():
	var movement = handle_movement_input()
	var input_vector = movement["input_vector"]
	var is_running = movement["is_running"]
	
	# Determine aim direction based on mouse position
	var mouse_pos = get_global_mouse_position()
	var aim_direction = global_position.direction_to(mouse_pos)
	
	# Check if shooting (holding button down)
	if Input.is_action_pressed("shoot"):
		if not is_shooting:
			shoot(aim_direction)
		# Update shooting direction while shooting
		var direction = get_direction_string(aim_direction)
		var anim_prefix = "runShooting" if is_running else "shooting"
		
		SpriteShooting.play(anim_prefix + direction)
		
	else:
		# Stop shooting when button released
		if is_shooting:
			is_shooting = false
			SpriteShooting.visible = false
	
	# Handle movement animations (only if not shooting)
	if not is_shooting:
		if input_vector != Vector2.ZERO:
			# Update last direction
			last_direction = input_vector
			
			var direction = get_direction_string(aim_direction)
			
			if is_running:
				SpriteRun.visible = true
				SpriteWalk.visible = false
				SpriteIdle.visible = false
				SpriteRun.play("runGun" + direction)
			else:
				SpriteWalk.visible = true
				SpriteRun.visible = false
				SpriteIdle.visible = false
				SpriteWalk.play("walkGun" + direction)
		else:
			SpriteIdle.visible = true
			SpriteWalk.visible = false
			SpriteRun.visible = false
			
			var direction = get_direction_string(aim_direction)
			SpriteIdle.play("idleGun" + direction)

func shoot(aim_dir: Vector2):
	is_shooting = true
	
	# Hide all movement sprites
	SpriteIdle.visible = false
	SpriteWalk.visible = false
	SpriteRun.visible = false
	
	# Show shooting sprite
	SpriteShooting.visible = true
	
	var direction = get_direction_string(aim_dir)
	
	# Check if running
	var is_running = Input.is_action_pressed("Run")
	var anim_prefix = "runShooting" if is_running else "shooting"
	
	SpriteShooting.play(anim_prefix + direction)
	
func _physics_process(delta: float) -> void:
	if has_gun:
		moveWithGun()
	else: 
		moveNoGun()
		
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

#--------------------------------------------------------------------------------

func shake_sprite(intensity: float, duration: float):
	var original_idle_pos = SpriteIdle.position
	var original_walk_pos = SpriteWalk.position
	var original_run_pos = SpriteRun.position
	var shake_timer = 0.0
	
	while shake_timer < duration:
		var shake_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		
		SpriteIdle.position = original_idle_pos + shake_offset
		SpriteWalk.position = original_walk_pos + shake_offset
		SpriteRun.position = original_run_pos + shake_offset
		
		shake_timer += get_process_delta_time()
		await get_tree().process_frame
	
	SpriteIdle.position = original_idle_pos
	SpriteWalk.position = original_walk_pos
	SpriteRun.position = original_run_pos
#---------------------------------------------------------------------------------
