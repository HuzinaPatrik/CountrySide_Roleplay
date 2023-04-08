addEvent("changeDoorState2", true)
addEventHandler("changeDoorState2", root,
    function(veh, table)
        local num, oState = unpack(table)
        setPedAnimation(source, "Ped", "CAR_open_LHS", 300, false, false, true, false)
        local openRatio = getVehicleDoorOpenRatio(veh, num)
        if openRatio == 1 then
            openRatio = 0
        else
            openRatio = 1
        end
        setVehicleDoorOpenRatio(veh, num, openRatio, 400)
    end
)