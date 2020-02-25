
local flares = false
for _,force in pairs(game.forces) do
	if force.get_entity_count("landmine-thrower-flare") > 0 then
		flares = true
	end
end


if flares then
	local count = 0
	for _,surface in pairs(game.surfaces) do
		for _,flare in pairs(surface.find_entities_filtered{name="landmine-thrower-flare"}) do
			if surface.count_entities_filtered{type="corpse",position=flare.position,limit=1}==0 and surface.count_entities_filtered{ghost_type="land-mine",position=flare.position,limit=1}==0 then
				flare.destroy()
				count = count + 1
			end
		end
	end
	if count > 0 then
		log(string.format("cleared %d flares",count))
	end
end