extends TextureRect

@export var id_amelioration: DonnesJeu.AMELIORATION

@onready var amelioration: Amelioration = DonnesJeu.amelioration_pour(id_amelioration)
@onready var button: Button = $Button
@onready var label_niveau: Label = $Niveau

func _ready():
	DonnesJeu.update_points.connect(_on_update_points)
	
	button.pressed.connect(_on_button_pressed)
	
	update_affichage()

func _on_button_pressed():
	DonnesJeu.acheter(amelioration)
	update_affichage()

func update_affichage():
	button.update_affichage(amelioration)
	label_niveau.update_affichage(amelioration)

func _on_update_points():
	update_affichage()
