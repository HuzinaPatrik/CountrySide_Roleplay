x, y, z = 2214.8024902344, -108.00592041016, 26.484375
c1, c2, c3, c4, c5, c6 = 2219.3239746094, -107.49320220947, 27.167499542236, 2214.8024902344, -108.00592041016, 26.484375, 0, 70
v1, v2, v3, v4, v5, v6 = 2225.4291992188, -108.51540374756, 28.801500320435, 2219.8491210938, -104.56120300293, 26, 0, 70

local renterPed = createPed(222,x, y, z)
setElementRotation(renterPed, 0, 0, 306)
setElementFrozen(renterPed, true)
setElementData(renterPed, "ped >> bikeRent", true)
setElementData(renterPed, "ped.name", "Bob")
setElementData(renterPed, "ped.type", "Biciklibérlő")

local show = false 
selected_veh = 1
can_press = true
show_rent_panel = false

white = tocolor(255, 255, 255, 220)
white_hex = "#FFFFFF"
sx, sy = guiGetScreenSize()
local submenu_show = false

function disablePedDamage()
	cancelEvent()
end
addEventHandler("onClientPedDamage", renterPed, disablePedDamage)

function addRentPedClick(button, state, x, y, wx, wy, wz, clickedElement)
	if clickedElement and getElementType(clickedElement) == "ped" and getElementData(renterPed, "ped >> bikeRent") and not show then
		if button=="left" and state=="down" then
			local lx, ly, lz = getElementPosition(localPlayer)
			local px, py, pz = getElementPosition(renterPed)
			if getDistanceBetweenPoints3D(lx, ly, lz, px, py, pz) <= 3 then
				setCameraToPed()
				setElementData(localPlayer, "hudVisible", false)
				oldState = exports['cr_custom-chat']:isChatVisible()
				exports['cr_custom-chat']:showChat(false)
				show = true

				oAlpha = localPlayer.alpha
				localPlayer.alpha = 0
				pedChatState = true
				createRender("createPedChat", createPedChat)
				exports['cr_dx']:startFade("bikeRent.ped", 
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
				
				can_press = false
				setTimer(function()
					can_press = true
				end, 1100, 1)
			end		
		end
	end
end
addEventHandler ("onClientClick", root, addRentPedClick)

function exitRentPanel()
		setCameraTarget(localPlayer)		
		setElementFrozen(localPlayer, false)
		setElementData(localPlayer, "hudVisible", true)
		toggleAllControls(true)		
		show = false
		exports['cr_custom-chat']:showChat(oldState)
		localPlayer.alpha = oAlpha or 255
		pedChatState = false
		exports['cr_dx']:startFade("bikeRent.ped", 
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
		removeEventHandler("onClientRender", root, vehicleAnimationAndShow)
		destroyRentPanel()
		rot = 0
		selected_veh = 1
		submenu_show = false
		show_rent_panel = false	
		if veh then
			destroyElement(veh)
			veh = nil
		end
end

function pressedKey(button, press)
	if press and button == "backspace" and show and can_press then
	
		exitRentPanel()
		
		can_press = false
		setTimer(function()
			can_press = true
		end, 1100, 1)		
		
	end	
	
	if press and button == "arrow_r" and show and submenu_show and not show_rent_panel then
		selected_veh = selected_veh + 1
		if selected_veh >= #vehicle_list then
			selected_veh = #vehicle_list
		end
		setElementModel(veh,vehicle_list[selected_veh][1])		
	end	
	
	if press and button == "arrow_l" and show and submenu_show and not show_rent_panel then
		selected_veh = selected_veh - 1
		if selected_veh < 1 then
			selected_veh = 1
		end	
		setElementModel(veh,vehicle_list[selected_veh][1])
	end
	
	if press and button == "enter" and show and not submenu_show and can_press then
		can_press = false
		setTimer(function()
			can_press = true
		end, 1100, 1)	
		
		setCameraToVeh()
		createVehicleToPos()
		submenu_show = true
		localPlayer.alpha = oAlpha or 255
		pedChatState = false
		exports['cr_dx']:startFade("bikeRent.ped", 
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

		addEventHandler("onClientRender",root, vehicleAnimationAndShow, false, "low-1")
	end
	
	if press and button == "enter" and show and submenu_show and can_press then
	
		can_press = false
		setTimer(function()
			can_press = true
		end, 1100, 1)
		
		show_rent_panel = true
		
		showRentPanel()
		
	end
end
addEventHandler("onClientKey", root, pressedKey)