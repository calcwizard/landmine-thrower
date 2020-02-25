

local function dying_trigger_effect(flare_name) 
	return {
		type = "create-entity",
		entity_name = flare_name,
		
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
end

local function make_thrower_projectile(base_entity) 
	data:extend({
	{
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
	},
})
end

local function make_flare(base_entity)
	local flare = {
		type = "artillery-flare",
		name = "thrower-flare-" .. base_entity.name,
		icon = "__base__/graphics/icons/artillery-targeting-remote.png",
		icon_size = 64, icon_mipmaps = 4,
		flags = {"placeable-off-grid", "not-on-map"},
		map_color = {r=1, g=0.5, b=0},
		flare_category = "thrower-flare-" .. base_entity.name,
		life_time = 65535, -- unit16 max, 18m 12.25s
		initial_height = 0,
		initial_vertical_speed = 0,
		initial_frame_speed = 1,
		shots_per_flare = 1,
		early_death_ticks = 3 * 60,
		pictures = {
			{
			  filename = "__core__/graphics/empty.png",
			  priority = "extra-high",
			  width = 1,
			  height = 1
			},
		  --{
		  --  filename = "__base__/graphics/entity/sparks/sparks-02.png",
		  --  width = 36,
		  --  height = 32,
		  --  frame_count = 19,
		  --  line_length = 19,
		  --  shift = {0.03125, 0.125},
		  --  tint = { r = 1.0, g = 0.9, b = 0.0, a = 1.0 },
		  --  animation_speed = 0.3,
		  --}
		},
		--[[
		regular_trigger_effect_frequency = 1,
		regular_trigger_effect = {
			type = "create-trivial-smoke",
			smoke_name = "artillery-smoke",
			initial_height = 0,
			speed_from_center = 0.05,
			speed_from_center_deviation = 0.005,
			offset_deviation = {{-4, -4}, {4, 4}},
			max_radius = 3.5,
			repeat_count = 4 * 4 * 15
		},
	]]
	}
	

	data:extend({
		flare,
		{
			type = "ammo-category",
			name = flare.flare_category,
		},
	})

	if not base_entity.dying_trigger_effect then
		base_entity.dying_trigger_effect = {}
	end
	table.insert(base_entity.dying_trigger_effect, dying_trigger_effect(flare.flare_category))

	table.insert(data.raw.gun["landmine-thrower-cannon"].attack_parameters.ammo_categories,flare.flare_category)

	return flare.flare_category
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
	table.insert(resistances,{type="acid",percent=resist})
	return resistances
end 


local landmines = {}

-- get a list of all land mine entities and the items that make them
for entity_name,entity in pairs(data.raw["land-mine"]) do
	entity.create_ghost_on_death = settings.startup["landmine-thrower-leave-ghosts"].value
	
	
	--[[if settings.startup["landmine-thrower-quick-arm"].value then
		entity.timeout = 6
	end]]
	if settings.startup["landmine-thrower-resistance"].value then
		entity.resistances = add_resistances(entity.resistances or {}, 99)
	end

	make_thrower_projectile(entity)

    landmines[entity_name] = make_flare(entity)
end

for item_name, item in pairs(data.raw.item) do
	if landmines[item.place_result] then
		item.type = "ammo"
		item.ammo_type = {
			category = landmines[item.place_result],
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
