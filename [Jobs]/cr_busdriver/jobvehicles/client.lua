createdMarkers = {}
createdPeds = {}

local currentRoute = 1
isRouteStarted = false

local currentPed = 0
local currentMarker = false
local payment = 0
local currentPedsAtThisStop = 0

local gameMinimized = false

function onClientMinimize()
    gameMinimized = true
end
addEventHandler("onClientMinimize", root, onClientMinimize)

function onClientRestore()
    gameMinimized = false
end
addEventHandler("onClientRestore", root, onClientRestore)

function createJobMarkers()
    local r, g, b = exports.cr_core:getServerColor("yellow", false)
    local pickupMarker = Marker(jobData.busPickupPoint, "cylinder", 1.5, r, g, b)
    pickupMarker:setData("marker >> customMarker", true)
    pickupMarker:setData("marker >> customIconPath", ":cr_busdriver/assets/images/icon.png")

    local pickupBlip = exports.cr_radar:createStayBlip("Munkajármű felvétele", Blip(jobData.busPickupPoint, 0, 2, 255, 0, 0, 255, 0, 0), 0, "job_vehicle", 24, 24, 255, 255, 255)

    createdMarkers[pickupMarker] = "pickupMarker"
end

function deleteJobMarkers()
    for k, v in pairs(createdMarkers) do 
        if isElement(k) then 
            k:destroy()
        end

        if v == "pickupMarker" then 
            exports.cr_radar:destroyStayBlip("Munkajármű felvétele")
        elseif v == "routeMarker" then 
            exports.cr_radar:destroyStayBlip("Következő megálló")
        end
    end

    createdMarkers = {}

    if localPlayer:getData("char >> jobVehicle") then
        triggerLatentServerEvent("destroyJobVehicle", 5000, false, localPlayer, localPlayer)
    end 

    collectgarbage("collect")
end

function destroyRouteMarkers()
    for k, v in pairs(createdMarkers) do 
        if v == "routeMarker" and isElement(k) then 
            k:destroy()
        end

        exports.cr_radar:destroyStayBlip("Következő megálló")
    end
end

function destroyPeds()
    for k, v in pairs(createdPeds) do 
        if isElement(v) then 
            v:destroy()
        end
    end

    createdPeds = {}

    collectgarbage("collect")
end

