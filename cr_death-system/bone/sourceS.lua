addEvent("anim - give", true)
addEventHandler("anim - give", root,
    function(ped, anim, specAnim)
        if not specAnim then
            setElementData(ped, "forceAnimation", anim)
            setTimer(setPedAnimation, 50, 2, ped, anim[1], anim[2], -1, false, true, false)
        else
            setElementData(ped, "forceAnimation", {"DeathSYSTEM", "GECHI"})
            setPedAnimation(ped, anim[1], anim[2], anim[3], anim[4], anim[5], anim[6])
        end
    end
)

addEvent("health - give", true)
addEventHandler("health - give", root,
    function(ped, stopTazer)
        setElementHealth(ped, 100)
        if stopTazer then
            triggerClientEvent(ped, "stopTazedEffect", ped, ped)
        end
    end
)

--[[
addEvent("GoServerToBackClient", true)
addEventHandler("GoServerToBackClient", root,
    function(veh, attacker, weapon)
        triggerClientEvent(attacker, "onClientVehicleDamageCopy", attacker, veh, attacker, weapon)
    end
)]]