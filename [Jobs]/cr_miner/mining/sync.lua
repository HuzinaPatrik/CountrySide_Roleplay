local playerCache = {}
local vehicleCache = {}

function syncPlayer(element)
    if element:getData("miner >> rockInHand") then 
        if not playerCache[element] then 
            local position = element.position
            local obj = Object(jobData.rockObjectId, position)

            obj.collisions = false
            obj.interior = element.interior
            obj.dimension = element.dimension

            obj:setScale(0.05)
            exports.cr_bone_attach:attachElementToBone(obj, element, 12, 0.15, 0.05, 0, 180, 90, 70)

            playerCache[element] = obj
        end
    else
        if playerCache[element] then 
            if isElement(playerCache[element]) then 
                playerCache[element]:destroy()
                playerCache[element] = nil
            end
    
            collectgarbage("collect")
        end
    end
end

function deSyncPlayer(element)
    if playerCache[element] then 
        if isElement(playerCache[element]) then 
            playerCache[element]:destroy()
        end

        playerCache[element] = nil
        collectgarbage("collect")
    end
end

function syncVehicle(element)
    if not vehicleCache[element] then 
        vehicleCache[element] = {}
    end 

    local rocksInVeh = element:getData("miner >> rocksInVeh") or {}

    for i = 1, jobData.maxRockInVeh do 
        if rocksInVeh[i] then 
            if not vehicleCache[element][i] then 
                local obj = Object(jobData.rockObjectId, 0, 0, 0)

                vehicleCache[element][i] = obj

                obj.collisions = false
                obj.dimension = element.dimension 
                obj.interior = element.interior
                
                obj:setScale(0.05)
                obj:attach(element, unpack(jobData.rockOffsets[i]))
            end 
        else
            if vehicleCache[element][i] then 
                vehicleCache[element][i]:destroy()
                vehicleCache[element][i] = nil 

                collectgarbage("collect")
            end
        end
    end
end

function deSyncVehicle(element)
    if vehicleCache[element] then 
        local rocksInVeh = vehicleCache[element]

        for i = 1, #rocksInVeh do 
            local v = rocksInVeh[i]

            if isElement(v) then 
                v:destroy()
            end
        end

        vehicleCache[element] = nil
        collectgarbage("collect")
    end
end

local function onClientSyncStart()
    local players = getElementsByType("player", root, true)
    local vehicles = getElementsByType("vehicle", root, true)

    for i = 1, #players do 
        local v = players[i]

        if v:getData("miner >> rockInHand") then 
            syncPlayer(v)
        end
    end

    for i = 1, #vehicles do 
        local v = vehicles[i]

        if v:getData("miner >> rocksInVeh") then 
            syncVehicle(v)
        end
    end
end
addEventHandler("onClientResourceStart", resourceRoot, onClientSyncStart)

function onStreamIn()
    if source.type == "player" then 
        if source:getData("miner >> rockInHand") then 
            syncPlayer(source)
        end
    elseif source.type == "vehicle" then 
        if source:getData("miner >> rocksInVeh") then 
            syncVehicle(source)
        end
    end
end
addEventHandler("onClientElementStreamIn", root, onStreamIn)

function onStreamOut()
    if source.type == "player" then 
        if source:getData("miner >> rockInHand") then 
            deSyncPlayer(source)
        end
    elseif source.type == "vehicle" then 
        if source:getData("miner >> rocksInVeh") then 
            deSyncVehicle(source)
        end
    end
end
addEventHandler("onClientElementStreamOut", root, onStreamOut)

function onClientQuit()
    if playerCache[source] then 
        deSyncPlayer(source)
    end
end
addEventHandler("onClientPlayerQuit", root, onClientQuit)

function onClientElementDestroy()
    if source.type == "vehicle" and vehicleCache[source] then 
        deSyncVehicle(source)
    end
end
addEventHandler("onClientElementDestroy", root, onClientElementDestroy)