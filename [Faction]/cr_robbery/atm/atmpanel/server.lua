local usingATM = {}
local usingElementToId = {}

function openATMPanel(id, element)
    if isElement(client) then 
        if not usingATM[id] then 
            usingATM[id] = client
            usingElementToId[client] = id

            triggerClientEvent(client, "atmRobbery.openATMPanel", client, element)
        end
    end
end
addEvent("atmRobbery.openATMPanel", true)
addEventHandler("atmRobbery.openATMPanel", root, openATMPanel)

function closeATMPanel(id)
    if isElement(client) then 
        if usingATM[id] then 
            usingATM[id] = nil
            usingElementToId[client] = nil
        end
    end
end
addEvent("atmRobbery.closeATMPanel", true)
addEventHandler("atmRobbery.closeATMPanel", root, closeATMPanel)

function isATMInUse(id)
    return usingATM[id]
end

function onQuit()
    if usingElementToId[source] then 
        local id = usingElementToId[source]

        usingATM[id] = nil
        usingElementToId[source] = nil
    end

    if grindingElementToId[source] then 
        local id = grindingElementToId[source]

        grindingATM[id] = nil
        grindingElementToId[source] = nil
    end
end
addEventHandler("onPlayerQuit", root, onQuit)