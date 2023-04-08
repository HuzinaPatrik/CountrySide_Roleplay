function toggleLock()
    local veh = getPedOccupiedVehicle(localPlayer)
    if isTimer(spamTimerLock) then return end
    spamTimerLock = setTimer(function() end, math.random(500,500), 1)
	
    local syntax = exports['cr_core']:getServerSyntax(false, "error")
	
    if veh then
        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
            local hasKey = exports['cr_inventory']:hasItem(localPlayer, keyItem, getElementData(veh, "veh >> id")) or false
            if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") then 
                hasKey = true
            end

            if getElementData(veh, "veh >> id") < 0 then
                if getElementData(veh, "veh >> owner") == getElementData(localPlayer, "acc >> id") or exports['cr_core']:getPlayerDeveloper(localPlayer) then
                    hasKey = true
                end 
            end  

            if localPlayer:getData('char >> group') then
                if tonumber(veh:getData('veh >> id') or 0) < 0 then 
                    if tonumber(veh:getData('veh >> group') or -1) == tonumber(localPlayer:getData('char >> group') or -2) then 
                        hasKey = true
                    end 
                end 
            end 
            
            if getElementData(veh, "veh >> forceToggleDoor") then
                hasKey = false
            end
            
            if hasKey then
                local oldValue = getElementData(veh, "veh >> locked")
                local newValue = not oldValue
                setElementData(veh, "veh >> lockSource", localPlayer)
                setElementData(veh, "veh >> locked", newValue)
                veh:setData("veh >> stealWarning", false)
                local vehicleName = getVehicleName(veh)
                
                if not newValue then
                    exports['cr_chat']:createMessage(localPlayer, "kinyitotta egy "..vehicleName.." ajtaját", 1)
                    if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then 
                        local syntax = exports['cr_admin']:getAdminSyntax()
                        local green = exports['cr_core']:getServerColor("orange", true)
                        local id = getElementData(veh, "veh >> id")
                        local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                        local time = getTime() .. " "
                        exports['cr_logs']:addLog(localPlayer, "sql", "Admin-VehicleOpen", time .. aName .. " kinyitotta a(z) "..id.." idjü ("..vehicleName..") jármű ajtaját!")
                    end
                else
                    exports['cr_chat']:createMessage(localPlayer, "bezárta egy "..vehicleName.." ajtaját", 1)
                    
                    if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then 
                        local syntax = exports['cr_admin']:getAdminSyntax()
                        local green = exports['cr_core']:getServerColor("orange", true)
                        local id = getElementData(veh, "veh >> id")
                        local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                        local time = getTime() .. " "
                        exports['cr_logs']:addLog(localPlayer, "sql", "Admin-VehicleOpen", time .. aName .. " bezárta a(z) "..id.." idjü ("..vehicleName..") jármű ajtaját!")
                    end
                end
			else
				outputChatBox(syntax.."Nincs kulcsod a járműhöz!", 255, 255, 255, true)
				exports['cr_infobox']:addBox("error", "Nincs kulcsod a járműhöz!")
            end
        else
            local hasKey = exports['cr_inventory']:hasItem(localPlayer, keyItem, getElementData(veh, "veh >> id")) or false
            if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") then 
                hasKey = true
            end 

            if getElementData(veh, "veh >> id") < 0 then
                if getElementData(veh, "veh >> owner") == getElementData(localPlayer, "acc >> id") or exports['cr_core']:getPlayerDeveloper(localPlayer) then
                    hasKey = true
                end 
            end  

            if localPlayer:getData('char >> group') then
                if tonumber(veh:getData('veh >> id') or 0) < 0 then 
                    if tonumber(veh:getData('veh >> group') or -1) == tonumber(localPlayer:getData('char >> group') or -2) then 
                        hasKey = true
                    end 
                end 
            end 

            if getElementData(veh, "veh >> forceToggleDoor") then
                hasKey = false
            end
            
            if hasKey then
                local oldValue = getElementData(veh, "veh >> locked")
                local newValue = not oldValue
                setElementData(veh, "veh >> lockSource", localPlayer)
                setElementData(veh, "veh >> locked", newValue)
                veh:setData("veh >> stealWarning", false)
                local vehicleName = getVehicleName(veh)
                if not newValue then
                    exports['cr_chat']:createMessage(localPlayer, "kinyitotta egy "..vehicleName.." ajtaját", 1)
                    
                    if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") then 
                        local syntax = exports['cr_admin']:getAdminSyntax()
                        local green = exports['cr_core']:getServerColor("orange", true)
                        local id = getElementData(veh, "veh >> id")
                        local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                        local time = getTime() .. " "
                        exports['cr_logs']:addLog(localPlayer, "sql", "Admin-VehicleOpen", time .. aName .. " kinyitotta a(z) "..id.." idjü ("..vehicleName..") jármű ajtaját!")
                    end
                else
                    exports['cr_chat']:createMessage(localPlayer, "bezárta egy "..vehicleName.." ajtaját", 1)
                    
                    if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") then 
                        local syntax = exports['cr_admin']:getAdminSyntax()
                        local green = exports['cr_core']:getServerColor("orange", true)
                        local id = getElementData(veh, "veh >> id")
                        local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                        local time = getTime() .. " "
                        exports['cr_logs']:addLog(localPlayer, "sql", "Admin-VehicleOpen", time .. aName .. " bezárta a(z) "..id.." idjü ("..vehicleName..") jármű ajtaját!")
                    end
                end
            else
				outputChatBox(syntax.."Nincs kulcsod a járműhöz!", 255, 255, 255, true)
				exports['cr_infobox']:addBox("error", "Nincs kulcsod a járműhöz!")
            end
        end
    else
        veh = getClosestVehicle(6, true)
        
        if veh then
            local hasKey = exports['cr_inventory']:hasItem(localPlayer, keyItem, getElementData(veh, "veh >> id")) or false
            if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") then 
                hasKey = true
            end

            if getElementData(veh, "veh >> id") < 0 then
                if getElementData(veh, "veh >> owner") == getElementData(localPlayer, "acc >> id") or exports['cr_core']:getPlayerDeveloper(localPlayer) then
                    hasKey = true
                end 
            end  

            if localPlayer:getData('char >> group') then
                if tonumber(veh:getData('veh >> id') or 0) < 0 then 
                    if tonumber(veh:getData('veh >> group') or -1) == tonumber(localPlayer:getData('char >> group') or -2) then 
                        hasKey = true
                    end 
                end 
            end 

            if getElementData(veh, "veh >> forceToggleDoor") then
                hasKey = false
            end

            if hasKey then
                local oldValue = getElementData(veh, "veh >> locked")
                local newValue = not oldValue
                triggerServerEvent("onLock", localPlayer, veh)
                setElementData(veh, "veh >> lockSource", localPlayer)
                setElementData(veh, "veh >> locked", newValue)
                veh:setData("veh >> stealWarning", false)
                local vehicleName = getVehicleName(veh)
                
                if not newValue then
                    exports['cr_chat']:createMessage(localPlayer, "kinyitotta egy "..vehicleName.." ajtaját", 1)
                    
                    if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") then 
                        local syntax = exports['cr_admin']:getAdminSyntax()
                        local green = exports['cr_core']:getServerColor("orange", true)
                        local id = getElementData(veh, "veh >> id")
                        local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                        local time = getTime() .. " "
                        
                        exports['cr_logs']:addLog(localPlayer, "sql", "Admin-VehicleOpen", time .. aName .. " kinyitotta a(z) "..id.." idjü ("..vehicleName..") jármű ajtaját!")
                    end
                else
                    exports['cr_chat']:createMessage(localPlayer, "bezárta egy "..vehicleName.." ajtaját", 1)
                    
                    if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") then 
                        local syntax = exports['cr_admin']:getAdminSyntax()
                        local green = exports['cr_core']:getServerColor("orange", true)
                        local id = getElementData(veh, "veh >> id")
                        local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                        local time = getTime() .. " "
                        
                        exports['cr_logs']:addLog(localPlayer, "sql", "Admin-VehicleOpen", time .. aName .. " bezárta a(z) "..id.." idjü ("..vehicleName..") jármű ajtaját!")
                    end
                end
            else
				--outputChatBox(syntax.."Nincs kulcsod a járműhöz!", 255, 255, 255, true)
				exports['cr_infobox']:addBox("error", "Nincs kulcsod a járműhöz!")
            end	
        end
    end
