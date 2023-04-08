addEventHandler("onClientPlayerStealthKill", localPlayer,
    function(target)
        if getElementData(target, "hunter >> id") then
            cancelEvent()
        end    
    end
)

addEventHandler("onClientPedDamage", resourceRoot, 
    function(attacker, weapon, bodypart, loss)
        if source:getData("hunter >> id") then 
            if attacker and attacker == localPlayer then 
                source:setData("hunter >> health", math.max(0, source:getData("hunter >> health") - loss))

                if not source:getData("hunter >> attacker") then 
                    source:setData("hunter >> attacker", localPlayer)
                end 
            end 

            cancelEvent()
        end 
    end 
)

addEventHandler("onClientElementDataChange", root, 
    function(dName, oValue, nValue)
        if dName == "hunter >> doingInteraction" then 
            if nValue and type(nValue) == "table" then 
                if oValue and type(oValue) == "table" and isElement(oValue[2]) and nValue[2] == localPlayer then 
                    source:setData(dName, oValue)

                    if exports['cr_dx']:isProgressBarActive('hunterProgress') then 
                        exports['cr_dx']:endProgressBar('hunterProgress')
        
                        localPlayer:setData("forceAnimation", {"", ""})
                    end 

                    return 
                end 

                if nValue[2] == localPlayer then 
                    if not exports['cr_dx']:isProgressBarActive('hunterProgress') then 
                        gPed = source 
                        
                        localPlayer.rotation = Vector3(0, 0, findRotation(localPlayer.position.x, localPlayer.position.y, source.position.x, source.position.y))
                        localPlayer:setData("forceAnimation", {"bomber", "bom_plant"})
                        typ = nValue[1]
                        
                        exports['cr_dx']:startProgressBar('hunterProgress', texts[typ])
                    end 
                end 
            end 
        elseif dName == "hunter >> id" then 
            if isElementStreamedIn(source) then 
                if nValue then 
                    startFollow(source)
                else 
                    stopFollow(source)
                end 
            end 
        end 
    end 
)

addEventHandler('ProgressBarEnd', localPlayer, 
    function(id, data)
        if id == 'hunterProgress' then 
            local itemid, value, count = unpack(animalTypes[gPed:getData("hunter >> type")][5][typ])
            exports['cr_inventory']:giveItem(localPlayer, itemid, value, count)
            triggerLatentServerEvent("StartAnimalRespawn", 5000, false, localPlayer, gPed)

            localPlayer:setData("forceAnimation", {"", ""})
            gPed:setData('hunter >> doingInteraction', nil)
        end 
    end 
)

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        local collectorPed = Ped(213, 811.095703125, -574.18438720703, 16.3359375)
        collectorPed.rotation = Vector3(0, 0, 263)
        collectorPed:setData("ped.name", "Michael Firth")
        collectorPed:setData("ped.type", "Vadász felvásárló")	
        collectorPed:setData("hunter >> collectorPed", true)	
        collectorPed.frozen = true 
        collectorPed:setData("char >> noDamage", true)

        exports['cr_radar']:createStayBlip("Vadász felvásárló", Blip(811.095703125, -574.18438720703, 16.3359375, 0, 2, 255, 0, 0, 255, 0, 0), 0, "hunting_down", 24, 24, 255, 255, 255)

        for k,v in pairs(getElementsByType("ped", _, true)) do 
            if v:getData("hunter >> id") then 
                startFollow(v)
            end 
        end 
    end 
)

local followCache = {}
local pedFollowCacheID = {}

function startFollow(element)
    if not pedFollowCacheID[element] then 
        local num = #followCache + 1
        
        pedFollowCacheID[element] = num
        followCache[num] = {}
        followCache[num].ped = element
        followCache[num].updateNPCTimer = setTimer(npc_updatePosition, 0, 0, num)
    end 
end 

function stopFollow(num)
    if isElement(num) then 
        num = pedFollowCacheID[num]
    end 

    if followCache[num] and followCache[num].ped then
        if isTimer(followCache[num].updateNPCTimer) then
            killTimer(followCache[num].updateNPCTimer)
        end
        if isElement(followCache[num].ped) then
            destroyElement(followCache[num].ped)
        end
        pedFollowCacheID[followCache[num].ped] = nil

        local target = followCache[num].ped:getData("hunter >> attacker")
        if isElement(target) then 
            if target == localPlayer then 
                target = false
                followCache[num].ped:setData("hunter >> attacker", false)
            end 
        end 

        followCache[num].ped = nil
		followCache[num] = nil
        return true
    end
end 

addEventHandler("onClientElementStreamIn", resourceRoot, 
    function()
        if source:getData("hunter >> id") then 
            startFollow(source)
        end 
    end 
)

