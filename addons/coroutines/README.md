# coroutine implementation (calcos scuffed gdscript coroutines v3 I guess)

Drastically simpler than previous impls, any coroutine must take either 0 prams, or 1, that being a `Coroutine.Ctx`.

```gdscript
var a = func(ctx: Coroutine.Ctx):
    var t = randf() * 5
    print("Creating timer A with ", t, " seconds.")
    await get_tree().create_timer(t).timeout
    if ctx.cancelled:
        return
    print("Finished timer A with ", t, " seconds. Context: ", ctx)
var b = func(ctx: Coroutine.Ctx):
    var t = randf() * 5
    print("Creating timer B with ", t, " seconds.")
    await get_tree().create_timer(t).timeout
    if ctx.cancelled:
        return
    print("Finished timer B with ", t, " seconds. Context: ", ctx)
var c = func(ctx: Coroutine.Ctx):
    var t = randf() * 5
    print("Creating timer C with ", t, " seconds.")
    await get_tree().create_timer(t).timeout
    if ctx.cancelled:
        return
    print("Finished timer C with ", t, " seconds. Context: ", ctx)
var finished = await Coroutine.new().first_of([a, b, c], true)
print("Timer ", "ABC"[finished], " finished first!")
```
