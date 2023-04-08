local noBeltTicket = 150
local white = "#ffffff"
spam = -500

local ignoreModel = {
    --[id] = true,
}

addEventHandler("onClientColShapeHit", root, 
    function(thePlayer, matchingDimension)
        if not isElement(source) then return end
        if thePlayer == localPlayer and getTickCount() >= spam + 10000 then
            if getElementData(source, "traffipax.object") then
                local veh = getPedOccupiedVehicle(localPlayer)
                if veh and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    local speed = math.round(getElementSpeed(veh), 1)
                    local maxSpeed = getElementData(source, "traffipax.speedLimit") or 30
                    local syntax = exports['cr_core']:getServerSyntax("Traffipax", "error")
                    local green = exports['cr_core']:getServerColor("yellow", true)
                    local model = getElementModel(veh)
                    if speed > maxSpeed and math.abs(speed - maxSpeed) > 10 then
                        local ticket = math.floor((speed - maxSpeed) * 10)
                        local goingSpeed = speed - maxSpeed
                        local occupants = getVehicleOccupants(veh)
                        local beltMiss = false
                        for k,v in pairs(occupants) do
                            if v.type == "player" then
                                if veh and getVehicleType(veh) == "Automobile" or getVehicleType(veh) == "Plane" or getVehicleType(veh) == "Monster Truck" then
                                    if not getElementData(v, "char >> belt") then
                                        beltMiss = true
                                        break
                                    end
                                end 
                            end
                        end
                        
                        if not ignoreModel[model] then
                            if beltMiss then
                                ticket = ticket + noBeltTicket
                                outputChatBox(syntax .. "Átlépted a sebességhatárt és valakinek a járművedben nem volt bekötve a biztonsági öve ezért " .. green .. "$ " .. ticket .. white .. " bírságot kaptál.",255,255,255,true)
                                outputChatBox(syntax .. "Megengedett: "..green..maxSpeed..white.." km/h | Te sebességed: "..green..speed..white.." km/h | Átlépés mértéke: "..green..goingSpeed..white.." km/h",255,255,255,true)
                            else
                                outputChatBox(syntax .. "Átlépted a sebességhatárt ezért " .. green .. "$ " .. ticket .. white .. " bírságot kaptál.",255,255,255,true)
                                outputChatBox(syntax .. "Megengedett: "..green..maxSpeed..white.." km/h | Te sebességed: "..green..speed..white.." km/h | Átlépés mértéke: "..green..goingSpeed..white.." km/h",255,255,255,true)
                            end

                            spam = getTickCount()
                            playSound("files/camera.mp3")
                            takeMoney(localPlayer, ticket)
                            fadeCamera(false, 0.5, 255,255,255)
                            setTimer(
                                function()
                                    fadeCamera(true, 0.5, 255,255,255)
                                end, 700, 1
                            )

                            triggerLatentServerEvent("speedcams.checkWantedVehicle", 5000, false, localPlayer, veh)
                        end
                    else
                        local ticket = noBeltTicket
                        local occupants = getVehicleOccupants(veh)
                        local beltMiss = false
                        for k,v in pairs(occupants) do
                            if v.type == "player" then
                                if veh and getVehicleType(veh) == "Automobile" or getVehicleType(veh) == "Plane" or getVehicleType(veh) == "Monster Truck" then
                                    if not getElementData(v, "char >> belt") then
                                        beltMiss = true
                                        break
                                    end
                                end 
                            end
                        end
                        
                        if not ignoreModel[model] then
                            if beltMiss then
                                playSound("files/camera.mp3")
                                outputChatBox(syntax .. "A járművedben egy vagy több személynek nem volt bekötve a biztonsági öve ezért ".. green .. "$ " .. ticket .. white .. " bírságot kaptál.",255,255,255,true)
                                takeMoney(localPlayer, ticket)
                                spam = getTickCount()
                                fadeCamera(false, 0.5, 255,255,255)
                                setTimer(
                                    function()
                                        fadeCamera(true, 0.5, 255,255,255)
                                    end, 700, 1
                                )

                                triggerLatentServerEvent("speedcams.checkWantedVehicle", 5000, false, localPlayer, veh)
                            end
                        end 
                    end
                end
            end
        end
    end
)

