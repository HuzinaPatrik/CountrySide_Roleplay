local white = "#ffffff"

function findID(cmd, id)
    if not id then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [target]", 255,255,255,true)
        return
    end
    local target = exports['cr_core']:findPlayer(localPlayer, id)
    if target then
        if not getElementData(target, "loggedIn") then
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A játékos nincs bejelentkezve", 255,255,255,true)
            return
        end
        
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        local green = exports['cr_core']:getServerColor('yellow', true)
        local aName = tostring(exports['cr_admin']:getAdminName(target, false))
        local level = tonumber(getElementData(target, "char >> id") or 1)
        outputChatBox(syntax .. green..aName..white .. " idje: " .. green..level, 255,255,255,true)
    else
        local green = exports['cr_core']:getServerColor('yellow', true)
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "A játékos nem található", 255,255,255,true)
    end
end
addCommandHandler("id", findID)

function findLevel(cmd, id)
    if not id then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [target]", 255,255,255,true)
        return
    end
    local target = exports['cr_core']:findPlayer(localPlayer, id)
    if target then
        if not getElementData(target, "loggedIn") then
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A játékos nincs bejelentkezve", 255,255,255,true)
            return
        end
        
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        local green = exports['cr_core']:getServerColor('yellow', true)
        local aName = tostring(exports['cr_admin']:getAdminName(target, false))
        local level = tonumber(getElementData(target, "char >> level") or 1)
        outputChatBox(syntax .. green..aName..white .. " szintje: " .. green..level, 255,255,255,true)
    else
        local green = exports['cr_core']:getServerColor('yellow', true)
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "A játékos nem található", 255,255,255,true)
    end
end
addCommandHandler("level", findLevel)
addCommandHandler("lvl", findLevel)
addCommandHandler("szint", findLevel)

local cache = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(getElementsByType("player")) do
            local id = getElementData(v, "char >> id") or 1
            if id then
                cache[id] = v
            end
        end
    end
)

addEventHandler("onClientElementDataChange", root,
    function(dName)
        if dName == "char >> id" then
            local value = source:getData(dName)
            if value and type(value) == "number" then
                cache[value] = source
            end
        end
    end
)

addEventHandler("onClientPlayerQuit", root,
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