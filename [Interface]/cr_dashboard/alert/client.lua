local start, startTick, state, specHover, w
alerts = {}

local lastClickTick = -5000

local AlertMinLines, AlertMaxLines, _AlertMaxLines, AlertScrolling

function createAlert(data)
    specHover = nil
    start = true
    startTick = getTickCount()
    lastClickTick = -5000
    if not state then
        alerts = data
        state = true
        addEventHandler("onClientRender", root, drawnAlert, true, "low-5")

        if alerts["isPermSelector"] then 
            bindKey("mouse_wheel_up", "down", AlertUP)
            bindKey("mouse_wheel_down", "down", AlertDown)

            AlertMinLines = 1
            AlertMaxLines = 15
            _AlertMaxLines = 15

            AlertScrolling = nil
        end 
    else
        if alerts['closeButton'] then 
            if alerts['closePressFunction'] then 
                if type(alerts['closePressFunction']) == "function" then
                    start = false
                    startTick = getTickCount()
                    alerts['closePressFunction']()
                end 
            end 
        end 
        
        for i = 1, #alerts["buttons"] do
            local data = alerts["buttons"][i]
            if data then
                if data["onClear"] then
                    if alerts["buttons"][i]["pressFunc"] then
                        if type(alerts["buttons"][i]["pressFunc"]) == "function" then
                            alerts["buttons"][i]["pressFunc"]()
                        elseif type(alerts["buttons"][i]["pressFunc"]) == "string" then
                            triggerEvent(alerts["buttons"][i]["pressFunc"], localPlayer)
                        end
                    end
                end
            end
        end
        
        alerts = data 
        removeEventHandler("onClientRender", root, drawnAlert)
        addEventHandler("onClientRender", root, drawnAlert, true, "low-5")
    end
    
    for i = 1, #alerts["buttons"] do
        local data = alerts["buttons"][i]
        if data then
            if data["onCreate"] then
                --alerts["buttons"][i]["onCreate"]()
                
                if type(alerts["buttons"][i]["onCreate"]) == "function" then
                    alerts["buttons"][i]["onCreate"]()
                elseif type(alerts["buttons"][i]["onCreate"]) == "string" then
                    triggerEvent(alerts["buttons"][i]["onCreate"], localPlayer)
                end
            end
        end
    end
end

function isAlertsActive()
    return state
end 

function clearAlerts()
    if alerts and alerts["buttons"] then
        if alerts['closeButton'] then 
            if alerts['closePressFunction'] then 
                if type(alerts['closePressFunction']) == "function" then
                    start = false
                    startTick = getTickCount()
                    alerts['closePressFunction']()
                end 
            end 
        end 

        for i = 1, #alerts["buttons"] do
            local data = alerts["buttons"][i]
            if data then
                if data["onClear"] and data["pressFunc"] then
                    --alerts["buttons"][i]["pressFunc"]()
                    
                    if type(alerts["buttons"][i]["pressFunc"]) == "function" then
                        alerts["buttons"][i]["pressFunc"]()
                    elseif type(alerts["buttons"][i]["pressFunc"]) == "string" then
                        triggerEvent(alerts["buttons"][i]["pressFunc"], localPlayer)
                    end
                end
            end
        end

        if alerts["isPermSelector"] then 
            unbindKey("mouse_wheel_up", "down", AlertUP)
            unbindKey("mouse_wheel_down", "down", AlertDown)

            AlertScrollBarHover = false 
        end 

        start = false
        startTick = getTickCount()
    end
end

function AlertUP()
    if AlertScrollBarHover then
        if AlertMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            AlertMinLines = AlertMinLines - 1
            AlertMaxLines = AlertMaxLines - 1
        end
    end
end 

function AlertDown()
    if AlertScrollBarHover then 
        local percent = #alerts['buttons']
        if AlertMaxLines + 1 <= percent then
            playSound(":cr_scoreboard/files/wheel.wav")
            AlertMinLines = AlertMinLines + 1
            AlertMaxLines = AlertMaxLines + 1
        end
    end 
end 

