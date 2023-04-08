local subTag = "cr_"

local resourceList = {

    --[[
        Core
    ]]

    subTag .. 'protect', 
    subTag .. "mysql",
    subTag .. "core",
    subTag .. "json",
    subTag .. "fonts",
    subTag .. "logs",
    subTag .. "anticheat",
    subTag .. "whitelist", 
    subTag .. "network",
    subTag .. "controls",
    subTag .. "blur",
    subTag .. "account",
    subTag .. 'infobox', -- Ennek is itt kell lennie
    subTag .. 'radar', -- Ez nem a core része de itt kell elindulnia, hogy minden alatt maradjon
    subTag .. "interface", -- Ennek is itt kell lennie
    subTag .. "inventory",
    subTag .. 'id',

    --[[
        Interface
    ]]
    subTag .. 'dx', 
    subTag .. 'minigame', 
    subTag .. 'custom-chat', 
    subTag .. 'dashboard',  

    --[[
        Admin
    ]]
    subTag .. 'permission', 
    subTag .. 'admin', 

    --[[
        Bank / Interior
    ]]
    subTag .. 'bank',
    subTag .. 'interior',
    subTag .. 'robbery',

    --[[
        Vehicle
    ]]
    subTag .. 'handling',
    subTag .. 'tuning',
    subTag .. 'vehicle',

    --[[
        Builders
    ]]
    subTag .. 'maploader',
    subTag .. 'models',
    subTag .. 'vehicles',
    subTag .. 'skins',
    subTag .. 'weapons',
    subTag .. 'tuningparts',
}

local excludeResources = {
    [subTag .. 'maps'] = true,
    [subTag .. 'modelpanel'] = true, 
    [subTag .. 'vehiclepanel'] = true, 
    [subTag .. 'skinpanel'] = true, 
    [subTag .. 'weaponpanel'] = true, 
    [subTag .. 'tuningpartpanel'] = true, 
}

for k,v in pairs(resourceList) do
    excludeResources[v] = true
end

local threadTimer
local threads = {}
local load_speed = 1000 -- Hány másodpercenként töltsön be load_speed_multipler számú resourceot
local load_speed_multipler = 1 -- Hány resource-t töltsön be load_speed időnként
local canConnect = false;
local serverStopping = false

