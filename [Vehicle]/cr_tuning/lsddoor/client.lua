local cache = {}
local oldDoorRatios = {}
local doorStatus = {}
local doorTimers = {}
local doorAnimTime = 350

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        for k, v in pairs(getElementsByType("vehicle", _, true)) do
            local tuningData = v:getData("veh >> tuningData") or {}
            if tuningData["lsdDoor"] then
                cache[v] = true

                if not isSync then 
                    isSync = true 
                    addEventHandler("onClientPreRender", root, doSync)
                end 
            end
        end
    end
)

addEventHandler("onClientElementStreamIn", root, 
    function()
        local tuningData = source:getData("veh >> tuningData") or {}
        if tuningData["lsdDoor"] then
            cache[source] = true

            if not isSync then 
                isSync = true 
                addEventHandler("onClientPreRender", root, doSync)
            end 
        end
    end
)

addEventHandler("onClientElementDataChange", root, 
    function(dName, oValue, nValue)
        if dName == "veh >> tuningData" then 
            if nValue["lsdDoor"] then 
                cache[source] = true

                if not isSync then 
                    isSync = true 
                    addEventHandler("onClientPreRender", root, doSync)
                end 
            else 
                if cache[source] then 
                    removeFromCache(source)
                end 
            end    
        end 
    end
)

function addToCache(veh)
    cache[veh] = true

    if not isSync then 
        isSync = true 
        addEventHandler("onClientPreRender", root, doSync)
    end 
end 

function doSync()
    for vehicle in pairs(cache) do
        if isElement(vehicle) then
            if not doorTimers[vehicle] then
                doorTimers[vehicle] = {}
            end
            
            local doorRatios = {}
            
            for i = 1, 4 do
                local i = i + 1
                local doorRatio = getVehicleDoorOpenRatio(vehicle, i)

                if doorRatio and oldDoorRatios[vehicle] and oldDoorRatios[vehicle][i] then
                    local oldDoorRatio = oldDoorRatios[vehicle][i]

                    if not doorStatus[vehicle] then
                        doorStatus[vehicle] = {}
                    end
                    
                    local doorPreviousState = doorStatus[vehicle][i]
                    
                    if not doorPreviousState then
                        doorPreviousState = "closed"
                    end
                    
                    if doorPreviousState == "closed" and doorRatio > oldDoorRatio then
                        doorStatus[vehicle][i] = "opening"
                        doorTimers[vehicle][i] = setTimer(function(vehicle,i)
                            doorStatus[vehicle][i] = "open"
                            doorTimers[vehicle][i] = nil
                        end, doorAnimTime, 1, vehicle, i)
                    elseif doorPreviousState == "open" and doorRatio < oldDoorRatio then
                        doorStatus[vehicle][i] = "closing"
                        doorTimers[vehicle][i] = setTimer(function(vehicle, i)
                            doorStatus[vehicle][i] = "closed"
                            doorTimers[vehicle][i] = nil
                        end, doorAnimTime, 1, vehicle, i)
                    end
                elseif not oldDoorRatios[vehicle] then
                    oldDoorRatios[vehicle] = {}
                end
                
                if doorRatio then
                    oldDoorRatios[vehicle][i] = doorRatio
                end
            end
        else
            cache[vehicle] = nil
            oldDoorRatios[vehicle] = nil
            doorStatus[vehicle] = nil
            doorTimers[vehicle] = nil
        end
    end
    
    for vehicle, doors in pairs(doorStatus) do
        if cache[vehicle] then
            local doorX, doorY, doorZ = -72, -25, 0
            
            for door, status in pairs(doors) do
                local ratio = 0
                
                if status == "open" then
                    ratio = 1
                end
                
                local doorTimer = doorTimers[vehicle][door]
                
                if doorTimer and isTimer(doorTimer) then
                    local timeLeft = getTimerDetails(doorTimer)
                    
                    ratio = timeLeft / doorAnimTime
                    
                    if status == "opening" then
                        ratio = 1 - ratio
                    end
                end
                
                local dummyName = (door == 2 and "door_lf_dummy") or (door == 3 and "door_rf_dummy") or (door == 4 and "door_lr_dummy")  or (door == 5 and "door_rr_dummy") 
                
                if dummyName then
                    local doorX, doorY, doorZ = doorX * ratio, doorY * ratio, doorZ * ratio
                    
                    if string.find(dummyName, "rf") or string.find(dummyName, "rr") then
                        doorY, doorZ = doorY * -1, doorZ * -1
                    end
                    
                    setVehicleComponentRotation(vehicle, dummyName, doorX, doorY, doorZ)
                end
            end
        end
    end
end


function removeFromCache(v)
	if cache[v] then
		cache[v] = nil
		oldDoorRatios[v] = nil
		doorStatus[v] = nil
        doorTimers[v] = nil
        
        for k,v in pairs(cache) do 
            return  
        end 

        if isSync then 
            isSync = false 
            removeEventHandler("onClientPreRender", root, doSync)
        end 
	end
end

addEventHandler("onClientElementDestroy", root, 
    function()
        removeFromCache(source)
    end
)

addEventHandler("onClientElementStreamOut", root, 
    function()
        removeFromCache(source)
    end
)

addEventHandler("onClientVehicleExplode", root, 
    function()
        removeFromCache(source)
    end
)