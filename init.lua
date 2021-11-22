minetest.log("action", "[waystones] loading...")

local modpath = minetest.get_modpath("waystones")

waystones = {}


dofile(modpath.."/items/warp_stone.lua")
dofile(modpath.."/crafting.lua")


minetest.log("action", "[waystones] loaded succesfully")