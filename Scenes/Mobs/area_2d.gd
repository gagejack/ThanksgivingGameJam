extends Area2D

var player 
var orc
var attackDamage
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("/root/Game/Player")
	orc = get_parent().get_parent()
	attackDamage = orc.attackDamage

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(orc.attackDamage)
		
		print("Damge Taken:", orc.attackDamage)
		print("New Health: ", body.playerHealth)
