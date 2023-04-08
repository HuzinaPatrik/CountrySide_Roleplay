function destroyRocks(vehicle)
    if isElement(vehicle) then 
        vehicle:removeData("miner >> rocksInVeh")
    end
end

function onClientDeliverRocks()
    if isElement(client) then 
        local jobVehicle = client:getData("char >> jobVehicle")

        if isElement(jobVehicle) then 
            destroyRocks(jobVehicle)
        end
    end
end
addEvent("onClientDeliverRocks", true)
addEventHandler("onClientDeliverRocks", root, onClientDeliverRocks)

function onClientDeliverRock()
    if isElement(client) then 
        client:removeData("miner >> rockInHand")
        client.frozen = false
    end
end
addEvent("onClientDeliverRock", true)
addEventHandler("onClientDeliverRock", root, onClientDeliverRock)