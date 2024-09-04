class_name CharacterSelectable
extends Node2D

const DEFAULT_POS = Vector2(-11, -39)
const HOVERED_POS = DEFAULT_POS + Vector2.UP * 10
const CONFIRMED_POS = DEFAULT_POS + Vector2.UP * 25

const ANIM_DUR = 0.2

@export var char_id: String = "invalid_id"

@export var area: Area2D = null
@export var area_area: Area2D = null
@export var area_poly: Polygon2D = null
@export var anim: AnimationPlayer = null
@export var char_anim: AnimationPlayer = null

@export var text_color: Color = Color.WHITE

var hovered: bool = false
var selected: bool = false

var hover_tween: Tween = null
var select_tween: Tween = null

func _ready() -> void:
	area_area.visible = true
	area_poly.polygon = (area_area.get_child(0) as CollisionPolygon2D).polygon.duplicate()
	area_poly.position = area_area.position
	area_poly.rotation = area_area.rotation
	area_poly.z_index = -1

	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)

	area_area.mouse_entered.connect(_on_mouse_entered_area)
	area_area.mouse_exited.connect(_on_mouse_exited_area)

	deselect_self()
	unhover_self()
	unhighlight_area()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"CHAR_SELECT_CONFIRM"):
		if selected:
			CharacterSelectScene.instance.confirm_character(char_id)
		if hovered:
			select_self()

func _on_mouse_entered_area() -> void:
	highlight_area()

func _on_mouse_exited_area() -> void:
	unhighlight_area()

func _on_mouse_entered() -> void:
	hover_self()

func _on_mouse_exited() -> void:
	unhover_self()

func highlight_area() -> void:
	anim.play("highlight")

func unhighlight_area() -> void:
	anim.play("unhighlight")

func hover_self() -> void:
	if hovered:
		return
	hovered = true
	char_anim.play("hover")
	CharacterSelectScene.instance.set_active_text_color(text_color)
	CharacterSelectScene.instance.select_char()

func unhover_self() -> void:
	if not hovered:
		return
	hovered = false
	char_anim.play("unhover")
	CharacterSelectScene.instance.deselect_char()

func select_self() -> void:
	if selected:
		return
	selected = true
	char_anim.play("select")
	CharacterSelectScene.instance.confirm_char()

func deselect_self() -> void:
	if not selected:
		return
	selected = false
	char_anim.play("deselect")
	if hovered:
		CharacterSelectScene.instance.select_char()
	else:
		CharacterSelectScene.instance.deselect_char()
