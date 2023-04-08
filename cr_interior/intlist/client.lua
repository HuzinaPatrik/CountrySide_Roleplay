local screenX, screenY = guiGetScreenSize()

local panelHover = false
local closeHover = false

local isRender = false

local function manageTextbars(state)
    if state == "create" then 
        CreateNewBar("interior.search", {0, 0, 0, 0}, {25, "Keresés...", false, tocolor(255, 255, 255), {"Poppins-Medium", 12}, 1, "left", "center", false, true}, 1)
    elseif state == "destroy" then
        Clear()
    end
end

function renderGameInteriorList()
    local alpha, progress = exports.cr_dx:getFade("gameInteriorList")
    
    if alpha and progress then 
        if progress >= 1 and alpha <= 0 then 
            destroyRender("renderGameInteriorList")
            manageTextbars("destroy")
        end
    end

    local font = exports.cr_fonts:getFont("Poppins-SemiBold", 16)
    local font2 = exports.cr_fonts:getFont("Poppins-Medium", 12)

    panelHover = nil

    local panelW, panelH = 450, 280
    local panelX, panelY = screenX / 2 - panelW / 2, screenY / 2 - panelH / 2
    local inSlot = exports.cr_core:isInSlot(panelX, panelY, panelW, panelH)
    if inSlot then 
        panelHover = true
    end

    dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(51, 51, 51, alpha * 0.8))

    local logoW, logoH = 26, 30
    local logoX, logoY = panelX + 10, panelY + 8

    dxDrawImage(logoX, logoY, logoW, logoH, "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("Elérhető interiorok (" .. #interiorList .. " db)", logoX + logoW + 10, logoY + 4, logoX + logoW, logoY + logoH, tocolor(255, 255, 255, alpha), 1, font, "left", "center")

    -- _x + w - 10 - 15, _y + 10, 15, 15

    closeHover = nil

    local closeW, closeH = 15, 15
    local closeX, closeY = panelX + panelW - 10 - closeW, panelY + 10
    local closeColor = tocolor(255, 59, 59, alpha * 0.6)
    local inSlot = exports.cr_core:isInSlot(closeX, closeY, closeW, closeH)

    if inSlot then 
        closeHover = true
        closeColor = tocolor(255, 59, 59, alpha)
    end

    dxDrawImage(closeX, closeY, closeW, closeH, "files/images/close.png", 0, 0, 0, closeColor)

    local searchW, searchH = 100, 20
    local searchX, searchY = panelX + panelW - searchW - 50, logoY + searchH / 2

    dxDrawRectangle(searchX, searchY, searchW, searchH, tocolor(51, 51, 51, alpha * 0.7))

    UpdatePos("interior.search", {searchX + 5, searchY + 1, searchW - 10, searchH})
    UpdateAlpha("interior.search", tocolor(242, 242, 242, alpha))

    local rowW, rowH = panelW - 20, 20
    local rowX, rowY = panelX + 10, logoY + (logoH / 2) + rowH + 10
    local rowStartY = rowY

    local array = gameInteriors
    local percent = #array

    if interiorListSearchCache then 
        array = interiorListSearchCache
        percent = #array
    end

    if availableInteriorsMaxLines > percent then 
        availableInteriorsMinLines = 1
        _availableInteriorsMaxLines = 10
        availableInteriorsMaxLines = _availableInteriorsMaxLines
    end

    for i = availableInteriorsMinLines, availableInteriorsMaxLines do 
        local v = array[i]

        local rowColor = tocolor(51, 51, 51, alpha * 0.6)
        local textColor = tocolor(242, 242, 242, alpha)

        local inSlot = exports.cr_core:isInSlot(rowX, rowY, rowW, rowH)
        if inSlot then 
            rowColor = tocolor(242, 242, 242, alpha * 0.8)
            textColor = tocolor(51, 51, 51, alpha)
        end

        dxDrawRectangle(rowX, rowY, rowW, rowH, rowColor)

        if v then 
            local name = v.name or "Ismeretlen"
            local id = v.id or "Ismeretlen"

            dxDrawText(name, rowX + 5, rowY + 2, rowX + rowW, rowY + rowH, textColor, 1, font2, "left", "center")
            dxDrawText("ID: " .. id, rowX, rowY + 2, rowX + rowW - 5, rowY + rowH, textColor, 1, font2, "right", "center")
        end

        rowY = rowY + rowH + 2
    end

    -- Scrollbar

    local scrollW, scrollH = 3, 218
    local scrollX, scrollY = panelX + panelW - scrollW - 4, rowStartY

    scrollBarHover = exports.cr_core:isInSlot(scrollX, scrollY, scrollW, scrollH)

    dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

    if percent >= 1 then
        local gW, gH = 3, scrollH
        local gX, gY = scrollX, scrollY

        scrollingHover = exports.cr_core:isInSlot(gX, gY, gW, gH)

        if scrolling then
            if isCursorShowing() then
                if getKeyState("mouse1") then
                    local cx, cy = exports.cr_core:getCursorPosition()
                    local cy = math.min(math.max(cy, gY), gY + gH)
                    local y = (cy - gY) / (gH)
                    local num = percent * y

                    availableInteriorsMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _availableInteriorsMaxLines) + 1)))
                    availableInteriorsMaxLines = availableInteriorsMinLines + (_availableInteriorsMaxLines - 1)
                end
            else
                scrolling = false
            end
        end

        local multiplier = math.min(math.max((availableInteriorsMaxLines - (availableInteriorsMinLines - 1)) / percent, 0), 1)
        local multiplier2 = math.min(math.max((availableInteriorsMinLines - 1) / percent, 0), 1)
        local gY = gY + ((gH) * multiplier2)
        local gH = gH * multiplier

        local r, g, b = 255, 59, 59
        dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
    end
end

local function scrollDown()
    if panelHover then 
        if availableInteriorsMaxLines + 1 <= #interiorList then 
            availableInteriorsMinLines = availableInteriorsMinLines + 1
            availableInteriorsMaxLines = availableInteriorsMaxLines + 1
        end
    end
end

local function scrollUP()
    if panelHover then 
        if availableInteriorsMinLines - 1 > 0 then 
            availableInteriorsMinLines = availableInteriorsMinLines - 1
            availableInteriorsMaxLines = availableInteriorsMaxLines - 1
        end
    end
end

local function onKey(button, state)
    if button == "mouse_wheel_down" and state then 
        scrollDown()
    elseif button == "mouse_wheel_up" and state then
        scrollUP()
    elseif button == "mouse1" then
        if state then 
            if closeHover then 
                if isRender then 
                    isRender = false
                    
                    manageGameInteriorList("close")
                end
            elseif scrollingHover then 
                if not scrolling then 
                    scrolling = true
                end
            end
        else
            if scrolling then 
                scrolling = false
            end
        end
    end
end

function manageGameInteriorList(state)
    if state == "init" then 
        isRender = true

        exports.cr_dx:startFade("gameInteriorList", 
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

        manageTextbars("create")
        createRender("renderGameInteriorList", renderGameInteriorList)

        removeEventHandler("onClientKey", root, onKey)
        addEventHandler("onClientKey", root, onKey)
    elseif state == "close" then
        exports.cr_dx:startFade("gameInteriorList", 
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

function showGameInteriors(cmd)
    if exports.cr_permission:hasPermission(localPlayer, cmd) or exports.cr_core:getPlayerDeveloper(localPlayer) then 
        if not isRender then 
            manageGameInteriorList("init")
        else
            isRender = false

            manageGameInteriorList("close")
        end
    end
end
addCommandHandler("gameintlist", showGameInteriors, false, false)