local createdLifters = {}
local liftersInUse = {}

function createLifters()
    createdLifters = {}

    for i = 1, #availableLifters do 
        local v = availableLifters[i]

        local modelId = v.modelId
        local position = v.position
        local rotation = v.rotation
        local interior = v.interior
        local dimension = v.dimension
        local movable = v.movable

        local obj = Object(modelId, Vector3(position.x, position.y, position.z), unpack(v.rotation))

        obj.rotation = Vector3(unpack(v.rotation))

        obj:setData("lifter >> id", i)

        createdLifters[i] = {
            state = false,
            object = obj
        }
    end
end
addEventHandler("onResourceStart", resourceRoot, createLifters)

function initLifter(thePlayer, id, state, vehicle)
    if isElement(thePlayer) and id then 
        if not liftersInUse[id] then 
            liftersInUse[id] = thePlayer
            requestLifters(thePlayer)

            if createdLifters[id] and isElement(createdLifters[id].object) then 
                local obj = createdLifters[id].object
                local position = obj.position
                local z = state and position.z + 1.5 or position.z - 1.5

                if isElement(vehicle) then 
                    vehicle:attach(obj, 0, 0, 0, 0, 0, 90)
                end

                moveObject(obj, liftTime, position.x, position.y, z)

                setTimer(
                    function(thePlayer, id, vehicle)
                        if liftersInUse[id] then 
                            liftersInUse[id] = nil
                        end

                        if createdLifters[id] then 
                            createdLifters[id].state = not createdLifters[id].state

                            if isElement(vehicle) then 
                                if not createdLifters[id].state then 
                                    vehicle:detach()
                                end
                            end
                        end

                        if isTimer(sourceTimer) then 
                            killTimer(sourceTimer)
                        end

                        if isElement(thePlayer) then 
                            requestLifters(thePlayer)
                        end
                    end, liftTime, 1, thePlayer, id, vehicle
                )
            end
        end
    end
end

function startLifter(id, vehicle)
    if isElement(client) then 
        if createdLifters[id] then 
            local state = createdLifters[id].state
            state = not state

            initLifter(client, id, state, vehicle)
        end
    end
end
addEvent("mechanic.startLifter", true)
addEventHandler("mechanic.startLifter", root, startLifter)

function requestLifters(thePlayer)
    local thePlayer = client or thePlayer

    if isElement(thePlayer) then 
        triggerClientEvent(thePlayer, "mechanic.receiveLifters", thePlayer, createdLifters, liftersInUse)
    end
end
addEvent("mechanic.requestLifters", true)
addEventHandler("mechanic.requestLifters", root, requestLifters)

-- function initLifter(id, state)
--     if isElement(client) and id then
--         local players = getElementsByType("player")

--         createdLifters[id] = {state = state}

--         triggerClientEvent(players, "mechanic.initLifter", client, id, state)
--     end
-- end
-- addEvent("mechanic.initLifter", true)
-- addEventHandler("mechanic.initLifter", root, initLifter)