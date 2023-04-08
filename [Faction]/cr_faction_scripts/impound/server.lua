addEvent("factionscripts.impoundVehicle", true)
addEventHandler("factionscripts.impoundVehicle", root,
    function(thePlayer, vehicle, enforcerFaction)
        exports["cr_impound"]:impoundVehicle(thePlayer, vehicle, enforcerFaction)
    end
)