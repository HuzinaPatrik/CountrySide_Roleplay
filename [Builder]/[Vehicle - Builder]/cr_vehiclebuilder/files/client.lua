local maxStartPerTime = 1
local percentTime = 62.5
local idCache = {}
virtualToAllocatedVehicleID = {}

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
    
    if not loadingStarted then
        localPlayer:setData('vehicles >> loading', true)

        local turnableCache = exports['cr_json']:jsonGET("modpanel/turnabled", true, {}) or {}
        loadingStarted = true
        engineSetAsynchronousLoading(false, false);
        
        local loadCache = {}
        for k,v in ipairs(cache) do
            local model, fileSrc, typ, isGlass, isVirtualVehicle, headerLength, dffLength = unpack(v)
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

        virtualVehicles = {}
        for k,v in ipairs(cache) do 
            local model, fileSrc, typ, isGlass, isVirtualVehicle, headerLength, dffLength = unpack(v)
            if isVirtualVehicle then 
                if typ == "txd" then 
                    local v = engineRequestModel("vehicle")

                    virtualVehicles[model] = v
                    virtualToAllocatedVehicleID[model] = v
                end 
            end 
        end 
        
        local maxs = #loadCache
        allStart = 0
        
        now = getTickCount()

        exports['cr_infobox']:addBox("vehicles", "Járművek betöltése: "..maxs.."/"..allStart, "vehicles", {2, {maxs, allStart}})
        startTimer = setTimer(
            function()
                local started = 0

                for k,v in ipairs(loadCache) do
                    local model, fileSrc, typ, isGlass, isVirtualVehicle, headerLength, dffLength = unpack(v)

                    if isVirtualVehicle then 
                        model = virtualVehicles[model]
                    end 

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

                    exports['cr_infobox']:updateBoxDetails("vehicles", "custom2.details", {maxs, allStart})
                    exports['cr_infobox']:updateBoxDetails("vehicles", "msg", "Járművek betöltése: "..maxs.."/"..allStart)

                    if started >= maxStartPerTime then
                        return
                    end
                end

                if #loadCache == 0 then
                    localPlayer:setData('vehicles >> loading', false)
                    localPlayer:setData('vehicles >> loaded', true)

                    local newNow = getTickCount()
                    local seconds = (newNow - now) / 1000
                    outputDebugString("Loading succesfully finished, #"..allStart.." vehicles loaded in #"..seconds.." seconds!", 0, 20, 87, 255)
                    killTimer(startTimer)
                    triggerEvent("builder>loadSkins", localPlayer, localPlayer)

                    for _, v in pairs(getElementsByType("vehicle", _, true)) do
                        local model = v:getData('veh >> virtuaModellID')
                        if model and isVehicleValid(model) then
                            setElementSpecialModel(v, model)
                        end
                    end
                end
            end, percentTime, 0
        )
    end
end
addEvent("builder>loadVehicles", true)
addEventHandler("builder>loadVehicles", root, loadModells)

function loadModel(id)
    if idCache[tostring(id)] then
        for k,v in pairs(idCache[tostring(id)]) do
            local model, fileSrc, typ, isGlass, isVirtualVehicle, headerLength, dffLength = unpack(v)

            if isVirtualVehicle then 
                model = virtualVehicles[model]
            end 

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
        end
    end
end

function getModelSize(id)
    local val = 0
    if idCache[tostring(id)] then
        for k,v in pairs(idCache[tostring(id)]) do
            local model, fileSrc, typ, isGlass, isVirtualVehicle, headerLength, dffLength = unpack(v)
            if fileExists(fileSrc) then
                local a = fileOpen(fileSrc)
                val = val + tonumber(string.sub(tostring(a.size * 0.00000095367432):gsub("%%", ""), 0, 4))
                fileClose(a)
            end
        end
    end
    
    return val
end

function getModelTypSize(id, s)
    local val = 0
    if idCache[tostring(id)] then
        for k,v in pairs(idCache[tostring(id)]) do
            local model, fileSrc, typ, isGlass, isVirtualVehicle, headerLength, dffLength = unpack(v)
            if typ == s then
                if fileExists(fileSrc) then
                    local a = fileOpen(fileSrc)
                    val = val + tonumber(string.sub(tostring(a.size * 0.00000095367432):gsub("%%", ""), 0, 4))
                    fileClose(a)
                end
            end
        end
    end
    
    return val
end

function setElementSpecialModel(veh, model)
    if tonumber(model) then 
        if isVirtualVehicle(model) then
            if virtualToAllocatedVehicleID[model] then 
                veh:setModel(virtualToAllocatedVehicleID[model])
            end 
        else
            veh:setModel(model)
        end
    end 
end


addEventHandler("onClientElementDataChange", root,
    function(dName, oValue, nValue)
        if dName == "veh >> virtuaModellID" then
            setElementSpecialModel(source, nValue)
        end 
    end
)

addEventHandler("onClientElementStreamIn", root, 
    function()
        if source then 
            if source.type == "vehicle" then 
                local model = source:getData('veh >> virtuaModellID')
                if model and isVehicleValid(model) then
                    setElementSpecialModel(source, model)
                end 
            end 
        end 
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        for i, v in pairs(virtualToAllocatedVehicleID) do
            engineFreeModel(virtualToAllocatedVehicleID[i])
        end
    end
)

addEventHandler('onClientResourceStart', resourceRoot, 
    function()
        if localPlayer:getData('modells >> loaded') then 
            if not localPlayer:getData('vehicles >> loading') then 
                loadModells()
            end 
        else 
            if not localPlayer:getData('modells >> loading') then 
                triggerEvent("builder>loadModells", localPlayer, localPlayer)
            end 
        end 
    end 
)