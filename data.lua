require("script/utils")



gun = copy_prototype("gun", "artillery-wagon-cannon", "landmine-thrower-cannon")
gun.attack_parameters.ammo_category = "land-mine"
gun.attack_parameters.range = settings.startup["landmine-thrower-range"].value
gun.attack_parameters.min_range = 8
gun.attack_parameters.cooldown = 60
gun.attack_parameters.shell_particle = nil


turret = copy_prototype("artillery-turret", "artillery-turret","landmine-thrower")
turret.gun = gun.name
turret.disable_automatic_firing = true
turret.manual_range_modifier = 1
turret.ammo_stack_limit = 100
turret.automated_ammo_count = 10
turret.base_picture.layers[1].tint = {g=255,b=255}
turret.base_picture.layers[1].hr_version.tint = {g=255,b=255}
turret.radius_visualisation_specification = {
	sprite = {
		filename="__landmine-thrower__/graphics/donut.png",
		size = 48*2,
	},
	distance = settings.startup["landmine-thrower-range"].value,
	draw_in_cursor = true,
	draw_on_selection = true,
}

--[[local smoke_opts = {
	name = "thrower-flare-smoke",
	duration = 600,
	color = {r=255,g=0,b=0},
}
flareSmoke = trivial_smoke(smoke_opts)]]

turretItem = copy_prototype("item","artillery-turret","landmine-thrower")
turretItem.icon = "__landmine-thrower__/graphics/icons/landmine-thrower.png"
turretItem.icon_size = 32

flare = copy_prototype("artillery-flare","artillery-flare","landmine-thrower-flare")
flare.shot_category = "land-mine"
flare.life_time = 65535 -- uint16 max, ~18m12s
flare.pictures = {
    {
      filename = "__core__/graphics/empty.png",
      priority = "extra-high",
      width = 1,
      height = 1
    },
}
--[[
flare.regular_trigger_effect_frequency = 1
flare.regular_trigger_effect = {
    type = "create-trivial-smoke",
    smoke_name = "artillery-smoke",
    initial_height = 0,
    speed_from_center = 0.05,
    speed_from_center_deviation = 0.005,
    offset_deviation = {{-4, -4}, {4, 4}},
    max_radius = 3.5,
    repeat_count = 4 * 4 * 15
    }
]]

-- so it doesn't interact with the artillery cannon
data.raw["artillery-flare"]["artillery-flare"].shot_category = data.raw["artillery-flare"]["artillery-flare"].shot_category or "artillery-shell"

data:extend({
	{
		type = "ammo-category",
		name = "land-mine"
	},


	-- technology	
	{
		name = "landmine-thrower",
		type = "technology",
		icons = {
			{
				icon = data.raw.technology["artillery"].icon,
				icon_size = data.raw.technology["artillery"].icon_size,
			},
			{
				icon = data.raw.technology["land-mine"].icon,
				icon_size = data.raw.technology["land-mine"].icon_size,
				shift = {30,44},
				scale = .5,
			}
		},
		unit = {
			count = 100,
			time = 30,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
			}
		},
		prerequisites = {"land-mine"},
		effects = {
			{type = "unlock-recipe", recipe = "landmine-thrower"},
			{type = "unlock-recipe", recipe = "landmine-thrower-remote"},
		},
		order = "d-e-h"
	},

	-- recipe
	{
		name = "landmine-thrower",
		type = "recipe",
		enabled = false,
		ingredients = {
			{"steel-plate", 20},
			{"copper-plate", 30},
			{"iron-gear-wheel", 30},
		},
		energy_required = 12,
		result = "landmine-thrower",
	},


	-- targeting remote
	{
		type = "capsule",
		name = "landmine-thrower-remote",
		icon = "__landmine-thrower__/graphics/icons/landmine-thrower-remote.png",
		icon_size = 32,
		capsule_action =
		{
			type = "artillery-remote",
			flare = "landmine-thrower-flare"
		},
		subgroup = "capsule",
		order = "zz",
		stack_size = 1
	},
	{
		name = "landmine-thrower-remote",
		type = "recipe",
		enabled = false,
		ingredients = {
			{"advanced-circuit", 1},
			{"radar", 1},
		},
		energy_required = 1,
		result = "landmine-thrower-remote",
	},

	gun,turret,turretItem,flare,flareSmoke
})