extends KinematicBody2D

var speed = 150
var speed_acelerate = 225
var velocity = Vector2.ZERO
var jump_s = -150
var jump_b = -250
var gravity = 500 

enum {
	IDLE, 
	RUN, 
	JUMP
}
var state
var current_animation
var new_animation

enum PlayerMode{
	SMALL,
	BIG
}
var player_mode_priority = 0
var player_mode = PlayerMode.SMALL

const SMALL_MARIO_COLLISION = preload("res://Collisions/small_player_collision.tres")
const SMALL_MARIO_HIT_COLLISION = preload("res://Collisions/small_area_collision.tres")
const BIG_MARIO_COLLISION = preload("res://Collisions/big_player_collision.tres")
const BIG_MARIO_HIT_COLLISION = preload("res://Collisions/big_area_collision.tres")

func transition_to(new_state, play_mode):
	state = new_state
	match state:
		IDLE:
			new_animation = ("%s_idle" % PlayerMode.keys()[play_mode].to_lower())
		RUN:
			new_animation = ("%s_run" % PlayerMode.keys()[play_mode].to_lower())
		JUMP:
			new_animation = ("%s_jump" % PlayerMode.keys()[play_mode].to_lower())


func _ready():
	transition_to(IDLE, player_mode_priority)

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
		transition_to(JUMP, player_mode_priority)
		
	if is_on_floor() and Input.is_action_just_pressed("ui_up_big"):
		velocity.y = jump_b
		transition_to(JUMP, player_mode_priority)
		
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if state == JUMP and is_on_floor():
		transition_to(IDLE, player_mode_priority)
		
	if state == IDLE and velocity.x != 0:
		transition_to(RUN, player_mode_priority)
		
	if state == RUN and velocity.x == 0:
		transition_to(IDLE, player_mode_priority)
		
	if state in [IDLE, RUN] and !is_on_floor():
		transition_to(JUMP, player_mode_priority)


func _on_Area2D_body_entered(body):
	if body.is_in_group("bricks") && player_mode_priority == 0:
		body.bump()
	
	if body.is_in_group("bricks") && player_mode_priority == 1:
		print("ladrillo roto")
		body.broken_brick()


#Función para que Mario evolucione
func evolve(player_mode):
	var priority = null
	
	match player_mode:
		PlayerMode.SMALL:
			priority = 0
		PlayerMode.BIG:
			priority = 1
			$AnimatedSprite.play("small_to_big")
			
	if priority != player_mode_priority:
		player_mode_priority = priority

#Función para las colisiones de Mario
func change_shape_scale(is_small: bool):
	var collision_shape = SMALL_MARIO_COLLISION if is_small else BIG_MARIO_COLLISION
	var collision_shape_hit = SMALL_MARIO_HIT_COLLISION if is_small else BIG_MARIO_HIT_COLLISION
	$CollisionShape2D.set_deferred("shape", collision_shape)
	$Area2D/BodyCollisionShape2D.set_deferred("shape", collision_shape_hit)

func game_over():
	if player_mode_priority == 0: #Si mario es pequeño
		$AnimatedSprite.play("die")
		set_physics_process(false)
		
		var death_tween = get_tree().create_tween()
		death_tween.tween_property(self, "position", position + Vector2(0,-48), 0.7)
		death_tween.chain().tween_property(self, "position", position + Vector2(0, 250), 1)
	else:
		$AnimatedSprite.play("small_to_big")
		evolve(0)
		$CollisionShape2D.visible = false
		yield(get_tree().create_timer(0.7), "timeout")
		change_shape_scale(true)
		$CollisionShape2D.visible = true
		 #is_small = true -> colisiones de mario pequeño
		
