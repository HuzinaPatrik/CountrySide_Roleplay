local screenX, screenY = guiGetScreenSize()

local previewPosition = Vector3(2308.8325195312, 49.427074432373, 26.184375)
local previewCameraMatrix = {2310.9143066406, 55.044300079346, 28.106599807739, 2310.5915527344, 54.144023895264, 27.814544677734}

local previewInterior = 0
local previewDimension = 0

local oldData = {
    oldDimension = false,
    chatState = true,
    hudVisible = true,
    keysDenied = false
}

local objectElement = false
local objectRotation = 0

local selectedFurniture = 1
local availableFurnitures = {}

local hoverButton = false
local isRender = false

local spinState = true
local promptActive = false
local lastKey = 0

function manageFurnitureShop(state)
    if state == "init" then 
        availableFurnitures = exports.cr_inventory:getAllFurniture()
        previewDimension = localPlayer:getData("acc >> id")

        oldData.oldDimension = localPlayer.dimension
        oldData.chatState = exports["cr_custom-chat"]:isChatVisible()
        oldData.hudVisible = localPlayer:getData("hudVisible")
        oldData.keysDenied = localPlayer:getData("keysDenied")

        exports["cr_custom-chat"]:showChat(false)
        localPlayer:setData("hudVisible", false)
        localPlayer:setData("keysDenied", true)
        localPlayer.dimension = previewDimension

        if isElement(objectElement) then 
            objectElement:destroy()
            objectElement = nil
        end

        if availableFurnitures[selectedFurniture] then
            objectElement = Object(availableFurnitures[selectedFurniture].objectId, previewPosition)
            objectElement.interior = previewInterior
            objectElement.dimension = previewDimension
        end

        exports.cr_dx:startFade("furnitureShop", 
            {
                startTick = getTickCount(),
                lastUpdateTick = getTickCount(),
                time = 250,
                animation = "InOutQuad",
                from = 0,
                to = 255,
                alpha = 0,
                progress = 0
            }
        )

        createRender("renderFurnitureShop", renderFurnitureShop)

        removeEventHandler("onClientKey", root, onKey)
        addEventHandler("onClientKey", root, onKey)

        isRender = true
    elseif state == "exit" then
        exports.cr_dx:startFade("furnitureShop", 
            {
                startTick = getTickCount(),
                lastUpdateTick = getTickCount(),
                time = 250,
                animation = "InOutQuad",
                from = 255,
                to = 0,
                alpha = 255,
                progress = 0
            }
        )

        removeEventHandler("onClientKey", root, onKey)
    end
end

-- function onClientStart()
--     if localPlayer.name == "Hugh_Wiley" then 
--         manageFurnitureShop("init")
--     end
-- end
-- addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

function renderFurnitureShop()
    local alpha, progress = exports.cr_dx:getFade("furnitureShop")

    if alpha and progress then 
        if progress >= 1 and alpha <= 0 then 
            destroyRender("renderFurnitureShop")

            exports["cr_custom-chat"]:showChat(oldData.chatState)
            localPlayer:setData("hudVisible", oldData.hudVisible)
            localPlayer:setData("keysDenied", oldData.keysDenied)
            localPlayer.dimension = oldData.oldDimension

            if isElement(objectElement) then 
                objectElement:destroy()
                objectElement = nil
            end

            setTimer(setCameraTarget, 100, 1, localPlayer)
        end
    end

    local font = exports.cr_fonts:getFont("Poppins-SemiBold", 16)
    local font2 = exports.cr_fonts:getFont("Poppins-Medium", 16)
    local font3 = exports.cr_fonts:getFont("Poppins-Medium", 14)

    local hexColor = exports.cr_core:getServerColor("yellow", true)
    local hexColor2 = exports.cr_core:getServerColor("green", true)
    local hexColor3 = exports.cr_core:getServerColor("red", true)

    local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)
    local redR, redG, redB = exports.cr_core:getServerColor("red", false)
    
    if spinState then 
        objectRotation = objectRotation + 1

        if objectRotation > 360 then 
            objectRotation = 0
        end
        
        if isElement(objectElement) then 
            local rotX, rotY = getElementRotation(objectElement)

            setElementRotation(objectElement, rotX, rotY, objectRotation)
        end
    end

    setCameraMatrix(unpack(previewCameraMatrix))

    local panelW, panelH = 400, 150
    local panelX, panelY = screenX / 2 - panelW / 2, screenY - panelH - 10

    dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(51, 51, 51, alpha * 0.8))

    local logoW, logoH = 26, 30
    local logoX, logoY = panelX + 10, panelY + 8

    dxDrawImage(logoX, logoY, logoW, logoH, "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("Bútorbolt", logoX + logoW + 10, logoY + 4, logoX + logoW, logoY + logoH, tocolor(255, 255, 255, alpha), 1, font, "left", "center")

    dxDrawText("Bútor neve: " .. hexColor .. exports.cr_inventory:getItemName(availableFurnitures[selectedFurniture].itemId), panelX, panelY - 17, panelX + panelW, panelY + panelH, tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, false, false, true)
    dxDrawText("Bútor ára: " .. hexColor2 .. "$" .. exports.cr_dx:formatMoney(availableFurnitures[selectedFurniture].price), panelX, panelY + 24, panelX + panelW, panelY + panelH, tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, false, false, true)

    local buttonW, buttonH = 120, 20
    local buttonX, buttonY = panelX + buttonW / 2, panelY + panelH - buttonH - 10

    local buyButtonColor = tocolor(greenR, greenG, greenB, alpha * 0.7)
    local buyButtonTextColor = tocolor(255, 255, 255, alpha * 0.6)
    local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

    hoverButton = nil

    if inSlot then 
        hoverButton = "buyFurniture"
        buyButtonColor = tocolor(greenR, greenG, greenB, alpha)
        buyButtonTextColor = tocolor(255, 255, 255, alpha)
    end

    dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buyButtonColor)
    dxDrawText("Megvétel", buttonX, buttonY + 4, buttonX + buttonW, buttonY + buttonH, buyButtonTextColor, 1, font3, "center", "center")

    local buttonX = panelX + panelW - buttonW - buttonW / 2
    local closeButtonColor = tocolor(redR, redG, redB, alpha * 0.7)
    local closeButtonTextColor = tocolor(255, 255, 255, alpha * 0.6)
    local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

    if inSlot then 
        hoverButton = "closeFurniture"
        closeButtonColor = tocolor(redR, redG, redB, alpha)
        closeButtonTextColor = tocolor(255, 255, 255, alpha)
    end

    dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, closeButtonColor)
    dxDrawText("Kilépés", buttonX, buttonY + 4, buttonX + buttonW, buttonY + buttonH, closeButtonTextColor, 1, font3, "center", "center")

    local spinW, spinH = 20, 20
    local spinX, spinY = panelX + panelW - 10 - spinW, panelY + 10
    local inSlot = exports.cr_core:isInSlot(spinX, spinY, spinW, spinH)

    local spinColor = tocolor(242, 242, 242, alpha)

    if inSlot then 
        hoverButton = "spinButton"

        if not spinState then 
            spinColor = tocolor(greenR, greenG, greenB, alpha)
        else
            spinColor = tocolor(redR, redG, redB, alpha)
        end
    end

    dxDrawImage(spinX, spinY, spinW, spinH, "files/images/reset.png", 0, 0, 0, spinColor)
