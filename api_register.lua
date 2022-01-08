--local S = minetest.get_translator("waystones")

local default_waystone_bottom_def = {
	--description = S("Waystone"),
	--_doc_items_longdesc = S("longdesc"),
	drawtype = "mesh",
	mesh = "waystones_waystone_bottom.obj",
	use_texture_alpha = "opaque",
	sunlight_propagates = true,
	--tiles = {"andesite_waystone.png"},
	groups = {pickaxey = 1, material_stone = 1, building_block = 1, waystone = 1, not_in_creative_inventory = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5},
			{-0.4375, -0.3125, -0.4375, 0.4375, -0.0625, 0.4375},
			{-0.375, -0.0625, -0.375, 0.375, 0.0625, 0.375},
			{-0.3125, 0.0625, -0.3125, 0.3125, 0.5, 0.3125},
		},
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	node_placement_prediction = "",
	drop = "",
	_mcl_hardness = 1.5,
}

local default_waystone_top_def = {
	--description = S("Waystone Top"),
	--_doc_items_longdesc = S("longdesc"),
	drawtype = "mesh",
	mesh = "waystones_waystone_top.obj",
	use_texture_alpha = "opaque",
	sunlight_propagates = true,
	--tiles = {"andesite_waystone.png"},
	groups = {pickaxey = 1, material_stone = 1, building_block = 1, waystone = 1, not_in_creative_inventory = 1},
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
	sounds = mcl_sounds.node_sound_stone_defaults(),
	node_placement_prediction = "",
	drop = "",
	_mcl_hardness = 1.5,
}

local default_waystone_bottom_def_activated = table.copy(default_waystone_bottom_def)
default_waystone_bottom_def_activated.groups.waystone_activated = 1

local default_waystone_top_def_activated = table.copy(default_waystone_top_def)
default_waystone_top_def_activated.groups.waystone_activated = 1

local default_waystone_item_def = {
	groups = {material_stone = 1, building_block = 1},
}

local function on_place_node(place_to, newnode, placer, oldnode, itemstack, pointed_thing)
	-- Run script hook
	for _, callback in pairs(minetest.registered_on_placenodes) do
		-- Deep-copy pos, node and pointed_thing because callback can modify them
		local place_to_copy = vector.new(place_to)
		local newnode_copy = {name = newnode.name, param1 = newnode.param1, param2 = newnode.param2}
		local oldnode_copy = {name = oldnode.name, param1 = oldnode.param1, param2 = oldnode.param2}
		local pointed_thing_copy = {
			type  = pointed_thing.type,
			above = vector.new(pointed_thing.above),
			under = vector.new(pointed_thing.under),
			ref   = pointed_thing.ref,
		}
		callback(place_to_copy, newnode_copy, placer, oldnode_copy, itemstack, pointed_thing_copy)
	end
end

