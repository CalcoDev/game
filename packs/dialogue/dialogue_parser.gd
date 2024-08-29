class_name Dialogue

static var NO_FILEPATH = "no filepath"

class Token:
    enum {SPEAKER, SPEED, WAIT, NEWPAGE, STRING, NEWLINE, BB_TOK, BB_END_TOK, EOF, UNKNOWN}
    var type: int
    var value

    func _init(p_type: int, p_value):
        type = p_type
        value = p_value
    
    static func _get_token(s: String) -> String:
        var sp = s.find(" ")
        var eq = s.find("=")
        var fi = min(sp, eq)
        if fi == - 1:
            fi = max(sp, eq)
        return s.substr(0, fi)
    
    static func _strip_token(s: String) -> String:
        var sp = s.find(" ")
        var eq = s.find("=")
        var fi = min(sp, eq)
        if fi == - 1:
            fi = max(sp, eq)
        if fi == - 1:
            return ""
        return s.substr(fi + 1, -1)

    static func _get_param_list(s: String) -> Array:
        if s == "":
            return []
        var params = s.split(" ")
        for i in len(params):
            if "=" in params[i]:
                var s0 = params[i].split("=")
                assert(len(s0) == 2, "Given parameter was equality based but didn't have value!")
                params[i] = [s0[0].strip_edges(), s0[1].strip_edges()]
            else:
                params[i] = params[i].strip_edges()
        return params
    
    static func custom_from_str(s):
        var type_str = Token._get_token(s).to_lower()
        var value_str = Token._strip_token(s)
        var value_arr = Token._get_param_list(value_str)
        match type_str:
            "speaker":
                print("TOK: ", value_arr, " | ", value_str)
                var speaker: Speaker = null
                if len(value_arr) > 0:
                    speaker = DialogueManager.speakers_register[value_arr[0]]
                    assert(speaker != null, "ERROR: Referenced speaker was null!")
                return Token.new(SPEAKER, speaker)
            "speed":
                return Token.new(SPEED, value_arr[0].to_float())
            "wait":
                return Token.new(WAIT, value_arr[0].to_float())
            "newpage":
                return Token.new(NEWPAGE, "")
            "n":
                return Token.new(NEWLINE, "")
        return Token.new(UNKNOWN, s)

var filepath: String = ""
var text: String = ""

static func from_file(p_filepath) -> Dialogue:
    var d = Dialogue.new()
    d.filepath = p_filepath
    var file: FileAccess = FileAccess.open(d.filepath, FileAccess.READ)
    assert(file != null, "Could not open filepath for dialogue!")
    d.text = file.get_as_text()
    return d

static func from_text(p_text) -> Dialogue:
    var d = Dialogue.new()
    d.filepath = NO_FILEPATH
    d.text = p_text
    return d

func get_first_token_of_type(type: int):
    var state = _c
    while true:
        var token = get_next_token()
        match token.type:
            type:
                _c = state
                return token.value
            Dialogue.Token.EOF:
                _c = state
                return null
    _c = state
    return null

# TODO(calco): log token misses here
func get_string_till_nextpage() -> String:
    var state = _c
    var s = ""
    while true:
        var token = get_next_token()
        match token.type:
            Dialogue.Token.STRING:
                s += token.value
            Dialogue.Token.NEWLINE:
                s += "\n"
            Dialogue.Token.BB_TOK:
                s += "[" + token.value + "]"
            Dialogue.Token.BB_END_TOK:
                s += "[" + token.value + "]"
            Dialogue.Token.NEWPAGE:
                break
            Dialogue.Token.EOF:
                break
    _c = state
    return s

func restart_tokenizer():
    _c = 0

func get_remaining_token_list() -> Array[Token]:
    var tokens: Array[Token] = []
    while true:
        var token: Token = get_next_token()
        tokens.append(token)
        if token.type == Dialogue.Token.EOF:
            break
    return tokens

# ! CALCO: This doesn't remove CRLF, but just LF 
# return s.replace("\n", "")
# TODO(calco): Fricking horrendous 
func _process_str(s: String) -> String:
    var s0 = ""
    for c in s:
        var ascii = c.to_ascii_buffer()[0]
        if ascii == 10 or ascii == 13:
            continue
        s0 += c
    return s0

static var DEFAULT_BB_TOKENS = {
    "b": true, "i": true, "u": true, "s": true, "code": true, "p": true,
    "center": true, "left": true, "right": true, "fill": true, "indent": true,
    "url": true, "hint": true, "img": true, "font": true, "dropcap": true,
    "font_size": true, "opentype_features": true, "lang": true, "color": true,
    "bgcolor": true, "fgcolor": true, "outline_size": true,
    "outline_color": true, "table": true, "cell": true, "ul": true, "ol": true,
    "lb": true, "rb": true, "lrm": true, "rlm": true, "rle": true, "lre": true,
    "lro": true, "rlo": true, "pdf": true, "alm": true, "lri": true,
    "rli": true, "pdi": true, "zwj": true, "zwnj": true, "wj": true, "shy": true
}

var _c = 0
func get_next_token() -> Token:
    var text_len = len(text)
    if _c >= len(text):
        return Token.new(Token.EOF, "eof")

    # get the remaining text
    var text = text.substr(_c, -1)

    # get the first [
    var t_start = text.find("[")
    # found none => return the rest as a string
    if t_start == - 1:
        # _c = len(text) # TODO(calco): len or len - 1 ?
        _c = text_len
        var s = _process_str(text)
        if len(s) == 0:
            return get_next_token()
        return Token.new(Token.STRING, s)
    # found sth

    # it is escaped => return it
    # TODO(calco): Good idea, but sadly you cna't do that. Add support
    # https://community.mybb.com/post-894396.html
    # if t_start > 0 and text[t_start - 1] == "\\":
    #     _c += 1
    #     text = text.substr(1, -1)
    #     return Token.new(Token.STRING, "[")
    
    # return the token until then
    # IMPORTANT(calco): WHAT THE FRICK EMPTY STRING ISNT EMPTY
    if t_start != 0:
        _c += t_start
        var s = _process_str(text.substr(0, t_start))
        if len(s) == 0:
            return get_next_token()
        return Token.new(Token.STRING, s)

    assert(len(text) > 1, "text cuts off before token ends.")

    # find the end
    var t_end = text.find("]")
    assert(t_end != - 1, "Token never ends.")
    assert(t_end > t_start, "Token ends before it starts.")
    
    var token = text.substr(t_start + 1, t_end - t_start - 1)

    # TODO(calco): Error handling for order of closing things
    # determine if it is an end token
    assert(len(token) > 0, "Token is empty!")
    if token[0] == "/":
        _c += t_end + 1
        return Token.new(Token.BB_END_TOK, token)
    # if it is a custom token, return 
    if token in DEFAULT_BB_TOKENS:
        _c += t_end + 1
        return Token.new(Token.BB_TOK, token)
    else:
        _c += t_end + 1
        return Token.custom_from_str(token)