function getElementSpeed( element, unit )
    if isElement( element ) then
        local x,y,z = getElementVelocity( element )
        if unit == "mph" or unit == 1 or unit == "1" then
            return ( x ^ 2 + y ^ 2 + z ^ 2 ) ^ 0.5 * 100
        else
            return ( x ^ 2 + y ^ 2 + z ^ 2 ) ^ 0.5 * 1.8 * 100
        end
    else
        outputDebugString( "Not an element. Can't get speed" )
        return false
    end
end

function takeMoney(e, m)
    --local oldMoney = getElementData(e, "char >> money") or 0
    --setElementData(e, "char >> money", oldMoney - m)

    triggerLatentServerEvent("giveMoneyToFaction", 5000, false, localPlayer, localPlayer, 1, math.floor(m * 0.05)) -- MEDIC MONEY GIVING

    exports['cr_core']:takeMoney(e, m, nil, true)
    
    --exports['cr_ticket']:giveTicket(e, "Tilos jelzésen való áthaladás", m, getRealTime()["timestamp"] + (3 * 60 * 60))
    --triggerServerEvent("ticket", localPlayer, e, m)
end

local maxDistNearby = 18
function getNearbySpeedCams(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "getnearbyspeedcams") then
        local target = false
        local px, py, pz = getElementPosition(localPlayer)
        local green = exports['cr_core']:getServerColor("orange", true)
        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "info")
        local hasVeh = false
        for k,v in pairs(getElementsByType("object", root, true)) do
            local x,y,z = getElementPosition(v)
            local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
            if dist <= maxDistNearby then
                local id = getElementData(v, "traffipax.id") or 0
                if id > 0 then
                    --local pairObject = getElementData(v, "traffipax.pairObject")
                    local model = getElementModel(v)
                    local type = getElementData(v, "traffipax.type") or 0
                    --local type = getElementData(v, "traffipax.type") or 0
                    outputChatBox(syntax.."Model: "..green..model..white..", ID: "..green..id..white..", Típus: "..green..type..white..", Távolság: "..green..math.floor(dist)..white.." yard", 255,255,255,true)
                    hasVeh = true
                end
            end
        end
        if not hasVeh then
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax("Traffipax", "error")
            outputChatBox(syntax .. "Nincs traffipax a közeledben!", 255,255,255,true)
        end
    end
end
addCommandHandler("getNearbySpeedCams", getNearbySpeedCams)
addCommandHandler("getnearbyspeedcams", getNearbySpeedCams)
addCommandHandler("getnearbytraffipaxs", getNearbySpeedCams)
addCommandHandler("getnearbytraffipax", getNearbySpeedCams)

function delSpeedCam(cmd, id2)
    if not id2 then
        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "warning")
        outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
        return
    elseif tonumber(id2) == nil then
        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "error")
        outputChatBox(syntax .. "Az IDnek egy számnak kell lennie!", 255,255,255,true)
        return 
    end
    if exports['cr_permission']:hasPermission(localPlayer, "delspeedcam") then
        local target = false
        local px, py, pz = getElementPosition(localPlayer)
        local green = exports['cr_core']:getServerColor("orange", true)
        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "info")
        local hasVeh = false
        for k,v in pairs(getElementsByType("object", root, true)) do
            local id = getElementData(v, "traffipax.id") or 0
            if id == tonumber(id2) then
                --local pairObject = getElementData(v, "traffipax.pairObject")
                --local model = getElementModel(pairObject)
                --local type = getElementData(v, "traffipax.type") or 0
                --local type = getElementData(v, "traffipax.type") or 0
                --outputChatBox(syntax.."Model: "..green..model..white..", ID: "..green..id..white..", Típus: "..green..type..white..", Távolság: "..green..math.floor(dist)..white.." yard", 255,255,255,true)
                target = v
                hasVeh = true
            end
        end
        if hasVeh then
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax("Traffipax", "success")
            outputChatBox(syntax .. "Traffipax (ID: "..green..id2..white..") törölve!", 255,255,255,true)
            triggerServerEvent("deleteTraffipax", localPlayer, target)
        end
    end
