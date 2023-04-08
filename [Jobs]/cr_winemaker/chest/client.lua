local chestCache = {}

function createChests()
    for k,v in pairs(chestPositions) do 
        local x,y,z,dim,int,rot = unpack(v)
        local obj = Object(7251, x, y, z)
        obj.dimension = dim 
        obj.interior = int 
        obj.rotation = Vector3(0, 0, rot)
        obj.frozen = true 
        obj:setData("winemaker >> chestPickupObj", k)

        chestCache[obj] = k

        exports['cr_radar']:createStayBlip("Láda felvétel: "..k, Blip(x, y, z, 0, 2, 255, 0, 0, 255, 0, 0), 0, "job", 24, 24, 255, 255, 255)
    end 
end 

function destroyChests()
    for k,v in pairs(chestCache) do 
        if isElement(k) then 
            k:destroy()

            exports['cr_radar']:destroyStayBlip("Láda felvétel: "..v)
        end 
    end 

    chestCache = {}

    collectgarbage("collect")
end

local lastClickTick1 = -1000
addEventHandler("onClientClick", root, 
    function(b, s, _, _, _, _, _, worldElement)
        if isJobStarted then 
            if b == "left" and s == "down" then 
                if worldElement and isElement(worldElement) and worldElement:getData("winemaker >> chestPickupObj") then 
                    if getDistanceBetweenPoints3D(localPlayer.position, worldElement.position) <= 2 then
                        if exports['cr_network']:getNetworkStatus() then return end 

                        local now = getTickCount()
                        local a = 1
                        if now <= lastClickTick1 + a * 1000 then
                            return
                        end
                        lastClickTick1 = getTickCount()
                        
                        if not localPlayer:getData("winemaker >> objInHand") then 
                            triggerLatentServerEvent("giveChestToHand", 5000, false, localPlayer, localPlayer, 7251)
                        else 
                            triggerLatentServerEvent("destroyChestFromHand", 5000, false, localPlayer, localPlayer)
                        end 
                    end 
                end 
            end 
        end 
    end 
)

addCommandHandler("eldob", 
    function(cmd)
        if isJobStarted then 
            if localPlayer:getData("winemaker >> objInHand") then

                local now = getTickCount()
                local a = 1
                if now <= lastClickTick1 + a * 1000 then
                    return
                end
                lastClickTick1 = getTickCount()
                triggerLatentServerEvent("destroyChestFromHand", 5000, false, localPlayer, localPlayer)
            end 
        end 
    end 
)

local gVeh, start, startTick, loadingProgressEnabled

local selectedType = 1
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

        if localPlayer:getData('char >> group') then
            local veh;
            local col = exports['cr_core']:getPlayerCol('minimum')

            if col then 
                local a = 9999

                for k,v in pairs(col:getElementsWithin('vehicle')) do 
                    if tonumber(v:getData('veh >> id') or 0) < 0 then 
                        if tonumber(v:getData('veh >> group') or -1) == tonumber(localPlayer:getData('char >> group') or -2) then 
                            local dist = getDistanceBetweenPoints3D(v.position, localPlayer.position)
                            if dist <= a then
                                veh = v
                                a = dist
                            end
                        end 
                    end 
                end 
            end 

            if veh then 
                gVeh = veh
            end 
        end 

        if isElement(gVeh) then
            local x,y,z = getVehicleComponentPosition(gVeh, "boot_dummy", "world")
            
            if getDistanceBetweenPoints3D(localPlayer.position, x,y,z) <= 1 then
                local chestData = gVeh:getData("winemaker >> chest") or {}
                local length = 0
                for k,v in pairs(chestData) do 
                    length = length + 1
                end 

                local breaked = true
                if localPlayer:getData("winemaker >> objInHand") and tonumber(localPlayer:getData('winemaker >> objInHand') or 0) ~= 6929 then
                    if length < 7 then
                        breaked = false
                    end
                elseif not localPlayer:getData("winemaker >> objInHand") and length > 0 then
                    breaked = false 
                end
                
                if not breaked then
                    local text = ""
                    local colorCode = exports['cr_core']:getServerColor('red', true)    
                    
                    if localPlayer:getData("winemaker >> objInHand") then
                        text = "#f2f2f2A láda felpakolásához használd a(z) ["..colorCode.."E#f2f2f2] billentyűt!"
                    elseif length > 0 then
                        text = "#f2f2f2A(z) typeText láda levételéhez használd a(z) ["..colorCode.."E#f2f2f2] billentyűt!\nA láda típusának változtatásához használd a(z) ["..colorCode.."X#f2f2f2] billentyűt!"
                    end 
                    
                    if not start then
                        loadingProgressEnabled = true
                        start = true
                        
                        exports['cr_dx']:startInfoBar(text)
                    else 
                        text = utf8.gsub(text, 'typeText', selectedType == 1 and 'üres' or 'tele')

                        exports['cr_dx']:setInfoBarText(text)
                    end
                end
                
                return
            end
        end
        
        if start then
            loadingProgressEnabled = false
            start = false
            
            exports['cr_dx']:closeInfoBar()
        end
    end, 125, 0
)

local lastClickTick = -500
function loadingProgress(b, s)
    if loadingProgressEnabled then
        if b == "e" and s then
            local now = getTickCount()
            local a = 1
            if now <= lastClickTick + a * 1000 then
                return
            end
            lastClickTick = getTickCount()
            
            local chestData = gVeh:getData("winemaker >> chest") or {}
            local length = 0
            for k,v in pairs(chestData) do 
                length = length + 1
            end 
            
            if localPlayer:getData("winemaker >> objInHand") then
                if length + 1 > 7 then
                    exports['cr_infobox']:addBox("error", "Erre a platóra már nem fér több láda!")
                    return
                end

                local id = 1
                for i = 1, 7 do 
                    if not chestData[i] then 
                        id = i
                        break 
                    end 
                end 

                triggerLatentServerEvent("addChestToVeh", 5000, false, localPlayer, gVeh, localPlayer, id)

                localPlayer:setData("forceAnimation", {"carry", "putdwn",-1,false, false, false, false, 250, true})
                if isTimer(animationTimer) then 
                    killTimer(animationTimer) 
                    animationTimer = nil 
                end 

                animationTimer = setTimer(
                    function()
                        localPlayer:setData("forceAnimation", nil)
                    end, 275, 1
                )
            elseif length > 0 then
                local id = 0
                local typeModelID = selectedType == 1 and 7251 or 7046

                for i = 1, 7 do 
                    if chestData[i] then 
                        if chestData[i]['modelid'] == typeModelID then 
                            id = i
                            break 
                        end 
                    end 
                end 

                if id == 0 then 
                    exports['cr_infobox']:addBox('error', 'A platón nem található ennek a típusnak megfelelő láda!')
                    return 
                end 

                triggerLatentServerEvent("takeChestFromVeh", 5000, false, localPlayer, gVeh, localPlayer, id)

                localPlayer:setData("forceAnimation", {"carry", "liftup",-1,false, false, false, false, 250, true})
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
        elseif b == "x" and s then
            local now = getTickCount()
            local a = 1
            if now <= lastClickTick + a * 1000 then
                return
            end
            lastClickTick = getTickCount()

            selectedType = selectedType + 1
            if selectedType == 3 then 
                selectedType = 1
            end 
        end
    end
end
addEventHandler("onClientKey", root, loadingProgress)