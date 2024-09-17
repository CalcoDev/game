# NOTE(calco): Used as an interface for displaying BBCode based dialogue.
class_name DialogueDisplay
extends Node

# TODO(calco): Dialopgue Display should be its own component probs
# @export var anim: AnimationPlayer = null

# @export var dialogue_box: NinePatchRect = null
# @export var dialogue_box_marker: TextureRect = null
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

var visible_characters: int = 0:
    set(value):
        visible_characters = value
        dialogue_box_lbl.visible_characters = value
    get:
        return visible_characters
