local screenX, screenY = guiGetScreenSize()

local objectCheckTimer = false
local renderTargetSize = 128

local fuelCache = {}
local activeFuelStations = {}
local activeVehicles = {}

availableStations = {}
fuelPrices = {}

local fuelPedCache = {}

local havePistol = false
local circleTexture = false
local currentVehicle = false

currentFuelPed = false
currentColshape = false

local pistolRequestTick = 0
local fuelSpeed = 0.8
local lastFuelTick = 0

function onClick(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
    if button == "left" and state == "down" then 
        if isElement(clickedElement) and clickedElement:getData("fuel >> stationId") and not localPlayer:getData("pistolHolder") then 
            local stationId = clickedElement:getData("fuel >> stationId")
            local positionId = clickedElement:getData("fuel >> positionId")
            local fuelType = clickedElement:getData("fuel >> fuelType")

            if availableStations[stationId] and availableStations[stationId].fuelData then 
                local fuelPos = availableStations[stationId].fuelData[positionId]
                
                if fuelPos.fillingStarted or isTimer(fuelPos.fuelStartTimer) then 
                    return
                end

                if fuelPos.lastFuelType and fuelPos.lastFuelType ~= fuelTypes[fuelType].id then 
                    local syntax = exports.cr_core:getServerSyntax("Fuel", "error")

                    outputChatBox(syntax .. "Előbb fizesd ki, amit eddig tankoltál!", 255, 0, 0, true)
                    return
                end

                local lineStartX, lineStartY, lineStartZ = fuelPos.lineStart[fuelType][1], fuelPos.lineStart[fuelType][2], fuelPos.lineStart[fuelType][3]

                if getDistanceBetweenPoints3D(localPlayer.position, lineStartX, lineStartY, lineStartZ) <= 3.5 and pistolRequestTick + 1000 < getTickCount() then 
                    if fuelPos then 
                        localPlayer:setData("pistolHolder", {stationId, positionId, fuelType})
                        pistolRequestTick = getTickCount()
                    end
                end
            end
        elseif isElement(clickedElement) and clickedElement:getData("fuel >> id") and localPlayer:getData("pistolHolder") then
            if getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position) <= 3 then  
                localPlayer:setData("pistolHolder", nil)
            end
        elseif isElement(clickedElement) and clickedElement.type == "ped" and clickedElement:getData("fuel >> pedId") and (localPlayer:getData("fuel >> pistolHolder") or localPlayer:getData("fuel >> fuelingWithoutVehicle")) then
            if getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position) <= 3 then 
                if not currentFuelPed then 
                    currentFuelPed = clickedElement

                    local fuelStation = localPlayer:getData("fuelStation")
                    local fueledVehicle = localPlayer:getData("fuel >> fuelingVehicle")

                    if isElement(fueledVehicle) then 
                        createFinishPage(
                            {
                                fuelType = localPlayer:getData("fuel >> fuelType"),
                                fuelPrice = fueledVehicle:getData("fuel >> currentFuelPrice"),
                                fueledLiters = fueledVehicle:getData("fuel >> currentLiters"),
                                location = "Texaco - " .. getZoneName(clickedElement.position)
                            }
                        )
                    else
                        local stationId = fuelStation[1]
                        local positionId = fuelStation[2]
                        local fuelType = fuelStation[3]

                        if availableStations[stationId] then 
                            local fuelPos = availableStations[stationId].fuelData[positionId]

                            if fuelPos then 
                                createFinishPage(
                                    {
                                        fuelType = fuelTypes[fuelType],
                                        fuelPrice = fuelPos.currentFuelPrice,
                                        fueledLiters = fuelPos.currentLiters,
                                        location = "Texaco - " .. getZoneName(clickedElement.position)
                                    }
                                )
                            end
                        end
                    end
                end
            end
        end
    end
end
addEventHandler("onClientClick", root, onClick)

function onKey(button, state)
    if button == "mouse1" then 
        if state then 
            if localPlayer:getData("pistolHolder") then 
                cancelEvent()

                if isCursorShowing() then 
                    return
                end

                if lastFuelTick + 2400 > getTickCount() then 
                    return
                end

                local fuelData = localPlayer:getData("pistolHolder")
                local stationId = fuelData[1]
                local positionId = fuelData[2]
                local fuelType = fuelData[3]

                if availableStations[stationId] then 
                    local fuelPos = availableStations[stationId].fuelData[positionId]

                    if fuelPos then 
                        if not fuelPos.fillingStarted and not isTimer(fuelPos.fuelStartTimer) then 
                            if isElement(currentVehicle) then 
                                if currentVehicle:getData("veh >> engine") then 
                                    local syntax = exports.cr_core:getServerSyntax("Fuel", "error")

                                    outputChatBox(syntax .. "Járó motorral nem tankolhatsz.", 255, 0, 0, true)
                                    return
                                end

                                local vehicleMaxFuelTank = exports.cr_vehicle:getVehicleMaxFuel(currentVehicle.model)
                                local currentVehicleFuel = currentVehicle:getData("veh >> fuel") or 0
                                local alreadyFueled = fuelPos.currentLiters or 0

                                if currentVehicleFuel + alreadyFueled >= vehicleMaxFuelTank then 
                                    return
                                end

                                localPlayer:setData("fillingStarted", {stationId, positionId, fuelType, currentVehicle})
                            else
                                localPlayer:setData("fillingStarted", {stationId, positionId, fuelType, currentVehicle})
                            end
                        end
                    end
                end

                lastFuelTick = getTickCount()
            end
        else 
            if localPlayer:getData("fillingStarted") then 
                cancelEvent()

                local fuelData = localPlayer:getData("fillingStarted")
                local stationId = fuelData[1]
                local positionId = fuelData[2]
                local fuelType = fuelData[3]

                if availableStations[stationId] then 
                    local fuelPos = availableStations[stationId].fuelData[positionId]

                    if fuelPos then
                        if fuelPos.fillingStarted or isTimer(fuelPos.fuelStartTimer) then
                            localPlayer:setData("fillingStarted", nil)
                        end
                    end
                end
            end
        end
    end
