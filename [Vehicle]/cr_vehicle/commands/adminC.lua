function gotoCar(cmd, id)
    if not id then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
        
        return
    elseif tonumber(id) == nil then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Az ID-nek egy számnak kell lennie!", 255,255,255,true)
        
        return
    end
    
    local id = math.floor(id)
    local target = nil
    if exports['cr_permission']:hasPermission(localPlayer, "gotocar") then
        local target = false
        for k,v in pairs(getElementsByType("vehicle")) do
            local id2 = getElementData(v, "veh >> id")
            if id2 == tonumber(id) then
                target = v
                
                break
            end
        end
        
        if target then
            local x,y,z = getElementPosition(target)
            local dim, int = getElementDimension(target), getElementInterior(target)
            local veh = getPedOccupiedVehicle(localPlayer)
            if veh then
                triggerServerEvent("setElementPosition", localPlayer, veh, x,y,z, dim, int)
            end
            
            setElementPosition(localPlayer, x,y,z + 1)
            setElementDimension(localPlayer, dim)
            setElementInterior(localPlayer, int)
            
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local vehicleName = getVehicleName(target)
            
            outputChatBox(syntax .. "Sikeresen elteleportáltál a járműhöz. (ID: "..green..id..white..")", 255,255,255,true)
            
            local aName = exports['cr_admin']:getAdminName(localPlayer, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            local time = getTime() .. " "
            
            exports['cr_logs']:addLog(localPlayer, "sql",  "Gotocar", time .. aName .. " odateleportált a(z) "..id.." idjü ("..vehicleName..")  járműhöz!")
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Hibás jármű ID (ID: "..green..id..white..")", 255,255,255,true)
        end
    end
end
addCommandHandler("gotocar", gotoCar)

function getCar(cmd, id)
    if not id then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
        
        return
    elseif tonumber(id) == nil then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Az ID-nek egy számnak kell lennie!", 255,255,255,true)
        
        return
    end
    
    local id = math.floor(id)
    local ownVehicle = false
    local target = nil
    if exports['cr_permission']:hasPermission(localPlayer, "getcar") then
        local target = false
        for k,v in pairs(getElementsByType("vehicle")) do
            local id2 = getElementData(v, "veh >> id")
            if id2 == tonumber(id) then
                if getElementData(v, "veh >> owner") == getElementData(localPlayer, "acc >> id") then
                    ownVehicle = true
                end
                
                target = v
                
                break
            end
        end
        
        if target then
            local x,y,z = getElementPosition(localPlayer)
            local rot = getPedRotation(localPlayer)
			local x, y, z = getElementPosition(localPlayer)
			x = x + 2
			y = y + 2
            local dim, int = getElementDimension(localPlayer), getElementInterior(localPlayer)
            triggerServerEvent("setElementPosition", localPlayer, target, x,y,z, dim, int)
            
            if ownVehicle then
                local green = exports['cr_core']:getServerColor('yellow', true)
                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                local vehicleName = getVehicleName(target)
                
                outputChatBox(syntax .. "Sikeresen magadhoz teleportáltad a járművet (ID: "..green..id..white..") (Saját jármű)", 255,255,255,true)
                
                local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                local syntax = exports['cr_admin']:getAdminSyntax()
                local time = getTime() .. " "
                
                exports['cr_logs']:addLog(localPlayer, "sql",  "GetcarOWN", time .. aName .. " magához teleportálta a(z) "..id.." idjü ("..vehicleName..")  járművet! (Saját jármű)")
            else
                local green = exports['cr_core']:getServerColor('yellow', true)
                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                local vehicleName = getVehicleName(target)
                
                outputChatBox(syntax .. "Sikeresen magadhoz teleportáltad a járművet (ID: "..green..id..white..")", 255,255,255,true)
                
                local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                local syntax = exports['cr_admin']:getAdminSyntax()
                local time = getTime() .. " "
                
                exports['cr_logs']:addLog(localPlayer, "sql",  "Getcar", time .. aName .. " magához teleportálta a(z) "..id.." idjü ("..vehicleName..")  járművet!")
            end
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Hibás jármű ID (ID: "..green..id..white..")", 255,255,255,true)
        end
    end
end
addCommandHandler("getcar", getCar)
addCommandHandler("getveh", getCar)

local maxDistNearby = 8

function nearbyVehicles(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "nearbyvehicle") then
        local target = false
        local px, py, pz = getElementPosition(localPlayer)
        local green = exports['cr_core']:getServerColor('yellow', true)
        local syntax = exports['cr_core']:getServerSyntax(false, "info")
        local hasVeh = false
        
        for k,v in pairs(getElementsByType("vehicle"), root, true) do
            local x,y,z = getElementPosition(v)
            local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
            
            if dist <= maxDistNearby then
                local id = getElementData(v, "veh >> id")
                if id > 0 then
                    if getElementDimension(v) == getElementDimension(localPlayer) then
                        local model = v:getData('veh >> virtuaModellID') or getElementModel(v)
                        local vehicleName = getVehicleName(v)
                        local ownerID = getElementData(v, "veh >> owner")
                        
                        triggerServerEvent("nearbyVehicleOutput", localPlayer, localPlayer, syntax.."Model: "..green..model..white.." ("..green..vehicleName..white.."), ID: "..green..id..white..", Tulaj: @4 ("..green..ownerID..white.."), Távolság: "..green..math.floor(dist)..white.." yard", ownerID, green, white)
                        hasVeh = true
                    end
                end
            end
        end
        
        if not hasVeh then
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Nincs jármű a közeledben!", 255,255,255,true)
        end
    end
end
addCommandHandler("nearbyvehicles", nearbyVehicles)
addCommandHandler("nearbyveh", nearbyVehicles)
addCommandHandler("nearbyvehs", nearbyVehicles)

local maxHasFix = 1

function fixVehicle(cmd, id)
    if not id then
        if not getPedOccupiedVehicle(localPlayer) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
            
            return
        else
            id = getElementData(localPlayer, "char >> name")
        end
    end
    
    local ownVehicle = false
    local target = nil
    local targetPlayer
    
    if exports['cr_permission']:hasPermission(localPlayer, "fixveh") then
        local targetPlayer = exports['cr_core']:findPlayer(localPlayer, id)
        if not targetPlayer then
            local veh = getPedOccupiedVehicle(localPlayer)
            
            if veh then
                target = veh
                targetPlayer = localPlayer
                id = getElementData(veh, "veh >> id")
            end
        end
        
        if targetPlayer then
            if getElementData(targetPlayer, "loggedIn")  then
                local veh = getPedOccupiedVehicle(targetPlayer)
                if not veh then
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs járműben", 255,255,255,true)
                    
                    return
                else
                    target = veh
                    id = getElementData(veh, "veh >> id")
                    local ownerID = getElementData(veh, "veh >> owner")
                    
                    if ownerID == getElementData(localPlayer, "acc >> id") then
                        ownVehicle = true
                    end
                end
                
                if ownVehicle then
                    local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local vehicleName = getVehicleName(target)
                    
                    outputChatBox(syntax .. "Sikeresen megjavítottad "..green..id..white.." járművét!", 255,255,255,true)
                    
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." megjavította "..green..id..white.." járművét! (Saját jármű)", 3)
                    
                    local time = getTime() .. " "
                    exports['cr_logs']:addLog(localPlayer, "sql",  "fixvehOWN", time .. aName .. " megjavította "..id.." járművét (Saját jármű)")
                    
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local text = syntax .. green .. aName .. white .. " megjavította a járműved!"
                    
                    triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                else
                    local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local vehicleName = getVehicleName(target)
                    
                    outputChatBox(syntax .. "Sikeresen megjavítottad "..green..id..white.." járművét!", 255,255,255,true)
                    
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." megjavította "..green..id..white.." járművét!", 3)
                    
                    local time = getTime() .. " "
                    exports['cr_logs']:addLog(localPlayer, "sql",  "fixveh", time .. aName .. " megjavította "..id.." járművét")
                    
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local text = syntax .. green .. aName .. white .. " megjavította a járműved!"
                    
                    triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                end
                
                local hasFIX = getElementData(localPlayer, "fix >> using") or 0
                local hasFIX = hasFIX + 1
                setElementData(localPlayer, "fix >> using", hasFIX)
                
                if hasFIX > maxHasFix then
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    local vehicleName = getVehicleName(target)
                    
                    outputChatBox(syntax .. "Figyelem! Átlépted a megengedett FIX limitet! (Limit: "..green..maxHasFix..white..") (Fixek száma: "..green..hasFIX..white..")", 255,255,255,true)
                end
                
                triggerServerEvent("fixVehicle", localPlayer, target)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A játékos nem található", 255,255,255,true)
        end
    end
