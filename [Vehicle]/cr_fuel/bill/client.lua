local cache = {}
local renderState, selected, gData, datum
local sx, sy = guiGetScreenSize()

function createFinishPage(data)
    if not renderState then 
        renderState = true 

        exports['cr_dx']:startFade("fuelBill", 
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

        gData = data
        datum = exports['cr_core']:getDatum(".")
        id = 1
        selected = 0
        gSelected = nil 

        bindKey("enter", "down", finishInteract)
        bindKey("backspace", "down", destroyFinishPage)
        bindKey("arrow_l", "down", leftInteract)
        bindKey("arrow_r", "down", rightInteract)

        addEventHandler("onClientClick", root, onBillClick)

        createRender("renderPanel", renderPanel)
    end 
end 

function destroyFinishPage()
    if renderState then 
        renderState = false 

        exports['cr_dx']:startFade("fuelBill", 
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

        unbindKey("enter", "down", finishInteract)
        unbindKey("backspace", "down", destroyFinishPage)
        unbindKey("arrow_l", "down", leftInteract)
        unbindKey("arrow_r", "down", rightInteract)

        removeEventHandler("onClientClick", root, onBillClick)
    end 
end 

function renderPanel()
    local alpha, progress = exports['cr_dx']:getFade("fuelBill")
    if not renderState then 
        if progress >= 1 then 
            destroyRender("renderPanel")
            currentFuelPed = false
            return 
        end  
    end 

    local font = exports['cr_fonts']:getFont("Poppins-Bold", 20)
    local font2 = exports['cr_fonts']:getFont("Poppins-Regular", 13)
    local font3 = exports['cr_fonts']:getFont("Poppins-Bold", 13)
    local font4 = exports['cr_fonts']:getFont("Poppins-Bold", 16)

    local w, h = 214, 330
    dxDrawImage(sx/2 - w/2, sy/2 - h/2, w, h, "files/images/bill.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText(gData["location"], sx/2 - w/2, sy/2 - h/2 + 55, sx/2 + w/2, sy/2 + h/2 + 55, tocolor(51, 51, 51, alpha), 1, font4, "center", "top")
    dxDrawText(datum, sx/2 - w/2 + 195, sy/2 - h/2 + 101, sx/2 - w/2 + 195, sy/2 - h/2 + 101, tocolor(51, 51, 51, alpha), 1, font2, "right", "top")
    dxDrawText(currentFuelPed:getData('ped.name'):gsub("_", " "), sx/2 - w/2 + 195, sy/2 - h/2 + 119, sx/2 - w/2 + 195, sy/2 - h/2 + 119, tocolor(51, 51, 51, alpha), 1, font2, "right", "top")

    dxDrawText(gData.fuelType.name, sx/2 - w/2 + 20, sy/2 - h/2 + 144, sx/2 - w/2 + 20, sy/2 - h/2 + 144 + 33 + 4, tocolor(51, 51, 51, alpha), 1, font2, "left", "center")
    -- dxDrawText(gData["count"] .. 'db', sx/2 - w/2 + 15, sy/2 - h/2 + 144, sx/2 - w/2 + 15 + 180, sy/2 - h/2 + 144 + 33 + 4, tocolor(51, 51, 51, alpha), 1, font2, "center", "center")
    dxDrawText('$ '.. math.floor(gData.fueledLiters * 10) / 10 .. '/l', sx/2 - w/2 + 195, sy/2 - h/2 + 144, sx/2 - w/2 + 195, sy/2 - h/2 + 144 + 33 + 4, tocolor(51, 51, 51, alpha), 1, font2, "right", "center")
    dxDrawText('$ '.. math.ceil(math.floor(gData.fuelPrice * 10) / 10), sx/2 - w/2 + 195, sy/2 - h/2 + 176, sx/2 - w/2 + 195, sy/2 - h/2 + 176 + 40, tocolor(51, 51, 51, alpha), 1, font3, "right", "center")

    local x, y = sx/2 - w/2 + 15, sy/2 - h/2 + 285
    local w2, h2 = 90, 25

    gSelected = nil 
    if exports['cr_core']:isInSlot(x, y, w2, h2) or selected == 1 then 
        if exports['cr_core']:isInSlot(x, y, w2, h2) then 
            gSelected = 1
        end

        dxDrawRectangle(x, y, w2, h2, tocolor(229, 229, 229, alpha))
        dxDrawText("Készpénz", x, y, x + w2, y + h2 + 4, tocolor(97, 177, 90, alpha), 1, font3, "center", "center")
    else 
        dxDrawRectangle(x, y, w2, h2, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText("Készpénz", x, y, x + w2, y + h2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
    end 

    x = x + w2 + 5

    if exports['cr_core']:isInSlot(x, y, w2, h2) or selected == 2 then 
        if exports['cr_core']:isInSlot(x, y, w2, h2) then 
            gSelected = 2
        end

        dxDrawRectangle(x, y, w2, h2, tocolor(229, 229, 229, alpha))
        dxDrawText("Bankkártya", x, y, x + w2, y + h2 + 4, tocolor(97, 177, 90, alpha), 1, font3, "center", "center")
    else 
        dxDrawRectangle(x, y, w2, h2, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText("Bankkártya", x, y, x + w2, y + h2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
    end 
end 

function finishInteract()
    if selected == 1 then 
        triggerEvent("shop.buyItem2", localPlayer, 1, gData)

        destroyFinishPage()
    elseif selected == 2 then 
        triggerEvent("shop.buyItem2", localPlayer, 2, gData)

        destroyFinishPage()
    end 
end 

function leftInteract()
    selected = math.max(selected - 1, 0)
end 

function rightInteract()
    selected = math.min(selected + 1, 2)
end

function onBillClick()
    if renderState then 
        if tonumber(gSelected) then 
            local fuelingVehicle = localPlayer:getData("fuel >> fuelingVehicle")
            local fuelType = localPlayer:getData("fuel >> fuelType") or {}
            local players = getElementsWithinColShape(currentColshape, "player") or {}

            if isElement(fuelingVehicle) then
                local fueledLiters = fuelingVehicle:getData("fuel >> currentLiters")
                local currentFuelPrice = fuelingVehicle:getData("fuel >> currentFuelPrice") or 100
                local currentLiters = fuelingVehicle:getData("veh >> fuel") or 0
                local pistolHolder = localPlayer:getData("fuel >> pistolHolder")

                local vehicleMaxFuelTank = exports.cr_vehicle:getVehicleMaxFuel(fuelingVehicle.model)
                local newFuel = math.min(vehicleMaxFuelTank, currentLiters + fueledLiters)
                local moneyToTake = math.ceil(math.floor(currentFuelPrice * 10) / 10)

                if exports.cr_core:hasMoney(localPlayer, moneyToTake, tonumber(gSelected) == 2) then 
                    exports.cr_core:takeMoney(localPlayer, moneyToTake, tonumber(gSelected) == 2)

                    fuelingVehicle:setData("veh >> fuel", newFuel)
                    fuelingVehicle:setData("veh >> oldfueltype", fuelType.defaultValue)
                    fuelingVehicle:setData("veh >> fueltype", fuelType.defaultValue)

                    fuelingVehicle:setData("fuel >> currentLiters", nil)
                    fuelingVehicle:setData("fuel >> currentFuelPrice", nil)
                    localPlayer:setData("fuel >> fuelingVehicle", nil)
                    localPlayer:setData("fuel >> pistolHolder", nil)
                    localPlayer:setData("fuel >> fuelType", nil)

                    local stationId = pistolHolder[1]
                    local positionId = pistolHolder[2]
                    local stationFuelType = pistolHolder[3]

                    if availableStations[stationId] then 
                        triggerLatentServerEvent("fuel.resetFuelDataForStation", 5000, false, localPlayer, stationId, positionId, players, "all")
                    end
                else
                    exports.cr_infobox:addBox("error", "Nincs elég pénzed.")
                end
            else
                local fuelStation = localPlayer:getData("fuelStation") or {}

                local stationId = fuelStation[1]
                local positionId = fuelStation[2]
                local fuelType = fuelStation[3]

                if availableStations[stationId] then 
                    local fuelPos = availableStations[stationId].fuelData[positionId]

                    if fuelPos then 
                        local moneyToTake = math.ceil(math.floor(fuelPos.currentFuelPrice * 10) / 10)

                        if exports.cr_core:hasMoney(localPlayer, moneyToTake, tonumber(gSelected) == 2) then 
                            exports.cr_core:takeMoney(localPlayer, moneyToTake, tonumber(gSelected) == 2)
        
                            triggerLatentServerEvent("fuel.resetFuelDataForStation", 5000, false, localPlayer, stationId, positionId, players, "all")
                            localPlayer:setData("fuel >> fuelingWithoutVehicle", nil)
                        else
                            exports.cr_infobox:addBox("error", "Nincs elég pénzed.")
                        end
                    end
                end
            end

            destroyFinishPage()
            gSelected = nil 
        end 
    end 
end 


-- addCommandHandler("asd",
--     function(cmd)
--         createFinishPage(
--             {
--                 ["ID"] = 1,
--                 ["ItemData"] = {1}, 
--                 ["count"] = 5,
--                 ["price"] = 25.5,
--             }
--         )
--     end 
-- )

--
function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end