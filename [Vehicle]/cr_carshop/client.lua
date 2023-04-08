lastClickTick = -500

sx, sy = guiGetScreenSize();
cDetails = {
	hbc = {r = 0, g = 255, b = 0, isGreen = 1}, 
	performanceDetails = true,
	consumptionDetails = false,
	cameraInteraction = true,
	buyPanel = {show = false, tick = 0, alpha = 0},
	colorPanel = {show = false, color = {r = 0, g = 0, b = 0}},
	worldTime = {0, 0},
	position = Vector3(1396.3236083984, 399.78552246094, 19.05),
	marker = false,
	greenBox = false,
	controllerPed = false,
	vehiclePreviewPosition = Vector3(1404.8586425781, 414.01150512695, 20.203125),
	mode = "show",
	isShowing = false,
	selectedBrand = 1,
	changedBrand = {false, used = "none"},
	selectedVehicle = 1,
	vehicle = false,
	preview = {screen = false, rotation = {0, 0, 0}, distance = 5},
	vehDetails = {
		tick = 0,
		values = {
			["maximumVelocity"] = {current = 0, new = 0,},
			["maximumAcceleration"] = {current = 0, new = 0,},
			["maximumTraction"] = {current = 0, new = 0,},
			["maximumBrakes"] = {current = 0, new = 0,},
			["vehicleConsumption"] = {current = 0, new = 0,},
			["vehicleBrand"] = {current = 0, new = 0,},
			["vehicleDrive"] = {current = 0, new = 0,},
			["vehicleFuelType"] = {current = 0, new = 0,},
		},
	},
	screen = {
		source = dxCreateScreenSource(sx, sy),
		viewer = dxCreateScreenSource(sx, sy),
	},
	render = {
		pressed = {false, 0},
		tick = 0,
		animFuncs = {},
		hUp = 0, --69
		hDown = 0, --136
		lineH = 2,
		cashIcon = "",
		bankIcon = "",
		ppIcon = "",
	},
};

local maxDistance = 16 

local colorPalette = {
	[1] = {
		{255, 0, 0}, {150, 50, 150}, {0, 0, 255}, {255, 255, 0}, {255, 255, 255},  {0, 255, 0},
	},
	[2] = {
		
	},
};

function isCursorHover(x, y, width, height)
	if(not isCursorShowing()) then
		return false
	end
	local sx, sy = guiGetScreenSize()
	local cx, cy = getCursorPosition()
	local cx, cy = (cx*sx), (cy*sy)
	return ((cx >= x and cx <= x+width) and (cy >= y and cy <= y+height))
end