end
addCommandHandler("fixveh", fixVehicle)
addCommandHandler("fix", fixVehicle)

function unflipVehicle(cmd, id)
    if not id then
        if not getPedOccupiedVehicle(localPlayer) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
            
            return
        else
            id = getElementData(localPlayer, "char >> name")
        end
    end
    
    local ownVehicle = false
    local target = nil
    local targetPlayer
    
    if exports['cr_permission']:hasPermission(localPlayer, "unflip") then
        local targetPlayer = exports['cr_core']:findPlayer(localPlayer, id)
        if not targetPlayer then
            local veh = getPedOccupiedVehicle(localPlayer)
            
            if veh then
                target = veh
                targetPlayer = localPlayer
                id = getElementData(veh, "veh >> id")
            end
        end
        if targetPlayer then
            if getElementData(targetPlayer, "loggedIn") then
                local veh = getPedOccupiedVehicle(targetPlayer)
                
                if not veh then
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs járműben", 255,255,255,true)
                    
                    return
                else
                    target = veh
                    id = getElementData(veh, "veh >> id")
                    
                    local ownerID = getElementData(veh, "veh >> owner")
                    if ownerID == getElementData(localPlayer, "acc >> id") then
                        ownVehicle = true
                    end
                end
                if ownVehicle then
                    local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local vehicleName = getVehicleName(target)
                    
                    outputChatBox(syntax .. "Sikeresen helyreállítottad "..green..id..white.." járművét! (Saját jármű)", 255,255,255,true)
                    
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." helyreállította "..green..id..white.." járművét! (Saját jármű)", 3)
                    
                    local time = getTime() .. " "
                    exports['cr_logs']:addLog(localPlayer, "sql",  "unflipOWN", time .. aName .. " helyreállította "..id.." járművét! (Saját jármű)")
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local text = syntax .. green .. aName .. white .. " helyreállította a járműved!"
                    
                    triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                else
                    local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local vehicleName = getVehicleName(target)
                    
                    outputChatBox(syntax .. "Sikeresen helyreállítottad a(z) "..green..id..white.." idjü ("..green..vehicleName..white..") járművet!", 255,255,255,true)
                    
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." helyreállította "..green..id..white.." járművét!", 3)
                    
                    local time = getTime() .. " "
                    exports['cr_logs']:addLog(localPlayer, "sql",  "unflip", time .. aName .. " helyreállította "..id.." járművét!")
                    
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local text = syntax .. green .. aName .. white .. " helyreállította a járműved!"
                    
                    triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                end
                
                triggerServerEvent("unflipVehicle", localPlayer, target)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            
            outputChatBox(syntax .. "A játékos nem található", 255,255,255,true)
        end
    end
end
addCommandHandler("unflip", unflipVehicle)
addCommandHandler("unflipveh", unflipVehicle)

