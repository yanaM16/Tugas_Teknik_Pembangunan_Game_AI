extends CharacterBody2D

# ---------------- Konfigurasi ----------------
@export var speed: float = 130.0
@export var detection_range: float = 260.0
@export var attack_range: float = 45.0
@export var flee_health_threshold: float = 30.0
@export var attack_cooldown: float = 1.0
@export var attack_damage: float = 10.0

# ---------------- State ----------------
enum State { PATROL, CHASE, ATTACK, FLEE }
var current_state: int = State.PATROL

var health: float = 100.0
var player: Node2D = null
var patrol_points: Array = []
var current_patrol_index: int = 0
var attack_timer: float = 0.0

@onready var state_label: Label = $StateLabel


func _ready() -> void:
	player = get_tree().get_root().find_child("Player", true, false)

	var patrol_container = get_node_or_null("../PatrolPoints")
	if patrol_container:
		for point in patrol_container.get_children():
			patrol_points.append(point.global_position)


func _physics_process(delta: float) -> void:
	# 1. NPC "berpikir" -> jalankan decision tree untuk menentukan state
	current_state = decide_state()

	# 2. NPC "bertindak" sesuai hasil keputusan
	execute_state(delta)

	# 3. Update tampilan label untuk debugging / demo
	if state_label:
		state_label.text = State.keys()[current_state]

	if attack_timer > 0.0:
		attack_timer -= delta


# =====================================================================
# DECISION TREE
# Root: Apakah HP NPC rendah?
#   YA  -> FLEE (menjauh dari player, prioritas bertahan hidup)
#   TIDAK -> Apakah player ada & berapa jaraknya?
#            - jarak <= attack_range      -> ATTACK
#            - jarak <= detection_range   -> CHASE
#            - selain itu                 -> PATROL
# =====================================================================
func decide_state() -> int:
	# Node keputusan 1: cek kondisi HP
	if health <= flee_health_threshold:
		return State.FLEE

	# Jika tidak ada player yang terdeteksi di scene
	if player == null or not is_instance_valid(player):
		return State.PATROL

	var distance: float = global_position.distance_to(player.global_position)

	# Node keputusan 2: cek jarak untuk menyerang
	if distance <= attack_range:
		return State.ATTACK

	# Node keputusan 3: cek jarak untuk mengejar
	if distance <= detection_range:
		return State.CHASE

	# Default: tidak ada kondisi terpenuhi -> patroli
	return State.PATROL


func execute_state(delta: float) -> void:
	match current_state:
		State.PATROL:
			_do_patrol()
		State.CHASE:
			_do_chase()
		State.ATTACK:
			_do_attack()
		State.FLEE:
			_do_flee()


func _do_patrol() -> void:
	if patrol_points.is_empty():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var target: Vector2 = patrol_points[current_patrol_index]
	var to_target: Vector2 = target - global_position

	if to_target.length() < 12.0:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
	else:
		velocity = to_target.normalized() * speed * 0.5

	move_and_slide()


func _do_chase() -> void:
	if player == null:
		return
	var dir: Vector2 = (player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()


func _do_attack() -> void:
	velocity = Vector2.ZERO
	move_and_slide()

	if attack_timer <= 0.0 and player and player.has_method("take_damage"):
		player.take_damage(attack_damage)
		attack_timer = attack_cooldown


func _do_flee() -> void:
	if player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var dir: Vector2 = (global_position - player.global_position).normalized()
	velocity = dir * speed * 1.3
	move_and_slide()


func take_damage(amount: float) -> void:
	health -= amount
	health = max(health, 0.0)
