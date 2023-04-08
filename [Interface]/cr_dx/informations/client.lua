local data, w = {}, 0

function openInformationsPanel(data)
    startFade("informationsPanel", 
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

    w = 0 
    
    informations = data["texts"] 
    createRender("renderInformations", renderInformations)
    isRender = true 
    hoverText = data["hoverText"] or ""
    altText = data["altText"] or ""
    minLines = data["minLines"]
    panelType = data["type"]
    if data["maxLines"] >= #data["texts"] then 
        data["maxLines"] = #data["texts"]
    end 
    maxLines = data["maxLines"]
    _maxLines = data["maxLines"]

    specHover = nil

    local font = exports['cr_fonts']:getFont("Poppins-SemiBold", 16)
    local font2 = exports['cr_fonts']:getFont("Poppins-Bold", 14)
    local font3 = exports['cr_fonts']:getFont("Poppins-Medium", 14)

    scrolling = false 
    BindScrollBarKeys()

    bindKey("backspace", "down", closeInformationsPanel)
    
    local w2 = dxGetTextWidth(hoverText, 1, font, true) + 100 
    if w2 > w then 
        w = w2 
    end 

    local w2 = dxGetTextWidth(altText, 1, font2, true) + 100 
    if w2 > w then 
        w = w2 
    end 

    for k,v in pairs(informations) do 
        if type(v) == "table" then 
            local w2 = dxGetTextWidth(v[1], 1, font3, true) + dxGetTextWidth(v[2], 1, font3, true) + 100

            if panelType == "anims" then 
                local w2 = dxGetTextWidth(v[1], 1, font3, true) + dxGetTextWidth(v[2], 1, font3, true) + 300

                if w2 > w then 
                    w = w2
                end
            else
                if w2 > w then 
                    w = w2 
                end 
            end
        else 
            local w2 = dxGetTextWidth(v, 1, font3, true) + 100

            if w2 > w then 
                w = w2 
            end 
        end 
    end 

    local h = 60 + ((20 + 3) * ((maxLines - minLines) + 1)) + 12

    local data = {
        ["name"] = "Információs Lista Panel: " .. hoverText,
        ["invisible"] = true,
        ["showing"] = true,
        ["width"] = w,
        ["height"] = 60,
        ["x"] = sx/2 - w/2,
        ["y"] = sy/2- h/2,
    }
    data['defPositions'] = fromJSON(toJSON(data))

    exports['cr_interface']:createNode('dxInformationsPanel' .. hoverText, data)
    exports['cr_interface']:setNode("dxInformationsPanel" .. hoverText, "active", true)
    exports['cr_interface']:setNode("dxInformationsPanel" .. hoverText, "width", w)
end 

function closeInformationsPanel()
    exports['cr_dx']:startFade("informationsPanel", 
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

    unBindScrollBarKeys()
    scrolling = false
    isRender = false 
    unbindKey("backspace", "down", closeInformationsPanel)

    exports['cr_interface']:setNode("dxInformationsPanel", "active", false)
end

sx, sy = guiGetScreenSize()
function renderInformations()
    local alpha, progress = exports['cr_dx']:getFade("informationsPanel")
    if not isRender then 
        if progress >= 1 then 
            informations = {}
            destroyRender("renderInformations")
            return 
        end  
    end 

    local font = exports['cr_fonts']:getFont("Poppins-SemiBold", 16)
    local font2 = exports['cr_fonts']:getFont("Poppins-Bold", 14)
    local font3 = exports['cr_fonts']:getFont("Poppins-Medium", 14)
    
    specHover = nil

    local h = 60 + ((20 + 3) * ((maxLines - minLines) + 1)) + 12
    --local x, y = sx/2 - w/2, sy/2 - h/2
    local x, y = exports['cr_interface']:getNode("dxInformationsPanel" .. hoverText, "x"), exports['cr_interface']:getNode("dxInformationsPanel" .. hoverText, "y")

    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
    dxDrawImage(x + 10, y + 5, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	dxDrawText(hoverText or "", x + 10 + 26 + 10,y+5,x+w,y+5+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center", false, false, false, true)

    if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
        specHover = "x"
        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
    else 
        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
    end 

    dxDrawText(altText or "", x + 15,y + 5 + 30,x+w,y+40 + 4,tocolor(242, 242, 242, alpha),1,font,"left","top", false, false, false, true)

    local _x = x
    x = x + 15
    y = y + 60

    --ScrollBar
    dxDrawRectangle(_x + w - 10, y, 3, ((20 + 3) * ((maxLines - minLines) + 1) - 3), tocolor(242, 242, 242, alpha * 0.6))
        
    local percent = #informations

    ScrollBarHover = exports['cr_core']:isInSlot(x, y, w, ((20 + 3) * ((maxLines - minLines) + 1)) - 3)
    if percent >= 1  then
        local gW, gH = 3, ((20 + 3) * ((maxLines - minLines) + 1)) - 3
        local gX, gY = _x + w - 10, y
        
        scrollingHover = exports['cr_core']:isInSlot(gX, gY, gW + (5), gH)

        if scrolling then
            if isCursorShowing() then
                if getKeyState("mouse1") then
                    local cx, cy = exports['cr_core']:getCursorPosition()
                    local cy = math.min(math.max(cy, gY), gY + gH)
                    local y = (cy - gY) / (gH)
                    local num = percent * y
                    minLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _maxLines) + 1)))
                    maxLines = minLines + (_maxLines - 1)
                end
            else
                scrolling = false
            end
        end

        local multiplier = math.min(math.max((maxLines - (minLines - 1)) / percent, 0), 1)
        local multiplier2 = math.min(math.max((minLines - 1) / percent, 0), 1)
        local gY = gY + ((gH) * multiplier2)
        local gH = gH * multiplier

        local r,g,b = 255, 59, 59
        dxDrawRectangle(gX, gY, gW, gH, tocolor(r,g,b, alpha))
        --
        --dxDrawImage(center.x - sizes["bottom"].x/2, y, sizes["bottom"].x, sizes["bottom"].y, sources["bottom"], 0,0,0, tocolor(255,255,255,alpha))
        --local rx = center.x - sizes["bottom"].x/2 + 10
        --local ry = y + (5)
    end
    --

    for i = minLines, maxLines do 
        local v = informations[i]
        if v then 
            local w, h = w - 30, 20

            if type(v) == "table" then 
                local name = v[1]
                local val = v[2]

                if panelType == "anims" then  
                    w = w - 25
                end 

                if exports['cr_core']:isInSlot(x, y, w, h) then 
                    dxDrawRectangle(x, y, w, h, tocolor(242,242,242,alpha * 0.8))

                    if panelType == "anims" then 
                        local inSlot = exports["cr_core"]:isInSlot(x + w + 7.5, y, 15, 20)
                        local gName = name:gsub("/#%x%x%x%x%x%x", ""):gsub("#%x%x%x%x%x%x", "")
                        local hasAnim = exports["cr_quickanim"]:hasQuickAnim(gName)

                        if inSlot then 
                            specHover = {i, name}
                        end

                        dxDrawText(string.gsub(name, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), x + 5, y, x + w, y + h + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", false, false, false, true)
                        dxDrawImage(x + w + 7.5, y, 15, 20, ":cr_animation/files/icon.png", 0, 0, 0, ((inSlot or hasAnim) and tocolor(255, 59, 59, alpha) or tocolor(242, 242, 242, alpha * 0.6)))
                    else
                        dxDrawText(string.gsub(name, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), x + 5, y, x + w, y + h + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", false, false, false, true)
                    end

                    dxDrawText(string.gsub(val, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), x + 1, y, x + w - 5, y + h + 4, tocolor(51, 51, 51, alpha), 1, font3, "right", "center", false, false, false, true)
                else 
                    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.6))

                    if panelType == "anims" then 
                        local inSlot = exports["cr_core"]:isInSlot(x + w + 7.5, y, 15, 20)
                        local gName = name:gsub("/#%x%x%x%x%x%x", ""):gsub("#%x%x%x%x%x%x", "")
                        local hasAnim = exports["cr_quickanim"]:hasQuickAnim(gName)

                        if inSlot then 
                            specHover = {i, name}
                        end

                        dxDrawText(name, x + 5, y, x + w, y + h + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center", false, false, false, true)
                        dxDrawImage(x + w + 7.5, y, 15, 20, ":cr_animation/files/icon.png", 0, 0, 0, ((inSlot or hasAnim) and tocolor(255, 59, 59, alpha) or tocolor(242, 242, 242, alpha * 0.6)))
                    else
                        dxDrawText(name, x + 5, y, x + w, y + h + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center", false, false, false, true)
                    end

                    --dxDrawTextAwesome("", name, x + 1 + 15, y, x + 1 + 15 + w, y + h, tocolor(156, 156, 156, alpha), tocolor(156, 156, 156, alpha), 1, 1, font2, icons, 5, false, false, "left", "center")
                    dxDrawText(val, x, y, x + w - 5, y + h + 4, tocolor(242, 242, 242, alpha), 1, font3, "right", "center", false, false, false, true)
                end 
            else 
                local val = v
                if exports['cr_core']:isInSlot(x, y, w, h) then 
                    specHover = k
                    dxDrawRectangle(x, y, w, h, tocolor(242,242,242,alpha * 0.8))
                    dxDrawText(string.gsub(val, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), x + 5, y, x + w, y + h + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", false, false, false, true)
                else 
                    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.6))
                    dxDrawText(val, x + 5, y, x + w, y + h + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center", false, false, false, true)
                end 
            end 

            y = y + h + 3
        end 
    end
end 

function BindScrollBarKeys()
    unBindScrollBarKeys()
    
    bindKey("mouse_wheel_up", "down", ScrollBarUP)
    bindKey("mouse_wheel_down", "down", ScrollBarDown)
    scrollKeysBinded = true
end

function unBindScrollBarKeys()
    if scrollKeysBinded then
        unbindKey("mouse_wheel_up", "down", ScrollBarUP)
        unbindKey("mouse_wheel_down", "down", ScrollBarDown)
        scrollKeysBinded = false
    end
end

function ScrollBarUP()
    if ScrollBarHover then
        if minLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            minLines = minLines - 1
            maxLines = maxLines - 1
        end
    end
end 

function ScrollBarDown()
    if ScrollBarHover then
        if maxLines + 1 <= #informations then
            playSound(":cr_scoreboard/files/wheel.wav")
            minLines = minLines + 1
            maxLines = maxLines + 1
        end
    end
end 

addEventHandler("onClientClick", root, 
    function(b, s)
        if isRender then 
            if b == "left" and s == "down" then 
                if scrollingHover then
                    scrolling = true
                    scrollingHover = false
                elseif specHover == "x" then 
                    closeInformationsPanel()

                    specHover = nil 
                elseif type(specHover) == "table" then 
                    local i = specHover[1]
                    local name = specHover[2]
                    local name = name:gsub("/#%x%x%x%x%x%x", ""):gsub("#%x%x%x%x%x%x", "")

                    if not exports["cr_quickanim"]:hasQuickAnim(name) then 
                        local anims = exports["cr_animation"]:getAnimations()
                        local selectedAnim = anims[i]
                        
                        if selectedAnim then 
                            local animData = selectedAnim[4]

                            if animData then 
                                local block, animName, time, loop, update, interruptable = unpack(animData)

                                exports["cr_quickanim"]:addQuickAnim(name, block, animName, time, loop, update, interruptable)
                                exports["cr_infobox"]:addBox("success", "Sikeresen hozzáadtad a gyors animációkhoz a /"..name.." animációt!")
                            end
                        end
                    else
                        local name = specHover[2]
                        local name = name:gsub("/#%x%x%x%x%x%x", ""):gsub("#%x%x%x%x%x%x", "")

                        exports["cr_quickanim"]:removeQuickAnim(name)
                        exports["cr_infobox"]:addBox("success", "Sikeresen kitörölted a gyors animációk közül a /"..name.." animációt!")
                    end

                    specHover = nil
                end 
            elseif b == "left" and s == "up" then
                if scrolling then
                    scrolling = false
                end
            end 
        end 
    end 
)