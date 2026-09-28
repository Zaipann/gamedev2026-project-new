extends Node3D
## กล้อง third-person: ลากเมาส์ขวาเพื่อหมุน, scroll เพื่อซูม, ตามผู้เล่น

@export var target: Node3D
@export var height := 1.2
@onready var spring: SpringArm3D = $SpringArm3D

var yaw := 0.0
var pitch := -0.3

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= event.relative.x * 0.005
		pitch = clamp(pitch - event.relative.y * 0.005, -1.2, 0.4)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring.spring_length = max(1.5, spring.spring_length - 0.4)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring.spring_length = min(12.0, spring.spring_length + 0.4)

func _process(_d: float) -> void:
	if target:
		global_position = global_position.lerp(target.global_position + Vector3(0, height, 0), 0.25)
	rotation = Vector3(pitch, yaw, 0)