alpha, cash, bank, pp = 0, "0 #7cc576$", "0 #7cc576$", "0 #ffa800PP"
function renderCarshop()
	if(cDetails.mode == "show") then
		alpha = interpolateBetween(0, 0, 0, 255, 0, 0, (getTickCount()-cDetails.render.tick)/1000, "InOutQuad")
		cDetails.render.hUp, cDetails.render.hDown = interpolateBetween(0, 0, 0, 69, 0, 0, (getTickCount()-cDetails.render.tick)/500, "InOutQuad"), interpolateBetween(0, 0, 0, 136, 0, 0, (getTickCount()-cDetails.render.tick)/500, "InOutQuad")
	else
		alpha = interpolateBetween(255, 0, 0, 0, 0, 0, (getTickCount()-cDetails.render.tick)/500, "InOutQuad")
		cDetails.render.hUp, cDetails.render.hDown = interpolateBetween(69, 0, 0, 0, 0, 0, (getTickCount()-cDetails.render.tick)/1000, "InOutQuad"), interpolateBetween(136, 0, 0, 0, 0, 0, (getTickCount()-cDetails.render.tick)/1000, "InOutQuad")
	end

	--[[
		Header
	]]

	local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 20)
	local font2 = exports['cr_fonts']:getFont('Poppins-Bold', 15)
	local font3 = exports['cr_fonts']:getFont('Poppins-Bold', 22)
	local font4 = exports['cr_fonts']:getFont('Poppins-Bold', 18)
	local font5 = exports['cr_fonts']:getFont('Poppins-Medium', 13)

	dxDrawRectangle(0, 0, sx, 101, tocolor(51, 51, 51, alpha * 0.8))
	dxDrawRectangle(0, 100, sx, 1, tocolor(255, 59, 59, alpha))

	dxDrawImage(25, 100/2 - 70/2, 60, 70, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

	dxDrawText('Járműkereskedés', 115, 100/2, 115, 100/2 + 4, tocolor(242, 242, 242, alpha), 1, font, "left", "center")

	local startY = 10 

	local hexCode = '#61b15a'
	if playerData['money'] < 0 then 
		hexCode = '#FF3B3B'
	end 
	local moneyText = hexCode .. "$ "..playerData['money']
	local tWidth = dxGetTextWidth(moneyText, 1, font2, true) + 20
	local tHeight = dxGetFontHeight(1, font2)
	dxDrawRectangle(sx - 20 - tWidth, startY, tWidth, tHeight, tocolor(51, 51, 51, alpha * 0.8))
	dxDrawText(moneyText, sx - 20 - tWidth, startY, sx - 20 - tWidth + tWidth, startY + tHeight + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, false, false, true)

	startY = startY + tHeight + 1

	local bankMoney = exports['cr_bank']:getBankAccountMoney(localPlayer)
	local hexCode = exports['cr_core']:getServerColor('yellow', true)
	local r,g,b = exports['cr_core']:getServerColor('yellow')
	if bankMoney < 0 then 
		hexCode = '#FF3B3B'
	end 
	local moneyText = hexCode .. "$ "..bankMoney
	local tWidth = dxGetTextWidth(moneyText, 1, font2, true) + 20 + 20
	local tHeight = dxGetFontHeight(1, font2)
	dxDrawRectangle(sx - 20 - tWidth, startY, tWidth, tHeight, tocolor(51, 51, 51, alpha * 0.8))
	exports['cr_dx']:dxDrawImageWithText(":cr_carshop/files/imgs/cardIcon.png", moneyText, sx - 20 - tWidth + tWidth/2, startY, sx - 20 - tWidth + tWidth, startY + tHeight + 4, tocolor(r,g,b, alpha), tocolor(242, 242, 242, alpha), 20, 15, 1, font2, 5, -2)

	startY = startY + tHeight + 1

	local premiumPoints = playerData['pp']
	local hexCode = exports['cr_core']:getServerColor('orange', true)
	if premiumPoints < 0 then 
		hexCode = '#FF3B3B'
	end 
	local moneyText = hexCode .. premiumPoints .. " PP"
	local tWidth = dxGetTextWidth(moneyText, 1, font2, true) + 20
	local tHeight = dxGetFontHeight(1, font2)
	dxDrawRectangle(sx - 20 - tWidth, startY, tWidth, tHeight, tocolor(51, 51, 51, alpha * 0.8))
	dxDrawText(moneyText, sx - 20 - tWidth, startY, sx - 20 - tWidth + tWidth, startY + tHeight + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, false, false, true)

	--[[
		BG
	]]

	local w, h = 400, 340
	local x, y = sx - w - 20, sy/2 - h/2 
	dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
	dxDrawRectangle(x, y, w, 1, tocolor(255, 59, 59, alpha))
	dxDrawRectangle(x, y + h - 1, w, 1, tocolor(255, 59, 59, alpha))

	dxDrawText(carList[cDetails.selectedBrand].brandName, x + 30, y + 30, x + 30, y + 30, tocolor(242, 242, 242, alpha), 1, font3, "left", "top")
	dxDrawText(exports["cr_vehicle"]:getVehicleName(carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].model):gsub(carList[cDetails.selectedBrand].brandName .. ' ', ''), x + 30, y + 55, x + 30, y + 55, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")

	--[[
		Stats
	]]
	dxDrawText('Végsebesség', x + 30, y + 85, x + 30, y + 85, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")

	dxDrawRectangle(x + 30, y + 110, 300, 15, tocolor(51, 51, 51, alpha * 0.6))
	dxDrawRectangle(x + 31, y + 111, 298, 13, tocolor(242, 242, 242, alpha * 0.6))

	local progress = (getTickCount()-cDetails.vehDetails.tick)
	local val = interpolateBetween(cDetails.vehDetails.values['maximumVelocity'].current, 0, 0, cDetails.vehDetails.values['maximumVelocity'].new, 0, 0, progress/12500, "InOutQuad")
	if(progress >= 1) then
		cDetails.vehDetails.values['maximumVelocity'].current = val
	end

	local percentage = (val/maxPerformance['maximumVelocity'])

	dxDrawRectangle(x + 30, y + 110, 300 * percentage, 15, tocolor(255, 59, 59, alpha))
	dxDrawRectangle(x + 30 + (300 * percentage) - 2, y + 108, 2, 19, tocolor(242, 242, 242, alpha))

	--

	dxDrawText('Tapadás', x + 30, y + 125, x + 30, y + 125, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")

	dxDrawRectangle(x + 30, y + 150, 300, 15, tocolor(51, 51, 51, alpha * 0.6))
	dxDrawRectangle(x + 31, y + 151, 298, 13, tocolor(242, 242, 242, alpha * 0.6))

	local progress = (getTickCount()-cDetails.vehDetails.tick)
	local val = interpolateBetween(cDetails.vehDetails.values['maximumTraction'].current, 0, 0, cDetails.vehDetails.values['maximumTraction'].new, 0, 0, progress/12500, "InOutQuad")
	if(progress >= 1) then
		cDetails.vehDetails.values['maximumTraction'].current = val
	end

	local percentage = (val/maxPerformance['maximumTraction'])

	dxDrawRectangle(x + 30, y + 150, 300 * percentage, 15, tocolor(255, 59, 59, alpha))
	dxDrawRectangle(x + 30 + (300 * percentage) - 2, y + 148, 2, 19, tocolor(242, 242, 242, alpha))

	--

	dxDrawText('Fékek', x + 30, y + 170, x + 30, y + 170, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")

	dxDrawRectangle(x + 30, y + 195, 300, 15, tocolor(51, 51, 51, alpha * 0.6))
	dxDrawRectangle(x + 31, y + 196, 298, 13, tocolor(242, 242, 242, alpha * 0.6))

	local progress = (getTickCount()-cDetails.vehDetails.tick)
	local val = interpolateBetween(cDetails.vehDetails.values['maximumBrakes'].current, 0, 0, cDetails.vehDetails.values['maximumBrakes'].new, 0, 0, progress/12500, "InOutQuad")
	if(progress >= 1) then
		cDetails.vehDetails.values['maximumBrakes'].current = val
	end

	local percentage = (val/maxPerformance['maximumBrakes'])

	dxDrawRectangle(x + 30, y + 195, 300 * percentage, 15, tocolor(255, 59, 59, alpha))
	dxDrawRectangle(x + 30 + (300 * percentage) - 2, y + 193, 2, 19, tocolor(242, 242, 242, alpha))

	--[[
		Price
	]]
	local startY = y + 25

	local hexCode = '#61b15a'
	local moneyText = hexCode .. "$ #333333"..(carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].price)
	local tWidth = dxGetTextWidth(moneyText, 1, font4, true) + 20
	local tHeight = dxGetFontHeight(1, font2)

	dxDrawRectangle(x + w - 40 - tWidth, startY, tWidth, tHeight, tocolor(242, 242, 242, alpha))
	dxDrawText(moneyText, x + w - 40 - tWidth, startY, x + w - 40 - tWidth + tWidth, startY + tHeight + 4, tocolor(51, 51, 51, alpha), 1, font4, "center", "center", false, false, false, true)

	startY = startY + tHeight + 5

	local hexCode = exports['cr_core']:getServerColor('orange', true)
	local moneyText = "#333333" .. (carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].pp) .. hexCode .." PP"
	local tWidth = dxGetTextWidth(moneyText, 1, font4, true) + 20
	local tHeight = dxGetFontHeight(1, font2)

	dxDrawRectangle(x + w - 40 - tWidth, startY, tWidth, tHeight, tocolor(242, 242, 242, alpha))
	dxDrawText(moneyText, x + w - 40 - tWidth, startY, x + w - 40 - tWidth + tWidth, startY + tHeight + 4, tocolor(51, 51, 51, alpha), 1, font4, "center", "center", false, false, false, true)

	--[[
		Desc Stats
	]]
	local limit = tostring(carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].limit).. " db"
	if tonumber(carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].limit) <= 0 then 
		limit = "Korlátlan"
	end 

	local text = 'Fogyasztás: '..(cDetails.vehDetails.values['vehicleConsumption'].new).." L/100KM\nÜzemanyag típusa: "..(cDetails.vehDetails.values['vehicleFuelType'].new).."\nMeghajtás: "..(cDetails.vehDetails.values['vehicleDrive'].new).."\nVégsebesség: "..(cDetails.vehDetails.values['maximumVelocity'].new).." KM/h\nLimit: "..tonumber(exports['cr_vehicle']:getVehicleCounts()[carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].model] or 0).." / "..limit
	dxDrawText(text, x + 30, y + 220, x + 30, y + 220, tocolor(242, 242, 242, alpha), 1, font5, 'left', 'top')

	--[[
		Palette icon
	]]
	paletteIconHover = nil 
	if exports['cr_core']:isInSlot(x + 355, y + 295, 30, 30) or (cDetails.colorPanel.show) then 
		if exports['cr_core']:isInSlot(x + 355, y + 295, 30, 30) then 
			paletteIconHover = true
		end 

		dxDrawImage(x + 355, y + 295, 30, 30, "files/imgs/paletteIcon.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
	else 
		dxDrawImage(x + 355, y + 295, 30, 30, "files/imgs/paletteIcon.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
	end 

	--[[
		Arrows
	]]
	leftArrowHover = nil 
	if exports['cr_core']:isInSlot(x, y - 5 - 30, 50, 30) then 
		leftArrowHover = true 

		dxDrawRectangle(x, y - 5 - 30, 50, 30, tocolor(51, 51, 51, alpha * 0.8))
		dxDrawImage(x + 50/2 - 24/2, y - 5 - 30 + 30/2 - 20/2, 24, 20, "files/imgs/leftArrow.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
	else 
		dxDrawRectangle(x, y - 5 - 30, 50, 30, tocolor(242, 242, 242, alpha * 0.6))
		dxDrawImage(x + 50/2 - 24/2, y - 5 - 30 + 30/2 - 20/2, 24, 20, "files/imgs/leftArrow.png", 0, 0, 0, tocolor(51, 51, 51, alpha * 0.6))
	end 

	rightArrowHover = nil 
	if exports['cr_core']:isInSlot(x + 60, y - 5 - 30, 50, 30) then 
		rightArrowHover = true 

		dxDrawRectangle(x + 60, y - 5 - 30, 50, 30, tocolor(51, 51, 51, alpha * 0.8))
		dxDrawImage(x + 60 + 50/2 - 24/2, y - 5 - 30 + 30/2 - 20/2, 24, 20, "files/imgs/leftArrow.png", 180, 0, 0, tocolor(255, 59, 59, alpha))
	else 
		dxDrawRectangle(x + 60, y - 5 - 30, 50, 30, tocolor(242, 242, 242, alpha * 0.6))
		dxDrawImage(x + 60 + 50/2 - 24/2, y - 5 - 30 + 30/2 - 20/2, 24, 20, "files/imgs/leftArrow.png", 180, 0, 0, tocolor(51, 51, 51, alpha * 0.6))
	end 

	--[[
		Test Drive
	]]
	testDriveHover = nil 
	if exports['cr_core']:isInSlot(x + w - 150, y - 5 - 30, 150, 30) then 
		testDriveHover = true

		dxDrawRectangle(x + w - 150, y - 5 - 30, 150, 30, tocolor(242, 242, 242, alpha * 0.6))

		exports['cr_dx']:dxDrawImageWithText(":cr_carshop/files/imgs/testdriveIcon.png", 'Tesztvezetés', x + w - 150 + 150/2, y - 5 - 30, x + w - 150 + 150/2, y - 5 - 30 + 30 + 4, tocolor(51, 51, 51, alpha), tocolor(51, 51, 51, alpha), 20, 20, 1, font5, 5, -2)
	else 
		dxDrawRectangle(x + w - 150, y - 5 - 30, 150, 30, tocolor(51, 51, 51, alpha * 0.6))

		exports['cr_dx']:dxDrawImageWithText(":cr_carshop/files/imgs/testdriveIcon.png", 'Tesztvezetés', x + w - 150 + 150/2, y - 5 - 30, x + w - 150 + 150/2, y - 5 - 30 + 30 + 4, tocolor(242, 242, 242, alpha * 0.6), tocolor(242, 242, 242, alpha * 0.6), 20, 20, 1, font5, 5, -2)
	end 

	dxDrawRectangle(x + w - 150, y - 5 - 1, 150, 1, tocolor(255, 59, 59, alpha))

	--[[
		Buy button
	]]
	local startY = y + h + 10

	if (cDetails.colorPanel.show) then 
		startY = y + h + 106
	end 

	buyButtonHover = nil 
	if exports['cr_core']:isInSlot(x, startY, w, 30) then 
		buyButtonHover = true 

		dxDrawRectangle(x, startY, w, 30, tocolor(97, 177, 90, alpha))
		dxDrawText('Vásárlás', x, startY, x + w, startY + 30 + 4, tocolor(242, 242, 242, alpha), 1, font5, "center", "center")
	else 
		dxDrawRectangle(x, startY, w, 30, tocolor(97, 177, 90, alpha * 0.7))
		dxDrawText('Vásárlás', x, startY, x + w, startY + 30 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font5, "center", "center")
	end 

	--[[ 
		Color Palette
	]]

	if (cDetails.colorPanel.show) then 
		local y = y + h + 10

		dxDrawRectangle(x, y, w, 86, tocolor(51, 51, 51, alpha * 0.8))
		dxDrawRectangle(x, y, w, 1, tocolor(255, 59, 59, alpha))
		dxDrawRectangle(x, y + 86 - 1, w, 1, tocolor(255, 59, 59, alpha))

		local startX, startY = x + 10, y + 10
		local now = 1
		local line = 1

		paletteHover = nil 
		for i = 1, 12 * 2 do 
			local r,g,b = 23, 23, 23

			if (colorPalette[line][now]) then
				r, g, b = colorPalette[line][now][1], colorPalette[line][now][2], colorPalette[line][now][3]
			end

			if exports['cr_core']:isInSlot(startX, startY, 30, 30) then 
				if (colorPalette[line][now]) then
					paletteHover = {line, now}
				end 

				dxDrawRectangle(startX, startY, 30, 30, tocolor(r, g, b, alpha))
			else 
				dxDrawRectangle(startX, startY, 30, 30, tocolor(r, g, b, alpha * 0.8))
			end 

			now = now + 1 
			startX = startX + 30 + 2

			if now > 12 then 
				now = 1
				line = line + 1
				startX = x + 10
				startY = startY + 30 + 5
			end 
		end 
	end 

	if exports['cr_core']:isInSlot(0, 0, sx, 101) or exports['cr_core']:isInSlot(x, y, w, h) or (cDetails.colorPanel.show) and exports['cr_core']:isInSlot(x, y + h + 10, w, 86) or leftArrowHover or rightArrowHover or buyButtonHover or testDriveHover or isCursorInPanel or exports['cr_dashboard']:isAlertsActive() then
		cDetails.cameraInteraction = false
	else
		cDetails.cameraInteraction = true
	end

	componentHover = nil 
	if isElement(cDetails.vehicle) and not isBuyRender then 
		local cameraX, cameraY, cameraZ = getCameraMatrix()

		for componentName, doorID in pairs(vehicleComponents) do 
			local x, y, z = getVehicleComponentPosition(cDetails.vehicle, componentName, "world")
			if x and y and z then 
				local distance = math.sqrt((cameraX - x) ^ 2 + (cameraY - y) ^ 2 + (cameraZ - z) ^ 2)
				local size = distance / maxDistance
				if distance <= maxDistance then 
					local sx, sy = getScreenFromWorldPosition(x, y, z) 
					if sx and sy then 
						local w, h = 25, 25
						if exports['cr_core']:isInSlot(sx - w/2, sy - h/2, w, h) then 
							componentHover = componentName
							cDetails.cameraInteraction = false 
							dxDrawImage(sx - w/2, sy - h/2, w, h, "files/door.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
						else 
							dxDrawImage(sx - w/2, sy - h/2, w, h, "files/door.png", 0, 0, 0, tocolor(255, 255, 255, alpha * 0.3))
						end 
					end 
				end 
			end 
		end 
	end 
end

function setViewerCar(model)
	cDetails.vehicle:setData('veh >> virtualModellID', nil)

	cDetails.vehicle.model = model <= 611 and model or 411
	if model > 611 then 
		cDetails.vehicle:setData('veh >> virtuaModellID', model)
	end 

	cDetails.vehicle.engineState = false
	cDetails.vehicle.overrideLights = 1
	for i = 0, 6 do
		setVehicleWindowOpen(cDetails.vehicle, i, true)
	end
	cDetails.vehicle.position = cDetails.vehiclePreviewPosition
	cDetails.vehDetails.tick = getTickCount()
	cDetails.vehDetails.values["maximumVelocity"].new = getHandlingProperty(cDetails.vehicle, "maxVelocity") or 0
	cDetails.vehDetails.values["maximumAcceleration"].new = getHandlingProperty(cDetails.vehicle, "engineAcceleration") or 0
	cDetails.vehDetails.values["maximumTraction"].new = getHandlingProperty(cDetails.vehicle, "tractionLoss") or 0
	cDetails.vehDetails.values["maximumBrakes"].new = getHandlingProperty(cDetails.vehicle, "brakeDeceleration") or 0
	cDetails.vehDetails.values["vehicleConsumption"].new = exports["cr_vehicle"]:getVehicleConsumption(carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].model, 100)/2
	cDetails.vehDetails.values["vehicleBrand"].new = carList[cDetails.selectedBrand].brandName
	cDetails.vehDetails.values["vehicleDrive"].new = getHandlingProperty(cDetails.vehicle, "driveType") == "awd" and "Összkerék" or (getHandlingProperty(cDetails.vehicle, "driveType") == "rwd" and "Hátsó kerék" or "Első kerék")
	cDetails.vehDetails.values["vehicleFuelType"].new = getHandlingProperty(cDetails.vehicle, "engineType") == "petrol" and "Benzin" or (getHandlingProperty(cDetails.vehicle, "engineType") == "diesel" and "Dízel" or "Elektromos")
end

function onKey(b, state)
	if(b == "arrow_u") then
		if(state) then
			if isBuyRender then return end 

			if(carList[cDetails.selectedBrand-1]) then
				cDetails.selectedBrand = cDetails.selectedBrand-1
				cDetails.selectedVehicle = 1
				cDetails.render.pressed = {btn = "up", tick = getTickCount()}
				setViewerCar(carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].model)
			end
		end
	elseif(b == "arrow_d") then
		if(state) then
			if isBuyRender then return end 

			if(carList[cDetails.selectedBrand+1]) then
				cDetails.selectedBrand = cDetails.selectedBrand+1
				cDetails.selectedVehicle = 1
				cDetails.render.pressed = {btn = "down", tick = getTickCount()}
				setViewerCar(carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].model)
			end
		end
	elseif(b == "arrow_l") then
		if(state) then
			if isBuyRender then 
				buyUp()
			elseif(cDetails.selectedVehicle > 1) then
				cDetails.selectedVehicle = cDetails.selectedVehicle-1
				cDetails.render.pressed = {btn = "left", tick = getTickCount()}
				setViewerCar(carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].model)
			end
		end
	elseif(b == "arrow_r") then
		if(state) then
			if isBuyRender then 
				buyDown()
			elseif(cDetails.selectedVehicle < #carList[cDetails.selectedBrand].vehicles) then
				cDetails.selectedVehicle = cDetails.selectedVehicle+1
				cDetails.render.pressed = {btn = "right", tick = getTickCount()}
				setViewerCar(carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].model)
			end
		end
	elseif(b == "backspace") then
		if(state) then
			if isBuyRender then 
				destroyBuy()
			elseif(cDetails.isShowing and not isCameraHandler) then
				toggleCarshop()
				cDetails.colorPanel.color = {r = 0, g = 0, b = 0}
			end
		else
			
		end
	elseif(b == "mouse1") then
		if(state) then
			if isBuyRender then return end 
			
			if componentHover then 
				local now = getTickCount()
				local a = 0.4
				if now <= lastClickTick + a * 1000 then
					return
				end

				lastClickTick = getTickCount()

				local num = vehicleComponents[componentHover]
				local openRatio = getVehicleDoorOpenRatio(cDetails.vehicle, num)
				if openRatio == 1 then
					openRatio = 0
				else
					openRatio = 1
				end
				setVehicleDoorOpenRatio(cDetails.vehicle, num, openRatio, 400)
				componentHover = nil 
			elseif leftArrowHover then 
				if(cDetails.selectedVehicle > 1) then
					cDetails.selectedVehicle = cDetails.selectedVehicle-1
					cDetails.render.pressed = {btn = "left", tick = getTickCount()}
					setViewerCar(carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].model)
				end

				leftArrowHover = nil 
			elseif rightArrowHover then 
				if(cDetails.selectedVehicle < #carList[cDetails.selectedBrand].vehicles) then
					cDetails.selectedVehicle = cDetails.selectedVehicle+1
					cDetails.render.pressed = {btn = "right", tick = getTickCount()}
					setViewerCar(carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].model)
				end

				rightArrowHover = nil
			elseif paletteIconHover then 
				cDetails.colorPanel.show = not cDetails.colorPanel.show

				paletteIconHover = nil
			elseif testDriveHover then 
				testDriveHover = nil 

				if exports['cr_network']:getNetworkStatus() then 
					return 
				end 

				local now = getTickCount()
				local a = 1
				if now <= lastClickTick + a * 1000 then
					exports['cr_infobox']:addBox("warning", "Csak "..a.." másodpercenként hajtható végre!")
					return
				end

				lastClickTick = getTickCount()

				triggerEvent("carshop.testDrive", localPlayer)
			elseif buyButtonHover then 
				startVehBuy()

				buyButtonHover = nil 
			elseif (cDetails.colorPanel.show) then
				if paletteHover then 
					local line, now = unpack(paletteHover)

					if (colorPalette[line][now]) then
						r, g, b = colorPalette[line][now][1], colorPalette[line][now][2], colorPalette[line][now][3]

						cDetails.vehicle:setColor(r, g, b, r, g, b, r, g, b)
					end

					paletteHover = nil
				end 
			end
		end
	elseif(b == "enter") then
		if(state) then
			if isBuyRender then 
				buyEnter()
			else 
				startVehBuy()
			end 
		end
	end