end
addEventHandler("onClientKey", root, onKey)

function onClientStart()
    if isTimer(objectCheckTimer) then 
        killTimer(objectCheckTimer)
        objectCheckTimer = nil
    end

    objectCheckTimer = setTimer(checkObjectRender, 50, 0)

    local includeColshape = false

    if localPlayer:getData("loggedIn") then 
        includeColshape = true
    end

    setTimer(triggerServerEvent, 500, 1, "fuel.requestFuelPumps", localPlayer, false, true, includeColshape)
    -- setTimer(triggerServerEvent, 500, 1, "fuel.requestFuelPeds", localPlayer, false)

    circleTexture = dxCreateTexture("files/images/materialCircle.png", "argb")
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

function checkObjectRender()
    activeFuelStations = {}
    activeVehicles = {}

    local cameraX, cameraY, cameraZ = getCameraMatrix()
    local streamedVehicles = getElementsByType("vehicle", root, true)

    for k, v in pairs(fuelCache) do 
        if isElement(k) and isElementStreamedIn(k) then 
            local stationX, stationY, stationZ = getElementPosition(k)
            local distance = math.sqrt((cameraX - stationX) ^ 2 + (cameraY - stationY) ^ 2 + (cameraZ - stationZ) ^ 2)

            if distance <= maxDistance then 
                local id = k:getData("fuel >> id")

                table.insert(activeFuelStations, id)

                for i = 1, #streamedVehicles do 
                    local v2 = streamedVehicles[i]
                    local vehicleType = getVehicleType(v2)

                    if isElement(v2) and vehicleType ~= "BMX" then 
                        local vehicleX, vehicleY, vehicleZ = getElementPosition(v2)
                        local vehDistance = getDistanceBetweenPoints3D(stationX, stationY, stationZ, vehicleX, vehicleY, vehicleZ)

                        if vehDistance <= maxDistance then 
                            table.insert(activeVehicles, {
                                element = v2,
                                vehicleType = vehicleType,
                                active = false
                            })
                        end
                    end
                end
            end
        end
    end
end

