local controlsName = {
	"fire", "next_weapon", "previous_weapon", "forwards", "backwards", "left", "right", "zoom_in", "zoom_out",
	"change_camera", "jump", "sprint", "look_behind", "crouch", "action", "walk", "aim_weapon",
	"enter_exit", "vehicle_fire", "vehicle_secondary_fire", "vehicle_left", "vehicle_right",
	"steer_forward", "steer_back", "accelerate", "brake_reverse", "radio_next", "radio_previous", "radio_user_track_skip", "horn",
	"handbrake", "vehicle_look_left", "vehicle_look_right", "vehicle_look_behind", "vehicle_mouse_look", "special_control_left", "special_control_right",
	"special_control_down", "special_control_up", "enter_passenger"
}

local cache = {}

local priorityData = {
	"low",
	"medium",
	"high",
	"instant"
}

_toggleControl = toggleControl
function toggleControl(controlName, value, priority, reload, byResource)
	if sourceResource then
		byResource = getResourceName(sourceResource)
	end

	if type(priority) == "string" then 
		local breaked 
		for k,v in pairs(priorityData) do 
			if v:lower() == priority:lower() then 
				priority = k 
				breaked = true 
				break 
			end 
		end 

		if not breaked then 
			return 
		end 
	elseif priority > #priorityData then 
		return
	end 
	
	if value then 
		if type(controlName) == "table" then 
			for k, controlName in ipairs(controlName) do 
				refreshControl(controlName, priority, byResource)
			end 

			return true
		else 
			return refreshControl(controlName, priority, byResource)
		end 
	end 

	if byResource then 
		if type(controlName) == "table" then 
			for k, controlName in ipairs(controlName) do 
				if not cache[controlName] then 
					cache[controlName] = {}
				end 
	
				local data = {
					["byResource"] = byResource, 
					["insertTime"] = getTickCount(),
					["priority"] = priority,
				}
	
				local breaked = false
				if cache[controlName] then 
					for k,v in pairs(cache[controlName]) do 
						if v["byResource"]:lower() == data["byResource"]:lower() then 
							if v["priority"] == data["priority"] then 
								breaked = true 
								break 
							end 
						end 
					end 
				end 

				if not breaked then 
					table.insert(cache[controlName], 1, data)
				end 
	
				local minPriority, minInsertTime, selected = -1, -1
				for k,v in pairs(cache[controlName]) do 
					if minPriority < v["priority"] then 
						minPriority = v["priority"]
						selected = k
					elseif minPriority <= v["priority"] then 
						if minInsertTime < v["insertTime"] then 
							minInsertTime = v["insertTime"]
							selected = k 
						end 
					end 
				end 
	
				if selected then 
					local data = cache[controlName][selected]
	
					_toggleControl(controlName, false)
				end 

				if reload then 
					return reloadControl(controlName, priority, byResource)
				end 
			end 
		else 
			if not cache[controlName] then 
				cache[controlName] = {}
			end 

			local data = {
				["byResource"] = byResource, 
				["insertTime"] = getTickCount(),
				["priority"] = priority,
			}

			local breaked = false
			if cache[controlName] then 
				for k,v in pairs(cache[controlName]) do 
					if v["byResource"]:lower() == data["byResource"]:lower() then 
						if v["priority"] == data["priority"] then 
							breaked = true 
							break 
						end 
					end 
				end 
			end 

			if not breaked then 
				table.insert(cache[controlName], 1, data)
			end 

			local minPriority, minInsertTime, selected = -1, -1
			for k,v in pairs(cache[controlName]) do 
				if minPriority < v["priority"] then 
					minPriority = v["priority"]
					selected = k
				elseif minPriority <= v["priority"] then 
					if minInsertTime < v["insertTime"] then 
						minInsertTime = v["insertTime"]
						selected = k 
					end 
				end 
			end 

			if selected then 
				local data = cache[controlName][selected]

				_toggleControl(controlName, false)
			end 

			if reload then 
				return reloadControl(controlName, priority)
			end 
		end 
	end
end 
addEvent("toggleControl", true)
addEventHandler("toggleControl", root, toggleControl)

_toggleAllControls = toggleAllControls
function toggleAllControls(value, priority, byResource)
	if sourceResource then
		byResource = getResourceName(sourceResource)
	end


	if byResource then 
		for k,v in pairs(controlsName) do 
			toggleControl(v, value, priority, true, byResource)
		end 

		_toggleAllControls(value)
	end
end 
addEvent("toggleAllControls", true)
addEventHandler("toggleAllControls", root, toggleAllControls)

function refreshControl(controlName, priority, byResource)
	if cache[controlName] then 
		local data = cache[controlName]
		for k,v in pairs(data) do 
			if v["byResource"]:lower() == byResource:lower() then 
				if v["priority"] == priority then 
					table.remove(cache[controlName], k)
				end 
			end 
		end 

		local minPriority, minInsertTime, selected = priority, -1
		for k,v in pairs(cache[controlName]) do 
			if minPriority < v["priority"] then 
				minPriority = v["priority"]
				selected = k
			elseif minPriority <= v["priority"] then 
				if minInsertTime < v["insertTime"] then 
					minInsertTime = v["insertTime"]
					selected = k 
				end 
			end 
		end 

		if selected then 
			local data = cache[controlName][selected]

			_toggleControl(controlName, false)
		else 
			_toggleControl(controlName, true)
		end 
	end 
end 

function reloadControl(controlName, priority)
	if cache[controlName] then 
		local data = cache[controlName]

		local minPriority, minInsertTime, selected = priority, -1
		for k,v in pairs(cache[controlName]) do 
			if minPriority < v["priority"] then 
				minPriority = v["priority"]
				selected = k
			elseif minPriority <= v["priority"] then 
				if minInsertTime < v["insertTime"] then 
					minInsertTime = v["insertTime"]
					selected = k 
				end 
			end 
		end 

		if selected then 
			local data = cache[controlName][selected]

			_toggleControl(controlName, false)
		else 
			_toggleControl(controlName, true)
		end 
	end 
end 