extends Area2D

signal picked
signal hurt

func _ready():
	OS.center_window() # centrar la pantalla
	$AnimatedSprite.play("idle")


func _process(delta):
	if Input.is_action_pressed("ui_left"):
		position.x += -250 * delta
		$AnimatedSprite.flip_h = true
		
	if Input.is_action_pressed("ui_right"):
		position.x += 250 * delta
		$AnimatedSprite.flip_h = false

		
	if Input.is_action_pressed("ui_up"):
		position.y += -250 * delta
		
	if Input.is_action_pressed("ui_down"):
		position.y += 250 * delta
		
	process_animations()
	
	# Limitar el movimiento en X y Y
	position.x = clamp(position.x, 0, 480)
	position.y = clamp(position.y, 0, 720)

func process_animations():
	if Input.is_action_pressed("ui_left") == true:
		$AnimatedSprite.play("run")
	elif Input.is_action_pressed("ui_right") == true:
		$AnimatedSprite.play("run")
	elif Input.is_action_pressed("ui_up") == true:
		$AnimatedSprite.play("run")
	elif Input.is_action_pressed("ui_down") == true:
		$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("idle")
	
func _on_Player_area_entered(area):
	if area.is_in_group("gem"):
		print("Gema encontrada")
		area.pickUp()
		emit_signal("picked")
		$GemAudio.play()
		



func game_over():
	set_process(false)
	$AnimatedSprite.play("hurt")


func _on_Player_body_entered(body):
	if body.is_in_group("enemy"):
		emit_signal("hurt")
