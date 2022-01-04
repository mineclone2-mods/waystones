local S = minetest.get_translator("waystones")

local default_waystone_bottom_def = {
	--description = S("Waystone"),
	--_doc_items_longdesc = S("longdesc"),
	drawtype = "mesh",
	mesh = "waystones_waystone_bottom.obj",
	--tiles = {"andesite_waystone.png"},
	groups = {pickaxey = 2, building_block = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5},
			{-0.4375, -0.3125, -0.4375, 0.4375, -0.0625, 0.4375},
			{-0.375, -0.0625, -0.375, 0.375, 0.0625, 0.375},
			{-0.3125, 0.0625, -0.3125, 0.3125, 0.5, 0.3125},
		},
	},
}

local default_waystone_top_def = {
	--description = S("Waystone Top"),
	--_doc_items_longdesc = S("longdesc"),
	drawtype = "mesh",
	mesh = "waystones_waystone_top.obj",
	--tiles = {"andesite_waystone.png"},
	groups = {pickaxey = 2, building_block = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.3125, 0.3125, 0, 0.3125},
			{-0.375, 0, -0.375, 0.375, 0.125, 0.375},
			{-0.4375, 0.125, -0.4375, 0.4375, 0.25, 0.4375},
			{-0.3125, 0.25, -0.3125, 0.3125, 0.375, 0.3125},
			{-0.25, 0.375, -0.25, 0.25, 0.5, 0.25},
		}
	},
}

function waystones.register_waystone(name, def)
	local def_bottom = table.copy(default_waystone_bottom_def)
	local def_top    = table.copy(default_waystone_top_def)
	for k,v in pairs(def) do
		def_bottom[k] = v
		def_top[k] = v
	end
	minetest.register_node("waystones:"..name.."_waystone_bottom", def_bottom)
	minetest.register_node("waystones:"..name.."_waystone_top", def_top)
end