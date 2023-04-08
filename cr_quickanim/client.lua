local screenX, screenY = guiGetScreenSize()

local hoverAnim = false
local cache = {}

local selectedAnim = 0
local iconPositions = false

local minLines = 1
local maxLines = 8
local _maxLines = maxLines

function onClientStart()
    local animations = exports.cr_json:jsonGET("quickAnims", true, {}) or {}

    if animations then 
        cache = animations
    end
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

function onClientStop()
    exports.cr_json:jsonSAVE("quickAnims", cache, true)
end
addEventHandler("onClientResourceStop", resourceRoot, onClientStop)

function renderQuickAnim()
    local alpha, progress = exports.cr_dx:getFade("quickAnimPanel")

    if alpha and progress then 
        if alpha <= 0 and progress >= 1 then 
            selectedAnim = 0
            minLines = 1
            maxLines = 8

            destroyRender("renderQuickAnim")
        end
    end

    local width, height = 214, 219
    local posX, posY = screenX / 2 - width / 2, screenY / 2 - height / 2

    local text = "Animok"
    local fontSize = 14
    local yOffset = 0

    if selectedAnim > _maxLines then 
        text = text .. "\n " .. (selectedAnim - _maxLines) .. " / " .. (maxLines - _maxLines)
        fontSize = 12
        yOffset = 5
    end

    local font = exports.cr_fonts:getFont("Poppins-SemiBold", fontSize)
    local font2 = exports.cr_fonts:getFont("Poppins-Medium", 8)

    local logoW, logoH = 40, 40
    local logoX, logoY = screenX / 2 - logoW / 2, screenY / 2 - logoH / 2 - 10

    dxDrawImage(posX, posY, width, height, "files/images/default/circle.png", 0, 0, 0, tocolor(44, 44, 44, alpha))
    dxDrawImage(logoX, logoY - yOffset, logoW, logoH, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText(text, posX, posY + 43 + yOffset, posX + width, posY + height, tocolor(255, 255, 255, alpha), 1, font, "center", "center")

    local iconW, iconH = 64, 64
    local iconX, iconY = posX + iconW / 2, posY + iconH / 2

    if not iconPositions then 
        iconPositions = {
            {
                x = iconX + 45, y = iconY - 35, icon = 1, textPosition = Vector2(30, 63), textRotation = Vector3(0, 0, 0)
            },

            {
                x = iconX + 98, y = iconY - 15, icon = 6, textPosition = Vector2(30, 63), textRotation = Vector3(0, 0, 0)
            },

            {
                x = iconX + 125, y = iconY + 43, icon = 5, textPosition = Vector2(30, 63), textRotation = Vector3(0, 0, 0)
            },

            {
                x = iconX + 97, y = iconY + 97, icon = 4, textPosition = Vector2(34, 63), textRotation = Vector3(0, 0, 0)
            },

            {
                x = iconX + 45, y = iconY + 118, icon = 3, textPosition = Vector2(30, 63), textRotation = Vector3(0, 0, 0)
            },

            {
                x = iconX - 8, y = iconY + 97, icon = 2, textPosition = Vector2(30, 63), textRotation = Vector3(0, 0, 0)
            },

            {
                x = iconX - 33, y = iconY + 42, icon = 1, textPosition = Vector2(30, 63), textRotation = Vector3(0, 0, 0)
            },
            
            {
                x = iconX - 10, y = iconY - 15, icon = 1, textPosition = Vector2(30, 63), textRotation = Vector3(0, 0, 0)
            },
        }
    end 

    local now = 1
    for index = minLines, maxLines do 
        local data = cache[index]

        if data then 
            local color = tocolor(44, 44, 44, alpha)
            local secondColor = tocolor(155, 155, 155, alpha)

            if selectedAnim == index then 
                color = tocolor(255, 59, 59, alpha)
                secondColor = tocolor(255, 255, 255, alpha)
            end

            local iconW, iconH = 64, 64
            local iconX, iconY = posX + iconW / 2, posY + iconH / 2

            dxDrawImage(posX, posY, width, height, "files/images/default/" .. now .. ".png", 0, 0, 0, color)

            local pos = iconPositions[now]
            local iconX, iconY = pos.x, pos.y
            local icon = data.typ or 1
            local animName = data.name

            local textX, textY = pos.textPosition.x, pos.textPosition.y
            local trx, try, trz = pos.textRotation.x, pos.textRotation.y, pos.textRotation.z

            dxDrawImage(iconX, iconY, iconW, iconH, "files/images/icons/" .. icon .. ".png", 0, 0, 0, secondColor)
            dxDrawText(animName, iconX + textX, iconY + textY, iconX + textX, iconY + textY, secondColor, 1, font2, "center", "bottom", false, false, false, false, false, trx, try, trz)

            now = now + 1
        end
    end

    if #cache < maxLines then 
        maxLines = #cache 
        minLines = maxLines - 7
    end 
end

function onKey(button, state)
    if button == "mouse3" then 
        if state then 
            if localPlayer:getData('keysDenied') then 
                return 
            end 

            if localPlayer.vehicle then 
                return
            end

            if #cache > 0 then 
                cancelEvent()

                if not checkRender("renderQuickAnim") then 
                    createRender("renderQuickAnim", renderQuickAnim)

                    exports.cr_dx:startFade("quickAnimPanel", 
                        {
                            startTick = getTickCount(),
                            lastUpdateTick = getTickCount(),
                            time = 250,
                            animation = "InOutQuad",
                            from = 0,
                            to = 255,
                            alpha = 0,
                            progress = 0,
                        }
                    )
                else
                    local selected = selectedAnim

                    if selectedAnim and cache[selected] then 
                        local data = cache[selected]
                        local animData = data.animationDetails

                        if animData then 
                            local animBlock = animData.blockName
                            local cachedAnim = animData.animName
                            local time = animData.time
                            local loop = animData.loop
                            local update = animData.update
                            local interruptable = animData.interruptable

                            local blockName, animName = getPedAnimation(localPlayer)

                            if animName ~= cachedAnim then 
                                if localPlayer.vehicle then 
                                    return
                                end

                                exports.cr_animation:applyAnimation(localPlayer, animBlock, cachedAnim, time, loop, update, interruptable)
                            end
                        end
                    end

                    exports.cr_dx:startFade("quickAnimPanel", 
                        {
                            startTick = getTickCount(),
                            lastUpdateTick = getTickCount(),
                            time = 250,
                            animation = "InOutQuad",
                            from = 255,
                            to = 0,
                            alpha = 255,
                            progress = 0,
                        }
                    )
                end
            end
        end
    elseif button == "mouse_wheel_down" and state then
        selectedAnim = math.min(selectedAnim + 1, #cache)

        if selectedAnim > maxLines then 
            minLines = minLines + 1
            maxLines = maxLines + 1
        end 
    elseif button == "mouse_wheel_up" and state then 
        selectedAnim = math.max(0, selectedAnim - 1)

        if math.max(selectedAnim, 1) < minLines then 
            minLines = minLines - 1
            maxLines = maxLines - 1
        end 
    end
end
addEventHandler("onClientKey", root, onKey)

function hasQuickAnim(name)
    local result = false

    for i = 1, #cache do 
        local v = cache[i]

        if v.name then 
            local gName = v.name

            if gName == name then 
                result = i
                break
            end
        end
    end

    return result
end

function addQuickAnim(name, block, animName, time, loop, update, interruptable)
    if name and block and animName then 
        table.insert(cache, {
            name = name,
            animationDetails = {
                blockName = block,
                animName = animName,
                time = time,
                loop = loop,
                update = update,
                interruptable = interruptable
            },
            typ = typ or 1
        })
    end

    if #cache > maxLines then 
        minLines = minLines + 1
        maxLines = maxLines + 1
    end 
end

function removeQuickAnim(name)
    local result = hasQuickAnim(name)

    if result then 
        table.remove(cache, result)

        if #cache <= 0 then 
            exports.cr_dx:startFade("quickAnimPanel", 
                {
                    startTick = getTickCount(),
                    lastUpdateTick = getTickCount(),
                    time = 250,
                    animation = "InOutQuad",
                    from = 255,
                    to = 0,
                    alpha = 255,
                    progress = 0,
                }
            )
        end

        return true
    end

    return result
end