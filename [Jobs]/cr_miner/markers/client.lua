local createdMarkers = {}

function createJobMarkers()
    local vehiclePickupMarker = Marker(jobData.vehiclePickupPoint, "checkpoint", 1.5, 124, 197, 118)
    local jobVehiclePickupBlip = exports.cr_radar:createStayBlip("Munkajármű felvétel", Blip(jobData.vehiclePickupPoint, 0, 2, 255, 0, 0, 255, 0, 0), 0, "target", 24, 24, 255, 255, 255)
    local caveEntrance = exports.cr_radar:createStayBlip("Bánya bejárat", Blip(jobData.caveEntrance, 0, 2, 255, 0, 0, 255, 0, 0), 0, "target", 24, 24, 200, 0, 0)

    vehiclePickupMarker.interior = jobData.vehiclePickupInterior
    vehiclePickupMarker.dimension = jobData.vehiclePickupDimension

    createdMarkers[vehiclePickupMarker] = "vehiclePickupMarker"

    local r, g, b = exports.cr_core:getServerColor("red", false)
    for i = 1, #jobData.rockDeliveryPositions do 
        local v = jobData.rockDeliveryPositions[i]

        if v.x and v.y and v.z then 
            local x, y, z = v.x, v.y, v.z
            local interior, dimension = v.interior, v.dimension

            local markerElement = Marker(x, y, z, "checkpoint", 1.5, r, g, b)
            local deliveryBlip = exports.cr_radar:createStayBlip("Kő leadó pont #" .. i, Blip(x, y, z, 0, 2, 255, 0, 0, 255, 0, 0), 0, "target", 24, 24, 200, 0, 0)

            markerElement.interior = interior
            markerElement.dimension = dimension

            createdMarkers[markerElement] = {name = "rockDeliveryMarker", index = i}
        end
    end
end

function destroyJobMarkers()
    for k, v in pairs(createdMarkers) do 
        if isElement(k) then 
            if v.index then 
                exports.cr_radar:destroyStayBlip("Kő leadó pont #" .. v.index)
            end

            createdMarkers[k] = nil

            k:destroy()
        end
    end

    exports.cr_radar:destroyStayBlip("Munkajármű felvétel")
    exports.cr_radar:destroyStayBlip("Bánya bejárat")

    collectgarbage("collect")
end

local function onClientMarkerHit(hitElement, mDim)
    if hitElement == localPlayer and mDim then 
        if createdMarkers[source] then 
            if createdMarkers[source] == "vehiclePickupMarker" then 
                if getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 5 then 
                    if localPlayer:getData("char >> jobVehicle") then 
                        exports.cr_jobvehicle:openRequestPanel({
                            type = "destroy",
                            titleText = "Munkajármű leadása",
                            buttonText = "Leadás"
                        })
                    else
                        local position = jobData.vehiclePositions[math.random(1, #jobData.vehiclePositions)]

                        exports.cr_jobvehicle:openRequestPanel({
                            type = "request",
                            titleText = "Munkajármű igénylése",
                            buttonText = "Igénylés",
                            position = position,
                            vehicles = jobData.vehicles,
                            now = 1
                        })
                    end
                end
            elseif createdMarkers[source].name == "rockDeliveryMarker" and createdMarkers[source].index then 
                local vehicle = localPlayer.vehicle
                local vehicleSeat = localPlayer.vehicleSeat
                local jobVehicle = localPlayer:getData("char >> jobVehicle")

                if vehicle then 
                    if vehicle == jobVehicle and vehicleSeat == 0 then 
                        local rocksInVeh = jobVehicle:getData("miner >> rocksInVeh") or {}

                        if #rocksInVeh > 0 then
                            deliverRocks(#rocksInVeh)
                        end
                    end
                else
                    if localPlayer:getData("miner >> rockInHand") then 
                        deliverRocks()
                    end
                end
            end
        end
    end
end
addEventHandler("onClientMarkerHit", root, onClientMarkerHit)

function onClientMarkerLeave(hitElement, mDim)
    if hitElement == localPlayer and mDim then 
        if createdMarkers[source] then 
            if createdMarkers[source] == "vehiclePickupMarker" then 
                exports.cr_jobvehicle:closeRequestPanel()
            end
        end
    end
end
addEventHandler("onClientMarkerLeave", root, onClientMarkerLeave)