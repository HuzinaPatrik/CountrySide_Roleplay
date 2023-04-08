local maxStartPerTime = 1
local percentTime = 62.5
local idCache = {}
virtualToAllocatedSkinID = {}

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
    
    if not loadingStarted then
        localPlayer:setData('skins >> loading', true)

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

        virtualSkins = {}
        for k,v in ipairs(cache) do 
            local model, fileSrc, typ, isGlass, isVirtualSkin, headerLength, dffLength = unpack(v)
            if isVirtualSkin then 
                if typ == "txd" then 
                    local v = engineRequestModel("ped")

                    virtualSkins[model] = v
                    virtualToAllocatedSkinID[model] = v
                end 
            end 
        end 
        
        local maxs = #loadCache
        allStart = 0
        
        now = getTickCount()

        exports['cr_infobox']:addBox("skins", "Skinek betöltése: "..maxs.."/"..allStart, "skins", {2, {maxs, allStart}})
        startTimer = setTimer(
            function()
                local started = 0

                for k,v in ipairs(loadCache) do
                    local model, fileSrc, typ, isGlass, isVirtualSkin, headerLength, dffLength = unpack(v)

                    if isVirtualSkin then 
                        model = virtualSkins[model]
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

                    exports['cr_infobox']:updateBoxDetails("skins", "custom2.details", {maxs, allStart})
                    exports['cr_infobox']:updateBoxDetails("skins", "msg", "Skinek betöltése: "..maxs.."/"..allStart)

                    if started >= maxStartPerTime then
                        return
                    end
                end

                if #loadCache == 0 then
                    localPlayer:setData('skins >> loading', false)
                    localPlayer:setData('skins >> loaded', true)

                    local newNow = getTickCount()
                    local seconds = (newNow - now) / 1000
                    outputDebugString("Loading succesfully finished, #"..allStart.." skins loaded in #"..seconds.." seconds!", 0, 20, 87, 255)
                    killTimer(startTimer)
                    triggerEvent("builder>loadWeapons", localPlayer, localPlayer)

                    for _, player in pairs(getElementsByType("player", _, true)) do
                        local skinID = getElementData(player, "char >> skin")
                        if skinID and isSkinValid(skinID) then
                            setElementSpecialModel(player, skinID)
                        end
                    end
            
                    for _, ped in pairs(getElementsByType("ped", _, true)) do
                        local skinID = getElementData(ped, "ped >> skin")
                        if skinID and isSkinValid(skinID) then
                            setElementSpecialModel(ped, skinID)
                        end
                    end
                end
            end, percentTime, 0
        )
    end
end
addEvent("builder>loadSkins", true)
addEventHandler("builder>loadSkins", root, loadModells)

function setElementSpecialModel(player, skin)
    if tonumber(skin) then 
        if isVirtualSkin(skin) then
            if virtualToAllocatedSkinID[skin] then 
                player:setModel(virtualToAllocatedSkinID[skin])
            end 
        else
            player:setModel(skin)
        end
    end 
end

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue, nValue)
        if dName == "char >> skin" or dName == "ped >> skin" or dName == "char >> dutyskin" then
            setElementSpecialModel(source, nValue)
        end 
    end
)

addEventHandler("onClientPlayerSpawn", root,
    function()
        setElementSpecialModel(source, source:getData("char >> skin") or source:getModel())
    end
)

addEventHandler("onClientElementStreamIn", root, 
    function()
        if source then 
            if source.type == "player" then 
                local skinID = getElementData(source, "char >> skin")
                if tonumber(source:getData("char >> dutyskin")) then 
                    skinID = tonumber(source:getData("char >> dutyskin"))
                end 
                if skinID and isSkinValid(skinID) then
                    setElementSpecialModel(source, skinID)
                end 
            elseif source.type == "ped" then 
                local skinID = getElementData(source, "ped >> skin")
                if skinID and isSkinValid(skinID) then
                    setElementSpecialModel(source, skinID)
                end 
            end 
        end 
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        for i, v in pairs(virtualToAllocatedSkinID) do
            engineFreeModel(virtualToAllocatedSkinID[i])
        end
    end
)

addEventHandler('onClientResourceStart', resourceRoot, 
    function()
        if localPlayer:getData('modells >> loaded') then 
            if not localPlayer:getData('modells >> loading') then 
                triggerEvent("builder>loadModells", localPlayer, localPlayer)
            end 
        end 

        if localPlayer:getData('vehicles >> loaded') then 
            if not localPlayer:getData('skins >> loading') then 
                loadModells()
            end 
        else 
            if not localPlayer:getData('vehicles >> loading') then 
                triggerEvent("builder>loadVehicles", localPlayer, localPlayer)
            end 
        end 
    end 
)