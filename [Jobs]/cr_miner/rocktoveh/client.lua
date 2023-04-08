local gVeh, start, startTick, loadingProgressEnabled
local animationTimer

setTimer(
    function()
        if not isJobStarted then 
            if start then
                loadingProgressEnabled = false
                start = false
            end

            return 
        end
        
        gVeh = localPlayer:getData("char >> jobVehicle")
        if isElement(gVeh) then
            local x, y, z = getVehicleComponentPosition(gVeh, "boot_dummy", "world")
            
            if getDistanceBetweenPoints3D(localPlayer.position, x, y,z ) <= 1 then
                local breaked = true
                local rockInHand = localPlayer:getData("miner >> rockInHand")
                local rocksInVeh = gVeh:getData("miner >> rocksInVeh") or {}

                if rockInHand then
                    if #rocksInVeh < jobData.maxRockInVeh then
                        breaked = false
                    end
                elseif #rocksInVeh > 0 then
                    breaked = false 
                end
                
                if not breaked and not exports.cr_network:getNetworkStatus() then
                    local text = ""
                    local colorCode = exports.cr_core:getServerColor("red", true)    
                    
                    if rockInHand then
                        text = "#f2f2f2A kő felrakásához használd a(z) [" .. colorCode .. "E#f2f2f2] billentyűt!"
                    elseif #rocksInVeh > 0 then
                        text = "#f2f2f2A kő levételéhez használd a(z) [" .. colorCode .. "E#f2f2f2] billentyűt!"
                    end 
                    
                    if not start then
                        loadingProgressEnabled = true
                        start = true
                        
                        exports.cr_dx:startInfoBar(text)
                    else 
                        exports.cr_dx:setInfoBarText(text)
                    end
                end

                return
            end
        end
        
        if start then
            loadingProgressEnabled = false
            start = false
            
            exports.cr_dx:closeInfoBar()
        end
    end, 50, 0
)

local lastKeyTick = -500
local function onKey(button, state)
    if button == "e" and state then 
        if loadingProgressEnabled then 
            if exports.cr_network:getNetworkStatus() then 
                cancelEvent()
                
                return
            end

            local nowTick = getTickCount()
            local a = 1

            if nowTick <= lastKeyTick + a * 2500 then
                return
            end

            lastKeyTick = getTickCount()

            if localPlayer:getData("miner >> rockInHand") then 
                local jobVehicle = localPlayer:getData("char >> jobVehicle")

                if isElement(jobVehicle) then 
                    if exports.cr_network:getNetworkStatus() then 
                        if localPlayer:getData("admin >> name") == "retf" then 
                            outputChatBox("network 2") 
                        end

                        return
                    end

                    local rocksInVeh = jobVehicle:getData("miner >> rocksInVeh") or {}

                    if #rocksInVeh >= jobData.maxRockInVeh then 
                        exports.cr_infobox:addBox("error", "Erre a platóra már nem fér több kő.")

                        return
                    end

                    local id = 1

                    for i = 1, jobData.maxRockInVeh do 
                        if not rocksInVeh[i] then 
                            id = i
                            break
                        end
                    end

                    triggerLatentServerEvent("onClientRockToVehiclePlace", 5000, false, localPlayer, id)
                    -- triggerServerEvent("onClientRockToVehiclePlace", localPlayer)

                    localPlayer:setData("forceAnimation", {"carry", "putdwn", -1, false, false, false, false, 250, true})

                    if isTimer(animationTimer) then 
                        killTimer(animationTimer) 
                        animationTimer = nil 
                    end 

                    animationTimer = setTimer(
                        function()
                            localPlayer:setData("forceAnimation", nil)
                        end, 275, 1
                    )
                end
            else
                if exports.cr_network:getNetworkStatus() then 
                    return
                end

                local id = 1
                local jobVehicle = localPlayer:getData("char >> jobVehicle")
                local rocksInVeh = jobVehicle:getData("miner >> rocksInVeh") or {}

                for i = 1, jobData.maxRockInVeh do 
                    if rocksInVeh[i] then 
                        id = i
                        break
                    end
                end

                triggerLatentServerEvent("onClientRockPickupFromVehicle", 5000, false, localPlayer, id)
                -- triggerServerEvent("onClientRockPickupFromVehicle", localPlayer)

                localPlayer:setData("forceAnimation", {"carry", "liftup", -1, false, false, false, false, 250, true})

                if isTimer(animationTimer) then 
                    killTimer(animationTimer) 
                    animationTimer = nil 
                end 

                animationTimer = setTimer(
                    function()
                        localPlayer:setData("forceAnimation", {"CARRY", "crry_prtial", 0, true, false, true, true})
                    end, 275, 1
                )
            end

            cancelEvent()
        end
    end
end
addEventHandler("onClientKey", root, onKey)

local lastCommandTick = -1000

function throwCommand()
    if isJobStarted then 
        if localPlayer:getData("miner >> rockInHand") then
            local now = getTickCount()
            local a = 1
            if now <= lastCommandTick + a * 1000 then
                return
            end

            lastCommandTick = getTickCount()
            localPlayer:setData("miner >> rockInHand", nil)
            triggerServerEvent("miner.carryRestriction", localPlayer, false, false)
        end 
    end
end
addCommandHandler("eldob", throwCommand, false, false)