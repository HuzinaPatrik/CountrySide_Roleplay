function onClientRockToVehiclePlace(id)
    if isElement(client) and id then 
        local jobVehicle = client:getData("char >> jobVehicle")

        if isElement(jobVehicle) then 
            local rocksInVeh = jobVehicle:getData("miner >> rocksInVeh") or {}

            if #rocksInVeh < jobData.maxRockInVeh then 
                if not rocksInVeh[id] then 
                    rocksInVeh[id] = true

                    jobVehicle:setData("miner >> rocksInVeh", rocksInVeh)
                end

                client:removeData("miner >> rockInHand")
                carryRestriction(client, false)
            end
        end
    end
end
addEvent("onClientRockToVehiclePlace", true)
addEventHandler("onClientRockToVehiclePlace", root, onClientRockToVehiclePlace)

function onClientRockPickupFromVehicle(id)
    if isElement(client) and id then 
        local jobVehicle = client:getData("char >> jobVehicle")

        if isElement(jobVehicle) then 
            local rocksInVeh = jobVehicle:getData("miner >> rocksInVeh") or {}

            if #rocksInVeh > 0 then
                if rocksInVeh[id] then  
                    rocksInVeh[id] = nil

                    jobVehicle:setData("miner >> rocksInVeh", rocksInVeh)
                end

                client:setData("miner >> rockInHand", true)
                carryRestriction(client, true)
            end
        end
    end
end
addEvent("onClientRockPickupFromVehicle", true)
addEventHandler("onClientRockPickupFromVehicle", root, onClientRockPickupFromVehicle)

local function onElementDestroy()
    if source.type == "vehicle" and source:getData("miner >> rocksInVeh") then 
        destroyRocks(source)
    end
end
addEventHandler("onElementDestroy", root, onElementDestroy)