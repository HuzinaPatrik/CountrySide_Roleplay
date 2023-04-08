local cache = {}
local playerCache = {}

local offsets = {
    {-0.5,-0.8,-0.13}, -- 1
    {0,-0.8,-0.13}, -- 2
    {0.5,-0.8,-0.13}, -- 3
    {0.25,-1.5,-0.13}, -- 4
    {-0.25,-1.5,-0.13}, -- 5
    {-0.4,-2.15,-0.13, 0, 0, 90}, -- 6
    {0.4,-2.15,-0.13, 0, 0, 90}, -- 7
}

function syncVehicle(veh)
    if not cache[veh] then 
        cache[veh] = {}
    end 

    local chestData = veh:getData("lumberjack >> wood") or {}

    for i = 1, 7 do 
        if chestData[i] then 
            local modelid = chestData[i]['modelid'] or 1463

            if not cache[veh][i] then 
                local obj = Object(modelid, veh.position, 0, 0, 0)
                cache[veh][i] = obj
                obj.scale = handModelData[modelid]['scale'] or 1
                obj.collisions = false
                obj.dimension = veh.dimension 
                obj.interior = veh.interior
                obj:attach(veh, unpack(offsets[i]))
            elseif cache[veh][i].model ~= modelid then 
                cache[veh][i].model = modelid

                cache[veh][i].scale = handModelData[modelid]['scale'] or 1
            end 
        else
            if cache[veh][i] then 
                cache[veh][i]:destroy()
                cache[veh][i] = nil 

                collectgarbage('collect')
            end 
        end 
    end 
end 

function syncPlayer(e)
    if e:getData("lumberjack >> objInHand") then
        local modelid = tonumber(e:getData("lumberjack >> objInHand")) or 1463

        if not playerCache[e] then 
            local obj = Object(modelid, e.position)
            obj.scale = handModelData[modelid]['scale'] or 1
            obj.collisions = false
            obj.dimension = e.dimension 
            obj.interior = e.interior
            exports['cr_bone_attach']:attachElementToBone(obj, e, handModelData[modelid]['bone'], unpack(handModelData[modelid]['offsets']))
            playerCache[e] = obj 
        elseif playerCache[e].model ~= modelid then 
            playerCache[e].model = modelid
            playerCache[e].scale = handModelData[modelid]['scale'] or 1
        end 
    else 
        if playerCache[e] then 
            playerCache[e]:destroy()
            playerCache[e] = nil 

            collectgarbage('collect')
        end 
    end 
end 

function deSyncVehicle(veh)
    if cache[veh] then 
        for k,v in pairs(cache[veh]) do 
            if isElement(v) then 
                v:destroy()
                cache[veh][k] = nil 

                collectgarbage('collect')
            end 
        end 
    end 
end 

function deSyncPlayer(e)
    if playerCache[e] then 
        if isElement(playerCache[e]) then 
            playerCache[e]:destroy()
            playerCache[e] = nil 

            collectgarbage('collect')
        end 
    end 
end 

addEventHandler('onClientResourceStart', resourceRoot, 
    function()
        for k,v in pairs(getElementsByType('vehicle', _, true)) do 
            local chestData = v:getData("lumberjack >> wood") or {}

            if chestData then 
                syncVehicle(v)
            end 
        end 

        for k,v in pairs(getElementsByType('player', _, true)) do 
            if v:getData("lumberjack >> objInHand") then
                syncPlayer(v)
            end 
        end 
    end 
)

addEventHandler('onClientElementStreamIn', root,
    function()
        if source and source.type == 'vehicle' then 
            local chestData = source:getData("lumberjack >> wood") or {}

            if chestData then 
                syncVehicle(source)
            end 
        elseif source and source.type == 'player' then 
            if source:getData("lumberjack >> objInHand") then
                syncPlayer(source)
            end 
        end 
    end 
)

addEventHandler('onClientElementStreamOut', root,
    function()
        if source and source.type == 'vehicle' then 
            if cache[source] then 
                deSyncVehicle(source)
            end 
        elseif source and source.type == 'player' then 
            if playerCache[source] then 
                deSyncPlayer(source)
            end 
        end 
    end 
)

addEventHandler("onClientElementDestroy", root, 
    function()
        if source and source.type == 'vehicle' then 
            if cache[source] then 
                deSyncVehicle(source)
            end 
        end 
    end 
)

addEventHandler('onClientPlayerQuit', root, 
    function()
        if source and source.type == 'player' then 
            if playerCache[source] then 
                deSyncPlayer(source)
            end 
        end
    end 
)

addEventHandler('onClientElementDataChange', root, 
    function(dName, oValue, nValue)
        if source and source.type == 'player' or source and source.type == 'vehicle' then 
            if isElementStreamedIn(source) then
                if dName == 'lumberjack >> wood' then 
                    syncVehicle(source)
                elseif dName == 'lumberjack >> objInHand' then 
                    syncPlayer(source)
                end 
            end
        end
    end 
)