end
addCommandHandler("delSpeedCam", delSpeedCam)
addCommandHandler("delspeedcam", delSpeedCam)
addCommandHandler("deltraffipax", delSpeedCam)
addCommandHandler("deltraffi", delSpeedCam)

function addSpeedCam(cmd, type, maxSpeed)
    if not type or not maxSpeed then
        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "warning")
        outputChatBox(syntax .. "/"..cmd.." [Típus (0 = Kicsi, 1 = Nagy)] [sebességLimit]", 255,255,255,true)
        return
    elseif tonumber(type) == nil then
        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "error")
        outputChatBox(syntax .. "A típusnak egy számnak kell lennie!", 255,255,255,true)
        return    
    elseif tonumber(type) > 1 then
        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "error")
        outputChatBox(syntax .. "A típusnak egy számnak kell lennie, mely kisebb mint 2!", 255,255,255,true)
        return    
    elseif tonumber(maxSpeed) == nil then
        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "error")
        outputChatBox(syntax .. "A sebességLimitnek egy számnak kell lennie!", 255,255,255,true)
        return
    elseif tonumber(type) < 0 then
        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "error")
        outputChatBox(syntax .. "A sebességLimitnek egy számnak kell lennie, mely nagyobb mint 0!", 255,255,255,true)
        return 
    elseif inSpeedCamCreating then
        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "error")
        outputChatBox(syntax .. "Egyszerre csak 1 traffipaxot hozhatsz létre!", 255,255,255,true)
        return 
    end
    
    if exports['cr_permission']:hasPermission(localPlayer, "addspeedcam") then
        inSpeedCamCreating = true 

        local modelid = 1339
        if type == 1 then
            modelid = 1339
        end
        local x,y,z = getElementPosition(localPlayer)
        z = z - 0.9
        local dim = getElementDimension(localPlayer) 
        local int = getElementInterior(localPlayer)
        local a,a,rotation = getElementRotation(localPlayer)
        obj = createObject(modelid, x,y,z, 0,0, rotation)
        setElementDimension(obj, dim)
        setElementInterior(obj, int)
        --setElementRotation(object, 0, 0, rotation)

        setElementPosition(localPlayer, x, y - 1, z)
    
        createPlayerAttachedCol({x,y,z,dim,int}, tonumber(type))

        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "success")
        local green = exports['cr_core']:getServerColor(nil, true)
        outputChatBox(syntax .. "Sikeresen elkezdted a traffipax létrehozását. Egyelőre csak te látod a traffipaxot, miután a collisont is sikeresen lehelyezted ez a folyamat befejeződik és müködőképes lesz a traffipax.", 255,255,255,true)
        outputChatBox(syntax .. "A collison typejának módosításához használd a "..green.."/changecoltype"..white.." parancsot!", 255,255,255,true)
        outputChatBox(syntax .. "A collison lehelyezésének befejezéséhez használd a "..green.."/finishcol"..white.." parancsot!", 255,255,255,true)
        outputChatBox(syntax .. "A collison követésének Ki/Be kapcsolásához használd a "..green.."/attachcol"..white.." parancsot!", 255,255,255,true)
        outputChatBox(syntax .. "A készítés létrehozás nélküli abbahagyásához használd a "..green.."/stopcolcreate"..white.." parancsot!", 255,255,255,true)
        
        setDevelopmentMode(true)
        executeCommandHandler("showcol", 1)
        
        globalSpeedLimit = tonumber(maxSpeed)
        followCol = true

        addCommands()
    end
