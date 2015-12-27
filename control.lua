require "util"
require "defines"

global.accesses = 0

local Entities = (function(store)

  local function check_setup()
    if not store.entities then
      store.entities = {}
    end
  end

  local function to_id(entity)
    return entity.position.x .. ':' .. entity.position.y .. ':' .. entity.name
  end

  local function get(entity)
    check_setup()
    entity = entity or store.current_entity
    local id = to_id(entity)
    if not store.entities[id] then
      store.entities[id] = { slots = {} }
    end
    return store.entities[id]
  end

  local function set_current(entity)
    store.current_entity = entity
  end

  local function delete(entity)
    check_setup()
    local id = to_id(entity)
    store.entities[id] = nil
  end

  return {
    get = get,
    set_current = set_current,
    delete = delete
  }
end)(global)

local function setup_slot(frame, id)
  local entity = Entities.get()

  for i = 1,#frame.children_names do
    frame[frame.children_names[i]].destroy()
  end

  local item = entity.slots[id]
  local button = frame.add{type="button", style="wrench-slot_button_style", name="wrench-button-slot-" .. id }
  if item then
    button.add{type="frame", style="wrench-slot_button_style-" .. item.name, name="wrench-icon-slot-" .. id }
    button.add{type="frame", style="wrench-amount_frame", name="wrench-frame-slot-" .. id }.add{type="label", style="wrench-amount_label", caption=item.count, name="wrench-label-slot-" .. id }
  end
end

local GUI = {
  add_item_button = function (place, id, item_stack)
    local main_frame = place.add{type="frame", style="wrench-amount_frame", name="wrench-slot-" .. id }
    if (item_stack) then
      Entities.get().slots[id] = item_stack
    end
    setup_slot(main_frame, id)
  end
}

local EntityClickEvent = script.generate_event_name()

script.on_event(defines.events.on_built_entity, function(event)
  local player = game.get_player(event.player_index)
  local print = player.print
  local created_entity = event.created_entity
  local surface = created_entity.surface

  if created_entity.name == "wrench-entity" then
    local pos = created_entity.position
    player.cursor_stack.set_stack({name = "wrench", count = 1})
    created_entity.destroy()
    entities = surface.find_entities{{ pos.x, pos.y }, { pos.x, pos.y }}
    if #entities > 1 then
      print('Error: more than one entity found here...')
      return
    end

    if player.gui.center.wrench then
      player.gui.center.wrench.destroy()
    end

    local entity
    if #entities == 1 then
      entity = entities[1]
    else
      entity = nil
    end

    Entities.set_current(entity)
    if (entity) then
      game.raise_event(EntityClickEvent, { entity = entity, player = player })
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

    local function itemstack_to_rep (stack)
      return {
            name = stack.name,
            count = stack.count,
            type = stack.type,
            has_grid = stack.has_grid,
            health = stack.health,
            durability = stack.durability
          }
    end

    id = tonumber(id)
    local entity = Entities.get()
    local slot = entity.slots[id]
    local hand = player.cursor_stack
    if hand.valid_for_read and slot then
      if hand.name == slot.name then
        slot.count = slot.count + hand.count
        player.cursor_stack.clear()
      else
        entity.slots[id] = itemstack_to_rep(hand)
        hand.set_stack(slot)
      end
    elseif hand.valid_for_read and not slot then
      entity.slots[id] = itemstack_to_rep(hand)
      hand.clear()
    elseif not hand.valid_for_read and slot then
      hand.set_stack(slot)
      entity.slots[id] = nil
    end
    setup_slot(parent, id)
  end
end)

remote.add_interface("wrench.entities", Entities)
remote.add_interface("wrench.gui", GUI)
remote.add_interface("wrench.events", { entity_click = function () return EntityClickEvent end })
