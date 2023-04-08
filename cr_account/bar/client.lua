textbars = {}
local state = false
local oText = "*****************************************************************************************************************************************"
local disabledKey = {
    ["capslock"] = true,
    ["lctrl"] = true,
    ["rctrl"] = true,
    ["lalt"] = true,
    ["ralt"] = true,
    ["home"] = true,
    [";"] = true,
    ["'"] = true,
    ["]"] = true,
    ["["] = true,
    ["="] = true,
    ["_"] = true,
    ["á"] = true,
    ["é"] = true,
    ["ű"] = true,
    ["#"] = true,
    ["\\"] = true,
    ["/"] = true,
    --["."] = true,
    [","] = true,
    ['"'] = true,
    ["_"] = true,
    ["-"] = true,
    ["*"] = true,
    ["-"] = true,
    ["+"] = true,
    ["//"] = true,
    --[" "] = true,
    [""] = true,
}

local subWord = {
    [";"] = "é",
    ["#"] = "á",
    ["["] = "ő",
    ["]"] = "ú",
    ["="] = "ó",
    ["/"] = "ü",
}

local changeKey = {
    ["num_0"] = "0",
    ["num_1"] = "1",
    ["num_2"] = "2",
    ["num_3"] = "3",
    ["num_4"] = "4",
    ["num_5"] = "5",
    ["num_6"] = "6",
    ["num_7"] = "7",
    ["num_8"] = "8",
    ["num_9"] = "9",
}
local guiState = false
local now = 0
local tick = 0
 
local instantBars = {
    ["Test"] = true
}
--[[
Bar felépítése tábla alapján:
textbars["Bar név"] = {{details(x,y,w,h)}, {options(hosszúság, defaultText, onlyNumber, color, font, fontsize, alignX, alingY, secured)}, id}
A defaultText állandóan változik azaz nem kell külön text változó táblába
]]

local gui 

function onGuiBlur2()
    --outputChatBox("asd")
    setTimer(onGuiBlur, 100, 1)
end
--bindKey("F8", "down", onGuiBlur2)

function CreateNewBar(name, details, options, id, needRefresh)
    textbars[name] = {details, options, id}
    if instantBars[name] then --name == "Char-Reg.Age" or name == "Char-Reg.Name" or name == "Char-Reg.Weight" or name == "Char-Reg.Height" then
        now = name
        SetText(now, "") -- textbars[now][2][2] = ""
        --outputChatBox(k)
        tick = 250

        if isElement(gui) then
            removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
            if isTimer(checkTimers) then killTimer(checkTimers) end
            removeEventHandler("onClientGUIChanged", gui, onGuiChange)
            destroyElement(gui)
        end
        gui = GuiEdit(-1, -1, 1, 1, "", true)
        --setTimer(function() gui:setProperty("AlwaysOnTop", "True") end, 100, 1)
        gui.maxLength = textbars[now][2][1]
        --guiEditSetCaretIndex(gui, 1)
        --guiSetProperty(gui, "AlwaysOnTop", "True")
        if isTimer(guiBringToFrontTimer) then killTimer(guiBringToFrontTimer) end
        guiBringToFrontTimer = setTimer(guiBringToFront, 50, 1, gui)

        addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
        
        checkTimers = setTimer(onGuiBlur, 150, 0)
        addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
        
        --setElementData(localPlayer, "bar >> Use", true)
        guiState = true
        allSelected = false
    end
    
    if not state then
        addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
        state = true
    end
    
    if name == "ForgetPass" or needRefresh then
        if state then
            removeEventHandler("onClientRender", root, DrawnBars)
            addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
        end
    end
end

function RemoveBar(name)
    if textbars[name] then
        if now == name and isElement(gui) then
            removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
            if isTimer(checkTimers) then killTimer(checkTimers) end
            removeEventHandler("onClientGUIChanged", gui, onGuiChange)
            destroyElement(gui)
            
            guiState = false
            tick = 0
            now = nil
        end
        
        textbars[name] = nil
        
        for k,v in pairs(textbars) do
            return
        end
        
        if state then
            removeEventHandler("onClientRender", root, DrawnBars)
            --setElementData(localPlayer, "bar >> Use", false)
            state = false
        end
    end
end

function Clear()
    textbars = {}
    if isElement(gui) then
        removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
        if isTimer(checkTimers) then killTimer(checkTimers) end
        removeEventHandler("onClientGUIChanged", gui, onGuiChange)
        destroyElement(gui)
    end
    if instantBars[now] then --now == "Char-Reg.Age" or now == "Char-Reg.Name" or now == "Char-Reg.Weight" or now == "Char-Reg.Height" then
        --setElementData(localPlayer, "bar >> Use", false)
        guiState = false
        tick = 0
        now = 0
    end
    if state then
        removeEventHandler("onClientRender", root, DrawnBars)
        --setElementData(localPlayer, "bar >> Use", false)
        state = false
    end
