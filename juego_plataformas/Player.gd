extends KinematicBody2D

var speed = 150
var speed_acelerate = 225
var velocity = Vector2.ZERO
var jump_s = -100
var jump_b = -250
var gravity = 500 

enum {IDLE, RUN, JUMP, DIE}
var state
var current_animation
var new_animation

func transition_to(new_state):
	state = new_state
	match state:
		IDLE:
			new_animation = "idle"
		RUN:
			new_animation = "run"
		JUMP:
			new_animation = "jump"
		DIE:
			new_animation = "die"

func _ready():
	transition_to(IDLE)

func _physics_process(delta):
	if current_animation != new_animation:
		current_animation = new_animation
		$AnimatedSprite.play(current_animation)
	
	velocity.y += gravity * delta
	velocity.x = 0
	
	if Input.is_action_pressed("ui_left"):
		velocity.x += -speed
		$AnimatedSprite.flip_h = true
	elif Input.is_action_pressed("ui_right"):
		velocity.x += speed
		$AnimatedSprite.flip_h = false
		
	if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_left_acelerate"):
		velocity.x += -speed_acelerate
		$AnimatedSprite.flip_h = true
	elif Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_right_acelerate"):
		velocity.x += speed_acelerate
		$AnimatedSprite.flip_h = false
		
	if is_on_floor() and Input.is_action_pressed("ui_up"):
		velocity.y = jump_s
		transition_to(JUMP)
		
	if is_on_floor() and Input.is_action_just_pressed("ui_up_big"):
		velocity.y = jump_b
		transition_to(JUMP)
		
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if state == JUMP and is_on_floor():
		transition_to(IDLE)
		
	if state == IDLE and velocity.x != 0:
		transition_to(RUN)
		
	if state == RUN and velocity.x == 0:
		transition_to(IDLE)
		
	if state in [IDLE, RUN] and !is_on_floor():
		transition_to(JUMP)
