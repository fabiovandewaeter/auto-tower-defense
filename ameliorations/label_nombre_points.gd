extends Label

func _ready():
	DonnesJeu.update_points.connect(_on_update_points)
	text = "Gold: " +  str(DonnesJeu.points)

func _on_update_points():
	text = "Gold: " + str(DonnesJeu.points)
