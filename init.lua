
csm_com = {}

local prefix_s = "Kill all humans!" -- A human would never write this.
local prefix_c = "Psst, don't let your master hear this. "
local csm_player_q = "Do you have csm?"
local csm_player_a = "I have csm."

if INIT == "client" then
	local funcs = {}
	local funcsp = {}
	function csm_com.register_on_receive(f, p)
		if p then
			funcsp[p] = funcsp[p] or {}
			funcsp[p][#funcsp[p]+1] = f
		else
			funcs[#funcs+1] = f
		end
	end

	minetest.register_on_receiving_chat_message(function(msg)
		if msg:sub(1, #prefix_c) ~= prefix_c then
			return
		end
		msg = msg:sub(#prefix_c+1)
		for pre, fs in pairs(funcsp) do
			if msg:sub(1, #pre) == pre then
				for i = 1, #fs do
					if fs[i](msg) then
						return true
					end
				end
				break
			end
		end
		for i = 1, #funcs do
			if funcs[i](msg) then
				return true
			end
		end
		return true
	end)

	function csm_com.send(msg)
		minetest.run_server_chatcommand("status", prefix_s..msg)
	end

	local on_know_funcs = {}
	function csm_com.register_on_know(f)
		on_know_funcs[#on_know_funcs+1] = f
	end
	local server_has_mod = false
	minetest.after(0, csm_com.send, csm_player_q)
	csm_com.register_on_receive(function(msg)
		if msg == csm_player_a then
			server_has_mod = true
			for i = 1, #on_know_funcs do
				on_know_funcs[i]()
			end
			return true
		elseif msg == csm_player_q then -- Old.
			server_has_mod = true
			csm_com.send(csm_player_a)
			for i = 1, #on_know_funcs do
				on_know_funcs[i]()
			end
			return true
		end
	end)
	function csm_com.server_has()
		return server_has_mod
	end

elseif INIT == "game" then
	local funcs = {}
	local funcsp = {}
	function csm_com.register_on_receive(f, p)
		if p then
			funcsp[p] = funcsp[p] or {}
			funcsp[p][#funcsp[p]+1] = f
		else
			funcs[#funcs+1] = f
		end
	end

	local status_o = minetest.registered_chatcommands["status"].func
	minetest.override_chatcommand("status", {func = function(name, param)
		if param:sub(1, #prefix_s) ~= prefix_s then
			return status_o(name, param)
		end
		param = param:sub(#prefix_s+1)
		for pre, fs in pairs(funcsp) do
			if param:sub(1, #pre) == pre then
				for i = 1, #fs do
					if fs[i](name, param) then
						return true
					end
				end
				break
			end
		end
		for i = 1, #funcs do
			if funcs[i](name, param) then
				return true
			end
		end
		return false
	end})

	function csm_com.send(player_name, msg)
		minetest.chat_send_player(player_name, prefix_c..msg)
	end

	local on_know_funcs = {}
	function csm_com.register_on_know(f)
		on_know_funcs[#on_know_funcs+1] = f
	end
	local csm_players = {}
	csm_com.register_on_receive(function(name, msg)
		if msg ~= csm_player_q then
			return
		end
		csm_players[name] = true
		csm_com.send(name, csm_player_a)
		for i = 1, #on_know_funcs do
			on_know_funcs[i](name)
		end
		return true
	end)
	minetest.register_on_leaveplayer(function(player, timed_out)
		csm_players[player:get_player_name()] = nil
	end)
	function csm_com.player_has(player_name)
		return csm_players[player_name] or false
	end

else
	error("csm_com is not made for such a use!")
end
