function in_array(e, t)
	for _,v in pairs(t) do
		if (v==e) then return true end
	end
	return false
end

function setVehicleWheelStates(veh, r1, r2, r3, r4)
    triggerServerEvent("csetVehicleWheelStates", localPlayer, veh, r1,r2,r3,r4)
end

local vehiclesList = {411,559}
local restrictionMode = "cars"
local pressingUp = false
local pressingDown = false
local isEventHandler = false
local isBurnoutDecreasing = false
local isBurnoutIncreasing = false
local isPopDecreasing = false
local isPopIncreasing = false
local isSpeedEffect = false
local burnPoints = 0
local points = 0
local multipler = 0.007
local alpha=0
local color = tocolor(255,255,0,alpha)
local sx, sy = guiGetScreenSize()

function isVehicleAllowed(veh)
	local allow = false
	if restrictionMode == "cars" then
		if getVehicleType(veh) == "Automobile" or getVehicleType(veh) == "Bike" or getVehicleType(veh) == "Quad" or getVehicleType(veh) == "Monster Truck" then
			allow = true
		end
	elseif restrictionMode == "list" then
		if in_array(getElementModel(veh), vehiclesList) then
			allow = true
		end
	else
		allow = true
	end
	return allow
end


function startAcc()
	local veh = getPedOccupiedVehicle(localPlayer)
	if (veh and getVehicleOccupant(veh, 0)==localPlayer and isVehicleOnGround(veh)) then
		local allow = isVehicleAllowed(veh)
		if (allow) then
			pressingUp=true
			startStopHandler()
		end
	end
end

function stopAcc()
	pressingUp=false
	startStopHandler()
end

function startRev()
    local veh = getPedOccupiedVehicle(localPlayer)
	if (veh and getVehicleOccupant(veh, 0)==localPlayer and isVehicleOnGround(veh)) then
		pressingDown=true
		startStopHandler()
	end
end

function stopRev()
	pressingDown=false
	startStopHandler()
end

function increaseBurnout()
    outputChatBox(burnPoints)
	if burnPoints < 1 then
		burnPoints = burnPoints + multiplier
		if (burnPoints > 1) then
			burnPoints = 0 -- to be sure
			color = tocolor(255, 0, 0, 255)
			--removeEventHandler("onClientRender", getRootElement(), increaseBurnout)
            popRandomTire()
			--isBurnoutIncreasing = false
		end
	else
		color = tocolor(255, 0, 0, 255)
		removeEventHandler("onClientRender", getRootElement(), increaseBurnout)
		isBurnoutIncreasing = false
	end
end

function popRandomTire()
	local veh = getPedOccupiedVehicle(localPlayer)
	if (veh) and getElementSpeed(veh) < 2 then
		local x1,x2,x3,x4 = getVehicleWheelStates(veh)
		local clean = { }
		if (x1==0) then table.insert(clean,"x1") end
		if (x2==0) then table.insert(clean,"x2") end
		if (x3==0) then table.insert(clean,"x3") end
		if (x4==0) then table.insert(clean,"x4") end
		local cleanCount = #clean or 0
        if cleanCount ~= 0 then
            --[[
            if (cleanCount==0) then
                local y1,y2,y3,y4 = getVehicleWheelStates(veh)
                local notRemoved = { }
                --if (y1~=2) then table.insert(notRemoved,"x1") end
                if (y2~=2) then table.insert(notRemoved,"x2") end
                --if (y3~=2) then table.insert(notRemoved,"x3") end
                if (y4~=2) then table.insert(notRemoved,"x4") end
                local notRemovedCount = #notRemoved
                if (notRemovedCount>2) then
                    local tire = math.random(notRemovedCount)
                    local tireToRemove = notRemoved[tire]
                    if (tireToRemove=="x1") then
                        setVehicleWheelStates(veh, -1)
                    elseif (tireToRemove=="x2") then
                        setVehicleWheelStates(veh, -1, 1)
                    elseif (tireToRemove=="x3") then
                        setVehicleWheelStates(veh, -1, -1, -1)
                    elseif (tireToRemove=="x4") then
                        setVehicleWheelStates(veh, -1, -1, -1, 1)
                    end
                end 
            else
            ]]
            local tire = math.random(cleanCount)
            local tireToPop = clean[tire]
            if (tireToPop=="x1") then
                setVehicleWheelStates(veh, 1)
            elseif (tireToPop=="x2") then
                setVehicleWheelStates(veh, -1, 1)
            elseif (tireToPop=="x3") then
                setVehicleWheelStates(veh, -1, -1, 1)
            elseif (tireToPop=="x4") then
                setVehicleWheelStates(veh, -1, -1, -1, 1)
            end
            
            exports['cr_infobox']:addBox("warning", "Túlmelegedett az autód gumija ezért kipukkant!")
		end
	end