end
bindKey("K", "down", toggleLock)

addEventHandler("onClientElementDataChange", root, 
    function(dName)
        if getElementType(source) == "vehicle" and isElementStreamedIn(source) then
            local value = getElementData(source, dName)
            if dName == "veh >> engineBroken" then
                if value then
                    local veh = getPedOccupiedVehicle(localPlayer)
                    if veh then
                        if disabledType[getVehicleType(veh)] then return end

                        if veh == source then
                            exports['cr_infobox']:addBox("error", "A járműved motorja súlyos károkat szenvedett ezért lerobbant!")
                        end
                    end
                end
            elseif dName == "veh >> fuel" then
                if value <= 0 then
                    local veh = getPedOccupiedVehicle(localPlayer)
                    if veh then
                        if veh == source then
                            exports['cr_infobox']:addBox("error", "Kifogyott az üzemanyag a járművedből!")

                            if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                                if getElementData(source, "veh >> engine") then
                                    setElementData(source, "veh >> engine", false)
                                end

                                if getVehicleEngineState(source) then
                                    setVehicleEngineState(source, false)
                                end
                            end
                        end
                    end
                end
            elseif dName == "veh >> odometer" then
                if getElementData(source, "veh >> fueltype") ~= getElementData(source, "veh >> oldfueltype") then
                    if value >= value + math.random(-1, 3) then
                        local veh = getPedOccupiedVehicle(localPlayer)
                        if veh == source then
                            if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                                exports['cr_infobox']:addBox("error", "Rossz üzemanyag lett tankolva a járműbe, ezért a motor tönkrement!")

                                triggerServerEvent("setVehicleHealth", localPlayer, source, 300)
                                
                                if getElementData(source, "veh >> engine") then
                                    setElementData(source, "veh >> engine", false)
                                end

                                if getVehicleEngineState(source) then
                                    setVehicleEngineState(source, false)
                                end
                            end
                        end
                    end
                end
            elseif dName == "veh >> engine" then
                setVehicleEngineState(source, value)
            elseif utfSub(dName, 1, 13) == "veh >> window" and utfSub(dName, 1, 14) ~= "veh >> windowS" and #dName > 13 then
                local num = tonumber(utfSub(dName, 14, 14))
                if num then
                    local window = true
                    setVehicleWindowOpen(source, num, value)

                    for i = 2, 5 do
                        local state = getElementData(source, "veh >> window"..i.."State")
                        if state then
                            window = false
                            break
                        end
                    end

                    setElementData(source, "veh >> windows >> closed", window)
                    
                    --alapból true, ha az egyik levan húzva akkor false
                end
            elseif dName == "veh >> locked" then
                local sourceElement = getElementData(source, "veh >> lockSource")
                local veh = source
                if sourceElement then
                    veh = getPedOccupiedVehicle(sourceElement)
                end

                if veh and veh == source then
                    local veh2 = getPedOccupiedVehicle(localPlayer)
                    if veh2 and veh == veh2 then
                        if disabledType[getVehicleType(veh)] then return end

                        playSound("assets/sounds/lockin.mp3")
                    end
                else
                    if disabledType[getVehicleType(source)] then return end

                    local x,y,z = getElementPosition(source)
                    local sound = playSound3D("assets/sounds/lock.mp3", x, y, z)
                    sound:attach(source)
                    --setSoundMaxDistance(sound, 50)
                    setElementDimension(sound, getElementDimension(source))
                    setElementInterior(sound, getElementInterior(source))
                end
            end
        end
    end
)

