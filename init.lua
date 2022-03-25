minetest.log("action", "[waystones] loading...")

local modpath = minetest.get_modpath("waystones")

local has_modname_tooltip = minetest.get_modpath("modname_tooltip")

local S = minetest.get_translator("waystones")

mcl_item_id.set_mod_namespace("waystones", "waystones")

if has_modname_tooltip then
	modname_tooltip.set_mod_title("waystones", "Waystones")
end

waystones = {}

dofile(modpath.."/api_names.lua")
dofile(modpath.."/api_waystones.lua")
dofile(modpath.."/api_register.lua")
dofile(modpath.."/items/warp_stone.lua")
dofile(modpath.."/crafting.lua")

waystones.register_waystone("andesite", {
	description = S("Waystone"),
	_doc_items_longdesc = S("longdesc"),
	inventory = "default_stone.png",
	tiles = {"waystones_waystone_andesite.png"},
})

waystones.register_waystone("mossy", {
	description = S("Mossy Waystone"),
	_doc_items_longdesc = S("longdesc"),
	inventory = "default_stone.png",
	tiles = {"waystones_waystone_andesite.png"},
})

waystones.register_waystone("sandy", {
	description = S("Sandy Waystone"),
	_doc_items_longdesc = S("longdesc"),
	inventory = "default_stone.png",
	tiles = {"waystones_waystone_andesite.png"},
})


minetest.log("action", "[waystones] loaded succesfully")