end

function startBurnout()
    --setElementData(localPlayer, "bornout", true)
    if not isTimer(bornoutTimer) then
        bornoutTimer = setTimer(
            function()
                points = points + multipler
                --outputChatBox(points)
                if points > 1 then
                    points = 0
                    popRandomTire()
                end
            end, 50, 0
        )
    --[[
    else
        killTimer(bornoutTimer)
        if not isTimer(bornout2Timer) then
            bornout2Timer =  setTimer(
                function()
                    points = points - multipler*5
                    --outputChatBox(points)
                    if points < 0 then
                        points = 0
                        killTimer(bornout2Timer)
                    end
                end, 50 , 0
            )
        end
    ]]        
    end
end

function stopBurnout()
--    setElementData(localPlayer, "bornout", true)
    if isTimer(bornoutTimer) then
        killTimer(bornoutTimer)
    end
    if points > 0 then
        if not isTimer(bornout2Timer) then
            bornout2Timer =  setTimer(
                function()
                    points = points - multipler*5
                    --outputChatBox(points)
                    if points < 0 then
                        points = 0
                        killTimer(bornout2Timer)
                    end
                end, 50 , 0
            )
        end
    end
end

function burnGain()
	local veh = getPedOccupiedVehicle(localPlayer)
	if veh then
		local speed = getElementSpeed(veh) --math.floor(getActualVelocity(veh, getElementVelocity(veh))*100)
		if (speed <= 2) then
			startBurnout()
		else
			stopBurnout()
		end
	end
end

function startStopHandler()
	if (pressingUp and pressingDown) then
		if not isEventHandler then
			addEventHandler("onClientRender", getRootElement(), burnGain)
			isEventHandler = true
		end
	else
		if isEventHandler then
			stopBurnout()
			removeEventHandler("onClientRender", getRootElement(), burnGain)
			isEventHandler = false
		end
	end
end

function fireUp(howMuch)
	local keys = getBoundKeys("accelerate")
	if keys then
		for keyName, state in pairs(keys) do
			bindKey(keyName, "down", startAcc)
			bindKey(keyName, "up", stopAcc)
		end
	end
	
	local keys = getBoundKeys("brake_reverse")
	if keys then
		for keyName, state in pairs(keys) do
			bindKey(keyName, "down", startRev)
			bindKey(keyName, "up", stopRev)
		end
	end
end


function getActualVelocity( element, x, y, z )
	return (x^2 + y^2 + z^2) ^ 0.5
end

