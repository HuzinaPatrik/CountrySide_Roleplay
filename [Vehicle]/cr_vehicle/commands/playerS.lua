addEvent("kickPlayerFromVeh", true)
addEventHandler("kickPlayerFromVeh", root, function(e, comPos)
    local veh = e.vehicle
    removePedFromVehicle(e)

    local x, y, z = e.position
    if comPos and type(comPos) == "table" then
        x,y,z = unpack(comPos)
    end
    setElementPosition(e, x, y, z)
end)