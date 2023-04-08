--[[
    TO:DO:

    Felkelljen dolgozni a minigammel:
     - Legyen full random milyen hosszú a minigame (Done)
     - Ha elrontsa sebződjön random (10-20 hp-t) és kezdjen el vérezni, de ha 0 alá megy haljon meg és kapja meg a special reason-t, hogy elvérzett vagy vágások miatt halt meg. (Done)

    Adja a kezébe a szart amit fel lehet pakolni a platóra és típusonként leszedni. Nyílván működjön CO-OP-ban is. (Done)
    Leadó CP-ben a kézben lévőt is le lehessen adni + minden fának nyílván más az ára.

    --
]]

local gPed, typ;

function onClick(b, s, _, _, _, _, _, worldElement)
    if isJobStarted then 
        if b == 'left' and s == 'down' then 
            if localPlayer:getWeapon() == 10 then 
                if worldElement and isElement(worldElement) then 
                    if worldElement:getData('lumberjack >> tree') then
                        if worldElement:getData('lumberjack >> tree >> fallen') and worldElement:getData('lumberjack >> tree >> falled') then 
                            if worldElement:getData('lumberjack >> tree >> fallen') == localPlayer or tonumber(worldElement:getData('lumberjack >> tree >> fallen'):getData('char >> group') or -1) == tonumber(localPlayer:getData('char >> group') or -2) then 
                                if worldElement:getData('lumberjack >> tree >> hit') == localPlayer or tonumber(worldElement:getData('lumberjack >> tree >> hit'):getData('char >> group') or -1) == tonumber(localPlayer:getData('char >> group') or -2) then 
                                    if not localPlayer:getData('lumberjack >> tree >> hit') or not isElement(localPlayer:getData('lumberjack >> tree >> hit')) or localPlayer:getData('lumberjack >> tree >> hit') == worldElement then 
                                        if tonumber(worldElement:getData('lumberjack >> tree >> cuttingCount') or 0) > 0 then
                                            if not localPlayer:getData('lumberjack >> objInHand') then
                                                if not worldElement:getData('lumberjack >> doingInteraction') then 
                                                    worldElement:setData('lumberjack >> tree >> hit', localPlayer)
                                                    localPlayer:setData('lumberjack >> tree >> hit', worldElement)

                                                    worldElement:setData("lumberjack >> doingInteraction", {worldElement:getData('lumberjack >> treeType'), localPlayer}) 
                                                end 
                                            end
                                        end
                                    end 
                                end 
                            end 
                        end 
                    end 
                end
            end 
        end 
    end
end 
addEventHandler('onClientClick', root, onClick)

addEventHandler("onClientElementDataChange", root, 
    function(dName, oValue, nValue)
        if dName == "lumberjack >> doingInteraction" then 
            if nValue and type(nValue) == "table" then 
                if oValue and type(oValue) == "table" and isElement(oValue[2]) and nValue[2] == localPlayer then 
                    source:setData(dName, oValue)

                    if exports['cr_minigame']:getMinigameStatus(4) then 
                        exports['cr_minigame']:stopMinigame(4, true)
        
                        localPlayer:setData("forceAnimation", {"", ""})
                    end 

                    return 
                end 

                if nValue[2] == localPlayer then 
                    if not exports['cr_minigame']:getMinigameStatus(4) then 
                        gPed = source 
                        
                        localPlayer.rotation = Vector3(0, 0, exports['cr_core']:findRotation(localPlayer.position.x, localPlayer.position.y, source.position.x, source.position.y))
                        localPlayer:setData("forceAnimation", {"bomber", "bom_plant"})
                        typ = nValue[1]
                        
                        exports['cr_minigame']:createMinigame(localPlayer, 4, 'LumberJack')
                    end 
                end 
            end 
        end 
    end 
)

