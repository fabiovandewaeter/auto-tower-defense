# mob.gb
extends CharacterBody2D

signal died()

@export var cible: Node2D
@export var vitesse: float = 100.0
@export var sprite_faces_right: bool = true

@onready var animation_black_walk = $Node2D/AnimatedSprite2D

var lvl: int = 1 : set = set_lvl
var pv_de_base: float = 10.0
var pv: float = pv_de_base
var recompense_points: int = 1

func _ready() -> void:
	animation_black_walk.play()
	_update_sprite_dir()

func set_lvl(new_lvl: int):
	lvl = new_lvl
	pv = pv_de_base * pow(1.20, lvl) # +20% par lvl
	recompense_points = 1 if lvl == 1 else 3 * lvl

func _update_sprite_dir() -> void:
	if cible == null:
		return
	_update_sprite_dir_from_vector(cible.global_position - global_position)

func _update_sprite_dir_from_vector(direction: Vector2) -> void:
	# tolérance pour éviter des flips quand on est presque vertical
	const HORIZONTAL_THRESHOLD := 0.2
	if abs(direction.x) < HORIZONTAL_THRESHOLD:
		return

	var facing_right := direction.x > 0
	# si ton sprite "regarde à droite" par défaut -> flip_h = not facing_right
	# sinon (sprite regarde gauche par défaut) -> flip_h = facing_right
	animation_black_walk.flip_h = (not facing_right) if sprite_faces_right else facing_right


func _physics_process(delta: float) -> void:
	if cible == null:
		return
	var direction = global_position.direction_to(cible.global_position)
	velocity = direction * vitesse
	# CA FAIT DELTA tout seul je crois
	move_and_slide()

func take_damage(degats: float):
	pv -= degats
	if pv <= 0.0:
		die()

func die():
	died.emit(self)
	queue_free()
