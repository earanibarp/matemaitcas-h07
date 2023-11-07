extends KinematicBody2D


export (int) var gravity_power 
export (int) var jump_power
export (int) var speed 

var velocity = Vector2.ZERO # Vector2(0,0)

enum {IDLE, CROAK, JUMP, FALL}

var state
var current_animation
var new_animation

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
	$JumpTimer.wait_time = rand_range(4,6)
	$JumpTimer.start()
	transition_to(IDLE)


func set_timer_interval():
	var interval = rand_range(2, 4)
	$Timer.wait_time = interval
	$Timer.start()
	


func _physics_process(delta):
	
	velocity.y += gravity_power * delta
	velocity = move_and_slide(velocity, Vector2.UP) # Vector2(0,-1) -> UP
	
	if new_animation != current_animation:
		current_animation = new_animation
		$AnimationPlayer.play(current_animation)
		
	if not is_on_floor() and velocity.y > 0:
		transition_to(FALL)
	if is_on_floor() and state == FALL:
		transition_to(IDLE)
		
	if not is_on_floor():
		velocity.x = speed
	else:
		velocity.x = 0
	
	if speed > 0:
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
	


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "croak":
		transition_to(IDLE)


func _on_JumpTimer_timeout():
	$JumpTimer.stop()
	if state == IDLE:
		update_speed_direction()
		velocity.y = jump_power
		transition_to(JUMP)
	set_timer_interval()

func update_speed_direction():
	var pulso = bool(randi()%2) # bool = 0 / bool = 1
	if pulso == true:
		speed = speed * 1
	else:
		speed = speed * -1
