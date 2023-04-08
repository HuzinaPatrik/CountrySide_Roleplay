addEventHandler("onClientElementDataChange", root, 
    function(dName, oValue, nValue)
        if dName == "char >> follow" then 
            if isElementStreamedIn(source) and not source:getData("char >> cuffed") then 
                if nValue then 
                    startFollow(source)
                else 
                    stopFollow(source)
                end 
            end 
        end 
    end 
)

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        for k,v in pairs(getElementsByType("player", _, true)) do 
            if v:getData("loggedIn") then 
                if v:getData("char >> follow") and not source:getData("char >> cuffed") then 
                    startFollow(v)
                end 
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
        followCache[num].ped = nil
		followCache[num] = nil
        return true
    end
end 

addEventHandler("onClientElementStreamIn", root, 
    function()
        if source:getData("char >> follow") and not source:getData("char >> cuffed") then 
            startFollow(source)
        end 
    end 
)

addEventHandler("onClientElementStreamOut", root, 
    function()
        if source:getData("char >> follow") and not source:getData("char >> cuffed") then 
            stopFollow(source)
        end 
    end 
)


function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function npc_updatePosition(e)
    if localPlayer:getData("loggedIn") then
        if not isElement(followCache[e].ped) or isElementFrozen(followCache[e].ped) or not isElementStreamedIn(followCache[e].ped) then
            return stopFollow(e)
        end
    
        local who = getElementData(followCache[e].ped, "char >> follow")

        local PlayerPos = {getElementPosition(who)}
        local PedPos = {getElementPosition(followCache[e].ped)}

        local intPedRot = findRotation(PedPos[1], PedPos[2], PlayerPos[1], PlayerPos[2])
        setElementRotation(followCache[e].ped, 0, 0, intPedRot, "default", true)
        setPedAnimation(followCache[e].ped, "", "")

        if followCache[e].ped == localPlayer then 
            setPedAnimation(localPlayer, "", "")

            if followCache[e].ped.dimension ~= who.dimension then 
                followCache[e].ped.dimension = who.dimension
                triggerLatentServerEvent("updateDimension", 5000, false, localPlayer, localPlayer, who.dimension)
            end 

            if followCache[e].ped.interior ~= who.interior then 
                followCache[e].ped.interior = who.interior
                triggerLatentServerEvent("updateInterior", 5000, false, localPlayer, localPlayer, who.interior)
            end 

            local intDistance = getDistanceBetweenPoints3D(PedPos[1], PedPos[2], PedPos[3], unpack(PlayerPos))

            if intDistance > 16 then 
                local x,y,z = unpack(PlayerPos)
                followCache[e].ped.position = Vector3(x,y - math.random(1, 2),z)
            end 

            local maxDistance = 1 
            if intDistance <= maxDistance then
                setPedControlState(followCache[e].ped, "forwards", false)
            else 
                setPedControlState(followCache[e].ped, "forwards", true)
            end
        
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
end

addEventHandler("onClientPlayerVehicleEnter", root,
    function(vehicle, seat)
        if localPlayer:getData("char >> follow") and localPlayer:getData("char >> follow") == source then 
            local seats = source.vehicle.occupants
            if source.vehicle.maxPassengers and source.vehicle.maxPassengers ~= 0 then 
                local max = source.vehicle.maxPassengers
                for i = 1, max do 
                    if seat + i <= max then 
                        if not seats[seat + i] then 
                            triggerLatentServerEvent("elementbox >> warpPedIntoVehicle", 5000, false, localPlayer, localPlayer, source, seat + i)
                            return 
                        end 
                    end
                end 
            end 

            localPlayer:setData("char >> follow", nil)
        end 
    end 
)

addEventHandler("onClientPlayerVehicleExit", root,
    function(vehicle, seat)
        if localPlayer:getData("char >> follow") and localPlayer:getData("char >> follow") == source then 
            triggerLatentServerEvent("elementbox >> removePedFromVehicle", 5000, false, localPlayer, localPlayer)

            if localPlayer:getData("char >> cuffed") then 
                setTimer(setElementData, 2000, 1, localPlayer, "currentAnimation", "standing_front")
            end
        end 
    end 
)