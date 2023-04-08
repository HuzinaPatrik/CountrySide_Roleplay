local sx, sy = guiGetScreenSize();
function getVehicles()
	local vehs = {}
	for k, v in pairs(getElementsByType("vehicle")) do
		if v:getData("veh >> owner") == localPlayer:getData("acc >> id") then
			if v:getData("veh >> id") > 0 then 
				if tonumber(v:getData("veh >> faction") or 0) <= 0 then 
					table.insert(vehs, v)
				end 
			end 
		end
	end

	return vehs
end

function getInteriors()
	local interiors = {}
	for k, v in pairs(getElementsByType("marker")) do
		if v:getData("marker >> data") then 
			if v:getData("marker >> data")["owner"] == localPlayer:getData("acc >> id") then
				table.insert(interiors, v)
			end
		end
	end

	return interiors
end

function getRankPayments()
	local data = {}
	local factions = exports['cr_dashboard']:getPlayerFactions(localPlayer)
	local total = 0

	for k, v in pairs(factions) do 
		local factionID = v
		local factionName = exports['cr_dashboard']:getFactionName(factionID)
		local playerFactionRank = exports['cr_dashboard']:getPlayerFactionRank(localPlayer, factionID)
		local payment = exports['cr_dashboard']:getPlayerFactionRankPayment(localPlayer, factionID)

		if payment > 0 then 
			table.insert(data, {id = factionID, name = factionName, value = payment})
			total = total + payment
		end
	end 

	data['total'] = total

	return data
end 

addEventHandler("onClientElementDataChange", root, function(k, o, n) 
	if(getElementType(source) == "player") then
		if(source == localPlayer) then
			if(k == "acc >> id") then
				triggerServerEvent("checkPending", localPlayer, localPlayer)
			elseif(k == "char >> playedtime") then
				if(tonumber(o) and tonumber(o or 0)+1 == tonumber(n)) then
					local hours = n/60
					if(hours == math.floor(hours) and math.floor(hours) >= 1) then
						triggerServerEvent("payDay", localPlayer, localPlayer, getVehicles(), getInteriors(), getRankPayments(), tonumber(localPlayer:getData('char >> playedtime') or 0), exports['cr_bank']:getBankAccountMoney(localPlayer))
					end
				end
			end
		end
	end
end)

local summary, start = {}, false
addEvent("showSummary", true)
addEventHandler("showSummary", root, 
	function(data) 
		if not start then 
			start = true 

			summary = data
			
			local notification = playSound("assets/sounds/notification.mp3")
			notification:setVolume(1)

			bindKey("backspace", "down", closeSummary)
			bindKey("mouse_wheel_up", "down", upMove)
			bindKey("mouse_wheel_down", "down", downMove)

			createRender("renderSummary", renderSummary)

			exports['cr_dx']:startFade("renderSummary", 
				{
					["startTick"] = getTickCount(),
					["lastUpdateTick"] = getTickCount(),
					["time"] = 250,
					["animation"] = "InOutQuad",
					["from"] = 0,
					["to"] = 255,
					["alpha"] = 0,
					["progress"] = 0,
				}
			)

			scrolling = false

			minLines = 1
			maxLines = 7
			_maxLines = maxLines
		end 
	end
)

