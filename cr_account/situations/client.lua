local eCache = {
    ["vehicle"] = {},
    ["ped"] = {},
    ["boat"] = {},
}

local timers = {}

function changeCameraPos(id, oid2, id2, time)
    local x0, y0, z0, x1, y1, z1 = unpack(cameraPos[id][oid2])
    --outputChatBox(x0 .. " " .. y0 .. " " .. z0)
    local x2, y2, z2, x3, y3, z3 = unpack(cameraPos[id][id2])
    --outputChatBox(x2 .. " " .. y2 .. " " .. z2)
    --outputChatBox(time)
    smoothMoveCamera(x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3, time)
    setTimer(
        function()
            setCameraMatrix(x2, y2, z2, x3, y3, z3)
        end, time, 1
    )
end

function createSituation(id, refresh, id2)
	--farclip = getFarClipDistance( )
	setFarClipDistance(200)
    local id = id or 1
    local id2 = id2 or 1
    setCameraMatrix(unpack(cameraPos[id][id2]))
    setTimer(
        function()
            if id == 1 then
                for k,v in pairs(vehicles[id]) do
                    local x,y,z,rot = unpack(v)
                    local model, pedModel = valiableVehicles[math.random(1,#valiableVehicles)], valiableSkins[math.random(1,#valiableSkins)]
                    local veh = createVehicle(model, x,y,z)
                    local ped = createPed(pedModel, 0,0,0)
                    setElementFrozen(ped, true)
                    warpPedIntoVehicle(ped, veh)
                    setVehicleHandling(veh, "maxVelocity", math.random(50, 80))
                    setElementRotation(veh, 0, 0, rot)
                    setElementDimension(veh, getElementDimension(localPlayer))
                    setElementDimension(ped, getElementDimension(localPlayer))
                    eCache["vehicle"][veh] = true
                    eCache["vehicle"][ped] = true
                    setTimer(setPedControlState, 300, 1, ped, "accelerate", true)
                end
                
                for k,v in pairs(boats[id]) do
                    local x,y,z,rot,model = unpack(v)
                    local veh = createVehicle(model, x,y,z)
                    --local ped = createPed(pedModel, 0,0,0)
                    --setElementFrozen(veh, true)
                    --warpPedIntoVehicle(ped, veh)
                    setVehicleHandling(veh, "maxVelocity", math.random(50, 80))
                    setElementRotation(veh, 0, 0, rot)
                    setElementDimension(veh, getElementDimension(localPlayer))
                    --setElementDimension(ped, getElementDimension(localPlayer))
                    eCache["boat"][veh] = true
                    --eCache["vehicle"][ped] = true
                    --setTimer(setPedControlState, 300, 1, ped, "accelerate", true)
                end

                timers["refilTimer"] = setTimer(
                    function()
                        for k,v in pairs(eCache["vehicle"]) do
                            if isElement(k) then
                                destroyElement(k)
                            end
                            eCache["vehicle"][k] = nil
                        end

                        for k,v in pairs(vehicles[id]) do
                            local x,y,z,rot = unpack(v)
                            local model, pedModel = valiableVehicles[math.random(1,#valiableVehicles)], valiableSkins[math.random(1,#valiableSkins)]
                            local veh = createVehicle(model, x,y,z)
                            local ped = createPed(pedModel, 0,0,0)
                            setElementFrozen(ped, true)
                            warpPedIntoVehicle(ped, veh)
                            setVehicleHandling(veh, "maxVelocity", math.random(50, 80))
                            setElementRotation(veh, 0, 0, rot)
                            setElementDimension(veh, getElementDimension(localPlayer))
                            setElementDimension(ped, getElementDimension(localPlayer))
                            eCache["vehicle"][veh] = true
                            eCache["vehicle"][ped] = true
                            setTimer(setPedControlState, 300, 1, ped, "accelerate", true)
                        end
                    end, 15000, 0
                )

                for k,v in pairs(peds[id]) do
                    local x,y,z,rot,walk,animDetails = unpack(v)
                    local pedModel = valiableSkins[math.random(1,#valiableSkins)]
                    local ped = createPed(pedModel, x,y,z)
                    setElementDimension(ped, getElementDimension(localPlayer))
                    setElementRotation(ped, 0, 0, rot)
                    if not walk then
                        setElementFrozen(ped, true)
                        setPedAnimation(ped, unpack(animDetails))
                    else
                        setTimer(setPedControlState, 300, 1, ped, "forwards", true)
                        setTimer(setPedControlState, 300, 1, ped, "walk", true)
                    end
                    eCache["ped"][ped] = true
                end

                timers["refilTimer2"] = setTimer(
                    function()
                        for k,v in pairs(eCache["ped"]) do
                            if getPedControlState(k, "forwards") then
                                destroyElement(k)
                                eCache["ped"][k] = nil
                            end
                        end

                        for k,v in pairs(peds[id]) do
                            local x,y,z,rot,walk,animDetails = unpack(v)
                            local pedModel = valiableSkins[math.random(1,#valiableSkins)]
                            if walk then
                                local ped = createPed(pedModel, x,y,z)
                                setElementDimension(ped, getElementDimension(localPlayer))
                                setElementRotation(ped, 0, 0, rot)
                                setTimer(setPedControlState, 300, 1, ped, "forwards", true)
                                setTimer(setPedControlState, 300, 1, ped, "walk", true)
                                eCache["ped"][ped] = true
                            end
                        end
                    end, 30000, 0
                )
            end
        end, 500, 1
    )
end

function stopSituations()
    --setFarClipDistance(farclip)
    resetFarClipDistance()
    if isTimer(timers["refilTimer"]) then
        killTimer(timers["refilTimer"])
    end
    if isTimer(timers["refilTimer2"]) then
        killTimer(timers["refilTimer2"])
    end
    for k,v in pairs(eCache) do
        for k2, v2 in pairs(eCache[k]) do
            if isElement(k2) then
                k2:destroy()
                eCache[k][k2] = nil
            end
        end
    end
end