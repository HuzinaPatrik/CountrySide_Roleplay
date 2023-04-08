addCommandHandler("thiscar", function(cmd)
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then
        local id = getElementData(veh, "veh >> id")
        local green = exports['cr_core']:getServerColor('yellow', true)
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        outputChatBox(syntax .. "Jármű ID: "..green..id,255,255,255,true)
    else
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Nem tartózkodsz járműben!",255,255,255,true)
    end
end)

addCommandHandler("oldcar", function(cmd)
    local veh = getElementData(localPlayer, "oldVehicle")
    if veh then
        local id = veh
        local green = exports['cr_core']:getServerColor('yellow', true)
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        outputChatBox(syntax .. "Jármű ID: "..green..id,255,255,255,true)
    else
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Mióta felcsatlakoztál a szerverre még nem szálltál járműbe!",255,255,255,true)
    end
end)

function ParkVehicle()
    local veh = getPedOccupiedVehicle(localPlayer)
    
    if veh then
        if isTimer(spamTimerPark) then return end
        spamTimerPark = setTimer(function() end, math.random(500,500), 1)
        
        local ownerID = getElementData(localPlayer, "acc >> id")
        local ownerID2 = getElementData(veh, "veh >> owner")
        
        if exports['cr_permission']:hasPermission(localPlayer, "forcePark") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then
            ownerID = ownerID2
        end
        
        local faction = tonumber(veh:getData("veh >> faction") or 0)
        if ownerID ~= ownerID2 and faction == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Ez nem a te járműved!", 255,255,255,true)
            return
        elseif faction >= 1 then
            if not exports['cr_dashboard']:isPlayerInFaction(localPlayer, faction) then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "Nem parkozhatod le ezt a jármüvet mivel nem tartozol abba a frakcióba ahova ez a kocsi!", 255,255,255,true)
                return
            end
        end
        
        local x,y,z = getElementPosition(veh)
        local rx, ry, rz = getElementRotation(veh)
        local int, dim = getElementInterior(veh), getElementDimension(veh)
        local table = {x,y,z,rx,ry,rz,int,dim}
        
        setElementData(veh, "veh >> park", table)
        
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        exports['cr_infobox']:addBox("success", "Sikeresen megváltoztattad járműved park pozicióit!")
    end
end
addCommandHandler("park", ParkVehicle)
addCommandHandler("Park", ParkVehicle)
addCommandHandler("parkveh", ParkVehicle)

function GpsVehicle(cmd, id)
    if not id then
        if gpsState then
            if isTimer(gpsUpdateTimer) then killTimer(gpsUpdateTimer) end
            removeEventHandler("onClientMarkerHit", gpsMarker, finishGPS)
            if isElement(gpsMarker) then destroyElement(gpsMarker) end
            
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            exports['cr_radar']:destroyStayBlip("Járműved!")
            exports['cr_infobox']:addBox("info", "GPS Poziciók törölve!")
            gpsState = false
            
            return
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
            return
        end
    elseif tonumber(id) == nil then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        exports['cr_infobox']:addBox("error", "Az ID-nek egy számnak kell lennie!")
        
        return
    end
    
    local target = nil
    local id = math.floor(id)
    
    if gpsState then
        if isTimer(gpsUpdateTimer) then killTimer(gpsUpdateTimer) end
        removeEventHandler("onClientMarkerHit", gpsMarker, finishGPS)
        
        if isElement(gpsMarker) then destroyElement(gpsMarker) end
        
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        exports['cr_radar']:destroyStayBlip("Járműved!")
        exports['cr_infobox']:addBox("info", "GPS Poziciók törölve!")
        gpsState = false
    else
        local target = false
        for k,v in pairs(getElementsByType("vehicle")) do
            local id2 = getElementData(v, "veh >> id")
            if id2 then
                if id2 == tonumber(id) then
                    local hasKey = exports['cr_inventory']:hasItem(localPlayer, keyItem, id2) or true
                    if hasKey then
                        target = v
                        
                        break
                    else
                        local green = exports['cr_core']:getServerColor('yellow', true)
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        exports['cr_infobox']:addBox("error", "Nincs kulcsod a(z) "..id.." idjü járműhöz!")
                        return
                    end
                end
            end
        end
        
        if target then
            if getElementDimension(target) ~= 0 or getElementInterior(target) ~= 0 then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                exports['cr_infobox']:addBox("error", "A(z) "..id.." idjü jármű garázsban vagy egyébb interiorban található!")
                return
            end
            
            local x,y,z = getElementPosition(target)
			local blip = createBlip(x,y,z,0,2,255,0,0,255,0,0)
			attachElements(blip,target)
            exports['cr_radar']:createStayBlip("Járműved!",createBlip (x,y,z,0,2,255,0,0,255,0,0),1,"vehicle",24,24,255,87,87)
            
            gpsState = true
            gpsMarker = createMarker(x,y,z, "checkpoint", 6)
            attachElements(gpsMarker, target)
            addEventHandler("onClientMarkerHit", gpsMarker, finishGPS)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            exports['cr_infobox']:addBox("success", "Jármű megjelölve!")
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            exports['cr_infobox']:addBox("error", "Hibás jármű ID (ID: "..id..")")
        end
    end
