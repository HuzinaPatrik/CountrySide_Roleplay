local state = false
local nowSpeed = false

local allowedTypes = {
    ["Automobile"] = true, 
    ["Bike"] = true, 
    ["Monster Truck"] = true,
    ["Quad"] = true,
    ["Boat"] = true, 
    ["Train"] = true,
}

local vehs = {
    [551] = true,
    [580] = true
}

local function setElementSpeed(element, unit, speed)
	--if (unit == nil) then unit = 1 end
	--if (speed == nil) then speed = 0 end
	speed = tonumber(speed)
	----outputChatBox(speed)
	local acSpeed = math.floor(getElementSpeed(element, "km/h")*1)
	if (acSpeed~=false) then 
		local diff = speed/acSpeed
		local x,y,z = getElementVelocity(element)
		setElementVelocity(element,x*diff,y*diff,z*diff)
		return true
	else
		return false
	end
end

function toggleTempomat()
    --if isTimer(spamTimer) then return end
    --spamTimer = setTimer(function() end, 500, 1)
    if isChatBoxInputActive() then return end
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then
        if getVehicleTowedByVehicle(veh) then return end
        if not allowedTypes[getVehicleType(veh)] then return end
        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
            local speed = getElementSpeed(veh)
            if not state and speed > 10 then
                if not isVehicleOnGround(veh) then
                    local allow = false
                    local modelid = getElementModel(veh)
                    for k,v in pairs(vehs) do
                        allow = true
                    end
                    if not allow then return end
                end
                
                if tonumber(getSurfaceVehicleIsOn(veh)) and tonumber(getSurfaceVehicleIsOn(veh)) == 178 then
                    return
                end
                
                sourceVeh = veh
                nowSpeed = math.floor(getElementSpeed(veh))
                setElementData(veh, "tempomat", true)
                setElementData(veh, "tempomat.speed", nowSpeed)
                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                ----outputChatBox(syntax .. "Tempomat beállítva: " ..nowSpeed.. " km/h", 255,255,255,true)
                addEventHandler("onClientPreRender", root, doingTempo, true, "high")
                --[[
                setTimer(
                    function()
                        local speed = math.floor(getElementSpeed(sourceVeh))
                        --setElementSpeed(sourceVeh, 1, nowSpeed)
                        if speed == nowSpeed then
                            setPedControlState(localPlayer, "accelerate", false)
                            setPedControlState(localPlayer, "brake_reverse", false)
                        elseif speed < nowSpeed then
                            setPedControlState(localPlayer, "accelerate", true)
                            setPedControlState(localPlayer, "brake_reverse", false)
                        elseif speed > nowSpeed then
                            setPedControlState(localPlayer, "accelerate", false)
                            setPedControlState(localPlayer, "brake_reverse", true)
                        end
                    end, 50, 0
                )
                ]]
                state = true
            elseif state then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                --outputChatBox(syntax .. "Tempomat kikapcsolva", 255,255,255,true)
                setElementData(veh, "tempomat", false)
                setElementData(veh, "tempomat.speed", false)
                setPedControlState(localPlayer, "accelerate", false)
                setPedControlState(localPlayer, "brake_reverse", false)
                removeEventHandler("onClientPreRender", root, doingTempo)
                state = false
            end
        end
    end
end

addEventHandler("onClientPlayerVehicleExit", root,
    function(veh, seat)
        if source == localPlayer then
            if state then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                --outputChatBox(syntax .. "Tempomat kikapcsolva", 255,255,255,true)
                setElementData(veh, "tempomat", false)
                setElementData(veh, "tempomat.speed", false)
                setPedControlState(localPlayer, "accelerate", false)
                setPedControlState(localPlayer, "brake_reverse", false)
                removeEventHandler("onClientPreRender", root, doingTempo)
                state = false
            end
        end
    end
)