addEventHandler("onClientElementStreamOut", resourceRoot, 
    function()
        if source:getData("hunter >> id") then 
            stopFollow(source)
        end 
    end 
)

function npc_updatePosition(e)
    if localPlayer:getData("loggedIn") then
        if not isElement(followCache[e].ped) or not isElementStreamedIn(followCache[e].ped) then
            return stopFollow(e)
        end
    
        local target = followCache[e].ped:getData("hunter >> attacker")
        if isElement(target) then 
            if followCache[e].ped == target or isPedDead(target) or target.vehicle then 
                if target == localPlayer then 
                    target = false
                    followCache[e].ped:setData("hunter >> attacker", false)
                end 

                return
            end
        end 

        if followCache[e].ped:getData("hunter >> health") <= 0 then 
            setPedControlState(followCache[e].ped, "fire", false)
            setPedControlState(followCache[e].ped, "forwards", false)
            setPedControlState(followCache[e].ped, "walk", false)
            setPedControlState(followCache[e].ped, "sprint", false)
        else
            local PlayerPos = {animals[followCache[e].ped:getData("hunter >> id")][1], animals[followCache[e].ped:getData("hunter >> id")][2], animals[followCache[e].ped:getData("hunter >> id")][3]}
            local PedPos = {getElementPosition(followCache[e].ped)}

            local intDistance2 = getDistanceBetweenPoints3D(PedPos[1], PedPos[2], PedPos[3], PlayerPos[1], PlayerPos[2], PlayerPos[3])
            if intDistance2 > followCache[e].ped:getData("hunter >> maxDist") then 
                --local x,y,z = PlayerPos[1], PlayerPos[2], PlayerPos[3]
                --followCache[e].ped.position = Vector3(x,y,z)
                if target and isElement(target) then 
                    if target == localPlayer then 
                        target = false
                        followCache[e].ped:setData("hunter >> attacker", false)
                    end 

                    return
                end 
            end 

            if target and isElement(target) and PedPos then 
                local intDistance = getDistanceBetweenPoints3D(PedPos[1], PedPos[2], PedPos[3], getElementPosition(target))

                if intDistance > followCache[e].ped:getData("hunter >> damageDist")[1] then 
                    if target == localPlayer then 
                        target = false
                        followCache[e].ped:setData("hunter >> attacker", false)
                    end 

                    return
                end 

                local maxDistance = 1

                if intDistance <= 2 then 
                    setPedControlState(followCache[e].ped, "fire", not getPedControlState(followCache[e].ped, "fire"))
                end 

                if intDistance <= maxDistance then
                    setPedControlState(followCache[e].ped, "forwards", false)
                else 
                    setPedControlState(followCache[e].ped, "forwards", true)
                end

                local x, y, z = getElementPosition(target)
                local intPedRot = -math.deg (math.atan2(x - PedPos[1], y - PedPos[2]))
                if intPedRot < 0 then intPedRot = intPedRot + 360 end;
            
                setElementRotation(followCache[e].ped, 0, 0, intPedRot, "default", true)
            else 
                if not localPlayer.vehicle then 
                    if not exports['cr_admin']:getAdminDuty(localPlayer, true) then
                        local intDistance = getDistanceBetweenPoints3D(PedPos[1], PedPos[2], PedPos[3], getElementPosition(localPlayer))
                        if intDistance <= followCache[e].ped:getData("hunter >> damageDist")[2] then 
                            followCache[e].ped:setData("hunter >> attacker", localPlayer)

                            return
                        end 
                    end 
                end
            end 
        
            if target and isElement(target) then 
                setPedControlState(followCache[e].ped, "sprint", true)
            else 
                if intDistance2 > 1 then 
                    local x, y, z = PlayerPos[1], PlayerPos[2], PlayerPos[3]
                    local intPedRot = -math.deg (math.atan2(x - PedPos[1], y - PedPos[2]))
                    if intPedRot < 0 then intPedRot = intPedRot + 360 end;

                    setElementRotation(followCache[e].ped, 0, 0, intPedRot, "default", true)
                end 

                if intDistance2 > 4 then
                    setPedControlState(followCache[e].ped, "forwards", true)
                    setPedControlState(followCache[e].ped, "sprint", true)
                    setPedControlState(followCache[e].ped, "walk", false)
                elseif intDistance2 > 2 then
                    setPedControlState(followCache[e].ped, "forwards", true)
                    setPedControlState(followCache[e].ped, "walk", true)
                    setPedControlState(followCache[e].ped, "sprint", false)
                else
                    setPedControlState(followCache[e].ped, "forwards", false)
                    setPedControlState(followCache[e].ped, "walk", false)
                    setPedControlState(followCache[e].ped, "sprint", false)
                end
            end
        end 
    end 
end

function findRotation(x1, y1, x2, y2) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end	

