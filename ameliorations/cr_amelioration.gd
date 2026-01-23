extends ColorRect

@export var amelioration: Amelioration

@onready var button: Button = $Button
@onready var label_niveau: Label = $Niveau

func _ready():
	update_affichage()

func _on_button_pressed():
	DonnesJeu.acheter(amelioration)
	update_affichage()

func update_affichage():
	button.update_affichage(amelioration)
	label_niveau.update_affichage(amelioration)
