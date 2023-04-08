local loadTimer
addEvent("loadedVehs", true)
addEventHandler("loadedVehs", root,
    function()
        if isTimer(loadTimer) then
            killTimer(loadTimer)
        end
        
        loadTimer = setTimer(triggerLatentServerEvent, 2500, 1, "loadPlayerVehicles", 5000, false, localPlayer, localPlayer)
    end
)

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName, oValue, nValue)
        if dName == "loggedIn" and nValue then
            if isTimer(loadTimer) then
                killTimer(loadTimer)
            end
        
            loadTimer = setTimer(triggerLatentServerEvent, 7500, 1, "loadPlayerVehicles", 5000, false, localPlayer, localPlayer)
        end
    end
)

--Vehicle betöltése
local state, cache = false, {}

function exist(e)
    for k,v in pairs(cache) do
        if v[1] == e then
            return true
        end
    end

    return false
end

function loadVehicle(e)
    if exist(e) then
        return
    end
    
    local start = getTickCount()
    table.insert(cache, {e, start, start + 5000, "alpha", {getVehicleColor(e, true)}, e.frozen, e.collisions})
    
    e.collisions = false
    triggerEvent("ghostMode", localPlayer, e, "on")
    e.alpha = 0
    e.frozen = true
    
    setVehicleColor(e, 255,255,255, 255,255,255, 255,255,255, 255,255,255)
    --setElementFrozen(veh, true)
    
    if not state then
        state = true
        addEventHandler("onClientRender", root, loadVehicles, true, "low-5")
    end
end

function loadVehicles()
    if #cache == 0 then
        state = false
        removeEventHandler("onClientRender", root, loadVehicles)
    end
    
    local now = getTickCount()
    for k,v in pairs(cache) do
        local e, startTime, endTime, state, color, oFrozen, oCol = unpack(v)
        if isElement(e) then
            if state == "alpha" then
                local elapsedTime = now - startTime
                local duration = endTime - startTime
                local progress = elapsedTime / duration
                
                local a = interpolateBetween(
                    0, 0, 0,
                    255, 0, 0,
                    progress, "Linear"
                )
                
                setElementAlpha(e, a)
                
                if progress >= 1 then
                    cache[k][4] = "color"
                    cache[k][2] = now
                    cache[k][3] = now + 3000
                end
            elseif state == "color" then
                local elapsedTime = now - startTime
                local duration = endTime - startTime
                local progress = elapsedTime / duration
                
                local r,g,b = interpolateBetween(
                    255, 255, 255,
                    color[1], color[2], color[3],
                    progress, "Linear"
                )

                local r2,g2,b2 = interpolateBetween(
                    255, 255, 255,
                    color[4], color[5], color[6],
                    progress, "Linear"
                )

                local r3,g3,b3 = interpolateBetween(
                    255, 255, 255,
                    color[7], color[8], color[9],
                    progress, "Linear"
                )

                local r4,g4,b4 = interpolateBetween(
                    255, 255, 255,
                    color[10], color[11], color[12],
                    progress, "Linear"
                )
                
                setVehicleColor(e, r,g,b, r2,g2,b2, r3, g3, b3, r4, g4, b4)

                if progress >= 1 then
                    if e:getData("warp") and e:getData("warp") == localPlayer then 
                        triggerLatentServerEvent("warpToVehicle", 5000, false, localPlayer, localPlayer, e)
                        e:setData("warp", nil)
                    end 

                    if e:getData("needLoad") then
                        e:setData("needLoad", false)
                    end
                    --setElementFrozen(e, oFrozen)
                    e.collisions = oCol
                    triggerEvent("ghostMode", localPlayer, e, "off")
                    e.frozen = oFrozen
                    e.alpha = 255
                    --setElementAlpha(e, 255)
                    setVehicleColor(e, unpack(color))
                    table.remove(cache, k)
                end
            end
        else
            table.remove(cache, k)
        end
    end
end

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue, nValue)
        if dName == "needLoad" then
            if nValue then
                if isElementStreamedIn(source) then
                    loadVehicle(source)
                end
            end
        end
    end
)

addEventHandler("onClientElementStreamIn", root, 
    function()
        if source.type == "vehicle" and source:getData("needLoad") then 
            loadVehicle(source)
        end
    end 
)

local vehicleCounts = {}

function requestVehicleCounts()
    setTimer(triggerLatentServerEvent, 1500, 1, "getVehicleCounts", 5000, false, localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, requestVehicleCounts)

function receiveVehicleCounts(tbl, modelid)
    if not modelid then 
        for k, v in pairs(tbl) do 
            vehicleCounts[k] = tonumber(v)
        end
    else 
        vehicleCounts[modelid] = tonumber((vehicleCounts[modelid] or 0) + 1)
    end
end
addEvent("getVehicleCounts", true)
addEventHandler("getVehicleCounts", root, receiveVehicleCounts)

function minusVehicleCount(modelid)
    vehicleCounts[modelid] = tonumber(vehicleCounts[modelid] or 0) - 1
end
addEvent("minusVehicleCount", true)
addEventHandler("minusVehicleCount", root, minusVehicleCount)

function addVehicleCount(modelid)
    vehicleCounts[modelid] = tonumber(vehicleCounts[modelid] or 0) + 1
end
addEvent("addVehicleCount", true)
addEventHandler("addVehicleCount", root, addVehicleCount)

function getVehicleCounts()
    return vehicleCounts
end 

function makeVehicle(e, model, factionID, playerID, pos, colors)
    triggerLatentServerEvent("makeVehicle", 5000, false, localPlayer, e, model, factionID, playerID, pos, colors)
end 