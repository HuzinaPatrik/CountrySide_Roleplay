--script by theMark
toggleAllControls(true)

localPlayer:setData('cashregister >> code', false)
localPlayer:setData('opened >> element', false)
localPlayer:setData('minigame >> active', false)
local cinematicType = '#ff3b3b Eladó:'
localPlayer:setData('opened >> ped', false)
local openTick = getTickCount()
local selectedOption = 1
local toPush = false
local yProgress = false
local sx, sy = guiGetScreenSize()
local subtable = {}
local evacuation = false
local evacuationTick = getTickCount()
local zoom = math.min(1,0.75 + (sx - 1024) * (1 - 0.75) / (1600 - 1024))
function res(value) return value * zoom end
function resFont(value) return math.floor(res(value)) end
local activeTableValue = 1
local show = false
local cashRegisterCode = ''
local hovered, selected = false, false
local tick = getTickCount()
local state = true

local ignoredWeapons = {
    [5] = true,
    [8] = true,
    [9] = true,
    [16] = true,
    [17] = true,
    [18] = true,
    [41] = true,
    [42] = true,
    [43] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [14] = true,
    [15] = true,
    [46] = true,
}

addEventHandler('onClientPlayerTarget', root, function(target)
    if target and isElement(target) and target.type == 'ped' and target:getData('ped.type') == 'Eladó' and openTick + 1500 <= getTickCount() and not target:getData('active >> rob') and not target:getData('shop >> robbed') then
        local distance = getDistanceBetweenPoints3D(localPlayer.position, target.position)
        if distance >= 3 or localPlayer:getData('minigame >> active') then
            return
        end
        if getPressedButton('mouse2') then
            local activeLaw = exports.cr_robbery:getActiveLawMembers()

            if activeLaw >= 3 then 
                openTick = getTickCount()
                localPlayer:setData('opened >> ped', target)
                target:setData('active >> rob', true)
                if show then
                    return
                end
                if localPlayer:getWeapon() <= 0 then
                    return
                end

                if ignoredWeapons[localPlayer:getWeapon()] then 
                    return
                end

                dialogueOpen(target)
                activeTableValue = 1
                local randomTableTextValue = math.random(1, #randomTableText)
                if randomTableTextValue then
                    randomTableTextString = randomTableText[randomTableTextValue]
                end
                cinematicType = '#ff3b3b Eladó:'
                drawAnimatedText(pedText['first']['question'].text)
            else
                exports.cr_infobox:addBox("error", "A rablás elkezdéséhez minimum 3 rendvédelmisre van szükség.")
            end
        else
            openTick = getTickCount()
            destroyMinigame()
            if show then
                if activePanel == 3 then 
                    return
                end
                showTick = getTickCount()
                toggleAllControls(true)
                dialogueOpen(false)
            end
        end
    end
end
)


addEventHandler('onClientRender', root, function()
    -- idg kiszedve ez:D [dexter kérte.]
    --[[if show and not getKeyState('mouse2') then
        if activePanel == 3 then
            return
        end
        closePanel()
    end]]
end
)

function getPressedButton(button)
    if button then
        return getKeyState(button)
    end
end

function closePanel()
    triggerServerEvent('setElementAnimation', localPlayer, localPlayer, localPlayer:getData('opened >> ped') or false, '', '')
    state = false
    show = false
    local element = localPlayer:getData('opened >> ped')
    if isElement(element) and element then
        destroyMinigame()
        element:setData('active >> rob', false)
        tick = getTickCount()
        for _, v in pairs(handlers) do
            Timer(function()
                activeTableValue = 1
                toPush = true
                removeEventHandler(v.name, v.arg or root, v.func)
                selectedOption = 1
                openTick = getTickCount()
                activePanel = 1
                -- 
                localPlayer.frozen = false
                setPedControlState(localPlayer, 'aim_weapon', false)
                localPlayer:setAnimation()
                toggleAllControls(true)
            end, 3500, 1)
        end
        localPlayer:setData('opened >> ped', false)
    end
end

function destroyMinigame()
    exports.cr_minigame:stopMinigame('cr_shop')
    localPlayer.frozen = false
end


function dialogueOpen(element)
    if element then
        show = not show
        destroyMinigame()
        state = true
        tick = getTickCount()
        activeTableValue = 1
        openTick = getTickCount()
        local whatToCall = show and addEventHandler or removEventHandler
        toggleAllControls(false)
        Timer(function()
            localPlayer:setAnimation('shop', 'shp_gun_aim')
            setPedControlState(localPlayer, 'aim_weapon', true)
            -- localPlayer.frozen = true
        end, 250, 1)
        tick = getTickCount()
        for _, v in pairs(handlers) do
            removeEventHandler(v.name, v.arg or root, v.func)
            whatToCall(v.name, v.arg or root, v.func)
        end
        triggerServerEvent('setElementAnimation', localPlayer, localPlayer, element, 'ped', 'handsup')
        -- toggleAllControls(false)
    else
        local element = localPlayer:getData('opened >> ped') or false
        if not element or not isElement(element) then
            return
        end
        element:setData('active >> rob', false)
        tick = getTickCount()
        show = false
        state = false
        localPlayer.frozen = false
        localPlayer:setData('opened >> ped', false)
        toggleAllControls(true)
        localPlayer:setAnimation()
        Timer(function()
            for _, v in pairs(handlers) do
                removeEventHandler(v.name, v.arg or root, v.func)
            end
        end, 3900, 1)
    end
end

function renderDialoguePanel()
    local headerFont = exports.cr_fonts:getFont('Poppins-Medium', resFont(15))
    local buttonFont = exports.cr_fonts:getFont('Poppins-Medium', resFont(20))
    local selectButtonFont = exports.cr_fonts:getFont('Poppins-Medium', resFont(13))
    local r, g, b = exports.cr_core:getServerColor()
    local endPoint = state and sy - 150 or sy
    local y = interpolateBetween(state and sy or sy - 150, 0, 0, endPoint, 0, 0, (getTickCount() - tick) / 2000, 'Linear')
    yProgress = {progress = y, endPoint = endPoint}
    local alpha = interpolateBetween(state and 0 or 255, 0, 0, state and 255 or 0, 0, 0, (getTickCount() - tick) / 3500, 'Linear')
    dxDrawRectangle(Vector2(0, y), Vector2(sx, 150), tocolor(0, 0, 0))
    drawText(cinematicType .. '#FFFFFF' .. ' ' .. subtable[activeTableValue], Vector2(10, y), Vector2(sx, 150), tocolor(255, 255, 255), 1, buttonFont, 'left', 'center', false, false, false, true)
    if localPlayer:getData('opened >> ped') then
        local pedPosition = localPlayer:getData('opened >> ped').position
        local dist = getDistanceBetweenPoints3D(localPlayer.position, pedPosition)
        if dist >= 6 then
            closePanel()
            return
        end
    end
    if activePanel == 1 then
        for i = 1, 2, 1 do
            local buttonSize = Vector2(150, 30)
            local buttonPosition = Vector2(sx / 2 - buttonSize.x - (buttonSize.x + 50) * 2 / 2, y + buttonSize.y + 40)
            dxDrawRectangle(buttonPosition + Vector2(i * 165, 30), buttonSize, selectedOption == i and tocolor(r, g, b) or tocolor(45, 45, 45))
            drawText(pedText['first']['answers'][i], buttonPosition + Vector2(i * 165, 30), buttonSize, tocolor(255, 255, 255), 1, selectButtonFont, 'center', 'center', false, false, false, true)
        end
    end
end
-- addEventHandler('onClientRender', root, renderDialoguePanel)


addEventHandler('onClientKey', root, function(button, state)
    if not state or not toPush or not show then
        return
    end
    if button == 'arrow_l' then
        if selectedOption <= 1 then
            return
        end
        selectedOption = selectedOption - 1
    elseif button == 'arrow_r' then
        if selectedOption >= 2 then 
            return
        end
        selectedOption = selectedOption + 1
    elseif button == 'enter' and selectedOption then
        if selectedOption == 1 then
            print('kod')
            toggleAllControls(false)
            openTick = getTickCount()
            if yProgress.progress >= yProgress.endPoint then
                if toPush then
                    local element = localPlayer:getData('opened >> ped')
                    element:setData('shop >> robbed', true)
                    Timer(function()
                        closePanel()
                        localPlayer:setData('minigame >> active', true)
                        exports.cr_minigame:createMinigame(localPlayer, 3, 'cr_shop')
                        localPlayer.frozen = true
                    end, 3500, 1)
                end
            end
        elseif selectedOption == 2 then
            closePanel()
        end
        cinematicType = '#ff3b3b Én:'
        drawAnimatedText(pedText['first']['meAction'][selectedOption])
        activePanel = 2
    end
end 
)

function drawText(text, pos, size, ...)
    return dxDrawText(text, pos.x, pos.y, pos.x + size.x, pos.y + size.y, ...)
end

function drawAnimatedText(text)
    local text = tostring(text) or '..'
    activeTableValue = 1
    local active = ''
    local plusTimer = false
    toPush = false
    subtable = {}
    for i = 1, #text do
        if #subtable == i then
            return
        end
        if text == '#FFFFFF' then
            return
        end
        result = string.sub(text, 1, i)
        subtable[i] = result
    end
    local plusMilliSec = 20
    plusTimer = Timer(function()
        if activeTableValue >= #subtable then
            if isTimer(plusTimer) then
                killTimer(plusTimer)
            end
            toPush = true
            return
        end
        activeTableValue = activeTableValue + 1
    end, plusMilliSec, 0)
end

function isInSlot(position, size) 
    if isCursorShowing() then 
        cPosX, cPosY = getCursorPosition()
        cPosX, cPosY = cPosX * sx, cPosY * sy
        if ( (cPosX > position.x) and (cPosY > position.y) and (cPosX < position.x + size.x) and (cPosY < position.y + size.y) ) then 
            return true 
        else
            return false
        end
    end
end

--[[function selectSpeechPanelButton(button, state)
    if not state then
        return
    end
    if button == 'arrow_d' then
        if selectedButton >= 2 then
            return
        end
        selectedButton = selectedButton + 1
    elseif button == 'arrow_u' then
        if selectedButton <= 1 then
            return
        end
        selectedButton = selectedButton - 1
    elseif button == 'enter' then
        -- ide majd amúgy jön a minigame
        if randomTableTextString == 'first' then
            if selectedButton == 1 then
                closePanel()
                local element = localPlayer:getData('opened >> ped') or false
                if not element then
                    return
                end
                element:setData('shop >> robbed', true)
                Timer(function()
                    exports.cr_minigame:createMinigame(localPlayer, 3, 'cr_shop')
                end, 2800, 1)
            elseif selectedButton == 2 then
                closePanel()
            end
        elseif randomTableTextString == 'two' then
            if selectedButton == 1 then
                local element = localPlayer:getData('opened >> ped') or false
                if not element then
                    return
                end
                element:setData('shop >> robbed', true)
                closePanel()
                Timer(function()
                    exports.cr_minigame:createMinigame(localPlayer, 3, 'cr_shop')
                end, 2800, 1)
            elseif selectedButton == 2 then

            end
        end
    end
end]]

function sucessfullMinigameAndGenerateRandomPassword(length)
    local cache = {}
    local length = tonumber(length)
    if not length then
        return
    end
    for i = 1, 4 do
        randomPW = math.random(1, length or 4)
        table.insert(cache, randomPW)
        -- iprint(cache)
    end
    if #cache > 0 then
        local code1, code2, code3, code4 = unpack(cache)
        -- activePanel = 3
        activeTableValue = 1
        subtable = {}
        state = true
        dialogueOpen(true)
        cinematicType = '#ff3b3b Eladó:'
        drawAnimatedText(pedText['ForASuccessfulMinigame']['cashRegisterCode'][1] .. code1 .. code2 .. code3 .. code4)
        localPlayer:setData('cashregister >> code', code1 .. code2 .. code3 .. code4)
        Timer(function()
            toggleAllControls(true)
            localPlayer.frozen = false
            setPedControlState(localPlayer, 'aim_weapon', false)
            localPlayer:setAnimation()
            closePanel()
        end, 4000, 1)
    end
end


addEvent('[Minigame - StopMinigame]', true)
addEventHandler('[Minigame - StopMinigame]', root, function(player, minigametable)
    local minigameId, resourceName, success, failed, required = unpack(minigametable)
    if resourceName == 'cr_shop' then
        toggleAllControls(true)
        localPlayer:setData('minigame >> active', false)
        activePanel = 3
        if success >= required then
            sucessfullMinigameAndGenerateRandomPassword(4)
        else
            dialogueOpen(true)
            activePanel = 3
            cinematicType = '#ff3b3b Eladó:'
            drawAnimatedText('Megnyomtam a vészjelzőt a rendőrség bármikor megérkezhet!!!')
            -- ide alert (pozi kell meg hogy rabolják)
            exports.cr_dashboard:sendMessageToFaction(1, exports.cr_core:getServerSyntax("MDC", "error") .. "A " .. exports.cr_core:getServerColor("yellow", true) .. getZoneName(localPlayer.position) .. "#ffffff bolt rablása folyamatban van.")
            Timer(function()
                closePanel()
                localPlayer.frozen = false
            end, 3500, 1)
        end
    end
end
)

-- 1514


addEventHandler('onClientClick', root, function(button, state, x, y, wx, wy, wz, element)
    if button == 'left' and state == 'down' and element and isElement(element) and localPlayer:getData('cashregister >> code') then
        if element.model == 1514 or element.model == 1984 then
            local distance = getDistanceBetweenPoints3D(localPlayer.position, element.position)
            if distance >= 4 then
                return
            end
            evacuationShow = true
            localPlayer:setData('opened >> element', element)
            removeEventHandler('onClientRender', root, renderImgPanel)
            addEventHandler('onClientRender', root, renderImgPanel)
        end
    end
end
)

function closeCinematicPanelWithButton(button, state)
    if button == 'backspace' and state and show and toPush then
        closePanel()
        destroyMinigame()
    end
end
addEventHandler('onClientKey', root, closeCinematicPanelWithButton)

local drawProgress = 0
function renderImgPanel()
    local headerFont = exports.cr_fonts:getFont('Poppins-Medium', resFont(15))
    local buttonFont = exports.cr_fonts:getFont('Poppins-Medium', resFont(10))
    hovered, selected = false, false
    local elementDist = getDistanceBetweenPoints3D(localPlayer.position, localPlayer:getData('opened >> element').position)

    if elementDist >= 4 then
        closeImgPanel()
    end
    if evacuation and localPlayer:getData('opened >> element') then
        local drawProgress = interpolateBetween(0, 0, 0, 400, 0, 0, (getTickCount() - evacuationTick) / 12000, 'Linear')
        local pos, size = Vector2(sx / 2 - 400 / 2, sy - 60), Vector2(400, 35)
        dxDrawRectangle(pos, size, tocolor(0, 0, 0)) -- bg
        dxDrawRectangle(pos, Vector2(drawProgress, size.y), tocolor(255, 0, 0))
        drawText('Pénztárgép kiüritése folyamatban..', pos, Vector2(size.x, size.y), tocolor(255, 255, 255), 1, buttonFont, 'center', 'center')
        if drawProgress >= 400 then
            closeImgPanel()
        end
    else
        local x = 0
        local y = 0
        local count = 0
        local size = Vector2(1921, 1080)
        local pos = Vector2(sx / 2 - size.x / 2, sy / 2 - size.y / 2)
        local newPos = Vector2(sx / 2 - 40 / 2, sy / 2 + 55)
        dxDrawImage(pos, size, 'shoprobbery/files/_shop_robbery.png')
        drawText(string.rep('*', string.len(cashRegisterCode)), pos + Vector2(80, -35), size, tocolor(255, 255, 255), 1, buttonFont, 'center', 'center')
        -- dxDrawRectangle(newPos + Vector2(235, 40), Vector2(20, 40)) -- gomb pozi
        if isInSlot(newPos + Vector2(235, 40), Vector2(20, 40)) then
            hovered = 'ok'
            selected = 1
        end
    
        -- pénztárgépen való gombok
        for i = 1, 11, 1 do  
            -- dxDrawRectangle(newPos + Vector2(x, y), Vector2(15, 15), tocolor(0, 0, 0), true)
            if isInSlot(newPos + Vector2(x, y), Vector2(15, 15)) then
                hovered = 'button'
                selected = i
            end
            x = x + 30
            count = count + 1
            if count == 3 then
                x = 0
                y = y + 20
                count = 0
            end
        end
    end
end

function cashRegisterClick(button, state)
    if button == 'left' and state == 'down' and evacuationShow then
        if not selected then
            return
        end
        if hovered == 'button' then
            if #cashRegisterCode >= 4 then
                return
            end
            cashRegisterCode = cashRegisterCode  .. cashRegisterNumTable[selected]
            Sound('shoprobbery/files/press.mp3')
        elseif hovered == 'ok' then
            if cashRegisterCode == localPlayer:getData('cashregister >> code') then
                -- evacuationTick = getTickCount()
                -- evacuation = true
                localPlayer:setData('cashregister >> code', false)
                closeImgPanel()
                toggleAllControls(false)
                exports.cr_dx:startProgressBar('shoprobbery >> progressBar', {
                    {'Pénztárgép kiüritése folyamatban..', 12000}
                })
                Timer(function()
                    toggleAllControls(true)
                end, 12000, 1)
                local randomAction = math.random(1, 2)
                if randomAction == 2 then
                    -- ide is majd mehet egy alert a pdnek (ugyanoda mint az előzőnél)
                    exports.cr_dashboard:sendMessageToFaction(1, exports.cr_core:getServerSyntax("MDC", "error") .. "A " .. exports.cr_core:getServerColor("yellow", true) .. getZoneName(localPlayer.position) .. "#ffffff bolt rablása folyamatban van.")
                end
            else
                -- -- ide is majd mehet egy alert a pdnek (ugyanoda mint az előzőnél)
                exports.cr_dashboard:sendMessageToFaction(1, exports.cr_core:getServerSyntax("MDC", "error") .. "A " .. exports.cr_core:getServerColor("yellow", true) .. getZoneName(localPlayer.position) .. "#ffffff bolt rablása folyamatban van.")
                closeImgPanel()
            end
        end
    end
end
addEventHandler('onClientClick', root, cashRegisterClick)

local lastClickTick = -30000
addEventHandler('ProgressBarEnd', root, function(Id, data)
    if Id and data then
        if Id == 'shoprobbery >> progressBar' then
            iprint(data)
            if exports['cr_network']:getNetworkStatus() then return end 
            local now = getTickCount()
            local a = 30
            if now <= lastClickTick + a * 1000 then
                return
            end
            lastClickTick = getTickCount()
            local randomMoney = math.random(20000, 60000)
            if randomMoney then
                exports.cr_core:giveMoney(localPlayer, randomMoney)
            end
        end
    end
end
)


function closeImgPanel()
    removeEventHandler('onClientRender', root, renderImgPanel)
    evacuationShow = false
    localPlayer:setData('opened >> element', false)
    toggleAllControls(true)
end

addEventHandler('onClientKey', root, function(button, state)
    if button == 'backspace' and state and evacuationShow then 
        cashRegisterCode = string.sub(cashRegisterCode, 1, #cashRegisterCode - 1)
    end
end
)