function loadFuelPoint(id, value)
    if not availableStations[id] then 
        availableStations[id] = {fuelData = {}}
    end

    local x, y, z = unpack(value.position)
    local _, _, rot = unpack(value.rotation)

    local createdBy = value.createdBy
    local createdAt = value.createdAt

    local interior, dimension = value.interior, value.dimension
    local data = {}

    data.fuelElement = Object(fuelObjectId, x, y, z, 0, 0, 0 + rot)

    data.fuelElement.interior = interior
    data.fuelElement.dimension = dimension
    -- data.fuelElement.collisions = false
    -- object.alpha = 0

    data.fuelElement:setData("fuel >> id", id)
    data.fuelElement:setData("fuel >> createdBy", createdBy)
    data.fuelElement:setData("fuel >> createdAt", createdAt)

    fuelCache[data.fuelElement] = id

    local x2, y2 = 0, 0
    
    -- 1. Oldal

    data.drawPosition = {x2 + 0.05, y2 + 0.53, z - 0.11, -1, 90, 0.25}

    local rotatedX, rotatedY = rotateAround(rot, data.drawPosition[1], data.drawPosition[2])
    data.drawPosition[1], data.drawPosition[2] = rotatedX + x, rotatedY + y

    rotatedX, rotatedY = rotateAround(rot, data.drawPosition[4], data.drawPosition[5])
    data.drawPosition[4], data.drawPosition[5] = rotatedX, rotatedY

    data.pistolDetails = {
        {fuelPistolObjectId, x2 + -0.64, y2 + 0.75, z - 0.895, 0, -30, -90 + rot},
        {fuelPistolObjectId, x2 + -0.90, y2 + 0.75, z - 0.895, 0, -30, -90 + rot},
        {fuelPistolObjectId, x2 + -1.17, y2 + 0.75, z - 0.895, 0, -30, -90 + rot},
        {fuelPistolObjectId, x2 + -1.44, y2 + 0.75, z - 0.895, 0, -30, -90 + rot},
    }

    data.lineStart = {
        {x2 + -1.64, y2 + 0.75, z - 0.895},
        {x2 + -1.84, y2 + 0.75, z - 0.895},
        {x2 + -2.84, y2 + 0.75, z - 0.895},
        {x2 + -3.84, y2 + 0.75, z - 0.895},
        -- {x2 + 0.3, y2 + 0.55, z - 1.5},
    }

    data.linePositions = {
        {
            {x2 + -0.64, y2 + 0.77, z - 0.93},
            {x2 + -0.64, y2 + 0.8, z - 1.2},
            {x2 + -0.64, y2 + 0.55, z - 1.75},
            {x2 + -0.64, y2 + 0.3, z - 1.75},
        },

        {
            {x2 + -0.90, y2 + 0.77, z - 0.93},
            {x2 + -0.90, y2 + 0.8, z - 1.2},
            {x2 + -0.90, y2 + 0.55, z - 1.75},
            {x2 + -0.90, y2 + 0.3, z - 1.75},
        },

        {
            {x2 + -1.17, y2 + 0.77, z - 0.93},
            {x2 + -1.17, y2 + 0.8, z - 1.2},
            {x2 + -1.17, y2 + 0.55, z - 1.75},
            {x2 + -1.17, y2 + 0.3, z - 1.75},
        },

        {
            {x2 + -1.44, y2 + 0.77, z - 0.93},
            {x2 + -1.44, y2 + 0.8, z - 1.2},
            {x2 + -1.44, y2 + 0.55, z - 1.75},
            {x2 + -1.44, y2 + 0.3, z - 1.75},
        }
    }

    data.lineGrabbingPositions = {
        {
            {x2 + -0.64, y2 + 0.5, z - 1.75},
            {x2 + -0.64, y2 + 0.8, z - 1.75},
            {x2 + -0.64, y2 + 0.55, z - 1.75},
            {x2 + -0.64, y2 + 0.3, z - 1.75},
        },

        {
            {x2 + -0.90, y2 + 0.5, z - 1.75},
            {x2 + -0.90, y2 + 0.8, z - 1.75},
            {x2 + -0.90, y2 + 0.55, z - 1.75},
            {x2 + -0.90, y2 + 0.3, z - 1.75},
        },

        {
            {x2 + -1.17, y2 + 0.5, z - 1.75},
            {x2 + -1.17, y2 + 0.8, z - 1.75},
            {x2 + -1.17, y2 + 0.55, z - 1.75},
            {x2 + -1.17, y2 + 0.3, z - 1.75},
        },

        {
            {x2 + -1.44, y2 + 0.5, z - 1.75},
            {x2 + -1.44, y2 + 0.8, z - 1.75},
            {x2 + -1.44, y2 + 0.55, z - 1.75},
            {x2 + -1.44, y2 + 0.3, z - 1.75},
        }
    }

    for i = 1, #data.pistolDetails do
        rotatedX, rotatedY = rotateAround(rot, data.pistolDetails[i][2], data.pistolDetails[i][3])
        data.pistolDetails[i][2], data.pistolDetails[i][3] = rotatedX + x, rotatedY + y
    end

    for i = 1, #data.lineStart do
        rotatedX, rotatedY = rotateAround(rot, data.lineStart[i][1], data.lineStart[i][2])
        data.lineStart[i][1], data.lineStart[i][2] = rotatedX + x, rotatedY + y

        if data.linePositions[i] then
            for j = 1, #data.linePositions[i] do
                rotatedX, rotatedY = rotateAround(rot, data.linePositions[i][j][1], data.linePositions[i][j][2])
                data.linePositions[i][j][1], data.linePositions[i][j][2] = rotatedX + x, rotatedY + y
            end

            data.linePositions[i] = createSpline(data.linePositions[i])
        end

        if data.lineGrabbingPositions[i] then
            for j = 1, #data.lineGrabbingPositions[i] do
                rotatedX, rotatedY = rotateAround(rot, data.lineGrabbingPositions[i][j][1], data.lineGrabbingPositions[i][j][2])
                data.lineGrabbingPositions[i][j][1], data.lineGrabbingPositions[i][j][2] = rotatedX + x, rotatedY + y
            end

            data.lineGrabbingPositions[i] = createSpline(data.lineGrabbingPositions[i])
        end
    end

    data.pistolObjects = {}
    data.pistolHolder = {}

    data.currentFuelPrice = 0
    data.currentLiters = 0

    for i = 1, #data.pistolDetails do
        data.pistolObjects[i] = createObject(unpack(data.pistolDetails[i]))

        data.pistolObjects[i]:setData("fuel >> stationId", id)
        data.pistolObjects[i]:setData("fuel >> positionId", 1)
        data.pistolObjects[i]:setData("fuel >> fuelType", availableFuelTypes[i])
    end

    if currentColshape then 
        if isElementWithinColShape(localPlayer, currentColshape) then 
            data.renderTarget = dxCreateRenderTarget(renderTargetSize, renderTargetSize, true)
        end
    end

    table.insert(availableStations[id].fuelData, data)

    -- 2. Oldal

    data = {}

    data.drawPosition = {x2 + -0.25, y2 - 0.485, z - 0.11, 1, -90, 0.5}

    local rotatedX, rotatedY = rotateAround(rot, data.drawPosition[1], data.drawPosition[2])
    data.drawPosition[1], data.drawPosition[2] = rotatedX + x, rotatedY + y

    rotatedX, rotatedY = rotateAround(rot, data.drawPosition[4], data.drawPosition[5])
    data.drawPosition[4], data.drawPosition[5] = rotatedX, rotatedY

    data.pistolDetails = {
        {fuelPistolObjectId, x2 - 0.4 - 0.23, y2 + -0.71, z - 0.895, 0, -30, 90 + rot},
        {fuelPistolObjectId, x2 - 0.4 - 0.50, y2 + -0.71, z - 0.895, 0, -30, 90 + rot},
        {fuelPistolObjectId, x2 - 0.4 - 0.76, y2 + -0.71, z - 0.895, 0, -30, 90 + rot},
        {fuelPistolObjectId, x2 - 0.4 - 1.03, y2 + -0.71, z - 0.895, 0, -30, 90 + rot},
    }

    data.lineStart = {
        {x2 + -1.64, y2 + -0.71, z - 0.895},
        {x2 + -2.64, y2 + -0.71, z - 0.895},
        {x2 + -3.64, y2 + -0.71, z - 0.895},
        {x2 + -4.64, y2 + -0.71, z - 0.895},
        -- {x2 + 0.3, y2 + 0.55, z - 1.5},
    }

    data.linePositions = {
        {
            {x2 + -0.627, y2 + -0.74, z - 0.93},
            {x2 + -0.627, y2 + -0.8, z - 1.2},
            {x2 + -0.627, y2 + -0.55, z - 1.75},
            {x2 + -0.627, y2 + -0.3, z - 1.75},
        },

        {
            {x2 + -0.897, y2 + -0.74, z - 0.93},
            {x2 + -0.897, y2 + -0.8, z - 1.2},
            {x2 + -0.897, y2 + -0.55, z - 1.75},
            {x2 + -0.897, y2 + -0.3, z - 1.75}, 
        },

        {
            {x2 + -1.157, y2 + -0.74, z - 0.93},
            {x2 + -1.157, y2 + -0.8, z - 1.2},
            {x2 + -1.157, y2 + -0.55, z - 1.75},
            {x2 + -1.157, y2 + -0.3, z - 1.75},
        },

        {
            {x2 + -1.427, y2 + -0.74, z - 0.93},
            {x2 + -1.427, y2 + -0.8, z - 1.2},
            {x2 + -1.427, y2 + -0.55, z - 1.75},
            {x2 + -1.427, y2 + -0.3, z - 1.75},
        }
    }

    data.lineGrabbingPositions = {
        {
            {x2 + -0.627, y2 + -0.5, z - 1.75},
            {x2 + -0.627, y2 + -0.8, z - 1.75},
            {x2 + -0.627, y2 + -0.55, z - 1.75},
            {x2 + -0.627, y2 + -0.3, z - 1.75},
        },

        {
            {x2 + -0.897, y2 + -0.5, z - 1.75},
            {x2 + -0.897, y2 + -0.8, z - 1.75},
            {x2 + -0.897, y2 + -0.55, z - 1.75},
            {x2 + -0.897, y2 + -0.3, z - 1.75}, 
        },

        {
            {x2 + -1.157, y2 + -0.5, z - 1.75},
            {x2 + -1.157, y2 + -0.8, z - 1.75},
            {x2 + -1.157, y2 + -0.55, z - 1.75},
            {x2 + -1.157, y2 + -0.3, z - 1.75},
        },

        {
            {x2 + -1.427, y2 + -0.5, z - 1.75},
            {x2 + -1.427, y2 + -0.8, z - 1.75},
            {x2 + -1.427, y2 + -0.55, z - 1.75},
            {x2 + -1.427, y2 + -0.3, z - 1.75},
        }
    }

    for i = 1, #data.pistolDetails do
        rotatedX, rotatedY = rotateAround(rot, data.pistolDetails[i][2], data.pistolDetails[i][3])
        data.pistolDetails[i][2], data.pistolDetails[i][3] = rotatedX + x, rotatedY + y
    end

    for i = 1, #data.lineStart do
        rotatedX, rotatedY = rotateAround(rot, data.lineStart[i][1], data.lineStart[i][2])
        data.lineStart[i][1], data.lineStart[i][2] = rotatedX + x, rotatedY + y

        if data.linePositions[i] then
            for j = 1, #data.linePositions[i] do
                rotatedX, rotatedY = rotateAround(rot, data.linePositions[i][j][1], data.linePositions[i][j][2])
                data.linePositions[i][j][1], data.linePositions[i][j][2] = rotatedX + x, rotatedY + y
            end

            data.linePositions[i] = createSpline(data.linePositions[i])
        end

        if data.lineGrabbingPositions[i] then
            for j = 1, #data.lineGrabbingPositions[i] do
                rotatedX, rotatedY = rotateAround(rot, data.lineGrabbingPositions[i][j][1], data.lineGrabbingPositions[i][j][2])
                data.lineGrabbingPositions[i][j][1], data.lineGrabbingPositions[i][j][2] = rotatedX + x, rotatedY + y
            end

            data.lineGrabbingPositions[i] = createSpline(data.lineGrabbingPositions[i])
        end
    end

    data.pistolObjects = {}
    data.pistolHolder = {}

    data.currentFuelPrice = 0
    data.currentLiters = 0

    for i = 1, #data.pistolDetails do
        data.pistolObjects[i] = createObject(unpack(data.pistolDetails[i]))

        data.pistolObjects[i]:setData("fuel >> stationId", id)
        data.pistolObjects[i]:setData("fuel >> positionId", 2)
        data.pistolObjects[i]:setData("fuel >> fuelType", availableFuelTypes[i])
    end

    if currentColshape then 
        if isElementWithinColShape(localPlayer, currentColshape) then 
            data.renderTarget = dxCreateRenderTarget(renderTargetSize, renderTargetSize, true)
        end
    end

    table.insert(availableStations[id].fuelData, data)
