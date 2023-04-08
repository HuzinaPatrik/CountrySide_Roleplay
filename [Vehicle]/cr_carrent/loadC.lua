x, y, z = 706.88989257812, -473.85684204102, 16.3359375
c1, c2, c3, c4, c5, c6 =  706.82250976562, -476.00549316406, 16.84289932251, 706.84027099609, -475.00772094727, 16.907073974609, 0, 70
v1, v2, v3, v4, v5, v6 = 702.34967041016, -464.03350830078, 19.532800674438, 703.08984375, -463.63076782227, 18.994354248047, 0, 70

local renterPed = createPed(100,x, y, z)
setElementRotation(renterPed, 0, 0, 181)
setElementFrozen(renterPed, true)
setElementData(renterPed, "ped >> carRent", true)
setElementData(renterPed, "ped.name", "John")
setElementData(renterPed, "ped.type", "Autóbérlő")

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
	if clickedElement and getElementType(clickedElement) == "ped" and getElementData(renterPed, "ped >> carRent") and not show then
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
				exports['cr_dx']:startFade("carRent.ped", 
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
		exports['cr_dx']:startFade("carRent.ped", 
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
		exports['cr_dx']:startFade("carRent.ped", 
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