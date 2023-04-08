local data
local element
local parentElement
local gData
local selected
local anim

function syncBullet(attacker, weapon, bodypart)
    if attacker and isElement(attacker) and attacker.type == "player" and tonumber(weapon) then
        if getPedTotalAmmo(attacker) > 1 then
            if weapon ~= 41 and weapon ~= 42 and weapon ~= 43 and not exports.cr_admin:getAdminDuty(localPlayer) then 
                local t = attacker:getData("weaponDatas") or {0,0,0}
                if t and t[2] and t[11] then
                    local id = t[2]
                    local weaponID = utf8.sub(md5(id), 1, 12)
                    local bulletsInBody = localPlayer:getData("bulletsInBody") or {}
                    local bulletID 
                    if t[11] and t[11][2] and t[11][2][2] then
                        bulletID = t[11][2][2] -- YEa bitch
                    else
                        bulletID = "Ismeretlen"
                    end

                    table.insert(bulletsInBody, 1, {bodypart, weapon, weaponID, bulletID})
                    localPlayer:setData("bulletsInBody", bulletsInBody)
                end 
            end
        end
    end
end
addEventHandler("onClientPlayerDamage", localPlayer, syncBullet)

function resetBullets()
    --localPlayer:setData("bulletsInBody", {})
end
addEventHandler("onClientPlayerSpawn", localPlayer, resetBullets)

local e = localPlayer:getData("parent") or localPlayer:getData("clone") or e
if isElement(e) then
    local p = e:getData("syncedBulletsBy")
    e:setData("syncedBulletsBy", nil)
    if isElement(p) then
        p:setData("syncedBulletsBy", nil)
    end
end

local closeInteraction = false