function setCarHealth(cmd, id, health)
    if not id or not health then
        if not getPedOccupiedVehicle(localPlayer) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ID] [Health (0-1000)]", 255,255,255,true)
            
            return
        else
            id = getElementData(localPlayer, "char >> name")
        end
        
        health = 1000
    elseif tonumber(health) == nil then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Az Health-nak egy számnak kell lennie!", 255,255,255,true)
        
        return
    elseif tonumber(health) < 300 or tonumber(health) > 1000 then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Az Health-nak egy számnak kell lennie mely 300 és 1000 között van!", 255,255,255,true)
        
        return
    end
    
    local ownVehicle = false
    local target = nil
    local targetPlayer
    
    if exports['cr_permission']:hasPermission(localPlayer, "setcarhp") then
        local targetPlayer = exports['cr_core']:findPlayer(localPlayer, id)
        
        if not targetPlayer then
            local veh = getPedOccupiedVehicle(localPlayer)
            if veh then
                target = veh
                targetPlayer = localPlayer
                id = getElementData(veh, "veh >> id")
            end
        end
        
        if targetPlayer then
            if getElementData(targetPlayer, "loggedIn") then
                local veh = getPedOccupiedVehicle(targetPlayer)
                if not veh then
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs járműben", 255,255,255,true)
                    
                    return
                else
                    target = veh
                    id = getElementData(veh, "veh >> id")
                    
                    local ownerID = getElementData(veh, "veh >> owner")
                    if ownerID == getElementData(localPlayer, "acc >> id") then
                        ownVehicle = true
                    end
                end
                
                if ownVehicle then
                    local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local vehicleName = getVehicleName(target)
                    
                    outputChatBox(syntax .. "Sikeresen átálítottad "..green..id..white.." járművének életszintjét (Új érték: "..green..health..white..") (Saját jármű)", 255,255,255,true)
                    
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." átállította "..green..id..white.." járművének életszíntjét (Új érték: "..green..health..white..") (Saját jármű)", 4)
                    
                    local time = getTime() .. " "
                    exports['cr_logs']:addLog(localPlayer, "sql",  "setcarhpOWN", time .. aName.." átállította "..id.." járművének életszíntjét (Új érték: "..health..")! (Saját jármű)")
                    
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local text = syntax .. green .. aName .. white .. " átállította a járműved életszintjét! (Új érték: "..green..health..white..")"
                    
                    triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                else
                    local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local vehicleName = getVehicleName(target)
                    
                    outputChatBox(syntax .. "Sikeresen átálítottad "..green..id..white.." járművének életszintjét (Új érték: "..green..health..white..")", 255,255,255,true)
                    
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." átállította "..green..id..white.." járművének életszíntjét (Új érték: "..green..health..white..")", 4)
                    
                    local time = getTime() .. " "
                    exports['cr_logs']:addLog(localPlayer, "sql",  "setcarhp", time .. aName.." átállította "..id.." járművének életszíntjét (Új érték: "..health..")")
                    
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    
                    local text = syntax .. green .. aName .. white .. " átállította a járműved életszintjét! (Új érték: "..green..health..white..")"
                    
                    triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                end
                
                triggerServerEvent("setElementHealth", localPlayer, target, tonumber(health))
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A játékos nem található", 255,255,255,true)
        end
    end
end
addCommandHandler("setcarhp", setCarHealth)

local maxHasRTC = 1
local minDistance = 8

function respawnThisCar(cmd)
    local ownVehicle = false
    local target = nil
    local shortest = {5000, nil}
    local px,py,pz = getElementPosition(localPlayer)
    
    if exports['cr_permission']:hasPermission(localPlayer, "rtc") then
        for k,v in pairs(getElementsByType("vehicle", root, true)) do
            local id = getElementData(v, "veh >> id") or 0
            
            if id > 0 then
                local x,y,z = getElementPosition(v)
                local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
                
                if dist < shortest[1] and dist < minDistance then
                    target = v
                    shortest = {dist, v}
                end
            end
        end
    end
    
    if shortest[2] then
        local id = tonumber(getElementData(target, "veh >> id") or -1)
        if id ~= -1 then
            local ownVehicle = getElementData(target, "veh >> owner") == getElementData(localPlayer, "acc >> id")
            
            if ownVehicle then
                local green = exports['cr_core']:getServerColor('yellow', true)
                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                local vehicleName = getVehicleName(target)
                
                outputChatBox(syntax .. "Sikeresen respawnoltad a járművet (ID: "..green..id..white..") (Saját jármű)", 255,255,255,true)
                
                local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                local syntax = exports['cr_admin']:getAdminSyntax()
                
                exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." respawnolt egy járművet (ID: "..green..id..white..") (Saját jármű)", 4)
                
                local time = getTime() .. " "
                exports['cr_logs']:addLog(localPlayer, "sql",  "rtcOWN", time .. aName.." respawnolt egy járművet (ID: "..id..") (Saját jármű)")
            else
                local green = exports['cr_core']:getServerColor('yellow', true)
                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                local vehicleName = getVehicleName(target)
                
                outputChatBox(syntax .. "Sikeresen respawnoltad a járművet (ID: "..green..id..white..")", 255,255,255,true)
                
                local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                local syntax = exports['cr_admin']:getAdminSyntax()
                
                exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." respawnolt egy járművet (ID: "..green..id..white..")", 4)
                
                local time = getTime() .. " "
                exports['cr_logs']:addLog(localPlayer, "sql",  "rtc", time .. aName.." respawnolt egy járművet (ID: "..id..")")
            end
            
            local hasRTC = getElementData(localPlayer, "rtc >> using") or 0
            local hasRTC = hasRTC + 1
            setElementData(localPlayer, "rtc >> using", hasRTC)
            
            if hasRTC > maxHasRTC then
                local green = exports['cr_core']:getServerColor('yellow', true)
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                local vehicleName = getVehicleName(target)
                
                outputChatBox(syntax .. "Figyelem! Átlépted a megengedett RTC limitet! (Limit: "..green..maxHasRTC..white..") (RTC-k száma: "..green..hasRTC..white..")", 255,255,255,true)
            end
            
            local x,y,z,rx,ry,rz,int,dim = unpack(getElementData(target, "veh >> park"))
            triggerServerEvent("respawnThisCar", localPlayer, target, x,y,z,rx,ry,rz,int,dim)
        end
    end
end
addCommandHandler("rtc", respawnThisCar)
addCommandHandler("respawnthiscar", respawnThisCar)

local maxHasFuel = 1

