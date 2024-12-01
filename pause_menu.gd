extends Control

@export var buttons: Array[Button]

func _ready():
	$AnimationPlayer.play ("RESET")
	hide()

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for button in buttons:
		button.disabled = true

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()
	for button in buttons:
		button.disabled = false

func testEsc():
	if Input.is_action_just_pressed("escape") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused == true:
		resume()


func _on_resume_pressed() -> void:
	resume()


func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(_delta):
	testEsc()
