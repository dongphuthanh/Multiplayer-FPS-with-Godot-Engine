extends KinematicBody

const SPEED = 20
const acc=5
const mouse_sensitivity=1
var velocity=Vector3()
var is_master = false
var mouse_mode=0
func _ready():
	$Head/Camera.current=false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func initialize(id):
	name = str(id)
	if id == Net.net_id:
		is_master = true
		$Head/Camera.current=true
func _input(event):
	if is_master==true:
		if event is InputEventMouseMotion:
			rotate_y(deg2rad(-event.relative.x*mouse_sensitivity))
			$Head.rotate_x(deg2rad(-event.relative.y*mouse_sensitivity))
			$Head.rotation.x=clamp($Head.rotation.x,-0.9,0.9)
		
func _physics_process(delta):
	if is_master:
		if Input.is_action_just_pressed("ui_cancel"):
			if mouse_mode==0:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				mouse_mode=1
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				mouse_mode=0
		var head_basis=$Head.get_global_transform().basis
		var direction=Vector3()
		if Input.is_action_pressed("ui_right"):
			direction+=head_basis.x
		elif Input.is_action_pressed("ui_left"):
			direction-=head_basis.x
		if Input.is_action_pressed("ui_down"):
			direction+=head_basis.z
		elif Input.is_action_pressed("ui_up"):
			direction-=head_basis.z
			direction=direction.normalized()
		velocity=velocity.linear_interpolate(direction*SPEED,acc*delta)
		move_and_slide(velocity)
		rpc_unreliable("update_position", translation)

remote func update_position(pos):
	translation = pos
