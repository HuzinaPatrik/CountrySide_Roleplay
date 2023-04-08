function buyProtectForVehicle(vehicle)
    if isElement(client) and isElement(vehicle) then 
        local vehId = vehicle:getData("veh >> id")
        local localName = exports.cr_admin:getAdminName(client)

        exports.cr_logs:addLog(client, "sql", "buyprotect", localName .. " vásárolt egy protectet egy járműre. Jármű id: " .. vehId)
        exports.cr_infobox:addBox(client, "success", "Sikeresen megvásároltad a protectet a járműre!")
        vehicle:setData("veh >> protect", true)

        dbExec(connection, "UPDATE vehicle SET protect = ? WHERE id = ?", "true", vehId)
    end
end
addEvent("vehicle.buyProtectForVehicle", true)
addEventHandler("vehicle.buyProtectForVehicle", root, buyProtectForVehicle)

function removeProtectFromVehicle(vehicle)
    if isElement(client) and isElement(vehicle) then 
        local vehId = vehicle:getData("veh >> id")
        local localName = exports.cr_admin:getAdminName(client)

        exports.cr_logs:addLog(client, "sql", "removeprotect", localName .. " levett egy protectet egy járműről. Jármű id: " .. vehId)
        exports.cr_infobox:addBox(client, "success", "Sikeresen levetted a protectet a járműről!")
        vehicle:setData("veh >> protect", false)

        dbExec(connection, "UPDATE vehicle SET protect = ? WHERE id = ?", "false", vehId)
    end
end
addEvent("vehicle.removeProtectFromVehicle", true)
addEventHandler("vehicle.removeProtectFromVehicle", root, removeProtectFromVehicle)