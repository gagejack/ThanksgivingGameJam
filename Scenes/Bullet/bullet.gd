extends Area2D

var velocity: Vector2 = Vector2.ZERO
var speed: float = 300.0
var damage: int = 10
var shooter = null  # Reference to who fired the bullet

func _ready():
	# Connect the body_entered signal to detect collisions
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Set up collision layers
	# OPTION 1: Bullets hit walls and enemies
	collision_layer = 4  # This bullet exists on layer 3 (bit 2)
	collision_mask = 3   # Can hit layer 1 (walls) and layer 2 (enemies)
	

	print("Bullet spawned at: ", global_position)

func set_direction(direction: Vector2, bullet_speed: float, from = null):
	velocity = direction.normalized() * bullet_speed
	speed = bullet_speed
	shooter = from
	
	print("Bullet velocity set to: ", velocity)
	print("Bullet speed: ", bullet_speed)
	
	# Optional: Rotate bullet sprite to match direction
	rotation = direction.angle()

func _physics_process(delta: float):
	position += velocity * delta
	print("Bullet position: ", position, " Velocity: ", velocity)

func _on_body_entered(body):
	print("Bullet hit body: ", body.name)
	
	# Don't hit the shooter
	if body == shooter:
		print("Hit shooter, ignoring")
		return
		
	# Handle collision with bodies (walls, enemies, etc.)
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	print("Destroying bullet")
	queue_free()  # Destroy bullet

func _on_area_entered(area):
	print("Bullet hit area: ", area.name)
	
	# Don't hit the shooter
	if area == shooter:
		print("Hit shooter area, ignoring")
		return
		
	# Handle collision with other areas if needed
	if area.has_method("take_damage"):
		area.take_damage(damage)
	
	print("Destroying bullet")
	queue_free()  # Destroy bullet

# Optional: Auto-destroy bullet after some time to prevent memory leaks
func _on_timer_timeout():
	queue_free()
