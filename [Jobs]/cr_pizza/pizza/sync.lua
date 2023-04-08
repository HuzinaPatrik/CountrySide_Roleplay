local playerCache = {}

function syncPlayer(e)
    if e:getData("pizza >> objInHand") then
        local modelid = tonumber(e:getData("pizza >> objInHand")) or 1582

        if not playerCache[e] then 
            local obj = Object(modelid, e.position)
            obj.collisions = false
            obj.dimension = e.dimension 
            obj.interior = e.interior
            exports['cr_bone_attach']:attachElementToBone(obj, e, 12, 0.15, 0.01, 0.15, 10, 270, -110)
            playerCache[e] = obj 
        elseif playerCache[e].model ~= modelid then 
            playerCache[e].model = modelid
        end 
    else 
        if playerCache[e] then 
            playerCache[e]:destroy()
            playerCache[e] = nil 

            collectgarbage('collect')
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
        for k,v in pairs(getElementsByType('player', _, true)) do 
            if v:getData("pizza >> objInHand") then
                syncPlayer(v)
            end 
        end 
    end 
)

addEventHandler('onClientElementStreamIn', root,
    function()
        if source and source.type == 'player' then 
            if source:getData("pizza >> objInHand") then
                syncPlayer(source)
            end 
        end 
    end 
)

addEventHandler('onClientElementStreamOut', root,
    function()
        if source and source.type == 'player' then 
            if playerCache[source] then 
                deSyncPlayer(source)
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
        if source and source.type == 'player' then 
            if isElementStreamedIn(source) then
                if dName == 'pizza >> objInHand' then 
                    syncPlayer(source)
                end 
            end
        end
    end 
)