function waystones.register_waystone(name, def)
	local name_bottom = "waystones:"..name.."_waystone_bottom"
	local name_top    = "waystones:"..name.."_waystone_top"
	local name_item   = "waystones:"..name.."_waystone"

	local name_bottom_activated = "waystones:"..name.."_waystone_bottom_activated"
	local name_top_activated    = "waystones:"..name.."_waystone_top_activated"

	local def_bottom  = table.copy(default_waystone_bottom_def)
	local def_top     = table.copy(default_waystone_top_def)

	local def_bottom_activated = table.copy(default_waystone_bottom_def_activated)
	local def_top_activated = table.copy(default_waystone_top_def_activated)

	local def_item    = table.copy(default_waystone_item_def)

	def_bottom.description                         = def.description
	def_top.description                            = def.description
	def_bottom._doc_items_longdesc                 = def._doc_items_longdesc
	def_top._doc_items_longdesc                    = def._doc_items_longdesc
	def_bottom.tiles                               = def.tiles
	def_top.tiles                                  = def.tiles

	def_bottom_activated.description               = def.description
	def_top_activated.description                  = def.description
	def_bottom_activated._doc_items_longdesc       = def._doc_items_longdesc
	def_top_activated._doc_items_longdesc          = def._doc_items_longdesc
	def_bottom_activated.tiles                     = def.tiles
	def_top_activated.tiles                        = def.tiles

	def_item.inventory_image                       = def.inventory
	def_item.description                           = def.description

	function def_bottom.after_destruct(pos)
		local pos2 = vector.add(pos, vector.new(0, 1, 0))
		local node = minetest.get_node(pos2)
		if node.name == name_top then
			minetest.remove_node(pos2)
			minetest.add_item(pos, def_item)
		end
		waystones.remove_waystone_from_world(pos)
	end

	function def_top.after_destruct(pos)
		local pos2 = vector.add(pos, vector.new(0, -1, 0))
		local node2 = minetest.get_node(pos2)
		if node2.name == name_bottom then
			minetest.dig_node(pos2)
		end
	end

	function def_item.on_place(itemstack, placer, pointed_thing)
		if not pointed_thing.type == "node" or not placer or not placer:is_player() then
			return itemstack
		end

		local pn = placer:get_player_name()
		if minetest.is_protected(pointed_thing.above, pn) and minetest.is_protected(pointed_thing.under, pn) then
			return itemstack
		end

		local new_stack = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if new_stack then
			return new_stack
		end

		local ptu = pointed_thing.under
		local nu = minetest.get_node(ptu)

		local pt
		if minetest.registered_nodes[nu.name] and minetest.registered_nodes[nu.name].buildable_to then
			pt = pointed_thing.under
		else
			pt = pointed_thing.above
		end

		local pt2 = vector.add(pt, vector.new(0, 1, 0))

		local ptname = minetest.get_node(pt).name
		local pt2name = minetest.get_node(pt2).name
		if
			(minetest.registered_nodes[ptname] and not minetest.registered_nodes[ptname].buildable_to) or
			(minetest.registered_nodes[pt2name] and not minetest.registered_nodes[pt2name].buildable_to)
		then
			return itemstack
		end

		minetest.set_node(pt,  {name = name_bottom})
		minetest.set_node(pt2, {name = name_top   })

		if def_bottom.sounds and def_bottom.sounds.place then
			minetest.sound_play(def_bottom.sounds.place, {pos = pt}, true)
		end


		if not minetest.is_creative_enabled(pn) then
			itemstack:take_item()
		end

		--waystones.add_waystone_to_world(pt, waystones.get_new_random_name())
		--waystones.discover_waystone(placer:get_player_name(), pt)

		on_place_node(pt, minetest.get_node(pt), placer,
			nu, itemstack, pointed_thing)
		on_place_node(pt2, minetest.get_node(pt2), placer,
			minetest.get_node(vector.add(ptu, vector.new(0, 1, 0))), itemstack, pointed_thing)

		return itemstack
	end

	function def_bottom.on_righclick(pos, node, clicker, itemstack, pointed_thing)
		if clicker:is_player() then
			minetest.show_formspec(clicker:get_player_name(), "waystones:waystone_init_"..pos.x.."_"..pos.y.."_"..pos.z, "size[5,5]button_exit[0,0;1,1,Test]")
		end
	end

	minetest.register_node(name_bottom, def_bottom)
	minetest.register_node(name_top, def_top)

	minetest.register_node(name_bottom_activated, def_bottom)
	minetest.register_node(name_top_activated, def_top)

	minetest.register_craftitem(name_item, def_item)
	minetest.register_lbm({
		label = "Remove invalids "..name_top,
		name = "waystones:remove_invalids_waystones_"..name.."_top",
		nodenames = {name_top},
		run_at_every_load = true,
		action = function(pos, node)
			local pos2 = vector.add(pos, vector.new(0, -1, 0))
			local node2 = minetest.get_node(pos2)
			if node2.name ~= name_bottom then
				minetest.remove_node(pos)
			end
		end,
	})
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if not string.sub(formname, 1, 9) == "waystones" then
		minetest.chat_send_all("thing2")
		return
	end
	minetest.chat_send_all("formname:"..formname)

	if string.sub(formname, 11, 23) == "waystone_init" then
		local _, _, x, y, z = string.find(formname, "(-?%d+)_(-?%d+)_(-?%d+)")
		local pos = vector.new(tonumber(x), tonumber(y), tonumber(z))
		minetest.chat_send_all(vector.to_string(pos))
	end
	minetest.chat_send_all("thing")
end)

minetest.register_abm({
	label = "Waystone Particles",
	interval = 1,
	chance = 1,
	nodenames = "group:waystone_activated",
	action = function(pos)
		local playernames = {}
		for _, obj in pairs(minetest.get_objects_inside_radius(pos, 15)) do
			if obj:is_player() then
				table.insert(playernames, obj:get_player_name())
			end
		end
		if #playernames < 1 then
			return
		end
		local rp = vector.new(0, 0, 0)
		local t = math.random() + 1 --time
		local d = {x = math.random(), y = math.random() - 0.7, z = math.random()} --distance
		local v = {x = -math.random(), y = math.random(), z = -math.random()} --velocity
		local a = {x = 2*(-v.x*t - d.x)/t/t, y = 2*(-v.y*t - d.y)/t/t, z = 2*(-v.z*t - d.z)/t/t} --acceleration
		local s = math.random() + 0.9 --size
		t = t - 0.1 --slightly decrease time to avoid texture overlappings
		local tx = "mcl_enchanting_glyph_" .. math.random(18) .. ".png"
		for _, name in pairs(playernames) do
			minetest.add_particle({
				pos = pos,
				velocity = v,
				acceleration = a,
				expirationtime = t,
				size = s,
				texture = tx,
				collisiondetection = false,
				playername = name
			})
		end
	end
})

minetest.register_on_joinplayer(function(ObjectRef, last_login)
	minetest.chat_send_all(dump(minetest.registered_nodes["waystones:andesite_waystone_bottom"]))
end)
