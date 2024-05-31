extends CharacterBody3D

const SPEED = 3.0 * 60
const SPRINT_SPEED = SPEED*1.5


var can_sprint = true
var is_sprinting = false
var sprint_time = 2

var tiles = []
var HP = 10

func HanDam(dam):
	HP = HP - dam

func _ready():
	add_to_group("Player")

func _physics_process(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		if Input.is_action_just_pressed("sprint") and can_sprint: 
			if  can_sprint:
				$TimerStamineTime.start(2)
			is_sprinting = true
			can_sprint = false 
			
		
		if is_sprinting:
			velocity.x = -direction.x * SPRINT_SPEED * delta
			velocity.z = -direction.z * SPRINT_SPEED * delta
		else:
			velocity.x = -direction.x * SPEED * delta
			velocity.z = -direction.z * SPEED * delta
		#rotation.y += 1
		#print(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	var dir2d = Vector2(input_dir.x, -input_dir.y)

	rotation.y = dir2d.angle()
	move_and_slide()


	
	var col_count = get_slide_collision_count()
	
	for i in range(col_count):
		var coll = get_slide_collision(i).get_collider().get_meta("type")
		if coll == "bullet":
			get_slide_collision(i).get_collider().get_parent().queue_free()
			HP -= 1
			
			if HP == 0:
				get_tree().reload_current_scene()
				for  turret in $"..".turrets:
					turret.queue_free()
					
	if  is_sprinting:
		sprint_time = $TimerStamineTime.time_left / 2.0
	elif not can_sprint:
		sprint_time = 1 - $Staminecooldown.time_left / 10.0
	else:
		sprint_time = 2
		
		
	print(is_sprinting, can_sprint)





func _on_timer_stamine_time_timeout():
	$Staminecooldown.start(10)
	
	is_sprinting = false
	 


func _on_staminecooldown_timeout():
	can_sprint = true