function getBullets(e)
    if exports['cr_dashboard']:isPlayerInFaction(localPlayer, 2) then
        --outputChatBox("asd")
        if not localPlayer:getData("syncedBulletsBy") then
            --outputChatBox("asd2")
            if not e:getData("syncedBulletsBy") then
                local parent = e:getData("parent") or e:getData("clone") or e
                local data = e:getData("bulletsInBody")
                --outputChatBox(#data)
                if data and #data >= 1 then
                    closeInteraction = false

                    exports.cr_dx:startFade("drawBulletsPanel", 
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

                    addEventHandler("onClientClick", root, clickHandler)

                    --outputChatBox("asd3")
                    exports['cr_chat']:createMessage(localPlayer, "átvizsgál egy testet ("..exports['cr_admin']:getAdminName(parent)..")", 1)
                    gData = data
                    element = e
                    parentElement = element:getData("clone")
                    e:setData("syncedBulletsBy", localPlayer)
                    localPlayer:setData("syncedBulletsBy", e)
                    bindKey("backspace", "down", closePanel)
                    selected = nil
                    anim = false
                    if not isRenderBullets then
                        addEventHandler("onClientRender", root, drawnBulletsPanel, true, "low-5")
                        isRenderBullets = true
                    end
                end
            else
                exports['cr_infobox']:addBox("error", "Valaki már vizsgálja a testet!")
            end
        end
    end
end

function closePanel()
    if not closeInteraction then 
        closeInteraction = true

        exports.cr_dx:startFade("drawBulletsPanel", 
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

        removeEventHandler("onClientClick", root, clickHandler)
    end
end

function closeBulletsPanel()
    localPlayer:setData("syncedBulletsBy", nil)
    if isElement(element) then
        element:setData("syncedBulletsBy", nil)
    end
    unbindKey("backspace", "down", closePanel)
    if isRenderBullets then
        removeEventHandler("onClientRender", root, drawnBulletsPanel)
        isRenderBullets = nil
    end

    closeInteraction = false
end

addEventHandler("onClientElementDataChange", root, 
    function(dName)
        if dName == "syncedBulletsBy" then
            local value = localPlayer:getData("syncedBulletsBy")
            if value == source then
                local value2 = source:getData("syncedBulletsBy")
                if localPlayer ~= value2 then
                    --exports['cr_minigame']:stopMinigame(localPlayer, 2, true)
                    localPlayer:setData("syncedBulletsBy", nil)
                    closeBulletsPanel()
                    --source:setData("syncedBulletsBy", nil)
                end
            end
        end
    end
)

addEventHandler("onClientPlayerQuit", root,
    function()
        if source:getData("syncedBulletsBy") then -- Akit gyógyítanak
            if localPlayer:getData("syncedBulletsBy") then
                local value = source:getData("syncedBulletsBy")
                local value2 = localPlayer:getData("syncedBulletsBy")
                if value == localPlayer and source == value2 then
                    --exports['cr_minigame']:stopMinigame(localPlayer, 2, true)
                    localPlayer:setData("isRespawningE", nil)
                    source:setData("isRespawningE", nil)
                    closeBulletsPanel()
                end
            end
        end
    end
)

local hunName = {
    [3] = "törzsben",
    [4] = "seggben",
    [5] = "bal kézben",
    [6] = "jobb kézben",
    [7] = "bal lábban",
    [8] = "jobb lábban",
    [9] = "fejben",
}

function getBullet(k)
    --local bulletsInBody = gData
    selected = nil
    anim = false
    local weaponID = gData[k][3]
    local bulletID = gData[k][4]

    exports['cr_inventory']:giveItem(localPlayer, 131, {weaponID, bulletID})
    table.remove(gData, k)
    
    element:setData("bulletsInBody", gData)
    exports['cr_chat']:createMessage(localPlayer, "kioperál egy használt lőszert "..exports['cr_admin']:getAdminName(element).." testéből", 1)
end

local sx, sy = guiGetScreenSize()

local animatedWidth = 0
local alpha = 255
local closeHover = false

function drawnBulletsPanel()
    local elementToCheck = parentElement and parentElement or element

    if not isElement(elementToCheck) or getDistanceBetweenPoints3D(elementToCheck.position, localPlayer.position) >= 3 then
        closePanel()
    end

    local alpha, progress = exports.cr_dx:getFade("drawBulletsPanel")
    if alpha and progress then 
        if progress >= 1 and alpha <= 0 then 
            closeBulletsPanel()
        end
    end

    local font = exports['cr_fonts']:getFont("Poppins-SemiBold", 16)
    local font2 = exports['cr_fonts']:getFont("Poppins-Medium", 12)

    local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)
    local redR, redG, redB = exports.cr_core:getServerColor("red", false)
    local yellowR, yellowG, yellowB = exports.cr_core:getServerColor("yellow", false)

    local fontHeight = dxGetFontHeight(1, font)

    -- gData = {1, 2, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5}

    local defaultHeight = 55
    local rowH = 25

    local h = defaultHeight + ((fontHeight - 2) * #gData)
    -- local h = defaultHeight + ((rowH + (fontHeight / 2) - 2) * #gData)

    local panelW, panelH = 300, h
    local panelX, panelY = sx / 2 - panelW / 2, sy / 2 - panelH / 2

    dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(51, 51, 51, alpha * 0.8))

    local closeW, closeH = 15, 15
    local closeX, closeY = panelX + panelW - closeW - 10, panelY + 10
    local inSlot = exports.cr_core:isInSlot(closeX, closeY, closeW, closeH)
    local closeColor = tocolor(redR, redG, redB, alpha * 0.6)

    closeHover = nil
    if inSlot then 
        closeColor = tocolor(redR, redG, redB, alpha)
        closeHover = true
    end

    exports.cr_dx:dxDrawImageAsTexture(closeX, closeY, closeW, closeH, ":cr_ambulance/assets/images/close.png", 0, 0, 0, closeColor)

    local logoW, logoH = 26, 30
    local logoX, logoY = panelX + 10, panelY + 8

    exports.cr_dx:dxDrawImageAsTexture(logoX, logoY, logoW, logoH, ":cr_ambulance/assets/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("Golyók kioperálása", logoX + logoW + 10, logoY + 4, logoX + logoW, logoY + logoH, tocolor(255, 255, 255, alpha), 1, font, "left", "center")
    
    selected = nil
    local startY = panelY + defaultHeight - 5

    for k = 1, #gData do
        local v = gData[k]

        if v then 
            local bodypart, weapon, weaponID, bulletID = v[1], v[2], v[3], v[4]

            local rowW = panelW - 20
            local rowX, rowY = panelX + 10, startY
            local inSlot = exports.cr_core:isInSlot(rowX, rowY, rowW, rowH)
            local rowColor = tocolor(51, 51, 51, alpha * 0.5)
            local textColor = tocolor(242, 242, 242, alpha)

            if inSlot then 
                rowColor = tocolor(242, 242, 242, alpha)
                textColor = tocolor(51, 51, 51, alpha)
            end

            dxDrawRectangle(rowX, rowY, rowW, rowH, rowColor)
            dxDrawText("Golyó a " .. hunName[bodypart], rowX + 5, rowY + 2, rowX + rowW, rowY + rowH, textColor, 1, font2, "left", "center")

            local buttonW, buttonH = 80, rowH - 5
            local buttonX, buttonY = rowX + rowW - buttonW - 5, rowY + 2.5
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
            local buttonColor = tocolor(greenR, greenG, greenB, alpha * 0.7)
            local textColor = tocolor(255, 255, 255, alpha * 0.6)

            if inSlot then 
                buttonColor = tocolor(greenR, greenG, greenB, alpha)
                textColor = tocolor(255, 255, 255, alpha)

                selected = k
                local activeWidth = anim and animatedWidth or buttonW

                dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, tocolor(greenR, greenG, greenB, alpha * 0.7))
                dxDrawRectangle(buttonX, buttonY, activeWidth, buttonH, buttonColor)
                dxDrawText("Kioperálás", buttonX, buttonY + 2, buttonX + buttonW, buttonY + buttonH, textColor, 1, font2, "center", "center")

                if anim then
                    local now = getTickCount()
                    local elapsedTime = now - startTime
                    local duration = endTime - startTime
                    local progress = elapsedTime / duration
        
                    animatedWidth = interpolateBetween ( 
                        0, 0, 0,
                        buttonW, 0, 0,
                        progress, "InOutQuad"
                    )
        
                    if progress >= 1 then
                        if not closeInteraction then
                            getBullet(k)
                            closePanel()
                        end
                    end
        
                    -- dxDrawRectangle(buttonX, buttonY, animatedWidth, buttonH, tocolor(redR, redG, redB, alpha))
                end
            else
                dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
                dxDrawText("Kioperálás", buttonX, buttonY + 2, buttonX + buttonW, buttonY + buttonH, textColor, 1, font2, "center", "center")
            end
        end
        
        startY = startY + fontHeight - 2
    end
end
-- isRenderBullets = true
-- addEventHandler("onClientRender", root, drawnBulletsPanel)

function clickHandler(button, state)
    if button == "left" then
        if selected then
            local v = gData[selected]
            local bodypart, weapon, weaponID, bulletID = v[1], v[2], v[3], v[4]
            
            startTime = getTickCount()
            endTime = startTime + 1000
            if state == "down" then
                anim = true
            else
                anim = false
            end
        end

        if closeHover and state == "down" then 
            closePanel()

            closeHover = false
        end
    end
end