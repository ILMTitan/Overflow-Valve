require "defines"

--[[
--debugging code
script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  player.insert{name="overflow-valve", count=10}
  player.insert{name="pipe", count=50}
  player.insert{name="offshore-pump", count=3}
  player.insert{name="storage-tank", count = 10}
  player.insert{name="wrench", count = 1}
end)
--]]--

global.locations = {}
global.player_selected = {}
local gui_frame_caption = "Overflow Valve Settings"

---- Event functions ----

function entity_built (event)
   if event.created_entity ~= nil and event.created_entity.name == "overflow-valve" then
      local entity = event.created_entity
      create_proxies(entity)
      local location_info = {entity.surface.name, entity.position}
      global.locations[location_info] = {overflow = 9, underflow = 10}
   end
end

function on_entity_click (event)
   
   local player = event.player
   local entity = event.entity
   if entity.name == "overflow-valve" then
      local location_info, flow_data = search_locations(entity)
      if location_info then
	 show_gui(entity, player, location_info, flow_data)
      else
	 player.print("Error in overflow-valve (on_entity_click), no location info")
      end
   end
end

function entity_rotated (event)
   if event.entity ~= nil and event.entity.name == "overflow-valve" then
      local entity = event.entity
      local left, right = get_proxies_from_entity(entity)
      left.direction = entity.direction
      right.direction = (entity.direction + 4) % 8
   end
end

function entity_removed (event)
   if event.entity ~= nil and event.entity.name == "overflow-valve" then
      local entity = event.entity

      local left, right = get_proxies_from_entity(entity)
      left.destroy()
      right.destroy()
      
      local location_info = search_locations(entity)
      global.locations[location_info] = nil

      for player_index, player_location_info in pairs(global.player_selected) do
	 if location_info == player_location_info then
	    destroy_gui(player_index)
	 end
      end
   end
end

function on_tick (event)
   if(need_init) then
      init()
   end
   for location_info, flow_info in pairs(global.locations) do
      local surface_name, position = table.unpack(location_info)
      local entity = game.surfaces[surface_name].find_entity("overflow-valve", position)
      if entity == nil then
	 global.locations[location_info] = nil
      else
	 local left, right = get_proxies_from_entity(entity)
	 if left.fluidbox[1] and (right.fluidbox[1] == nil or left.fluidbox[1].amount > right.fluidbox[1].amount) then
	    flow_in(entity, left, flow_info.overflow)
	    flow_out(entity, right, flow_info.underflow)
	 elseif right.fluidbox[1] and (left.fluidbox[1] == nil or right.fluidbox[1].amount > left.fluidbox[1].amount) then
	    flow_in(entity, right, flow_info.overflow)
	    flow_out(entity, left, flow_info.underflow)
	 end
      end
   end
   for player_index, target_location_info in pairs(global.player_selected) do
      local player_position = game.players[player_index].position
      local target_position = target_location_info[2]
      local reach_distance = 6 --data.raw.player.player.reach_distance
      if math.abs((player_position.x - target_position.x) * (player_position.y - target_position.y)) >
	 reach_distance * reach_distance
      then
	 destroy_gui(player_index)
      end
   end
end


function on_gui_click (event)
   local element = event.element
   local player_index = event.player_index
   local valve_gui = game.players[player_index].gui.center.wrench
   if valve_gui and valve_gui.caption == gui_frame_caption then
      if valve_gui.buttons.cancel == element then
	 destroy_gui(player_index)
      elseif valve_gui.buttons.accept == element then
	 try_gui_accept(valve_gui, player_index)
      elseif valve_gui.defaults.prod == element then
	 valve_gui.over_flow.input.text = "0"
	 valve_gui.under_flow.input.text = "90"
      elseif valve_gui.defaults.cons == element then
	 valve_gui.over_flow.input.text = "90"
	 valve_gui.under_flow.input.text = "100"
      end
   end
end

function on_configuration_changed(...)
   if(global.valve_locations) then
      need_init = true
   end

   if global.valve then
      global.locations = global.valve.locations
      global.player_selected = global.valve.player_selected
      global.valve = nil
   end
end

function on_load()
   if next(global.player_selected) then
      script.on_event(defines.events.on_gui_click, on_gui_click)
   end
end

---- Helper functions ----

function create_proxies (entity)
   entity.surface.create_entity{
      name = "valve-proxy",
      position = entity.position,
      direction = entity.direction,
      force = entity.force
   }
   
   entity.surface.create_entity{
      name = "valve-proxy",
      position = entity.position,
      direction = (entity.direction + 4) % 8,
      force = entity.force
   }
end

function destroy_gui(player_index)
   local valve_gui = game.players[player_index].gui.center.wrench
   
   if valve_gui then
      
      valve_gui.destroy()
      
      global.player_selected[player_index] = nil
      if next(global.player_selected) == nil then
	 script.on_event(defines.events.on_gui_click, nil)
      end
   end
end


function try_gui_accept (valve_gui, player_index)
   local errors = {}
   local overflow = tonumber(valve_gui.over_flow.input.text)
   if overflow == nil then
      table.insert(errors, "Minimum input must be a number!")
   elseif overflow < 0 then
      table.insert(errors, "Minimum input was too small. It must be between 0 and 100 but was " .. overflow .. ".")
   elseif overflow > 100 then
      table.insert(errors, "Minimum input was too large. It must be between 0 and 100 but was " .. overflow .. ".")
   end
   
   local underflow = tonumber(valve_gui.under_flow.input.text)
   if underflow == nil then
      table.insert(errors, "Maximum output must be a number!")
   elseif underflow < 0 then
      table.insert(errors, "Maximum output was too small. It must be between 0 and 100 but was " .. underflow .. ".")
   elseif underflow > 100 then
      table.insert(errors, "Maximum output was too large. It must be between 0 and 100 but was " .. underflow .. ".")
   end
   
   if next(errors) == nil then
      global.locations[global.player_selected[player_index]] = {overflow = overflow/10, underflow = underflow/10}
      destroy_gui(player_index)
   else
      if valve_gui.errors then
	 valve_gui.errors.destroy()
      end
      valve_gui.add{type = "flow", name = "errors", direction = "vertical"}
      for _, error_text in ipairs(errors) do
	 local error_label = valve_gui.errors.add{type = "label", caption = error_text}
	 error_label.style.font_color = {r = 1}
      end
   end
