local maxStartPerTime = 1
local percentTime = 62.5
local idCache = {}

local function saveFile(path, data)
    if not path then
        return false
    end
    if fileExists(path) then
        fileDelete(path)
    end
    local file = fileCreate(path)
    fileWrite(file, data)
    fileClose(file)
    return true
end

function loadModells() 
    if not localPlayer:getData('modells >> loaded') then return end 
    if not localPlayer:getData('vehicles >> loaded') then return end 
    if not localPlayer:getData('skins >> loaded') then return end 
    
    if not loadingStarted then
        localPlayer:setData('weapons >> loading', true)

        local turnableCache = exports['cr_json']:jsonGET("modpanel/turnabled", true, {}) or {}
        loadingStarted = true
        engineSetAsynchronousLoading(false, false);
        
        local loadCache = {}
        for k,v in ipairs(cache) do
            local model, fileSrc, typ, isGlass, isVirtualSkin, headerLength, dffLength = unpack(v)
            if tonumber(model) then
                if not idCache[tostring(model)] then
                    idCache[tostring(model)] = {}
                end
                table.insert(idCache[tostring(model)], v)
                
                if not turnableCache[tostring(model)] then
                    table.insert(loadCache, v)
                end
            elseif fromJSON(tostring(model)) then
                table.insert(loadCache, v)
            end
        end
        
        local maxs = #loadCache
        allStart = 0
        
        now = getTickCount()

        exports['cr_infobox']:addBox("weapons", "Fegyverek betöltése: "..maxs.."/"..allStart, "weapons", {2, {maxs, allStart}})
        startTimer = setTimer(
            function()
                local started = 0

                for k,v in ipairs(loadCache) do
                    local model, fileSrc, typ, isGlass, isVirtualSkin, headerLength, dffLength = unpack(v)

                    if tonumber(model) then
                        if typ == "txd" then
                            local txd = engineLoadTXD(fileSrc);
                            engineImportTXD(txd, model);
                        elseif typ == "dff" then
                            local file = fileOpen(fileSrc)
                            if not file then
                                return
                            end

                            file.pos = headerLength
                            local dffData = file:read(dffLength)
                            saveFile("tmp", dffData)

                            local dff = engineLoadDFF("tmp"); --engineLoadDFF(dffData);
                            engineReplaceModel(dff, model, isGlass);
                            if fileExists("tmp") then
                                fileDelete("tmp")
                            end
                            file:close()
                        elseif typ == "col" then
                            local dff = engineLoadCOL(fileSrc);
                            engineReplaceCOL(dff, model);
                        end
                    elseif fromJSON(tostring(model)) then
                        local modells = fromJSON(tostring(model))
                        for k,v in ipairs(modells) do
                            local model = v
                            if typ == "txd" then
                                local txd = engineLoadTXD(fileSrc);
                                engineImportTXD(txd, model);
                            elseif typ == "dff" then
                                local file = fileOpen(fileSrc)
                                if not file then
                                    return
                                end

                                file.pos = headerLength
                                local dffData = file:read(dffLength)
                                saveFile("tmp", dffData)

                                local dff = engineLoadDFF("tmp"); --engineLoadDFF(dffData);
                                engineReplaceModel(dff, model, isGlass);
                                if fileExists("tmp") then
                                    fileDelete("tmp")
                                end
                                file:close()
                            elseif typ == "col" then
                                local dff = engineLoadCOL(fileSrc);
                                engineReplaceCOL(dff, model);
                            end
                        end
                    end

                    collectgarbage("collect")
                    table.remove(loadCache, k)
                    started = started + 1
                    allStart = allStart + 1

                    exports['cr_infobox']:updateBoxDetails("weapons", "custom2.details", {maxs, allStart})
                    exports['cr_infobox']:updateBoxDetails("weapons", "msg", "Fegyverek betöltése: "..maxs.."/"..allStart)

                    if started >= maxStartPerTime then
                        return
                    end
                end

                if #loadCache == 0 then
                    localPlayer:setData('weapons >> loading', false)
                    localPlayer:setData('weapons >> loaded', true)

                    local newNow = getTickCount()
                    local seconds = (newNow - now) / 1000
                    outputDebugString("Loading succesfully finished, #"..allStart.." weapons loaded in #"..seconds.." seconds!", 0, 20, 87, 255)
                    triggerEvent("builder>loadTuningParts", localPlayer, localPlayer)
                    killTimer(startTimer)
                end
            end, percentTime, 0
        )
    end
end
addEvent("builder>loadWeapons", true)
addEventHandler("builder>loadWeapons", root, loadModells)

addEventHandler('onClientResourceStart', resourceRoot, 
    function()
        if localPlayer:getData('modells >> loaded') then 
            if not localPlayer:getData('modells >> loading') then 
                triggerEvent("builder>loadModells", localPlayer, localPlayer)
            end 
        end 

        if localPlayer:getData('vehicles >> loaded') then 
            if not localPlayer:getData('vehicles >> loading') then 
                triggerEvent("builder>loadVehicles", localPlayer, localPlayer)
            end 
        end 

        if localPlayer:getData('skins >> loaded') then 
            if not localPlayer:getData('weapons >> loading') then 
                loadModells()
            end 
        else 
            if not localPlayer:getData('skins >> loading') then 
                triggerEvent("builder>loadSkins", localPlayer, localPlayer)
            end 
        end 
    end 
)