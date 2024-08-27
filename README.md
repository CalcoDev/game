# game

a game.

made by<br>
tudyslaier calcopod

## TODO(s):
- [ ] Multiplayer
  - [ ] Joining world
- [ ] Persistency
  - [ ] Create `save file`
    - [ ] World options
    - [ ] Character options
- [ ] Visuals
  - [ ] Lights
- [ ] Gameplay
  - [ ] Interactions
  - [ ] Dialogue
  - [ ] Sound
  - [ ] Flow
    - [ ] Config world
    - [ ] Start game (singleplayer | multiplayer)
    - [ ] ??? (talk with tudy)


### 25.08.2024:
- [x] Main menu screen
- [x] Scene transitions (with adequate HDWorld setup)

### 26.08.2024:
- [x] Lighting system

(impromptuu)
- [x] Smooth pixelart camera

- [x] Lights Fix:
  - [x] Not working outside of camera bounds (aka render to a larget texture and then overlay that)
  - [x] If camera moves, the scene viewport does not...


### 27.08.2024:
~~- [ ] Lights height~~ (kinda did it, but didn't work as expected, so I abandoned it and will use a work around)

- [x] HDWorld:
  - [x] Add permanent high res UI stuff (for game scene transitions)
  - [x] Make association between objects and their parents, and listen to free() signals (allow dynamically spawned objects to have their own low-res or high-res)

- [ ] ACTUALLY TEST THOSE FEATURES

- [ ] 1 - Player walking simulator
  - [ ] Wheat field (display + physics)
  - [ ] House
    - [ ] Exterior
    - [ ] Interior
      - [ ] ???
- [ ] Basic save / load system (character and world files)
- [ ] Multiplayer stuff
