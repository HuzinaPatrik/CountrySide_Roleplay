addEventHandler("onClientVehicleStartEnter", root, 
    function(player, seat, door)
        if player == localPlayer then
            if getElementAlpha(source) ~= 255 then
                cancelEvent()
                return
            end

            setVehicleEngineState(source, source:getData("veh >> engine"))
            source.frozen = true 

            setElementData(localPlayer, "char >> belt", false)

            if not getElementData(source, "veh >> id") then
                cancelEvent()
                return
            end

            if getElementData(source, "needLoad") then
                cancelEvent()
                return
            end

            if getVehicleController(source) and seat == 0 or getVehicleController(source) and door == 0 then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                local green = exports['cr_core']:getServerColor("orange", true)
                outputChatBox(syntax .. "Ez nonrp-s kocsi lopás! Használd a "..green.."/kiszed [ID]"..white.." parancsot!",255,255,255,true)
                cancelEvent()
                return
            end

            if getElementData(source, "veh >> id") < 0 then
                if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleStart") then 
                    return 
                end

                if not tonumber(getElementData(source, "veh >> group")) or tonumber(getElementData(source, "veh >> group") or 0) ~= tonumber(getElementData(localPlayer, "char >> group") or 0) then 
                    if getElementData(source, "veh >> owner") ~= getElementData(localPlayer, "acc >> id") and seat == 0 then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        local green = exports['cr_core']:getServerColor("orange", true)
                        outputChatBox(syntax .. "Ez nem a te ideiglenes járműved!",255,255,255,true)
                        cancelEvent()
                        return
                    end
                end 
            end

            if getElementData(source, "veh >> locked") then
                if tonumber((source:getData("veh >> tuningData") or {})["stealwarning"] or 0) == 1 then 
                    if not source:getData("veh >> stealWarning") then 
                        source:setData("veh >> stealWarning", true)
                    end 
                end 

                local doorO = getVehicleDoorOpenRatio(source, seat + 2)
                if doorO > 0 then
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A jármű zárva van!",255,255,255,true)
                    cancelEvent()
                    return
                end
            end

            if getVehicleType(source) == "BMX" or getVehicleType(source) == "Bike" or getVehicleType(source) == "Quad" then
                if getElementData(source, "veh >> locked") then
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A jármű zárva van!",255,255,255,true)
                    cancelEvent()
                    return
                end
            end
        end
    end
)

addEventHandler("onClientPlayerVehicleEnter", localPlayer, 
    function()
        local veh = getPedOccupiedVehicle(localPlayer)
        local value = getElementData(veh, "veh >> engine")
        local newOdometer = getElementData(veh, "veh >> odometer") or 0

        setVehicleEngineState(veh, value)
        veh.frozen = veh:getData("veh >> handbrake")

        setElementData(localPlayer, "oldVehicle", getElementData(veh, "veh >> id"))

        old = veh.position

        oldOdometerFloor = math.floor(newOdometer)
        
        if getVehicleType(veh) == "Automobile" or getVehicleType(veh) == "Plane" or getVehicleType(veh) == "Monster Truck" then
            local breaked = false;
            local occupants = getVehicleOccupants(veh);

            for k,v in pairs(occupants) do
                if not getElementData(v, "char >> belt") and getElementData(veh, "veh >> engine") then
                     breaked = true;
                end
            end

            if breaked then
                setBeltSound(veh);
            else
                setBeltSound(veh);
            end
        end

        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "info")
            outputChatBox(syntax .. "A jármű beindításához nyomd hosszan a #E34F4F[J] #FFFFFF+ #E34F4F[SPACE] #FFFFFFbillentyűt! ",255,255,255,true)
            outputChatBox(syntax .. "A biztonsági öv becsatolásához nyomd meg az #E34F4F[F5] #FFFFFFbillentyűt!",255,255,255,true)
            outputChatBox(syntax .. "A legközelebbi ablak lehúzásához használd az #E34F4F[F2]#FFFFFF gombot, az ablak kezelő felülethez pedig tartsd lenyomva a gombot #E34F4F1 másodpercig",255,255,255,true)

            if disabledType[getVehicleType(veh)] then
                setElementData(veh, "veh >> engine", false)
                setElementData(veh, "veh >> engine", true)
            end
        end
    end
)

