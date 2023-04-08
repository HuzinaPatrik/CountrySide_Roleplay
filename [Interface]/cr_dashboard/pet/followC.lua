local start, gPed;

addEventHandler("onClientElementDataChange", root, 
    function(dName, oValue, nValue)
        if dName == "pet >> follow" then 
            if isElementStreamedIn(source) then 
                if nValue then 
                    startFollow(source)
                else 
                    stopFollow(source)
                end 
            end 
        elseif dName == "pet" then 
            if source == localPlayer then 
                startPetLoveMinus(nValue)
            end 
        elseif dName == "pet >> target" then 
            if localPlayer:getData("pet") == source then 
                if nValue then 
                    if not start then
                        bindKey("backspace", "down", callbackDog)
                        gPed = source
                        start = true
                        
                        local colorCode = exports['cr_core']:getServerColor('red', true)
                        exports['cr_dx']:startInfoBar("#F2F2F2A kutya visszahívásához használd a ["..colorCode.."Backspace#F2F2F2] billentyűt!")
                    end
                else 
                    if start then
                        unbindKey("backspace", "down", callbackDog)
                        start = false
                        gPed = nil
                        
                        exports['cr_dx']:closeInfoBar()
                    end
                end 
            end
        end 
    end 
)

addEventHandler('onClientElementDestroy', resourceRoot, 
    function()
        if start then 
            if source == gPed then 
                unbindKey("backspace", "down", callbackDog)
                start = false
                gPed = nil
                
                exports['cr_dx']:closeInfoBar()
            end 
        end 
    end 
)

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        for k,v in pairs(getElementsByType("ped", _, true)) do 
            if v:getData("pet >> id") then 
                if localPlayer:getData("pet") == v then 
                    startPetLoveMinus(e)
                end 

                if v:getData("pet >> follow") then 
                    startFollow(v)
                end 
            end 
        end 
    end 
)

function startPetLoveMinus(e)
    local e = e -- mta fix
    stopPetLoveMinus(e)

    if not gPed then 
        gPed = e

        minusTimer = setTimer(
            function()
                if not isElement(gPed) then 
                    if isTimer(minusTimer) then 
                        killTimer(minusTimer)
                    end 

                    return
                end 

                local data = gPed:getData("pet >> data") or {200, 100, 100, 100}
                data[2] = math.min(100, math.max(0, data[2] - 0.5))
                if data[2] <= 0 then 
                    triggerLatentServerEvent("deSpawnPet", 5000, false, localPlayer, localPlayer, 0)
                elseif data[2] <= 15 then 
                    exports['cr_infobox']:addBox("warning", "A kutyád kezd nagyon éhes lenni, ha nem eteted meg meghal!")
                end 
                data[3] = math.min(100, math.max(0, data[3] - 0.5))
                if data[3] <= 0 then 
                    triggerLatentServerEvent("deSpawnPet", 5000, false, localPlayer, localPlayer, 0)
                elseif data[3] <= 15 then 
                    exports['cr_infobox']:addBox("warning", "A kutyád kezd nagyon szomjas lenni, ha nem itatod meg meghal!")
                end 
                data[4] = math.min(100, math.max(0, data[4] - 1))
                gPed:setData("pet >> data", data)
            end, 1 * 60 * 1000, 0
        )
    end
end 

function stopPetLoveMinus(e)
    if gPed == e then 
        if isTimer(minusTimer) then 
            killTimer(minusTimer)
        end 
    end 
end 

addEventHandler("onClientElementDestroy", root, 
    function()
        if source and source.type == "ped" and source:getData("pet >> id") then 
            stopPetLoveMinus(source)
        end 
    end 
)

local followCache = {}
local pedFollowCacheID = {}
local soundCache = {}
local soundCache2 = {}

function startFollow(element)
    if not pedFollowCacheID[element] then 
        local num = #followCache + 1
        
        pedFollowCacheID[element] = num
        followCache[num] = {}
        followCache[num].ped = element
        followCache[num].updateNPCTimer = setTimer(npc_updatePosition, 250, 0, num)
    end 
end 

function stopFollow(num)
    if isElement(num) then 
        num = pedFollowCacheID[num]
    end 

    if followCache[num] and followCache[num].ped then
        if soundCache[followCache[num].ped] then 
            soundCache[followCache[num].ped]:destroy()
            soundCache[followCache[num].ped] = nil 
            collectgarbage("collect")
        end 
        if soundCache2[followCache[num].ped] then 
            soundCache2[followCache[num].ped]:destroy()
            soundCache2[followCache[num].ped] = nil 
            collectgarbage("collect")
        end 
        if isTimer(followCache[num].updateNPCTimer) then
            killTimer(followCache[num].updateNPCTimer)
        end
        if isElement(followCache[num].ped) then
            destroyElement(followCache[num].ped)
        end
        pedFollowCacheID[followCache[num].ped] = nil
        followCache[num].ped = nil
		followCache[num] = nil
        return true
    end
