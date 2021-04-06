extends Area2D



func _on_Area2D_body_entered(body):
	Global.number_of_dashes += 1
	queue_free()
