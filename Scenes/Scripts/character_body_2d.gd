extends CharacterBody2D

# Movement variables
@export var speed: float = 75.0

@onready var anim_sprite = $AnimatedSprite2D
var last_direction = Vector2.DOWN  # Track the last direction faced

func _physics_process(delta: float) -> void:
	# Get input direction
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("Left", "Right")
	input_vector.y = Input.get_axis("Up", "Down")
	
	# Normalize diagonal movement so player doesn't move faster diagonally
	input_vector = input_vector.normalized()
	
	# Apply constant velocity
	velocity = input_vector * speed
	
	# Move the character
	move_and_slide()
	
	# Handle animations
	if input_vector != Vector2.ZERO:
		# Update last direction
		last_direction = input_vector
		
		# Determine direction and play corresponding animation
		if abs(input_vector.x) > abs(input_vector.y):
			# Moving more horizontally
			if input_vector.x > 0:
				anim_sprite.play("WalkRight")
			else:
				anim_sprite.play("WalkLeft")
		else:
			# Moving more vertically
			if input_vector.y > 0:
				anim_sprite.play("WalkDown")
			else:
				anim_sprite.play("WalkUp")
	else:
		# Play idle animation based on last direction faced
		if abs(last_direction.x) > abs(last_direction.y):
			if last_direction.x > 0:
				anim_sprite.play("IdleRight")
			else:
				anim_sprite.play("IdleLeft")
		else:
			if last_direction.y > 0:
				anim_sprite.play("IdleDown")
			else:
				anim_sprite.play("IdleUp")
