addEvent("fixVehicle", true)
addEventHandler("fixVehicle", root, function(e)
    setElementData(e, "veh >> engineBroken", false)
    fixVehicle(e)
end)

addEvent("unflipVehicle", true)
addEventHandler("unflipVehicle", root, function(e)
    local a1, a2, a3 = getElementRotation(e)
    setElementRotation(e, 0, a2, a3)
end)

addEvent("setElementPosition", true)
addEventHandler("setElementPosition", root, function(e, x,y,z, dim, int)
    setElementPosition(e, x,y,z)
    setElementData(e,"veh >> oldDim",getElementDimension(e))
        
    if dim then
        setElementDimension(e, dim)
    end
            
    if int then
        setElementInterior(e, int)
    end
end)

addEvent("setElementHealth", true)
addEventHandler("setElementHealth", root, function(e, health)
    setElementHealth(e, health)
end)
    
addEvent("destroyElement", true)
addEventHandler("destroyElement", root, function(e)
    destroyElement(e)
end)

addEvent("setVehicleColor", true)
addEventHandler("setVehicleColor", root, function(e, r,g,b,r1,g1,b1)
    local a
    if not r1 or not b1 or not g1 or tonumber(r1) == nil or tonumber(g1) == nil or tonumber(b1) == nil then 
        a, a, a, r1, g1, b1 = getVehicleColor(e, true)
    end
            
    setVehicleColor(e, r,g,b, r1, g1, b1)
end)

addEvent("respawnThisCar", true)
addEventHandler("respawnThisCar", root, function(e, x,y,z,rx,ry,rz,int,dim)
    local occupants = getVehicleOccupants(e)
    for k,v in pairs(occupants) do
        removePedFromVehicle(v)
    end
            
    --setElementData(e, "veh >> engineBroken", false)
    --fixVehicle(e)
    setElementFrozen(e, true)
    setElementPosition(e, x,y,z)
    setElementDimension(e, dim)
    setElementInterior(e, int)
    setElementRotation(e, rx,ry,rz)
    setElementData(e, "veh >> handbrake", true)
    setElementData(e, "veh >> locked", true)
    setElementData(e, "veh >> engine", false)
            
    if getVehicleType(e) == "Bike" then
        setElementData(e, "veh >> engine", false)
    end
end)

addEvent("setVehiclePlateText", true)
addEventHandler("setVehiclePlateText", root, function(e, target, id, text)
    if text == "Rand" or text == "rand" then
        text = generatePlateText()
    end
        
    local id = getElementData(target, "veh >> id") or 0
            
    text = string.upper(text)
            
    if isValidPlate[text] then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Ez a rendszám már használatban van!",e,255,255,255,true)
        return
    end
        
    local oldPlate = target:getData("veh >> plateText")
        
    if isValidPlate[oldPlate] then
        isValidPlate[oldPlate] = nil
    end
            
    plates[id] = text
    isValidPlate[text] = true
        
    target.plateText = text
    target:setData("veh >> plateText", text)
            
    local green = exports['cr_core']:getServerColor('yellow', true)
    local syntax = exports['cr_core']:getServerSyntax(false, "success")
    local vehicleName = getVehicleName(target)
            
    outputChatBox(syntax .. "Sikeresen átírtad egy jármű rendszámtábláját ("..text..") (ID: "..green..id..white..")", e, 255,255,255,true)
            
    local aName = exports['cr_admin']:getAdminName(e, true)
    local syntax = exports['cr_admin']:getAdminSyntax()
            
    exports['cr_core']:sendMessageToAdmin(e, syntax..green..aName..white.." átírta egy jármű rendszámtábláját ("..text..") (ID: "..green..id..white..")", 3)
            
    local time = getTime() .. " "
    exports['cr_logs']:addLog(e, "sql", "setvehplatetext", time .. aName .. " átírta egy jármű rendszámtábláját ("..text..") (ID: "..id..")")
end)

addEvent("deleteVehicle", true)
addEventHandler("deleteVehicle", root, function(e, vehicle, id)
    deleteVehicle(id)
end)

addEvent("deleteTemporaryVehicle", true)
addEventHandler("deleteTemporaryVehicle", root, function(e, vehicle, id)
    destroyTemporaryVehicle(id)
end)

addEvent("nearbyVehicleOutput", true)
addEventHandler("nearbyVehicleOutput", root, function(e, text, ownerID, green, white)
    local ownerName = exports['cr_account']:getCharacterNameByID(ownerID)
    local ownerName = ownerName:gsub("_", " ")
    local text = text:gsub("@4", green..ownerName..white)
            
    outputChatBox(text, e, 255,255,255, true)
end)

addEvent("receiveOwnerNameForStats.server", true)
addEventHandler("receiveOwnerNameForStats.server", root, function(e, text, ownerID, green, white)
    local ownerName = exports['cr_account']:getCharacterNameByID(ownerID)
    local ownerName = ownerName:gsub("_", " ")
    local text = text:gsub("@4", green..ownerName..white)
    triggerClientEvent(e, "receiveOwnerNameForStats.client", e, e, text)
end)

addEvent("blowVehicle", true)
addEventHandler("blowVehicle", root, function(vehicle)
    blowVehicle(vehicle, true)
end)

addEvent("makeVeh", true)
addEventHandler("makeVeh", root, function(e, model, target, id, factionID, playerID, pos, colors, playerName, e2)
    if factionID > 0 then
        playerID = 0
    elseif playerID > 0 then
        factionID = 0
    end
        
    dbExec(connection, "INSERT INTO `vehicle` SET `modelid`=?, `owner`=?, `faction`=?, `pos`=?, `parkPos`=?, `colors`=?", model, playerID, factionID, pos, pos, colors)
        
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            local tick = getTickCount()
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = row["id"]
                        loadVehicle(row)
                            
                        exports['cr_inventory']:giveItem(e, 16, id, 1, 100, 0, 0, model)
                        local green = exports['cr_core']:getServerColor('yellow', true)
                        local syntax = exports['cr_core']:getServerSyntax(false, "success")
                        local vehicleName = getVehicleName(model)
                        local faction = factionID

                        if factionID == 0 then
                            faction = "0"
                        end

                        outputChatBox(syntax .. "Sikeresen létrehoztál egy járművet (ID: "..green..id..white..")", e, 255,255,255,true)

                        local aName = exports['cr_admin']:getAdminName(e, true)
                        local syntax = exports['cr_admin']:getAdminSyntax()
                        local playerName = exports['cr_account']:getCharacterNameByID(playerID)

                        playerName = playerName:gsub("_", " ")
                        exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." létrehozott egy járművet (Tulajdonos: "..green..playerName..white..", Model: "..green..vehicleName..white..", FrakcióID: "..green..faction..white..") (ID: "..green..id..white..")", 8)

                        local time = getTime() .. " "
                        exports['cr_logs']:addLog(e, "sql", "makeveh", time .. aName .. " létrehozott egy járművet (Tulajdonos: "..playerName..", Model: "..vehicleName..", FrakcióID: "..faction..") (ID: "..id..")")
                    end,

                    function()
                        collectgarbage("collect")
                        outputDebugString("Loaded "..query_lines.." vehicles in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
                    end
                )
            end    
        end, 
    connection, "SELECT * FROM vehicle WHERE id=LAST_INSERT_ID()")
end) 