function fuelVehicle(cmd, id)
    if not id then
        if not getPedOccupiedVehicle(localPlayer) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
            return
        else
            id = getElementData(localPlayer, "char >> name")
        end
    end
    local ownVehicle = false
    local target = nil
    local targetPlayer
    if exports['cr_permission']:hasPermission(localPlayer, "fuelveh") then
        local targetPlayer = exports['cr_core']:findPlayer(localPlayer, id)
        if not targetPlayer then
            local veh = getPedOccupiedVehicle(localPlayer)
            if veh then
                target = veh
                targetPlayer = localPlayer
                id = getElementData(veh, "veh >> id")
            end
        end
        if targetPlayer then
            if getElementData(targetPlayer, "loggedIn") then
                local veh = getPedOccupiedVehicle(targetPlayer)
                if not veh then
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs járműben", 255,255,255,true)
                    return
                else
                    target = veh
                    --targetPlayer = localPlayer
                    id = getElementData(veh, "veh >> id")
                    local ownerID = getElementData(veh, "veh >> owner")
                    if ownerID == getElementData(localPlayer, "acc >> id") then
                        ownVehicle = true
                    end
                end
                if ownVehicle then
                    local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local vehicleName = getVehicleName(target)
                    outputChatBox(syntax .. "Sikeresen megtankoltad "..green..id..white.." járművét!", 255,255,255,true)
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." megtankolta "..green..id..white.." járművét! (Saját jármű)", 3)
                    local time = getTime() .. " "
                    exports['cr_logs']:addLog(localPlayer, "sql",  "fuelvehOWN", time .. aName .. " megtankolta "..id.." járművét (Saját jármű)")
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local text = syntax .. green .. aName .. white .. " megtankolta a járműved!"
                    triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                else
                    local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local vehicleName = getVehicleName(target)
                    outputChatBox(syntax .. "Sikeresen megtankoltad "..green..id..white.." járművét!", 255,255,255,true)
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." megtankolta "..green..id..white.." járművét!", 3)
                    local time = getTime() .. " "
                    exports['cr_logs']:addLog(localPlayer, "sql",  "fuelveh", time .. aName .. " megtankolta "..id.." járművét")
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local text = syntax .. green .. aName .. white .. " megtankolta a járműved!"
                    triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                end
                local hasFuel = getElementData(localPlayer, "fuel >> using") or 0
                local hasFuel = hasFuel + 1
                setElementData(localPlayer, "fuel >> using", hasFuel)
                if hasFuel > maxHasFuel then
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    local vehicleName = getVehicleName(target)
                    outputChatBox(syntax .. "Figyelem! Átlépted a megengedett FUEL limitet! (Limit: "..green..maxHasFuel..white..") (Fuelek száma: "..green..hasFuel..white..")", 255,255,255,true)
                end
                setElementData(target, "veh >> fuel", maxFuel[target:getData('veh >> virtuaModellID') or getElementModel(target)])
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A játékos nem található", 255,255,255,true)
        end
    end
end
addCommandHandler("fuelveh", fuelVehicle)
addCommandHandler("fuel", fuelVehicle)

function setCarFuel(cmd, id, health)
    if not id or not health then
        if not getPedOccupiedVehicle(localPlayer) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ID] [Fuel (0-maxFuel)]", 255,255,255,true)
            return
        else
            id = getElementData(localPlayer, "char >> name")
            local model = localPlayer.vehicle:getData('veh >> virtuaModellID') or getElementModel(localPlayer.vehicle)
            health = maxFuel[model]
        end
    elseif tonumber(health) == nil then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "A Fuel-nek egy számnak kell lennie!", 255,255,255,true)
        return
    end
    local ownVehicle = false
    local target = nil
    local targetPlayer
    if exports['cr_permission']:hasPermission(localPlayer, "setfuelveh") then
        local targetPlayer = exports['cr_core']:findPlayer(localPlayer, id)
        if not targetPlayer then
            local veh = getPedOccupiedVehicle(localPlayer)
            if veh then
                target = veh
                targetPlayer = localPlayer
                id = getElementData(veh, "veh >> id")
            end
        end
        if targetPlayer then
            if getElementData(targetPlayer, "loggedIn") then
                local veh = getPedOccupiedVehicle(targetPlayer)
                if not veh then
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs járműben", 255,255,255,true)
                    return
                else
                    target = veh
                    --targetPlayer = localPlayer
                    id = getElementData(veh, "veh >> id")
                    local ownerID = getElementData(veh, "veh >> owner")
                    if ownerID == getElementData(localPlayer, "acc >> id") then
                        ownVehicle = true
                    end
                end
                local model = target:getData('veh >> virtuaModellID') or getElementModel(target)
                if tonumber(health) < 0 or tonumber(health) > maxFuel[model] then
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A Fuel-nek egy számnak kell lennie mely 0 és "..maxFuel[target:getData('veh >> virtuaModellID') or getElementModel(target)].." között van!", 255,255,255,true)
                    return
                end
                if ownVehicle then
                    local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local vehicleName = getVehicleName(target)
                    outputChatBox(syntax .. "Sikeresen átálítottad "..green..id..white.." járművének benzinszintjét (Új érték: "..green..health..white..") (Saját jármű)", 255,255,255,true)
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." átállította "..green..id..white.." járművének benzinszintjét (Új érték: "..green..health..white..") (Saját jármű)", 4)
                    local time = getTime() .. " "
                    exports['cr_logs']:addLog(localPlayer, "sql",  "setfuelvehOWN", time .. aName.." átállította "..id.." járművének benzinszintjét (Új érték: "..health..")! (Saját jármű)")
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local text = syntax .. green .. aName .. white .. " átállította a járműved benzinszintjét! (Új érték: "..green..health..white..")"
                    triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                else
                    local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local vehicleName = getVehicleName(target)
                    outputChatBox(syntax .. "Sikeresen átálítottad "..green..id..white.." járművének benzinszintjét (Új érték: "..green..health..white..")", 255,255,255,true)
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." átállította "..green..id..white.." járművének benzinszintjét (Új érték: "..green..health..white..")", 4)
                    local time = getTime() .. " "
                    exports['cr_logs']:addLog(localPlayer, "sql",  "setfuelveh", time .. aName.." átállította "..id.." járművének benzinszintjét (Új érték: "..health..")")
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local text = syntax .. green .. aName .. white .. " átállította a járműved benzinszintjét! (Új érték: "..green..health..white..")"
                    triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                end
                local hasFuel = getElementData(localPlayer, "fuel >> using") or 0
                local hasFuel = hasFuel + 1
                setElementData(localPlayer, "fuel >> using", hasFuel)
                if hasFuel > maxHasFuel then
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    local vehicleName = getVehicleName(target)
                    outputChatBox(syntax .. "Figyelem! Átlépted a megengedett FUEL limitet! (Limit: "..green..maxHasFuel..white..") (Fuelek száma: "..green..hasFuel..white..")", 255,255,255,true)
                end
                setElementData(target, "veh >> fuel", tonumber(health))
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A játékos nem található", 255,255,255,true)
        end
    end
end
addCommandHandler("setfuelveh", setCarFuel)
addCommandHandler("setvehfuel", setCarFuel)