end
addCommandHandler("gpskocsi", GpsVehicle)
addCommandHandler("Gpskocsi", GpsVehicle)

function finishGPS()
    if isTimer(gpsUpdateTimer) then killTimer(gpsUpdateTimer) end
    removeEventHandler("onClientMarkerHit", gpsMarker, finishGPS)
    if isElement(gpsMarker) then destroyElement(gpsMarker) end
    exports['cr_radar']:destroyStayBlip("Járműved!")
    exports['cr_infobox']:addBox("success", "Megérkeztél a kijelölt járműhöz!")
    gpsState = false
end

local seatNames = {
    [0] = "door_lf_dummy",
    [1] = "door_rf_dummy",
    [2] = "door_lr_dummy",
    [3] = "door_rr_dummy",
}

function removePedFromVehicleFunc(cmd, id)
    if not id then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. " /"..cmd.." [target]", 255, 255, 255, true)
        
        return
    end
    
    local target = exports['cr_core']:findPlayer(localPlayer, id)
    
    if target then
        if getElementData(target, "loggedIn") then
            local _target = target
            if target:getData("clone") then
                inspect(target:getData("clone"))
                target = target:getData("clone")
            end
            local veh = getPedOccupiedVehicle(target)
            
            if veh then
                
                local x,y,z = getElementPosition(target)
                local px,py,pz = getElementPosition(localPlayer)
                local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
                local dim1, dim2 = getElementDimension(localPlayer), getElementDimension(target)
                local int1, int2 = getElementInterior(localPlayer), getElementInterior(target)
                
                if dist < 4 and dim1 == dim2 and int1 == int2 then
                    local veh = getPedOccupiedVehicle(target)
                    if veh then
                        if not getElementData(veh, "veh >> locked") then
                            if not getElementData(target, "char >> belt") then
                                if target == localPlayer then
                                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                                    local name = exports['cr_admin']:getAdminName(target)
                                    local green = exports['cr_core']:getServerColor('yellow', true)
                                    outputChatBox(syntax .. "Saját magadat nem rángathatod ki!", 255,255,255,true)
                                    
                                    return
                                end
                                
                                local name = exports['cr_admin']:getAdminName(_target)
                                exports['cr_chat']:createMessage(localPlayer, "kirángott valakit a gépjárműből ((" .. name .. "))", 1)
                                
                                local veh = getPedOccupiedVehicle(target)
                                local comPos = false
                                local seat = nil
                                if veh then
                                    seat = getPedOccupiedVehicleSeat(target)
                                    --triggerServerEvent("kickPlayerFromVeh", localPlayer, localPlayer)
                                    local name = seatNames[seat]
                                    local x,y,z = getVehicleComponentPosition(veh, name, "world")
                                    if x and y and z then
                                        comPos = {x,y,z}
                                    end
                                    
                                    if comPos then
                                        x,y,z = unpack(comPos)
                                    else
                                        if getVehicleType(veh) == "BMX" or getVehicleType(veh) == "Bike" then
                                            x,y,z = getElementPosition(veh)
                                            if seat == 0 then
                                                x = x + 0.5
                                                y = y + 0.5
                                            elseif seat == 1 then
                                                x = x - 0.5
                                                y = y - 0.5
                                            end
                                        else
                                            if getElementModel(veh) == 539 or getElementModel(veh) == 457 or getElementModel(veh) == 424 or getElementModel(veh) == 568 then
                                                if seat == 1 then
                                                    x,y,z = getElementPosition(veh)
                                                    x = x + 1
                                                    y = y + 1
                                                elseif seat == 0 then
                                                    x,y,z = getElementPosition(veh)
                                                    x = x - 1
                                                    y = y - 1
                                                end
                                            else
                                                x,y,z = getElementPosition(veh)
                                                x = x + 3
                                                y = y + 3
                                            end    
                                        end
                                    end
                                    z = z + 0.1
                                    
                                    comPos = {x,y,z}
                                end
                            
                                triggerServerEvent("kickPlayerFromVeh", localPlayer, target, comPos)
                                
                                return
                            else
                                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                                local name = exports['cr_admin']:getAdminName(target)
                                local green = exports['cr_core']:getServerColor('yellow', true)
                                outputChatBox(syntax .. green .. name .. white .. " biztonsági öve be van csatolva!", 255,255,255,true)
                                
                                return
                            end
                        else
                            local syntax = exports['cr_core']:getServerSyntax(false, "error")
                            outputChatBox(syntax .. "A jármű zárva van!", 255,255,255,true)
                            
                            return
                        end
                    end
                end
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                local name = exports['cr_admin']:getAdminName(target)
                local green = exports['cr_core']:getServerColor('yellow', true)
                outputChatBox(syntax .. green .. name .. white .. " nincs járműben!", 255,255,255,true)
                
                return
            end
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
        end
    end
