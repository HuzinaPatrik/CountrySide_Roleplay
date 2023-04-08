local screenX, screenY = guiGetScreenSize()
local dxDrawMultiplier = math.min(0.8, screenX / 1280)

function resp(val)
    return val * dxDrawMultiplier
end

function getRealFontSize(a)
    local a = resp(a)
    local val = ((a) - math.floor(a))
    if val < 0.5 then
        return math.floor(a)
    elseif val >= 0.5 then
        return math.ceil(a)
    end
end

local maxCashBox = 4
local hoverCashBox = false
local lastClick = 0
local lastPickup = 0

local isRender = false
local selectedElement = false
local cashBoxes = {}

function createCashBoxes()
    cashBoxes = {}

    for i = 1, maxCashBox do 
        cashBoxes[i] = true
    end

    return cashBoxes
end

function renderATMPanel()
    local alpha, progress = exports.cr_dx:getFade("atmRobPanel")

    if alpha and progress then 
        if progress >= 1 and alpha <= 0 then 
            if isElement(selectedElement) then 
                local id = selectedElement:getData("bank >> atm")

                triggerServerEvent("atmRobbery.closeATMPanel", localPlayer, id)
            end

            selectedElement = false
            destroyRender("renderATMPanel")
            return
        end
    end

    local panelW, panelH = resp(576), resp(1080)
    local panelX, panelY = screenX / 2 - panelW / 2, screenY / 2 - panelH / 2

    dxDrawImage(panelX, panelY, panelW, panelH, "atm/files/images/atm.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

    local cashBoxW, cashBoxH = resp(337), resp(105)
    local cashBoxX, cashBoxY = panelX + resp(120), panelY + panelH / 2 + resp(45)

    hoverCashBox = nil

    for i = 1, maxCashBox do 
        local v = cashBoxes[i]

        if v then 
            local inSlot = exports.cr_core:isInSlot(cashBoxX, cashBoxY, cashBoxW, cashBoxH)
            if inSlot then 
                hoverCashBox = i
            end

            dxDrawImage(cashBoxX, cashBoxY, cashBoxW, cashBoxH, "atm/files/images/cashbox.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
        end

        cashBoxY = cashBoxY + cashBoxH + resp(4)
    end
end

local function onPanelKey(button, state)
    if button == "mouse1" and state then 
        if hoverCashBox then 
            if cashBoxes[hoverCashBox] then 
                if lastPickup + 1500 > getTickCount() then 
                    exports.cr_infobox:addBox("error", "Ilyen gyorsan nem tudod kivenni a pénzkazettákat.")
                    return
                end

                cashBoxes[hoverCashBox] = nil

                if isElement(selectedElement) then 
                    selectedElement:setData("atm >> cashBoxes", cashBoxes)
                    localPlayer:setData("forceAnimation", {"rob_bank", "cat_safe_rob", 1200, false, false, true, false})

                    exports.cr_inventory:giveItem(localPlayer, 317, 1, 1)
                    exports.cr_chat:createMessage(localPlayer, "kivesz egy pénzkazettát az ATM-ből.", 1)
                end

                if table.count(cashBoxes) <= 0 then 
                    isRender = false

                    manageATMPanel("exit")
                end

                lastPickup = getTickCount()
            end
        end
    elseif button == "backspace" and state then
        if isRender then 
            isRender = false

            manageATMPanel("exit")
        end
    end
end

function manageATMPanel(state, element)
    if state == "init" then 
        isRender = true
        createRender("renderATMPanel", renderATMPanel)

        if element then 
            selectedElement = element
        end

        exports.cr_dx:startFade("atmRobPanel", 
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

        removeEventHandler("onClientKey", root, onPanelKey)
        addEventHandler("onClientKey", root, onPanelKey)

        removeEventHandler("onClientElementDestroy", root, onClientElementDestroy)
        addEventHandler("onClientElementDestroy", root, onClientElementDestroy)
    elseif state == "exit" then
        removeEventHandler("onClientKey", root, onPanelKey)
        removeEventHandler("onClientElementDestroy", root, onClientElementDestroy)

        exports.cr_dx:startFade("atmRobPanel", 
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
    end
end

function onPanelClick(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
    if button ~= "middle" and state == "down" then 
        if isElement(clickedElement) then 
            if clickedElement.model == destroyedAtmModelId and clickedElement:getData("bank >> atm") and clickedElement:getData("atm >> unavailable") and not isRender then 
                if (clickedElement:getData("atm >> health") or 100) <= 0 then 
                    if exports.cr_network:getNetworkStatus() then 
                        return
                    end

                    if lastClick + 2000 > getTickCount() then 
                        return
                    end

                    if getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position) > 1 then 
                        return
                    end

                    local atmCashBoxes = clickedElement:getData("atm >> cashBoxes") or {}

                    if table.count(atmCashBoxes) > 0 then 
                        if not hasPermissionToRob("atmRob") then 
                            exports.cr_infobox:addBox("warning", "Neked ehhez nincs jogosultságod.")
                            return
                        end

                        local id = clickedElement:getData("bank >> atm")

                        triggerServerEvent("atmRobbery.openATMPanel", localPlayer, id, clickedElement)
                    end

                    lastClick = getTickCount()
                end
            end
        end
    end
end
addEventHandler("onClientClick", root, onPanelClick)

function onClientElementDestroy()
    if selectedElement == source then 
        manageATMPanel("exit")
    end
end

function openATMPanel(element)
    local atmCashBoxes = element:getData("atm >> cashBoxes") or {}

    selectedElement = element
    cashBoxes = atmCashBoxes

    manageATMPanel("init")
end
addEvent("atmRobbery.openATMPanel", true)
addEventHandler("atmRobbery.openATMPanel", root, openATMPanel)