addEventHandler("onResourceStart", resourceRoot,
    function()
        if not canConnect then 
            threads = {}

            local resources = {}
            for k,v in ipairs(resourceList) do 
                resources[k] = v 
            end 

            for k,v in ipairs(getResources()) do 
                local name = getResourceName(v)

                local subText = utfSub(name, 1, #subTag)
                if subText == subTag and not excludeResources[name] then 
                    table.insert(resources, #resources + 1, name)
                end 
            end 

            for i = 1, #resources do
                local resName = resources[i]
                local res = getResourceFromName(resName)

                if res and res ~= getThisResource() then
                    local meta = xmlLoadFile(":" .. resName .. "/meta.xml")
                    if meta then
                        local dpg = xmlFindChild(meta, "download_priority_group", 0)
                        local download_priority_group = 0 - i
                        if dpg then
                            xmlNodeSetValue(dpg, tostring(download_priority_group))
                        else
                            dpg = xmlCreateChild(meta, "download_priority_group")
                            xmlNodeSetValue(dpg, tostring(download_priority_group))
                        end

                        outputDebugString(resName .. " download_priority_group changed to -> " .. tostring(download_priority_group), 1)

                        xmlSaveFile(meta)
                        xmlUnloadFile(meta)
                    else 
                        outputDebugString(resName)
                    end

                    table.insert(threads, #threads + 1, res)
                end
            end

            threadSize = #threads

            threadTimer = setTimer(
                function(resources)
                    local num = 0

                    for k,v in ipairs(threads) do
                        num = num + 1

                        if num > load_speed_multipler then
                            break
                        end

                        startResource(v)

                        table.remove(threads, k)

                        outputDebugString(getResourceName(v).. " resource has started!", 2)
                    end

                    if num == 0 then
                        killTimer(threadTimer)
                        outputDebugString("All resource started!", 3)

                        threads = {}

                        threadTimer = nil
                        
                        for i = 1, #resources do
                            local resName = resources[i]
                            local res = getResourceFromName(resName)
            
                            if res and res ~= getThisResource() then
                                table.insert(threads, 1, res)
                            end
                        end
            
                        threadSize = #threads
            
                        threadTimer = setTimer(
                            function()
                                local num = 0
            
                                for k,v in ipairs(threads) do
                                    num = num + 1
            
                                    if num > load_speed_multipler then
                                        break
                                    end
            
                                    restartResource(v)
            
                                    table.remove(threads, k)
            
                                    outputDebugString(getResourceName(v).. " resource has restarted!", 2)
                                end
            
                                if num == 0 then
                                    killTimer(threadTimer)
                                    outputDebugString("All resource restarted!", 3)
            
                                    threads = {}
            
                                    threadTimer = nil
                                    canConnect = true
                                end
                            end, load_speed, 0 
                        )
                    end
                end, load_speed, 0, resources
            )
        end
    end
)

addEventHandler("onPlayerConnect", root,
    function()
        if not canConnect then
            cancelEvent(true, "CountrySide\nA szerver " .. (serverStopping and "leállítás" or "betöltés") .. " alatt van (".. (threadSize - #threads) .. " / " .. threadSize .. ")!")
        end
    end
)

function stopServer(player, cmd)
    if exports['cr_permission']:hasPermission(player, 'stopserver') then 
        if canConnect then 
            threads = {}

            canConnect = false 
            serverStopping = true

            --[[
                Player Kick
            ]]

            local players = getElementsByType('player')
            for i = 1, #players do
                table.insert(threads, 1, players[i])
            end

            threadSize = #threads

            threadTimer = setTimer(
                function()
                    local num = 0

                    for k,v in ipairs(threads) do
                        num = num + 1

                        if num > load_speed_multipler then
                            break
                        end

                        kickPlayer(v, 'Core', 'A szerver leállítás alatt van!')

                        table.remove(threads, k)

                        outputDebugString(getPlayerName(v).. " player kicked!", 2)
                    end

                    if num == 0 then
                        killTimer(threadTimer)
                        outputDebugString("All players started!", 3)

                        threads = {}

                        threadTimer = nil

                        --[[
                            After players kicked
                        ]]

                        local resources = {}

                        for k,v in ipairs(getResources()) do 
                            local name = getResourceName(v)

                            local subText = utfSub(name, 1, #subTag)
                            if subText == subTag and not excludeResources[name] then 
                                table.insert(resources, 1, name)
                            end 
                        end 

                        for i = 1, #resourceList do 
                            local v = resourceList[(#resourceList - i) + 1]
                            table.insert(resources, #resources + 1, v)
                        end

                        for i = 1, #resources do
                            local resName = resources[i]
                            local res = getResourceFromName(resName)

                            if res and res ~= getThisResource() then
                                table.insert(threads, #threads + 1, res)
                            end
                        end

                        threadSize = #threads

                        threadTimer = setTimer(
                            function()
                                local num = 0

                                for k,v in ipairs(threads) do
                                    num = num + 1

                                    if num > load_speed_multipler then
                                        break
                                    end

                                    stopResource(v)

                                    table.remove(threads, k)

                                    outputDebugString(getResourceName(v).. " resource stopped!", 2)
                                end

                                if num == 0 then
                                    killTimer(threadTimer)
                                    outputDebugString("All resource stopped, server shutting down!", 3)

                                    shutdown('A szerver sikeresen leállítva!')

                                    threadTimer = nil

                                end
                            end, load_speed, 0 
                        )
                    end
                end, load_speed, 0 
            )
        end
    end 
end 
addCommandHandler('stopserver', stopServer)