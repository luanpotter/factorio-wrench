data.raw["gui-style"].default["wrench-amount_label"] = {
  type = "label_style",
  font = "default-semibold"
}

data.raw["gui-style"].default["wrench-amount_frame"] = {
  type = "frame_style",
  parent = "frame_style",
  left_padding = 16,
  top_padding = 12,
  graphical_set = { type = "none" }
}

local slot_button_graphical_set = {
  type = "monolith",
  top_monolith_border = 1,
  right_monolith_border = 1,
  bottom_monolith_border = 1,
  left_monolith_border = 1,
  monolith_image =
  {
    filename = "__core__/graphics/gui.png",
    priority = "extra-high-no-scale",
    width = 36,
    height = 36,
    x = 111
  }
}

data.raw["gui-style"].default["wrench-slot_button_style"] = {
  type = "button_style",
  parent = "button_style",
  scalable = false,
  width = 36,
  height = 36,
  top_padding = 1,
  right_padding = 1,
  bottom_padding = 1,
  left_padding = 1,
  default_graphical_set = slot_button_graphical_set,
  hovered_graphical_set = slot_button_graphical_set,
  clicked_graphical_set = slot_button_graphical_set
}

for typename, sometype in pairs(data.raw) do
  local _, object = next(sometype)
  if object.stack_size or typename == "fluid" then
    for name, item in pairs(sometype) do
      if item.icon then
        data.raw["gui-style"].default["wrench-slot_button_style-"..name] = {
          type = "frame_style",
          width = 32,
          height = 32,
          graphical_set = {
            type = "monolith",
            monolith_image =
            {
              filename = item.icon,
              priority = "extra-high-no-scale",
              width = 32,
              height = 32,
              x = 0,
              y = 0
            }
          }
        }
      end
    end
  end
end