end 

addEventHandler("onClientElementStreamIn", resourceRoot, 
    function()
        if source:getData("pet >> follow") then 
            startFollow(source)
        end 
    end 
)

addEventHandler("onClientElementStreamOut", resourceRoot, 
    function()
        if source:getData("pet >> follow") then 
            stopFollow(source)
        end 
    end 
)

function npc_updatePosition(e)
    if localPlayer:getData("loggedIn") then
        if not isElement(followCache[e].ped) or isElementFrozen(followCache[e].ped) or not isElementStreamedIn(followCache[e].ped) then
            return stopFollow(e)
        end
    
        local data = followCache[e].ped:getData("pet >> data") or {200, 100, 100, 100}
        if data[4] >= 25 then 
            local target = followCache[e].ped:getData("pet >> target")
            local who = getElementData(followCache[e].ped, "pet >> follow")
            if isElement(target) then 
                if target == who or followCache[e].ped == target or isPedDead(target) or target.vehicle then 
                    target = false
                    followCache[e].ped:setData("pet >> target", false)
                else
                    who = target
                end
            end 
            local PlayerPos = {getElementPosition(who)}
            local PedPos = {getElementPosition(followCache[e].ped)}

            if followCache[e].ped:getData("pet >> barking") then 
                if target then 
                    if followCache[e].ped:getData("pet >> owner") == localPlayer:getData("acc >> id") then 
                        followCache[e].ped:setData("pet >> barking", false)
                    end 

                    if soundCache2[followCache[e].ped] then 
                        soundCache2[followCache[e].ped]:destroy()
                        soundCache2[followCache[e].ped] = nil 
                        collectgarbage("collect")
                    end 
                else 
                    if not soundCache2[followCache[e].ped] then 
                        soundCache2[followCache[e].ped] = Sound3D("assets/sounds/dogbarking.mp3", followCache[e].ped.position, true)
                        soundCache2[followCache[e].ped]:attach(followCache[e].ped)
                    end 
                end 
            else 
                if soundCache2[followCache[e].ped] then 
                    soundCache2[followCache[e].ped]:destroy()
                    soundCache2[followCache[e].ped] = nil 
                    collectgarbage("collect")
                end 
            end 

            if target then 
                if not soundCache[followCache[e].ped] then 
                    soundCache[followCache[e].ped] = Sound3D("assets/sounds/dogattack.mp3", followCache[e].ped.position, true)
                    soundCache[followCache[e].ped]:attach(followCache[e].ped)
                end 
            else 
                if soundCache[followCache[e].ped] then 
                    soundCache[followCache[e].ped]:destroy()
                    soundCache[followCache[e].ped] = nil 
                    collectgarbage("collect")
                end 

                followCache[e].ped.dimension = who.dimension
                followCache[e].ped.interior = who.interior
            end
        
            local intDistance = getDistanceBetweenPoints3D(PedPos[1], PedPos[2], PedPos[3], unpack(PlayerPos))

            if intDistance > 32 then 
                if target then 
                    target = false
                    followCache[e].ped:setData("pet >> target", false)
                else 
                    local x,y,z = unpack(PlayerPos)
                    followCache[e].ped.position = Vector3(x,y - 2,z)
                end 
            end 
            
            local intPedRot = -math.deg (math.atan2(PlayerPos[1] - PedPos[1], PlayerPos[2] - PedPos[2]))
            if intPedRot < 0 then intPedRot = intPedRot + 360 end;
        
            setElementRotation(followCache[e].ped, 0, 0, intPedRot, "default", true)

            local maxDistance = 2 
            if target then 
                maxDistance = 1

                if intDistance <= 2 then 
                    setPedControlState(followCache[e].ped, "fire", not getPedControlState(followCache[e].ped, "fire"))
                end 
            end 

            if intDistance <= maxDistance then
                setPedControlState(followCache[e].ped, "forwards", false)
            else 
                setPedControlState(followCache[e].ped, "forwards", true)
            end
        
        
            if  target then 
                setPedControlState(followCache[e].ped, "sprint", true)
            else 
                if intDistance > 4 then
                    setPedControlState(followCache[e].ped, "sprint", true)
                    setPedControlState(followCache[e].ped, "walk", false)
                elseif intDistance > 2 then
                    setPedControlState(followCache[e].ped, "walk", true)
                    setPedControlState(followCache[e].ped, "sprint", false)
                else
                    setPedControlState(followCache[e].ped, "walk", false)
                    setPedControlState(followCache[e].ped, "sprint", false)
                end
            end
        end

        if followCache[e].ped.health <= 0 and followCache[e].ped == localPlayer:getData("pet") then 
            triggerLatentServerEvent("deSpawnPet", 5000, false, localPlayer, localPlayer, 0)
        end 
    end
