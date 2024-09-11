class_name LegendScene
extends Node

@export_file("dia_*.txt") var legend_dialogue: String = ""
@export var dialogue_display: DialogueDisplay = null

func start_cutscene() -> void:
	var d = Dialogue.from_file(legend_dialogue)
	await DialoguePlayer.new(dialogue_display, true).play_await_box(d)
