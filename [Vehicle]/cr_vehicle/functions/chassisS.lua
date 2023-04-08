local chassisCache = {}
local isValidChassis = {}

--setchassistext újraírása, sql alapura

function checkChassis(vehicleID, chassis)
    if not chassisCache[vehicleID] then
        if not chassis or isValidChassis[chassis] or chassis == "false" or chassis == "nil" or chassis == "" then
            chassis = generateChassisNumber()
            
            cache[vehicleID]:setData("veh >> chassis", chassis)
            
            dbExec(connection, "UPDATE vehicle SET chassis = ? WHERE id = ?", chassis, vehicleID)
            
            outputDebugString("Chassis update: ID: #"..vehicleID..", New: "..chassis, 0, 255, 87, 87)
        end
        
        chassisCache[vehicleID] = chassis
        isValidChassis[chassis] = vehicleID
    end
end

addEventHandler("onVehicleLoad", root,
    function(id)
        checkChassis(id, source:getData("veh >> chassis"))
    end
)

addEventHandler("onVehicleDestroy", root,
    function(id)
        isValidChassis[chassisCache[id]] = nil
        chassisCache[id] = nil
        collectgarbage("collect")
    end
)

function generateChassisNumber()
    local chassis = "";
    chassis = chassis .. generateString(10, false, true);
    chassis = chassis .. generateString(3, true, false);
    chassis = chassis .. generateString(4, false, true);
    
    if isValidChassis[chassis] then 
        chassis = generateChassisNumber()
    end
    
    return string.upper(chassis);
end

function clearChassisCache(vehicle)
    if isElement(vehicle) then
        local id = vehicle:getData("vehicle")
        isValidChassis[chassisCache[id]] = nil
        chassisCache[id] = nil
        collectgarbage("collect")
        
        return true
    elseif tonumber(vehicle) then
        local id = tonumber(vehicle)
        isValidChassis[chassisCache[id]] = nil
        chassisCache[id] = nil
        collectgarbage("collect")
        
        return true
    end
    
    return false
end
