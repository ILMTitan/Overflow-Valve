require "defines"

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  player.insert{name="overflow-valve", count=10}
  player.insert{name="pipe", count=50}
  player.insert{name="offshore-pump", count=3}
  player.insert{name="storage-tank", count = 10}
end)

global.valve_locations = {}

function create_proxies(entity)
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

function entity_built (event)
   if event.created_entity ~= nil and event.created_entity.name == "overflow-valve" then
      local entity = event.created_entity
      create_proxies(entity)
      global.valve_locations[{entity.position, entity.surface}] = true
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

function get_proxies_from_entity(entity)
   local search_area = {entity.position, entity.position}
   local proxies = entity.surface.find_entities_filtered{area = search_area, name="valve-proxy"}
   return table.unpack(proxies)
end

function entity_removed (event)
   if event.entity ~= nil and event.entity.name == "overflow-valve" then
      local entity = event.entity
      local left, right = get_proxies_from_entity(entity)
      left.destroy()
      right.destroy()
      global.valve_locations[{entity.position, entity.surface}] = nil
   end
end

function on_tick (event)
   local locations_to_remove = {}
   for location_info, _ in pairs(global.valve_locations) do
      local location, surface = unpack(location_info)
      local valve = surface.find_entity("overflow-valve", location)
      if valve == nil then
	 locations_to_remove[#locations_to_remove + 1] = location_info
      else
	 local left, right = get_proxies_from_entity(valve)
	 flow_in(valve, left)
	 flow_in(valve, right)
	 flow_out(valve, right)
	 flow_out(valve, left)
      end
   end
   for _, location in ipairs(locations_to_remove) do
      global.valve_locations[location] = nil
   end
end

function flow_in (valve, proxy)
   local proxy_box = proxy.fluidbox[1]
   if(proxy_box ~= nil) then
      local valve_box = valve.fluidbox[1] or {amount = 0, type = "water", temperature = 0}
      if(proxy_box.amount > 9 and (proxy_box.type == valve_box.type or valve_box.amount == 0)) then
	 local flow_amount = math.min(proxy_box.amount - 9, 10 - valve_box.amount)
	 proxy_box.amount = proxy_box.amount - flow_amount
	 valve_box.temperature = (valve_box.temperature * valve_box.amount + proxy_box.temperature * flow_amount) / (valve_box.amount + flow_amount)
	 valve_box.amount = valve_box.amount + flow_amount
	 valve_box.type = proxy_box.type
      end
      valve.fluidbox[1] = valve_box
      proxy.fluidbox[1] = proxy_box
   end
end

function flow_out (valve, proxy)
   local valve_box = valve.fluidbox[1]
   if(valve_box ~= nil) then
      local proxy_box = proxy.fluidbox[1] or {amount = 0, type = "water", temperature = 0}
      if(proxy_box.amount < 9 and (proxy_box.type == valve_box.type or proxy_box.amount == 0)) then
	 local flow_amount = math.min((9 - proxy_box.amount)/2, valve_box.amount)
	 valve_box.amount = valve_box.amount - flow_amount
	 proxy_box.temperature = (valve_box.temperature * flow_amount + proxy_box.temperature * proxy_box.amount) / (proxy_box.amount + flow_amount)
	 proxy_box.amount = proxy_box.amount + flow_amount
	 proxy_box.type = valve_box.type
      end
      valve.fluidbox[1] = valve_box
      proxy.fluidbox[1] = proxy_box
   end
end
   

script.on_event(defines.events.on_built_entity, entity_built)
script.on_event(defines.events.on_robot_built_entity, entity_built)

script.on_event(defines.events.on_player_rotated_entity, entity_rotated)

script.on_event(defines.events.on_preplayer_mined_item, entity_removed)
script.on_event(defines.events.on_robot_pre_mined, entity_removed)
script.on_event(defines.events.on_entity_died, entity_removed)

script.on_event(defines.events.on_tick, on_tick)
