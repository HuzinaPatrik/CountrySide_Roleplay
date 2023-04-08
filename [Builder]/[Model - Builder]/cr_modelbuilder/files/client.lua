local maxStartPerTime = 1
local percentTime = 125
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
    if not loadingStarted then
        localPlayer:setData('modells >> loading', true)

        local turnableCache = exports['cr_json']:jsonGET("modpanel/turnabled", true, {}) or {}
        loadingStarted = true
        engineSetAsynchronousLoading(false, false);
        
        local loadCache = {}
        for k,v in ipairs(cache) do
            local model, fileSrc, typ, isGlass, specialLodDistance, headerLength, dffLength = unpack(v)
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

        exports['cr_infobox']:addBox("models", "Modellek betöltése: "..maxs.."/"..allStart, "models", {2, {maxs, allStart}})
        startTimer = setTimer(
            function()
                local started = 0

                for k,v in ipairs(loadCache) do
                    local model, fileSrc, typ, isGlass, specialLodDistance, headerLength, dffLength = unpack(v)

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

                        if tonumber(specialLodDistance) then 
                            engineSetModelLODDistance(tonumber(model), tonumber(specialLodDistance))
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

                            if tonumber(specialLodDistance) then 
                                engineSetModelLODDistance(tonumber(model), tonumber(specialLodDistance))
                            end 
                        end
                    end

                    collectgarbage("collect")
                    table.remove(loadCache, k)
                    started = started + 1
                    allStart = allStart + 1

                    exports['cr_infobox']:updateBoxDetails("models", "custom2.details", {maxs, allStart})
                    exports['cr_infobox']:updateBoxDetails("models", "msg", "Modellek betöltése: "..maxs.."/"..allStart)

                    if started >= maxStartPerTime then
                        return
                    end
                end

                if #loadCache == 0 then
                    localPlayer:setData('modells >> loading', false)
                    localPlayer:setData('modells >> loaded', true)

                    local newNow = getTickCount()
                    local seconds = (newNow - now) / 1000
                    outputDebugString("Loading succesfully finished, #"..allStart.." modells loaded in #"..seconds.." seconds!", 0, 20, 87, 255)
                    killTimer(startTimer)
                    triggerEvent("builder>loadVehicles", localPlayer, localPlayer)
                end
            end, percentTime, 0
        )
    end
end
addEvent('builder>loadModells', true)
addEventHandler('builder>loadModells', root, loadModells)

localPlayer:setData("modsLoaded", false)
addEventHandler("onClientResourceStart", resourceRoot, loadModells)