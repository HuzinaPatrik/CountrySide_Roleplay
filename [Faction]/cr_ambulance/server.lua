addEvent("healPed >> giveHealth", true)
addEventHandler("healPed >> giveHealth", root,
    function(thePlayer, value)
        if client and client == thePlayer and isElement(thePlayer) then 
            thePlayer.health = value
        end
    end
)

addEvent("ambulance.setElementFrozen", true)
addEventHandler("ambulance.setElementFrozen", root,
    function(thePlayer, state)
        local thePlayer = thePlayer or client

        if isElement(thePlayer) then 
            thePlayer.frozen = state
        end
    end
)