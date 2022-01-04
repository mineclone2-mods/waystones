minetest.log("action", "[waystones] loading...")

local modpath = minetest.get_modpath("waystones")

local S = minetest.get_translator("waystones")

mcl_item_id.set_mod_namespace("waystones", "waystones")

waystones = {}

dofile(modpath.."/api.lua")
dofile(modpath.."/items/warp_stone.lua")
dofile(modpath.."/crafting.lua")

waystones.register_waystone("andesite", {
	description = S("Waystone"),
	_doc_items_longdesc = S("longdesc"),
	tiles = {"waystones_waystone_andesite.png"},
})


minetest.log("action", "[waystones] loaded succesfully")