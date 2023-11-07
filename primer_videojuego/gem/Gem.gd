extends Area2D

func pickUp():
	queue_free()


func _on_Gem_area_entered(area):
	if area.is_in_group("enemy"):
		self.position.x = rand_range(20, 470)
		self.position.y = rand_range(20, 700)
