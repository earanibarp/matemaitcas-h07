extends KinematicBody2D


export (int) var gravity_power 
export (int) var jump_power
export (int) var speed 

var velocity = Vector2.ZERO # Vector2(0,0)

enum {IDLE, CROAK, JUMP, FALL}

var state # para guardar el estado de enum
var current_animation # para guardar la animación actual
var new_animation # para guardar la nueva animación en caso haya cambiado

func transition_to(new_state):
	state = new_state
	match (state):
		IDLE:
			new_animation = "idle"
		CROAK:
			new_animation = "croak"
		JUMP:
			new_animation = "jump"
		FALL:
			new_animation = "fall"


func _ready():
	randomize()
	set_timer_interval()
	$JumpTimer.wait_time = rand_range(4,6) # Intervalo de tiempo para la ejecución de la animación JUMP
	$JumpTimer.start()
	transition_to(IDLE)


func set_timer_interval():
	var interval = rand_range(2, 4) # Intervalo de tiempo para la ejecución de la animación CROAK
	$Timer.wait_time = interval
	$Timer.start()


func _physics_process(delta):
	
	velocity.y += gravity_power * delta # Para que el enemigo caiga
	velocity = move_and_slide(velocity, Vector2.UP) # Vector2(0,-1) -> UP
	
	if new_animation != current_animation:
		current_animation = new_animation
		$AnimationPlayer.play(current_animation)
		
	if not is_on_floor() and velocity.y > 0: # Si el enemigo no está en piso y se encuentra cayendo
		transition_to(FALL)
	if is_on_floor() and state == FALL: # si el enemigo se encuentra en el piso y acaba de caer
		transition_to(IDLE)
		
	if not is_on_floor(): # para asignarle movimiento al enemigo cuando salte
		velocity.x = speed
	else:
		velocity.x = 0
	
	if speed > 0: # para voltear la figura cuando sea positiva
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false


func _on_Timer_timeout():
	$Timer.stop()
	#$AnimationPlayer.play("croak")
	if state == IDLE:
		transition_to(CROAK)
	#Animación de jump
	$JumpTimer.wait_time = rand_range(4,6)
	$JumpTimer.start()
	


func _on_AnimationPlayer_animation_finished(anim_name): # cuando la animacion croak termine se ejecutará idle
	if anim_name == "croak":
		transition_to(IDLE)


func _on_JumpTimer_timeout():
	$JumpTimer.stop()
	if state == IDLE:
		update_speed_direction() # para cambiar la dirección del salto
		velocity.y = jump_power
		transition_to(JUMP)
	set_timer_interval()

func update_speed_direction():
	var pulso = bool(randi()%2) # bool = 0 (true) / bool = 1 (false)
	if pulso == true:
		speed = speed * 1 # salta a la derecha 
	else:
		speed = speed * -1 # salta a la izquierda