function resetVehOil(cmd, id)
    if not id then
        if not getPedOccupiedVehicle(localPlayer) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
            return
        else
            id = getElementData(localPlayer, "char >> name")
        end
    end
    local ownVehicle = false
    local target = nil
    local targetPlayer
    if exports['cr_permission']:hasPermission(localPlayer, "resetvehoil") then
        local targetPlayer = exports['cr_core']:findPlayer(localPlayer, id)
        if not targetPlayer then
            local veh = getPedOccupiedVehicle(localPlayer)
            if veh then
                target = veh
                targetPlayer = localPlayer
                id = getElementData(veh, "veh >> id")
            end
        end
        if targetPlayer then
            if getElementData(targetPlayer, "loggedIn") then
                local veh = getPedOccupiedVehicle(targetPlayer)
                if not veh then
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs járműben", 255,255,255,true)
                    return
                else
                    target = veh
                    --targetPlayer = localPlayer
                    id = getElementData(veh, "veh >> id")
                    local ownerID = getElementData(veh, "veh >> owner")
                    if ownerID == getElementData(localPlayer, "acc >> id") then
                        ownVehicle = true
                    end
                end
                if ownVehicle then
                    local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local vehicleName = getVehicleName(target)
                    outputChatBox(syntax .. "Sikeresen újratöltötted "..green..id..white.." járművének olajszintjét (Saját jármű)", 255,255,255,true)
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." újratöltötte "..green..id..white.." járművének olajszintjét (Saját jármű)", 4)
                    local time = getTime() .. " "
                    exports['cr_logs']:addLog(localPlayer, "sql",  "resetvehoilOWN", time .. aName.." újratöltötte "..id.." járművének olajszintjét (Saját jármű)")
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local text = syntax .. green .. aName .. white .. " újratöltötte a járműved olajszintjét!"
                    triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                else
                    local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local vehicleName = getVehicleName(target)
                    outputChatBox(syntax .. "Sikeresen újratöltötted "..green..id..white.." járművének olajszintjét", 255,255,255,true)
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." újratöltötte "..green..id..white.." járművének olajszintjét", 4)
                    local time = getTime() .. " "
                    exports['cr_logs']:addLog(localPlayer, "sql",  "resetvehoil", time .. aName.." újratöltötte "..id.." járművének olajszintjét")
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local text = syntax .. green .. aName .. white .. " újratöltötte a járműved olajszintjét!"
                    triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                end
                local odometer = getElementData(target, "veh >> odometer")
                setElementData(target, "veh >> lastOilRecoil", odometer)
                if getElementData(target, "veh >> engineBroken") then
                    setElementData(target, "veh >> engineBroken", false)
                end
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A játékos nem található", 255,255,255,true)
        end
    end
end
addCommandHandler("resetvehoil", resetVehOil)

function setVehOil(cmd, id, oil)
    if not id or not oil and not tonumber(oil) then
        if not getPedOccupiedVehicle(localPlayer) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ID] [Oil (Hány kilómétert tett már meg az ezerből az utolsó olajcsere óta 0 - 1000)]", 255,255,255,true)
            return
        else
            id = getElementData(localPlayer, "char >> name")
        end
    elseif not tonumber(oil) then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Az Oilnak egy számnak kell lennie!", 255,255,255,true)
        return
    elseif tonumber(oil) < 0 or tonumber(oil) > 1000 then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Az Oilnak egy számnak kell lennie mely 0 és 1000 között van!", 255,255,255,true)
        return
    end
    if not oil then
        oil = 0 
    end
    local ownVehicle = false
    local target = nil
    local targetPlayer
    if exports['cr_permission']:hasPermission(localPlayer, "setvehoil") then
        local targetPlayer = exports['cr_core']:findPlayer(localPlayer, id)
        if not targetPlayer then
            local veh = getPedOccupiedVehicle(localPlayer)
            if veh then
                target = veh
                targetPlayer = localPlayer
                id = getElementData(veh, "veh >> id")
            end
        end
        if targetPlayer then
            if getElementData(targetPlayer, "loggedIn") then
                local veh = getPedOccupiedVehicle(targetPlayer)
                if not veh then
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs járműben", 255,255,255,true)
                    return
                else
                    target = veh
                    --targetPlayer = localPlayer
                    id = getElementData(veh, "veh >> id")
                    local ownerID = getElementData(veh, "veh >> owner")
                    if ownerID == getElementData(localPlayer, "acc >> id") then
                        ownVehicle = true
                    end
                end
                if ownVehicle then
                    local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local vehicleName = getVehicleName(target)
                    outputChatBox(syntax .. "Sikeresen átállítottad "..green..id..white.." járművének olajszintjét (Új érték: "..green..oil..white..") (Saját jármű)", 255,255,255,true)
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." átállította "..green..id..white.." járművének olajszintjét (Új érték: "..green..oil..white..") (Saját jármű)", 4)
                    local time = getTime() .. " "
                    exports['cr_logs']:addLog(localPlayer, "sql",  "setvehoilOWN", time .. aName.." átállította "..id.." járművének olajszintjét (Új érték: "..oil..") (Saját jármű)")
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local text = syntax .. green .. aName .. white .. " újratöltötte a járműved olajszintjét! (Új érték: "..green..oil..white..")"
                    triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                else
                    local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local vehicleName = getVehicleName(target)
                    outputChatBox(syntax .. "Sikeresen átállítottad "..green..id..white.." járművének olajszintjét (Új érték: "..green..oil..white..")", 255,255,255,true)
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." átállította "..green..id..white.." járművének olajszintjét (Új érték: "..green..oil..white..")", 4)
                    local time = getTime() .. " "
                    exports['cr_logs']:addLog(localPlayer, "sql",  "setvehoil", time .. aName.." átállította "..id.." járművének olajszintjét (Új érték: "..oil..")")
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local text = syntax .. green .. aName .. white .. " átállította a járműved olajszintjét! (Új érték: "..green..oil..white..")"
                    triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                end
                local odometer = getElementData(target, "veh >> odometer")
                setElementData(target, "veh >> lastOilRecoil", odometer - tonumber(oil))
                --[[
                if getElementData(target, "veh >> engineBroken") then
                    setElementData(target, "veh >> engineBroken", false)
                end
                ]]
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A játékos nem található", 255,255,255,true)
        end
    end
end
addCommandHandler("setvehoil", setVehOil)