end
addEvent("fuel.loadFuelPoint", true)
addEventHandler("fuel.loadFuelPoint", root, loadFuelPoint)

function requestFuelPumps(tbl, prices, colshape)
    for k, v in pairs(tbl) do 
        loadFuelPoint(k, v)
    end

    if prices then 
        fuelPrices = prices
    end

    if colshape then 
        createRenderTarget(colshape)
    end

    local players = getElementsByType("player")
    for i = 1, #players do 
        local v = players[i]
        local pistolHolder = v:getData("pistolHolder")

        if pistolHolder then 
            local stationId = pistolHolder[1]
			local positionId = pistolHolder[2]
			local fuelType = pistolHolder[3]

            if availableStations[stationId] then 
                local fuelPos = availableStations[stationId].fuelData[positionId]

				if fuelPos then
					fuelPos.pistolHolder[fuelType] = v

					if fuelPos.pistolObjects[fuelType] then
                        setElementCollisionsEnabled(fuelPos.pistolObjects[fuelType], false)
						exports.cr_bone_attach:attachElementToBone(fuelPos.pistolObjects[fuelType], v, 12, 0.05, 0.05, 0.05, 180, 0, 180)
					end

                    if v == localPlayer then 
                        havePistol = pistolHolder

                        exports.cr_controls:toggleControl({"fire", "sprint", "jump"}, false, "high")
                    end
				end
            end
        end
    end
end
addEvent("fuel.requestFuelPumps", true)
addEventHandler("fuel.requestFuelPumps", root, requestFuelPumps)

-- function loadFuelPed(value)
    
-- end

-- function requestFuelPeds(tbl)
--     for k, v in pairs(tbl) do 
--         loadFuelPed(v)
--     end
-- end
-- addEvent("fuel.requestFuelPeds", true)
-- addEventHandler("fuel.requestFuelPeds", root, requestFuelPeds)

function requestFuelPrices(tbl)
    fuelPrices = tbl
end
addEvent("fuel.requestFuelPrices", true)
addEventHandler("fuel.requestFuelPrices", root, requestFuelPrices)

