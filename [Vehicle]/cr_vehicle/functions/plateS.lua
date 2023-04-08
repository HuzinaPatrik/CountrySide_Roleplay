plates = {}
isValidPlate = {}

--setplatetext újraírása, sql alapura

function checkPlate(vehicleID, plate)
    if not plates[vehicleID] then
        if not plate or isValidPlate[plate] or plate == "false" or plate == "nil" or plate == "" or plate == " " then
            plate = generatePlateText()
            
            cache[vehicleID]:setData("veh >> plateText", plate)
            cache[vehicleID].plateText = plate
            
            dbExec(connection, "UPDATE vehicle SET plate = ? WHERE id = ?", plate, vehicleID)
            
            outputDebugString("Plate update: ID: #"..vehicleID..", New: "..plate, 0, 255, 87, 87)
        end
        
        plates[vehicleID] = plate
        isValidPlate[plate] = vehicleID
    end
end
addEvent("checkPlate", true)
addEventHandler("checkPlate", root, checkPlate)

addEventHandler("onVehicleLoad", root,
    function(id)
        checkPlate(id, source:getData("veh >> plateText"))
    end
)

function setVehiclePlateText(sourcePlayer, vehicle, val)
    if vehicle and val then 
        if isValidPlate[val:upper()] then 
            exports['cr_infobox']:addBox(sourcePlayer, "error", "Ez a rendszám már használatban van!")
            return 
        end 

        local id = vehicle:getData("veh >> id")
        local plateText = plates[id]

        isValidPlate[plateText] = nil 
        vehicle:setData("veh >> plateText", val)
        vehicle.plateText = val
        isValidPlate[val] = id
        plates[id] = val

        dbExec(connection, "UPDATE vehicle SET plate = ? WHERE id = ?", val, id)
    end
end
addEvent("setVehiclePlateText.tuning", true)
addEventHandler("setVehiclePlateText.tuning", root, setVehiclePlateText)


addEventHandler("onVehicleDestroy", root,
    function(id)
        isValidPlate[plates[id]] = nil
        plates[id] = nil
        collectgarbage("collect")
    end
)

function generatePlateText()
    local plate1 = generateString(3, false, true);
    local plate2 = generateString(3, true, false);
    local plate = tostring(plate1) .. "-" .. tostring(plate2);
    if isValidPlate[plate] then
        plate = generatePlateText();
    end
    
    return string.upper(plate);
end

function clearPlateCache(vehicle)
    if isElement(vehicle) then
        local id = vehicle:getData("veh >> id")
        isValidPlate[plates[id]] = nil
        plates[id] = nil
        collectgarbage("collect")
        
        return true
    elseif tonumber(vehicle) then
        local id = tonumber(vehicle)
        isValidPlate[plates[id]] = nil
        plates[id] = nil
        collectgarbage("collect")
        
        return true
    end
    
    return false
end
addEventHandler("onVehicleDestroy", resourceRoot, clearPlateCache)