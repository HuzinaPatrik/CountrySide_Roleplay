local cache = {
    ["ship"] = {},
    ["crates"] = {},
}

local shipDestroyTimer = false
local shipCheckTimer = false

function createShip()
    cache["ship"][1] = Object(shipObjectId, shipStartPoint, 0, 0, objectRotation)

    local interiorPoint = Vector3(shipStartPoint.x - 14.7188, shipStartPoint.y + 1.05, 7.125)
    cache["ship"][2] = Object(shipInteriorObjectId, interiorPoint, 0, 0, objectRotation)

    local framePoint = Vector3(shipStartPoint.x + 0.250, shipStartPoint.y + 1.4, shipStartPoint.z - 1.14844)
    cache["ship"][3] = Object(shipFrameObjectId, framePoint, 0, 0, objectRotation)

    local stairsFramePoint = Vector3(shipStartPoint.x - 44.3906, shipStartPoint.y - 0.7656, shipStartPoint.z - 0.75781)
    cache["ship"][4] = Object(shipStairsFrameObjectId, stairsFramePoint, 0, 0, objectRotation)

    local boxesPoint = Vector3(shipStartPoint.x + 0.9, shipStartPoint.y + 1.495, shipStartPoint.z + 1)
    cache["ship"][5] = Object(shipBoxesObjectId, boxesPoint, 0, 0, objectRotation)

    local shipRotationPoint = Vector3(0, 0, 0)
    cache["ship"][1]:move(moveTime, shipEndPoint, shipRotationPoint, "InOutQuad")

    local interiorPoint = Vector3(shipEndPoint.x - 14.7188, shipEndPoint.y + 1.05, 7.125)
    cache["ship"][2]:move(moveTime, interiorPoint, shipRotationPoint, "InOutQuad")

    local framePoint = Vector3(shipEndPoint.x + 0.250, shipEndPoint.y + 1.4, shipEndPoint.z - 1.14844)
    cache["ship"][3]:move(moveTime, framePoint, shipRotationPoint, "InOutQuad")

    local stairsFramePoint = Vector3(shipEndPoint.x - 44.3906, shipEndPoint.y - 0.7656, shipEndPoint.z - 0.75781)
    cache["ship"][4]:move(moveTime, stairsFramePoint, shipRotationPoint, "InOutQuad")

    local boxesPoint = Vector3(shipEndPoint.x + 0.9, shipEndPoint.y + 1.495, shipEndPoint.z + 1)
    cache["ship"][5]:move(moveTime, boxesPoint, shipRotationPoint, "InOutQuad")

    setTimer(
        function()
            local randomPlayer = getRandomPlayer()

            if randomPlayer then 
                local players = getElementsByType("player")

                triggerClientEvent(players, "playShipHornSound", randomPlayer)
            end

            createCrates()
            notifyFactions("arrival")
        end, moveTime, 1
    )
end
addCommandHandler("createship", createShip)

function destroyShip()
    for i = 1, 5 do 
        local v = cache["ship"][i]

        if v then 
            v:destroy()
        end
    end

    cache["ship"] = {}
    collectgarbage("collect")
end

function createCrates()
    for i = 1, #crates do 
        local v = crates[i]

        if v then 
            local x, y, z, rx, ry, rz = unpack(v)

            local obj = Object(ammoBoxObjectId, x, y, z, rx, ry, rz)

            obj:setData("weaponcrate >> id", i)

            cache["crates"][i] = obj
        end
    end
end

function destroyCrates()
    for i = 1, #cache["crates"] do 
        local v = cache["crates"][i]

        if v then 
            if isElement(v) then 
                v:destroy()
            end
        end
    end

    collectgarbage("collect")
end

function notifyFactions(state)
    local syntax = exports["cr_core"]:getServerSyntax("Weaponship", "red")
    local yellowHex = exports["cr_core"]:getServerColor("yellow", true)
    local serverHex = exports["cr_core"]:getServerColor("blue", true)

    if state == "arrival" then 
        exports["cr_dashboard"]:sendMessageToFaction(3, syntax.."A fegyverhajó megérkezett a "..yellowHex.."Nyugati kikötőbe"..white.." és "..serverHex..shipStayTime..white.." percig fog ott maradni.")

        if isTimer(shipDestroyTimer) then 
            killTimer(shipDestroyTimer)

            shipDestroyTimer = nil
        end

        shipDestroyTimer = setTimer(
            function()
                destroyCrates()
                destroyShip()

                shipDestroyTimer = nil
            end, 60000 * shipStayTime, 1
        )

        if isTimer(shipCheckTimer) then 
            killTimer(shipCheckTimer)

            shipCheckTimer = nil
        end

        shipCheckTimer = setTimer(
            function()
                local remaining, executesRemaining, timeInterval = shipDestroyTimer:getDetails()
                local minutesLeft = math.ceil((remaining / 1000) / 60)

                if minutesLeft <= 5 then 
                    local randomPlayer = getRandomPlayer()

                    if randomPlayer then 
                        local players = getElementsByType("player")

                        triggerClientEvent(players, "playShipHornSound", randomPlayer)
                        notifyFactions("getaway")
                    end

                    if isTimer(shipCheckTimer) then 
                        killTimer(shipCheckTimer)
                        
                        shipCheckTimer = nil
                    end
                end
            end, 1000, 0
        )
    elseif state == "getaway" then 
        exports["cr_dashboard"]:sendMessageToFaction(3, syntax.."A fegyverhajó "..serverHex.."5"..white.." perc múlva indul vissza.")
    end
end

addEvent("weaponship.pickupCrate", true)
addEventHandler("weaponship.pickupCrate", root,
    function(thePlayer, element)
        if client and client == thePlayer and element and isElement(element) then 
            local id = element:getData("weaponcrate >> id")

            if id and id > 0 then 
                if cache["crates"][id] then 
                    cache["crates"][id] = nil
                end
                
                element:destroy()
                attachCrateToPlayer(thePlayer)

                collectgarbage("collect")
            end
        end
    end
)

function attachCrateToPlayer(thePlayer)
    if isElement(thePlayer) then 
        local obj = Object(ammoBoxObjectId, 0, 0, 0, 0, 0, 0)
        thePlayer:setData("weaponcrate >> inHand", obj)

        exports["cr_bone_attach"]:attachElementToBone(obj, thePlayer, 12, 0.2, 0.2, 0.15, 80, 0, 0)
        thePlayer:setAnimation("carry", "crry_prtial", 1, true, false, true, true)

        triggerLatentClientEvent(thePlayer, "carryRestriction", 50000, false, thePlayer, false)
    end
end

function detachCrateFromPlayer(thePlayer)
    if client and client == thePlayer then 
        local obj = thePlayer:getData("weaponcrate >> inHand")

        if obj and isElement(obj) then 
            exports["cr_bone_attach"]:detachElementFromBone(obj)
            obj:destroy()

            thePlayer:setData("weaponcrate >> inHand", nil)
            thePlayer:setAnimation(nil, nil)

            triggerLatentClientEvent(thePlayer, "carryRestriction", 50000, false, thePlayer, true)

            collectgarbage("collect")
        end
    end
end
addEvent("weaponship.detachCrateFromPlayer", true)
addEventHandler("weaponship.detachCrateFromPlayer", root, detachCrateFromPlayer)