function handleDataChange(dataName, oldValue, newValue)
    if source.type == "player" then 
        if dataName == "pistolHolder" then 
            local pistolHolder = source:getData("pistolHolder")

            if pistolHolder then 
                local stationId = pistolHolder[1]
                local positionId = pistolHolder[2]
                local fuelType = pistolHolder[3]

                if availableStations[stationId] then 
                    local fuelPos = availableStations[stationId].fuelData[positionId]

                    if fuelPos then 
                        fuelPos.pistolHolder[fuelType] = source

                        if fuelPos.pistolObjects[fuelType] then 
                            setElementCollisionsEnabled(fuelPos.pistolObjects[fuelType], false)
                            exports.cr_bone_attach:attachElementToBone(fuelPos.pistolObjects[fuelType], source, 12, 0.05, 0.05, 0.05, 180, 0, 180)
                        end

                        if source == localPlayer then 
                            havePistol = pistolHolder

                            exports.cr_controls:toggleControl({"fire", "sprint", "jump"}, false, "high")
                        end
                    end
                end
            elseif oldValue then
                local stationId = oldValue[1]
                local positionId = oldValue[2]
                local fuelType = oldValue[3]

                if availableStations[stationId] then 
                    local fuelPos = availableStations[stationId].fuelData[positionId]

                    if fuelPos then 
                        fuelPos.pistolHolder[fuelType] = {}

                        if fuelPos.pistolObjects[fuelType] then 
                            exports.cr_bone_attach:detachElementFromBone(fuelPos.pistolObjects[fuelType])
                            setElementCollisionsEnabled(fuelPos.pistolObjects[fuelType], false)

                            setTimer(
                                function(fuelType)
                                    setElementCollisionsEnabled(fuelPos.pistolObjects[fuelType], true)

                                    setElementPosition(fuelPos.pistolObjects[fuelType], fuelPos.pistolDetails[fuelType][2], fuelPos.pistolDetails[fuelType][3], fuelPos.pistolDetails[fuelType][4])
                                    setElementRotation(fuelPos.pistolObjects[fuelType], fuelPos.pistolDetails[fuelType][5], fuelPos.pistolDetails[fuelType][6], fuelPos.pistolDetails[fuelType][7])
                                end, 250, 1, fuelType
                            )

                            if source == localPlayer then 
                                havePistol = false

                                exports.cr_controls:toggleControl({"fire", "sprint", "jump"}, true, "high")
                            end
                        end
                    end
                end
            end

            if pistolHolder or oldValue then 
                playSound3D("files/sounds/pickup.mp3", source.position)
            end
        elseif dataName == "fillingStarted" then
            if newValue then 
                local fuelData = source:getData(dataName)

                local stationId = fuelData[1]
                local positionId = fuelData[2]
                local fuelType = fuelData[3]
                local currentVehicle = fuelData[4]

                if availableStations[stationId] then 
                    local fuelPos = availableStations[stationId].fuelData[positionId]

                    if fuelPos then 
                        local playerX, playerY, playerZ = getElementPosition(source)

                        if not fuelPos.fillingStarted then 
                            fuelPos.activeFuelType = fuelTypes[fuelType].id
                            fuelPos.currentFuelType = fuelType

                            if isElement(fuelPos.fillingSound) then 
                                destroyElement(fuelPos.fillingSound)
                                fuelPos.fillingSound = nil
                            end

                            fuelPos.fillingSound = playSound3D("files/sounds/fill.mp3", playerX, playerY, playerZ, true)
                            setPedAnimation(source, "SWORD", "sword_IDLE")

                            if not currentVehicle then 
                                fuelPos.fillingStarted = getTickCount()

                                local pistolRotZ = select(3, getElementRotation(fuelPos.pistolObjects[fuelType]))
                                local effectX, effectY, effectZ = getPositionFromElementOffset(fuelPos.pistolObjects[fuelType], 0.45, 0, 0)

                                fuelPos.fuelingEffect = createEffect("petrolcan", effectX, effectY, effectZ, 120, 0, -pistolRotZ + 90)
                                setEffectDensity(fuelPos.fuelingEffect, 2)

                                source:setData("fuel >> fuelingWithoutVehicle", true)
                            else
                                if not currentVehicle:getData("veh >> engine") then 
                                    fuelPos.currentVehicle = currentVehicle
                                    fuelPos.currentVehicleFueledBy = source

                                    fuelPos.currentFuelTank = currentVehicle:getData("veh >> fuel")
                                    fuelPos.vehicleMaxFuelTank = exports.cr_vehicle:getVehicleMaxFuel(currentVehicle.model)

                                    currentVehicle:setData("veh >> fueling", true)
                                    currentVehicle:setData("fuel >> currentFuelPrice", 0)
                                    currentVehicle:setData("fuel >> currentLiters", 0)

                                    source:setData("fuel >> fuelingVehicle", currentVehicle)
                                    source:setData("fuel >> fuelType", fuelTypes[fuelType])
                                    source:setData("fuel >> pistolHolder", source:getData("pistolHolder"))

                                    setPedAnimation(source, "CASINO", "cards_win")

                                    if isElement(fuelPos.fillingSound) then 
                                        destroyElement(fuelPos.fillingSound)
                                        fuelPos.fillingSound = nil
                                    end

                                    playSound3D("files/sounds/start.mp3", playerX, playerY, playerZ)

                                    if isTimer(fuelPos.fuelStartTimer) then 
                                        killTimer(fuelPos.fuelStartTimer)
                                        fuelPos.fuelStartTimer = nil
                                    end

                                    fuelPos.fuelStartTimer = setTimer(
                                        function(playerElement)
                                            if isElement(playerElement) then 
                                                local playerX, playerY, playerZ = getElementPosition(playerElement)

                                                setPedAnimation(playerElement, "SWORD", "sword_IDLE")

                                                if isElement(fuelPos.fillingSound) then 
                                                    destroyElement(fuelPos.fillingSound)
                                                    fuelPos.fillingSound = nil
                                                end

                                                fuelPos.fillingStarted = getTickCount()
                                                fuelPos.fillingSound = playSound3D("files/sounds/fill.mp3", playerX, playerY, playerZ, true)
                                            end
                                        end, 2400, 1, source
                                    )
                                end
                            end

                            source:setData("fuelStation", {stationId, positionId, fuelType})
                        end
                    end
                end
            elseif oldValue then
                local fuelData = oldValue

                local stationId = fuelData[1]
                local positionId = fuelData[2]
                local fuelType = fuelData[3]
                local currentVehicle = fuelData[4]

                if availableStations[stationId] then 
                    local fuelPos = availableStations[stationId].fuelData[positionId]

                    if fuelPos then
                        local playerX, playerY, playerZ = getElementPosition(source)

                        if fuelPos.fillingStarted then 
                            fuelPos.fillingStarted = false
                            fuelPos.lastFuelType = fuelPos.activeFuelType

                            fuelPos.activeFuelType = false
                            fuelPos.currentFuelType = false

                            fuelPos.currentVehicle = false
                            fuelPos.currentVehicleFueledBy = false

                            fuelPos.vehicleMaxFuelTank = false
                            fuelPos.currentFuelTank = false

                            setPedAnimation(source, false)

                            if isElement(fuelPos.fuelingEffect) then 
                                destroyElement(fuelPos.fuelingEffect)
                                fuelPos.fuelingEffect = nil
                            end

                            if isElement(fuelPos.fillingSound) then 
                                destroyElement(fuelPos.fillingSound)
                                fuelPos.fillingSound = nil
                            end
                        end

                        if isTimer(fuelPos.fuelStartTimer) then 
                            killTimer(fuelPos.fuelStartTimer)
                            fuelPos.fuelStartTimer = nil
                        end

                        if currentVehicle then 
                            playSound3D("files/sounds/over.mp3", playerX, playerY, playerZ)
                            setPedAnimation(source, "CASINO", "cards_win")

                            setTimer(setPedAnimation, 2400, 1, source, false)

                            if isElement(currentVehicle) then 
                                currentVehicle:setData("veh >> fueling", nil)
                            end
                        end
                    end
                end
            end
        elseif dataName == "loggedIn" then
            if newValue and source == localPlayer then 
                triggerServerEvent("fuel.requestCurrentColshape", localPlayer)
            end
        end
    end
