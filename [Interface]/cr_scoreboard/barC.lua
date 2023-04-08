textbars = {}
local guiState = false
local now = 0
local tick = 0
local state = false
searchCache = {}
 
--[[
Bar felépítése tábla alapján:
textbars["Bar név"] = {{details(x,y,w,h)}, {options(hosszúság, defaultText, onlyNumber, color, font, fontsize, alignX, alingY, secured)}, id}
A defaultText állandóan változik azaz nem kell külön text változó táblába
]]

function CreateNewBar(name, details, options, id)
    searchCache = {}
    local x,y,w,h = unpack(details)
    --local gui = GuiEdit(x, y, w, h, "", false)
    --gui:setData("name", name)
    --guiSetAlpha(gui, 0)
    --guiSetVisible(gui, false)
    --guiSetInputMode("no_binds_when_editing")
    --setTimer(guiBringToFront, 50, 1, gui)
    --addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
    --addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
    textbars[name] = {details, options, id}
    --options[2] = "Névrészlet/ID"
    if not state then
        addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
        state = true
    end
end

function onGuiBlur()
    guiBringToFront(source)
end

function onGuiChange()
    local name = getElementData(source, "name") or ""
    textbars[name][2][2] = guiGetText(source)
    playSound(":cr_account/files/key.mp3")
    searchCache = {}
    local text = string.lower(textbars[name][2][2])
    
    for k,v in ipairs(cache) do
        local text2 = string.lower(v["name"])
        local text3 = string.lower(tostring(v["id"]))
        local e = v["element"]
        
        if string.lower(tostring(text2)):find(text) or string.lower(text3):find(text) then
            --outputChatBox("asd")
            if e == localPlayer then
                table.insert(searchCache, 1, v)
            else
                table.insert(searchCache, v)
            end
        end
    end
    
    if maxLines > #searchCache then
        minLines = 1
        maxLines = minLines + (_maxLines - 1)
    end
end

function Clear()
    for k,v in pairs(textbars) do
        if isElement(v[4]) then
            destroyElement(v[4])
        end
        textbars[k] = nil
    end
    if state then
        removeEventHandler("onClientRender", root, DrawnBars)
        state = false
        guiState = false
        tick = 0
        now = 0
    end
end

function UpdatePos(name, details)
    if textbars[name] then
        textbars[name][1] = details
        --local x,y,w,h = unpack(details)
        --guiSetPosition(textbars[name][4], x, y, false)
        if not state then
            addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
            state = true
        end
    end
end

function GetText(name)
    return textbars[name][2][2]
end

function DrawnBars()
    for k,v in pairs(textbars) do
        local details = v[1]
        local x,y,w,h = unpack(details)
        local w,h = x + w, y + h
        local options = v[2]
        local text = options[2]
        local color = options[4]
        local font = options[5]
        local fontsize = options[6]
        local alignX = options[7]
        local alignY = options[8]
        local secured = options[9]
        --local rot1,rot2,rot3 = unpack(options[10])
        
        if text == "" or #text == 0 then
            text = "Névrészlet/ID"
        end
        
        if text ~= "Névrészlet/ID" then
            if isElement(v[4]) then
                tick = tick + 5
                if tick >= 425 then
                    tick = 0
                elseif tick >= 250 then
                    text = text .. "|"
                end 
            end
        end
        
        
        --outputChatBox(text)
        local color = tocolor(242,242,242,alpha * 0.8)
        dxDrawText(text, x,y, w,h, color, fontsize, font, alignX, alignY)
    end
end

addEventHandler("onClientClick", root,
    function(b, s)
        if b == "left" and s == "down" then
            if state then
                for k,v in pairs(textbars) do
                    local details = v[1]
                    local x,y,w,h = unpack(details)
                    if isInSlot(x,y,w,h) then
                        if not isElement(v[4]) then
                            local gui = GuiEdit(-1, -1, 1, 1, textbars[k][2][2], true)
                            gui.maxLength = v[2][1]
                            gui:setData("name", k)
                            gui.caretIndex = #textbars[k][2][2]
                            --guiSetAlpha(gui, 0)
                            --guiSetVisible(gui, false)
                            --guiSetInputMode("no_binds_when_editing")
                            setTimer(guiBringToFront, 50, 1, gui)
                            addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
                            addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
                            textbars[k][4] = gui
                        else
                            guiBringToFront(v[4])
                        end
                        return
                    end
                end
                
                for k,v in pairs(textbars) do
                    if isElement(v[4]) then
                        destroyElement(v[4])
                    end
                    textbars[k][4] = nil
                end
            end
        end
    end
)