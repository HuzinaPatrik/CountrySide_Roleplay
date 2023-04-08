function checkFuelType(vehicleID, fueltype)
    if not fueltype or fueltype == "false" or fueltype == "nil" or fueltype == "" or fueltype == " " then
        local handling = getModelHandling(cache[vehicleID].model)
        fueltype = getHandlingProperty(cache[vehicleID], "engineType")
        
        cache[vehicleID]:setData("veh >> fueltype", fueltype)
        cache[vehicleID]:setData("veh >> oldfueltype", fueltype)

        dbExec(connection, "UPDATE vehicle SET fueltype = ? WHERE id = ?", fueltype, vehicleID)

        outputDebugString("Fueltype update: ID: #"..vehicleID..", New: "..fueltype, 0, 255, 87, 87)
    end
end

addEventHandler("onVehicleLoad", root,
    function(id)
        checkFuelType(id, source:getData("veh >> fueltype"))
    end
)