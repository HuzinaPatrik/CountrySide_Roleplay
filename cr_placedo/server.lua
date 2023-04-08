local cache = {}
local playerPlacedo = {}
local idToCache = {}
local timers = {}

function createPlacedo(sourcePlayer, text)
    if not playerPlacedo[sourcePlayer:getData("acc >> id")] then 
        playerPlacedo[sourcePlayer:getData("acc >> id")] = 0 
    end 

    if playerPlacedo[sourcePlayer:getData("acc >> id")] + 1 <= 3 then 
        playerPlacedo[sourcePlayer:getData("acc >> id")] = playerPlacedo[sourcePlayer:getData("acc >> id")] + 1

        local obj = Object(1962, sourcePlayer.position)
        obj:setData("placedo >> owner", sourcePlayer:getData("acc >> id"))
        obj:setData("placedo >> text", text)
        obj.dimension = sourcePlayer.dimension 
        obj.interior = sourcePlayer.interior
        obj.collisions = false
        obj.alpha = 0

        table.insert(cache, obj)
        idToCache[#cache] = obj
        obj:setData("placedo >> id", #cache)

        local syntax = exports['cr_core']:getServerSyntax(nil, "success")
        local blue = exports['cr_core']:getServerColor(nil, true)
        outputChatBox(syntax .. "Sikeresen létrehoztad a placedo-t! ID: ".. blue .. #cache, sourcePlayer, 255, 255, 255, true)

        timers[obj] = setTimer(deletePlacedo, 1 * 60 * 60 * 1000, 1, #cache)
    else 
        local syntax = exports['cr_core']:getServerSyntax(nil, "error")
        outputChatBox(syntax .. "Neked már levan helyezve 3 placedo-d, törölj ki egyet ahhoz, hogy újat tudj létrehozni!", sourcePlayer, 255, 255, 255, true)
    end 
end 
addEvent("createPlacedo", true)
addEventHandler("createPlacedo", root, createPlacedo)

function deletePlacedo(id)
    if idToCache[id] then 
        local obj = idToCache[id]
        local owner = obj:getData("placedo >> owner")
        playerPlacedo[owner] = playerPlacedo[owner] - 1
        obj:destroy()
        idToCache[id] = nil 

        if isTimer(timers[obj]) then 
            killTimer(timers[obj])
            timers[obj] = nil 
        end 

        collectgarbage("collect")
    end 
end 
addEvent("deletePlacedo", true)
addEventHandler("deletePlacedo", root, deletePlacedo)

function deletePlaceDoCommand(sourcePlayer, cmd, id)
    if exports['cr_permission']:hasPermission(sourcePlayer, "deleteplacedo") then
        id = tonumber(id)
        if not id then 
            local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ID]", sourcePlayer, 255, 255, 255, true)
            return 
        end 

        if idToCache[id] then 
            deletePlacedo(id)

            local blue = exports['cr_core']:getServerColor("blue", true)
            local white = "#ffffff"
            local syntax = exports['cr_core']:getServerSyntax(nil, "success")
            outputChatBox(syntax .. "Sikeresen törölted a placedo-t! (ID: "..blue..id..white..")", sourcePlayer, 255, 255, 255, true)

            local green = exports['cr_core']:getServerColor("orange", true)
            local white = "#ffffff"
            local syntax = exports['cr_admin']:getAdminSyntax()
            local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
            exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." törölt egy placedo-t! (ID: "..blue..id..white..")", 6)
            exports['cr_logs']:addLog(sourcePlayer, "Placedo", "deleteplacedo", syntax..aName.." törölt egy placedo-t! (ID: "..id..")")
        else 
            local syntax = exports['cr_core']:getServerSyntax(nil, "error")
            outputChatBox(syntax .. "Nem található ilyen IDjű placedo!", sourcePlayer, 255, 255, 255, true)
        end 
    end 
end 
addCommandHandler("deleteplacedo", deletePlaceDoCommand, false, false)
addCommandHandler("delplacedo", deletePlaceDoCommand, false, false)

addEvent("updatePlacedoPosition", true)
addEventHandler("updatePlacedoPosition", root, 
    function(sourcePlayer, e, x, y,z)
        e.position = Vector3(x,y,z)
    end 
)