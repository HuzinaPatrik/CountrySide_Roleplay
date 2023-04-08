local playerCache = {}

function syncPlayer(element)
    if element:getData("delivery >> crateInHand") then 
        if not playerCache[element] then 
            local position = element.position
            local obj = Object(jobData.crateObjectId, position)

            obj.collisions = false
            obj.interior = element.interior
            obj.dimension = element.dimension

            setObjectScale(obj, 0.7)
            exports.cr_bone_attach:attachElementToBone(obj, element, 12, 0.15, 0, 0, -90, 20, 0)

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

function onStreamIn()
    if source.type == "player" then 
        if source:getData("delivery >> crateInHand") then 
            syncPlayer(source)
        end
    end
end
addEventHandler("onClientElementStreamIn", root, onStreamIn)

function onStreamOut()
    if source.type == "player" then 
        if source:getData("delivery >> crateInHand") then 
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