addEventHandler("onClientElementDataChange", localPlayer, 
    function(dName)
        local value = getElementData(source, dName)
        if dName == "inDeath" then
            if value then
                if state then
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    --outputChatBox(syntax .. "Tempomat kikapcsolva", 255,255,255,true)
                    setElementData(sourceVeh, "tempomat", false)
                    setElementData(sourceVeh, "tempomat.speed", false)
                    setPedControlState(localPlayer, "accelerate", false)
                    setPedControlState(localPlayer, "brake_reverse", false)
                    removeEventHandler("onClientPreRender", root, doingTempo)
                    state = false
                end
            end
        end
    end
)

addEventHandler("onClientElementDestroy", root,
    function()
        if getElementType(source) == "vehicle" then
            local veh = getPedOccupiedVehicle(localPlayer)
            if veh == source then
                if state then
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    --outputChatBox(syntax .. "Tempomat kikapcsolva", 255,255,255,true)
                    setElementData(sourceVeh, "tempomat", false)
                    setElementData(sourceVeh, "tempomat.speed", false)
                    setPedControlState(localPlayer, "accelerate", false)
                    setPedControlState(localPlayer, "brake_reverse", false)
                    removeEventHandler("onClientPreRender", root, doingTempo)
                    state = false
                end
            end
        end
    end
)

bindKey("c", "down", toggleTempomat)
bindKey("accelerate", "down", 
    function()
        if state then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            --outputChatBox(syntax .. "Tempomat kikapcsolva", 255,255,255,true)
            setElementData(sourceVeh, "tempomat", false)
            setElementData(sourceVeh, "tempomat.speed", false)
            setPedControlState(localPlayer, "accelerate", false)
            setPedControlState(localPlayer, "brake_reverse", false)
            removeEventHandler("onClientPreRender", root, doingTempo)
            state = false
        end
    end
)

bindKey("handbrake", "down",
    function()
        if state then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            --outputChatBox(syntax .. "Tempomat kikapcsolva", 255,255,255,true)
            setElementData(sourceVeh, "tempomat", false)
            setElementData(sourceVeh, "tempomat.speed", false)
            setPedControlState(localPlayer, "accelerate", false)
            setPedControlState(localPlayer, "brake_reverse", false)
            removeEventHandler("onClientPreRender", root, doingTempo)
            state = false
        end
    end
)

bindKey("brake_reverse", "down", 
    function()
        if state then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            --outputChatBox(syntax .. "Tempomat kikapcsolva", 255,255,255,true)
            setElementData(sourceVeh, "tempomat", false)
            setElementData(sourceVeh, "tempomat.speed", false)
            setPedControlState(localPlayer, "accelerate", false)
            setPedControlState(localPlayer, "brake_reverse", false)
            removeEventHandler("onClientPreRender", root, doingTempo)
            state = false
        end
    end
)

addEventHandler("onClientVehicleDamage", root,
    function(attacker, weapon, loss)
        local veh = getPedOccupiedVehicle(localPlayer)
        if veh then
            if veh == source then
                local seat = getPedOccupiedVehicleSeat(localPlayer)
                if seat == 0 then
                    if state then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        --outputChatBox(syntax .. "Tempomat kikapcsolva", 255,255,255,true)
                        setElementData(sourceVeh, "tempomat", false)
                        setElementData(sourceVeh, "tempomat.speed", false)
                        setPedControlState(localPlayer, "accelerate", false)
                        setPedControlState(localPlayer, "brake_reverse", false)
                        removeEventHandler("onClientPreRender", root, doingTempo)
                        state = false
                    end
                end
            end
        end
    end
)

bindKey("num_sub", "down",
    function()
        if state then
            if nowSpeed - 2 >= 10 then
                nowSpeed = nowSpeed - 2
                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                ----outputChatBox(syntax .. "Tempomat beállítva: " ..nowSpeed.. " km/h", 255,255,255,true)
                setElementData(sourceVeh, "tempomat.speed", nowSpeed)
            end
        end
    end
)

