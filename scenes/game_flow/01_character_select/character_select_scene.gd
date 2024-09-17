class_name CharacterSelectScene
extends Node2D

static var instance: CharacterSelectScene = null

const TWEEN_DURATION: float = 0.75

@export var prompt_lbl: RichTextLabel = null
@export var select_lbl: RichTextLabel = null
@export var confirm_lbl: RichTextLabel = null

@export var anim: AnimationPlayer = null

var prompt_tween: Tween = null
var select_tween: Tween = null
var confirm_tween: Tween = null

var text_col: Color = Color.WHITE

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	prompt_lbl.modulate = Color.WHITE
	select_lbl.modulate = Color.TRANSPARENT
	confirm_lbl.modulate = Color.TRANSPARENT

func confirm_character(char_id: String) -> void:
	if anim.is_playing() and anim.current_animation == "end_transition":
		return
	anim.play("end_transition")
	await anim.animation_finished
	print("doing stuff with ", char_id)
	Game.change_scene_file(
		"res://scenes/game_flow/02_legend/scene_legend.tscn",
		TransitionParams.new(Game.TRANSITION_FADE, false, true, true)
	)

func set_active_text_color(col: Color) -> void:
	text_col = col

func deselect_char() -> void:
	_toggle_text(prompt_lbl)

func select_char() -> void:
	_toggle_text(select_lbl)

func confirm_char() -> void:
	_toggle_text(confirm_lbl)
	
# TODO(Calco): Fix this to now change modulate of random text
func _toggle_text(txt: RichTextLabel) -> void:
	var og_col = text_col
	og_col.a8 = 0
	prompt_tween = _handle_tween(prompt_tween)
	if prompt_lbl != txt:
		prompt_tween.tween_property(prompt_lbl, "modulate", og_col, TWEEN_DURATION)
	else:
		prompt_tween.tween_property(prompt_lbl, "modulate", text_col, TWEEN_DURATION)
	prompt_tween.play()
	
	select_tween = _handle_tween(select_tween)
	if select_lbl != txt:
		select_tween.tween_property(select_lbl, "modulate", og_col, TWEEN_DURATION)
	else:
		select_tween.tween_property(select_lbl, "modulate", text_col, TWEEN_DURATION)
	select_tween.play()

	confirm_tween = _handle_tween(confirm_tween)
	if confirm_lbl != txt:
		confirm_tween.tween_property(confirm_lbl, "modulate", og_col, TWEEN_DURATION)
	else:
		confirm_tween.tween_property(confirm_lbl, "modulate", text_col, TWEEN_DURATION)
	confirm_tween.play()

func _handle_tween(tween: Tween) -> Tween:
	if tween != null and tween.is_valid():
		tween.kill()
	return get_tree().create_tween()
