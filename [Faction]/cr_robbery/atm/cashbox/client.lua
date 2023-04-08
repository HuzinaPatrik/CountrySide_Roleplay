local screenX, screenY = guiGetScreenSize()

local maxRotation = 90
local oldRotationY = 0
local currentRotationY = 0
local lastTick = 0

local availableAngles = {}
local lockPickRotation = {rotX = 0, rotY = 0}

local buttonCheckTimer = false
local buttonTimer = false

local soundElement = false
local isRender = false

local currentHits = 0
local maxHits = 4
local currentItemDbId = false

local minCashboxValue = 0
local maxCashboxValue = 15000
local lastPayOutTick = -10000

for i = 5, 360, 5 do 
    table.insert(availableAngles, i)
end

local lockPickData = {
    range = availableAngles[math.random(1, #availableAngles)],

    barData = {
        interpolationValue = {},
        lastValue = {}
    }
}

function math.clamp(min, max, value)
    return math.min(math.max(value, min), max)
end

function renderLockPicking()
    local alpha, progress = exports.cr_dx:getFade("lockPickMinigame")
    
    if alpha and progress then 
        if progress >= 1 and alpha <= 0 then 
            if not isRender then 
                currentItemDbId = false
                destroyRender("renderLockPicking")

                currentHits = 0
                currentRotationY = 0
                lockPickRotation.rotX = 0
                lockPickData.barData = {
                    interpolationValue = {},
                    lastValue = {}
                }

                return
            end
        end
    end

    local font = exports.cr_fonts:getFont("Poppins-SemiBold", 15)
    local font2 = exports.cr_fonts:getFont("Poppins-SemiBold", 14)
    local redR, redG, redB = exports.cr_core:getServerColor("red", false)

    local panelW, panelH = 520, 180
    local panelX, panelY = screenX / 2 - panelW / 2, screenY / 2 - panelH / 2

    dxDrawImage(panelX, panelY, panelW, panelH, "atm/files/images/locked_cashbox.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

    local barW, barH = 229, 20
    local barX, barY = panelX + 12 + barW / 2, panelY - barH - 30

    dxDrawBar(barX, barY, barW, barH, 1, tocolor(189, 189, 189, alpha), tocolor(redR, redG, redB, alpha * 0.8), currentHits, "currentHits", 4)

    shadowedText("Feltört zárak", barX, barY - 20, barX + barW, barY + barH, tocolor(255, 255, 255, alpha), 1, font2, "left", "top", math.min(100, alpha))
    dxDrawText("Feltört zárak", barX, barY - 20, barX + barW, barY + barH, tocolor(255, 255, 255, alpha), 1, font2, "left", "top")

    shadowedText(currentHits .. " / " .. maxHits, barX, barY - 20, barX + barW, barY + barH, tocolor(255, 255, 255, alpha), 1, font2, "right", "top", math.min(100, alpha))
    dxDrawText(currentHits .. " / " .. maxHits, barX, barY - 20, barX + barW, barY + barH, tocolor(255, 255, 255, alpha), 1, font2, "right", "top")

    local imageW, imageH = 21, 21
    local imageX, imageY = panelX + 37 + imageW, panelY + 102

    dxDrawImage(imageX, imageY, imageW, imageH, "atm/files/images/lock.png", currentRotationY, 0, 0, tocolor(255, 255, 255, alpha))

    local imageW, imageH = 59, 160
    local imageX, imageY = panelX + 39, panelY + 27

    dxDrawImage(imageX, imageY, imageW, imageH, "atm/files/images/lockpick.png", lockPickRotation.rotX, 0, 0, tocolor(255, 255, 255, alpha))

    local imageW, imageH = 200, 150
    local imageX, imageY = panelX + 50, panelY + 85

    dxDrawImage(imageX, imageY, imageW, imageH, "atm/files/images/screwdriver.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

    shadowedText("[A-D] Zárfésű mozgatása", panelX + 12, panelY, panelX + panelW, panelY + 50 + panelH, tocolor(255, 255, 255, alpha), 1, font, "left", "bottom", math.min(100, alpha))
    dxDrawText("[A-D] Zárfésű mozgatása", panelX + 12, panelY, panelX + panelW, panelY + 50 + panelH, tocolor(255, 255, 255, alpha), 1, font, "left", "bottom")

    shadowedText("[Space] Nyitás megerősítése", panelX + 12, panelY, panelX + panelW, panelY + 73 + panelH, tocolor(255, 255, 255, alpha), 1, font, "left", "bottom", math.min(100, alpha))
    dxDrawText("[Space] Nyitás megerősítése", panelX + 12, panelY, panelX + panelW, panelY + 73 + panelH, tocolor(255, 255, 255, alpha), 1, font, "left", "bottom")
end

function dxDrawBar(x, y, w, h, borderSize, bgColor, color, value, name, segments, alpha)
    local borderSize = borderSize or 0
    local alpha = alpha or 255
    local bgColor = bgColor or tocolor(51, 51, 51, alpha * 0.8)
    local color = color or tocolor(255, 50, 255, alpha * 0.8)
    local segments = segments or 3

    local w = math.ceil(w) - 2 * (segments - 1)
    local h = math.ceil(h)

    local w = w / segments
    local value = math.min(100, value)

    local interpolationValue = false

    if name then 
        if lockPickData.barData.lastValue[name] then 
            if lockPickData.barData.lastValue[name] ~= value then 
                if not lockPickData.barData.interpolationValue[name] then 
                    lockPickData.barData.interpolationValue[name] = {}
                end

                lockPickData.barData.interpolationValue[name].startTick = getTickCount()
                lockPickData.barData.interpolationValue[name].oldValue = lockPickData.barData.lastValue[name]
                lockPickData.barData.lastValue[name] = value
            end
        else
            lockPickData.barData.lastValue[name] = value
        end

        if lockPickData.barData.interpolationValue[name] then 
            local elapsedTime = getTickCount() - lockPickData.barData.interpolationValue[name].startTick
            local duration = 500
            local progress = elapsedTime / duration

            interpolationValue = interpolateBetween(lockPickData.barData.interpolationValue[name].oldValue, 0, 0, value, 0, 0, progress, "InOutQuad")
            value = interpolationValue
        end
    end

    local progressPerSegment = 4 / segments
    local remainingProgress = value % progressPerSegment
    local fullSegments = math.floor(value / progressPerSegment)
    local inUseSegments = math.ceil(value / progressPerSegment)

    local startX = x
    local doubleBorder = borderSize * 2

    for i = 1, segments do 
        if borderSize > 0 then 
            dxDrawRectangle(startX, y, w, borderSize, tocolor(51, 51, 51, alpha))
			dxDrawRectangle(startX, y + h - borderSize, w, borderSize, tocolor(51, 51, 51, alpha))
			dxDrawRectangle(startX, y + borderSize, borderSize, h - doubleBorder, tocolor(51, 51, 51, alpha))
			dxDrawRectangle(startX + w - borderSize, y + borderSize, borderSize, h - doubleBorder, tocolor(51, 51, 51, alpha))
        end

        dxDrawRectangle(startX + borderSize, y + borderSize, w - doubleBorder, h - doubleBorder, bgColor)
        
        if i <= fullSegments then
			dxDrawRectangle(startX + borderSize, y + borderSize, w - doubleBorder, h - doubleBorder, color)
		elseif i == inUseSegments and remainingProgress > 0 then
			dxDrawRectangle(startX + borderSize, y + borderSize, (w - doubleBorder) / progressPerSegment * remainingProgress, h - doubleBorder, color)
		end

        startX = startX + w + 4
    end
end

function manageLockpickMinigame(state, dbId)
    if state == "init" then 
        createRender("renderLockPicking", renderLockPicking)
        addEventHandler("onClientKey", root, onKey)
        addEventHandler("onClientPlayerWasted", localPlayer, onWasted)

        exports.cr_dx:startFade("lockPickMinigame", 
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

        isRender = true
        currentItemDbId = dbId
        exports.cr_controls:toggleAllControls(false, "instant")

        localPlayer:setData("forceAnimation", {"bd_fire", "wash_up"})
        exports.cr_chat:createMessage(localPlayer, "elkezdett feltörni egy pénzkazettát", 1)
    elseif state == "exit" then
        exports.cr_dx:startFade("lockPickMinigame", 
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

        exports.cr_inventory:findAndUseItemByIDAndDBID(317, currentItemDbId)
        exports.cr_controls:toggleAllControls(true, "instant")
        removeEventHandler("onClientKey", root, onKey)
        removeEventHandler("onClientPlayerWasted", localPlayer, onWasted)

        isRender = false
        localPlayer:setData("openingCashbox", nil)
        localPlayer:setData("forceAnimation", {"", ""})
    end
end

function isLockpickingMinigameActive()
    return isRender
end

function processMinigame(button, fastSpeed)
    if button == "a" then 
        lockPickRotation.rotX = lockPickRotation.rotX - 5

        if math.abs(lockPickRotation.rotX) > 360 then 
            lockPickRotation.rotX = 0
        end
        
        if math.abs(lockPickRotation.rotX) == lockPickData.range then 
            soundElement = playSound("atm/files/sounds/lock.mp3")

            if fastSpeed then 
                setSoundVolume(soundElement, 0.08)
            end
        end
    elseif button == "d" then
        lockPickRotation.rotX = lockPickRotation.rotX + 5

        if math.abs(lockPickRotation.rotX) > 360 then 
            lockPickRotation.rotX = 0
        end

        if math.abs(lockPickRotation.rotX) == lockPickData.range then 
            soundElement = playSound("atm/files/sounds/lock.mp3")

            if fastSpeed then 
                setSoundVolume(soundElement, 0.08)
            end
        end
    end
end

function onKey(button, state)
    if button == "a" then 
        if state then 
            processMinigame(button)

            if isTimer(buttonCheckTimer) then 
                killTimer(buttonCheckTimer)
                buttonCheckTimer = nil
            end

            if isTimer(buttonTimer) then 
                killTimer(buttonTimer)
                buttonTimer = nil
            end

            buttonCheckTimer = setTimer(
                function()
                    if getKeyState(button) then 
                        buttonTimer = setTimer(processMinigame, 100, 0, button, true)
                    end
                end, 500, 1
            )
        else
            if isTimer(buttonCheckTimer) then 
                killTimer(buttonCheckTimer)
                buttonCheckTimer = nil
            end

            if isTimer(buttonTimer) then 
                killTimer(buttonTimer)
                buttonTimer = nil
            end
        end
    elseif button == "d" then
        if state then 
            processMinigame(button)

            if isTimer(buttonCheckTimer) then 
                killTimer(buttonCheckTimer)
                buttonCheckTimer = nil
            end

            if isTimer(buttonTimer) then 
                killTimer(buttonTimer)
                buttonTimer = nil
            end

            buttonCheckTimer = setTimer(
                function()
                    if getKeyState(button) then 
                        buttonTimer = setTimer(processMinigame, 100, 0, button, true)
                    end
                end, 500, 1
            )
        else
            if isTimer(buttonCheckTimer) then 
                killTimer(buttonCheckTimer)
                buttonCheckTimer = nil
            end

            if isTimer(buttonTimer) then 
                killTimer(buttonTimer)
                buttonTimer = nil
            end
        end
    elseif button == "space" then
        if state then 
            if math.abs(lockPickRotation.rotX) == lockPickData.range then 
                if currentHits + 1 < maxHits then 
                    currentHits = currentHits + 1
                    lockPickData.range = availableAngles[math.random(1, #availableAngles)]

                    playSound("atm/files/sounds/hit.mp3")
                else 
                    currentHits = currentHits + 1
                    playSound("atm/files/sounds/hit.mp3")

                    manageLockpickMinigame("exit")

                    if not exports.cr_network:getNetworkStatus() then 
                        local nowTick = getTickCount()
                        local count = 10
                    
                        if nowTick <= lastPayOutTick + count * 1000 then
                            return
                        end
                    
                        lastPayOutTick = getTickCount()
                        local randomMoney = math.random(minCashboxValue, maxCashboxValue)

                        exports.cr_core:giveMoney(localPlayer, randomMoney, false)
                        exports.cr_infobox:addBox("success", "Sikeresen felnyitottad a pénzkazettát, kaptál " .. randomMoney .. " dollárt.")
                    end
                end

                if isTimer(buttonCheckTimer) then 
                    killTimer(buttonCheckTimer)
                    buttonCheckTimer = nil
                end
    
                if isTimer(buttonTimer) then 
                    killTimer(buttonTimer)
                    buttonTimer = nil
                end
            else
                manageLockpickMinigame("exit")

                exports.cr_infobox:addBox("error", "A feltörés közben a zárfésű beletört a zárba.")
            end
        end
    end
end

function onWasted()
    if isRender then 
        manageLockpickMinigame("exit")
    end
end