end

addEvent('carshop.testDrive.activate', true)
addEventHandler('carshop.testDrive.activate', localPlayer, 
	function()
		triggerLatentServerEvent("testDrive", 5000, false, localPlayer, localPlayer, carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle])
		oData = {cDetails.selectedBrand, cDetails.selectedVehicle}

		if isTimer(clockTimer) then 
			killTimer(clockTimer)
		end 

		minutes = 10
		seconds = 0

		clockTimer = setTimer(
			function()
				seconds = seconds - 1
				if seconds <= 0 then
					seconds = 59
					minutes = minutes - 1
					if minutes < 0 then
						minutes = 10
						seconds = 0

						triggerLatentServerEvent("exitTestDrive", 5000, false, localPlayer, localPlayer)
					end
				end
			end, 1000, 0
		)

		createRender('testDriveTimer', testDriveTimer)

		localPlayer:setData("char >> noDamage", true)
		toggleCarshop()
	end 
)

function formatString(n)
    if n < 10 then
        n = "0" .. n
    end
    return n
end

function testDriveTimer()
    local font = exports['cr_fonts']:getFont("Poppins-SemiBold", 16)
    local minutesS = formatString(minutes)
    local secondsS = formatString(seconds)
    local x, y = sx - 70, sy - 50
    dxDrawText(minutesS .. ":" .. secondsS,x,y+1,x,y+1,tocolor(0,0,0,245),1, font, "center", "top", false, false, false, true) -- Fent
    dxDrawText(minutesS .. ":" .. secondsS,x,y-1,x,y-1,tocolor(0,0,0,245),1, font, "center", "top", false, false, false, true) -- Lent
    dxDrawText(minutesS .. ":" .. secondsS,x-1,y,x-1,y,tocolor(0,0,0,245),1, font, "center", "top", false, false, false, true) -- Bal
    dxDrawText(minutesS .. ":" .. secondsS,x+1,y,x+1,y,tocolor(0,0,0,245),1, font, "center", "top", false, false, false, true) -- Jobb
    local r,g,b = 255,255,255
    if minutes <= 3 then
        r,g,b = 255,87,87
    end
    dxDrawText(minutesS .. ":" .. secondsS, x, y, x, y, tocolor(r,g,b,255), 1, font, "center", "top")
