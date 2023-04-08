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
now = nil
local tick = 0
 
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

function CreateNewBar(name, details, options, id, refresh)
    textbars[name] = {details, options, id}
    if name == "Desc >> Edit" then
        now = name
        --textbars[now][2][2] = ""
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
        guiSetText(gui, textbars[now][2][2])
        guiEditSetCaretIndex(gui, #guiGetText(gui))
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
        --createRender("DrawnBars", DrawnBars)
        state = true
    end

    if refresh then 
        removeEventHandler("onClientRender", root, DrawnBars)
        addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
    end 
end

function Clear()
    textbars = {}
    --setElementData(localPlayer, "bar >> Use", false)
    if isElement(gui) then
        removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
        if isTimer(checkTimers) then killTimer(checkTimers) end
        removeEventHandler("onClientGUIChanged", gui, onGuiChange)
        destroyElement(gui)
        
        guiState = false
        tick = 0
        now = nil
    end
    if now == "Desc >> Edit" then
        guiState = false
        tick = 0
        now = nil
    end
    if state then
        removeEventHandler("onClientRender", root, DrawnBars)
        state = false
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

        if now == "Desc >> Edit" then
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

function UpdatePos(name, details)
--    outputChatBox(name)
    if textbars[name] then
        --outputChatBox("asd2")
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
    return textbars[name][2][2]
end

function SetText(name, val)
    if textbars[name] then
        textbars[name][2][2] = val
        return true
    end
    
    return false
end


local subTexted = {
    --["bank >> cardNumber"] = "Számlaszám: ",
    --["bank >> subjectText"] = "Tárgy: ",
    --["bank >> messageText"] = "Üzenet: ",
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
        local font = options[5]
        local fontsize = options[6]
        local alignX = options[7]
        local alignY = options[8]
        local secured = options[9]
        local clip = options[10]
        local wordBreak = options[11]
        --local rot1,rot2,rot3 = unpack(options[10])
        
        if secured then
            text = utfSub(oText, 1, #options[2])
        end
        
        if now == k then
            tick = tick + 5
            if tick >= 425 then
                tick = 0
            elseif tick >= 250 then
                text = text .. "|"
            end 
        end

        if k == "bank >> cardNumber" then 
            text = formatCardNumber(text)
        end 

        if subTexted[k] then
            text = subTexted[k] .. text
        end

        --dxDrawRectangle(x,y,w - x,h - y, tocolor(0,0,0,120))
        local font = exports['cr_fonts']:getFont(font[1], font[2])
        dxDrawText(text, x,y, w,h, color, fontsize, font, alignX, alignY, clip, wordBreak, false, not wordBreak)
        --outputChatBox(text)
    end
end

local allSelected = false

addEventHandler("onClientClick", root,
    function(b, s)
        local screen = {guiGetScreenSize()}
        local defSize = {250, 28}
        local defMid = {screen[1]/2 - defSize[1]/2, screen[2]/2 - defSize[2]/2}
        if s == "down" then
            if now == "Desc >> Edit" then
                return
            end
            for k,v in pairs(textbars) do
                local x,y,w,h = unpack(v[1])
                if exports['cr_core']:isInSlot(x,y,w,h) then
                    now = k
                    textbars[now][2][2] = ""
                    
                    if now == "Group >> search" then 
                        groupSearchCache = nil
                    end 

                    tick = 250
                    
                    if isElement(gui) then
                        removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
                        if isTimer(checkTimers) then killTimer(checkTimers) end
                        removeEventHandler("onClientGUIChanged", gui, onGuiChange)
                        destroyElement(gui)
                    end
                    gui = GuiEdit(-1, -1, 1, 1, textbars[now][2][2], true)
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
            --setElementData(localPlayer, "bar >> Use", false)
            guiState = false
            tick = 0
            now = nil
            
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

function onGuiChange()
    playSound(":cr_account/files/key.mp3")
    
    --outputChatBox(now)
    --outputChatBox(guiGetText(gui):gsub(" ", ""))

    if textbars[now][2][3] then
        if tonumber(guiGetText(gui)) then
            SetText(now, tostring(math.floor(tonumber(guiGetText(gui)))))
        else
            guiSetText(gui, "")
            SetText(now, guiGetText(gui))
            guiEditSetCaretIndex(gui, #GetText(now))
        end
        
        return
    end
    
    textbars[now][2][2] = guiGetText(gui)
    guiSetText(gui, textbars[now][2][2])
    guiEditSetCaretIndex(gui, #textbars[now][2][2])
    
    if now == "ModPanel >> search" then
        if textbars[now][2][2]:gsub(" ", "") ~= "" then
            modPanelSearchCache = {}
            
            --edit
            local text = string.lower(textbars[now][2][2])
            for k, v in ipairs(modPanelCache) do
                if modPanelCache[k] then
                    local data = modPanelCache[k]
                    local text2 = string.lower(data["name"])
                    local text3 = string.lower(tostring(data["id"]))
                    local text4 = string.lower(data["defname"])
                    local e = v["element"]

                    if string.lower(tostring(text2)):find(text) or string.lower(text3):find(text) or string.lower(text4):find(text) then
                        table.insert(modPanelSearchCache, v)
                    end
                end
            end

            if tonumber(modPanelSelected) then 
                if tonumber(modPanelSelected) > #modPanelSearchCache then 
                    modPanelSelected = 0
                end 
            end 
        else
            modPanelSearchCache = nil
        end
    end
end

addEventHandler("onClientKey", root,
    function(b, s)
        if isElement(gui) and s and now and tostring(now) ~= "" and tostring(now) ~= " " then
            if b == "enter" then
                if now == "R" or now == "G" or now == "B" or now == "hex" then 
                    if pickerData["onEnter"] then 
                        pickerData["onEnter"]()
                    end 
                end 
            elseif b == "tab" then
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
                    gui = GuiEdit(-1, -1, 1, 1, textbars[now][2][2], true)
                    --setTimer(function() gui:setProperty("AlwaysOnTop", "True") end, 100, 1)
                    gui.maxLength = textbars[now][2][1]
                    guiEditSetCaretIndex(gui, #textbars[now][2][2])
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
                    gui = GuiEdit(-1, -1, 1, 1, textbars[now][2][2], true)
                    --setTimer(function() gui:setProperty("AlwaysOnTop", "True") end, 100, 1)
                    gui.maxLength = textbars[now][2][1]
                    guiEditSetCaretIndex(gui, #textbars[now][2][2])
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