end
addCommandHandler("addSpeedCam", addSpeedCam)
addCommandHandler("addspeedcam", addSpeedCam)
addCommandHandler("createtraffipax", addSpeedCam)
addCommandHandler("createTraffiPax", addSpeedCam)

function addCommands()
    addCommandHandler("changecoltype", changecoltype)
    addCommandHandler("stopcolcreate", stopcolcreate)
    addCommandHandler("attachcol", attachcol)
    addCommandHandler("finishcol", finishcol)
end

function removeAttachedCommands()
    removeCommandHandler("changecoltype", changecoltype)
    removeCommandHandler("stopcolcreate", stopcolcreate)
    removeCommandHandler("attachcol", attachcol)
    removeCommandHandler("finishcol", finishcol)
end

function createPlayerAttachedCol(pos, type, rotType)
    local x,y,z,dim,int = unpack(pos)
    
    if not rotType then
        rotType = 0
    end
    
    globalType = type
    globalRotType = rotType
    
    --[[
        Cuboid sizeok:
        Type 1: 4, 15, 2
        Type 2: 4, 30, 2
    ]]
    
    local w,d,h = 0,0,0
    if rotType == 0 then
        w, d, h = 4, 15, 2 
        if type == 1 then
            w, d, h = 4, 30, 2
        end
    elseif rotType == 1 then
        w, d, h = 15, 4, 2 
        if type == 1 then
            w, d, h = 30, 4, 2
        end
    end
    
    col = createColCuboid(x,y,z, w, d, h)
    setElementDimension(col, dim)
    setElementInterior(col, int)
    
    attachElements(col, localPlayer, 0, 0, -1)
end

function destroyPlayerAttachedCol()
    detachElements(col, localPlayer)
    destroyElement(col)
end

function startAttach()
    attachElements(col, localPlayer, 0, 0, -1)
end

function stopAttach()
    detachElements(col, localPlayer)
end

function changecoltype(cmd, rotType)
    if not rotType then
        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "warning")
        outputChatBox(syntax .. "/"..cmd.." [Típus (0, 1)]", 255,255,255,true)
        return
    elseif tonumber(rotType) == nil then
        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "error")
        outputChatBox(syntax .. "A típusnak egy számnak kell lennie!", 255,255,255,true)
        return    
    elseif tonumber(rotType) > 1 then
        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "error")
        outputChatBox(syntax .. "A típusnak egy számnak kell lennie, mely kisebb mint 2!", 255,255,255,true)
        return    
    end
    
    local x,y,z = getElementPosition(localPlayer)
    z = z - 0.5
    local dim = getElementDimension(localPlayer)
    local int = getElementInterior(localPlayer)
    
    destroyPlayerAttachedCol()
    createPlayerAttachedCol({x,y,z,dim,int}, globalType, tonumber(rotType))
    
    local syntax = exports['cr_core']:getServerSyntax("Traffipax", "success")
    local green = exports['cr_core']:getServerColor(nil, true)
    outputChatBox(syntax .. "Collison típus módosítva, Új típus: "..green..rotType, 255,255,255,true)
end

function attachcol(cmd, rotType)
    followCol = not followCol
    if followCol then
        startAttach()
        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "success")
        outputChatBox(syntax .. "Collison követés bekapcsolva", 255,255,255,true)
    else
        stopAttach()
        local syntax = exports['cr_core']:getServerSyntax("Traffipax", "error")
        outputChatBox(syntax .. "Collison követés kikapcsolva", 255,255,255,true)
    end
end

--nearbytraffipax, deltraffipax

