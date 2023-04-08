local hover, panelState, gVeh, selectedRentTime;

local hunType = {
	["Automobile"] = "Jármű",
	["Plane"] = "Repülő",
	["Bike"] = "Motor",
	["Helicopter"] = "Helikopter",
	["Boat"] = "Hajó",
	["BMX"] = "Bicikli",
	["Quad"] = "Quad",
}

function createPanelForRent()
	local alpha, progress = exports['cr_dx']:getFade("carRent")

	if not panelState then 
		if progress >= 1 then 
			destroyRender("createPanelForRent")

			gVeh = nil 

			return
		end 
	end 

	local font = exports['cr_fonts']:getFont("Poppins-SemiBold", 16)
	local font2 = exports['cr_fonts']:getFont("Poppins-Medium", 14)
	local font3 = exports['cr_fonts']:getFont("Poppins-Medium", 10)

	local w, h = 400, 350
	local x, y = sx/2 - w/2, sy/2 - h/2
	hover = nil
	dxDrawRectangle(x,y,w,h,tocolor(51,51,51,alpha * 0.8))
	dxDrawImage(x + 10, y + 10, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	dxDrawText("Jármű bérlés", x + 10 + 26 + 10,y+10,x+w,y+10+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

	if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
		hover = "close"
		dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
	else 
		dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
	end 

	local green = "#61b15a"
	local white = "#f2f2f2"

	dxDrawText("Jármű típusa: "..green..hunType[getVehicleType(gVeh)]..white.."\nBérleti díj: "..green.."$"..vehicle_list[selected_veh][3].."/perc"..white.."\nKaució: "..green.."$"..vehicle_list[selected_veh][4]..white.."\nBérleti idő:", x + 40, y + 50, x + 40, y + 50, tocolor(242, 242, 242, alpha), 1, font2, "left", "top", false, false, false, true)

	local w2, h2 = 320, 10
	dxDrawRectangle(x + 40, y + 165, w2, h2, tocolor(242, 242, 242, alpha * 0.6))
	local between = (w2 / #rent_time)
	local nowX = x + 40 + between

	for k,v in ipairs(rent_time) do
		if k < 4 then 
			local w3 = 2
			dxDrawRectangle(nowX - w3/2, y + 165, w3, h2, tocolor(110, 110, 110, alpha * 0.6))

			if (selectedRentTime == k) then 
				dxDrawRectangle(nowX - 10/2, y + 165 - 2, 10, h2 + 4, tocolor(255, 59, 59, alpha))
				dxDrawRectangle(nowX - 30/2, y + 165 - 15 - 5, 30, 15, tocolor(242, 242, 242, alpha * 0.6))
				dxDrawText(v.tim .. " p", nowX - 30/2, y + 165 - 15 - 5, nowX + 30/2, y + 165 - 5, tocolor(51, 51, 51, alpha), 1, font3, "center", "center")
			else 
				if exports['cr_core']:isInSlot(nowX - 35/2, y + 165, 35, h2) then 
					if exports['cr_core']:isInSlot(nowX - 10/2, y + 165, 10, h2) then 
						hover = tonumber(k)

						dxDrawRectangle(nowX - 10/2, y + 165, 10, h2, tocolor(255, 59, 59, alpha))
					else 
						dxDrawRectangle(nowX - 10/2, y + 165, 10, h2, tocolor(255, 59, 59, alpha * 0.6))
					end
				end 
			end 

			nowX = nowX + between
		end
	end 

	dxDrawText("A csúszka segítségével kérlek válaszd ki a bérleti időt.", x + 40, y + 180, x + 40, y + 180, tocolor(242, 242, 242, alpha), 1, font3, "left", "top", false, false, false, true)

	dxDrawText("Bérleti díj: "..green.."$"..(vehicle_list[selected_veh][3] * rent_time[selectedRentTime].tim)..white.."\nKaució: "..green.."$"..vehicle_list[selected_veh][4]..white.."\nFizetendő összeg: "..green.."$".. ((vehicle_list[selected_veh][3] * rent_time[selectedRentTime].tim) + vehicle_list[selected_veh][4]), x + 40, y + 205, x + 40, y + 205, tocolor(242, 242, 242, alpha), 1, font2, "left", "top", false, false, false, true)

	if exports['cr_core']:isInSlot(x + 30, y + 290, 340, 35) then 
		hover = "rent"

		dxDrawRectangle(x + 30, y + 290, 340, 35, tocolor(97, 177, 90, alpha))
		dxDrawText("Jármű bérlése", x + 30, y + 290, x + 30 + 340, y + 290 + 35 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
	else 
		dxDrawRectangle(x + 30, y + 290, 340, 35, tocolor(97, 177, 90, alpha * 0.7))
		dxDrawText("Jármű bérlése", x + 30, y + 290, x + 30 + 340, y + 290 + 35 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
	end 
end

addEventHandler("onClientClick", root, 
	function(b, s)
		if panelState then 
			if b == "left" and s == "down" then 
				if hover then 
					if hover == "close" then 
						destroyRentPanel()
					elseif tonumber(hover) then 
						selectedRentTime = tonumber(hover)
					elseif hover == "rent" then 
						if exports['cr_network']:getNetworkStatus() then 
							return 
						end

						if not getElementData(localPlayer,"carrent >> on_rent") or nil then
							local count_price = ((vehicle_list[selected_veh][3] * rent_time[selectedRentTime].tim) + vehicle_list[selected_veh][4])
							if exports['cr_core']:takeMoney(localPlayer, count_price, false) then
								triggerLatentServerEvent("giveMoneyToFaction", 5000, false, localPlayer, localPlayer, 4, math.floor(count_price * 0.05)) -- GOVERMENT MONEY GIVING

								exports['cr_infobox']:addBox("success", "Sikeresen kibéreltél egy járművet!")
								triggerServerEvent("carrent >> giveRentCar", resourceRoot, localPlayer, vehicle_list[selected_veh][1], rent_time[selectedRentTime].tim, vehicle_list[selected_veh][4])
								exitRentPanel()
							else
								exports['cr_infobox']:addBox("error", "Sajnálom, de nincs elég pénzed a bérléshez!")
							end  			 			
						else
							exports['cr_infobox']:addBox("error", "Ameddig van járműved bérelve, nem tudsz újat bérelni!")
						end
					end 

					hover = nil 
					return 
				end
			end 
		end 
	end 
)

function showRentPanel()
	if not panelState then 
		exports['cr_dx']:startFade("carRent", 
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

		panelState = true 
		gVeh = vehicle_list[selected_veh][1]
		selectedRentTime = 1

		createRender("createPanelForRent", createPanelForRent)
	end 
end 

function destroyRentPanel()
	if panelState then 
		exports['cr_dx']:startFade("carRent", 
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

		panelState = false 
	end 
end 