function triggerVehicleLock(id)
    if tonumber(id) then
        for k, v in pairs(getElementsByType("vehicle", _, true)) do
            if v:getData("veh >> id") == id then
                local dist = getDistanceBetweenPoints3D(v.position, localPlayer.position)
                if dist <= 16 then
                    local enabled = exports["cr_inventory"]:hasItem(localPlayer, 16, tonumber(v:getData("veh >> id"))) or localPlayer:getData("admin >> duty") and tonumber(localPlayer:getData("admin >> level")) > 5 or exports['cr_core']:getPlayerDeveloper(localPlayer)

                    if enabled then
                        local oldValue = getElementData(v, "veh >> locked")
                        local newValue = not oldValue
                        setElementData(v, "veh >> lockSource", localPlayer)
                        setElementData(v, "veh >> locked", newValue)
                        veh:setData("veh >> stealWarning", false)
                        local vehicleName = getVehicleName(v)

                        if not newValue then
                            exports['cr_chat']:createMessage(localPlayer, "kinyitotta egy "..vehicleName.." ajtaját", 1)
                        else
                            exports['cr_chat']:createMessage(localPlayer, "bezárta egy "..vehicleName.." ajtaját", 1)
                        end
                        
                        return true
                    end
                end
            end
        end

        return false
    end
end