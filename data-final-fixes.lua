

local dying_trigger_effect = {
	type = "create-entity",
	entity_name = "landmine-thrower-flare",
	
	-- old particle stuff, should be ignored, doesn't affect error either way
--[[frame_speed = 0,
	frame_speed_deviation = 0,
	initial_vertical_speed=0,
	initial_vertical_speed_deviation=0,
	initial_height=0,
	initial_height_deviation=0,
	speed_from_center = 0,
	speed_from_center_deviation=0,
	]]
}

local function make_thrower_projectile(base_entity) 
	return {
	    type = "artillery-projectile",
	    name = "thrower-" .. base_entity.name,
	    flags = {"not-on-map"},
	    reveal_map = false,
	    map_color = {r=1, g=1, b=0},
	    rotatable = false,
	    picture = base_entity.picture_safe,
	    shadow = {
	      filename = "__landmine-thrower__/graphics/entity/hr-shell-shadow.png",
	      width = 64,
	      height = 64,
	      scale = 0.5
	    },
	    chart_picture = {
			filename = "__core__/graphics/empty.png",
			priority = "extra-high",
			width = 1,
			height = 1
	    },
	    action = {
			type = "direct",
			action_delivery =
			{
				type = "instant",
				target_effects =
				{
					{
						type = "create-trivial-smoke",
						smoke_name = "artillery-smoke",
						initial_height = 0,
						speed_from_center = 0.05,
						speed_from_center_deviation = 0.005,
						offset_deviation = {{-4, -4}, {4, 4}},
						max_radius = 3.5,
						repeat_count = 4 * 4 * 15
					},
					{
						type = "create-entity",
						entity_name = base_entity.name,
						trigger_created_entity = true,
						check_buildability = true,
						show_in_tooltip = true,
					}
				}
			}
	    },
	    height_from_ground = 280 / 64
	}
end


local function add_resistances(resistances,resist)
	--[[local updated_resistances = {physical = false, acid = false}
	for k,v in pairs(resistances) do
		if updated_resistances[v.type] ~= nil then
			v.percent = settings.startup["landmine-thrower-quick-arm"].value
		end
	end
	if not updated_resistances.physical then
		table.insert(resistances,{type="physical",percent=resist})
	end
	if not updated_resistances.acid then
		table.insert(resistances,{type="acid",percent=resist})
	end]]
	table.insert(resistances,{type="physical",percent=resist})
	table.insert(resistances,{type="acid",percent=resist})
	return resistances
end 


local landmines = {}

-- get a list of all land mine entities and the items that make them
for entity_name,entity in pairs(data.raw["land-mine"]) do
	entity.create_ghost_on_death = settings.startup["landmine-thrower-leave-ghosts"].value
	if not entity.dying_trigger_effect then
		entity.dying_trigger_effect = {}
	end
	table.insert(entity.dying_trigger_effect, dying_trigger_effect)
	
	--[[if settings.startup["landmine-thrower-quick-arm"].value then
		entity.timeout = 6
	end]]
	if settings.startup["landmine-thrower-resistance"].value then
		entity.resistances = add_resistances(entity.resistances or {}, 99)
	end

	local projectile = make_thrower_projectile(entity)
    data:extend({projectile})

    landmines[entity_name] = true
end

for item_name, item in pairs(data.raw.item) do
	if landmines[item.place_result] then
		item.type = "ammo"
		item.ammo_type = {
			category = "land-mine",
			target_type = "position",
			action =
			{
				type = "direct",
				action_delivery =
				{
					type = "artillery",
					projectile = "thrower-" .. item.place_result,
					starting_speed = 1,
					direction_deviation = 0,
					range_deviation = 0,
					source_effects =
					{
						type = "create-explosion",
						entity_name = "artillery-cannon-muzzle-flash"
					}
				}
			}
	    }

	    data:extend({item})
	    data.raw.item[item_name] = nil
	end
end
