extends Area2D



func _on_Area2D_body_entered(body):
	Global.can_wall_run = true
	queue_free()
