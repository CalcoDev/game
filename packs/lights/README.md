# lights

trying to make lightning system.

## attempts

- 2dgi, voronoi points => issue

Cant have voronoi diagram (maybe?) unless figure out a way to do it over polygons / stuff in general

## current attempt:

dumbest implementation:
- for every pixel, step in small steps towards -light_dir.
- if hit something, get distance.
- if distance is less than THRESHOLD, make shadow
