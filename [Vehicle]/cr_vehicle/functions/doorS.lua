addEvent("changeDoorState", true)
addEventHandler("changeDoorState", root, function(veh, num, oldState)
    local oldState = not oldState
    local openRatio = 0
        
    if oldState then
        openRatio = 1
    end
        
    setVehicleDoorOpenRatio(veh, num, openRatio, 500)
end)