end

function onKey(button, state)
    if button == "mouse1" and state then 
        if hoverButton == "spinButton" then 
            spinState = not spinState
        elseif hoverButton == "buyFurniture" then
            if not promptActive then 
                promptActive = true

                exports.cr_dashboard:createAlert(
                    {
                        title = {"Biztosan megszeretnéd vásárolni ezt a bútort?"},
                        buttons = {
                            {
                                name = "Igen", 
                                pressFunc = "furnitureShop.buyFurniture",
                                color = {exports.cr_core:getServerColor("green", false)},
                            },

                            {
                                name = "Nem", 
                                onClear = true,
                                pressFunc = "furnitureShop.declineFurnitureBuying",
                                color = {exports.cr_core:getServerColor("red", false)},
                            },
                        },
                    }
                )
            end
        elseif hoverButton == "closeFurniture" then
            if isRender then 
                isRender = false

                manageFurnitureShop("exit")
            end
        end
    elseif button == "arrow_l" and state then
        if lastKey + 250 > getTickCount() then 
            return
        end

        if selectedFurniture - 1 > 0 then 
            selectedFurniture = selectedFurniture - 1

            if isElement(objectElement) then 
                objectElement:destroy()
                objectElement = nil
            end

            if availableFurnitures[selectedFurniture] then
                objectElement = Object(availableFurnitures[selectedFurniture].objectId, previewPosition)
                objectElement.interior = previewInterior
                objectElement.dimension = previewDimension
            end
        end

        lastKey = getTickCount()
    elseif button == "arrow_r" and state then 
        if lastKey + 250 > getTickCount() then 
            return
        end

        if selectedFurniture + 1 <= #availableFurnitures then 
            selectedFurniture = selectedFurniture + 1

            if isElement(objectElement) then 
                objectElement:destroy()
                objectElement = nil
            end

            if availableFurnitures[selectedFurniture] then
                objectElement = Object(availableFurnitures[selectedFurniture].objectId, previewPosition)
                objectElement.interior = previewInterior
                objectElement.dimension = previewDimension
            end
        end

        lastKey = getTickCount()
    end
end

function onClick(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
    if button ~= "middle" and state == "down" then 
        if isElement(clickedElement) and clickedElement:getData("furniturePed") then 
            local distance = getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position)

            if distance <= 3 then 
                if not isRender then 
                    manageFurnitureShop("init")
                end
            end
        end
    end
end
addEventHandler("onClientClick", root, onClick)

function buyFurniture()
    promptActive = false
    local price = availableFurnitures[selectedFurniture].price
    local itemId = availableFurnitures[selectedFurniture].itemId

    if exports.cr_core:hasMoney(localPlayer, price, false) then 
        exports.cr_core:takeMoney(localPlayer, price, false)
        exports.cr_inventory:giveItem(localPlayer, itemId, 1)
        exports.cr_infobox:addBox("success", "Sikeresen megvásároltad a kiválasztott bútort!")

        if isRender then 
            isRender = false

            manageFurnitureShop("exit")
        end
    else
        exports.cr_infobox:addBox("error", "Nincs elég pénzed.")
    end
end
addEvent("furnitureShop.buyFurniture", true)
addEventHandler("furnitureShop.buyFurniture", root, buyFurniture)

function declineFurnitureBuying()
    promptActive = false
end
addEvent("furnitureShop.declineFurnitureBuying", true)
addEventHandler("furnitureShop.declineFurnitureBuying", root, declineFurnitureBuying)