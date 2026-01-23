extends CharacterBody2D

signal died()

@export var cible: Node2D
@export var vitesse: float = 100.0
var lvl: int = 1
var pv: float = pow(1.20, lvl) # +20% par lvl
var recompense_points: int = 1 if lvl == 1 else 2 * lvl

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
