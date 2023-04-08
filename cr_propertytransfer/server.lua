local sql = exports.cr_mysql:getConnection(getThisResource())

addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then 
            sql = exports.cr_mysql:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

function showPropertyTransfer(data)
    if isElement(client) and data then 
        local targetElement = data.buyerElement

        if isElement(targetElement) then 
            local price = data.price

            if exports.cr_core:hasMoney(targetElement, price) then 
                if data.isVehicle then 
                    local targetVehicleLimit = tonumber(targetElement:getData("char >> vehicleLimit") or 0)

                    if data.allVehicle then 
                        if data.allVehicle + 1 > targetVehicleLimit then 
                            exports.cr_infobox:addBox(client, "error", "A kiválasztott játékosnak nincs elegendő jármű slotja.")
                            return
                        end
                    end
                elseif data.isInterior then
                    local targetInteriorLimit = tonumber(targetElement:getData("char >> interiorLimit") or 0)

                    if data.allInterior then 
                        if data.allInterior + 1 > targetInteriorLimit then 
                            exports.cr_infobox:addBox(client, "error", "A kiválasztott játékosnak nincs elegendő interior slotja.")
                            return
                        end
                    end
                end

                client:setData("hasOnGoingTransfer", targetElement)
                targetElement:setData("hasOnGoingTransfer", client)
                triggerClientEvent(targetElement, "propertyTransfer.showPropertyTransferCallback", client, data)
            else 
                exports.cr_infobox:addBox(client, "error", "A célpontnak nincs elegendő pénze.")
            end
        end
    end
end
addEvent("propertyTransfer.showPropertyTransfer", true)
addEventHandler("propertyTransfer.showPropertyTransfer", root, showPropertyTransfer)

function transferProperty(data)
    if isElement(client) and data then 
        local buyerElement = data.buyerElement
        local sellerElement = data.sellerElement
        local elementToSell = data.elementToSell

        if isElement(buyerElement) and isElement(sellerElement) and isElement(elementToSell) then 
            if elementToSell.type == "vehicle" then 
                local price = data.price
                local players = {}

                if price and price > 0 then 
                    if not exports.cr_inventory:hasItem(sellerElement, 26) then 
                        exports.cr_infobox:addBox(buyerElement, "error", "Az eladónál nem volt üres adásvételi szerződés, ezért a vásárlás megszakadt.")

                        buyerElement:removeData("hasOnGoingTransfer")
                        sellerElement:removeData("hasOnGoingTransfer")
                        return
                    end

                    if not exports.cr_core:hasMoney(buyerElement, price) then 
                        exports.cr_infobox:addBox(sellerElement, "error", "A vevőnek nem volt elég pénze, ezért a vásárlás megszakadt.")

                        buyerElement:removeData("hasOnGoingTransfer")
                        sellerElement:removeData("hasOnGoingTransfer")
                        return
                    end

                    if getDistanceBetweenPoints3D(buyerElement.position, sellerElement.position) > 3 then 
                        exports.cr_infobox:addBox(sellerElement, "error", "A vevő túl messze van tőled.")

                        buyerElement:removeData("hasOnGoingTransfer")
                        sellerElement:removeData("hasOnGoingTransfer")
                        return
                    end

                    exports.cr_core:takeMoney(buyerElement, price)
                    exports.cr_core:giveMoney(sellerElement, price)

                    exports.cr_infobox:addBox(sellerElement, "success", "Sikeresen eladtad a kiválasztott gépjárművet!")
                    exports.cr_infobox:addBox(buyerElement, "success", "Sikeresen megvetted a szerződésben írt gépjárművet!")

                    local vehDbId = elementToSell:getData("veh >> id")
                    local buyerAccId = buyerElement:getData("acc >> id")

                    exports.cr_vehicle:removeVehicleFromPlayer(sellerElement, elementToSell)
                    exports.cr_vehicle:addVehicleToPlayer(buyerElement, elementToSell)

                    dbExec(sql, "UPDATE vehicle SET owner = ? WHERE id = ?", buyerAccId, vehDbId)

                    elementToSell:setData("veh >> owner", buyerAccId)

                    table.insert(players, buyerElement)
                    table.insert(players, sellerElement)

                    if #players > 0 then 
                        triggerClientEvent(sellerElement, "propertyTransfer.removeItem", sellerElement, 26)
                        triggerClientEvent(players, "propertyTransfer.updateProperty", buyerElement)
                    end

                    data.buyerElement = nil
                    data.sellerElement = nil
                    data.elementToSell = nil

                    exports.cr_inventory:giveItem(buyerElement, 80, data)

                    buyerElement:removeData("hasOnGoingTransfer")
                    sellerElement:removeData("hasOnGoingTransfer")
                end
            elseif elementToSell.type == "marker" then
                local price = data.price
                local players = {}

                if price and price > 0 then 
                    if not exports.cr_inventory:hasItem(sellerElement, 26) then 
                        exports.cr_infobox:addBox(buyerElement, "error", "Az eladónál nem volt üres adásvételi szerződés, ezért a vásárlás megszakadt.")

                        buyerElement:removeData("hasOnGoingTransfer")
                        sellerElement:removeData("hasOnGoingTransfer")
                        return
                    end

                    if not exports.cr_core:hasMoney(buyerElement, price) then 
                        exports.cr_infobox:addBox(sellerElement, "error", "A vevőnek nem volt elég pénze, ezért a vásárlás megszakadt.")

                        buyerElement:removeData("hasOnGoingTransfer")
                        sellerElement:removeData("hasOnGoingTransfer")
                        return
                    end

                    if getDistanceBetweenPoints3D(buyerElement.position, sellerElement.position) > 3 then 
                        exports.cr_infobox:addBox(sellerElement, "error", "A vevő túl messze van tőled.")

                        buyerElement:removeData("hasOnGoingTransfer")
                        sellerElement:removeData("hasOnGoingTransfer")
                        return
                    end

                    exports.cr_core:takeMoney(buyerElement, price)
                    exports.cr_core:giveMoney(sellerElement, price)

                    exports.cr_infobox:addBox(sellerElement, "success", "Sikeresen eladtad a kiválasztott ingatlant!")
                    exports.cr_infobox:addBox(buyerElement, "success", "Sikeresen megvetted a szerződésben írt ingatlant!")

                    local markerData = elementToSell:getData("marker >> data")

                    if not markerData then 
                        return
                    end

                    local interiorDbId = markerData.id
                    local buyerAccId = buyerElement:getData("acc >> id")

                    dbExec(sql, "UPDATE interiors SET owner = ? WHERE id = ?", buyerAccId, interiorDbId)

                    markerData.owner = tonumber(buyerAccId)
                    elementToSell:setData("marker >> data", markerData)

                    table.insert(players, buyerElement)
                    table.insert(players, sellerElement)

                    if #players > 0 then 
                        triggerClientEvent(sellerElement, "propertyTransfer.removeItem", sellerElement, 26)
                        triggerClientEvent(players, "propertyTransfer.updateProperty", buyerElement)
                    end

                    data.buyerElement = nil
                    data.sellerElement = nil
                    data.elementToSell = nil

                    exports.cr_inventory:giveItem(buyerElement, 80, data)

                    buyerElement:removeData("hasOnGoingTransfer")
                    sellerElement:removeData("hasOnGoingTransfer")
                end
            end
        end
    end
end
addEvent("propertyTransfer.transferProperty", true)
addEventHandler("propertyTransfer.transferProperty", root, transferProperty)