end

function startVehBuy()
	if not isBuyRender then 
		local data = carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle]

		createBuy({
			["tuningName"] = "Jármű",
			["tuningType"] = "vehicle",
			["nextLevel"] = exports["cr_vehicle"]:getVehicleName(carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].model),
			['tuningPrice'] = {data.price, data.price, data.pp},
			["onEnter"] = function(type)
				local data = carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle]

				local tuningPrice = buyCache['tuningPrice']

				if type == 1 then 
					if tonumber(exports['cr_vehicle']:getVehicleCounts()[data.model] or 0) + 1 <= data.limit or data.limit <= 0 then
						if getPlayerVehicles() + 1 <= tonumber(localPlayer:getData("char >> vehicleLimit") or 0) then 
							if tuningPrice[1] == 0 or exports['cr_core']:takeMoney(localPlayer, tuningPrice[1]) then 
								if exports['cr_network']:getNetworkStatus() then 
									return 
								end 
	
								local now = getTickCount()
								local a = 1
								if now <= lastClickTick + a * 1000 then
									exports['cr_infobox']:addBox("warning", "Csak "..a.." másodpercenként hajtható végre!")
									return
								end
	
								lastClickTick = getTickCount()
	
								destroyBuy()
								toggleCarshop()
								exports['cr_vehicle']:makeVehicle(localPlayer, data.model, 0, localPlayer:getData("acc >> id"), toJSON(generatePosition()), toJSON({getVehicleColor(cDetails.vehicle, true)}))
								exports['cr_infobox']:addBox("success", "Sikeresen megvetted a járművet $ "..data.price.." ért")
							else 
								exports['cr_infobox']:addBox("error", "Nincs elég pénzed, hogy megvásárold ezt a kocsit!")
							end 
						else
							exports['cr_infobox']:addBox("error", "Nincs elég slotod, hogy megvásárold ezt a kocsit!")
						end 
					else 
						exports['cr_infobox']:addBox("error", "Ennek a kocsinak megtelt a limitje!")
					end
				elseif type == 2 then 
					if tonumber(exports['cr_vehicle']:getVehicleCounts()[data.model] or 0) + 1 <= data.limit or data.limit <= 0 then
						if getPlayerVehicles() + 1 <= tonumber(localPlayer:getData("char >> vehicleLimit") or 0) then 
							if tuningPrice[2] == 0 or exports['cr_core']:takeMoney(localPlayer, tuningPrice[2], true) then 
								if exports['cr_network']:getNetworkStatus() then 
									return 
								end 
	
								local now = getTickCount()
								local a = 1
								if now <= lastClickTick + a * 1000 then
									exports['cr_infobox']:addBox("warning", "Csak "..a.." másodpercenként hajtható végre!")
									return
								end
	
								lastClickTick = getTickCount()
	
								destroyBuy()
								toggleCarshop()
								exports['cr_vehicle']:makeVehicle(localPlayer, data.model, 0, localPlayer:getData("acc >> id"), toJSON(generatePosition()), toJSON({getVehicleColor(cDetails.vehicle, true)}))
								exports['cr_infobox']:addBox("success", "Sikeresen megvetted a járművet $ "..data.price.." ért")
							else 
								exports['cr_infobox']:addBox("error", "Nincs elég pénz a bankkártyádon, hogy megvásárold ezt a kocsit!")
							end 
						else
							exports['cr_infobox']:addBox("error", "Nincs elég slotod, hogy megvásárold ezt a kocsit!")
						end 
					else 
						exports['cr_infobox']:addBox("error", "Ennek a kocsinak megtelt a limitje!")
					end
				elseif type == 3 then 
					if getPlayerVehicles() + 1 <= tonumber(localPlayer:getData("char >> vehicleLimit") or 0) then 
						if tuningPrice[3] == 0 or localPlayer:getData("char >> premiumPoints") >= tuningPrice[3] then 
							localPlayer:setData("char >> premiumPoints", localPlayer:getData("char >> premiumPoints") - tuningPrice[3])
							if exports['cr_network']:getNetworkStatus() then 
								return 
							end 
	
							local now = getTickCount()
							local a = 1
							if now <= lastClickTick + a * 1000 then
								exports['cr_infobox']:addBox("warning", "Csak "..a.." másodpercenként hajtható végre!")
								return
							end
	
							lastClickTick = getTickCount()
	
							destroyBuy()
							toggleCarshop()
							exports['cr_vehicle']:makeVehicle(localPlayer, data.model, 0, localPlayer:getData("acc >> id"), toJSON(generatePosition()), toJSON({getVehicleColor(cDetails.vehicle, true)}))
							exports['cr_infobox']:addBox("success", "Sikeresen megvetted a járművet "..data.pp.." pp-ért")
						else
							exports['cr_infobox']:addBox("error", "Nincs elég pp-d, hogy megvásárold ezt a kocsit!")
						end 
					else
						exports['cr_infobox']:addBox("error", "Nincs elég slotod, hogy megvásárold ezt a kocsit!")
					end 
				end 
			end 
		})
	end 
