grindingATM = {}
grindingElementToId = {}

function startGrinding(id, element)
    if isElement(client) then 
        if not grindingATM[id] then 
            grindingATM[id] = client
            grindingElementToId[client] = id

            triggerClientEvent(root, "atmRobbery.startGrinding", client, element)

            if not element:getData("atm >> unavailable") then 
                element:setData("atm >> unavailable", true)
                -- element.model = 2943
            end
        end
    end
end
addEvent("atmRobbery.startGrinding", true)
addEventHandler("atmRobbery.startGrinding", root, startGrinding)

function stopGrinding(id, element)
    if isElement(client) then 
        if grindingATM[id] then 
            grindingATM[id] = nil
            grindingElementToId[client] = nil

            triggerClientEvent(root, "atmRobbery.stopGrinding", client)
        end
    end
end
addEvent("atmRobbery.stopGrinding", true)
addEventHandler("atmRobbery.stopGrinding", root, stopGrinding)

function isGrinded(id)
    return grindingATM[id]
end