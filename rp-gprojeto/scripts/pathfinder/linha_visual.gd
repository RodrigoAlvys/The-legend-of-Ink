extends Line2D

func desenhar_caminho(caminho: Array[Vector2]):
	clear_points()
	for ponto in caminho:
		add_point(ponto)