end 

local controlTimer = false;
function toggleCarshop()
	if(not isTimer(controlTimer)) then
		cDetails.isShowing = not cDetails.isShowing
		if(cDetails.isShowing) then
			--changeViewerBoxHidingColor(0, 255, 0)

			cDetails.selectedBrand = 1
			cDetails.selectedVehicle = 1

			cDetails.vehDetails = {
				tick = 0,
				values = {
					["maximumVelocity"] = {current = 0, new = 0,},
					["maximumAcceleration"] = {current = 0, new = 0,},
					["maximumTraction"] = {current = 0, new = 0,},
					["maximumBrakes"] = {current = 0, new = 0,},
					["vehicleConsumption"] = {current = 0, new = 0,},
					["vehicleBrand"] = {current = 0, new = 0,},
					["vehicleDrive"] = {current = 0, new = 0,},
					["vehicleFuelType"] = {current = 0, new = 0,},
				},
			}

			if oData then
				cDetails.selectedBrand = oData[1]
				cDetails.selectedVehicle = oData[2]
				localPlayer:setData("char >> noDamage", false)
				oData = nil 
			end

			if isTimer(clockTimer) then 
				killTimer(clockTimer)

				destroyRender('testDriveTimer')
			end 

			--cDetails.worldTime = {getTime()}
			cDetails.vehicle = createVehicle(carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].model <= 611 and carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].model or 411, cDetails.vehiclePreviewPosition)

			if carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].model > 611 then 
				cDetails.vehicle:setData('veh >> virtuaModellID', carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].model)
			end 

			for k,v in pairs(getElementsByType("vehicle", _, true)) do 
				cDetails.vehicle:setCollidableWith(v, false)
			end 
			for k,v in pairs(getElementsByType("player", _, true)) do 
				cDetails.vehicle:setCollidableWith(v, false)
			end 

			cDetails.vehicle:setColor(cDetails.colorPanel.color.r, cDetails.colorPanel.color.g, cDetails.colorPanel.color.b, cDetails.colorPanel.color.r, cDetails.colorPanel.color.g, cDetails.colorPanel.color.b, cDetails.colorPanel.color.r, cDetails.colorPanel.color.g, cDetails.colorPanel.color.b, cDetails.colorPanel.color.r, cDetails.colorPanel.color.g, cDetails.colorPanel.color.b)
			oDatas = {
				["chat"] = exports['cr_custom-chat']:isChatVisible(),
				["hudVisible"] = localPlayer:getData("hudVisible"),
				["keysDenied"] = localPlayer:getData("keysDenied"),
			}
			exports['cr_custom-chat']:showChat(false)
			--cDetails.vehicle:setFrozen(true)
			setViewerCar(carList[cDetails.selectedBrand].vehicles[cDetails.selectedVehicle].model)
			--cDetails.greenBox.dimension = 0
			cDetails.render.tick = getTickCount()
			cDetails.mode = "show"
			showCursor(true)
			cDetails.controllerPed = createPed(0, cDetails.vehiclePreviewPosition)
			cDetails.controllerPed.alpha = 0
			cDetails.controllerPed.vehicle = cDetails.vehicle
			cDetails.controllerPed:setControlState("vehicle_left", true)
			localPlayer:setData("keysDenied", true)
			cameraInit(true)
			dxUpdateScreenSource(cDetails.screen.source)
			localPlayer:setData("hudVisible", false)
			generatePlayerData()
			addEventHandler('onClientElementDataChange', localPlayer, updatePlayerData)
			--addEventHandler("onClientRender", root, renderCarshop)
			createRender("renderCarshop", renderCarshop)
			controlTimer = setTimer(function() 
				cDetails.vehicle.engineState = false
				addEventHandler("onClientKey", root, onKey)
			end, 1000, 1)
		else
			setupViewer(cDetails.vehiclePreviewPosition)
			cDetails.render.tick = getTickCount()
			cDetails.mode = "hide"
			--cDetails.greenBox.dimension = tonumber(localPlayer:getData("acc >> id"))
			cDetails.controllerPed:destroy()
			cameraInit(false)
			controlTimer = setTimer(function() 
				showCursor(false)
				--removeEventHandler("onClientRender", root, renderCarshop)
				destroyRender("renderCarshop")
				removeEventHandler('onClientElementDataChange', localPlayer, updatePlayerData)
				removeEventHandler("onClientKey", root, onKey)
				if(isElement(cDetails.vehicle)) then
					cDetails.vehicle:destroy()
				end
				--setTime(unpack(cDetails.worldTime))
				exports['cr_custom-chat']:showChat(oDatas["chat"])
				localPlayer:setData("keysDenied", oDatas["keysDenied"])
				localPlayer:setData("hudVisible", oDatas["hudVisible"])
			end, 1000, 1)
		end
	end
