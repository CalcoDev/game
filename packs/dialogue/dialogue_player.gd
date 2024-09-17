# NOTE(calco): Used for getting the text and playing it in a `DialogueDisplay`
# NOTE(calco): Could be a func -> Coroutine, but I'd like a bit more control now
class_name DialoguePlayer

var display: DialogueDisplay = null
var require_player_input: bool = false

@warning_ignore("shadowed_variable")
func _init(display: DialogueDisplay, require_player_input: bool) -> void:
    self.display = display
    self.require_player_input = require_player_input

# TODO(calco): Perhaps await the display and hide calls
func play(dialogue: Dialogue) -> void:
    display.display()
    await Coroutine.new().single(play_dialogue_coro.bind(dialogue))
    display.hide()

@warning_ignore("redundant_await")
func play_await_box(dialogue: Dialogue) -> void:
    await display.display()
    await Coroutine.new().single(play_dialogue_coro.bind(dialogue))
    await display.hide()

# TODO(calco): Somehow communicate canncelation, to hide box
func play_dialogue_coro(ctx: Coroutine.Ctx, dialogue: Dialogue) -> void:
    dialogue.restart_tokenizer()

    display.set_text(dialogue.get_string_till_nextpage())
    display.visible_characters = 0

    var speed: float = 1.0

    var token: Dialogue.Token
    var wait_frame = true
    var skipped_prev_string = false
    while true:
        if wait_frame:
            await Game.on_pre_process
            if ctx.cancelled:
                return
        token = dialogue.get_next_token()
        print(token.type, " ", token.value)
        wait_frame = false
        match token.type:
            # TODO(calco): Work on this later
            Dialogue.Token.SPEAKER:
                # current_speaker = token.value
                pass
            Dialogue.Token.SPEED:
                speed = token.value
            Dialogue.Token.WAIT:
                await Game.get_tree().create_timer(token.value).timeout
                if ctx.cancelled:
                    return
            Dialogue.Token.NEWPAGE:
                if require_player_input:
                    await _await_player_input_coro("DIA_NEXT")
                    if ctx.cancelled:
                        return
                # TODO(calco): Figure out what to do if no player input
                display.set_text(dialogue.get_string_till_nextpage())
                display.visible_characters = 0
                wait_frame = true
                skipped_prev_string = false
            Dialogue.Token.STRING:
                if skipped_prev_string:
                    display.visible_characters += len(token.value)
                    continue
                
                if require_player_input:
                    var idx = await Coroutine.new().first_of([
                        _await_player_input_coro.bind("DIA_SKIP"), 
                        _display_dialogue_page_coro.bind(speed, len(token.value))
                    ], true)
                    if ctx.cancelled:
                        return
                    
                    if idx == 1:
                        wait_frame = true
                    else:
                        display.visible_characters += len(token.value) - display.visible_characters
                        skipped_prev_string = true
                else:
                    await Coroutine.new().single(_display_dialogue_page_coro.bind(speed, len(token.value)))
                    if ctx.cancelled:
                        return
                    skipped_prev_string = false
                    wait_frame = true
            Dialogue.Token.NEWLINE:
                display.visible_characters += 1
            Dialogue.Token.EOF:
                if require_player_input:
                    await _await_player_input_coro("DIA_NEXT")
                await Game.on_pre_process
                if ctx.cancelled:
                    return
                break
            Dialogue.Token.UNKNOWN:
                push_warning("WARNING: Dialogue Player encountered a token it didn't know how to handle! Skipping over it ...")

func _display_dialogue_page_coro(ctx: Coroutine.Ctx, speed: float, length: int) -> void:
    var idx: float = float(display.visible_characters)
    var curr_char: float = idx
    var end_idx = idx + length
    while idx < end_idx:
        await Game.on_pre_process
        if ctx.cancelled:
            return
        # TODO(calco): use end_idx ??? len(display.get_text())
        var tchar: int = mini(floori(idx + speed * Game.get_delta()), end_idx)
        if curr_char != tchar:
            # TODO(calco): Why substring and not just math lol
            var val = display.get_text().substr(int(curr_char), tchar - int(curr_char))
            display.visible_characters += len(val)
            curr_char = tchar
        idx += speed * Game.get_delta()

func _await_player_input_coro(action: String) -> void:
    while true:
        await Game.on_pre_process
        if Input.is_action_just_pressed(action):
            break
