extends CharacterBody2D

@export var speed: float = 220.0

var health: float = 100.0

func _physics_process(_delta):
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()

func take_damage(amount: float) -> void:
	health -= amount
	health = max(health, 0.0)
