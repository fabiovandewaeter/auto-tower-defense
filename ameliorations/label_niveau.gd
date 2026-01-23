extends Label

func update_affichage(amelioration: Amelioration):
	text = "Lvl " + str(amelioration.lvl_actuel)
