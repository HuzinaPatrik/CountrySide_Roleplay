function setVehHandling(veh, k, v)
    if veh and k and v then 
        setVehicleHandling(veh, k, v) 
    end 
end 
addEvent("setVehicleHandling", true)
addEventHandler("setVehicleHandling", root, setVehHandling)