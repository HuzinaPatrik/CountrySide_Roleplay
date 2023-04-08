local white = "#ffffff"
local objectCache = {}
local elements = {}
local elementShaders = {}
local elementTextures = {}

function onStart(res)
    engineSetModelLODDistance(1375, 150)
    removeWorldModel(1375,10000,0,0,0)
    removeWorldModel(1283,10000,0,0,0) -- lámpák
    removeWorldModel(1284,10000,0,0,0) -- lámpák
    removeWorldModel(3516,10000,0,0,0) -- lámpák
    removeWorldModel(1350,10000,0,0,0) -- lámpák
    removeWorldModel(1351,10000,0,0,0) -- lámpák
    removeWorldModel(1315,10000,0,0,0) -- lámpák
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function syncModel(e)    
    if not objectCache[e] and e:getData("TrafficBoards.id") then
        local id = e:getData("TrafficBoards.id")
        local type = e:getData("TrafficBoards.type")
        objectCache[e] = id
		elementShaders[e] = dxCreateShader("fx.fx")
        if not elements[type] then
            elements[type] = dxCreateTexture("textures/" .. type .. ".png")
        end
        elementTextures[e] = elements[type]
		dxSetShaderValue(elementShaders[e], "gTexture", elementTextures[e])
		engineApplyShaderToWorldTexture(elementShaders[e], "tabla", e)
    end
end

addEventHandler("onClientElementStreamIn", resourceRoot,
    function()
        syncModel(source)
    end
)

local timers = {}
local timers2 = {}
addEventHandler("onClientObjectDamage", root,
    function()
        local source = source
        --outputChatBox(source.health)
        if objectCache[source] then
            local data = source:getData("defPositions")

            if source.position ~= Vector3(data.x, data.y, data.z) or source.health <= 0 then
                if not timers[source] then
                    if not timers2[source] then
                        timers2[source] = setTimer(
                            function()
                                setElementPosition(source, data.x,data.y,data.z - 100)
                                source.frozen = true
                                timers[source] = setTimer(respawnTable, 2 * 60 * 1000, 1, source)
                            end, 30 * 1000, 1
                        )
                    end
                end
            end
        end
    end
)

function respawnTable(e)
    if objectCache[e] then
        local data = e:getData("defPositions")
        if data then
            local x,y,z = data.x, data.y, data.z
            e.position = Vector3(x,y,z)
            e.frozen = false
        end
    end
end

local maxDistNearby = 18
function getNearbyTrafficBoards(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "getnearbyspeedcams") then
        local target = false
        local px, py, pz = getElementPosition(localPlayer)
        local green = exports['cr_core']:getServerColor("orange", true)
        local syntax = exports['cr_core']:getServerSyntax("TrafficBoards", "info")
        local hasVeh = false
        for k,v in pairs(getElementsByType("object", root, true)) do
            local x,y,z = getElementPosition(v)
            local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
            if dist <= maxDistNearby then
                local id = getElementData(v, "TrafficBoards.id") or 0
                if id > 0 then
                    --local pairObject = getElementData(v, "TrafficBoards.pairObject")
                    local model = getElementModel(v)
                    local type = getElementData(v, "TrafficBoards.type") or 0
                    --local type = getElementData(v, "TrafficBoards.type") or 0
                    outputChatBox(syntax.."Model: "..green..model..white..", ID: "..green..id..white..", Típus: "..green..type..white..", Távolság: "..green..math.floor(dist)..white.." yard", 255,255,255,true)
                    hasVeh = true
                end
            end
        end
        if not hasVeh then
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax("TrafficBoards", "error")
            outputChatBox(syntax .. "Nincs TrafficBoards a közeledben!", 255,255,255,true)
        end
    end
end
addCommandHandler("getnearbytraffic", getNearbyTrafficBoards)
addCommandHandler("getnearbytrafficboard", getNearbyTrafficBoards)
addCommandHandler("getnearbyTrafficBoard", getNearbyTrafficBoards)
addCommandHandler("getnearbyTrafficBoards", getNearbyTrafficBoards)

function createTrafficBoard(cmd, type)
    if not type then
        local syntax = exports['cr_core']:getServerSyntax("TrafficBoards", "warning")
        outputChatBox(syntax .. "/"..cmd.." [Típus]", 255,255,255,true)
        return
    elseif tonumber(type) == nil then
        local syntax = exports['cr_core']:getServerSyntax("TrafficBoards", "error")
        outputChatBox(syntax .. "A típusnak egy számnak kell lennie!", 255,255,255,true)
        return    
    elseif inSpeedCamCreating then
        local syntax = exports['cr_core']:getServerSyntax("TrafficBoards", "error")
        outputChatBox(syntax .. "Egyszerre csak 1 TrafficBoardsot hozhatsz létre!", 255,255,255,true)
        return 
    end
    
    if exports['cr_permission']:hasPermission(localPlayer, "addspeedcam") then
        inSpeedCamCreating = true 
        
        local modelid = 1375
        local x,y,z = getElementPosition(localPlayer)
        z = z + 0.4
        local dim = getElementDimension(localPlayer) 
        local int = getElementInterior(localPlayer)
        local a,a,rotation = getElementRotation(localPlayer)
        obj = createObject(modelid, x,y,z, 0,0, 90)
        setElementDimension(obj, dim)
        setElementInterior(obj, int)
        obj.collisions = false
        obj:setData("TrafficBoards.id", -1)
        obj:setData("TrafficBoards.type", tonumber(type))
        syncModel(obj)
        
        exports["cr_elementeditor"]:toggleEditor(obj, "onSaveTrafficPositionEditor", "onSaveTrafficDeleteEditor", true)
        
        addCommandHandler("type", changeType)
    end