local sx, sy = guiGetScreenSize()
local startAnimationTime = 500
local startAnimation = "InOutQuad"
function drawnAlert()
    local alpha
    local nowTick = getTickCount()
    if start then
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            0, 0, 0,
            255, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph
    else
        
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            255, 0, 0,
            0, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph
        
        if progress >= 1 then
            alerts = {}
            state = false
            removeEventHandler("onClientRender", root, drawnAlert)
            alpha = 0
            return
        end
    end
    
    if alerts["isPermSelector"] then 
        local font = exports['cr_fonts']:getFont("Poppins-Medium", 12)

        local w, h = 300, 30 + ((20 + 5) * math.min((AlertMaxLines - AlertMinLines) + 1, #alerts["buttons"])) + 5 + 20 + 10

        local x, y = sx/2 - w/2, sy/2 - h/2
        dxDrawRectangle(x, y, w, h, tocolor(23, 23, 23, alpha * 0.9))

        specHover = nil
        if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
            specHover = "x"

            dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
        else 
            dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
        end 

        dxDrawText("Jogok szerkesztése", x + 15, y + 10, x + 15, y + 10 + 15 + 4, tocolor(156, 156, 156, alpha), 1, font, "left", "center", false, false, false, true)

        y = y + 30

        local _y = y

        AlertScrollBarHover = isInSlot(x, y, w, h, true)

        for i = AlertMinLines, AlertMaxLines do
            local v = alerts['buttons'][i]
            local name = v[1][2]
            local val = v[2]

            local w, h = 280, 20
            if isInSlot(x + 12, y, w, h, true) then 
                specHover = i

                dxDrawRectangle(x + 12, y, w, h, tocolor(242, 242, 242, alpha * 0.8))
                dxDrawText(name, x + 12 + 5, y, x + w, y + h + 4, tocolor(51, 51, 51,alpha), 1, font, "left", "center", false, false, false, true)
            else 
                dxDrawRectangle(x + 12, y, w, h, tocolor(51, 51, 51, alpha * 0.6))
                dxDrawText(name, x + 12 + 5, y, x + w, y + h + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font, "left", "center", false, false, false, true)
            end 

            local w2, h2 = 14, 14
            local nowX, nowY = x + 12 + w - 5 - w2, y + h/2 - h2/2
            dxDrawImage(nowX, nowY, w2, h2, "assets/images/checkbox-off.png", 0, 0, 0, tocolor(255, 255, 255, alpha * 0.25))

            if val then 
                dxDrawImage(nowX, nowY, w2, h2, "assets/images/checkbox-on.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
            end

            y = y + h + 5
        end 

        --[[ Alert List Scrollbar ]]

        local scrollx, scrolly = x + w - 3, _y
        local scrollh = ((20 + 5) * _AlertMaxLines) - 5

        dxDrawRectangle(scrollx, scrolly, 3, scrollh, tocolor(242, 242, 242, alpha * 0.6))
    
        local percent = #alerts['buttons']

        if AlertMaxLines > percent then
            AlertMinLines = 1
            AlertMaxLines = _AlertMaxLines
        end

        if percent >= 1 then
            local gW, gH = 3, scrollh
            local gX, gY = scrollx, scrolly

            AlertScrollingHover = isInSlot(gX, gY, gW, gH, true)

            if AlertScrolling then
                if isCursorShowing() then
                    if getKeyState("mouse1") then
                        local cx, cy = exports['cr_core']:getCursorPosition()
                        local cy = math.min(math.max(cy, gY), gY + gH)
                        local y = (cy - gY) / (gH)
                        local num = percent * y
                        AlertMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _AlertMaxLines) + 1)))
                        AlertMaxLines = AlertMinLines + (_AlertMaxLines - 1)
                    end
                else
                    AlertScrolling = false
                end
            end

            local multiplier = math.min(math.max((AlertMaxLines - (AlertMinLines - 1)) / percent, 0), 1)
            local multiplier2 = math.min(math.max((AlertMinLines - 1) / percent, 0), 1)
            local gY = gY + ((gH) * multiplier2)
            local gH = gH * multiplier

            dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
        end
        
        y = y + 5
 
        local textWidth = dxGetTextWidth('Mentés', 1, font, true) + 30
        if isInSlot(x + w/2 - textWidth/2, y, textWidth, 20, true) then
            if start then
                specHover = "save"
            end

            dxDrawRectangle(x + w/2 - textWidth/2, y, textWidth, 20, tocolor(97, 177, 90,alpha))
            dxDrawText('Mentés', x + w/2 - textWidth/2, y, x + w/2 - textWidth/2 + textWidth, y + 20 + 4, tocolor(242, 242, 242, alpha), 1, font, "center", "center", false, false, false, true)
        else
            dxDrawRectangle(x + w/2 - textWidth/2, y, textWidth, 20, tocolor(97, 177, 90,alpha*0.6))
            dxDrawText('Mentés', x + w/2 - textWidth/2, y, x + w/2 - textWidth/2 + textWidth, y + 20 + 4, tocolor(242, 242, 242, alpha * 0.7), 1, font, "center", "center", false, false, false, true)
        end
    else 
        local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
        local font2 = exports['cr_fonts']:getFont('Poppins-Regular', 10)
        local font3 = exports['cr_fonts']:getFont('Poppins-Medium', 14)

        local headerH = 40

        w = 55 
        if alerts['closeButton'] then 
            w = w + 25
        end 

        local _w = w

        if alerts["isPetSelector"] then 
            w = 125 + ((16 + 15) * 2) + 80
        end 

        local h = headerH

        local lines = alerts["title"][2] or 1
        local fontHeight = dxGetFontHeight(1, font2)
        local linesH = (fontHeight * lines)
        h = h + linesH + 10

        h = h + (#alerts["buttons"] * (20 + 5)) + 5

        h = h + (alerts["isPetSelector"] and 160 or 0)

        local textWidth = dxGetTextWidth(alerts['headerText'] or '', 1, font, true) + _w
        if textWidth >= w then
            w = textWidth
        end

        local textWidth = dxGetTextWidth(alerts["title"][1] or '', 1, font2, true) + _w
        if textWidth >= w then
            w = textWidth
        end

        local x, y = sx/2 - w/2, sy/2 - h/2

        --[[
            Header
        ]]

        dxDrawRectangle(x, y, w, h, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText(alerts['headerText'] or '', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

        closeHover = nil 
        if alerts['closeButton'] then 
            if isInSlot(x + w - 10 - 15, y + 10, 15, 15, true) then 
                closeHover = true 

                dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
            else 
                dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
            end 
        end 

        --[[
            Title text
        ]]

        dxDrawText(alerts["title"][1] or '', x, y + 40, x + w, y + 40 + (linesH) + 4, tocolor(242,242,242,alpha), 1, font2, "center", "center", false, false, false, true)

        --[[ 
            Buttons
        ]]
        specHover = nil
        specArrowHover = nil
        
        startY = y + 40 + (linesH) + 10

        for i = 1, #alerts["buttons"] do
            local data = alerts["buttons"][i]
            local name = data["name"]
            local r,g,b = 51, 51, 51
            if data['color'] then 
                r, g, b = unpack(data["color"])
            end 

            if data["type"] == "showBox" then
                local textWidth = dxGetTextWidth(data["text"], 1, font3, true)
                local w2 = textWidth
                
                if (textWidth + _w) >= w then
                    w = (textWidth + _w)
                end

                if isInSlot(x + w/2 - textWidth/2, startY, textWidth, 20, true) then
                    if start then
                        specHover = i   
                    end

                    dxDrawText(data["text"], x + w/2 - textWidth/2, startY, x + w/2 - textWidth/2 + textWidth, startY + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center", false, false, false, true)
                else 
                    dxDrawText(data["text"], x + w/2 - textWidth/2, startY, x + w/2 - textWidth/2 + textWidth, startY + 20 + 4, tocolor(242, 242, 242, alpha * 0.7), 1, font3, "center", "center", false, false, false, true)
                end 
            elseif data['type'] == "outputBox" then 
                local w2, h2 = w - (20 * 2), 2

                UpdatePos(data["boxName"], {x + w/2 - textWidth/2, startY, textWidth, 20 - h2 + 4})

                dxDrawRectangle(x + 20, startY + 20 - h2, w2, h2, tocolor(155, 155, 155, alpha * 0.6))

                if isInSlot(x + 20, startY, w2, 20, true) then 
                    UpdateAlpha(data["boxName"], tocolor(242, 242, 242, alpha))
                else 
                    UpdateAlpha(data["boxName"], tocolor(242, 242, 242, alpha * 0.7))
                end 
            elseif data["type"] == "petSelector" then 
                local w2, h2 = 125, 150
                local w3, h3 = 16, 31

                if isInSlot(x + w/2 - w2/2 - 15 - w3, startY + 150/2 - h3/2, w3, h3, true) then 
                    specArrowHover = {i, "left"}
                    
                    exports['cr_dx']:dxDrawImageAsTexture(x + w/2 - w2/2 - 15 - w3, startY + 150/2 - h3/2, w3, h3, ':cr_dashboard/assets/images/arrow.png', 180, 0, 0, tocolor(242, 242, 242, alpha))
                else 
                    exports['cr_dx']:dxDrawImageAsTexture(x + w/2 - w2/2 - 15 - w3, startY + 150/2 - h3/2, w3, h3, ':cr_dashboard/assets/images/arrow.png', 180, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
                end

                if isInSlot(x + w/2 + w2/2 + 15, startY + 150/2 - h3/2, w3, h3, true) then 
                    specArrowHover = {i, "right"}
                    
                    exports['cr_dx']:dxDrawImageAsTexture(x + w/2 + w2/2 + 15, startY + 150/2 - h3/2, w3, h3, ':cr_dashboard/assets/images/arrow.png', 0, 0, 0, tocolor(242, 242, 242, alpha))
                else 
                    exports['cr_dx']:dxDrawImageAsTexture(x + w/2 + w2/2 + 15, startY + 150/2 - h3/2, w3, h3, ':cr_dashboard/assets/images/arrow.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
                end

                dxDrawRectangle(x + w/2 - w2/2, startY, w2, h2, tocolor(23, 23, 23, alpha * 0.8))
                dxDrawImage(x + w/2 - w2/2, startY, w2, h2, "assets/pets/"..data["specData"][data["now"]]..".png", 0, 0, 0, tocolor(255, 255, 255, alpha))

                startY = startY + 160

                local textWidth = dxGetTextWidth(name, 1, font3, true) + _w
                local w2 = textWidth + 20

                if textWidth >= w then
                    w = textWidth
                end

                if isInSlot(x + w/2 - textWidth/2, startY, textWidth, 20, true) then
                    if start then
                        specHover = i   
                    end
                    dxDrawRectangle(x + w/2 - textWidth/2, startY, textWidth, 20, tocolor(r,g,b,alpha))
                    dxDrawText(name, x + w/2 - textWidth/2, startY, x + w/2 - textWidth/2 + textWidth, startY + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center", false, false, false, true)
                else
                    dxDrawRectangle(x + w/2 - textWidth/2, startY, textWidth, 20, tocolor(r,g,b,alpha*0.6))
                    dxDrawText(name, x + w/2 - textWidth/2, startY, x + w/2 - textWidth/2 + textWidth, startY + 20 + 4, tocolor(242, 242, 242, alpha * 0.7), 1, font3, "center", "center", false, false, false, true)
                end
            else -- Sima button
                local textWidth = dxGetTextWidth(name, 1, font3, true) + _w
                local w2 = textWidth + 20

                if textWidth >= w then
                    w = textWidth
                end

                if isInSlot(x + w/2 - textWidth/2, startY, textWidth, 20, true) then
                    if start then
                        specHover = i   
                    end
                    dxDrawRectangle(x + w/2 - textWidth/2, startY, textWidth, 20, tocolor(r,g,b,alpha))
                    dxDrawText(name, x + w/2 - textWidth/2, startY, x + w/2 - textWidth/2 + textWidth, startY + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center", false, false, false, true)
                else
                    dxDrawRectangle(x + w/2 - textWidth/2, startY, textWidth, 20, tocolor(r,g,b,alpha*0.6))
                    dxDrawText(name, x + w/2 - textWidth/2, startY, x + w/2 - textWidth/2 + textWidth, startY + 20 + 4, tocolor(242, 242, 242, alpha * 0.7), 1, font3, "center", "center", false, false, false, true)
                end
            end 

            startY = startY + 20 + 5
        end 
    end 
end

addEventHandler("onClientClick", root,
    function(b, s)
        if start then
            if b == "left" and s == "down" then
                if alerts["isPermSelector"] then 
                    if AlertScrollingHover then
                        AlertScrolling = true
                        AlertScrollingHover = false
                    elseif specHover then 
                        local now = getTickCount()
                        if now <= lastClickTick + 250 then
                            return
                        end
                        lastClickTick = getTickCount()
                        
                        if exports['cr_network']:getNetworkStatus() then
                            return
                        end

                        if specHover == "x" then 
                            if start then 
                                start = false
                                startTick = getTickCount()

                                if alerts["isPermSelector"] then 
                                    unbindKey("mouse_wheel_up", "down", AlertUP)
                                    unbindKey("mouse_wheel_down", "down", AlertDown)
                        
                                    AlertScrollBarHover = false 
                                end 
                            end 
                        elseif specHover == "save" then 
                            if start then 
                                start = false
                                startTick = getTickCount()

                                local permissions = {}
                                for k,v in pairs(alerts["buttons"]) do 
                                    permissions[v[1][1]] = v[2]
                                end 

                                triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, alerts["factionID"], exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(localPlayer) .. " #828282megváltoztatta " .. exports['cr_core']:getServerColor('yellow', true) .. cache["playerDatas"]["faction"][selectedFaction][3][alerts["playerID"]][2]:gsub("_", " ").. "#828282 jogosultságait!")
                                triggerLatentServerEvent("setPlayerPermissions", 5000, false, localPlayer, alerts["playerID"], alerts["factionID"], permissions)
                                exports['cr_infobox']:addBox("success", "Sikeres mentés!")

                                if alerts["isPermSelector"] then 
                                    unbindKey("mouse_wheel_up", "down", AlertUP)
                                    unbindKey("mouse_wheel_down", "down", AlertDown)
                        
                                    AlertScrollBarHover = false 
                                end 
                            end 
                        elseif tonumber(specHover) then 
                            alerts["buttons"][tonumber(specHover)][2] = not alerts["buttons"][tonumber(specHover)][2]
                        end 

                        specHover = nil
                    end 
                else 
                    if specHover or specArrowHover or closeHover then                    
                        if specArrowHover then 
                            if specArrowHover[2] == "left" then 
                                alerts["buttons"][specArrowHover[1]]["now"] = math.max(1, alerts["buttons"][specArrowHover[1]]["now"] - 1)
                                alerts["buttons"][2]["text"] = petTypePrices[alerts["buttons"][specArrowHover[1]]["now"]] .. " PP"
                            elseif specArrowHover[2] == "right" then 
                                alerts["buttons"][specArrowHover[1]]["now"] = math.min(#alerts["buttons"][specArrowHover[1]]["specData"], alerts["buttons"][specArrowHover[1]]["now"] + 1)
                                alerts["buttons"][2]["text"] = petTypePrices[alerts["buttons"][specArrowHover[1]]["now"]] .. " PP"
                            end 

                            specArrowHover = nil 
                        elseif tonumber(specHover) then
                            local now = getTickCount()
                            if now <= lastClickTick + 1000 then
                                return
                            end
                            lastClickTick = getTickCount()
                            
                            if exports['cr_network']:getNetworkStatus() then
                                return
                            end

                            if alerts["buttons"][tonumber(specHover)]["pressFunc"] then
                                if type(alerts["buttons"][tonumber(specHover)]["pressFunc"]) == "function" then
                                    start = false
                                    startTick = getTickCount()
                                    alerts["buttons"][tonumber(specHover)]["pressFunc"]()
                                elseif type(alerts["buttons"][tonumber(specHover)]["pressFunc"]) == "string" then
                                    start = false
                                    startTick = getTickCount()
                                    triggerEvent(alerts["buttons"][tonumber(specHover)]["pressFunc"], localPlayer)
                                end
                            end

                            specHover = nil
                        elseif closeHover then 
                            local now = getTickCount()
                            if now <= lastClickTick + 1000 then
                                return
                            end
                            lastClickTick = getTickCount()
                            
                            if exports['cr_network']:getNetworkStatus() then
                                return
                            end

                            if alerts['closePressFunction'] then 
                                if type(alerts['closePressFunction']) == "function" then
                                    start = false
                                    startTick = getTickCount()
                                    alerts['closePressFunction']()
                                end 
                            end 

                            closeHover = nil 
                        end
                    end
                end 
            elseif b == 'left' and s == 'up' then 
                if alerts['isPermSelector'] then 
                    if AlertScrolling then
                        AlertScrolling = false
                    end
                end 
            end
        end
    end
)

screenSize = {guiGetScreenSize()}
getCursorPos = getCursorPosition
function getCursorPosition()

    --outputChatBox(tostring(isCursorShowing()))
    if isCursorShowing() then
        --outputChatBox("asd")
        local x,y = getCursorPos()
        --outputChatBox("x"..tostring(x))
        --outputChatBox("y"..tostring(y))
        x, y = x * screenSize[1], y * screenSize[2] 
        return x,y
    else
        return -5000, -5000
    end
end

cursorState = isCursorShowing()
cursorX, cursorY = getCursorPosition()

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end

function isInSlot(xS,yS,wS,hS, ignore)
    if not state and not isPickerRender or ignore then
        if isCursorShowing() then
            local cursorX, cursorY = getCursorPosition()
            if isInBox(xS,yS,wS,hS, cursorX, cursorY) then
                return true
            else
                return false
            end
        end 
    end
end


function resetStartTickAlert()
    start = true
    startTick = getTickCount() - 10000
end

addEvent("dashboard.createNewBankCard", true)
addEventHandler("dashboard.createNewBankCard", localPlayer, 
    function(money )
        local blue = exports['cr_core']:getServerColor('green', true)
        local r,g,b = exports['cr_core']:getServerColor('green')
        local r2,g2,b2 = exports['cr_core']:getServerColor("red")
        local white = "#F2F2F2"
        local money = money

        createAlert(
            {
                ['headerText'] = 'Bank',
                ["title"] = {white .. "Biztosan létre szeretnél hozni egy új bankkártyát? " .. blue .. '$ ' .. money .. white .. "-ba/be fog kerülni!", 1},
                ["buttons"] = {
                    {
                        ["name"] = "Igen", 
                        ["pressFunc"] = function()
                            triggerEvent("createNewBankCard", localPlayer, money)
                        end,
                        ["onCreate"] = function()
                            money = money 
                        end,
                        ["color"] = {r, g, b},
                    },

                    {
                        ["name"] = "Nem", 
                        ["onClear"] = true,
                        ["pressFunc"] = function()
                        end,
                        ["color"] = {r2, g2, b2},
                    },
                },
            }
        )
    end 
)

addEvent("dashboard.deleteBankCard", true)
addEventHandler("dashboard.deleteBankCard", localPlayer, 
    function()
        local blue = exports['cr_core']:getServerColor('yellow', true)
        local r,g,b = exports['cr_core']:getServerColor('green')
        local r2,g2,b2 = exports['cr_core']:getServerColor("red")
        local white = "#F2F2F2"

        createAlert(
            {
                ['headerText'] = 'Bank',
                ["title"] = {white .. "Biztosan "..blue.."törölni"..white.." szeretnéd a bankkártyát?", 1},
                ["buttons"] = {
                    {
                        ["name"] = "Igen", 
                        ["pressFunc"] = function()
                            triggerEvent("deleteBankCard", localPlayer, localPlayer)
                        end,
                        ["color"] = {r, g, b},
                    },

                    {
                        ["name"] = "Nem", 
                        ["onClear"] = true,
                        ["pressFunc"] = function()
                        end,
                        ["color"] = {r2, g2, b2},
                    },
                },
            }
        )
    end 
)

addEvent('carshop.testDrive', true)
addEventHandler('carshop.testDrive', localPlayer, 
    function()
        local blue = exports['cr_core']:getServerColor('yellow', true)
        local green = exports['cr_core']:getServerColor('green', true)
        local white = "#F2F2F2"

        local r,g,b = exports['cr_core']:getServerColor('yellow')
        local r2,g2,b2 = exports['cr_core']:getServerColor("red")

        createAlert(
            {
                ['headerText'] = 'Járműkereskedés',
                ["title"] = {white .. "Biztosan szeretnéd a tesztvezetést? (Kaució: "..green.."$ 100"..white..")", 1},
                ["buttons"] = {
                    {
                        ["name"] = "Igen", 
                        ["pressFunc"] = function()
                            if exports['cr_core']:takeMoney(localPlayer, 100) then 
                                triggerEvent("carshop.testDrive.activate", localPlayer)
                            else 
                                exports['cr_infobox']:addBox('error', 'Nincs elég pénzed')
                            end 
                        end,
                        ["color"] = {r, g, b},
                    },

                    {
                        ["name"] = "Nem", 
                        ["onClear"] = true,
                        ["pressFunc"] = function()
                        end,
                        ["color"] = {r2, g2, b2},
                    },
                },
            }
        )
    end 
)

addEvent('boatshop.testDrive', true)
addEventHandler('boatshop.testDrive', localPlayer, 
    function()
        local blue = exports['cr_core']:getServerColor('yellow', true)
        local green = exports['cr_core']:getServerColor('green', true)
        local white = "#F2F2F2"

        local r,g,b = exports['cr_core']:getServerColor('yellow')
        local r2,g2,b2 = exports['cr_core']:getServerColor("red")

        createAlert(
            {
                ['headerText'] = 'Hajókereskedés',
                ["title"] = {white .. "Biztosan szeretnéd a tesztvezetést? (Kaució: "..green.."$ 100"..white..")", 1},
                ["buttons"] = {
                    {
                        ["name"] = "Igen", 
                        ["pressFunc"] = function()
                            if exports['cr_core']:takeMoney(localPlayer, 100) then 
                                triggerEvent("boatshop.testDrive.activate", localPlayer)
                            else 
                                exports['cr_infobox']:addBox('error', 'Nincs elég pénzed')
                            end 
                        end,
                        ["color"] = {r, g, b},
                    },

                    {
                        ["name"] = "Nem", 
                        ["onClear"] = true,
                        ["pressFunc"] = function()
                        end,
                        ["color"] = {r2, g2, b2},
                    },
                },
            }
        )
    end 
)

addEvent("dashboard.giveItemAlert", true)
addEventHandler("dashboard.giveItemAlert", localPlayer,
    function(hovered)
        local blue = exports['cr_core']:getServerColor('yellow', true)
        local white = "#F2F2F2"

        local r,g,b = exports['cr_core']:getServerColor('yellow')
        local r2,g2,b2 = exports['cr_core']:getServerColor("red")

        createAlert(
            {
                ['headerText'] = 'Inventory',
                ["title"] = {white .. "Gépeld be hány darab "..blue..exports['cr_inventory']:getItemName(hovered, val, nbt)..white.."-ot(et) szeretnél addolni!", 1},
                ["buttons"] = {
                    {
                        ["type"] = "outputBox",
                        ["color"] = {r, g, b},
                        ["boxName"] = "invBox",
                        ["onCreate"] = function()
                            CreateNewBar("invBox", {0, 0, 0, 0}, {3, "1", true, tocolor(242, 242, 242, 255), {'Poppins-Bold', 12}, 1, "center", "center", false, true}, 1, true)
                        end,
                    },

                    {
                        ["name"] = "Tovább", 
                        ["pressFunc"] = function()
                            count = GetText("invBox")
                            if tonumber(count) and tonumber(count) >= 1 then 
                                RemoveBar("invBox")

                                triggerEvent("giveSelectedItem", localPlayer, count)
                            else
                                resetStartTickAlert()
                                exports['cr_infobox']:addBox("error", "Minimum 1 db!")
                            end
                        end,
                        ["color"] = {r, g, b},
                    },

                    {
                        ["name"] = "Mégse", 
                        ["onClear"] = true,
                        ["pressFunc"] = function()
                            RemoveBar("invBox")
                        end,
                        ["color"] = {r2, g2, b2},
                    },
                },
            }
        )
    end 
)

addEvent("shop.buyItem", true)
addEventHandler("shop.buyItem", localPlayer, 
    function(type, data) 
        local blue = exports['cr_core']:getServerColor("yellow", true)
        local white = "#F2F2F2"

        local r,g,b = exports['cr_core']:getServerColor("green")
        local r2,g2,b2 = exports['cr_core']:getServerColor("red")
        local id, val, nbt, price = unpack(data)

        if type == 2 then 
            createAlert(
                {
                    ['headerText'] = 'Okmányiroda',
                    ['title'] = {white .. "Biztosan kiszeretnéd váltani a(z) "..blue..(exports['cr_inventory']:getItemName(id, val, nbt))..white.."-ot(et)?", 1},
                    ['buttons'] = {
                        {
                            ["name"] = "Igen", 
                            ["onCreate"] = function()
                                data = data
                                id, val, nbt, price = unpack(data)
                            end,
                            ["pressFunc"] = function()
                                local name = exports['cr_inventory']:getItemName(id, val, nbt)

                                if exports['cr_inventory']:isElementHasSpace(localPlayer, nil, id, val, nbt, 1) then
                                    if exports['cr_core']:takeMoney(localPlayer, tonumber(price)) then
                                        exports['cr_inventory']:giveItem(localPlayer, id, val, 1, 100, 0, 0, nbt)
                                        exports['cr_infobox']:addBox("success", "Sikeresen kiváltatottad a(z) "..name.."-ot(et)!")
                                    else
                                        exports['cr_infobox']:addBox("error", "Nincs elengedő pénzed ahhoz, hogy kiváltsd a(z) "..name.."-ot(et) ($ "..price..")")
                                    end
                                else
                                    exports['cr_infobox']:addBox("error", "Nincs elég hely az inventorydban!")
                                end
                            end,
                            ["color"] = {r, g, b},
                        },

                        {
                            ["name"] = "Nem", 
                            ["pressFunc"] = function()
                            end,
                            ["color"] = {r2, g2, b2},
                        },
                    }
                }
            )
        else 
            createAlert(
                {
                    ['headerText'] = 'Bolt',
                    ["title"] = {white .. "Gépeld be hány darab "..blue..exports['cr_inventory']:getItemName(id, val, nbt)..white.."-ot(et) szeretnél vásárolni!", 1},
                    ['closeButton'] = true, 
                    ['closePressFunction'] = function()
                        RemoveBar("shopBuyBox")
                    end,

                    ["buttons"] = {
                        {
                            ["type"] = "outputBox",
                            ["color"] = {r, g, b},
                            ["boxName"] = "shopBuyBox",
                            ["onCreate"] = function()
                                data = data
                                id, val, nbt, price = unpack(data)
                                CreateNewBar("shopBuyBox", {0, 0, 0, 0}, {3, "1", true, tocolor(242, 242, 242, 255), {"Poppins-Bold", 12}, 1, "center", "center", false, true}, 1)
                            end,
                        },

                        {
                            ["name"] = "Tovább", 
                            ["pressFunc"] = function()
                                count = GetText("shopBuyBox")
                                if tonumber(count) and tonumber(count) >= 1 then
                                    local maxStack = exports['cr_inventory']:GetData(id, val, nbt, "maxStack") or 1
                                    if tonumber(count) > maxStack then
                                        resetStartTickAlert()
                                        exports['cr_infobox']:addBox("warning", "Ebből maximum "..maxStack.." db-t vásárolhatsz!")
                                    else    
                                        RemoveBar("shopBuyBox")
                                        exports['cr_shop']:createFinishPage(
                                            {
                                                ["ID"] = 1,
                                                ["ItemData"] = {id, val, nbt}, 
                                                ["count"] = count,
                                                ["price"] = price,
                                            }
                                        )
                                    end
                                else
                                    resetStartTickAlert()
                                    exports['cr_infobox']:addBox("error", "Minimum 1 db!")
                                end
                            end,
                            ["color"] = {r, g, b},
                        },
                    },
                }
            )
        end 
    end 
)

addEvent("shop.buyItem2", true)
addEventHandler("shop.buyItem2", localPlayer, 
    function(type, data) 
        local blue = exports['cr_core']:getServerColor("yellow", true)
        local green = exports['cr_core']:getServerColor("green", true)
        local white = "#F2F2F2"

        local r,g,b = exports['cr_core']:getServerColor("green")
        local r2,g2,b2 = exports['cr_core']:getServerColor("red")

        local id, val, nbt = unpack(data["ItemData"])
        local count = data["count"]
        local price = data["price"]
        
        createAlert(
            {
                ['headerText'] = 'Bolt',
                ["title"] = {white .. "Szeretnél vásárolni "..blue..count..white.." darab "..blue..exports['cr_inventory']:getItemName(id, val, nbt)..white.."-ot(et) "..green.. '$ ' .. (count * price)..white.." ért?", 1},
                ["buttons"] = {
                    {
                        ["name"] = "Igen", 
                        ["pressFunc"] = function()
                            local name = exports['cr_inventory']:getItemName(id, val, nbt)

                            if exports['cr_inventory']:isElementHasSpace(localPlayer, nil, id, val, nbt, count) then
                                if exports['cr_core']:takeMoney(localPlayer, tonumber(price) * count, type == 2) then
                                    triggerLatentServerEvent("giveMoneyToFaction", 5000, false, localPlayer, localPlayer, 4, math.floor(price * 0.05)) -- GOVERMENT MONEY GIVING

                                    exports['cr_inventory']:giveItem(localPlayer, id, val, count, 100, 0, 0, nbt)
                                    exports['cr_infobox']:addBox("success", "Sikeres vásárlás!")
                                else
                                    exports['cr_infobox']:addBox("error", "Nincs elengedő pénzed ahhoz, hogy "..name.."-ot(et) vásárolj ($ "..(count * price)..")")
                                end
                            else
                                exports['cr_infobox']:addBox("error", "Nincs elég hely az inventorydban!")
                            end
                            --outputChatBox(name, 255, 255, 255, true)
                        end,
                        ["color"] = {r,g,b},
                    },

                    {
                        ["name"] = "Nem", 
                        ["onClear"] = true,
                        ["pressFunc"] = function()
                        end,
                        ["color"] = {r2, g2, b2},
                    },
                },
            }
        )
    end 
)

addEvent("mechanic.fixVehicle", true)
addEventHandler("mechanic.fixVehicle", localPlayer, 
    function()
        local blue = exports['cr_core']:getServerColor("yellow", true)
        local green = exports['cr_core']:getServerColor("green", true)
        local red = exports['cr_core']:getServerColor("red", true)
        local white = "#F2F2F2"
        local r,g,b = exports['cr_core']:getServerColor("green")
        local r2,g2,b2 = exports['cr_core']:getServerColor("red")
        
        createAlert(
            {
                ['headerText'] = 'Red County Mechanic Service',
                ["title"] = {white .. "Megszeretnéd "..blue.."javítani"..white.." a járműved "..green.."$ "..math.floor(10000 * (1 - localPlayer.vehicle.health / 1000))..white.." ért?", 1},
                ["buttons"] = {
                    {
                        ["name"] = "Igen", 
                        ["pressFunc"] = function()
                            if exports['cr_core']:takeMoney(localPlayer, math.floor(10000 * (1 - localPlayer.vehicle.health / 1000))) then 
                                triggerLatentServerEvent("giveMoneyToFaction", 5000, false, localPlayer, localPlayer, 3, math.floor(10000 * (1 - localPlayer.vehicle.health / 1000))) -- MECHANIC MONEY GIVING

                                triggerLatentServerEvent("fixVehicle", 5000, false, localPlayer, localPlayer.vehicle)                                

                                exports['cr_infobox']:addBox('success', 'Sikeresen megjavítottad a járműved!')
                            else
                                exports['cr_infobox']:addBox("error", "Nincs elengedő pénzed ahhoz, hogy megjavítsd a járműved!")
                            end 
                        end,
                        ["onCreate"] = function()
                        end,
                        ["color"] = {r,g,b},
                    },

                    {
                        ["name"] = "Nem", 
                        ["onClear"] = true,
                        ["pressFunc"] = function()
                        end,
                        ["color"] = {r2, g2, b2},
                    },
                },
            }
        )
    end 
)