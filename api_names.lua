local math = math
local ipairs = ipairs

local name_generation_mode = minetest.settings:get("waystones.name_generation_mode") or "preset_first"

local custom_waystone_names = minetest.parse_json(minetest.settings:get("waystones.custom_waystone_names") or "[]")

if name_generation_mode == "preset_only" and #custom_waystone_names == 0 then
	minetest.log("warning",
		"[waystones] There is no custom waystone names in config, name generation will fallback to preset_first")
		name_generation_mode = "preset_first"
end

local function resolve_name_duplicates(name)
	local try = name
    local i = 1
	while waystones.used_waystone_names[try] do
		try = name.." "..mcl_enchanting.roman_numerals.toRoman(i)
		i = i + 1
	end
	return try
end

local function get_name_custom(allow_duplicate)
	table.shuffle(custom_waystone_names)
	for _,v in ipairs(custom_waystone_names) do
		if allow_duplicate or waystones.used_waystone_names[v] then
			return v
		end
	end
end

local random_name1 = {
	"Kr", "Ca", "Ra", "Rei", "Mar", "Luk", "Cro", "Cru", "Ray", "Bre", "Zed", "Mor", "Jag", "Mer", "Jar", "Mad", "Cry", "Zur",
	"Mjol", "Zork", "Creo", "Azak", "Azur", "Mrok", "Drak",
}

local random_name2 = {
	"ir", "mi", "air", "sor", "mee", "clo", "red", "cra", "ark", "arc", "mur", "zer", "miri", "lori", "cres", "zoir", "urak",
	"marac", "slamar", "salmar",
}

local random_name3 = {
	"d", "ed", "es", "er", "ark", "arc", "der", "med", "ure", "zur", "mur", "tron", "cred",
}

local function get_name_mrpork(_)
	return random_name1[math.random(#random_name1)]..
		   random_name2[math.random(#random_name2)]..
		   random_name3[math.random(#random_name3)]
end

function waystones.get_new_random_name()
	local name
	if name_generation_mode == "mixed" then
		for _,func in ipairs(table.shuffle({get_name_mrpork, get_name_custom})) do
			local candidate_name = func(false)
			if candidate_name ~= nil then
				name = candidate_name
			end
		end
	elseif name_generation_mode == "random_only" then
		name = get_name_mrpork()
	elseif name_generation_mode == "preset_only" then
		name = get_name_custom(true)
	else
		--preset_first
		for _,func in ipairs({get_name_custom, get_name_mrpork}) do
			local candidate_name = func(false)
			if candidate_name ~= nil then
				name = candidate_name
			end
		end
	end

	--should never the case
	if name == nil then
		name = get_name_mrpork()
	end

	name = resolve_name_duplicates(name)

	waystones.used_waystone_names[name] = true

	return name
end

minetest.register_chatcommand("wname", {
	func = function()
		return true, waystones.get_new_random_name()
	end,
})