end
addCommandHandler("kiszed", removePedFromVehicleFunc)

function destroyBeltPlayer(cmd, id)
    if not id then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. " /"..cmd.." [target]", 255, 255, 255, true)
        
        return
    end
    
    local target = exports['cr_core']:findPlayer(localPlayer, id)
    
    if target then
        if getElementData(target, "loggedIn") then
            local _target = target
            if target:getData("clone") then
                target = target:getData("clone")
            end
            
            local veh = getPedOccupiedVehicle(target)
            
            if veh then
                
                local x,y,z = getElementPosition(target)
                local px,py,pz = getElementPosition(localPlayer)
                local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
                local dim1, dim2 = getElementDimension(localPlayer), getElementDimension(target)
                local int1, int2 = getElementInterior(localPlayer), getElementInterior(target)
                
                if dist < 4 and dim1 == dim2 and int1 == int2 then
                    local veh = getPedOccupiedVehicle(target)
                    if veh then
                        if not getElementData(veh, "veh >> locked") then
                            if getElementData(target, "char >> belt") then
                                local hasItem, slot, data = exports['cr_inventory']:hasItem(localPlayer, 133)
                                if hasItem then
                                    if target == localPlayer then
                                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                                        local name = exports['cr_admin']:getAdminName(target)
                                        local green = exports['cr_core']:getServerColor('yellow', true)
                                        outputChatBox(syntax .. "Saját magad övét nem vághatod el!", 255,255,255,true)

                                        return
                                    end

                                    if not target:getData("clone") then
                                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                                        local name = exports['cr_admin']:getAdminName(target)
                                        local green = exports['cr_core']:getServerColor('yellow', true)
                                        outputChatBox(syntax .. "A célpontnak halottnak kell lennie!", 255,255,255,true)

                                        return
                                    end

                                    local name = exports['cr_admin']:getAdminName(target)
                                    exports['cr_chat']:createMessage(localPlayer, "elvágja valaki övét ((" .. name .. "))", 1)

                                    target:setData("char >> belt", false)
                                    triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, 1)

                                    return
                                else
                                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                                    local name = exports['cr_admin']:getAdminName(target)
                                    local green = exports['cr_core']:getServerColor('yellow', true)
                                    outputChatBox(syntax .." Nincs nálad övelvágó genyó (átírás kell)!", 255,255,255,true)

                                    return
                                end
                            else
                                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                                local name = exports['cr_admin']:getAdminName(target)
                                local green = exports['cr_core']:getServerColor('yellow', true)
                                outputChatBox(syntax .. green .. name .. white .. " biztonsági öve ki van csatolva!", 255,255,255,true)
                                
                                return
                            end
                        else
                            local syntax = exports['cr_core']:getServerSyntax(false, "error")
                            outputChatBox(syntax .. "A jármű zárva van!", 255,255,255,true)
                            
                            return
                        end
                    end
                end
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                local name = exports['cr_admin']:getAdminName(target)
                local green = exports['cr_core']:getServerColor('yellow', true)
                outputChatBox(syntax .. green .. name .. white .. " nincs járműben!", 255,255,255,true)
                
                return
            end
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
        end
    end
end
addCommandHandler("ovelvag", destroyBeltPlayer)
addCommandHandler("elvag", destroyBeltPlayer)