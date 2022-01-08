local storage = minetest.get_mod_storage()


local used_waystone_names = {}

waystones.used_waystone_names = used_waystone_names

local global_waystones = minetest.deserialize(storage:get_string("waystones")) or {}

for _,v in pairs(global_waystones) do
	used_waystone_names[v] = true
end

local player_waystones = {}

minetest.register_on_joinplayer(function(player, last_login)
	player_waystones[player:get_player_name()] = minetest.deserialize(
		player:get_meta():get_string("waystones:discovered_waystones")
	) or {}

	local pwaystones = player_waystones[player:get_player_name()]

	for _,hash in ipairs(pwaystones) do
		if not global_waystones[hash] then
			table.remove(pwaystones, hash)
		end
	end
end)

--HACK: this is due to a minetest inconsistency
if minetest.is_singleplayer() then
	minetest.register_on_shutdown(function()
		storage:set_string("waystones", minetest.serialize(global_waystones))
		local player = minetest.get_player_by_name("singleplayer")
		if player then
			player:get_meta():set_string("waystones:discovered_waystones", minetest.serialize(player_waystones["singleplayer"]))
		end
	end)
else
	minetest.register_on_leaveplayer(function(player)
		player:get_meta():set_string("waystones:discovered_waystones", minetest.serialize(player_waystones[player:get_player_name()]))
	end)
	minetest.register_on_shutdown(function()
		storage:set_string("waystones", minetest.serialize(global_waystones))
	end)
end

local saving_interval = 300

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer >= saving_interval then
		timer = 0
		storage:set_string("waystones", minetest.serialize(global_waystones))
	end
end)


function waystones.add_waystone_to_world(pos, name)
	--this pos should coincide with a waystone node
	local hash = minetest.hash_node_position(pos)
	global_waystones[hash] = name
end

function waystones.remove_waystone_from_world(pos)
	local hash = minetest.hash_node_position(pos)
	global_waystones[hash] = nil
	for _,player in ipairs(minetest.get_connected_players()) do
		for k,v in ipairs(player_waystones[player:get_player_name()]) do
			if v == hash then
				table.remove(player_waystones[player:get_player_name()], k)
			end
		end
	end
end

function waystones.discover_waystone(player_name, pos)
	--this pos should coincide with a waystone node
	local hash = minetest.hash_node_position(pos)
	table.insert(player_waystones[player_name], hash)
end

--TEMPORARY TESTING STUFF
minetest.register_chatcommand("lwa", {
	func = function()
		return true, "Waistones:\n"..dump(global_waystones)
	end,
})

minetest.register_chatcommand("lwa2", {
	func = function(name)
		return true, "Waistones:\n"..dump(player_waystones[name])
	end,
})