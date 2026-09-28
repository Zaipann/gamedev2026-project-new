extends CharacterBody3D
## Player: WASD เดิน, Shift วิ่ง, Space กระโดด, J/K/L โจมตี, R กลิ้ง, H เจ็บ, X ตาย

const WALK_SPEED := 2.2
const RUN_SPEED := 5.0
const JUMP_VELOCITY := 5.0
const TURN_SPEED := 10.0

@export var camera_pivot: Node3D

@onready var visual: Node3D = $Visual
@onready var anim: AnimationPlayer = $Visual/blockman_n_Walking/AnimationPlayer

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var busy := false          # กำลังเล่นท่า one-shot (โจมตี/กลิ้ง/ตาย)
var dead := false
var preview_mode := false  # true = ให้ UI เลือกท่าเอง ไม่ใช้ท่าอัตโนมัติ

const LOOPING := [
	"melee/LightIdle", "melee/LightWalking", "melee/LightRunning", "melee/Sprint",
	"melee/LightFalling", "melee/Guarding", "melee/HeavyIdle",
]

func _ready() -> void:
	anim.add_animation_library("melee", load("res://animations/MeleeLib.res"))
	anim.add_animation_library("shooter", load("res://animations/ShooterLib.res"))
	anim.animation_finished.connect(_on_anim_finished)
	anim.play("melee/LightIdle")

func play_anim(name: String, blend := 0.15) -> void:
	if anim.has_animation(name) and anim.current_animation != name:
		anim.play(name, blend)

func play_once(name: String) -> void:
	if busy or dead: return
	busy = true
	preview_mode = false
	anim.play(name, 0.1)

func _on_anim_finished(_n: StringName) -> void:
	if not dead:
		busy = false

func _unhandled_input(event: InputEvent) -> void:
	if dead or not event is InputEventKey or not event.pressed or event.echo: return
	match event.keycode:
		KEY_J: play_once("melee/Slash1")
		KEY_K: play_once("melee/Slash2")
		KEY_L: play_once("melee/Slash3")
		KEY_U: play_once("melee/ShieldBash")
		KEY_R: play_once("melee/Roll")
		KEY_H: play_once("melee/Hurt1")
		KEY_X:
			play_once("melee/Die1")
			dead = true
		KEY_ENTER, KEY_KP_ENTER:
			# ฟื้นคืนชีพ
			dead = false; busy = false; preview_mode = false

## เรียกจาก UI เพื่อดูท่าที่เลือก
func preview(name: String) -> void:
	if not anim.has_animation(name): return
	preview_mode = true
	dead = false
	busy = false
	anim.get_animation(name).loop_mode = Animation.LOOP_LINEAR
	anim.play(name, 0.2)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if dead or busy or preview_mode and input == Vector2.ZERO:
		input = Vector2.ZERO
	elif preview_mode:
		preview_mode = false

	# ทิศทางอิงกล้อง
	var basis_y := camera_pivot.global_transform.basis if camera_pivot else global_transform.basis
	var dir := (basis_y * Vector3(input.x, 0, input.y))
	dir.y = 0
	dir = dir.normalized()

	var running := Input.is_key_pressed(KEY_SHIFT)
	var speed := RUN_SPEED if running else WALK_SPEED

	if Input.is_key_pressed(KEY_SPACE) and is_on_floor() and not busy and not dead and not preview_mode:
		velocity.y = JUMP_VELOCITY

	if dir != Vector3.ZERO:
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		var target := atan2(-dir.x, -dir.z)
		# โมเดล Mixamo หันหน้าไปทาง +Z ต้องหมุน 180°
		visual.rotation.y = lerp_angle(visual.rotation.y, target + PI, TURN_SPEED * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 4 * delta * 3)
		velocity.z = move_toward(velocity.z, 0, speed * 4 * delta * 3)

	move_and_slide()

	if busy or dead or preview_mode:
		return
	if not is_on_floor():
		play_anim("melee/LightFalling" if velocity.y < 0 else "melee/Jump", 0.1)
	elif dir != Vector3.ZERO:
		play_anim("melee/LightRunning" if running else "melee/LightWalking")
	else:
		play_anim("melee/LightIdle", 0.2)
