local cache = {}
local serverslot = getMaxPlayers()

function generateId(v)
    for i = 1, serverslot do
        if not cache[i] then
            cache[i] = v
            setElementData(v, "char >> id", i)
            return
        end
    end
end

addEventHandler("onResourceStart", resourceRoot,
    function()
        for k,v in pairs(getElementsByType("player")) do
            local id = getElementData(v, "char >> id")
            if id then
                cache[id] = v
            else
                generateId(v)
            end
        end
    end
)

addEventHandler("onPlayerJoin", root,
    function()
        generateId(source)
    end
)

addEventHandler("onPlayerQuit", root,
    function()
        local id = getElementData(source, "char >> id")
        if id then
            cache[id] = nil
        end
    end
)

function getPlayer(id)
    local a = cache[id]
    return a
end

function getPlayers()
    return cache
end