function setVehicleInterior(cmd, id, int)
    if not id or not int then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [ID] [Interior]", 255,255,255,true)
        return
    elseif tonumber(id) == nil then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Az ID-nek egy számnak kell lennie!", 255,255,255,true)
        return 
    elseif tonumber(int) == nil then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Az Interiornak egy számnak kell lennie!", 255,255,255,true)
        return     
    end
    local id = math.floor(id)
    local ownVehicle = false
    local target = nil
    if exports['cr_permission']:hasPermission(localPlayer, "setvehint") then
        local target = false
        for k,v in pairs(getElementsByType("vehicle")) do
            local id2 = getElementData(v, "veh >> id") 
            if id2 == tonumber(id) then
                target = v
                break
            end
        end
        if target then
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local vehicleName = getVehicleName(target)
            outputChatBox(syntax .. "Sikeresen átállítottad egy jármű interiorját "..green..int..white.."-ra(re) (ID: "..green..id..white..")", 255,255,255,true)
            local x,y,z = getElementPosition(target)
            local dim = getElementDimension(target)
            triggerServerEvent("setElementPosition", localPlayer, target, x,y,z, dim, tonumber(int))
            local aName = exports['cr_admin']:getAdminName(localPlayer, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." átállította egy jármű interiorját "..green..int..white.."-ra(re) (ID: "..green..id..white..")", 3)
            local time = getTime() .. " "
            exports['cr_logs']:addLog(localPlayer, "sql",  "setvehint", time .. aName .. " átállította egy jármű interiorját "..int.."-ra(re) (ID: "..id..")")
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Hibás jármű ID (ID: "..green..id..white..")", 255,255,255,true)
        end
    end
end
addCommandHandler("setvehint", setVehicleInterior)

function setVehicleDimension(cmd, id, int)
    if not id or not int then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [ID] [Dimension]", 255,255,255,true)
        return
    elseif tonumber(id) == nil then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Az ID-nek egy számnak kell lennie!", 255,255,255,true)
        return 
    elseif tonumber(int) == nil then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Az Dimensionnak egy számnak kell lennie!", 255,255,255,true)
        return     
    end
    local id = math.floor(id)
    local ownVehicle = false
    local target = nil
    if exports['cr_permission']:hasPermission(localPlayer, "setvehdim") then
        local target = false
        for k,v in pairs(getElementsByType("vehicle")) do
            local id2 = getElementData(v, "veh >> id") 
            if id2 == tonumber(id) then
                target = v
                break
            end
        end
        if target then
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local vehicleName = getVehicleName(target)
            outputChatBox(syntax .. "Sikeresen átállítottad egy jármű dimenzióját "..green..int..white.."-ra(re) (ID: "..green..id..white..")", 255,255,255,true)
            local x,y,z = getElementPosition(target)
            local int2 = getElementInterior(target)
            triggerServerEvent("setElementPosition", localPlayer, target, x,y,z, tonumber(int), int2)
            local aName = exports['cr_admin']:getAdminName(localPlayer, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." átállította egy jármű dimenzióját "..green..int..white.."-ra(re) (ID: "..green..id..white..")", 3)
            local time = getTime() .. " "
            exports['cr_logs']:addLog(localPlayer, "sql",  "setvehdim", time .. aName .. " átállította egy jármű dimenzióját "..int.."-ra(re) (ID: "..id..")")
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Hibás jármű ID (ID: "..green..id..white..")", 255,255,255,true)
        end
    end
end
addCommandHandler("setvehdim", setVehicleDimension)

function setVehicleColorCMD(cmd, r,g,b, r1,g1,b1)
    if not r or not g or not b then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [R] [G] [B] [R1] [G1] [B1] (Az R1 G1 B1 nem szükséges csak az R G B)", 255,255,255,true)
        return
    elseif tonumber(r) == nil or tonumber(g) == nil or tonumber(b) == nil then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "A szinkódnak számnak kell lennie!", 255,255,255,true)
        return 
    end
    local ownVehicle = false
    local target = nil
    if exports['cr_permission']:hasPermission(localPlayer, "setvehcolor") then
        local target = getPedOccupiedVehicle(localPlayer)
        if target then
            local id = getElementData(target, "veh >> id") or 0
            local green = exports['cr_core']:getServerColor('yellow', true)
            local string = green .. r .. white .. ", " .. green .. g .. white .. ", " .. green .. b .. white
            local string2 = r .. ", " .. g .. ", " .. b
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local vehicleName = getVehicleName(target)
            outputChatBox(syntax .. "Sikeresen átállítottad egy jármű RGB színeit (Új színek: "..string..") (ID: "..green..id..white..")", 255,255,255,true)
            local aName = exports['cr_admin']:getAdminName(localPlayer, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." átállította egy jármű RGB színeit (Új színek: "..string..") (ID: "..green..id..white..")", 3)
            local time = getTime() .. " "
            exports['cr_logs']:addLog(localPlayer, "sql",  "setvehcolor", time .. aName .. " átállította egy jármű RGB színeit (Új színek: "..string2..") (ID: "..id..")")
            triggerServerEvent("setVehicleColor", localPlayer, target, r,g,b, r1, g1, b1)
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Nem vagy járműben!", 255,255,255,true)
        end
    end
end
addCommandHandler("setvehcolor", setVehicleColorCMD)
addCommandHandler("setcolor", setVehicleColorCMD)

function setVehiclePlateText(cmd, id, plateText)
    if not id or not plateText then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [ID] [Rendszámtábla (Rand = Random rendszám)]", 255,255,255,true)
        return
    elseif tonumber(id) == nil then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Az ID-nek egy számnak kell lennie!", 255,255,255,true)
        return
    elseif #plateText > 8 then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "A Rendszámtábla maximum 8 karakter lehet", 255,255,255,true)
        return
    end
    local id = math.floor(id)
    local target = nil
    if exports['cr_permission']:hasPermission(localPlayer, "setvehicleplatetext") then
        local target = false
        for k,v in pairs(getElementsByType("vehicle")) do
            local id2 = getElementData(v, "veh >> id") 
            if id2 == tonumber(id) then
                target = v
                break
            end
        end
        if target then
            triggerServerEvent("setVehiclePlateText", localPlayer, localPlayer, target, id, plateText)
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Hibás jármű ID (ID: "..green..id..white..")", 255,255,255,true)
        end
    end
