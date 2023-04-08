local screenX, screenY = guiGetScreenSize()

-- ** Responsivity Calculations ** --
reMap = function(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

resp = function(value)
	return value
end

respc = function(value)
	return value
end

responsiveMultiplier = math.min(1, reMap(screenX, 1024, 1920, 0.75, 1))

-- local poppinsBoldFont = dxCreateFont("files/fonts/Poppins-Bold.ttf", resp(28))
-- local poppinsBoldFont19 = dxCreateFont("files/fonts/Poppins-Bold.ttf", resp(19))
-- local poppinsSemiBold = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", resp(12))
-- local poppinsBold16 = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", resp(14))
local vehicleNameFont = dxCreateFont(":cr_interface/hud/files/font2.ttf", 20 * responsiveMultiplier)

local roundedCorner = "files/roundedcorner.png"

local currentVehicle = nil
local circ = false
local vehicleMaxFuelTank = false

local speedoPosition = {screenX-respc(265), screenY-respc(210)}
local iconTable = {
	{
		image = "engine",
		monitoredData = "veh >> engine",
		activeColor = {242, 153, 74},
	},
	{
		image = "handbrake",
		monitoredData = "veh >> handbrake",
		activeColor = {207, 30, 28},
	},
	{
		image = "lights",
		monitoredData = "veh >> light",
		activeColor = {101, 206, 90},
	},
	{
		image = "left",
		monitoredData = "index.left",
		activeColor = {101, 206, 90},
	},
	{
		image = "right",
		monitoredData = "index.right",
		activeColor = {101, 206, 90},
		united = true,
	},
	{
		image = "door",
		monitoredData = "veh >> locked",
		activeColor = {101, 206, 90},
	},
	{
		image = "seatbelt",
		monitoredData = "char >> belt",
		activeColor = {exports.cr_core:getServerColor("green", false)},
	},
}

local monitoredRenderData = {}
local alphaAnimations = {}

local dataToMonitor = {
    ["veh >> tuningData"] = true,
    ["veh >> fuel"] = true,
    ["veh >> odometer"] = true,
    ["veh >> KM/H Color"] = true,
    ["index.both"] = true,
    ["tempomat.speed"] = true,
    ["char >> belt"] = "player"
}

for i = 1, #iconTable do 
    local v = iconTable[i]
    local monitoredData = v.monitoredData

    if monitoredData then 
        if not dataToMonitor[monitoredData] then 
            dataToMonitor[monitoredData] = true
        end
    end
end

local maxAngle = 240
local maxSpeed = 300
local hudVisible = true
local speedoPainting = false
local currentVehicleName = false

function renderSpeedoMeter(positionX, positionY)
	local alpha, progress = exports['cr_dx']:getFade("speedo")
    if not isRender then 
        if progress >= 1 then 
			currentVehicle = nil
            monitoredRenderData = {}
			vehicleMaxFuelTank = false

			if isElement(circ) then 
				circ:destroy()
				circ = nil
			end

			removeEventHandler("onClientElementDataChange", root, handleDataChange)
			destroyRender("activateSpeedoMeter")

            return 
        end  
	end 

    local enabled, positionX, positionY = exports.cr_interface:getDetails("speedo")

    if not speedoPainting then 
		if not hudVisible then return end
	end 

	if not localPlayer.vehicle then 
		if isRender then 
			isRender = false 
	
			exports['cr_dx']:startFade("speedo", 
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

    if enabled then 
        local poppinsBoldFont = exports.cr_fonts:getFont("Poppins-Bold", resp(28))
        local poppinsBoldFont19 = exports.cr_fonts:getFont("Poppins-Bold", resp(19))
        local poppinsSemiBold = exports.cr_fonts:getFont("Poppins-SemiBold", resp(12))
        local poppinsBold16 = exports.cr_fonts:getFont("Poppins-SemiBold", resp(14))

        local speed = getVehicleSpeed()

        positionX = positionX + respc(45)

        if speed then
            speed = math.floor(speed)

            -- # Draw the base of the speedometer
            local calculation = speed / maxSpeed * maxAngle

            local r, g, b = 244, 8, 8
            
            if monitoredRenderData["veh >> KM/H Color"] then 
                local data = monitoredRenderData["veh >> KM/H Color"]
                 
                r, g, b = data[1], data[2], data[3]
            end

            dxDrawRing(positionX, positionY, respc(200), respc(180), 0.025, 150, maxAngle, {200/255,200/255,200/255,alpha / 255}, tocolor(100, 100, 100, 0), false, true)
            dxDrawRing(positionX, positionY, respc(200), respc(180), 0.025, 150, calculation, {r/255,g/255,b/255,alpha / 255}, tocolor(100, 100, 100, 0), false, true)
            -- # Draw the calculated speed and unit
            dxDrawCorrectText(math.ceil(speed), positionX+respc(10), positionY+respc(10), respc(160), respc(115), tocolor(255, 255,255,alpha), 1, poppinsBoldFont, "center", "center")
            dxDrawCorrectText("km/h", positionX+respc(10), positionY+respc(40), respc(160), respc(115), tocolor(255,255,255,alpha), 1, poppinsBoldFont19, "center", "center")
            -- # Draw the nitro circle
            local tuningData = monitoredRenderData["veh >> tuningData"] or {}
            local nitroLevel = tuningData["nitroLevel"] or 0
            local nitroCalculation = nitroLevel / 1 * 210
            local nitroPercentage = math.ceil(nitroCalculation / 210 * 100)
            dxDrawRing(positionX-respc(50), positionY+respc(60), respc(70), respc(70), 0.05, 90, 210, {200/255,200/255,200/255,alpha / 255}, tocolor(100, 100, 100, 0), false, true)
            dxDrawRing(positionX-respc(50), positionY+respc(60), respc(70), respc(70), 0.05, 90, nitroCalculation, {100/255,177/255,245/255,alpha / 255}, tocolor(100, 100, 100, 0), false, true)
            dxDrawCorrectText(nitroPercentage.."%", positionX-respc(60), positionY+respc(45), respc(70), respc(70), tocolor(255,255,255,alpha), 1, poppinsSemiBold, "right", "top")
            dxDrawImage(positionX-respc(30), positionY+respc(80), respc(30), respc(30), "files/nitro.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
            -- # Draw the fuel circle

            local ceiledFuel = math.ceil((monitoredRenderData["veh >> fuel"] or 100))
            local fuelCalculation = math.min(210, ceiledFuel / vehicleMaxFuelTank * 210)
            local fuelPercentage = math.min(100, math.ceil(ceiledFuel / vehicleMaxFuelTank * 100))

            dxDrawRing(positionX+respc(155), positionY+respc(60), respc(70), respc(70), 0.05, 90, 210, {200/255, 200/255, 200/255, alpha / 255}, tocolor(100, 100, 100, 0), false, true, 1)
            dxDrawRing(positionX+respc(155), positionY+respc(60), respc(70), respc(70), 0.05, 90, fuelCalculation, {r/255, g/255, b/255, alpha / 255}, tocolor(100, 100, 100, 0), false, true, 1)
            dxDrawCorrectText(fuelPercentage.."%", positionX+respc(165), positionY+respc(45), respc(70), respc(70), tocolor(255,255,255,alpha), 1, poppinsSemiBold, "left", "top")
            dxDrawImage(positionX+respc(177), positionY+respc(80), respc(30), respc(30), "files/fuel.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
            -- # Draw the actual gear of vehicle
            local vehicleGear = getVehicleCurrentGear(currentVehicle)
            dxDrawRoundedCornersRectangle("full", 10, positionX+respc(60), positionY+respc(130), respc(55), respc(25), roundedCorner, tocolor(150,150,150,alpha))
            dxDrawCorrectText(vehicleGear, positionX+respc(50), positionY+respc(132), respc(55), respc(25), tocolor(255,255,255,alpha), 1, poppinsBoldFont19, "right", "center")
            dxDrawImage(positionX+respc(65), positionY+respc(132), respc(20), respc(20), "files/gear.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
            -- # Draw the kms of the vehicle
            local vehicleKilometers = math.ceil((monitoredRenderData["veh >> odometer"] or 100000))
            dxDrawRoundedCornersRectangle("full", 10, positionX+respc(125), positionY+respc(135), respc(100), respc(20), roundedCorner, tocolor(150,150,150,alpha))
            dxDrawCorrectText(vehicleKilometers.." km", positionX+respc(125), positionY+respc(137), respc(100), respc(20), tocolor(255,255,255,alpha), 1, poppinsBold16, "center", "center")
            -- # Draw the icons

            local nowTick = getTickCount()

            for i = 1, #iconTable do
                local data = iconTable[i]
                local iconColor = {255, 255, 255}

                if data.monitoredData == "char >> belt" then 
                    if not monitoredRenderData["char >> belt"] then 
                        iconColor = {255, 179, 0}

                        if not alphaAnimations["char >> belt"] then 
                            alphaAnimations["char >> belt"] = {startTick = getTickCount(), state = "fadeIn", alpha = 0}
                        end

                        local alphaData = alphaAnimations["char >> belt"]

                        if alphaData.state == "fadeIn" then 
                            local elapsedTime = nowTick - alphaData.startTick
                            local duration = 500
                            local progress = elapsedTime / duration

                            alphaData.alpha = interpolateBetween(100, 0, 0, alpha, 0, 0, progress, "InOutQuad")

                            if progress >= 1 then 
                                alphaData.state = "fadeOut"
                                alphaData.startTick = getTickCount()
                            end
                        elseif alphaData.state == "fadeOut" then
                            local elapsedTime = nowTick - alphaData.startTick
                            local duration = 500
                            local progress = elapsedTime / duration

                            alphaData.alpha = interpolateBetween(alpha, 0, 0, 100, 0, 0, progress, "InOutQuad")

                            if progress >= 1 then 
                                alphaData.state = "fadeIn"
                                alphaData.startTick = getTickCount()
                            end
                        end
                    else
                        if alphaAnimations["char >> belt"] then 
                            alphaAnimations["char >> belt"] = nil
                        end
                    end
                end

                if data.monitoredData and monitoredRenderData[data.monitoredData] then
                    iconColor = data.activeColor
                end

                if data.image == "engine" and getElementHealth(currentVehicle) <= 550 then
                    iconColor = data.activeColor
                end

                local animAlpha = alphaAnimations[data.monitoredData] and alphaAnimations[data.monitoredData].alpha or 255

                dxDrawImage(positionX-respc(10) + (i-1) * respc(30), positionY+respc(165), respc(24), respc(24), "files/circle.png",0,0,0,tocolor(100,100,100,alpha))
                dxDrawImage(positionX-respc(8) + (i-1) * respc(30), positionY+respc(167), respc(20), respc(20), "files/"..data.image..".png",0,0,0,tocolor(iconColor[1],iconColor[2],iconColor[3], math.min(alpha, animAlpha)))
            end
        end
    end

    renderVehicleName()
end

function renderVehicleName()
    local alpha, progress = exports['cr_dx']:getFade("speedo")
    local enabled, positionX, positionY, positionW, positionH = exports.cr_interface:getDetails("vehname")

    if not enabled then 
        return
    end

    -- local font = exports.cr_fonts:getFont("Poppins-Medium", resp(16))
    local text = currentVehicleName
    local tempomatText = false

    local hexColor = exports.cr_core:getServerColor("yellow", true)
    local white = "#ffffff"

    if monitoredRenderData["tempomat.speed"] then 
        tempomatText = "Tempomat: " .. hexColor .. monitoredRenderData["tempomat.speed"] .. white .. " km/h"
    end

    shadowedText(text:gsub("#......", ""), positionX, positionY, positionX + positionW, positionY + positionH, tocolor(255, 255, 255, alpha), 1, vehicleNameFont, "center", "center", alpha)
    dxDrawText(text, positionX, positionY, positionX + positionW, positionY + positionH, tocolor(255, 255, 255, alpha), 1, vehicleNameFont, "center", "center", false, false, false, true)

    if tempomatText then 
        shadowedText(tempomatText:gsub("#......", ""), positionX, positionY - respc(65), positionX + positionW, positionY + positionH, tocolor(255, 255, 255, alpha), 1, vehicleNameFont, "center", "center", alpha)
        dxDrawText(tempomatText, positionX, positionY - respc(65), positionX + positionW, positionY + positionH, tocolor(255, 255, 255, alpha), 1, vehicleNameFont, "center", "center", false, false, false, true)
    end
end

function activateSpeedoMeter()
	if currentVehicle then
		renderSpeedoMeter(speedoPosition[1], speedoPosition[2])
	end
end

function initSpeedoAssets(vehicle)
    if isElement(vehicle) then 
        monitoredRenderData = {}

        for k, v in pairs(dataToMonitor) do 
            if v == "player" then 
                monitoredRenderData[k] = localPlayer:getData(k)
            else
                monitoredRenderData[k] = vehicle:getData(k)
            end
        end

        if isElement(circ) then 
            circ:destroy()
            circ = nil
        end

        circ = dxCreateShader("files/circle.fx")
        vehicleMaxFuelTank = exports.cr_vehicle:getVehicleMaxFuel(vehicle.model)
        currentVehicleName = exports.cr_vehicle:getVehicleName(vehicle)

        addEventHandler("onClientElementDataChange", root, handleDataChange)
    end
end

function destroySpeedoAssets()
	if isRender then 
		isRender = false 

		exports['cr_dx']:startFade("speedo", 
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

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), function()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle then
		currentVehicle = vehicle

		if not isRender and getVehicleType(currentVehicle) ~= "BMX" then 
			isRender = true 

			exports['cr_dx']:startFade("speedo", 
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
				
			createRender("activateSpeedoMeter", activateSpeedoMeter)
		end 

        initSpeedoAssets(currentVehicle)
	end
end)

addEventHandler("onClientVehicleEnter", root, function(player, seat)
	if player == localPlayer and (seat == 0 or seat == 1) then
		currentVehicle = source

		if not isRender and getVehicleType(currentVehicle) ~= "BMX" then 
			isRender = true 

			exports['cr_dx']:startFade("speedo", 
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
				
            initSpeedoAssets(currentVehicle)
			createRender("activateSpeedoMeter", activateSpeedoMeter)
		end 
	end
end)

addEventHandler("onClientVehicleExit", root, function(player)
	if player == localPlayer and isRender then
        destroySpeedoAssets()
	end
end)

function onClientElementDestroy()
    if currentVehicle == source then 
        destroySpeedoAssets()
    end
end
addEventHandler("onClientElementDestroy", root, onClientElementDestroy)

function handleDataChange(dataName, oldValue, newValue)
    if source.type == "vehicle" then 
        if currentVehicle == source then 
            if dataToMonitor[dataName] then 
                if dataName == "index.both" then 
                    monitoredRenderData["index.left"] = source:getData(dataName)
                    monitoredRenderData["index.right"] = source:getData(dataName)
                else
                    monitoredRenderData[dataName] = source:getData(dataName)
                end
            end
        end
    elseif source.type == "player" and source == localPlayer then
        if dataToMonitor[dataName] then 
            monitoredRenderData[dataName] = source:getData(dataName)
        elseif dataName == "hudVisible" then
            hudVisible = newValue
		elseif dataName == 'tuning >> speedoColor' then
			speedoPainting = newValue
        end
    end
end

-- ## Asset functions ## --

function getVehicleSpeed()
    if isElement(currentVehicle) then
	    local vx, vy, vz = getElementVelocity(currentVehicle)
	    return math.sqrt(vx^2 + vy^2 + vz^2) * 187.5
    end

    return false
end

function dxDrawRing (posX, posY, width, height, thick, startAngle, amount, color, bgcolor, postGUI, absoluteAmount, direction, radius)
	if circ then
		direction = direction or -1
		if direction > 1 then
			direction = 1
		end
		radius = radius or 0.4
		dxSetShaderValue(circ,"thickness",thick)
		dxSetShaderValue(circ,"radius",radius)
		dxSetShaderValue(circ,"antiAliased",0.005)
		dxSetShaderValue(circ,"direction",direction)

		if absoluteAmount then
			dxSetShaderValue(circ,"progress",{0,amount/360})
		else
			dxSetShaderValue(circ,"progress",{0,amount})
		end
		if amount == 0 then
		   dxSetShaderValue(circ,"indicatorColor",{0,0,0,0})
		else
		   dxSetShaderValue(circ,"indicatorColor",color)
		end
		dxDrawImage(posX,posY,height,height,circ,startAngle,0,0,bgcolor,postGUI)
	end
end

function dxDrawCorrectText(text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, hex)
  dxDrawText(text, left, top, left+right, top+bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, hex)
end

function dxDrawRoundedCornersRectangle(alignment, cornerSize, x, y, width, height, cornerImage, ...)
	if not (alignment and cornerSize and x and y and width and height and cornerImage) then
		return
	end

	if width < cornerSize * 2 then
		width = cornerSize * 2
	end

	if height < cornerSize * 2 then
		height = cornerSize * 2
	end

	if not isElement(cornerImage) then
		dxDrawRectangle(x, y, width, height, ...)
		return
	end

	if alignment == "full" or alignment == "top" then
		exports.cr_dx:dxDrawImageAsTexture(x, y, cornerSize, cornerSize, cornerImage, 0, 0, 0, ...)
		exports.cr_dx:dxDrawImageAsTexture(x + cornerSize + (width - cornerSize * 2), y, cornerSize, cornerSize, cornerImage, 90, 0, 0, ...)
		dxDrawRectangle(x + cornerSize, y, width - cornerSize * 2, cornerSize, ...)
	end

	if alignment == "top" then
		dxDrawRectangle(x, y + cornerSize, width, height - cornerSize, ...)
	end

	if alignment == "full" or alignment == "bottom" then
		exports.cr_dx:dxDrawImageAsTexture(x, y + height - cornerSize, cornerSize, cornerSize, cornerImage, 270, 0, 0, ...)
		exports.cr_dx:dxDrawImageAsTexture(x + cornerSize + (width - cornerSize * 2), y + height - cornerSize, cornerSize, cornerSize, cornerImage, 180, 0, 0, ...)
		dxDrawRectangle(x + cornerSize, y + height - cornerSize, width - cornerSize * 2, cornerSize, ...)
	end

	if alignment == "left" then
		exports.cr_dx:dxDrawImageAsTexture(x, y, cornerSize, cornerSize, cornerImage, 0, 0, 0, ...)
		exports.cr_dx:dxDrawImageAsTexture(x, y + height - cornerSize, cornerSize, cornerSize, cornerImage, 270, 0, 0, ...)
		dxDrawRectangle(x + cornerSize, y, width - cornerSize * 2, cornerSize, ...)
		dxDrawRectangle(x + cornerSize, y + height - cornerSize, width - cornerSize * 2, cornerSize, ...)
		dxDrawRectangle(x+width-cornerSize, y, cornerSize, height, ...)
		dxDrawRectangle(x, y + cornerSize, width, height - cornerSize * 2, ...)
	end

	if alignment == "right" then
		exports.cr_dx:dxDrawImageAsTexture(x + cornerSize + (width - cornerSize * 2), y, cornerSize, cornerSize, cornerImage, 90, 0, 0, ...)
		exports.cr_dx:dxDrawImageAsTexture(x + cornerSize + (width - cornerSize * 2), y + height - cornerSize, cornerSize, cornerSize, cornerImage, 180, 0, 0, ...)
		dxDrawRectangle(x + cornerSize, y + height - cornerSize, width - cornerSize * 2, cornerSize, ...)
		dxDrawRectangle(x, y + cornerSize, width, height - cornerSize * 2, ...)
		dxDrawRectangle(x + cornerSize, y, width - cornerSize * 2, cornerSize, ...)
		dxDrawRectangle(x, y, cornerSize, height, ...)
	end

	if alignment == "bottom" then
		dxDrawRectangle(x, y, width, height - cornerSize, ...)
	end

	if alignment == "full" then
		dxDrawRectangle(x, y + cornerSize, width, height - cornerSize * 2, ...)
	end
end

function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY, alpha)
    dxDrawText(text,x,y+1,w,h+1,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY);
    dxDrawText(text,x,y-1,w,h-1,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY);
    dxDrawText(text,x-1,y,w-1,h,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY);
    dxDrawText(text,x+1,y,w+1,h,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY);
end