local showWindowPanel, update, windows, components = false, 0, {
	[0] = false,
	[1] = false,
	[2] = false,
	[3] = false,
}, {}

local convertSeatIntoName = {
	[4] = "door_lf_dummy",
	[2] = "door_rf_dummy",
	[5] = "door_lr_dummy",
	[3] = "door_rr_dummy",
}

local w, h = 0, 0

function renderWindowPanel()
	local alpha, progress = exports["cr_dx"]:getFade("windowPanel")
	if alpha and progress then 
		if progress >= 1 then 
			if alpha <= 0 then 
				destroyRender("renderWindowPanel", renderWindowPanel)
			end
		end
	end

	if (localPlayer.vehicle) then

		if(update < getTickCount()) then
			update = getTickCount()+100
			components = localPlayer.vehicle:getComponents()
			for i = 0, 3 do
				local state = localPlayer.vehicle:getData("veh >> window"..(convert[i]).."State")
				windows[i] = state
			end
		end

		local _, x, y, _w, _h = exports["cr_interface"]:getDetails("windowPanel")

		local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 14)
		local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 12)

		local fullHeight = 0
		for i = 0, 3 do
			if ((components[convertSeatIntoName[convert[i]]])) then 
				local w2, h2 = 160, 20

				fullHeight = fullHeight + h2 + 5
			end 
		end 
		local w, h = 210, 40 + 10 + 10 + (fullHeight - 5) + 10 + 10

		dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
		boxHover = exports['cr_core']:isInSlot(x,y,w,h)
		dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Ablakok kezelése', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

		closeHover = nil
		if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
			closeHover = true 

			dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
		else 
			dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
		end 

		dxDrawRectangle(x + 15, y + 50, 180, (fullHeight - 5) + 10 + 10, tocolor(41, 41, 41, alpha * 0.9))
		hoverComponent = nil

		local startX, startY = x + 15 + 10, y + 50 + 10
		for i = 0, 3 do
			if ((components[convertSeatIntoName[convert[i]]])) then 
				local name = windowNames2[convert[i]]

				local w2, h2 = 160, 20
				
				local inSlot = isCursorHover(startX, startY, w2, h2)
				local inSlot2 = isCursorHover(startX + w2 - 25 - 5, startY + h2/2 - 12/2, 25, 12)

				if inSlot then 
					dxDrawRectangle(startX, startY, w2, h2, tocolor(242, 242, 242, alpha * 0.8))
					dxDrawText(name, startX + 5, startY, startX + w2, startY + h2 + 4, tocolor(51, 51, 51, alpha), 1, font2, "left", "center")
				else 
					dxDrawRectangle(startX, startY, w2, h2, tocolor(51, 51, 51, alpha * 0.6))
					dxDrawText(name, startX + 5, startY, startX + w2, startY + h2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "left", "center")
				end 

				if windows[i] then 
					dxDrawImage(startX + w2 - 25 - 5, startY + h2/2 - 12/2, 25, 12, 'assets/images/slider-on.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
				else 
					dxDrawImage(startX + w2 - 25 - 5, startY + h2/2 - 12/2, 25, 12, 'assets/images/slider-off.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
				end

				startY = startY + h2 + 5

				if inSlot2 then 
					hoverComponent = i

					exports['cr_dx']:drawTooltip(1, '#F2F2F2' .. (windows[i] and 'Felhúzás' or 'Lehúzás'))
				end
			end
		end
	else
		if showWindowPanel then 
			toggleWindow()
		end 
	end
end

function isCursorHover(x, y, width, height)
	if(not isCursorShowing()) then
		return false
	end
	local sx, sy = guiGetScreenSize()
	local cx, cy = getCursorPosition()
	local cx, cy = (cx*sx), (cy*sy)
	return ((cx >= x and cx <= x+width) and (cy >= y and cy <= y+height))
end


local clickSpam = 0
function checkWindowPanelClick(b, st)
	if(isCursorShowing()) then
		if(st == "down") then
			if clickSpam + 400 < getTickCount() then
				if localPlayer:getData("pulling") then 
					local syntax = exports['cr_core']:getServerSyntax(false, "error");
					outputChatBox(syntax .. "Pullozás közben nem húzhatod fel az ablakot!",255,255,255,true);
					return
				end

				if closeHover then 
					toggleWindow()

					closeHover = nil 
				elseif hoverComponent then 
					if ((components[convertSeatIntoName[convert[hoverComponent]]])) then
						localPlayer.vehicle:setData("veh >> window"..(convert[hoverComponent]).."State", not windows[hoverComponent])

						local text = windowNames[convert[hoverComponent]];

						playSound("assets/sounds/window.mp3");

						if (windows[hoverComponent]) then
							exports['cr_chat']:createMessage(localPlayer, "felhúzza a "..text.." ablakot", 1);
						else
							exports['cr_chat']:createMessage(localPlayer, "lehúzza a "..text.." ablakot", 1);
						end
					end

					hoverComponent = nil
				end

				clickSpam = getTickCount()
			end
		end
	end
end

local spamTimerWindow, windowPanelCheck, checkWindowKeyHold, showWindowPanelTimer = 0, false, false, false;
function toggleWindow()
	if(showWindowPanel) then
		showWindowPanel = false
		
		exports["cr_dx"]:startFade("windowPanel", 
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

		exports['cr_interface']:setNode("windowPanel", "active", false)

		unbindKey("mouse1", "down", checkWindowPanelClick)
		return
	end
    local veh = localPlayer.vehicle;
	if veh then
		if(isTimer(windowPanelCheck)) then killTimer(windowPanelCheck) end
		windowPanelCheck = setTimer(function() 
			if(not getKeyState("F2")) then
				if spamTimerWindow + 500 > getTickCount() then return end
				spamTimerWindow = getTickCount()
				if localPlayer:getData("pulling") then 
					local syntax = exports['cr_core']:getServerSyntax(false, "error");
					outputChatBox(syntax .. "Pullozás közben nem húzhatod fel az ablakot!",255,255,255,true);
					return
				end
				local num = convert[getPedOccupiedVehicleSeat(localPlayer)];
				local convertSeatIntoName = {
					[0] = "door_lf_dummy",
					[1] = "door_rf_dummy",
					[2] = "door_lr_dummy",
					[3] = "door_rr_dummy",
				}
				local windowSeatName = convertSeatIntoName[localPlayer.vehicleSeat]
				if windowSeatName and veh:getComponentVisible(windowSeatName) then
					local windowState = veh:getData("veh >> window"..num.."State");
					veh:setData("veh >> window"..num.."State", not windowState);
					local newWindowState = windowState;
					local text = windowNames[num];
					playSound("assets/sounds/window.mp3");
					if newWindowState then
						exports['cr_chat']:createMessage(localPlayer, "felhúzza a "..text.." ablakot", 1);
					else
						exports['cr_chat']:createMessage(localPlayer, "lehúzza a "..text.." ablakot", 1);
					end
				end
			else
				if(localPlayer.vehicleSeat == 0) then
					checkWindowKeyHold = setTimer(function() 
						if(not getKeyState("F2")) then 
							if(isTimer(checkWindowKeyHold)) then killTimer(checkWindowKeyHold) end
							if(isTimer(showWindowPanelTimer)) then killTimer(showWindowPanelTimer) end
						end
					end, 50, 0)

					showWindowPanelTimer = setTimer(function() 
						if(isTimer(checkWindowKeyHold)) then killTimer(checkWindowKeyHold) end

						local components = localPlayer.vehicle:getComponents()
						for key = 0, 3 do 
							if ((components[convertSeatIntoName[convert[key]]])) then 
								createRender("renderWindowPanel", renderWindowPanel)

								exports["cr_dx"]:startFade("windowPanel", 
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

								exports['cr_interface']:setNode("windowPanel", "active", true)

								showWindowPanel = true
								bindKey("mouse1", "both", checkWindowPanelClick)

								break 
							else 
								return exports["cr_infobox"]:addBox("error", "Ennek a járműnek nincsenek ablakai.")
							end
						end
					end, 1000, 1)
				end
			end
		end, 400, 1)
    end
end
bindKey("F2", "down", toggleWindow);

function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if(x and y and w and h) then
		if(not borderColor) then
			borderColor = tocolor(0, 0, 0, 200);
		end
		if(not bgColor) then
			bgColor = borderColor;
		end
		dxDrawRectangle(x, y, w, h, bgColor, postGUI);
		dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI); -- top
		dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI); -- bottom
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI); -- left
		dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI); -- right
	end
end