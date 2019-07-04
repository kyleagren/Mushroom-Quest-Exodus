extends Area2D

export var popup_text = "Hello"


func _on_TutorialBox_body_entered(body):
	$Popup/Label.text = popup_text
	$Popup.popup_centered()
	

func _on_TutorialBox_body_exited(body):
	$Popup.hide()