function finishcol(cmd)
    removeAttachedCommands()
    local syntax = exports['cr_core']:getServerSyntax("Traffipax", "error")
    --outputChatBox(syntax .. "Traffipax létrehozás abbahagyva", 255,255,255,true)
    inSpeedCamCreating = false
    followCol = false
    local modelid = getElementModel(obj)
    local x,y,z = getElementPosition(obj)
    local dim = getElementDimension(obj)
    local int = getElementDimension(obj)
    local a1, a2, rot = getElementRotation(obj)
    
    local w,d,h = 0,0,0
    if globalRotType == 0 then
        w, d, h = 4, 15, 2 
        if globalType == 1 then
            w, d, h = 4, 30, 2
        end
    elseif globalRotType == 1 then
        w, d, h = 15, 4, 2 
        if globalType == 1 then
            w, d, h = 30, 4, 2
        end
    end
    
    local x2, y2, z2 = getElementPosition(col)
    local dim2 = getElementDimension(col)
    local int2 = getElementDimension(col)
    triggerServerEvent("createTraffiPax", localPlayer, {x,y,z,int,dim,rot, globalSpeedLimit}, {x2, y2, z2, int2, dim2, w, d, h}, globalType, localPlayer)
    destroyPlayerAttachedCol()
    destroyElement(obj)
end

function stopcolcreate(cmd)
    removeAttachedCommands()
    local syntax = exports['cr_core']:getServerSyntax("Traffipax", "error")
    outputChatBox(syntax .. "Traffipax létrehozás abbahagyva", 255,255,255,true)
    inSpeedCamCreating = false
    followCol = false
    destroyPlayerAttachedCol()
    destroyElement(obj)
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

-- WANTED VEHICLE BLIP

local blipCache = {}
local factionCheckTimer = false
local oldFactions = {}

function onClientStart()
    if isTimer(factionCheckTimer) then 
        killTimer(factionCheckTimer)
        factionCheckTimer = nil
    end

    factionCheckTimer = setTimer(
        function()
            local resource = getResourceFromName("cr_dashboard")
            
            if resource and getResourceState(resource) == "running" then 
                local currentFactions = exports.cr_dashboard:getPlayerFactions(localPlayer)

                if #oldFactions ~= #currentFactions then 
                    oldFactions = currentFactions

                    destroyAllWantedBlip()
                end
            end
        end, 1000, 0
    )
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

function deleteWantedBlip(veh)
    if blipCache[veh] then 
        exports.cr_radar:destroyStayBlip(blipCache[veh].blipName)

        if isTimer(blipCache[veh].theTimer) then 
            killTimer(blipCache[veh].theTimer)
            blipCache[veh].theTimer = nil
        end

        blipCache[veh] = nil
    end
end

function destroyAllWantedBlip()
    for k, v in pairs(blipCache) do 
        deleteWantedBlip(k)
    end

    blipCache = {}
end

function createWantedBlip(thePlayer, veh)
    if not blipCache[veh] then 
        local plateText = veh.plateText
        local blipElement = Blip(veh.position, 0, 2, 255, 0, 0, 255, 0, 0)
        local blipName = "Körözött jármű - " .. plateText

        blipElement:attach(veh)

        local redR, redG, redB = exports.cr_core:getServerColor("red", false)
        local radarBlip = exports.cr_radar:createStayBlip(blipName, blipElement, 0, "target", 24, 24, redR, redG, redB)
        local theTimer = setTimer(deleteWantedBlip, 5000, 1, veh)

        blipCache[veh] = {blipName = blipName, theTimer = theTimer}
    end
end

function onClientElementDestroy()
    if blipCache[source] then 
        deleteWantedBlip(source)
    end
end
addEventHandler("onClientElementDestroy", root, onClientElementDestroy)

function onWantedBlipCreate(veh)
    if isElement(source) and isElement(veh) then 
        if exports.cr_dashboard:isPlayerInFaction(localPlayer, 1) then 
            createWantedBlip(source, veh)
        end
    end
end
addEvent("speedcams.onWantedBlipCreate", true)
addEventHandler("speedcams.onWantedBlipCreate", root, onWantedBlipCreate)