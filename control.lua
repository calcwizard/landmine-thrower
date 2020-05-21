
const = {
	names = {
		flare_name = "landmine-thrower-flare",
		flare_type = "artillery-flare"
	}
}

function place_flare_on_ghost(ghost)
	ghost.surface.create_entity{name=const.names.flare_name,position=ghost.position,force=ghost.force,frame_speed=0,vertical_speed=0,height=0,movement={0,0}}
end

function remove_flare_from_ghost(ghost)
	if ghost and ghost.valid then
		local surface = ghost.surface
		local position = ghost.position
		local flare = surface.find_entity(const.names.flare_name,position)
		if flare then
			flare.destroy()
		end
		for _,flare in pairs(surface.find_entities_filtered{type=const.names.flare_type,position=position,radius=2}) do
			if surface.count_entities_filtered{position=flare.position,type="entity-ghost",ghost_type="land-mine"} == 0 then
				flare.destroy()
			end
		end
	end
end

function built_entity(event)
	local entity = event.created_entity
	if entity and entity.valid then
		if entity.type == "land-mine" then
			remove_flare_from_ghost(entity)
		elseif entity.type == "entity-ghost" and entity.ghost_type == "land-mine" then
			place_flare_on_ghost(entity)		
		end	
	end
end

script.on_event(defines.events.on_built_entity,built_entity,{{filter="ghost_type",type="land-mine"},{filter="type",type="land-mine"}})
script.on_event(defines.events.on_pre_ghost_deconstructed,function(event) remove_flare_from_ghost(event.ghost) end,{{filter="ghost_type",type="land-mine"}})
script.on_event(defines.events.on_player_mined_entity,function(event) remove_flare_from_ghost(event.entity) end,{{filter="ghost_type",type="land-mine"}})
script.on_event(defines.events.on_robot_built_entity,built_entity,{{filter="type",type="land-mine"}})