end
addCommandHandler("setplatetext", setVehiclePlateText)
addCommandHandler("setvehplatetext", setVehiclePlateText)
addCommandHandler("setvehicleplatetext", setVehiclePlateText)

function adminChangeLock(cmd)
    local target = getPedOccupiedVehicle(localPlayer)
    if exports['cr_permission']:hasPermission(localPlayer, "achangelock") then
        if target then
            local id = getElementData(target, "veh >> id") or 0
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local vehicleName = getVehicleName(target)
            outputChatBox(syntax .. "Sikeresen changelockoltál egy járművet (ID: "..green..id..white..")", 255,255,255,true)
            local aName = exports['cr_admin']:getAdminName(e, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." changelockolt egy járművet (ID: "..green..id..white..")", 3)
            local time = getTime() .. " "
            exports['cr_logs']:addLog(localPlayer, "sql",  "achangelock", time .. aName .. " changelockolt egy járművet (ID: "..id..")")
            --exports['cr_inventory']:deleteAllItem(keyItem, id)
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Nem vagy járműben!", 255,255,255,true)
        end
    end
end
addCommandHandler("achangelock", adminChangeLock)

function makeVeh(cmd, playerID, id, factionID, r,g,b)
    if not id or not playerID or not factionID then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Játékos ID/Név] [Kocsinév/ModelID] [Frakció ID] [R] [G] [B]", 255,255,255,true)
        return
    elseif tonumber(factionID) == nil then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "A Frakció ID-nek egy számnak kell lennie!", 255,255,255,true)
        return
    end
    if not r then r = 0 end
    if not g then g = 0 end
    if not b then b = 0 end
    if tonumber(id) ~= nil then
        id = math.floor(id)
    end
    local target = exports['cr_core']:findPlayer(localPlayer, playerID)
    if exports['cr_permission']:hasPermission(localPlayer, "makeveh") then
        local model = false
        if tonumber(id) ~= nil then
            if getVehicleNameFromModel(tonumber(id)) or exports['cr_vehicles']:isVirtualVehicle(tonumber(id)) then
                model = tonumber(id)
            end
        elseif tonumber(id) == nil then
            id = tostring(id):gsub("_", " ")
            if getVehicleModelFromName(id) then
                model = getVehicleModelFromName(id)
            end
        end
        if model then
            if target then
                if getElementData(target, "loggedIn") then
                    local testVehicle = createVehicle(model <= 611 and model or 411, 0,0,0)
                    if isElement(testVehicle) then
                        destroyElement(testVehicle)
                        local x,y,z = getElementPosition(target)
                        local rx, ry, rz = 0, 0, 0
                        x = x + 2
                        y = y + 2
                        local int = getElementInterior(target)
                        local dim = getElementDimension(target)
                        local pos = toJSON({x,y,z,rx,ry,rz,int,dim,dim2})
                        local playerID = getElementData(target, "acc >> id")
                        --local playerName = exports['cr_account']:getCharacterNameByID(playerID)
                        --playerName = playerName:gsub("_", " ")
                        setElementData(localPlayer, "char >> belt", false)
                        triggerServerEvent("makeVeh", localPlayer, localPlayer, model, target, id, tonumber(factionID), tonumber(playerID), pos, toJSON({r,g,b}), playerName, target)
                        setElementData(localPlayer, "command >> makeveh >> enged", true)
                        setTimer( function()
                        	setElementData(localPlayer, "command >> makeveh >> enged", false)
                        end, 3000, 1) -- 3másodperc után enged lehívni újat!
                    else
                        local green = exports['cr_core']:getServerColor('yellow', true)
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Hibás modell id/név!", 255,255,255,true)
                    end
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            else
                local green = exports['cr_core']:getServerColor('yellow', true)
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nem található", 255,255,255,true)
            end
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Hibás modell id/név!", 255,255,255,true)
        end
    end
end
addCommandHandler("makeveh", makeVeh)

function delThisVehicle(cmd)
    local target = getPedOccupiedVehicle(localPlayer)
    if exports['cr_permission']:hasPermission(localPlayer, "delthisveh") then
        if target then
            local id = getElementData(target, "veh >> id") or 0
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local vehicleName = getVehicleName(target)
            outputChatBox(syntax .. "Sikeresen töröltél egy járművet (ID: "..green..id..white..")", 255,255,255,true)
            --exports['cr_sirenpanel']:toggleMusic(target)
            local aName = exports['cr_admin']:getAdminName(localPlayer, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." kitörölt egy járművet (ID: "..green..id..white..")", 8)
            local time = getTime() .. " "
            exports['cr_logs']:addLog(localPlayer, "sql",  "delveh", time .. aName .. " kitörölt egy járművet (ID: "..id..")")
            if id >= 1 then 
                triggerServerEvent("deleteVehicle", localPlayer, localPlayer, target, id)
            else
                triggerServerEvent("deleteTemporaryVehicle", localPlayer, localPlayer, target, id) 
            end 
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Nem vagy járműben!", 255,255,255,true)
        end
    end
end
addCommandHandler("delthisveh", delThisVehicle)

function deleteVehicle(cmd, id)
    if not id then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
        return
    elseif tonumber(id) == nil then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Az ID-nek egy számnak kell lennie!", 255,255,255,true)
        return
    end
    local id = math.floor(id)
    local ownVehicle = false
    local target = nil
    if exports['cr_permission']:hasPermission(localPlayer, "delveh") then
        local target = false
        for k,v in pairs(getElementsByType("vehicle")) do
            local id2 = getElementData(v, "veh >> id") 
            if id2 == tonumber(id) then
                if getElementData(v, "veh >> owner") == getElementData(localPlayer, "acc >> id") then
                    ownVehicle = true
                end
                target = v
                break
            end
        end

        if id <= 0 then 
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "Használd a "..green.."/deltempveh#ffffff parancsot!", 255,255,255,true)
            return 
        end 

        if target then
            local id = getElementData(target, "veh >> id") or 0
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local vehicleName = getVehicleName(target)
            outputChatBox(syntax .. "Sikeresen töröltél egy járművet (ID: "..green..id..white..")", 255,255,255,true)
            local aName = exports['cr_admin']:getAdminName(localPlayer, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." kitörölt egy járművet (ID: "..green..id..white..")", 8)
            local time = getTime() .. " "
            exports['cr_logs']:addLog(localPlayer, "sql",  "delveh", time .. aName .. " kitörölt egy járművet (ID: "..id..")")
            --exports['cr_inventory']:deleteItem(keyItem, id)
            triggerServerEvent("deleteVehicle", localPlayer, localPlayer, target, id)
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Hibás jármű ID (ID: "..green..id..white..")", 255,255,255,true)
        end
    end