function round2(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

--[[
function enterCar(veh, seat)
	if (seat==0) then
		local allow = false
		
		allow=isVehicleAllowed(veh)
		
		if (allow) then
			if (isTimer(alpTimer)) then killTimer(alpTimer) end
			alpTimer = setTimer(function()
				if (alpha >= 255) then
					alpha = 255
					killTimer(alpTimer)
				else
					alpha = alpha+15
				end
			end, 50)
		end
	end
end

function leaveCar(veh, seat)
	if (isTimer(alpTimer)) then killTimer(alpTimer) end
	alpTimer = setTimer(function()
		if (alpha <= 0) then
			alpha = 0
			killTimer(alpTimer)
		else
			alpha = alpha-15
		end
	end, 50)
end


addEventHandler("onClientPlayerVehicleEnter", localPlayer, enterCar)
addEventHandler("onClientPlayerVehicleExit", localPlayer, leaveCar)
]]--

function getElementSpeed( element, unit )
    if isElement( element ) then
        local x,y,z = getElementVelocity( element )
        if unit == "mph" or unit == 1 or unit == "1" then
            return ( x ^ 2 + y ^ 2 + z ^ 2 ) ^ 0.5 * 100
        else
            return ( x ^ 2 + y ^ 2 + z ^ 2 ) ^ 0.5 * 1.8 * 100
        end
    else
        outputDebugString( "Not an element. Can't get speed" )
        return false
    end
end

fireUp()

function getSurfaceVehicleIsOn(vehicle)
    if isElement(vehicle) and (isVehicleOnGround(vehicle) or isElementInWater(vehicle)) then -- Is an element and is touching any surface?
        local cx, cy, cz = getElementPosition(vehicle) -- Get the position of the vehicle
        local gz = getGroundPosition(cx, cy, cz) - 0.001 -- Get the Z position of the ground the vehicle is on (-0.001 because of processLineOfSight)
        local hit, _, _, _, _, _, _, _, surface = processLineOfSight(cx, cy, cz, cx, cy, gz, _, false) -- This will get the material of the thing the car is standing on
        if hit then
            --outputChatBox(tostring(surface))
            return tonumber(surface) -- If everything is correct, stop executing this function and return the surface type
        end
    end
    return false -- If something isn't correct, return false
end

local boundKeys = false
local multipler = 0

local function popRandomTire2()
	local veh = getPedOccupiedVehicle(localPlayer)
	if (veh) then
		local x1,x2,x3,x4 = getVehicleWheelStates(veh)
		local clean = { }
		if (x1==0) then table.insert(clean,"x1") end
		if (x2==0) then table.insert(clean,"x2") end
		if (x3==0) then table.insert(clean,"x3") end
		if (x4==0) then table.insert(clean,"x4") end
		local cleanCount = #clean or 0
        --outputChatBox(cleanCount)
        if cleanCount ~= 0 then
            local tire = math.random(cleanCount)
            --outputChatBox(tire)
            local tireToPop = clean[tire]
            if (tireToPop=="x1") then
                setVehicleWheelStates(veh, 1)
            elseif (tireToPop=="x2") then
                setVehicleWheelStates(veh, -1, 1)
            elseif (tireToPop=="x3") then
                setVehicleWheelStates(veh, -1, -1, 1)
            elseif (tireToPop=="x4") then
                setVehicleWheelStates(veh, -1, -1, -1, 1)
            end
            
            exports['cr_infobox']:addBox("warning", "Az autód gumija kipukkant!")
		end
	end
end

function boundKeysOn()
    if not boundKeys then
        --if isTimer(minusTimer) then killTimer(minusTimer) end
        if isTimer(plusTimer) then killTimer(plusTimer) end
        --multipler = 0
        
        local keys = getBoundKeys("accelerate")
        if keys then
            for keyName, state in pairs(keys) do
                bindKey(keyName, "down", startAcc2)
                if getKeyState(keyName) then
                    startAcc2()
                end
                bindKey(keyName, "up", stopAcc2)
            end
        end
        
        boundKeys = true
    end
end

function boundKeysOff()
    if boundKeys then
        --if isTimer(minusTimer) then killTimer(minusTimer) end
        if isTimer(plusTimer) then killTimer(plusTimer) end
        
        local keys = getBoundKeys("accelerate")
        if keys then
            for keyName, state in pairs(keys) do
                unbindKey(keyName, "down", startAcc2)
                unbindKey(keyName, "up", stopAcc2)
            end
        end
        
        stopAcc2()
        boundKeys = false
    end
end

function startAcc2()
    local veh = getPedOccupiedVehicle(localPlayer)
	if veh then
		--local speed = getElementSpeed(veh) --math.floor(getActualVelocity(veh, getElementVelocity(veh))*100)
        --outputChatBox(speed)
		--if (speed >= 2) then
        if isTimer(minusTimer) then killTimer(minusTimer) end
        if isTimer(plusTimer) then killTimer(plusTimer) end
        plusTimer = setTimer(
            function()
                local veh = getPedOccupiedVehicle(localPlayer)
                if veh then
                    local speed = getElementSpeed(veh) --math.floor(getActualVelocity(veh, getElementVelocity(veh))*100)
                    if (speed >= 2) then
                        multipler = multipler + 0.008
                        --outputChatBox(multipler)
                        if multipler >= 1 then
                            multipler = 0
                            popRandomTire2(getPedOccupiedVehicle(localPlayer))
                        end
                    end
                else
                    multipler = 0
                    if isTimer(minusTimer) then killTimer(minusTimer) end
                    if isTimer(plusTimer) then killTimer(plusTimer) end
                end
            end, 50, 0
        )
        --end
    end
end

function stopAcc2()
    local veh = getPedOccupiedVehicle(localPlayer)
	if veh then
		--local speed = getElementSpeed(veh) --math.floor(getActualVelocity(veh, getElementVelocity(veh))*100)
		--if (speed >= 2) then
        if isTimer(minusTimer) then killTimer(minusTimer) end
        if isTimer(plusTimer) then killTimer(plusTimer) end
        minusTimer = setTimer(
            function()
                local veh = getPedOccupiedVehicle(localPlayer)
                if veh then
                    multipler = multipler - 0.01
                    --outputChatBox("Minusz: "..multipler)
                    if multipler <= 0 then
                        if isTimer(minusTimer) then killTimer(minusTimer) end
                        multipler = 0
                        --popRandomTire2(localPlayer.vehicle)
                    end
                else
                    multipler = 0
                    if isTimer(minusTimer) then killTimer(minusTimer) end
                    if isTimer(plusTimer) then killTimer(plusTimer) end
                end
            end, 50, 0
        )
        --end
    end
end

setTimer(
    function()
        local veh = getPedOccupiedVehicle(localPlayer)
        if veh then
            --outputChatBox(tonumber(getSurfaceVehicleIsOn(veh)))
            if tonumber(getSurfaceVehicleIsOn(veh)) and tonumber(getSurfaceVehicleIsOn(veh)) == 178 then
                boundKeysOn()
                return
            end
        end
        
        boundKeysOff()
    end, 250, 0
)

function getPedOccupiedVehicle(e)
    if getPedOccupiedVehicleSeat(e) == 0 then
        return e.vehicle
    else
        return false
    end
end

--[[
    Car Wheel Blownout reaction
]]
local wheelCache = {}

setTimer(
    function()
        if localPlayer.vehicle then 
            if localPlayer.vehicleSeat == 0 then 
                local x1,x2,x3,x4 = getVehicleWheelStates(localPlayer.vehicle)
                if x1 ~= 0 or x2 ~= 0 or x3 ~= 0 or x4 ~= 0 then 
                    if not wheelCache[localPlayer.vehicle] then 
                        wheelCache[localPlayer.vehicle] = true

                        triggerLatentServerEvent("setVehicleHandling", 5000, false, localPlayer, localPlayer.vehicle, 'maxVelocity', 30)
                        triggerLatentServerEvent("setVehicleHandling", 5000, false, localPlayer, localPlayer.vehicle, 'dragCoeff', 8)
                    end 
                else 
                    if wheelCache[localPlayer.vehicle] then 
                        wheelCache[localPlayer.vehicle] = false

                        exports['cr_handling']:refreshHandling(localPlayer.vehicle, true)
                    end 
                end 
            end 
        end 
    end, 20 * 1000, 0
)