function playVehicleSound3D(sourcePlayer, soundPath)
    local sound = playSound3D(soundPath, sourcePlayer.vehicle.position)
    sound.dimension = sourcePlayer.vehicle.dimension 
    sound.interior = sourcePlayer.vehicle.interior 
    sound:attach(sourcePlayer.vehicle)
end 
addEvent("playVehicleSound3D", true)
addEventHandler("playVehicleSound3D", root, playVehicleSound3D)

oldGear = 1
setTimer(
    function()
        if localPlayer.vehicle and localPlayer.vehicleSeat == 0 then 
            if localPlayer.vehicle.health <= 550 then 
                if oldGear ~= getVehicleCurrentGear(localPlayer.vehicle) then 
                    oldGear = getVehicleCurrentGear(localPlayer.vehicle)

                    if tonumber(oldGear) and tonumber(oldGear) >= 1 then 
                        local rand = math.random(1, 100)
                        local chance = (1 - (localPlayer.vehicle.health - 300) / 250) * 100
                        if rand <= chance then 
                            local players = exports['cr_core']:getNearbyPlayers("medium")
                            local soundPath = "assets/sounds/gearbox.mp3"
                            local sound = playSound3D(soundPath, localPlayer.vehicle.position)
                            sound.dimension = localPlayer.vehicle.dimension 
                            sound.interior = localPlayer.vehicle.interior 
                            sound:attach(localPlayer.vehicle)
                            if #players >= 1 then 
                                triggerLatentServerEvent("playVehicleSound3D", 5000, false, localPlayer, localPlayer, players, soundPath)
                            end 
                        end 
                    end 
                end 
            end 
        end 
    end, 500, 0
)

