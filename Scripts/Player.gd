extends KinematicBody2D

var motion = Vector2()
var speed = 1000
var number_of_jumps = Global.number_of_jumps
var jump_counter = 0
var dash_counter = 0
var can_double_jump
var is_dashing = false
var dash_available = true
var number_of_dashes = Global.number_of_dashes
var can_wall_run = Global.can_wall_run
var dash_direction

const GRAVITY = 100
const UP = Vector2(0, -1)
const JUMP_SPEED = 2000
const HEIGHT_BOUNDARY = 8000
const SLOWNESS_MODIFIER = 0.7
const DASH_DISTANCE = 3000


func _ready():
	Global.Player = self


func _physics_process(delta):
	dash()
	apply_gravity()
	if can_wall_run:
		wall_run()
	move()
	jump()
	animate()
	move_and_slide(motion, UP)
	lose()
	retreive_powerup()

func move():
	if Input.is_action_pressed("left") and not Input.is_action_pressed("right") and not is_dashing:
		motion.x = -speed
		$Sprite.flip_h = true
	elif Input.is_action_pressed("right") and not Input.is_action_pressed("left") and not is_dashing:
		motion.x = speed
		$Sprite.flip_h = false
	elif not is_dashing:
		motion.x = 0


func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_dashing:
		can_double_jump = false
		jump_counter = 1
		motion.y -= JUMP_SPEED
		$JumpTimer.start()
	if Input.is_action_just_pressed("jump") and not jump_counter == number_of_jumps and can_double_jump and not is_dashing:
		can_double_jump = false
		motion.y = 0
		motion.y -= JUMP_SPEED
		jump_counter += 1
		$JumpTimer.start()


func wall_run():
	if is_on_wall():
		motion.y = GRAVITY / SLOWNESS_MODIFIER
		if jump_counter == number_of_jumps:
			jump_counter = number_of_jumps - 1
		if $Sprite.is_flipped_h():
			if Input.is_action_just_pressed("jump"):
				motion.x = JUMP_SPEED
		elif not $Sprite.is_flipped_h():
			if Input.is_action_just_pressed("jump"):
				motion.x = -JUMP_SPEED


#func dash():
#	if Input.is_action_just_pressed("dash") and not $Sprite.is_flipped_h() and dash_available and not dash_counter == number_of_dashes:
#		is_dashing = true
#		$DashTimer.start()
#		dash_counter += 1
#		$Sprite.rotation = DASH_ANGLE
#		motion.y = 0
#		motion.x += DASH_DISTANCE
#		dash_available = false
#		$DashRecharge.start()
#	elif Input.is_action_just_pressed("dash") and $Sprite.is_flipped_h() and dash_available and not dash_counter == number_of_dashes:
#		is_dashing = true
#		$DashTimer.start()
#		dash_counter += 1
#		$Sprite.rotation = -DASH_ANGLE
#		motion.y = 0
#		motion.x -= DASH_DISTANCE
#		dash_available = false
#		$DashRecharge.start()
#
#	if dash_counter == number_of_dashes and is_on_floor():
#		dash_counter = 0


func dash():
	if Input.is_action_just_pressed("dash") and dash_available and not dash_counter == number_of_dashes:
		is_dashing = true
		$DashTimer.start()
		dash_counter += 1
		motion.y = 0
		dash_available = false
		$DashRecharge.start()
		
		if not $Sprite.is_flipped_h():
			dash_direction = "right"
		else:
			dash_direction = "left"
			
		if dash_direction == "left":
			motion.x += -DASH_DISTANCE
		elif dash_direction == "right":
			motion.x += DASH_DISTANCE
		
	if dash_counter == number_of_dashes and is_on_floor():
		dash_counter = 0


func retreive_powerup():
	number_of_dashes = Global.number_of_dashes
	number_of_jumps = Global.number_of_jumps
	can_wall_run = Global.can_wall_run


func apply_gravity():
	if is_on_floor() and motion.y > 0 and not is_dashing:
		motion.y = GRAVITY
	elif is_on_ceiling():
		motion.y = 1
	elif not is_dashing:
		motion.y += GRAVITY


func animate():
	var animation = $AnimationPlayer.get_current_animation()
	if motion.y < 0 and jump_counter == 1:
		$AnimationPlayer.play("Jump")
		$Sprite.rotation = 0
	elif is_dashing:
		if dash_direction == "right":
			$AnimationPlayer.play("DashRight")
		elif dash_direction == "left":
			$AnimationPlayer.play("DashLeft")
	elif motion.y < 0 and not $Sprite.is_flipped_h() and jump_counter > 1 and not animation == "DoubleJumpLeft":
		$AnimationPlayer.play("DoubleJumpRight")
	elif motion.y < 0 and $Sprite.is_flipped_h() and jump_counter > 1 and not animation == "DoubleJumpRight":
		$AnimationPlayer.play("DoubleJumpLeft")
	elif not animation == "Jump" and motion.x > 0:
		$AnimationPlayer.play("Run")
		$Sprite.rotation = 0
	elif not animation == "Jump" and motion.x < 0:
		$AnimationPlayer.play("Run")
		$Sprite.rotation = 0
	else:
		$AnimationPlayer.play("Idle")
		$Sprite.rotation = 0


func lose():
	if position.y > HEIGHT_BOUNDARY:
		get_tree().reload_current_scene()


func _on_JumpTimer_timeout():
	can_double_jump = true


func _on_DashTimer_timeout():
	is_dashing = false
	$Sprite.rotation = 0


func _on_DashRecharge_timeout():
	dash_available = true
	
