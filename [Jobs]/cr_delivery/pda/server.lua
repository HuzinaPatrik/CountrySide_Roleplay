function carryRestriction(element, state)
    state = not state

    exports.cr_controls:toggleControl(element, jobData.carryControls, state, "high")
end

function onClientDeliveryPackagePickup() 
    if not client:getData("delivery >> crateInHand") then 
        client:setData("delivery >> crateInHand", true)

        carryRestriction(client, true)
    end
end
addEvent("onClientDeliveryPackagePickup", true)
addEventHandler("onClientDeliveryPackagePickup", root, onClientDeliveryPackagePickup)

function onClientDeliveryPackagePutdown() 
    if client:getData("delivery >> crateInHand") then 
        client:setData("delivery >> crateInHand", false)

        carryRestriction(client, false)
    end
end
addEvent("onClientDeliveryPackagePutdown", true)
addEventHandler("onClientDeliveryPackagePutdown", root, onClientDeliveryPackagePutdown)