local lastCall = -1
local lastCallTick = -5000
function closeSummary()
	if start then 
		if exports['cr_network']:getNetworkStatus() then return end 

		start = false 

		unbindKey("backspace", "down", closeSummary)
		unbindKey("mouse_wheel_up", "down", upMove)
		unbindKey("mouse_wheel_down", "down", downMove)

		local now = getTickCount()
		if now <= lastCallTick + 1000 then
			cancelLatentEvent(lastCall)
		end 
		triggerLatentServerEvent("payTotal", 1000, false, localPlayer, localPlayer)
		lastCall = getLatentEventHandles()[#getLatentEventHandles()] 
		lastCallTick = getTickCount()

		exports['cr_dx']:startFade("renderSummary", 
			{
				["startTick"] = getTickCount(),
				["lastUpdateTick"] = getTickCount(),
				["time"] = 250,
				["animation"] = "InOutQuad",
				["from"] = 255,
				["to"] = 0,
				["alpha"] = 255,
				["progress"] = 0,
			}
		)
	end 
end 

function renderSummary()
	local alpha, progress = exports['cr_dx']:getFade("renderSummary")

    if not start then
        if progress >= 1 then
			destroyRender("renderSummary")

			return 
		end 
	end 

	hover = nil

	local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
	local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 14)
	local font3 = exports['cr_fonts']:getFont('Poppins-Medium', 12)

	local w, h = 440, 275
	local w2, h2 = 410, 20
	local x, y = sx/2 - w/2, sy/2 - h/2

	dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
	dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	dxDrawText("Fizetési bizonylat", x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

	if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
		hover = "close"

        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
    else 
        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
    end 

	dxDrawRectangle(x + 5, y + 40, 430, 230, tocolor(41, 41, 41, alpha * 0.9))

	canScroll = false
	if exports['cr_core']:isInSlot(x + 5, y + 40, 430, 230) then 
		canScroll = true 
	end 

	local startX, startY = x + 15, y + 50

	local index, num = 1, 1
	for k,v in ipairs(summary) do 
		if index >= minLines and index <= maxLines then
			if exports['cr_core']:isInSlot(startX, startY, w2, h2) or v.listed then 
				dxDrawRectangle(startX, startY, w2, h2, tocolor(242, 242, 242, alpha * 0.8))
				dxDrawText(v["name"], startX + 5, startY, startX + w2, startY + h2 + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")
				dxDrawText('$ '..v["value"], startX, startY, startX + w2 - 5, startY + h2 + 4, tocolor(51, 51, 51, alpha), 1, font3, "right", "center")

				if v.list and #v.list > 0 then 
					local tWidth = dxGetTextWidth(v["name"], 1, font3)

					local rot = 0 
					if v.listed then 
						rot = 180
					end 

					if exports['cr_core']:isInSlot(startX + 5 + tWidth + 5, startY + h2/2 - 8/2, 14, 8) then 
						hover = k 

						dxDrawImage(startX + 5 + tWidth + 5, startY + h2/2 - 8/2, 14, 8, "assets/images/icon.png", rot, 0, 0, tocolor(51, 51, 51, alpha))
					else 
						dxDrawImage(startX + 5 + tWidth + 5, startY + h2/2 - 8/2, 14, 8, "assets/images/icon.png", rot, 0, 0, tocolor(51, 51, 51, alpha * 0.6))
					end 
				end 
			else 
				dxDrawRectangle(startX, startY, w2, h2, tocolor(51, 51, 51, alpha * 0.6))
				dxDrawText(v["name"], startX + 5, startY, startX + w2, startY + h2 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center")
				dxDrawText('$ '..v["value"], startX, startY, startX + w2 - 5, startY + h2 + 4, v['value'] > 0 and tocolor(97, 177, 90, alpha) or tocolor(255, 59, 59, alpha), 1, font3, "right", "center")

				if v.list and #v.list > 0 then 
					local tWidth = dxGetTextWidth(v["name"], 1, font3)

					if exports['cr_core']:isInSlot(startX + 5 + tWidth + 5, startY + h2/2 - 8/2, 14, 8) then 
						hover = k 

						dxDrawImage(startX + 5 + tWidth + 5, startY + h2/2 - 8/2, 14, 8, "assets/images/icon.png", 0, 0, 0, tocolor(242, 242, 242, alpha))
					else 
						dxDrawImage(startX + 5 + tWidth + 5, startY + h2/2 - 8/2, 14, 8, "assets/images/icon.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
					end 
				end 
			end

			startY = startY + h2 + 5
			num = num + 1
		end 

		if v.listed then 
			if v.list and #v.list > 0 then 
				local listNums = 0
				local nowIndex = index
				for k,v in ipairs(v.list) do 
					nowIndex = nowIndex + 1
					
					if nowIndex >= minLines and nowIndex <= maxLines then
						listNums = listNums + 1
					end 
				end 

				if listNums > 0 then 
					dxDrawRectangle(startX + 4, startY, 2, (listNums * (h2 + 5)) - 5, tocolor(255, 59, 59, alpha))
				end

				for k,v in ipairs(v.list) do 
					index = index + 1

					if index >= minLines and index <= maxLines then
						local w2 = 395

						if exports['cr_core']:isInSlot(startX, startY, w2, h2) then 
							dxDrawRectangle(startX + 15, startY, w2, h2, tocolor(242, 242, 242, alpha * 0.8))
							dxDrawText(v["name"], startX + 15 + 5, startY, startX + 15 + w2, startY + h2 + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")
							dxDrawText('$ '..v["value"], startX + 15, startY, startX + 15 + w2 - 5, startY + h2 + 4, tocolor(51, 51, 51, alpha), 1, font3, "right", "center")
						else 
							dxDrawRectangle(startX + 15, startY, w2, h2, tocolor(51, 51, 51, alpha * 0.6))
							dxDrawText(v["name"], startX + 15 + 5, startY, startX + 15 + w2, startY + h2 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center")
							dxDrawText('$ '..v["value"], startX + 15, startY, startX + 15 + w2 - 5, startY + h2 + 4, v['value'] > 0 and tocolor(97, 177, 90, alpha) or tocolor(255, 59, 59, alpha), 1, font3, "right", "center")
						end

						startY = startY + h2 + 5
						num = num + 1
					end 
				end 
			end 
		end

		index = index + 1
	end 

	--scrollbar
	local percent = math.max(0, index - 1)
        
	if percent >= 1 then
		local gW, gH = 3, 170
		local gX, gY = x + 432, y + 50
		_sX, _sY, _sW, _sH = gX, gY, gW, gH
		
		if scrolling then
			if isCursorShowing() then
				if getKeyState("mouse1") then
					local cx, cy = exports['cr_core']:getCursorPosition()
					local cy = math.min(math.max(cy, _sY), _sY + _sH)
					local y = (cy - _sY) / (_sH)
					local num = percent * y
					minLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _maxLines) + 1)))
					maxLines = minLines + (_maxLines - 1)
				end
			else
				scrolling = false
			end
		end
		
		dxDrawRectangle(gX,gY,gW,gH, tocolor(242,242,242,alpha * 0.6))
		
		local multiplier = math.min(math.max((maxLines - (minLines - 1)) / percent, 0), 1)
		local multiplier2 = math.min(math.max((minLines - 1) / percent, 0), 1)
		local gY = gY + ((gH) * multiplier2)
		local gH = gH * multiplier
		local r,g,b = 255, 59, 59
		dxDrawRectangle(gX, gY, gW, gH, tocolor(r,g,b, alpha))
	end
	--

	if maxLines > (index - 1) then 
		maxLines = math.max(_maxLines, index - 1)
		minLines = maxLines - (_maxLines - 1)
	end

	dxDrawRectangle(x + w/2 - 380/2, startY + 5, 380, 2, tocolor(141, 50, 50, alpha))

	if exports['cr_core']:isInSlot(startX, startY + 5 + 2 + 10, w2, h2) then 
		dxDrawRectangle(startX, startY + 5 + 2 + 10, w2, h2, tocolor(242, 242, 242, alpha * 0.8))
		dxDrawText('Összesen', startX + 5, startY + 5 + 2 + 10, startX + w2, startY + 5 + 2 + 10 + h2 + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")
		dxDrawText('$ '..summary.total, startX, startY + 5 + 2 + 10, startX + w2 - 5, startY + 5 + 2 + 10 + h2 + 4, tocolor(51, 51, 51, alpha), 1, font3, "right", "center")
	else 
		dxDrawRectangle(startX, startY + 5 + 2 + 10, w2, h2, tocolor(51, 51, 51, alpha * 0.6))
		dxDrawText('Összesen', startX + 5, startY + 5 + 2 + 10, startX + w2, startY + 5 + 2 + 10 + h2 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center")
		dxDrawText('$ '..summary.total, startX, startY + 5 + 2 + 10, startX + w2 - 5, startY + 5 + 2 + 10 + h2 + 4, summary.total > 0 and tocolor(97, 177, 90, alpha) or tocolor(255, 59, 59, alpha), 1, font3, "right", "center")
	end
end 

addEventHandler("onClientClick", root, 
	function(b, s)
		if start then 
			if b == "left" and s == "down" then 
				if exports['cr_core']:isInSlot(_sX, _sY, _sW, _sH) then
					scrolling = true

					return
				elseif hover then 
					if hover == "close" then 
						closeSummary()
					else 
						if summary[hover] then 
							summary[hover].listed = not summary[hover].listed
						end 
					end 

					hover = nil 
					return 
				end 
			elseif b == "left" and s == "up" then
                if scrolling then
                    scrolling = false
                end
			end
		end 
	end 
)

function upMove()
	if canScroll then 
		if minLines - 1 >= 1 then
            minLines = minLines - 1
            maxLines = maxLines - 1
        end
	end 
end 

function downMove()
	if canScroll then 
		local index, num = 1, 1
		for k,v in ipairs(summary) do 
			if index >= minLines and index <= maxLines then
				num = num + 1
			end 

			if v.listed then 
				if v.list and #v.list > 0 then 
					for k,v in ipairs(v.list) do 
						index = index + 1

						if index >= minLines and index <= maxLines then
							num = num + 1
						end 
					end 
				end 
			end

			index = index + 1
		end 

		if maxLines + 1 < index then
            minLines = minLines + 1
            maxLines = maxLines + 1
        end
	end 
end 