end

function show_gui (entity, player, location_info, flow_data)
   local center_gui = player.gui.center
   if center_gui.wrench then
      destroy_gui(player.index)
   end

   center_gui.add{type = "frame", caption = gui_frame_caption, name = "wrench", direction = "vertical"}
   local valve_gui = center_gui.wrench

   valve_gui.add{type = "flow", name = "defaults", direction = "horizontal"}
   valve_gui.defaults.add{type = "button", name = "prod", caption = "Restrict Production"}
   valve_gui.defaults.add{type = "button", name = "cons", caption = "Restrict Consumption"}

   valve_gui.add{type = "flow", name = "over_flow", direction = "horizontal"}
   valve_gui.over_flow.add{type = "label", caption = "Minimum input % full for flow:"}
   local over_field = valve_gui.over_flow.add{type = "textfield", name = "input"}
   over_field.text = tostring(flow_data.overflow * 10)
   over_field.style.maximal_width = 50
   valve_gui.over_flow.add{type = "label", caption = "%"}

   valve_gui.add{type = "flow", name = "under_flow", direction = "horizontal"}
   valve_gui.under_flow.add{type = "label", caption = "Maximum output % full for flow:"}
   local under_field = valve_gui.under_flow.add{type = "textfield", name = "input"}
   under_field.text = tostring(flow_data.underflow * 10)
   under_field.style.maximal_width = 50
   valve_gui.under_flow.add{type = "label", caption = "%"}


   valve_gui.add{type = "flow", name = "buttons", direction = "horizontal"}
   valve_gui.buttons.add{type = "button", name = "accept", caption = "Accept"}
   valve_gui.buttons.add{type = "button", name = "cancel", caption = "Cancel"}
   
   global.player_selected[player.index] = location_info
   script.on_event(defines.events.on_gui_click, on_gui_click)
end

function search_locations (entity)
   for location_info, flow_info in pairs(global.locations) do
      if entity.surface.name == location_info[1] then
	 local position = location_info[2]
	 if entity.position.x == position.x and entity.position.y == position.y then
	    return location_info, flow_info
	 end
      end
   end
   return nil, nil
end

function get_proxies_from_entity(entity)
   local search_area = {entity.position, entity.position}
   local proxies = entity.surface.find_entities_filtered{area = search_area, name = "valve-proxy"}
   return table.unpack(proxies)
end

function flow (in_box, out_box, flow_amount)
   out_box.amount = out_box.amount - flow_amount
   in_box.temperature = 
      (in_box.temperature * in_box.amount + out_box.temperature * flow_amount)
      / (in_box.amount + flow_amount)
   in_box.amount = in_box.amount + flow_amount
   in_box.type = out_box.type
   return in_box, out_box
end

function flow_in (entity, proxy, overflow)
   local proxy_box = proxy.fluidbox[1]
   if (proxy_box ~= nil) then
      local valve_box = entity.fluidbox[1] or {amount = 0, type = "water", temperature = 0}
      if proxy_box.amount > overflow and (proxy_box.type == valve_box.type or valve_box.amount == 0) then
	 local flow_amount = math.min(proxy_box.amount - overflow, 10 - valve_box.amount)
	 entity.fluidbox[1], proxy.fluidbox[1] = flow(valve_box, proxy_box, flow_amount)
      end
   end
end

function flow_out (entity, proxy, underflow)
   local valve_box = entity.fluidbox[1]
   if valve_box ~= nil then
      local proxy_box = proxy.fluidbox[1] or {amount = 0, type = "water", temperature = 0}
      if proxy_box.amount < underflow and (proxy_box.type == valve_box.type or proxy_box.amount == 0) then
	 local flow_amount = math.min((underflow - proxy_box.amount)/2, valve_box.amount/2)
	 proxy.fluidbox[1], entity.fluidbox[1] = flow(proxy_box, valve_box, flow_amount)
      end
   end
end

function init()

   global.locations = global.locations or global.valve.locations or {}
   global.player_selected = global.player_selected or (global.valve and global.valve.player_selected) or {}
   
   for location_info, _ in pairs(global.valve_locations) do
      local position, surface = table.unpack(location_info)
      for k, v in pairs(surface) do
	 game.player.print("k " .. tostring(k) .. " v " .. tostring(v))
      end
      surface = game.get_surface(surface.surfaceindex + 1)
      new_location_info = {surface.name, position}
      global.locations[new_location_info] = {overflow = 9, underflow = 10}
   end
   global.valve_locations = nil
   
   need_init = false
end

script.on_event(defines.events.on_built_entity, entity_built)
script.on_event(defines.events.on_robot_built_entity, entity_built)

script.on_event(defines.events.on_player_rotated_entity, entity_rotated)

script.on_event(defines.events.on_preplayer_mined_item, entity_removed)
script.on_event(defines.events.on_robot_pre_mined, entity_removed)
script.on_event(defines.events.on_entity_died, entity_removed)

script.on_event(defines.events.on_tick, on_tick)

script.on_event(remote.call("wrench.events", "entity_click"), on_entity_click)

script.on_load(on_load)
script.on_configuration_changed(on_configuration_changed)

