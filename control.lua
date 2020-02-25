
const = {
	names = {
		flare_prefix = "thrower-flare-",
		flare_type = "artillery-flare"
	}
}

function place_flare_on_ghost(event)
	if event.created_entity.type == "entity-ghost" and event.created_entity.ghost_type == "land-mine" then
		event.created_entity.surface.create_entity{name=const.names.flare_prefix..event.created_entity.ghost_name,position=event.created_entity.position,force=event.created_entity.force,frame_speed=0,vertical_speed=0,height=0,movement={0,0}}
	end
end

function remove_flare_from_ghost(ghost)
	local flare = ghost.surface.find_entities_filtered{type=const.names.flare_type,position=ghost.position}[1]
	if flare then
		flare.destroy()
	else
		log("couldn't find a flare when removing a land mine ghost")
	end
end

script.on_event(defines.events.on_built_entity,place_flare_on_ghost,{{filter="ghost_type",type="land-mine"}})
script.on_event(defines.events.on_pre_ghost_deconstructed,function(event) remove_flare_from_ghost(event.ghost) end,{{filter="ghost_type",type="land-mine"}})
script.on_event(defines.events.on_player_mined_entity,function(event) remove_flare_from_ghost(event.entity) end,{{filter="ghost_type",type="land-mine"}})