addEvent("[Minigame - StopMinigame]", true)
addEventHandler("[Minigame - StopMinigame]", root,
    function(thePlayer, array)
        if thePlayer == localPlayer and array[1] == 4 and array[2] == "LumberJack" then 
            localPlayer:setData("forceAnimation", {"", ""})
            gPed:setData("lumberjack >> doingInteraction", nil)

            if array[3] >= array[5] then 
                local woodCount = gPed:getData('lumberjack >> tree >> cuttingCount')
                gPed:setData('lumberjack >> tree >> cuttingCount', woodCount - 1)

                exports['cr_inventory']:putdownWeapon()

                local modelid = treeDatas[typ]['handModelID']

                triggerLatentServerEvent("giveWoodToHand", 5000, false, localPlayer, localPlayer, modelid)

                if woodCount - 1 <= 0 then 
                    triggerLatentServerEvent("respawnTree", 5000, false, localPlayer, localPlayer, gPed)
                end 
            else
                local newHealth = math.max(0, localPlayer.health - math.random(5, 20))

                if newHealth > 0 then 
                    localPlayer.health = newHealth

                    exports['cr_death-system']:addBloodDamage(localPlayer, localPlayer, 10, 5)
                else 
                    localPlayer:setData("specialReason", "Elvérzett favágás közben!")

                    localPlayer.health = 0
                end 
            end 
        end 
    end 
)

local lastClickTick1 = -1000
addCommandHandler("eldob", 
    function(cmd)
        if isJobStarted then 
            if localPlayer:getData("lumberjack >> objInHand") then

                local now = getTickCount()
                local a = 1
                if now <= lastClickTick1 + a * 1000 then
                    return
                end
                lastClickTick1 = getTickCount()
                triggerLatentServerEvent("destroyWoodFromHand", 5000, false, localPlayer, localPlayer)
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
                local woodData = gVeh:getData("lumberjack >> wood") or {}
                local length = 0
                for k,v in pairs(woodData) do 
                    length = length + 1
                end 

                local breaked = true
                if localPlayer:getData("lumberjack >> objInHand") then
                    if length < 7 then
                        breaked = false
                    end
                elseif not localPlayer:getData("lumberjack >> objInHand") and length > 0 then
                    breaked = false 
                end
                
                if not breaked then
                    local text = ""
                    local colorCode = exports['cr_core']:getServerColor('red', true)    
                    
                    if localPlayer:getData("lumberjack >> objInHand") then
                        text = "#f2f2f2A fa felpakolásához használd a(z) ["..colorCode.."E#f2f2f2] billentyűt!"
                    elseif length > 0 then
                        text = "#f2f2f2A(z) typeText levételéhez használd a(z) ["..colorCode.."E#f2f2f2] billentyűt!\nA fa típusának változtatásához használd a(z) ["..colorCode.."X#f2f2f2] billentyűt!"
                    end 
                    
                    if not start then
                        loadingProgressEnabled = true
                        start = true
                        
                        exports['cr_dx']:startInfoBar(text)
                    else 
                        text = utf8.gsub(text, 'typeText', treeDatas[selectedType]['name']:lower())

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
            
            local woodData = gVeh:getData("lumberjack >> wood") or {}
            local length = 0
            for k,v in pairs(woodData) do 
                length = length + 1
            end 
            
            if localPlayer:getData("lumberjack >> objInHand") then
                if length + 1 > 7 then
                    exports['cr_infobox']:addBox("error", "Erre a platóra már nem fér több láda!")
                    return
                end

                local id = 1
                for i = 1, 7 do 
                    if not woodData[i] then 
                        id = i
                        break 
                    end 
                end 

                triggerLatentServerEvent("addWoodToVeh", 5000, false, localPlayer, gVeh, localPlayer, id)

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
                local typeModelID = treeDatas[selectedType]['handModelID']

                for i = 1, 7 do 
                    if woodData[i] then 
                        if woodData[i]['modelid'] == typeModelID then 
                            id = i
                            break 
                        end 
                    end 
                end 

                if id == 0 then 
                    exports['cr_infobox']:addBox('error', 'A platón nem található ennek a típusnak megfelelő láda!')
                    return 
                end 

                triggerLatentServerEvent("takeWoodFromVeh", 5000, false, localPlayer, gVeh, localPlayer, id)

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
            if selectedType > #treeDatas then 
                selectedType = 1
            end 
        end
    end
end
addEventHandler("onClientKey", root, loadingProgress)