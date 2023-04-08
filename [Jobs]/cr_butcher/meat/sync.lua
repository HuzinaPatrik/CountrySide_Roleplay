local playerCache = {}

function syncPlayer(element, dataName)
    if element:getData("butcher >> meatInHand") or element:getData("butcher >> boxInHand") then 
        if not playerCache[element] then 
            if dataName == "butcher >> meatInHand" then 
                local position = element.position
                local obj = Object(jobData.meatObjectId, position)

                obj.collisions = false
                obj.interior = element.interior
                obj.dimension = element.dimension

                setObjectScale(obj, 0.5)
                exports.cr_bone_attach:attachElementToBone(obj, element, 12, 0.15, 0.05, 0, 180, 90, 70)

                playerCache[element] = obj
            elseif dataName == "butcher >> boxInHand" then 
                local position = element.position
                local obj = Object(jobData.crateObjectId, position)

                obj.collisions = false
                obj.interior = element.interior
                obj.dimension = element.dimension

                setObjectScale(obj, 0.7)
                exports.cr_bone_attach:attachElementToBone(obj, element, 12, 0.15, 0, 0, -90, 20, 0)

                playerCache[element] = obj
            end
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

local function onClientSyncStart()
    local players = getElementsByType("player", root, true)

    for i = 1, #players do 
        local v = players[i]
        
        if v:getData("butcher >> meatInHand") or v:getData("butcher >> boxInHand") then 
            local dataName = v:getData("butcher >> meatInHand") and "butcher >> meatInHand" or "butcher >> boxInHand"

            syncPlayer(v, dataName)
        end
    end
end
addEventHandler("onClientResourceStart", resourceRoot, onClientSyncStart)

function onStreamIn()
    if source.type == "player" then 
        if source:getData("butcher >> meatInHand") or source:getData("butcher >> boxInHand") then 
            syncPlayer(source)
        end
    end
end
addEventHandler("onClientElementStreamIn", root, onStreamIn)

function onStreamOut()
    if source.type == "player" then 
        if source:getData("butcher >> meatInHand") or source:getData("butcher >> boxInHand") then 
            deSyncPlayer(source)
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