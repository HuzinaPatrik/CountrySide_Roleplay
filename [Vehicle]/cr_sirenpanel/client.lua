local screenX, screenY = guiGetScreenSize()
local boxWidth, boxHeight = 253, 87

local alpha = 0

local minSirenLine = 1
local maxSirenLine = 4

local hoverSiren = false

local occupiedVehicle = false
local occupiedVehicleData = false

local soundElements = {}

local vehicleLightDatas = {}
local vehicleLightTimers = {}

local vehicleSirenCache = {}
local activeVehicle = false
local activeVehicleDbId = false

local lastInteractionTick = 0
local interactionTimeDelay = 500

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        if localPlayer:getData("loggedIn") then
            local vehicle = localPlayer.vehicle
            
            if vehicle then 
                if emergencyVehicles[vehicle.model] or vehicle:getData("veh >> sirenData") and vehicle:getData("veh >> sirenData").activeByItem then 
                    local seat = localPlayer.vehicleSeat

                    if seat == 0 or seat == 1 then 
                        processSirenPanel("init")
                    end
                end
            end

            local streamedVehicles = getElementsByType("vehicle", root, true)

            for i = 1, #streamedVehicles do 
                local v = streamedVehicles[i]
                local sirenData = getSirenData(v)

                if sirenData then 
                    if sirenData.activeByItem then 
                        processVehicleSiren(v, true)
                    end
                end
            end
        end
    end
)

function onStreamIn()
    if not vehicleSirenCache[source] then 
        local sirenData = getSirenData(source)

        if sirenData and sirenData.activeByItem then 
            processVehicleSiren(source, true)
        end
    end
end
addEventHandler("onClientElementStreamIn", root, onStreamIn)

function onStreamOut()
    if vehicleSirenCache[source] then 
        local sirenData = getSirenData(source)

        if sirenData and sirenData.activeByItem then
            processVehicleSiren(source, false)
        end
    end
end
addEventHandler("onClientElementStreamOut", root, onStreamOut)