end
addCommandHandler("delveh", deleteVehicle)

function deleteTemporaryVehicle(cmd, id)
    if not id then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
        return
    elseif tonumber(id) == nil then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Az ID-nek egy számnak kell lennie!", 255,255,255,true)
        return
    end
    local id = math.floor(id)
    local ownVehicle = false
    local target = nil
    if exports['cr_permission']:hasPermission(localPlayer, "deltempveh") then
        local target = false
        for k,v in pairs(getElementsByType("vehicle")) do
            local id2 = getElementData(v, "veh >> id") 
            if id2 == tonumber(id) then
                if getElementData(v, "veh >> owner") == getElementData(localPlayer, "acc >> id") then
                    ownVehicle = true
                end
                target = v
                break
            end
        end

        if id >= 0 then 
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "Használd a "..green.."/delveh#ffffff parancsot!", 255,255,255,true)
            return 
        end 

        if target then
            local id = getElementData(target, "veh >> id") or 0
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local vehicleName = getVehicleName(target)
            outputChatBox(syntax .. "Sikeresen töröltél egy járművet (ID: "..green..id..white..")", 255,255,255,true)
            local aName = exports['cr_admin']:getAdminName(localPlayer, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." kitörölt egy járművet (ID: "..green..id..white..")", 8)
            local time = getTime() .. " "
            exports['cr_logs']:addLog(localPlayer, "sql",  "delveh", time .. aName .. " kitörölt egy járművet (ID: "..id..")")
            --exports['cr_inventory']:deleteItem(keyItem, id)
            triggerServerEvent("deleteTemporaryVehicle", localPlayer, localPlayer, target, id)
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Hibás jármű ID (ID: "..green..id..white..")", 255,255,255,true)
        end
    end
end
addCommandHandler("deltempveh", deleteTemporaryVehicle)

function startVehicleEngine(cmd, id)
    if not id then
        if not getPedOccupiedVehicle(localPlayer) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
            return
        else
            id = getElementData(localPlayer, "char >> name")
        end
    end
    local ownVehicle = false
    local target = nil
    local targetPlayer
    if exports['cr_permission']:hasPermission(localPlayer, "startvehengine") then
        local targetPlayer = exports['cr_core']:findPlayer(localPlayer, id)
        if not targetPlayer then
            local veh = getPedOccupiedVehicle(localPlayer)
            if veh then
                target = veh
                targetPlayer = localPlayer
                id = getElementData(veh, "veh >> id")
            end
        end
        if targetPlayer then
            if getElementData(targetPlayer, "loggedIn") then
                local veh = getPedOccupiedVehicle(targetPlayer)
                if not veh then
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs járműben", 255,255,255,true)
                    return
                else
                    target = veh
                    --targetPlayer = localPlayer
                    id = getElementData(veh, "veh >> id")
                    local ownerID = getElementData(veh, "veh >> owner")
                    if ownerID == getElementData(localPlayer, "acc >> id") then
                        ownVehicle = true
                    end
                end
                local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                local green = exports['cr_core']:getServerColor('yellow', true)
                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                local vehicleName = getVehicleName(target)
                outputChatBox(syntax .. "Sikeresen beindítottad "..green..id..white.." járművét!", 255,255,255,true)
                local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                local syntax = exports['cr_admin']:getAdminSyntax()
                exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." beindította "..green..id..white.." járművét!", 3)
                local time = getTime() .. " "
                exports['cr_logs']:addLog(localPlayer, "sql",  "startvehengine", time .. aName .. " beindította "..id.." járművét")
                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                local text = syntax .. green .. aName .. white .. " beindította a járműved!"
                triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                setElementData(target, "veh >> engine", true)
                --triggerServerEvent("fixVehicle", localPlayer, target)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A játékos nem található", 255,255,255,true)
        end
    end
end
addCommandHandler("startvehengine", startVehicleEngine)

function stopVehicleEngine(cmd, id)
    if not id then
        if not getPedOccupiedVehicle(localPlayer) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
            return
        else
            id = getElementData(localPlayer, "char >> name")
        end
    end
    local ownVehicle = false
    local target = nil
    local targetPlayer
    if exports['cr_permission']:hasPermission(localPlayer, "stopvehengine") then
        local targetPlayer = exports['cr_core']:findPlayer(localPlayer, id)
        if not targetPlayer then
            local veh = getPedOccupiedVehicle(localPlayer)
            if veh then
                target = veh
                targetPlayer = localPlayer
                id = getElementData(veh, "veh >> id")
            end
        end
        if targetPlayer then
            if getElementData(targetPlayer, "loggedIn") then
                local veh = getPedOccupiedVehicle(targetPlayer)
                if not veh then
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs járműben", 255,255,255,true)
                    return
                else
                    target = veh
                    --targetPlayer = localPlayer
                    id = getElementData(veh, "veh >> id")
                    local ownerID = getElementData(veh, "veh >> owner")
                    if ownerID == getElementData(localPlayer, "acc >> id") then
                        ownVehicle = true
                    end
                end
                local id = getElementData(targetPlayer, "char >> name"):gsub("_", " ")
                local green = exports['cr_core']:getServerColor('yellow', true)
                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                local vehicleName = getVehicleName(target)
                outputChatBox(syntax .. "Sikeresen leállítottad "..green..id..white.." járművét!", 255,255,255,true)
                local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                local syntax = exports['cr_admin']:getAdminSyntax()
                exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." leállította "..green..id..white.." járművét!", 3)
                local time = getTime() .. " "
                exports['cr_logs']:addLog(localPlayer, "sql",  "stopvehengine", time .. aName .. " leállította "..id.." járművét")
                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                local text = syntax .. green .. aName .. white .. " leállította a járműved!"
                triggerServerEvent("outputChatBox", localPlayer, targetPlayer, text)
                setElementData(target, "veh >> engine", false)
                --triggerServerEvent("fixVehicle", localPlayer, target)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        else
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A játékos nem található", 255,255,255,true)
        end
    end
end
addCommandHandler("stopvehengine", stopVehicleEngine)