end

addEventHandler("onClientPlayerVehicleEnter", localPlayer,
    function(vehicle, seat)
        if localPlayer:getData("pet") then 
            local seats = localPlayer.vehicle.occupants
            if localPlayer.vehicle.maxPassengers and localPlayer.vehicle.maxPassengers ~= 0 then 
                local max = localPlayer.vehicle.maxPassengers
                for i = 1, max do 
                    if seat + i <= max then 
                        if not seats[seat + i] then 
                            triggerLatentServerEvent("warpPetIntoVehicle", 5000, false, localPlayer, localPlayer, seat + i)
                            return 
                        end 
                    end
                end 
            end 

            triggerLatentServerEvent("deSpawnPet", 5000, false, localPlayer, localPlayer, localPlayer:getData("pet").health)
        end 
    end 
)

addEventHandler("onClientPlayerVehicleExit",localPlayer,
    function(vehicle, seat)
        if localPlayer:getData("pet") then 
            triggerLatentServerEvent("removePetFromVehicle", 5000, false, localPlayer, localPlayer)
        end 
    end 
)

addEventHandler("onClientPlayerStealthKill", localPlayer,
    function(target)
        if getElementData(target, "pet >> id") then
            cancelEvent()
        end    
    end
)

function attackPlayerByDog(attacker, weapon, bodypart)
    if attacker == localPlayer then 
        if localPlayer:getData("pet") then 
            local data = localPlayer:getData("pet"):getData("pet >> data") or {200, 100, 100, 100}
            if data[4] >= 75 then 
                if isElement(source) and source.type == "player" then 
                    localPlayer:getData("pet"):setData("pet >> target", source) 
                end 
            end
        end 
    end 
end
addEventHandler("onClientPlayerDamage", root, attackPlayerByDog)

function defendPlayerByDog(attacker, weapon, bodypart)
    if localPlayer:getData("pet") then 
        if attacker ~= localPlayer and attacker ~= localPlayer:getData("pet") then 
            local data = localPlayer:getData("pet"):getData("pet >> data") or {200, 100, 100, 100}
            if data[4] >= 50 then 
                if isElement(attacker) and attacker.type == "player" then 
                    localPlayer:getData("pet"):setData("pet >> target", attacker)
                end 
            end
        end 
    end 
end
addEventHandler("onClientPlayerDamage", localPlayer, defendPlayerByDog)

function defendDogHimself(attacker, weapon, bodypart)
    if source:getData("pet >> id") then 
        if attacker == localPlayer and source ~= localPlayer:getData("pet") then 
            local data = source:getData("pet >> data") or {200, 100, 100, 100}
            if data[4] >= 25 then 
                if isElement(attacker) and attacker.type == "player" then 
                    source:setData("pet >> target", attacker)
                end
            end
        elseif attacker == localPlayer and source == localPlayer:getData("pet") then 
            local data = source:getData("pet >> data") or {200, 100, 100, 100}
            data[4] = math.min(100, math.max(0, data[4] - 15))
            source:setData("pet >> data", data)
        end 
    end 
end
addEventHandler("onClientPedDamage", root, defendDogHimself)

function callbackDog()
    if localPlayer:getData("pet") then 
        local players = exports['cr_core']:getNearbyPlayers("medium")
        if #players >= 1 then 
            triggerLatentServerEvent("playSound3D", 5000, false, localPlayer, localPlayer, localPlayer, players, "assets/sounds/whistle.mp3")
        end 

        local sound = Sound3D("assets/sounds/whistle.mp3", localPlayer.position)
        sound.dimension = localPlayer.dimension 
        sound.interior = localPlayer.interior 
        sound:attach(localPlayer)
        
        localPlayer:getData("pet"):setData("pet >> target", nil)
    end 
end 

addEvent("playSound3D", true)
addEventHandler("playSound3D", root, 
    function(sourceElement, path)
        local sound = Sound3D(path, sourceElement.position)
        sound.dimension = sourceElement.dimension 
        sound.interior = sourceElement.interior 
        sound:attach(sourceElement)
    end 
)