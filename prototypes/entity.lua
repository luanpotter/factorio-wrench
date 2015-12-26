data:extend({{
  type = "decorative",
  name = "wrench-entity",
  icon = "__Wrench__/graphics/icon.png",
  flags = {"placeable-neutral", "not-on-map"},
  collision_mask = { "ghost-layer"},
  subgroup = "grass",
  order = "b[decorative]-b[turret-range-overlay-gun]",
  collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  selectable_in_game = false,
  render_layer = "radius-visualization",
  pictures = {
    {
      filename = "__Wrench__/graphics/icon.png",
      width = 32,
      height = 32
    }
  }
}})
