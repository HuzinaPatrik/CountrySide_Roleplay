local createdLifters = {}
local liftersInUse = {}

function getNearestObject(thePlayer, model, range)
    if isElement(thePlayer) and model then 
        range = range or 5

        local result = false
        local elements = getElementsWithinRange(thePlayer.position, range, "object")

        if elements and #elements > 0 then 
            for k, v in pairs(elements) do 
                if v.interior == thePlayer.interior and v.dimension == thePlayer.dimension and v.model == model then 
                    local distance = getDistanceBetweenPoints3D(thePlayer.position, v.position)

                    if distance <= range then 
                        result = v
                        break
                    end
                end
            end
        end

        return result
    end
end

function isVehicleOnLifter(id, range)
    range = range or 5

    local result = false
    local vehicles = getElementsByType("vehicle", root, true)
    local lifterData = createdLifters[id]

    if lifterData and isElement(lifterData.object) then
        for i = 1, #vehicles do 
            local v = vehicles[i]
            local distance = getDistanceBetweenPoints3D(v.position, lifterData.object.position)

            if distance <= range then 
                result = v
                break
            end
        end
    end

    return result
end

function isVehicleHasPassengers(vehicle)
    local result = false

    if isElement(vehicle) then 
        local occupants = getVehicleOccupants(vehicle)

        for k, v in pairs(occupants) do 
            if isElement(v) then 
                result = true
                break
            end
        end
    end

    return result
end

function liftCommand(cmd)
    if localPlayer:getData("loggedIn") then 
        if hasPermission(localPlayer, 3, "mechanic.canUseLifter") then 
            local lifter = getNearestObject(localPlayer, 6923, 4)

            if not isElement(lifter) then 
                local syntax = exports.cr_core:getServerSyntax("Mechanic", "error")

                outputChatBox(syntax .. "Nincs a közeledben emelő.", 255, 0, 0, true)
                return
            end

            local id = lifter:getData("lifter >> id")

            if liftersInUse[id] then 
                local syntax = exports.cr_core:getServerSyntax("Mechanic", "error")

                outputChatBox(syntax .. "Ez az emelő már mozgásban van.", 255, 0, 0, true)
                return
            end

            local vehicle = isVehicleOnLifter(id, 1.5)

            if isElement(vehicle) and isVehicleHasPassengers(vehicle) then 
                local syntax = exports.cr_core:getServerSyntax("Mechanic", "error")

                outputChatBox(syntax .. "A járműben nem ülhetnek mozgás közben.", 255, 0, 0, true)
                return
            end

            triggerServerEvent("mechanic.startLifter", localPlayer, id, vehicle)
        end
    end
end
addCommandHandler("lift", liftCommand, false, false)

function receiveLifters(tbl, tbl2)
    createdLifters = tbl
    liftersInUse = tbl2
end
addEvent("mechanic.receiveLifters", true)
addEventHandler("mechanic.receiveLifters", root, receiveLifters)

function onClientStart()
    setTimer(triggerServerEvent, 1000, 1, "mechanic.requestLifters", localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)