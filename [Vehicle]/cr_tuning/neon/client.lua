neons = {
    5764,
    5681,
    18448,
    18215,
    18214,
    18213,
    14399,
    14400,
    14401,
    14402,
}

neonNames = {
    [0] = {"none", "Nincs"},
    [1] = {"white", "Fehér"},
    [2] = {"blue", "Kék"},
    [3] = {"green", "Zöld"},
    [4] = {"red", "Piros"},
    [5] = {"yellow", "Sárga"},
    [6] = {"pink", "Rózsaszín"},
    [7] = {"orange", "Narancssárga"},
    [8] = {"lightblue", "Halványkék"},
    [9] = {"rasta", "Raszta"},
    [10] = {"ice", "Jég"},
}

function getNeonNames()
    return neonNames
end 

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        for k, v in pairs(neons) do
            removeWorldModel(v, 3000, 0, 0, 0, 0)
            
            local neonCOL = engineLoadCOL("neon/modells/neon.col")
            local neonName = neonNames[k][1]
            local neonDFF = engineLoadDFF("neon/modells/" .. neonName .. ".dff")
            
            engineReplaceModel(neonDFF, v)
            engineReplaceCOL(neonCOL, v)
        end
        
        for k,v in pairs(getElementsByType("vehicle", _, true)) do 
            if tonumber(v:getData("veh >> id")) then 
                local tuningData = v:getData("veh >> tuningData") or {}
                if tonumber(tuningData["neon"] or 0) > 0 then 
                    if v:getData("veh >> neon >> active") then 
                        addNeon(v, tonumber(tuningData["neon"] or 0))
                    end 
                end 
            end 
        end 
    end
)

local neonCache = {}
local neonTimersCache = {}
function addNeon(veh, id)
    if neons[id] then 
        if neonCache[veh] then 
            local object1, object2 = unpack(neonCache[veh]) 
            object1.model = neons[id]
            object2.model = neons[id]
        else 
            local objectID = neons[id]
            local object1 = Object(objectID, veh.position)
            object1:attach(veh, 0.8, 0, -0.5)

            local object2 = Object(objectID, veh.position)
            object2:attach(veh, -0.8, 0, -0.5)

            if isTimer(neonTimersCache[veh]) then killTimer(neonTimersCache[veh]) end 
            neonTimersCache[veh] = setTimer(
                function(veh)
                    local object1, object2 = unpack(neonCache[veh]) 
                    object1.dimension = veh.dimension 
                    object1.interior = veh.interior 

                    object2.dimension = veh.dimension 
                    object2.interior = veh.interior 
                end, 15000, 0, veh
            )
            neonCache[veh] = {object1, object2}
        end 
    end 
end 

function destroyNeon(veh)
    if neonCache[veh] then 
        if isTimer(neonTimersCache[veh]) then 
            killTimer(neonTimersCache[veh]) 
        end 

        local object1, object2 = unpack(neonCache[veh])
        object1:destroy()
        object2:destroy()

        neonCache[veh] = nil
    end 
end 

addEventHandler("onClientElementStreamIn", root, 
    function()
        if source and source.type == "vehicle" then 
            if tonumber(source:getData("veh >> id")) then 
                local tuningData = source:getData("veh >> tuningData") or {}
                if tonumber(tuningData["neon"] or 0) > 0 then 
                    if source:getData("veh >> neon >> active") then 
                        addNeon(source, tonumber(tuningData["neon"] or 0))
                    end 
                end 
            end 
        end 
    end
)

addEventHandler("onClientElementStreamOut", root, 
    function()
        if source and source.type == "vehicle" then 
            if tonumber(source:getData("veh >> id")) then 
                local tuningData = source:getData("veh >> tuningData") or {}
                if tonumber(tuningData["neon"] or 0) > 0 then 
                    if source:getData("veh >> neon >> active") then 
                        destroyNeon(source)
                    end 
                end 
            end 
        end 
    end
)

addEventHandler("onClientElementDestroy", root, 
    function()
        if source and source.type == "vehicle" then 
            local tuningData = source:getData("veh >> tuningData") or {}
            if tonumber(tuningData["neon"] or 0) > 0 then 
                if source:getData("veh >> neon >> active") then 
                    destroyNeon(source)
                end 
            end 
        end 
    end 
)

addEventHandler("onClientElementDataChange", root, 
    function(dName, oValue, nValue)
        if dName == "veh >> neon >> active" then 
            if isElementStreamedIn(source) then
                local tuningData = source:getData("veh >> tuningData") or {}
                if tonumber(tuningData["neon"] or 0) > 0 then 
                    if nValue then 
                        addNeon(source, tonumber(tuningData["neon"] or 0))
                    else 
                        destroyNeon(source)
                    end 
                else 
                    destroyNeon(source)
                end 
            end
        end 
    end 
)

lastClickTick = -15000
bindKey("n", "down", 
    function()
        if localPlayer.vehicle then 
            if localPlayer:getData("inDeath") or localPlayer:getData("keysDenied") or localPlayer.vehicleSeat ~= 0 then 
                return 
            end 

            local now = getTickCount()
            local a = 1
            if now <= lastClickTick + a * 1000 then
                return
            end

            lastClickTick = getTickCount()

            local tuningData = localPlayer.vehicle:getData("veh >> tuningData") or {}
            if tonumber(tuningData["neon"] or 0) > 0 then 
                localPlayer.vehicle:setData("veh >> neon >> active", not localPlayer.vehicle:getData("veh >> neon >> active"))

                if localPlayer.vehicle:getData("veh >> neon >> active") then 
                    exports['cr_chat']:createMessage(localPlayer, "bekapcsolja a jármú neon fényeit", 1)
                else 
                    exports['cr_chat']:createMessage(localPlayer, "kikapcsolja a jármú neon fényeit", 1)
                end 
            end 
        end 
    end 
)