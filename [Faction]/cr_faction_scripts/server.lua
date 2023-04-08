addEvent("factionscripts.unFlip", true)
addEventHandler("factionscripts.unFlip", root,
    function(vehicle)
        local a1, a2, a3 = getElementRotation(vehicle)
        setElementRotation(vehicle, 0, a2, a3)
    end
)