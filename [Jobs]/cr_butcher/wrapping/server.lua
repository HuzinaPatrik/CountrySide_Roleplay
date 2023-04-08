function onClientMeatBoxPickUp()
    if not client:getData("butcher >> boxInHand") then 
        client:setData("butcher >> boxInHand", true)

        carryRestriction(client, true)
    end
end
addEvent("onClientMeatBoxPickUp", true)
addEventHandler("onClientMeatBoxPickUp", root, onClientMeatBoxPickUp)

function onClientMeatBoxDeliver()
    if client:getData("butcher >> boxInHand") then 
        client:setData("butcher >> boxInHand", false)

        carryRestriction(client, false)
    end
end
addEvent("onClientMeatBoxDeliver", true)
addEventHandler("onClientMeatBoxDeliver", root, onClientMeatBoxDeliver)