function setupRoute()
    local r, g, b = exports.cr_core:getServerColor("blue", false)

    local routeData = jobData.busRoutes[currentRoute]
    local x, y, z = routeData.x, routeData.y, routeData.z
    local routePoint = Vector3(x, y, z)
    local routeMarker = Marker(routePoint, "checkpoint", 1.5, r, g, b)
    local routeBlip = exports.cr_radar:createStayBlip("Következő megálló", Blip(routePoint, 0, 2, 255, 0, 0, 255, 0, 0), 0, "target", 24, 24, r, g, b)
    
    createdMarkers[routeMarker] = "routeMarker"

    math.randomseed(getTickCount())

    local randomPed = math.random(jobData.minPed, jobData.maxPed)
    local randomNationality = math.random(1, 2)
    local randomNem = math.random(1, 2)
    local skins = exports.cr_skinprotection:getAvailableSkins(randomNationality, randomNem)

    local pedNum = 0

    while true do 
        local skinId = skins[math.random(1, #skins)]
        local startPoint = routeData.pedStartPoint
        local rotationPoint = routeData.pedRotation
        local pedOffset = routeData.pedOffset

        local x, y, z = startPoint.x, startPoint.y, startPoint.z
        local pedPoint = Vector3(x, y, z)

        if pedOffset == "right" then 
            pedPoint = Vector3(x + pedNum + 1, y, z)
        elseif pedOffset == "left" then 
            pedPoint = Vector3(x, y + pedNum + 1, z)
        end

        local element = Ped(1, pedPoint)

        if element then 
            element:setData("char >> noDamage", true)
            element:setData("ped >> skin", skinId)

            element.rotation = rotationPoint
            element.frozen = true

            table.insert(createdPeds, element)

            pedNum = pedNum + 1
        end

        if pedNum == randomPed then 
            break
        end
    end
end

function destroyCurrentRoute()
    if currentMarker and createdMarkers[currentMarker] then 
        if createdMarkers[currentMarker] == "routeMarker" and isElement(currentMarker) then 
            currentMarker:destroy()

            exports.cr_radar:destroyStayBlip("Következő megálló")
        end

        createdMarkers[currentMarker] = nil
        currentMarker = false
    end
end

function initBusRoute()
    if not isRouteStarted then 
        isRouteStarted = true

        setupRoute()
    end
end

function genRoute()
    if isRouteStarted then 
        if jobData.busRoutes[currentRoute + 1] then 
            currentRoute = currentRoute + 1

            setupRoute()
        end
    end
end

function handleBusStop()
    local vehicle = localPlayer.vehicle
    local zoneName = getZoneName(localPlayer.position)

    local syntax = exports.cr_core:getServerSyntax("Buszsofőr", "info")
    local hexColor = exports.cr_core:getServerColor("red", true)

    outputChatBox(syntax .. "A jelenlegi megálló: " .. hexColor .. zoneName, 255, 255, 255, true)

    if jobData.busRoutes[currentRoute + 1] then 
        local routeData = jobData.busRoutes[currentRoute + 1]
        local x, y, z = routeData.x, routeData.y, routeData.z
        local routePoint = Vector3(x, y, z)
        local zoneName = getZoneName(routePoint)

        local syntax = exports.cr_core:getServerSyntax("Buszsofőr", "info")
        local hexColor = exports.cr_core:getServerColor("red", true)

        outputChatBox(syntax .. "A következő megálló: " .. hexColor .. zoneName, 255, 255, 255, true)
    end

    currentPedsAtThisStop = #createdPeds

    exports.cr_dx:startProgressBar("busDriver >> progressBar", {
        {"Várd meg, amíg felszállnak az utasok", jobData.pedWaitTime * currentPedsAtThisStop}
    })

    localPlayer:setData('handbrakeDisabled', true)
    vehicle.frozen = true
    exports.cr_controls:toggleControl("enter_exit", false, "high")

    setTimer(
        function()
            currentPed = currentPed + 1

            if createdPeds[currentPed] and isElement(createdPeds[currentPed]) then 
                local salary = math.random(jobData.minPayment, jobData.maxPayment)

                local salaryMultiplier = exports.cr_salary:getMultiplier()

                payment = payment + (salary * salaryMultiplier)
                
                createdPeds[currentPed]:destroy()
                createdPeds[currentPed] = nil
            end
        end, jobData.pedWaitTime, currentPedsAtThisStop
    )
end

function resetVariables(state)
    currentPed = 0
    payment = 0
    currentPedsAtThisStop = 0

    if state then 
        isRouteStarted = false
        currentRoute = 1
    end
end

local lastClickTick = -10000
function payOut()
    if exports.cr_network:getNetworkStatus() then 
        currentRoute = currentRoute - 1

        resetVariables()
        destroyCurrentRoute()
        genRoute()
        return
    end

    local now = getTickCount()
    local a = 10
    if now <= lastClickTick + a * 1000 then
        currentRoute = currentRoute - 1

        resetVariables()
        destroyCurrentRoute()
        genRoute()
        return
    end
    lastClickTick = getTickCount()

    local vehicle = localPlayer.vehicle

    vehicle.frozen = false
    exports.cr_controls:toggleControl("enter_exit", true, "high")

    local syntax = exports.cr_core:getServerSyntax("Buszsofőr", "success")
    local hexColor = exports.cr_core:getServerColor("yellow", true)

    outputChatBox(syntax .. "Összesen felszállt " .. hexColor .. currentPedsAtThisStop .. " db " .. white .. "utas, és kerestél " .. hexColor .. "$" .. payment .. white .. "-t ezen a megállóhelyen.", 255, 255, 255, true)
    exports.cr_core:giveMoney(localPlayer, payment)

    if not jobData.busRoutes[currentRoute + 1] then 
        currentRoute = 0

        local syntax = exports.cr_core:getServerSyntax("Buszsofőr", "info")
        outputChatBox(syntax .. "A jelenlegi járatnak vége, új járat kezdéséhez menj a legelső megállóhoz.", 255, 255, 255, true)
    end

    resetVariables()
    destroyCurrentRoute()
    genRoute()
end

function onProgressBarEnd(id, data)
    if id == "busDriver >> progressBar" then 
        localPlayer:setData('handbrakeDisabled', false)

        if isTimer(payOutTimer) then killTimer(payOutTimer) end
        payOutTimer = setTimer(payOut, 250, 1)
    end
end
addEventHandler("ProgressBarEnd", localPlayer, onProgressBarEnd)

function onClientMarkerHit(hitElement, mDim)
    if hitElement == localPlayer and mDim then 
        if createdMarkers[source] then 
            if createdMarkers[source] == "pickupMarker" then 
                if getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 2.5 then 
                    if localPlayer:getData("char >> jobVehicle") then 
                        exports.cr_jobvehicle:openRequestPanel({
                            type = "destroy",
                            titleText = "Munkajármű leadása",
                            buttonText = "Leadás"
                        })
                    else
                        local position = jobData.vehiclePositions[math.random(1, #jobData.vehiclePositions)]

                        exports.cr_jobvehicle:openRequestPanel({
                            type = "request",
                            titleText = "Munkajármű igénylése",
                            buttonText = "Igénylés",
                            position = position,
                            vehicles = jobData.vehicles,
                            now = 1
                        })
                    end
                end
            elseif createdMarkers[source] == "routeMarker" then 
                local vehicle = localPlayer.vehicle

                if vehicle then 
                    local modelId = vehicle.model

                    if isJobVehicle(modelId) then 
                        if not exports.cr_dx:isProgressBarActive("busDriver >> progressBar") then 
                            if getElementSpeed(vehicle) <= 10 and localPlayer.vehicleSeat == 0 and not gameMinimized then 
                                handleBusStop()
                                currentMarker = source
                            else
                                local syntax = exports.cr_core:getServerSyntax("Buszsofőr", "error")

                                outputChatBox(syntax .. "Túl gyorsan mentél el a megállónál.", 255, 0, 0, true)
                            end
                        end
                    end
                end
            end
        end
    end
end

function onClientMarkerLeave(hitElement, mDim)
    if hitElement == localPlayer and mDim then 
        if createdMarkers[source] then 
            if createdMarkers[source] == "pickupMarker" then 
                exports.cr_jobvehicle:closeRequestPanel()
            end

            currentMarker = false
        end
    end
end