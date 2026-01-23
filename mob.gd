extends CharacterBody2D

signal died()

# façon hardcodée : faut faire ça car ça attend que le chargement soit fait
#@onready var player = $"/root/Jeu/Joueur"
@export var cible: Node2D

var pv = 10.0

func _ready() -> void:
	#%Slime.play_walk()
	pass

func _physics_process(delta: float) -> void:
	if cible == null:
		return

	var direction = global_position.direction_to(cible.global_position)
	velocity = direction * 300.0
	# CA FAIT DELTA tout seul je crois
	move_and_slide()

func take_damage(degats: int):
	pv -= degats
	#%Slime.play_hurt()
	if pv <= 0.0:
		die()

func die():
	died.emit(self)
	queue_free()

func points_recompense():
	const POINTS_RECOMPENSE = 1
	
	return POINTS_RECOMPENSE
