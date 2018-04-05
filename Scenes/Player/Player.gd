extends KinematicBody2D

# Environment Physics
const UP = Vector2(0, -1)
const GRAVITY = 10
# Movement
const ACCELERATION = 20
const MAX_SPEED = 450
const JUMP_HEIGHT = 350
# Blink
const BLINK_DISTANCE = 130

# Movement
var motion = Vector2()
# Blink
var can_blink = true
var blink_effect
var blink_timer
var blink_recharge_progress_bar

func _ready():
	
	# Blink
	blink_effect = get_node("/root/Game/BlinkEffect")
	
	blink_timer = $Blink/Timer
	blink_timer.connect("timeout", self, "blink_timer_timeout")
	
	blink_recharge_progress_bar = $Blink/CanvasLayer/RechargeProgressBar
	
	print("Player ready")
	
	pass

func _process(delta):
	
	blink_recharge_progress_bar.value = (blink_timer.time_left * blink_recharge_progress_bar.max_value) / blink_timer.wait_time
	
	pass

func _physics_process(delta):
	
	# Movement
	if Input.is_action_pressed("ui_right"):
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		$Sprite.flip_h = false
		if is_on_floor():
			$Sprite.animation = "running"
	elif Input.is_action_pressed("ui_left"):
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		$Sprite.flip_h = true
		if is_on_floor():
			$Sprite.animation = "running"
		pass
	else:
		motion.x = lerp(motion.x, 0, 0.2)
		if is_on_floor():
			$Sprite.animation = "idle"
			
	# Jump
	if Input.is_action_pressed("ui_up"):
		if is_on_floor():
			motion.y = -JUMP_HEIGHT
			$Sprite.animation = "jump"
		
	# Blink
	if Input.is_action_just_pressed("ui_accept"):
		blink()
			
	# Fall
	if !is_on_floor():
		motion.y += GRAVITY
		if motion.y > 0:
			$Sprite.animation = "fall"

	move_and_slide(motion, UP)

	pass

func blink():
	
	var blink_to_pos = self.position
	
	if can_blink:
		if Input.is_action_pressed("ui_left"):
			blink_to_pos.x -= BLINK_DISTANCE
		if Input.is_action_pressed("ui_right"):
			blink_to_pos.x +=  BLINK_DISTANCE
		if Input.is_action_pressed("ui_up"):
			blink_to_pos.y -=  BLINK_DISTANCE
		if Input.is_action_pressed("ui_down"):
			blink_to_pos.y +=  BLINK_DISTANCE
		
	if self.position != blink_to_pos:
		blink_effect.position = self.position
		blink_effect.restart()
		$AudioStreamPlayer2D.play()
		
		self.position = blink_to_pos
		
		can_blink = false
		blink_timer.start()
		
	pass
	
func blink_timer_timeout():
	
	can_blink = true
	
	pass