end
addEventHandler("onClientElementDataChange", root, handleDataChange)

function deleteFuelStation(id)
    if availableStations[id] then 
        local data = availableStations[id].fuelData

        for k, v in ipairs(data) do
            if isElement(v.renderTarget) then 
                destroyElement(v.renderTarget)
                v.renderTarget = nil
            end

            if v.pistolObjects then 
                for k2, v2 in pairs(v.pistolObjects) do 
                    if isElement(v2) then 
                        destroyElement(v2)
                    end
                end

                v.pistolObjects = nil
            end

            if v.fuelElement then 
                fuelCache[v.fuelElement] = nil

                if isElement(v.fuelElement) then 
                    destroyElement(v.fuelElement)

                    v.fuelElement = nil
                end
            end
        end

        availableStations[id] = nil
    end
end
addEvent("fuel.deleteFuelStation", true)
addEventHandler("fuel.deleteFuelStation", root, deleteFuelStation)

function createRenderTarget(sourceElement)
    if isElement(sourceElement) then 
        local elements = getElementsWithinColShape(sourceElement, "object")
        local playerInterior = localPlayer.interior
        local playerDimension = localPlayer.dimension

        if elements and #elements > 0 then 
            currentColshape = sourceElement

            for i = 1, #elements do 
                local v = elements[i]
                local colInterior = getElementInterior(v)
                local colDimension = getElementDimension(v)

                if v:getData("fuel >> stationId") and colInterior == playerInterior and colDimension == playerDimension then 
                    local stationId = v:getData("fuel >> stationId")
                    local positionId = v:getData("fuel >> positionId")
                    local fuelType = v:getData("fuel >> fuelType")

                    if availableStations[stationId] then 
                        local fuelPos = availableStations[stationId].fuelData[positionId]

                        if fuelPos then 
                            if not fuelPos.renderTarget then 
                                fuelPos.renderTarget = dxCreateRenderTarget(renderTargetSize, renderTargetSize, true)
                            end
                        end
                    end
                end
            end
        end
    end
end
addEvent("fuel.requestCurrentColshape", true)
addEventHandler("fuel.requestCurrentColshape", root, createRenderTarget)

function onColShapeHit(hitElement, mDim)
    if source:getData("fuel >> fuelArea") then 
        if hitElement == localPlayer and mDim then 
            createRenderTarget(source)
        end
    end
end
addEventHandler("onClientColShapeHit", root, onColShapeHit)

function onColShapeLeave(hitElement, mDim)
    if source:getData("fuel >> fuelArea") then 
        if hitElement == localPlayer and mDim then 
            local players = getElementsWithinColShape(source, "player")
            local fuelData = localPlayer:getData("fuelStation")

            currentColshape = false

            if fuelData then 
                local stationId = fuelData[1]
                local positionId = fuelData[2]
                local fuelType = fuelData[3]

                if availableStations[stationId] then 
                    local fuelPos = availableStations[stationId].fuelData[positionId]

                    if fuelPos then 
                        local fuelingVehicle = localPlayer:getData("fuel >> fuelingVehicle")

                        if isElement(fuelingVehicle) then 
                            fuelingVehicle:setData("fuel >> currentLiters", nil)
                            fuelingVehicle:setData("fuel >> currentFuelPrice", nil)
                            localPlayer:setData("fuel >> fuelingVehicle", nil)
                            localPlayer:setData("fuel >> pistolHolder", nil)
                            localPlayer:setData("fuel >> fuelType", nil)
                        else 
                            if localPlayer:getData("fuel >> fuelingWithoutVehicle") then 
                                localPlayer:setData("fuel >> fuelingWithoutVehicle", nil)
                            end
                        end

                        triggerLatentServerEvent("fuel.resetFuelDataForStation", 5000, false, localPlayer, stationId, positionId, players, "price")
                    end
                end
            end
        end
    end
end
addEventHandler("onClientColShapeLeave", root, onColShapeLeave)

function onStreamOut()
    if source:getData("fuel >> stationId") then 
        local stationId = source:getData("fuel >> stationId")
        local positionId = source:getData("fuel >> positionId")

        if availableStations[stationId] then 
            local fuelPos = availableStations[stationId].fuelData[positionId]

            if fuelPos then 
                if isElement(fuelPos.renderTarget) then 
                    destroyElement(fuelPos.renderTarget)
                    fuelPos.renderTarget = false
                end
            end
        end
    end
