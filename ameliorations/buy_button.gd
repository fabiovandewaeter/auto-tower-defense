extends Button

@export var amelioration: Amelioration

func _ready():
	text = amelioration.nom + " (" + str(amelioration.cout_de_base) + " golds)"

func _on_pressed():
	print("TEST")
	DonnesJeu.acheter(amelioration)