function renderSirenPanel()
    local _, x, y, w = exports["cr_interface"]:getDetails("sirenPanel")
    local h = 90

    local alpha, progress = exports["cr_dx"]:getFade("sirenPanel")
    if alpha and progress then 
        if progress >= 1 then 
            if alpha <= 0 then 
                destroyRender("renderSirenPanel")

                -- activeVehicle = false
                occupiedVehicle = false
                occupiedVehicleData = false
            end
        end
    end

    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 10)

    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
    dxDrawImage(x + 10, y + 5, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	dxDrawText("Sziréna", x + 10 + 26 + 5,y+5,x+w,y+5+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

    local startX, startY = x + 25, y + 40
    hoverSiren = nil
    local r, g, b = 255, 59, 59

    local activeSiren = false
    local activeLight = false

    if occupiedVehicleData then 
        activeSiren = occupiedVehicleData.activeSiren
        activeLight = occupiedVehicleData.activeLight or occupiedVehicleData.activeItemLights and 1 or false
    end

    for i = minSirenLine, maxSirenLine do 
        local v = sirenTypes[i]

        if v then
            if v["imagePath"] then 
                local x, y = startX + 52/2 - v["w"]/2, startY 

                local inSlot = exports["cr_core"]:isInSlot(x, y, v["w"], v["h"])
                if inSlot then 
                    hoverSiren = i
                end

                dxDrawImage(x, y, v["w"], v["h"], v["imagePath"], 0, 0, 0, ((inSlot or activeSiren == i or activeLight == i) and tocolor(r, g, b, alpha) or tocolor(242, 242, 242, alpha * 0.6)))

                dxDrawText(v['name'], startX, y + 30, startX + 52, y + 30, ((inSlot or activeSiren == i or activeLight == i) and tocolor(r, g, b, alpha) or tocolor(242, 242, 242, alpha * 0.6)), 1, font2, "center", "top")

                if i < maxSirenLine then 
                    dxDrawRectangle(startX + 52, y, 2, 40, tocolor(151, 58, 58, alpha * 0.7)) 
                end
            end
        end 

        startX = startX + 52 + 2
    end 
end

function getSirenData(vehicle)
    if isElement(vehicle) then 
        local data = vehicle:getData("veh >> sirenData") or {["soundId"] = false, ["lights"] = false, ["strobe"] = false, ["activeSiren"] = false, ["activeLight"] = false, ["activeByItem"] = false}

        return data
    end

    return false
end

function manageSirenFunctions(type, id)
    local vehicle = localPlayer.vehicle

    if type == "sound" then 
        local data = getSirenData(vehicle)

        if data["soundId"] ~= id then 
            data["soundId"] = id
            data.activeSiren = id

            triggerServerEvent("siren >> toggleSound", localPlayer, localPlayer, id, vehicle)
        else
            data["soundId"] = false
            data.activeSiren = false

            triggerServerEvent("siren >> toggleSound", localPlayer, localPlayer, false, vehicle)
        end

        vehicle:setData("veh >> sirenData", data)
    elseif type == "lights" then 
        local data = getSirenData(vehicle)

        if not data["lights"] or data["lights"] ~= id and id then 
            data["lights"] = id
            data.activeLight = 1

            triggerServerEvent("siren >> toggleLights", localPlayer, localPlayer, id)
        else
            data["lights"] = false
            data.activeLight = false

            triggerServerEvent("siren >> toggleLights", localPlayer, localPlayer, false)
        end

        vehicle:setData("veh >> sirenData", data)
    elseif type == "itemLights" then
        if lastInteractionTick + interactionTimeDelay > getTickCount() then 
            local syntax = exports.cr_core:getServerSyntax("Siren", "error")
            outputChatBox(syntax .. "Ilyen gyorsan nem végezhetsz interakciót!", 255, 0, 0, true)
            
            return
        end

        if vehicleSirenCache[vehicle] then 
            local data = getSirenData(vehicle)
            local state = not data.activeItemLights

            data.activeItemLights = state
            vehicle:setData("veh >> sirenData", data)
        end

        lastInteractionTick = getTickCount()
    end
end

function onKey(button, state)
    if button == "mouse1" then 
        if state then 
            if checkRender("renderSirenPanel") then 
                if hoverSiren then 
                    if sirenTypes[hoverSiren] then 
                        if lastInteractionTick + interactionTimeDelay > getTickCount() then 
                            local syntax = exports.cr_core:getServerSyntax("Siren", "error")
                            outputChatBox(syntax .. "Ilyen gyorsan nem végezhetsz interakciót!", 255, 0, 0, true)
                            
                            return
                        end

                        local soundPath = sirenTypes[hoverSiren]["soundPath"]

                        if exports["cr_network"]:getNetworkStatus() then 
                            return
                        end

                        local sirenType = sirenTypes[hoverSiren]["type"]
                        local id = hoverSiren

                        if sirenTypes[id]["name"] == "Villogó" then 
                            local vehicle = localPlayer.vehicle
                            
                            if sirenPositions[vehicle.model] then 
                                local data = getSirenData(vehicle)

                                if not data["lights"] then 
                                    id = 1
                                else 
                                    if id + 1 <= #sirenPositions[vehicle.model] then 
                                        id = id + 1
                                    else
                                        id = false
                                    end
                                end

                                manageSirenFunctions(sirenType, id)
                            elseif vehicleSirenPositions[vehicle.model] then
                                manageSirenFunctions("itemLights")
                            end
                        else
                            manageSirenFunctions(sirenType, hoverSiren)
                        end

                        exports["cr_chat"]:createMessage(localPlayer, "megnyomott egy gombot a műszerfalon.", 1)
                    end

                    lastInteractionTick = getTickCount()
                    hoverSiren = nil
                end
            end
        end
    end
end

function processVehicleStrobe(vehicle, state)
    if isElement(vehicle) then 
        if state then 
            vehicle:setLightState(0, 1)
            vehicle:setLightState(3, 1)
            vehicle:setLightState(1, 0)
            vehicle:setLightState(2, 0)
            vehicle:setHeadLightColor(255, 255, 255)
        else
            vehicle:setLightState(0, 0)
            vehicle:setLightState(3, 0)
            vehicle:setLightState(1, 1)
            vehicle:setLightState(2, 1)
            vehicle:setHeadLightColor(255, 255, 255)
        end

        vehicleLightTimers[vehicle] = setTimer(processVehicleStrobe, 150, 1, vehicle, not state)
    else
        vehicleLightTimers[vehicle] = nil 
    end
end

addEventHandler("onClientElementDataChange", root,
    function(dataName, oldValue, newValue)
        if source.type == "vehicle" then 
            if dataName == "veh >> sirenData" then 
                local data = getSirenData(source)

                if data["strobe"] then 
                    if not vehicleLightDatas[source] then 
                        vehicleLightDatas[source] = {}

                        for i = 0, 3 do 
                            vehicleLightDatas[source][i] = source:getLightState(i)
                        end

                        vehicleLightDatas[source]["headLightColor"] = {source:getHeadLightColor()}
                        vehicleLightDatas[source]["overRideLights"] = source:getOverrideLights()

                        source:setOverrideLights(2)

                        vehicleLightTimers[source] = setTimer(processVehicleStrobe, 150, 1, source, true)
                    end
                else
                    if vehicleLightTimers[source] and isTimer(vehicleLightTimers[source]) then 
                        killTimer(vehicleLightTimers[source])
                        vehicleLightTimers[source] = nil 
                    end

                    if vehicleLightDatas[source] then 
                        for i = 0, 3 do 
                            if vehicleLightDatas[source][i] then 
                                source:setLightState(i, vehicleLightDatas[source][i])
                            end
                        end

                        source:setHeadLightColor(unpack(vehicleLightDatas[source]["headLightColor"]))
                        source:setOverrideLights(vehicleLightDatas[source]["overRideLights"])

                        vehicleLightDatas[source] = nil
                    end
                end

                if data.activeByItem then
                    if not checkRender("renderSirenPanel") then 
                        local occupiedVehicle = localPlayer.vehicle

                        if occupiedVehicle and source == occupiedVehicle then 
                            processSirenPanel("init")
                        end
                    end

                    if isElementStreamedIn(source) and not vehicleSirenCache[source] then 
                        processVehicleSiren(source, true)
                    end
                else
                    if checkRender("renderSirenPanel") then 
                        local occupiedVehicle = localPlayer.vehicle

                        if occupiedVehicle and source == occupiedVehicle and not emergencyVehicles[occupiedVehicle.model] then 
                            processSirenPanel("exit")
                        end
                    end

                    if isElementStreamedIn(source) and vehicleSirenCache[source] then 
                        processVehicleSiren(source, false)
                    end
                end

                if data.activeItemLights then 
                    if vehicleSirenCache[source] then 
                        if isElement(vehicleSirenCache[source].markerElement) and not vehicleSirenCache[source].active then 
                            if not vehicleSirenCache[source].startTick then 
                                vehicleSirenCache[source].startTick = getTickCount()
                            end

                            local r, g, b = getMarkerColor(vehicleSirenCache[source].markerElement)
        
                            vehicleSirenCache[source].active = true
                            setMarkerColor(vehicleSirenCache[source].markerElement, r, g, b, 255)
                        end
                    end
                else
                    if data.activeByItem and oldValue.activeItemLights ~= data.activeItemLights and vehicleSirenCache[source] then 
                        if isElement(vehicleSirenCache[source].markerElement) then 
                            local r, g, b = getMarkerColor(vehicleSirenCache[source].markerElement)
        
                            vehicleSirenCache[source].active = false
                            setMarkerColor(vehicleSirenCache[source].markerElement, r, g, b, 0)
                        end
                    end
                end

                if occupiedVehicle == source then 
                    occupiedVehicleData = data
                end
            end
        end
    end
)

function processVehicleSiren(vehicle, state)
    if isElement(vehicle) then 
        if state then 
            if vehicleSirenPositions[vehicle.model] then
                local sirenData = getSirenData(vehicle)

                local objectElement = Object(2037, vehicle.position)
                objectElement.interior = vehicle.interior
                objectElement.dimension = vehicle.dimension
                objectElement:attach(vehicle, unpack(vehicleSirenPositions[vehicle.model]))

                local markerElement = Marker(vehicle.position, "corona", 0.4, 0, 0, 255)
                markerElement.interior = vehicle.interior
                markerElement.dimension = vehicle.dimension
                markerElement:attach(vehicle, unpack(vehicleSirenPositions[vehicle.model]))

                vehicleSirenCache[vehicle] = {objectElement = objectElement, markerElement = markerElement, state = "start", startTick = false, active = sirenData.activeItemLights}

                if vehicleSirenCache[vehicle].active then 
                    vehicleSirenCache[vehicle].startTick = getTickCount()
                else
                    local r, g, b = getMarkerColor(markerElement)

                    setMarkerColor(markerElement, r, g, b, 0)
                end
            end
        else
            if vehicleSirenCache[vehicle] then 
                if isElement(vehicleSirenCache[vehicle].objectElement) then 
                    vehicleSirenCache[vehicle].objectElement:destroy()
                end

                if isElement(vehicleSirenCache[vehicle].markerElement) then 
                    vehicleSirenCache[vehicle].markerElement:destroy()
                end

                vehicleSirenCache[vehicle] = nil
            end
        end
    end
end

function renderVehicleSirens()
    local nowTick = getTickCount()

    for k, v in pairs(vehicleSirenCache) do 
        if isElement(k) then 
            if isElement(v.markerElement) and v.active then 
                if v.state == "start" then 
                    local elapsedTime = nowTick - v.startTick
                    local duration = 250
                    local progress = elapsedTime / duration

                    local alpha = interpolateBetween(255, 0, 0, 0, 0, 0, progress, "InOutQuad")

                    local r, g, b = getMarkerColor(v.markerElement)
                    setMarkerColor(v.markerElement, r, g, b, alpha)

                    if progress >= 1 then 
                        vehicleSirenCache[k].state = "stop"
                        vehicleSirenCache[k].startTick = getTickCount()
                    end
                elseif v.state == "stop" then
                    local elapsedTime = nowTick - v.startTick
                    local duration = 250
                    local progress = elapsedTime / duration

                    local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, progress, "InOutQuad")

                    local r, g, b = getMarkerColor(v.markerElement)
                    setMarkerColor(v.markerElement, r, g, b, alpha)

                    if progress >= 1 then 
                        vehicleSirenCache[k].state = "start"
                        vehicleSirenCache[k].startTick = getTickCount()
                    end
                end
            end
        end
    end
end
createRender("renderVehicleSirens", renderVehicleSirens)

function processSirenPanel(state)
    if state == "init" then 
        exports['cr_interface']:setNode('sirenPanel', 'active', true)

        local vehicle = localPlayer.vehicle
        local data = getSirenData(vehicle)

        occupiedVehicle = vehicle
        occupiedVehicleData = data

        createRender("renderSirenPanel", renderSirenPanel)

        removeEventHandler("onClientKey", root, onKey)
        addEventHandler("onClientKey", root, onKey)

        exports["cr_dx"]:startFade("sirenPanel", 
            {
                ["startTick"] = getTickCount(),
                ["lastUpdateTick"] = getTickCount(),
                ["time"] = 250,
                ["animation"] = "InOutQuad",
                ["from"] = 0,
                ["to"] = 255,
                ["alpha"] = 0,
                ["progress"] = 0,
            }
        )
    elseif state == "exit" then 
        exports['cr_interface']:setNode('sirenPanel', 'active', false)

        removeEventHandler("onClientKey", root, onKey)

        exports["cr_dx"]:startFade("sirenPanel", 
            {
                ["startTick"] = getTickCount(),
                ["lastUpdateTick"] = getTickCount(),
                ["time"] = 250,
                ["animation"] = "InOutQuad",
                ["from"] = 255,
                ["to"] = 0,
                ["alpha"] = 255,
                ["progress"] = 0,
            }
        )
    end
end

function processStrobe()
    if checkRender("renderSirenPanel") then 
        if not isCursorShowing() and occupiedVehicle then 
            local vehicle = localPlayer.vehicle

            if vehicle then 
                local data = getSirenData(vehicle)

                data["strobe"] = not data["strobe"]
                vehicle:setData("veh >> sirenData", data)
            end
        end
    end
end
bindKey("p", "down", processStrobe)

function processQuickSiren()
    if checkRender("renderSirenPanel") then 
        if occupiedVehicle then 
            if emergencyVehicles[occupiedVehicle.model] then 
                local seat = localPlayer.vehicleSeat

                if seat == 0 or seat == 1 then 
                    if lastInteractionTick + interactionTimeDelay > getTickCount() then 
                        local syntax = exports.cr_core:getServerSyntax("Siren", "error")
                        outputChatBox(syntax .. "Ilyen gyorsan nem végezhetsz interakciót!", 255, 0, 0, true)
                        
                        return
                    end

                    manageSirenFunctions("lights", 1)
                    lastInteractionTick = getTickCount()
                end
            else
                local sirenData = getSirenData(occupiedVehicle)

                if sirenData and sirenData.activeByItem then 
                    if lastInteractionTick + interactionTimeDelay > getTickCount() then 
                        local syntax = exports.cr_core:getServerSyntax("Siren", "error")
                        outputChatBox(syntax .. "Ilyen gyorsan nem végezhetsz interakciót!", 255, 0, 0, true)
                        
                        return
                    end

                    manageSirenFunctions("itemLights")
                    lastInteractionTick = getTickCount()
                end
            end
        end
    end
end
bindKey("h", "down", processQuickSiren)

function toggleSirenCommand(cmd, id)
    if localPlayer:getData("loggedIn") then 
        if not checkRender("renderSirenPanel") then 
            return
        end

        local vehicle = localPlayer.vehicle

        if not vehicle then 
            return
        end

        if not emergencyVehicles[vehicle.model] then 
            return
        end

        if not id or tonumber(id) < 3 or tonumber(id) > 4 then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")

            outputChatBox(syntax .. "/" .. cmd .. " [id]", 255, 0, 0, true)
            return
        end

        if lastInteractionTick + interactionTimeDelay > getTickCount() then 
            local syntax = exports.cr_core:getServerSyntax("Siren", "error")
            outputChatBox(syntax .. "Ilyen gyorsan nem végezhetsz interakciót!", 255, 0, 0, true)
            
            return
        end
        
        id = tonumber(id)
        manageSirenFunctions("sound", id)

        lastInteractionTick = getTickCount()
    end
end
addCommandHandler("togglesiren", toggleSirenCommand, false, false)

addEventHandler("onClientVehicleEnter", root,
    function(thePlayer, seat)
        if thePlayer == localPlayer then 
            if emergencyVehicles[source.model] or source:getData("veh >> sirenData") and source:getData("veh >> sirenData").activeByItem then 
                if not checkRender("renderSirenPanel") then 
                    if seat == 0 or seat == 1 then 
                        processSirenPanel("init")
                    end
                end
            end
        end
    end
)

addEventHandler("onClientVehicleExit", root,
    function(thePlayer, seat)
        if thePlayer == localPlayer then 
            if checkRender("renderSirenPanel") then 
                processSirenPanel("exit")
            end
        end
    end
)

addEventHandler("onClientPlayerWasted", localPlayer,
    function()
        if checkRender("renderSirenPanel") then 
            processSirenPanel("exit")
        end
    end
)

addEventHandler("onClientElementDestroy", root,
    function()
        if source.type == "vehicle" then 
            if localPlayer:isInVehicle() then 
                if localPlayer.vehicle == source then 
                    if checkRender("renderSirenPanel") then 
                        processSirenPanel("exit")
                    end
                end
            end

            if isElement(soundElements[source]) then 
                soundElements[source]:destroy()
                soundElements[source] = nil
            end

            if vehicleLightDatas[source] then 
                vehicleLightDatas[source] = nil
            end

            if isTimer(vehicleLightTimers[source]) then 
                killTimer(vehicleLightTimers[source])
                vehicleLightTimers[source] = nil
            end

            if vehicleSirenCache[source] then 
                if isElement(vehicleSirenCache[source].objectElement) then 
                    vehicleSirenCache[source].objectElement:destroy()
                    vehicleSirenCache[source].objectElement = nil
                end

                if isElement(vehicleSirenCache[source].markerElement) then 
                    vehicleSirenCache[source].markerElement:destroy()
                    vehicleSirenCache[source].markerElement = nil
                end

                vehicleSirenCache[source] = nil
            end

            if activeVehicle == source then 
                exports.cr_inventory:findAndUseItemByIDAndDBID(37, activeVehicleDbId)

                activeVehicle = false
                activeVehicleDbId = false
            end

            collectgarbage("collect")
        end
    end
)

addEvent("siren >> toggleSound", true)
addEventHandler("siren >> toggleSound", root,
    function(id, vehicle)
        if vehicle then 
            if id then 
                local sirenData = getSirenData(vehicle)

                if emergencyVehicles[vehicle.model] or sirenData.activeByItem then 
                    if isElement(soundElements[vehicle]) then 
                        soundElements[vehicle]:destroy()
                        soundElements[vehicle] = nil
                    end

                    local soundPath = sirenTypes[id]["soundPath"]
                    local soundMaxDistance = sirenTypes[id]["sirenMaxDistance"]
                    local needLoop = true

                    if vehicle.model == 416 and id >= 3 then 
                        soundPath = "files/sounds/3.wav"
                    end

                    if sirenTypes[id]["name"] == "Kürt" then 
                        needLoop = false

                        setTimer(
                            function(element, sirenId)
                                local data = getSirenData(element)

                                if data["soundId"] == sirenId then 
                                    data["soundId"] = false
                                    data["activeSiren"] = false
                                end

                                element:setData("veh >> sirenData", data)

                                if element == occupiedVehicle then 
                                    occupiedVehicleData = data
                                end
                            end, 1000, 1, vehicle, id
                        )
                    end

                    if soundPath then 
                        soundElements[vehicle] = Sound3D(soundPath, vehicle.position, needLoop)
                        soundElements[vehicle]:setMaxDistance(soundMaxDistance)
                        soundElements[vehicle]:attach(vehicle)

                        soundElements[vehicle].interior = vehicle.interior
                        soundElements[vehicle].dimension = vehicle.dimension
                    end
                end
            else
                if isElement(soundElements[vehicle]) then 
                    soundElements[vehicle]:destroy()
                    soundElements[vehicle] = nil
                end
            end
        end
    end
)

function createSirenObject(vehicle, dbId)
    if isElement(vehicle) then 
        if activeVehicle and activeVehicle ~= vehicle then 
            return false
        end

        if not vehicleSirenPositions[vehicle.model] then 
            local syntax = exports.cr_core:getServerSyntax("Siren", "error")

            outputChatBox(syntax .. "Erre a járműre nem elérhető a villogó.", 255, 0, 0, true)
            return false
        end

        activeVehicle = vehicle
        activeVehicleDbId = dbId

        local sirenData = getSirenData(vehicle)
        sirenData.activeByItem = not sirenData.activeByItem
        sirenData.activeItemLights = sirenData.activeByItem

        vehicle:setData("veh >> sirenData", sirenData)

        if not sirenData.activeByItem then 
            activeVehicle = false
        end

        return sirenData.activeByItem and "active" or "inactive"
    end

    return false
end