local spikeCache = {}

function requestSpikes()
    if isElement(client) then 
        triggerClientEvent(client, "spike.receiveSpikes", client, spikeCache)
    end
end
addEvent("spike.requestSpikes", true)
addEventHandler("spike.requestSpikes", root, requestSpikes)

function deleteSpike(id)
    if isElement(client) and id then 
        local players = getElementsByType("player")

        if spikeCache[id] then
            spikeCache[id] = nil
            triggerClientEvent(players, "spike.deleteSpike", client, id)

            local syntax = exports.cr_core:getServerSyntax("Spike", "success")
            local hexColor = exports.cr_core:getServerColor("yellow", true)

            outputChatBox(syntax .. "Sikeresen kitörölted a szögesdrótot. " .. hexColor .. "(" .. id .. ")", client, 255, 0, 0, true)
        end
    end
end
addEvent("spike.deleteSpike", true)
addEventHandler("spike.deleteSpike", root, deleteSpike)

function pierceWheels(vehicle)
    if isElement(vehicle) then 
        setVehicleWheelStates(vehicle, 1, 1, 1, 1)
    end
end
addEvent("spike.pierceWheels", true)
addEventHandler("spike.pierceWheels", root, pierceWheels)

function getFreeId()
    local result = 0

    for k, v in ipairs(spikeCache) do 
        result = k
    end

    return result + 1
end

function createSpike(thePlayer)
    if isElement(thePlayer) then
        local id = getFreeId() 
        local x, y, z, rotZ = getPositionInFrontOfElement(thePlayer, 5.3)
        local objectId = 2892

        local createdBy = exports.cr_admin:getAdminName(thePlayer)
        local createdAt = os.time()
        
        spikeCache[id] = {
            objectId = objectId,
            x = x,
            y = y,
            z = z - 0.95,
            rotZ = rotZ,
            createdBy = createdBy,
            createdAt = createdAt
        }

        local players = getElementsByType("player")

        thePlayer:setData("forceAnimation", {"GRENADE", "weapon_throwu", 1000, false, false, false, false, 250, true})
        triggerClientEvent(players, "spike.placeSpikeOnGround", thePlayer, id, spikeCache[id])
    end
end

function spikeCommand(thePlayer, cmd)
    if exports.cr_faction_scripts:hasPlayerPermission(thePlayer, cmd) then 
        if not thePlayer:isInVehicle() then 
            createSpike(thePlayer)
        else
            local syntax = exports.cr_core:getServerSyntax("Spike", "error")
            outputChatBox(syntax .. "Járműben nem rakhatod le a szögesdrótot.", thePlayer, 255, 0, 0, true)
        end
    end
end
addCommandHandler("spike", spikeCommand, false, false)