end
addEventHandler("onClientElementStreamOut", root, onStreamOut)

function resetFuelDataForStation(stationId, positionId, typ)
    if stationId and positionId then 
        if availableStations[stationId] then 
            local fuelPos = availableStations[stationId].fuelData[positionId]

            if fuelPos then 
                if typ == "price" then 
                    fuelPos.currentLiters = 0
                    fuelPos.currentFuelPrice = 0
                    fuelPos.lastFuelType = false

                    fuelPos.activeFuelType = false
                    fuelPos.currentFuelType = false
                elseif typ == "all" then 
                    fuelPos.currentLiters = 0
                    fuelPos.currentFuelPrice = 0
                    fuelPos.lastFuelType = false

                    fuelPos.activeFuelType = false
                    fuelPos.currentFuelType = false

                    fuelPos.currentVehicle = false
                    fuelPos.currentVehicleFueledBy = false

                    fuelPos.vehicleMaxFuelTank = false
                    fuelPos.currentFuelTank = false
                end
            end
        end
    end
end
addEvent("fuel.resetFuelDataForStation", true)
addEventHandler("fuel.resetFuelDataForStation", root, resetFuelDataForStation)

function onClientQuit()
    local pistolHolder = localPlayer:getData("pistolHolder") or {}

    if pistolHolder and pistolHolder[1] then 
        local stationId = pistolHolder[1]
        local positionId = pistolHolder[2]
        local fuelType = pistolHolder[3]

        if availableStations[stationId] then 
            local fuelPos = availableStations[stationId].fuelData[positionId]

            if fuelPos then 
                fuelPos.pistolHolder[fuelType] = {}

                if fuelPos.pistolObjects[fuelType] then 
                    exports.cr_bone_attach:detachElementFromBone(fuelPos.pistolObjects[fuelType])
                    setElementCollisionsEnabled(fuelPos.pistolObjects[fuelType], false)

                    setTimer(
                        function(fuelType)
                            setElementCollisionsEnabled(fuelPos.pistolObjects[fuelType], true)

                            setElementPosition(fuelPos.pistolObjects[fuelType], fuelPos.pistolDetails[fuelType][2], fuelPos.pistolDetails[fuelType][3], fuelPos.pistolDetails[fuelType][4])
                            setElementRotation(fuelPos.pistolObjects[fuelType], fuelPos.pistolDetails[fuelType][5], fuelPos.pistolDetails[fuelType][6], fuelPos.pistolDetails[fuelType][7])
                        end, 250, 1, fuelType
                    )
                end

                resetFuelDataForStation(stationId, positionId, "all")
            end
        end
    end
end
addEventHandler("onClientPlayerQuit", root, onClientQuit)

