createdMarkers = {}

deliveryPickupMarker = false
isVehicleFilledUp = false

function createJobMarkers()
    local pickupMarker = Marker(jobData.vehiclePickupPoint, "cylinder", 1.5, 255, 235, 59)
    pickupMarker:setData("marker >> customMarker", true)
    pickupMarker:setData("marker >> customIconPath", ":cr_winemaker/assets/images/icon.png")

    local pickupBlip = exports.cr_radar:createStayBlip("Munkajármű felvétele", Blip(jobData.vehiclePickupPoint, 0, 2, 255, 0, 0, 255, 0, 0), 0, "job_vehicle", 24, 24, 255, 255, 255)

    createdMarkers[pickupMarker] = "pickupMarker"
end

function destroyElements()
    for k, v in pairs(createdMarkers) do 
        if isElement(k) then 
            k:destroy()
        end

        if v.index then 
            exports.cr_radar:destroyStayBlip("Áru felvétele #" .. v.index)
        end
    end

    for k, v in pairs(createdPeds) do 
        if isElement(k) then 
            if type(v) ~= "table" then 
                k:destroy()
            end
        end
    end

    exports.cr_radar:destroyStayBlip("Munkajármű felvétele")
end

function startFillingUp()
    local vehicle = localPlayer.vehicle

    exports.cr_dx:startProgressBar("delivery >> fillingUp", {
        {"Várd meg, amíg feltöltik a járművedet áruval.", jobData.fillingUpTime}
    })

    vehicle.frozen = true
    exports.cr_controls:toggleControl("enter_exit", false, "instant")

    removeEventHandler("ProgressBarEnd", localPlayer, onProgressBarEnd)
    addEventHandler("ProgressBarEnd", localPlayer, onProgressBarEnd)
end

function destroyCustomers()
    local result = false

    for k, v in pairs(createdPeds) do 
        if type(v) == "string" then
            if v == "customer" then 
                k:destroy()

                if not result then 
                    result = true
                end
            end
        elseif type(v) == "table" then 
            if v.typ and v.typ == "customer" then 
                if isElement(k) then 
                    local orderId = v.orderId
                    local name = k:getData("ped.name")

                    exports.cr_radar:destroyStayBlip("#" .. orderId .. " - " .. name)
                    k:destroy()
                end

                if isElement(createdMarkers[k]) then 
                    createdMarkers[k]:destroy()
                end

                createdMarkers[k] = nil

                if not result then 
                    result = true
                end
            end
        end
    end

    if result then 
        collectgarbage("collect")
    end
end

function onFillingUpComplete()
    isVehicleFilledUp = true

    local vehicle = localPlayer.vehicle

    vehicle.frozen = false
    exports.cr_controls:toggleControl("enter_exit", true, "instant")

    local syntax = exports.cr_core:getServerSyntax("Delivery", "success")
    outputChatBox(syntax .. "A felrakodás sikeresen megtörtént, most szállítsd ki a csomagokat a megadott helyekre.", 255, 0, 0, true)

    destroyCustomers()    
    setupDeliveryLocations()
end

function onProgressBarEnd(id)
    if id == "delivery >> fillingUp" then 
        onFillingUpComplete()

        removeEventHandler("ProgressBarEnd", localPlayer, onProgressBarEnd)
    end
end

function onClientMarkerHit(hitElement, mDim)
    if hitElement == localPlayer and mDim then 
        if createdMarkers[source] then 
            if createdMarkers[source] == "pickupMarker" then 
                if getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 5 then 
                    if talkedWithShiftLeader then 
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
                                now = 1,

                                ['jobVehSettings'] = { 
                                    ['customCol'] = {'sphere', {219.50833129883, 17.37592124939, 2.578125, 20}},
                                },
                            })
                        end
                    else 
                        local syntax = exports.cr_core:getServerSyntax("Delivery", "error")

                        outputChatBox(syntax .. "Előbb beszélj a műszakvezetővel.", 255, 0, 0, true)
                    end
                end 
            elseif createdMarkers[source].name and createdMarkers[source].name == "deliveryPickupMarker" then 
                local vehicle = localPlayer.vehicle

                if vehicle and vehicle.model == jobData.vehicles[1] and getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 5 then 
                    if not exports.cr_dx:isProgressBarActive("delivery >> fillingUp") and not isVehicleFilledUp then 
                        startFillingUp()
                    else
                        local syntax = exports.cr_core:getServerSyntax("Delivery", "error")

                        outputChatBox(syntax .. "A járműved már fel van töltve, most kézbesítsd a csomagokat.", 255, 0, 0, true)
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
        end
    end
end