end 
addEvent("toggleCarshop", true)
addEventHandler("toggleCarshop", root, toggleCarshop)

function init()
	setupViewer(cDetails.vehiclePreviewPosition)
	--[[
	cDetails.greenBox = Object(3471, cDetails.vehiclePreviewPosition)
	cDetails.greenBox:setDoubleSided(true)
	cDetails.greenBox.dimension = math.random(1, 999)]]
	cDetails.marker = createMarker(cDetails.position, "cylinder", 1.2, 255, 59, 59, 0)
	cDetails.marker:setData("marker >> customMarker", true)
	cDetails.marker:setData("marker >> customIconPath", ":cr_carshop/files/icon.png")
end
addEventHandler("onClientResourceStart", resourceRoot, init)

addEventHandler('onClientResourceStop', resourceRoot,
	function()
		if cDetails.isShowing then
			toggleCarshop()
		end
	end 
)

addEventHandler("onClientMarkerHit", root, function(p, md)	
	if(p == localPlayer and md and cDetails.marker == source) then
		if not localPlayer.vehicle then 
			if getDistanceBetweenPoints3D(p.position, source.position) < 2 then 
				toggleCarshop()
			end
		end
	end
end)

playerData = {}
function generatePlayerData()
	playerData = {
		money = localPlayer:getData('char >> money') or 0,
		pp = localPlayer:getData('char >> premiumPoints') or 0,
	}