function toggleEngine()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    if getElementData(veh, "veh >> engine") then return end
    if disabledType[getVehicleType(veh)] then return end
    if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return end
    -- if exports['cr_core']:getElementSpeed(localPlayer.vehicle) ~= 0 then return end

    if not getElementData(veh, "veh >> engine") then 
        local hasKey = exports['cr_inventory']:hasItem(localPlayer, keyItem, getElementData(veh, "veh >> id"))
            
        if(exports['cr_permission']:hasPermission(localPlayer, "forceVehicleStart") or veh:getData("veh >> job") and veh:getData("veh >> owner") == localPlayer:getData("acc >> id") or veh:getData("veh >> temporaryVehicle") and veh:getData("veh >> owner") == localPlayer:getData("acc >> id")) then
            hasKey = true
        end
        
        if getElementData(localPlayer.vehicle, "veh >> id") < 0 then
            if getElementData(localPlayer.vehicle, "veh >> owner") == getElementData(localPlayer, "acc >> id") then
                hasKey = true
            end 
        end  

        if veh:getData("veh >> fueling") then 
            exports.cr_infobox:addBox("error", "Tankolás közben nem tudod elindítani a járművet.")
            
            return
        end

        if hasKey then
            if isElement(vehicleSound) then destroyElement(vehicleSound) end 
            vehicleSound = playSound("assets/sounds/enginestart.mp3")
        end    
        
        if getKeyState("j") then
            if isTimer(spamTimerEngine) then return end

            if hasKey then
                if isElement(vehicleSound) then destroyElement(vehicleSound) end 
                vehicleSound = playSound("assets/sounds/engine.mp3")
            else 
                local vehicleName = getVehicleName(veh)
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                -- exports['cr_infobox']:addBox("error", "Kifogyott az üzemenyanyag a járművedből!")
                --outputChatBox(syntax.."Nincs kulcsod a járműhöz!", 255, 255, 255, true)
                exports['cr_infobox']:addBox("error", "Nincs kulcsod a járműhöz!")

                return 
            end
                
            if isTimer(engineStartTimer) then killTimer(engineStartTimer) end 
            engineStartTimer = setTimer(function()
                if getKeyState("space") then
                    local veh = getPedOccupiedVehicle(localPlayer)
                    if veh then 
                        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                            local oldValue = getElementData(veh, "veh >> engine")
                            local newValue = not oldValue
                            if newValue then
                                if getElementData(veh, "veh >> engineBroken") then
                                    local vehicleName = getVehicleName(veh)
                                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                                    exports['cr_chat']:createMessage(localPlayer, "beindítani egy "..vehicleName.." motorját", "try2 >> failed")
                                    exports['cr_infobox']:addBox("error", "A jármű motorja túlságosan sérült!")
                                        
                                    return
                                elseif getElementData(veh, "veh >> fuel") <= 0 then
                                    local vehicleName = getVehicleName(veh)
                                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                                    exports['cr_chat']:createMessage(localPlayer, "beindítani egy "..vehicleName.." motorját", "try2 >> failed")
                                    exports['cr_infobox']:addBox("error", "Kifogyott az üzemenyanyag a járművedből!")
                                        
                                    return
                                elseif veh.health <= 550 then 
                                    local chance = (1 - (veh.health - 300) / 250) * 100
                                    local rand = math.random(1, 100)
                                    --outputChatBox(inspect(rand).. " >> "..inspect(chance))
                                    if rand <= chance then 
                                        local vehicleName = getVehicleName(veh)
                                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                                        exports['cr_chat']:createMessage(localPlayer, "beindítani egy "..vehicleName.." motorját", "try2 >> failed")
                                        exports['cr_infobox']:addBox("error", "Lefulladt a járműved!")

                                        return 
                                    end

                                    local players = exports['cr_core']:getNearbyPlayers("medium")
                                    local soundPath = "assets/sounds/fanbelt2.mp3"
                                    local sound = playSound3D(soundPath, localPlayer.vehicle.position)
                                    sound.dimension = localPlayer.vehicle.dimension 
                                    sound.interior = localPlayer.vehicle.interior 
                                    sound:attach(localPlayer.vehicle)
                                    if #players >= 1 then 
                                        triggerLatentServerEvent("playVehicleSound3D", 5000, false, localPlayer, localPlayer, players, soundPath)
                                    end 
                                end
                                        
                                if hasKey then
                                    if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleStart") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then 
                                        local vehicleName = getVehicleName(veh)
                                        local syntax = exports['cr_admin']:getAdminSyntax()
                                        local green = exports['cr_core']:getServerColor("orange", true)
                                        local id = getElementData(veh, "veh >> id")
                                        local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                                        local time = getTime() .. " "
                                        exports['cr_logs']:addLog(localPlayer, "sql", "Admin-VehicleStart", time .. aName .. " beindította a(z) "..id.." idjü ("..vehicleName..") motorját!")
                                    end
                                            
                                    if not (getElementData(veh, "veh >> engineBroken")) and (getElementData(veh, "veh >> fuel")) > 0 then
                                        local vehicleName = getVehicleName(veh)
                                        setElementData(veh, "veh >> engine", newValue)
                                        exports['cr_chat']:createMessage(localPlayer, "beindította egy "..vehicleName.." motorját", 1)
                                            
                                        return
                                    end 
                                            
                                else
                                    local vehicleName = getVehicleName(veh)
                                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                                    -- exports['cr_infobox']:addBox("error", "Kifogyott az üzemenyanyag a járművedből!")
                                    --outputChatBox(syntax.."Nincs kulcsod a járműhöz!", 255, 255, 255, true)
                                    exports['cr_infobox']:addBox("error", "Nincs kulcsod a járműhöz!")
                                end
                            end
                        end
                    end
                end    
            end, 1050, 1)
        end 
    end    
end
bindKey("space", "down", toggleEngine)

function toggleEngineDown()
    local veh = getPedOccupiedVehicle(localPlayer)
    
    if veh then
        if disabledType[getVehicleType(veh)] then return end

        if isTimer(spamTimerEngine) then return end
        spamTimerEngine = setTimer(function() end, math.random(125, 125), 1)

        if isTimer(engineStartTimer) then killTimer(engineStartTimer) end 
        
        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
            local oldValue = getElementData(veh, "veh >> engine")
            local newValue = not oldValue
            
            if not newValue then
                local vehicleName = getVehicleName(veh)  
				exports['cr_chat']:createMessage(localPlayer, "leállította egy "..vehicleName.." motorját", 1)
                setElementData(veh, "veh >> engine", newValue)
                if isElement(vehicleOffSound) then destroyElement(vehicleOffSound) end 
			    vehicleOffSound = playSound("assets/sounds/engineoff.mp3")
            end
        end
    end
end
bindKey("j", "down", toggleEngineDown)