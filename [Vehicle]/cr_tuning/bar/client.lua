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
    [","] = true,
    ['"'] = true,
    ["_"] = true,
    ["-"] = true,
    ["*"] = true,
    ["-"] = true,
    ["+"] = true,
    ["//"] = true,
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
}
--[[
Bar felépítése tábla alapján:
textbars["Bar név"] = {{details(x,y,w,h)}, {options(hosszúság, defaultText, onlyNumber, color, font, fontsize, alignX, alingY, secured)}, id}
A defaultText állandóan változik azaz nem kell külön text változó táblába
]]

local gui 

function onGuiBlur2()
    setTimer(onGuiBlur, 100, 1)
end

function CreateNewBar(name, details, options, id, needRefresh)
    textbars[name] = {details, options, id}
    if instantBars[name] then
        now = name
        SetText(now, "")
        tick = 250

        if isElement(gui) then
            removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
            if isTimer(checkTimers) then killTimer(checkTimers) end
            removeEventHandler("onClientGUIChanged", gui, onGuiChange)
            destroyElement(gui)
        end
        gui = GuiEdit(-1, -1, 1, 1, "", true)
        gui.maxLength = textbars[now][2][1]
        if isTimer(guiBringToFrontTimer) then killTimer(guiBringToFrontTimer) end
        guiBringToFrontTimer = setTimer(guiBringToFront, 50, 1, gui)

        addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
        
        checkTimers = setTimer(onGuiBlur, 150, 0)
        addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
        
        allSelected = false
    end
    
    if not state then
        addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
        state = true
    end
end

function RemoveBar(name)
    if textbars[name] then
        textbars[name] = nil
        
        for k,v in pairs(textbars) do
            return
        end
        
        if state then
            removeEventHandler("onClientRender", root, DrawnBars)
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

    now = nil

    if instantBars[now] then
        guiState = false
        tick = 0
        now = 0
    end

    if state then
        removeEventHandler("onClientRender", root, DrawnBars)
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
    return textbars[name][2][2]
end

function SetText(name, val)
    if textbars[name] then
        textbars[name][2][2] = val
        return true
    end
    
    return false
end

function DrawnBars()
    for k,v in pairs(textbars) do
        local details = v[1]
        local x,y,w,h = unpack(details)
        local w,h = x + w, y + h
        local options = v[2]
        local text = options[2]
        local color = options[4]
        local fontName = options[5]
        local font = exports['cr_fonts']:getFont(fontName[1], fontName[2])
        local fontsize = options[6]
        local alignX = options[7]
        local alignY = options[8]
        local secured = options[9]
        
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

            if k == "R" then
                text = "R: " .. text
            end
            
            if k == "G" then
                text = "G: " .. text
            end
            
            if k == "B" then
                text = "B: " .. text 
            end

            if k == "hex" then
                text = "#" .. text 
            end
            
            dxDrawText(text, x,y, w,h, color, fontsize, font, alignX, alignY)
        end
    end
end

local allSelected = false

addEventHandler("onClientClick", root,
    function(b, s)

        if s == "down" then
            if instantBars[now] then
                return
            end

            for k,v in pairs(textbars) do
                local x,y,w,h = unpack(v[1])
                if exports['cr_core']:isInSlot(x,y,w,h) then
                    if bitExtract(v[2][4], 24, 8) >= 255 then
                        now = k
                        SetText(now, "")
                        tick = 250

                        if isElement(gui) then
                            removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
                            if isTimer(checkTimers) then killTimer(checkTimers) end
                            removeEventHandler("onClientGUIChanged", gui, onGuiChange)
                            destroyElement(gui)
                        end
                        gui = GuiEdit(-1, -1, 1, 1, GetText(now), true)
                        gui.maxLength = textbars[now][2][1]
                        if isTimer(guiBringToFrontTimer) then killTimer(guiBringToFrontTimer) end
                        guiBringToFrontTimer = setTimer(guiBringToFront, 50, 1, gui)

                        addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
                        checkTimers = setTimer(onGuiBlur, 150, 0)
                        addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
                        return
                    end
                end
            end

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
    ["plateText"] = true,
}

function onGuiChange()
    playSound(":cr_account/files/key.mp3")
    
    if textbars[now][2][3] then
        if tonumber(guiGetText(gui)) then
            if now == "R" then 
                pickerData["selectedColor"][1] = tonumber(guiGetText(gui))
				pickerData["color"][1] = tonumber(guiGetText(gui))
            elseif now == "G" then 
                pickerData["selectedColor"][2] = tonumber(guiGetText(gui))
				pickerData["color"][2] = tonumber(guiGetText(gui))
            elseif now == "B" then 
                pickerData["selectedColor"][3] = tonumber(guiGetText(gui))
				pickerData["color"][3] = tonumber(guiGetText(gui))
            end 
            SetText(now, guiGetText(gui))
        else
            guiSetText(gui, "")
            SetText(now, guiGetText(gui))
            guiEditSetCaretIndex(gui, #GetText(now))
        end
        
        return
    end
    
    if now == "hex" then 
        if #guiGetText(gui) == 6 then 
            local color = {getColorFromString("#" .. guiGetText(gui))}

            pickerData["selectedColor"] = {color[1], color[2], color[3]}
            pickerData["color"] = {color[1], color[2], color[3]}
            
            SetText("R", pickerData["color"][1])
            SetText("G", pickerData["color"][2])
            SetText("B", pickerData["color"][3])
        end
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
            guiSetText(gui, utfSub(guiGetText(gui), 1, #guiGetText(gui) - 1))
            guiEditSetCaretIndex(gui, #guiGetText(gui))
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
            SetText(now, a2)
            return
        elseif tonumber(b) then
            SetText(now, a2)
            return
        end
    end

    if now == "plateText" then 
        SetText(now, guiGetText(gui):upper())
    end 
end

addEventHandler("onClientKey", root,
    function(b, s)
        if isElement(gui) and s and now and tostring(now) ~= "" and tostring(now) ~= " " then
            if b == "backspace" then 
                if isBuyRender then 
                    destroyBuy()
                end 
            elseif b == "enter" then
                if not isBuyRender then 
                    if now == "plateText" then 
                        selectorCache["now"] = GetText("plateText")
                        if selectorCache["onEnter"] then 
                            selectorCache["onEnter"]()
                        end 
                    elseif now == "R" or now == "G" or now == "B" or now == "hex" then 
                        if pickerData["onEnter"] then 
                            pickerData["onEnter"]()
                        end 
                    end 
                else 
                    buyEnter()
                end
            elseif b == "tab" then
                if now == "ForgetPass" then
                    return
                end
                
                local idTable = {}
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
                    gui.maxLength = textbars[now][2][1]
                    guiEditSetCaretIndex(gui, #GetText(now))
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
                    gui.maxLength = textbars[now][2][1]
                    guiEditSetCaretIndex(gui, #GetText(now))
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