function isKnow(who, id)
    local friendTable = who:getData("friends") or {}
    if friendTable[tonumber(id)] then
        return true
    else
        return false
    end
end

addEvent("nametag->goToServer", true)
addEventHandler("nametag->goToServer", root, 
    function(e, id, e2)
        triggerClientEvent(e, "nametag->goToClient", e, id, e2)
    end
)

addEvent("updateDimension", true)
addEventHandler("updateDimension", root, 
    function(sourcePlayer, dim)
        sourcePlayer.dimension = dim 
    end 
)

addEvent("updateInterior", true)
addEventHandler("updateInterior", root, 
    function(sourcePlayer, int)
        sourcePlayer.interior = int 
    end 
)

addEvent("elementbox >> warpPedIntoVehicle", true)
addEventHandler("elementbox >> warpPedIntoVehicle", root, 
    function(sourcePlayer, targetPlayer, seat)
        warpPedIntoVehicle(sourcePlayer, targetPlayer.vehicle, seat)
    end 
)

addEvent("elementbox >> removePedFromVehicle", true)
addEventHandler("elementbox >> removePedFromVehicle", root, 
    function(sourcePlayer)
        removePedFromVehicle(sourcePlayer)
    end 
)