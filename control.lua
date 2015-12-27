require "util"
require "defines"

local Entities = (function()

  local function check_setup()
    if not global.entities then
      global.entities = {}
    end
  end

  local function to_id(entity)
    return entity.position.x .. ':' .. entity.position.y .. ':' .. entity.name
  end

  local function get(entity)
    check_setup()
    entity = entity or global.current_entity
    local id = to_id(entity)
    if not global.entities[id] then
      global.entities[id] = {
        slots = {}
      }
    end
    return global.entities[id]
  end

  local function delete(entity)
    check_setup()
    local id = to_id(entity)
    global.entities[id] = nil
  end

  return {
    get = get,
    delete = delete
  }
end)()

local function setup_slot(frame, id)
  for i = 1,#frame.children_names do
    frame[frame.children_names[i]].destroy()
  end

  local item = Entities.get().slots[id]
  local button = frame.add{type="button", style="wrench-slot_button_style", name="wrench-button-slot-" .. id }
  if item then
    button.add{type="frame", style="wrench-slot_button_style-" .. item.name, name="wrench-icon-slot-" .. id }
    button.add{type="frame", style="wrench-amount_frame", name="wrench-frame-slot-" .. id }.add{type="label", style="wrench-amount_label", caption=item.count, name="wrench-label-slot-" .. id }
  end
end

local add_item_button = function (place, id)
  local main_frame = place.add{type="frame", style="wrench-amount_frame", name="wrench-slot-" .. id }
  setup_slot(main_frame, id)
end


local EntityClickEvent = script.generate_event_name()

script.on_event(defines.events.on_built_entity, function(event)
  local player = game.get_player(event.player_index)
  local print = player.print
  local created_entity = event.created_entity
  local surface = created_entity.surface

  if created_entity.name == "wrench-entity" then
    local pos = created_entity.position
    player.insert{name = "wrench", count = 1}
    created_entity.destroy()
    entities = surface.find_entities{{ pos.x, pos.y }, { pos.x, pos.y }}
    if #entities > 1 then
      print('Error: more than one entity found here...')
      return
    end

    if #entities == 1 then
      global.current_entity = entities[1]
      game.raise_event(EntityClickEvent, { entity = global.current_entity, player = player })
    elseif player.gui.center.wrench then
      global.current_entity = nil
      player.gui.center.wrench.destroy()
    end
  end
end)

script.on_event(defines.events.on_entity_died, function(event)
  Entities.delete(event.entity)
end)

script.on_event(defines.events.on_preplayer_mined_item, function(event)
  local player = game.players[event.player_index]
  local print = player.print

  local entity = Entities.get(event.entity)
  if entity then
    for _, slot in pairs(entity.slots) do
      player.insert(slot)
    end
  end
  Entities.delete(event.entity)
end)

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]
  local print = player.print

  local name = event.element.name
  local id = string.match(name, 'wrench%-%l+%-slot%-(%d+)')
  if id then
    local parent = event.element
    while parent.name ~= "wrench-slot-" .. id do
      parent = parent.parent
    end

    local slot = Entities.get().slots[id]
    local hand = player.cursor_stack
    if hand.valid_for_read and slot then
      if hand.name == slot.name then
        slot.count = slot.count + hand.count
        player.cursor_stack.clear()
      end
    elseif hand.valid_for_read and not slot then
      Entities.get().slots[id] = {
        name = hand.name,
        count = hand.count
      }
      hand.clear()
    elseif not hand.valid_for_read and slot then
      hand.set_stack(slot)
      Entities.get().slots[id] = nil
    end
    setup_slot(parent, id)
  end
end)

remote.add_interface("wrench.entities", Entities)
remote.add_interface("wrench.events", { entity_click = function () return EntityClickEvent end })
remote.add_interface("wrench.gui", { add_item_button = add_item_button })