end
addCommandHandler("createTrafficBoard", createTrafficBoard)

function changeType(cmd, id)
    if tonumber(id) and isElement(obj) then
        obj:setData("TrafficBoards.type", tonumber(id))
        objectCache[obj] = nil
        destroyElement(elementShaders[obj])
        elementShaders[obj] = nil
        elementTextures[obj] = nil
        syncModel(obj)
    end
end

addEventHandler("onClientElementDestroy", root,
    function()
        local obj = source
        if objectCache[obj] then
            objectCache[obj] = nil
            destroyElement(elementShaders[obj])
            elementShaders[obj] = nil
            elementTextures[obj] = nil
        end
    end
)

addEvent("onSaveTrafficPositionEditor", true)
addEventHandler("onSaveTrafficPositionEditor", localPlayer,
    function(e, x, y, z, rx, ry, rz)
        inSpeedCamCreating = false
        removeCommandHandler("type", changeType)
        
        triggerServerEvent("createTrafficBoards", localPlayer, {x, y, z, e.interior,e.dimension, rz}, e:getData("TrafficBoards.type"), localPlayer)
        
        e:destroy()
    end
)

addEvent("onSaveTrafficDeleteEditor", true)
addEventHandler("onSaveTrafficDeleteEditor", localPlayer,
    function(e, x, y, z, rx, ry, rz)
        inSpeedCamCreating = false
        removeCommandHandler("type", changeType)
        e:destroy()
    end
)

local maxDistNearby = 18
function getNearbyTrafficBoards(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "getnearbyspeedcams") then
        local target = false
        local px, py, pz = getElementPosition(localPlayer)
        local green = exports['cr_core']:getServerColor("orange", true)
        local syntax = exports['cr_core']:getServerSyntax("TrafficBoards", "info")
        local hasVeh = false
        for k,v in pairs(getElementsByType("object", root, true)) do
            local x,y,z = getElementPosition(v)
            local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
            if dist <= maxDistNearby then
                local id = getElementData(v, "TrafficBoards.id") or 0
                if id > 0 then
                    --local pairObject = getElementData(v, "traffipax.pairObject")
                    local model = getElementModel(v)
                    local type = getElementData(v, "TrafficBoards.type") or 0
                    --local type = getElementData(v, "traffipax.type") or 0
                    outputChatBox(syntax.."Model: "..green..model..white..", ID: "..green..id..white..", Típus: "..green..type..white..", Távolság: "..green..math.floor(dist)..white.." yard", 255,255,255,true)
                    hasVeh = true
                end
            end
        end
        if not hasVeh then
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax("TrafficBoards", "error")
            outputChatBox(syntax .. "Nincs TrafficBoards a közeledben!", 255,255,255,true)
        end
    end
end
addCommandHandler("getNearbyTrafficBoards", getNearbyTrafficBoards)
addCommandHandler("getnearbytrafficBoards", getNearbyTrafficBoards)
addCommandHandler("getnearbytrafficboards", getNearbyTrafficBoards)
addCommandHandler("getnearbytrafficboard", getNearbyTrafficBoards)

function delTrafficBoards(cmd, id2)
    if not id2 then
        local syntax = exports['cr_core']:getServerSyntax("TrafficBoards", "warning")
        outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
        return
    elseif tonumber(id2) == nil then
        local syntax = exports['cr_core']:getServerSyntax("TrafficBoards", "error")
        outputChatBox(syntax .. "Az IDnek egy számnak kell lennie!", 255,255,255,true)
        return 
    end
    if exports['cr_permission']:hasPermission(localPlayer, "delspeedcam") then
        local target = false
        local px, py, pz = getElementPosition(localPlayer)
        local green = exports['cr_core']:getServerColor("orange", true)
        local syntax = exports['cr_core']:getServerSyntax("TrafficBoards", "info")
        local hasVeh = false
        for k,v in pairs(getElementsByType("object", root, true)) do
            local id = getElementData(v, "TrafficBoards.id") or 0
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
            local syntax = exports['cr_core']:getServerSyntax("TrafficBoards", "success")
            outputChatBox(syntax .. "TrafficBoards (ID: "..green..id2..white..") törölve!", 255,255,255,true)
            triggerServerEvent("deleteTrafficBoards", localPlayer, target)
        end
    end
end
addCommandHandler("delTrafficBoards", delTrafficBoards)
addCommandHandler("deltrafficBoards", delTrafficBoards)
addCommandHandler("deltrafficboards", delTrafficBoards)
addCommandHandler("deltrafficboard", delTrafficBoards)