end 

function updatePlayerData(dName, oValue, nValue)
	if dName == 'char >> money' then 
		playerData.money = nValue
	elseif dName == 'char >> premiumPoints' then 
		playerData.pp = nValue
	end 
end 

local positions = {
	--x, y, z, rx, ry, rz, int, dim
	{1384.5833740234, 427.2314453125, 20.03125, 0, 0, 245, 0, 0},
	{1383.0355224609, 423.36877441406, 20.03125, 0, 0, 245, 0, 0},
	{1381.3381347656, 420.29321289062, 20.03125, 0, 0, 245, 0, 0},
	{1370.1335449219, 396.01281738281, 20.03125, 0, 0, 245, 0, 0},
	{1369.0374755859, 392.5227355957, 20.03125, 0, 0, 245, 0, 0},
	{1367.2841796875, 388.93661499023, 20.03125, 0, 0, 245, 0, 0},
	{1366.1541748047, 385.75421142578, 20.03125, 0, 0, 245, 0, 0},
}

function generatePosition()
	return positions[math.random(1, #positions)]
end 

function getPlayerVehicles()
	local count = 0 

	for k,v in pairs(getElementsByType("vehicle")) do
		if v:getData("veh >> owner") == localPlayer:getData("acc >> id") then
			if v:getData("veh >> id") > 0 then 
				if tonumber(v:getData("veh >> faction") or 0) <= 0 then 
					count = count + 1
				end
			end
		end
	end

	return count
end 