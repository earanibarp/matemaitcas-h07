extends KinematicBody2D

const SPEED = 50

var velocity = Vector2(-SPEED, 0)
var side_lenght = OS.window_size.x * 0.5
onready var camera = get_parent().get_parent().get_node("Player/Camera2D")

func _ready():
	$AnimationPlayer.play("walk")
	#Efecto Tween
	$Tween.interpolate_property(
		$Sprite,
		'modulate',
		Color(1,1,1,1),
		Color(1,1,1,0),
		1.0, Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	
func _physics_process(delta):
	# Comprobar si gomba se encuentra en los límites de la cámara
	if position.x - 8 < (camera.get_camera_screen_center().x + side_lenght) && position.x + 8 > (camera.get_camera_screen_center().x - side_lenght):
		move_and_slide(velocity, Vector2.UP)
		
	#Verificar si goomba está en el suelo
	if is_on_floor():
		velocity.y = 0
	else:
		#Aplicar gravedad
		velocity.y += 1000 * delta
	
	# Cambiar de dirección a goomba cuando se encuentre contra la pared
	if is_on_wall():
		velocity.x = -velocity.x


func _on_AreaCrush_body_entered(body):
	if body.velocity.y > 0 && body.is_in_group("player"):
		get_parent().get_parent().points += 200
		velocity.x = 0
		$AnimationPlayer.play("die")
		$Tween.start()
		yield($Tween, "tween_completed")
		queue_free()



func _on_AreaHit_body_entered(body):
	if body.is_in_group("player") && velocity.x != 0:
		print("Mario muere!")
		body.game_over()