end

function UpdatePos(name, details)
    if textbars[name] then
        textbars[name][1] = details
        if not state then
            addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
            state = true
        end
    end
end

function UpdateAlpha(name, newColor)
    if textbars[name] then
        textbars[name][2][4] = newColor
        if not state then
            addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
            state = true
        end
    end
end

function GetText(name)
    if textbars[name] then  
        return textbars[name][2][2]
    end
end

function SetText(name, val)
    if textbars[name] then
        textbars[name][2][2] = val
        return true
    end
    
    return false
end

local subTexted = {
    ["CharRegisterHeiht"] = " kg",
    ["CharRegisterWeight"] = " cm",
    ["CharRegisterAge"] = " év",
}

function DrawnBars()
    for k,v in pairs(textbars) do
        local details = v[1]
        local x,y,w,h = unpack(details)
        --dxDrawRectangle(x,y,w,h,tocolor(0,0,0,180))
        local w,h = x + w, y + h
        --outputChatBox("x:"..x)
        --outputChatBox("y:"..y)
        --outputChatBox("w:"..w)
        --outputChatBox("h:"..h)
        --outputChatBox("k:"..k)
        local options = v[2]
        local text = options[2]
        local color = options[4]
        local fontName = options[5]
        local font = exports['cr_fonts']:getFont(fontName[1], fontName[2])
        local fontsize = options[6]
        local alignX = options[7]
        local alignY = options[8]
        local secured = options[9]
        --local rot1,rot2,rot3 = unpack(options[10])
        
        if secured then
            text = utfSub(oText, 1, #options[2])
        end
        
        if not instantBars[now] then -- then
            if now == k then
                tick = tick + 5
                if tick >= 425 then
                    tick = 0
                elseif tick >= 250 then
                    text = text .. "|"
                end 
            end

            if k == "Char-Reg.Height" then
                if text ~= "Karakter magasság" then
                    local color = exports['cr_core']:getServerColor("yellow", true)
                    text = text .. color .. " cm"
                end
            end
            
            if k == "Char-Reg.Weight" then
                if text ~= "Karakter súly" then
                    local color = exports['cr_core']:getServerColor("yellow", true)
                    text = text .. color .. " kg"
                end
            end
            
            if k == "Char-Reg.Age" then
                if text ~= "Karakter életkor" then
                    local color = exports['cr_core']:getServerColor("yellow", true)
                    text = text .. color .. " év"
                end
            end
            
            if subTexted[k] then
                text = text .. subTexted[k]
            end
            
            --dxDrawRectangle(x,y,w - x,h - y, tocolor(0,0,0,120))
            dxDrawText(text, x,y, w,h, color, fontsize, font, alignX, alignY, false, false, false, true)
        end
    end
end

local allSelected = false

addEventHandler("onClientClick", root,
    function(b, s)
        local screen = {guiGetScreenSize()}
        local defSize = {250, 28}
        local defMid = {screen[1]/2 - defSize[1]/2, screen[2]/2 - defSize[2]/2}
        if s == "down" then
            if page == "Login" or page == "passwordForget" then 
                local x,y,w,h = defMid[1] + defSize[1]/2 + 300/2 - 41/2 - 13/2, loginPos[1] + defSize[2] + 10 + 35/2 - 12/2, 13, 12
                if isInSlot(x,y,w,h) then
                    --outputChatBox("asd2")
                    saveJSON["canSeePassword"] = not saveJSON["canSeePassword"]
                    if textbars["Login.Password"] then
                        --outputChatBox("asd2.1")
                        textbars["Login.Password"][2][9] = not saveJSON["canSeePassword"]
                        return
                    end
                    
                    if textbars["Register.Password1"] then
                        --outputChatBox("asd2.1")
                        textbars["Register.Password1"][2][9] = not saveJSON["canSeePassword"]
                        textbars["Register.Password2"][2][9] = not saveJSON["canSeePassword"]
                        return
                    end
                end
            elseif page == "Register" then 
                local x1,y1,w1,h1 = defMid[1] + defSize[1]/2 + 300/2 - 41/2 - 13/2, regPos[1] + defSize[2] + 10 + 35/2 - 12/2, 13, 12
                local x2,y2,w2,h2 = defMid[1] + defSize[1]/2 + 300/2 - 41/2 - 13/2, regPos[1] + defSize[2] + 55 + 35/2 - 12/2, 13, 12

                --outputChatBox("asd2.-1")
                if isInSlot(x1,y1,w1,h1) or isInSlot(x2,y2,w2,h2) then
                    --outputChatBox("asd2")
                    saveJSON["canSeePassword"] = not saveJSON["canSeePassword"]
                    if textbars["Login.Password"] then
                        --outputChatBox("asd2.1")
                        textbars["Login.Password"][2][9] = not saveJSON["canSeePassword"]
                        return
                    end
                    
                    if textbars["Register.Password1"] then
                        --outputChatBox("asd2.1")
                        textbars["Register.Password1"][2][9] = not saveJSON["canSeePassword"]
                        textbars["Register.Password2"][2][9] = not saveJSON["canSeePassword"]
                        return
                    end
                end
            end 

            if instantBars[now] then --now == "Char-Reg.Age" or now == "Char-Reg.Name" or now == "Char-Reg.Weight" or now == "Char-Reg.Height" then
                return
            end
            for k,v in pairs(textbars) do
                local x,y,w,h = unpack(v[1])
                if isInSlot(x,y,w,h) then
                    if bitExtract(v[2][4], 24, 8) >= math.floor(255 * 0.5) then
                        now = k
                        SetText(now, "") --textbars[now][2][2] = ""
                        --outputChatBox(k)
                        tick = 250

                        if isElement(gui) then
                            removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
                            if isTimer(checkTimers) then killTimer(checkTimers) end
                            removeEventHandler("onClientGUIChanged", gui, onGuiChange)
                            destroyElement(gui)
                        end
                        gui = GuiEdit(-1, -1, 1, 1, GetText(now), true)
                        --setTimer(function() gui:setProperty("AlwaysOnTop", "True") end, 100, 1)
                        gui.maxLength = textbars[now][2][1]
                        --guiEditSetCaretIndex(gui, 1)
                        --guiSetProperty(gui, "AlwaysOnTop", "True")
                        if isTimer(guiBringToFrontTimer) then killTimer(guiBringToFrontTimer) end
                        guiBringToFrontTimer = setTimer(guiBringToFront, 50, 1, gui)

                        addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
                        checkTimers = setTimer(onGuiBlur, 150, 0)
                        addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
                        return
                    end
                end
            end
            ----setElementData(localPlayer, "bar >> Use", false)
            guiState = false
            tick = 0
            now = 0
            
            if isElement(gui) then
                removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
                if isTimer(checkTimers) then killTimer(checkTimers) end
                removeEventHandler("onClientGUIChanged", gui, onGuiChange)
                destroyElement(gui)
            end
        end
    end
)

function onGuiBlur()
    if isElement(gui) then
        guiBringToFront(gui)
    end
end

local specIgnore = {
    ["Char-Reg.Name"] = true,
    ["Register.Email"] = true,
    ["Login.Name"] = true,
    ["ForgetPass"] = true,
    ["ForgetCode"] = true,
}

function onGuiChange()
    playSound("files/key.mp3")
    
    if textbars[now][2][3] then --if now == "Char-Reg.Age" or now == "Char-Reg.Weight" or now == "Char-Reg.Height" then
        if tonumber(guiGetText(gui)) then
            SetText(now, guiGetText(gui))
        else
            guiSetText(gui, "")
            SetText(now, guiGetText(gui))
            guiEditSetCaretIndex(gui, #GetText(now))
        end
        
        return
    end
    
    if not specIgnore[now] then
        local st = ""
        for k in string.gmatch(guiGetText(gui), "%w+") do
            st = st .. k
        end
        guiSetText(gui, st)
        guiEditSetCaretIndex(gui, #guiGetText(gui))
        SetText(now, guiGetText(gui))
    end    
    
    if now == "Char-Reg.Name" then
        local st = ""
        for k in string.gmatch(guiGetText(gui), "[%a+%s]") do
            st = st .. k
        end
        guiSetText(gui, st)
        guiEditSetCaretIndex(gui, #guiGetText(gui))
        SetText(now, guiGetText(gui))
        
        if utfSub(guiGetText(gui), #guiGetText(gui), #guiGetText(gui)) == "_" then
            guiSetText(gui, utfSub(guiGetText(gui), 1, #guiGetText(gui) - 1))
            guiEditSetCaretIndex(gui, #guiGetText(gui))
            exports['cr_infobox']:addBox("warning", "Használj space-t a(z) '_' - helyett")
        end
        
        if utfSub(guiGetText(gui), #guiGetText(gui), #guiGetText(gui)) == " " and utfSub(guiGetText(gui), #guiGetText(gui) - 1, #guiGetText(gui) - 1) == " " then
            --outputChatBox("asd2")
            --outputChatBox("asd2")
            guiSetText(gui, utfSub(guiGetText(gui), 1, #guiGetText(gui) - 1))
            guiEditSetCaretIndex(gui, #guiGetText(gui))
            --exports['cr_infobox']:addBox("warning", "Használj space-t a(z) '_' - helyett")
        end
        
        SetText(now, guiGetText(gui))
    else
        SetText(now, guiGetText(gui):gsub(" ", ""))
    end
    
    guiSetText(gui, GetText(now))
    guiEditSetCaretIndex(gui, #GetText(now))
    
    local b = utfSub(GetText(now), #GetText(now), #GetText(now))
    local a2 = utfSub(GetText(now), 1, #GetText(now) - 1)
    if changeKey[b] then 
        b = changeKey[b] 
    end

    if disabledKey[b] then
        local b2 = " " .. b .. " "
        if subWord[b] or b2 == " \ " then
            --exports["pb_infobox"]:addBox("warning", "A nevedben nem szerepelhet ékezet!")
            SetText(now, a2)
            return
        elseif tonumber(b) then
            SetText(now, a2)
            return
        end
    end
end

addEventHandler("onClientKey", root,
    function(b, s)
        if isElement(gui) and s and now and tostring(now) ~= "" and tostring(now) ~= " " then
            if b == "enter" then
                if now == "Login.Name" then 
                    loginInteraction()
                elseif now == "Login.Password" then 
                    loginInteraction()
                elseif now == "Register.Name" then 
                    registerInteraction()
                elseif now == "Register.Email" then 
                    registerInteraction()
                elseif now == "Register.Password1" then 
                    registerInteraction()
                elseif now == "Register.Password2" then 
                    registerInteraction()
                elseif now == "Register.InviteCode" then 
                    registerInteraction()
                end 
                --[[
                if now == "Char-Reg.Age" then
                    ageNext()
                elseif now == "Char-Reg.Name" then
                    nameNext()
                elseif now == "Char-Reg.Height" then
                    heightNext()
                elseif now == "Char-Reg.Weight" then
                    weightNext()
                end]]
            elseif b == "tab" then
                if now == "ForgetPass" then
                    return
                end
                
                local idTable = {}
                --idTable[k] = i
                for k,v in pairs(textbars) do
                    local i = textbars[k][3]
                    idTable[k] = i
                    idTable[i] = k
                end
                local newNum = idTable[now] + 1
                if idTable[newNum] then
                    now = idTable[newNum]
                    
                    if isElement(gui) then
                        removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
                        if isTimer(checkTimers) then killTimer(checkTimers) end
                        removeEventHandler("onClientGUIChanged", gui, onGuiChange)
                        destroyElement(gui)
                    end
                    gui = GuiEdit(-1, -1, 1, 1, GetText(now), true)
                    --setTimer(function() gui:setProperty("AlwaysOnTop", "True") end, 100, 1)
                    gui.maxLength = textbars[now][2][1]
                    guiEditSetCaretIndex(gui, #GetText(now))
                    --guiSetProperty(gui, "AlwaysOnTop", "True")
                    if isTimer(guiBringToFrontTimer) then killTimer(guiBringToFrontTimer) end
                    guiBringToFrontTimer = setTimer(guiBringToFront, 50, 1, gui)
                    
                    addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
                    checkTimers = setTimer(onGuiBlur, 150, 0)
                    addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
                else    
                    now = idTable[1]
                    
                    if isElement(gui) then
                        removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
                        if isTimer(checkTimers) then killTimer(checkTimers) end
                        removeEventHandler("onClientGUIChanged", gui, onGuiChange)
                        destroyElement(gui)
                    end
                    gui = GuiEdit(-1, -1, 1, 1, GetText(now), true)
                    --setTimer(function() gui:setProperty("AlwaysOnTop", "True") end, 100, 1)
                    gui.maxLength = textbars[now][2][1]
                    guiEditSetCaretIndex(gui, #GetText(now))
                    --guiSetProperty(gui, "AlwaysOnTop", "True")
                    if isTimer(guiBringToFrontTimer) then killTimer(guiBringToFrontTimer) end
                    guiBringToFrontTimer = setTimer(guiBringToFront, 50, 1, gui)
                    
                    addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
                    checkTimers = setTimer(onGuiBlur, 150, 0)
                    addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
                end
                return
            end
        end
    end
)