bindKey("num_add", "down",
    function()
        if state then
            local t = getVehicleHandling(sourceVeh)
            local maxVelocity = t["maxVelocity"]
            if nowSpeed + 2 <= maxVelocity then
                nowSpeed = nowSpeed + 2
                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                ----outputChatBox(syntax .. "Tempomat beállítva: " ..nowSpeed.. " km/h", 255,255,255,true)
                setElementData(sourceVeh, "tempomat.speed", nowSpeed)
            end
        end
    end
)

function getElementSpeed( element )
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if isPedInVehicle(localPlayer) then
        local vx, vy, vz = getElementVelocity(getPedOccupiedVehicle(localPlayer))
        return math.sqrt(vx^2 + vy^2 + vz^2) * 187.5      
    end
    return 0
end

local sx, sy = guiGetScreenSize()

function getSurfaceVehicleIsOn(vehicle)
    if isElement(vehicle) and (isVehicleOnGround(vehicle) or isElementInWater(vehicle)) then -- Is an element and is touching any surface?
        local cx, cy, cz = getElementPosition(vehicle) -- Get the position of the vehicle
        local gz = getGroundPosition(cx, cy, cz) - 0.001 -- Get the Z position of the ground the vehicle is on (-0.001 because of processLineOfSight)
        local hit, _, _, _, _, _, _, _, surface = processLineOfSight(cx, cy, cz, cx, cy, gz, _, false) -- This will get the material of the thing the car is standing on
        if hit then
            ----outputChatBox(tostring(surface))
            return tonumber(surface) -- If everything is correct, stop executing this function and return the surface type
        end
    end
    return false -- If something isn't correct, return false
end

setTimer(
    function()
        if state then
            local veh = getPedOccupiedVehicle(localPlayer)
            if veh and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                ----outputChatBox(tonumber(getSurfaceVehicleIsOn(veh)))
                if tonumber(getSurfaceVehicleIsOn(veh)) and tonumber(getSurfaceVehicleIsOn(veh)) == 178 then
                    --off
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    --outputChatBox(syntax .. "Tempomat kikapcsolva", 255,255,255,true)
                    setElementData(sourceVeh, "tempomat", false)
                    setElementData(sourceVeh, "tempomat.speed", false)
                    setPedControlState(localPlayer, "accelerate", false)
                    removeEventHandler("onClientPreRender", root, doingTempo)
                    state = false
                    return
                end
            end
        end
    end, 250, 0
)

function doingTempo()
    --setPedControlState("")
    if getElementData(sourceVeh, "veh >> engineBroken") or not getElementData(sourceVeh, "veh >> engine") or getElementData(sourceVeh, "veh >> fuel") <= 0 then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        --outputChatBox(syntax .. "Tempomat kikapcsolva", 255,255,255,true)
        setElementData(sourceVeh, "tempomat", false)
        setElementData(sourceVeh, "tempomat.speed", false)
        setPedControlState(localPlayer, "accelerate", false)
        removeEventHandler("onClientPreRender", root, doingTempo)
        state = false
        return
    end
    
    
    --[[if not isVehicleOnGround(veh) then
        local allow = false
        local modelid = getElementModel(veh)
        for k,v in pairs(vehs) do
            allow = true
        end
        if not allow then return end
    end]]
        local speed = math.floor(getElementSpeed(sourceVeh))
        --setElementSpeed(sourceVeh, 1, nowSpeed)
        if speed == nowSpeed or (speed - nowSpeed) == 1 or (nowSpeed - speed) == 1 then
            setPedControlState(localPlayer, "accelerate", false)
            setPedControlState(localPlayer, "brake_reverse", false)
            setElementSpeed(sourceVeh, 1, nowSpeed)
        elseif speed < nowSpeed then
            setPedControlState(localPlayer, "accelerate", true)
            setPedControlState(localPlayer, "brake_reverse", false)
        elseif speed > nowSpeed then
            setPedControlState(localPlayer, "accelerate", false)
            setPedControlState(localPlayer, "brake_reverse", true)
        end
end