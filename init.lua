--[[

  ____   ______ _____       ____  ____   _____
_/ ___\ /  ___//     \    _/ ___\/  _ \ /     \
\  \___ \___ \|  Y Y  \   \  \__(  <_> )  Y Y  \
 \___  >____  >__|_|  /____\___  >____/|__|_|  /
     \/     \/      \/_____/   \/            \/
--]]

local load_time_start = os.clock()
local modname = minetest.get_current_modname()


csm_com = {}

local prefix_s = "Kill all humans!" -- A human would never write this.
local prefix_c = "Psst, don't let your master hear this. "
local csm_player_q = "Do you have csm?"
local csm_player_a = "I have csm."

if INIT == "client" then
	local funcs = {}
	function csm_com.register_on_receive(f)
		funcs[#funcs+1] = f
	end

	minetest.register_on_receiving_chat_message(function(message)
		if message:sub(1, #prefix_c) ~= prefix_c then
			return
		end
		message = message:sub(#prefix_c+1)
		for i = 1, #funcs do
			if funcs[i](message) then
				break
			end
		end
		return true
	end)

	function csm_com.send(msg)
		minetest.run_server_chatcommand("status", prefix_s..msg)
	end

	local server_has_mod = false
	csm_com.register_on_receive(function(msg)
		if msg ~= csm_player_q then
			return
		end
		server_has_mod = true
		csm_com.send(csm_player_a)
		return true
	end)
	function csm_com.server_has()
		return server_has_mod
	end

elseif INIT == "game" then
	local funcs = {}
	function csm_com.register_on_receive(f)
		funcs[#funcs+1] = f
	end

	local funco = minetest.registered_chatcommands["status"].func
	minetest.override_chatcommand("status", {func = function(name, param)
		if param:sub(1, #prefix_s) ~= prefix_s then
			return funco(name, param)
		end
		param = param:sub(#prefix_s+1)
		for i = 1, #funcs do
			if funcs[i](name, param) then
				break
			end
		end
		return false
	end})

	function csm_com.send(player_name, msg)
		minetest.chat_send_player(player_name, prefix_c..msg)
	end

	local csm_players = {}
	minetest.register_on_joinplayer(function(player)
		csm_com.send(player:get_player_name(), csm_player_q)
	end)
	csm_com.register_on_receive(function(name, answer)
		if answer == csm_player_a then
			csm_players[name] = true
			return true
		end
	end)
	minetest.register_on_leaveplayer(function(player, timed_out)
		csm_players[player:get_player_name()] = nil
	end)
	function csm_com.player_has(player_name)
		return csm_players[player_name] or false
	end

else
	print("csm_com is not made for such a use!")
end


local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "["..modname.."] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end