function renderPistolLines()
    -- if localPlayer.name ~= "Banana_Joe" then 
    --     return
    -- end

    local font = exports.cr_fonts:getFont("DS-DIGI", 12)
    local nowTick = getTickCount()

    for n = 1, #activeFuelStations do
        local activeStation = activeFuelStations[n]

        if availableStations[activeStation] then 
            local fuelData = availableStations[activeStation].fuelData

            for k = 1, #fuelData do
                local v = fuelData[k]

                if v.pistolObjects and v.lineStart then
                    for i = 1, #v.lineStart do
                        if isElement(v.pistolObjects[i]) then
                            if v.pistolHolder and isElement(v.pistolHolder[i]) and isElementOnScreen(v.pistolHolder[i]) then
                                local pistolPosX, pistolPosY, pistolPosZ = getElementPosition(v.pistolObjects[i])

                                local linePos = v.lineGrabbingPositions[i][1]
                                local offsetX = (pistolPosX - linePos[1]) / 2
                                local offsetY = (pistolPosY - linePos[2]) / 2

                                local splinePositions = {
                                    {linePos[1], linePos[2], linePos[3]},
                                    {linePos[1] + offsetX / 2, linePos[2] + offsetY / 2, linePos[3]},
                                    {pistolPosX - offsetX / 2, pistolPosY - offsetY / 2, pistolPosZ - 0.3},
                                    {pistolPosX, pistolPosY, pistolPosZ}
                                }

                                local pistolSpline = createSpline(splinePositions)

                                for j = 1, #pistolSpline do
                                    local k = j + 1

                                    if pistolSpline[k] then
                                        dxDrawLine3D(pistolSpline[j][1], pistolSpline[j][2], pistolSpline[j][3], pistolSpline[k][1], pistolSpline[k][2], pistolSpline[k][3], tocolor(5, 5, 5), 1.25)
                                    end
                                end
                            elseif v.linePositions and v.linePositions[i] then
                                for j = 1, #v.linePositions[i] do
                                    local k = j + 1

                                    if v.linePositions[i][k] then
                                        dxDrawLine3D(v.linePositions[i][j][1], v.linePositions[i][j][2], v.linePositions[i][j][3], v.linePositions[i][k][1], v.linePositions[i][k][2], v.linePositions[i][k][3], tocolor(5, 5, 5), 1.25)
                                    end
                                end
                            end
                        end
                    end
                end

                if v.renderTarget then 
                    if not v.lastRenderUpdate then 
                        v.lastRenderUpdate = 0
                    end

                    if nowTick - v.lastRenderUpdate >= 1000 then 
                        dxSetRenderTarget(v.renderTarget, true)

                        dxDrawText("$" .. math.ceil(math.floor(v.currentFuelPrice * 10) / 10), 0, 0, renderTargetSize, 36, tocolor(200, 200, 200, 200), 1, font, "right", "center")
                        dxDrawText(math.floor(v.currentLiters * 10) / 10 .. " L", 0, 52, renderTargetSize, 42 + 30, tocolor(200, 200, 200, 200), 1, font, "right", "center")

                        dxSetRenderTarget()
                        
                        v.lastRenderUpdate = getTickCount()
                    end

                    if v.drawPosition then
                        dxDrawMaterialLine3D(v.drawPosition[1], v.drawPosition[2], v.drawPosition[3] + 0.5, v.drawPosition[1], v.drawPosition[2], v.drawPosition[3], v.renderTarget, 0.725, -1, v.drawPosition[1] + v.drawPosition[4], v.drawPosition[2] + v.drawPosition[5], v.drawPosition[3] + v.drawPosition[6])
                    end
                end

                if v.fuelingEffect then 
                    local currentFuelType = v.currentFuelType

                    if isElement(v.pistolObjects[currentFuelType]) and isElement(v.pistolHolder[currentFuelType]) then 
                        local pistolRotZ = select(3, getElementRotation(v.pistolObjects[currentFuelType]))
                        local effectX, effectY, effectZ = getPositionFromElementOffset(v.pistolObjects[currentFuelType], 0.45, 0, 0)

                        setElementPosition(v.fuelingEffect, effectX, effectY, effectZ)
                        setElementRotation(v.fuelingEffect, 120, 0, -pistolRotZ + 90)
                    end
                end

                if v.fillingStarted then 
                    if nowTick - v.fillingStarted >= 250 then 
                        local fuelPrice = fuelPrices[v.activeFuelType] or 1
                        local elapsedTime = nowTick - v.fillingStarted
                        local amount = fuelSpeed / 1000 * elapsedTime

                        v.fillingStarted = getTickCount()
                        v.currentFuelPrice = v.currentFuelPrice + amount * fuelPrice
                        v.currentLiters = v.currentLiters + amount

                        if isElement(v.currentVehicle) then 
                            v.currentVehicle:setData("fuel >> currentFuelPrice", v.currentFuelPrice)
                            v.currentVehicle:setData("fuel >> currentLiters", v.currentLiters)
                        end

                        if v.currentFuelTank then 
                            if v.currentFuelTank + v.currentLiters >= v.vehicleMaxFuelTank then 
                                localPlayer:setData("fillingStarted", nil)

                                return
                            end
                        end
                    end
                end
            end
        end
    end

    local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
    local playerRotZ = select(3, getElementRotation(localPlayer))
    local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)
    local redR, redG, redB = exports.cr_core:getServerColor("red", false)

    if havePistol then 
        local stationId = havePistol[1]
        local positionId = havePistol[2]
        local fuelType = havePistol[3]
        local activeVehicle = havePistol[4]

        if availableStations[stationId] then 
            local fuelPos = availableStations[stationId].fuelData[positionId]

            if fuelPos then 
                local playerX, playerY, playerZ = getElementPosition(localPlayer)
                local lineStartX, lineStartY, lineStartZ = fuelPos.lineStart[fuelType][1], fuelPos.lineStart[fuelType][2], fuelPos.lineStart[fuelType][3]

                if getDistanceBetweenPoints3D(playerX, playerY, playerZ, lineStartX, lineStartY, lineStartZ) > 3.5 then 
                    localPlayer:setData("pistolHolder", nil)

                    if localPlayer:getData("fillingStarted") then 
                        localPlayer:setData("fillingStarted", nil)
                    end

                    exports.cr_infobox:addBox("error", "Túl messzire mentél a csővel.")
                    return
                end

                if localPlayer.vehicle then 
                    localPlayer:setData("pistolHolder", nil)

                    if localPlayer:getData("fillingStarted") then 
                        localPlayer:setData("fillingStarted", nil)
                    end

                    exports.cr_infobox:addBox("error", "Kocsiba nem szállhatsz be a csővel.")
                    return
                end 

                if fuelPos.fillingStarted and fuelPos.currentVehicle and fuelPos.currentVehicle ~= currentVehicle then 
                    if fuelPos.currentVehicleFueledBy and fuelPos.currentVehicleFueledBy == localPlayer then 
                        if localPlayer:getData("fillingStarted") then 
                            localPlayer:setData("fillingStarted", nil)
                        end

                        exports.cr_infobox:addBox("error", "A tankolás abbamaradt, mivel elmentél a tanksapkától.")
                        return
                    end
                end
            end
        end

        currentVehicle = nil

        if #activeVehicles > 0 then 
            for i = 1, #activeVehicles do 
                local v = activeVehicles[i]
    
                if v then 
                    local element = v.element

                    local vehicleType = v.vehicleType
                    local componentName = vehicleType == "Bike" and wheelSides.bikes.center or wheelSides.bottomRight

                    local x, y, z = getVehicleComponentPosition(element, componentName, "world")
                    local rot = select(3, getElementRotation(element)) --getVehicleComponentRotation(v, wheelSides.bottomRight, "world")
                    local vehiclePosX, vehiclePosY, vehiclePosZ = getElementPosition(element)
    
                    if x and y and z then 
                        local distance = getDistanceBetweenPoints2D(playerPosX, playerPosY, x, y)
    
                        if distance <= 5 then 
                            local groundPosition = getGroundPosition(x, y, z) + 0.05
                            local x2, y2 = 0, 0
                            local minVehDistance = vehicleType == "Bike" and 1 or 0.75
    
                            if rot then 
                                x2, y2 = rotateAround(rot, 0.7, 0)
                            end
    
                            x = x + x2
                            y = y + y2
    
                            local angle = math.deg(math.atan2(vehiclePosY - playerPosY, vehiclePosX - playerPosX)) + 180 - playerRotZ
    
                            if angle < 0 then 
                                angle = angle + 360
                            end
    
                            if distance <= minVehDistance and angle >= 200 and angle <= 280 then 
                                currentVehicle = element
                                v.active = true
                            end
    
                            if v.active then
                                dxDrawMaterialLine3D(x, y + 0.5, groundPosition, x, y - 0.5, groundPosition, circleTexture, 1, tocolor(greenR, greenG, greenB, 255), x, y, groundPosition + 0.25)
                            else
                                dxDrawMaterialLine3D(x, y + 0.5, groundPosition, x, y - 0.5, groundPosition, circleTexture, 1, tocolor(redR, redG, redB, 200), x, y, groundPosition + 0.25)
                            end
                        end
                    end
                end
            end
        end
    end
end
createRender("renderPistolLines", renderPistolLines)