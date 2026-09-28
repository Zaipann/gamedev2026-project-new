extends Node3D
## Scene Demo: เดินได้ด้วย WASD + เลือกดูท่าจากลิสต์ทางขวา

@onready var player: CharacterBody3D = $Player
@onready var list: ItemList = $UI/Panel/Margin/VBox/List
@onready var filter: OptionButton = $UI/Panel/Margin/VBox/LibraryPick
@onready var label: Label = $UI/Hint

var libs := {}

func _ready() -> void:
	# ตั้งค่า Input map ด้วยโค้ด (ไม่ต้องตั้งใน project settings)
	_add_key("move_forward", KEY_W); _add_key("move_forward", KEY_UP)
	_add_key("move_back", KEY_S);    _add_key("move_back", KEY_DOWN)
	_add_key("move_left", KEY_A);    _add_key("move_left", KEY_LEFT)
	_add_key("move_right", KEY_D);   _add_key("move_right", KEY_RIGHT)

	libs = {
		"melee": load("res://animations/MeleeLib.res") as AnimationLibrary,
		"shooter": load("res://animations/ShooterLib.res") as AnimationLibrary,
	}
	for k in libs.keys():
		filter.add_item("%s Library" % k.capitalize())
	filter.item_selected.connect(func(i): _fill_list(libs.keys()[i]))
	list.item_selected.connect(_on_pick)
	_fill_list("melee")

	label.text = "WASD เดิน | Shift วิ่ง | Space กระโดด | J/K/L ฟัน | U ชน | R กลิ้ง | H เจ็บ | X ตาย | Enter ฟื้น\nคลิกขวาลากเพื่อหมุนกล้อง | Scroll ซูม | เลือกท่าจากลิสต์ด้านขวา"

func _fill_list(lib: String) -> void:
	list.clear()
	var names: Array = Array(libs[lib].get_animation_list())
	names = names.filter(func(n): return not str(n).begins_with("root-") and not str(n).begins_with("Armature"))
	names.sort()
	for n in names:
		var idx := list.add_item(str(n))
		list.set_item_metadata(idx, "%s/%s" % [lib, n])

func _on_pick(i: int) -> void:
	player.preview(list.get_item_metadata(i))
	list.release_focus()

func _add_key(action: String, key: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var ev := InputEventKey.new()
	ev.physical_keycode = key
	InputMap.action_add_event(action, ev)
