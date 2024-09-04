class_name DialogueManager
extends Node

@export_dir var speakers_dir: String = ""
@export_file("*.txt") var _dbg_dialogue: String = ""

@export var dia_display: DialogueDisplay = null

static var speakers_init: bool = false
static var speakers_register: Dictionary = {}:
    get:
        assert(speakers_init, "ERROR: Tried accessing speakers register without it being initialised.")
        return speakers_register

# Stuff to do with displaying dialogue
var speed: float = 1.0

func _enter_tree() -> void:
    if not speakers_init:
        speakers_init = true
        var dir_q = []
        var dir_s = DirAccess.open(speakers_dir)
        dir_q.append([dir_s, speakers_dir])
        while len(dir_q) > 0:
            var dir = dir_q[0][0]
            var path = dir_q[0][1]
            dir_q.remove_at(0)
            dir.list_dir_begin()
            var file_path = dir.get_next()
            while file_path != "":
                var full_path = path + "/" + file_path
                if dir.current_is_dir():
                    dir_q.append([DirAccess.open(full_path), full_path])
                    file_path = dir.get_next()
                    continue
                var res = ResourceLoader.load(full_path)
                if res is Speaker:
                    speakers_register[res.id] = res
                file_path = dir.get_next()

func _ready() -> void:
    var d = Dialogue.from_file(_dbg_dialogue)
    await DialoguePlayer.new(dia_display, true).play(d)
    print("player dialogue finished")
    pass

# func play_dialogue(_dialogue: Dialogue) -> void:
#     # display_box()
#     # await Coroutine.new().single(play_dialogue_coro.bind(dialogue))
#     # hide_box()
#     pass
#
# # TODO(calco): Somehow communicate canncelation, to hide box
# func play_dialogue_coro(ctx: Coroutine.Ctx, dialogue: Dialogue) -> void:
#     dialogue.restart_tokenizer()
#
#     dia_display.set_text(dialogue.get_string_till_nextpage())
#     dia_display.set_visible_chars(0)
#
#     var token: Dialogue.Token
#     var wait_frame = true
#     var skipped_prev_string = false
#     while true:
#         if wait_frame:
#             await Game.on_pre_process
#             if ctx.cancelled:
#                 return
#         token = dialogue.get_next_token()
#         wait_frame = false
#         match token.type:
#             # TODO(calco): Work on this later
#             Dialogue.Token.SPEAKER:
#                 # current_speaker = token.value
#                 pass
#             Dialogue.Token.SPEED:
#                 speed = token.value
#             Dialogue.Token.WAIT:
#                 await get_tree().create_timer(token.value).timeout
#                 if ctx.cancelled:
#                     return
#             Dialogue.Token.NEWPAGE:
#                 await _await_player_input_coro("DIA_NEXT")
#                 if ctx.cancelled:
#                     return
#                 dia_display.set_text(dialogue.get_string_till_nextpage())
#                 dia_display.set_visible_chars(0)
#                 wait_frame = true
#                 skipped_prev_string = false
#             Dialogue.Token.STRING:
#                 if skipped_prev_string:
#                     dia_display.set_visible_chars(len(token.value))
#                     continue
#
#                 var idx = await Coroutine.new().first_of([
#                     _await_player_input_coro.bind("DIA_NEXT"), 
#                     _display_dialogue_page_coro
#                 ], true)
#                 if ctx.cancelled:
#                     return
#
#                 if idx == 0:
#                     wait_frame = true
#                 else:
#                     skipped_prev_string = true
#             Dialogue.Token.NEWLINE:
#                 dia_display.set_visible_chars(1)
#             Dialogue.Token.EOF:
#                 await _await_player_input_coro("DIA_NEXT")
#                 if ctx.cancelled:
#                     return
#                 break
#             Dialogue.Token.UNKNOWN:
#                 push_warning("WARNING: Dialogue Manager encountered a token it didn't know how to handle! Skipping over it ...")
#
# func _display_dialogue_page_coro(ctx: Coroutine.Ctx) -> void:
#     var idx: float = 0.0
#     var curr_char: float = 0.0
#     while idx < len(dia_display.get_text()):
#         await Game.on_pre_process
#         if ctx.cancelled:
#             return
#         var tchar: int = mini(floori(idx + speed * get_process_delta_time()), len(dia_display.get_text()))
#         if curr_char != tchar:
#             var val = dia_display.get_text().substr(int(curr_char), tchar - int(curr_char))
#             dia_display.set_visible_chars(len(val))
#             curr_char = tchar
#         idx += speed * get_process_delta_time()
#
# func _await_player_input_coro(action: String) -> void:
#     while true:
#         await Game.on_pre_process
#         if Input.is_action_just_pressed(action):
#             break
