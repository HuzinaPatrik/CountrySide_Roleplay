addEvent("csetVehicleWheelStates", true)
addEventHandler("csetVehicleWheelStates", root, 
    function(veh, r1,r2,r3,r4)
        setVehicleWheelStates(veh, r1,r2,r3,r4)
    end
)