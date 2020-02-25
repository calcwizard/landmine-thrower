
data:extend({
	-- startup
	{
		type = "bool-setting",
		name = "landmine-thrower-leave-ghosts",
		setting_type = "startup",
		default_value = false,
		order = "ba",
	},
	{
		type = "int-setting",
		name = "landmine-thrower-range",
		setting_type = "startup",
		default_value = 48,
		minimum_value = 8,
		order = "aa",
	},
	{
		type = "bool-setting",
		name = "landmine-thrower-resistance",
		setting_type = "startup",
		default_value = false,
		order = "ab",
	},
})
