class_name DialogueDisplay
extends Node

# TODO(calco): Dialopgue Display should be its own component probs
@export var anim: AnimationPlayer = null

@export var dialogue_box: NinePatchRect = null
@export var dialogue_box_marker: TextureRect = null
@export var dialogue_box_lbl: RichTextLabel = null


func display() -> void:
    pass

func hide() -> void:
    pass

# Getters & Setters
func get_text() -> String:
    return dialogue_box_lbl.text

func set_text(text: String) -> void:
    dialogue_box_lbl.text = text

func set_visible_chars(count: int) -> void:
    dialogue_box_lbl.visible_characters = count
