local cache = {}
local options = {
    ["font"] = 1,
    ["fontsize"] = 10,
    ["bold"] = 0,
    ["fadeout"] = 1,
    ["showtime"] = 30,
    ["fadeoutmultiplier"] = 30,
    ["backgroundr"] = 0,
    ["backgroundg"] = 0,
    ["backgroundb"] = 0,
    ["backgrounda"] = 0,
    ["cacheRemain"] = 10,
    ["outline"] = 0,
}
local fontNames = {
    "Roboto",
    "OpenSans",
    "RobotoB",
    "FontAwesome",
    "DeansGateB",
    "Rubik",
    "gotham_light",
}
local convert = {
    ["Say"] = "IC Chat: ",
    ["IC"] = "IC Chat: ",
    ["b"] = "OOC Chat: ",
    ["OOC"] = "OOC Chat: ",
    ["Rádió"] = "Rádió: ",
    ["y"] = "Rádió: ",
}

guiSetInputMode("no_binds_when_editing")

function setICOption(name, val)
    options[name] = val
end 

_showChat = showChat
function showChat(a)
    if not customChatEnabled then
        if state then
            destroyRender("drawnChat")
            
            state = false
        end
        return _showChat(a)
    else
        _showChat(false)
        if a then
            if not state then
                createRender("drawnChat", drawnChat)
                state = true
            end
        else
            if state then
                destroyRender("drawnChat")
                state = false
            end
        end
        return true
    end
end

_isChatVisible = isChatVisible
function isChatVisible()
    if not customChatEnabled then
        return _isChatVisible(a)
    else
        return state
    end
end
--

local function initWidgets()
    startCustomChat()
end

addEventHandler("onClientResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_interface" then
            setTimer(initWidgets, 1000, 1)
        elseif startedRes == getThisResource() then
            if(getResourceState(getResourceFromName("cr_interface"))=="running")then
                setTimer(initWidgets, 1000, 1)
            end
        end
    end
)

function getLines()
    local a = getChatboxLayout()["chat_lines"]
    if customChatEnabled then
        a = options["lines"]
    end
    return a
end

function recalculateIC()
    local font = exports['cr_fonts']:getFont(fontNames[options["font"]], options["fontsize"], options["bold"] == 1)
    options["font-height"] = dxGetFontHeight(1, font)
    options["lines"] = math.floor(height / options["font-height"] )
    minLines = 1
    maxLines = options["lines"]
    
    if #cache >= options["lines"] + options["cacheRemain"] then
        table.remove(cache, options["lines"] + options["cacheRemain"])
    end

    if #cache > 0 then
        for k,v in pairs(cache) do 
            local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)

            local text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
            text = string.gsub(text, "\n", "")
            local length = dxGetTextWidth(text, 1, font, true)
            
            local textSub = {}
            local a = 0
            local breaks = 0
            if length >= width then
                local i = 1
                local i2 = 1
                local start = 1
                local remainText = ""
                while true do
                    local length = dxGetTextWidth(utfSub(text, start, i), 1, font, true)
                    if length >= width then
                        breaks = breaks + 1
                        local startpos, endpos = utf8.find(text, "#", i - 7)
                        if startpos and startpos <= i - 1 then
                            i = startpos + 7
                        end
                        if utfSub(text, i - 1, i - 1) == "#" then
                            table.insert(textSub, utfSub(text, i2, i - 2) .. "\n")
                            i2 = i - 1
                            remainText = utfSub(text, i2, #text)
                            
                            text = utfSub(text, 1, i - 2) .. "\n" .. utfSub(text, i - 1, #text)
                        else
                            table.insert(textSub, utfSub(text, i2, i - 1) .. "\n")
                            i2 = i
                            remainText = utfSub(text, i2, #text)
                            
                            text = utfSub(text, 1, i - 1) .. "\n" .. utfSub(text, i, #text)
                        end
                        start = i
                    elseif i + 1 >= #text then
                        table.insert(textSub, remainText)
                        break
                    end
                    i = i + 1
                end
            end
            
            text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
            cache[k][1] = text
            cache[k][3] = breaks + 1
            cache[k][4] = text2
            cache[k][7] = textSub
        end
        
        if typing then
            local text = name .. options["sayingText"]
            local a = 0
            local breaks = 0
            local length = dxGetTextWidth(text, 1, font, true)
            if length > width then
                local i = 1
                local start = 1
                while true do
                    local length = dxGetTextWidth(utfSub(text, start, i), 1, font, true)
                    if length >= width then
                        breaks = breaks + 1
                        local startpos, endpos = utf8.find(text, "#", i - 7)
                        if startpos and startpos <= i - 1 then
                            i = startpos + 7
                        end
                        if utfSub(text, i - 1, i - 1) == "#" then
                            text = utfSub(text, 1, i - 2) .. "\n" .. utfSub(text, i - 1, #text)
                        else
                            text = utfSub(text, 1, i - 1) .. "\n" .. utfSub(text, i, #text)
                        end
                        start = i
                    elseif i + 1 >= #text then
                        break
                    end
                    i = i + 1
                end
            end
            options["renderText"] = string.gsub(text, name, "")
        end
    end
end

function startCustomChat()
    _, startX, startY, width, height = exports['cr_interface']:getDetails("chat")
    isEnabledICChat = localPlayer:getData("chat.enabled")
    local font = exports['cr_fonts']:getFont(fontNames[options["font"]], options["fontsize"], options["bold"] == 1)
    options["font-height"] = dxGetFontHeight(1, font)
    customChatEnabled = false
    if isEnabledICChat then
        customChatEnabled = true
        owidth, oheight = width, height
        options["lines"] = math.floor(height / options["font-height"] )
        startY = startY + ((options["lines"]) * options["font-height"])
        minLines = 1
        maxLines = options["lines"]
        showChat(true)
    end
    bindKey("t", "down", startTyping, "IC")
    bindKey("b", "down", startTyping, "OOC")
    bindKey("y", "down", startTyping, "Rádió")
end

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName)
        if dName == "chat.enabled" then
            startCustomChat()
        end
    end
)

function upMove()
    if state then
        if maxLines + 1 <= #cache then
            maxLines = maxLines + 1 
            minLines = minLines + 1
        end
    end
end

function downMove()
    if state then
        if minLines - 1 >= 1 then
            maxLines = maxLines - 1 
            minLines = minLines - 1
        end
    end
end

function startTyping(B, B, a)
    if not localPlayer:getData("hudVisible") then return end
    if not localPlayer:getData("loggedIn") then return end
    if state and customChatEnabled then
        if not typing then
            if a ~= "b" then
                for i, v in pairs(cache) do
                    local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)
                    cache[i][5] = getTickCount()
                    cache[i][6] = 255
                end
            else
                refreshOOC()
            end
            gui = GuiEdit(-1, -1, 1, 1, "", true)
            setTimer(guiBringToFront, 50, 1, gui)
            _oldCState = false
            showCursor(true)
            addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
            addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
            localPlayer:setData("player.write", true)
            localPlayer:setData("write", true)
            typing = true
            guiSetInputMode("no_binds")
            local newValue = typing
            if newValue then
                options["textType"] = a

                name = convert[options["textType"]]
                options["sayingText"] = ""
                options["renderText"] = ""
                bindKey("enter", "down", interactText)
            end
        end
    end
end

function onGuiBlur()
    guiBringToFront(gui)
end

function onGuiChange()
    options["sayingText"] = guiGetText(gui)
    local text = name .. options["sayingText"]
    local a = 0
    local breaks = 0
    local font = exports['cr_fonts']:getFont(fontNames[options["font"]], options["fontsize"], options["bold"] == 1)
    local length = dxGetTextWidth(text, 1, font, true)
    if length > width then
        local i = 1
        local start = 1
        while true do
            local length = dxGetTextWidth(utfSub(text, start, i), 1, font, true)
            if length >= width then
                breaks = breaks + 1
                local startpos, endpos = utf8.find(text, "#", i - 7)
                if startpos and startpos <= i - 1 then
                    i = startpos + 7
                end
                if utfSub(text, i - 1, i - 1) == "#" then
                    text = utfSub(text, 1, i - 2) .. "\n" .. utfSub(text, i - 1, #text)
                else
                    text = utfSub(text, 1, i - 1) .. "\n" .. utfSub(text, i, #text)
                end
                start = i
            elseif i + 1 >= #text then
                break
            end
            i = i + 1
        end
    end
    options["renderText"] = string.gsub(text, name, "")
end

function stopTyping()
    if typing then
        setTimer(function() typing = false end, 150, 1)
        unbindKey("enter", "down", interactText)
        showCursor(_oldCState)
        guiSetInputMode("no_binds_when_editing")
        localPlayer:setData("player.write", false)
        localPlayer:setData("write", false)
        if isElement(gui) then
            destroyElement(gui)
        end

        if isTimer(backspaceTimer) then
            killTimer(backspaceTimer)
        end

        if isTimer(backspaceRepeatTimer) then
            killTimer(backspaceRepeatTimer)
        end

        if isTimer(buttonTimer) then
            killTimer(buttonTimer)
        end

        if isTimer(buttonTimerRepeatTimer) then
            killTimer(buttonTimerRepeatTimer)
        end
    end
end
addEventHandler("onClientResourceStop", root, stopTyping)

addEventHandler("onClientKey", root, 
    function(button,press) 
        if button == "escape" and press then
            return stopTyping()
        end
    end
)

function interactText()
    local t = options["sayingText"]
    
    if #t == 0 then
        stopTyping()
    else
        local st = utfSub(t, 1, 1)
        if st == "/" then
            if #t > 1 then
                stopTyping()
                local stW = utfSub(t, 2, #t)
                local cmd = gettok(t, 1, string.byte(' '))
                cmd = cmd:gsub("/", "")
                
                local match = searchSpace(t)
                local args = matchConvertToString(t, match)
                
                if not executeCommandHandler(cmd, args) then
                    triggerServerEvent("executeCommand", localPlayer, cmd, args)
                end
                stopTyping()
                return
            else
                stopTyping()
                return
            end
        end
        
        if st and st ~= " " then
            if options["textType"] == "b" then
                executeCommandHandler("b", t)
            else
                executeCommandHandler(options["textType"], t)
            end
        end
        
        stopTyping()
    end
end

local disabledKey = {
    ["capslock"] = true,
    ["lctrl"] = true,
    ["rctrl"] = true,
    ["lalt"] = true,
    ["ralt"] = true,
    ["home"] = true,
}

for i = 1, 9 do
    disabledKey["F"..i] = true
end

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
    ["num_div"] = "/",
    ["space"] = " ",
    ["num_mul"] = "*",
    ["num_add"] = "+",
    ["num_sub"] = "-",
    ["num_dec"] = "."
}

local subWord = {
    [";"] = "é",
    ["#"] = "á",
    ["["] = "ő",
    ["'"] = "ö",
    ["]"] = "ú",
    ["="] = "ó",
    ["/"] = "ü",
    ["\\"] = "ű",
}

local upperKey = {
    ["é"] = "É",
    ["á"] = "Á",
    ["ő"] = "Ő",
    ["ö"] = "Ö",
    ["ú"] = "Ú",
    ["ó"] = "Ó",
    ["ü"] = "Ü",
    ["ű"] = "Ű",
    ["í"] = "Í"
}

local subWordBack = {}

for k,v in pairs(subWord) do
    subWordBack[v] = true
end

for k,v in pairs(upperKey) do
    subWordBack[v] = true
end

local maxChar = 100

function backspace()
    if #options["sayingText"] > 0 then
        if allSelected then
            options["sayingText"] = ""
            allSelected = false
            return
        end
        local NText = options["sayingText"]
        local num = #NText
        local last = NText:sub(num - 1, num)
        local text = ""
        if subWordBack[last] then
            text = NText:sub(1, num - 2)
        else
            text = NText:sub(1, num - 1)
        end
        
        options["sayingText"] = text
        local text = name .. text
        local a = 0
        local breaks = 0
        local font = exports['cr_fonts']:getFont(fontNames[options["font"]], options["fontsize"], options["bold"] == 1)
        local length = dxGetTextWidth(text, 1, font, true)
        if length > width then
            local i = 1
            local start = 1
            while true do
                local length = dxGetTextWidth(utfSub(text, start, i), 1, font, true)
                if length >= width then
                    breaks = breaks + 1
                    local startpos, endpos = utf8.find(text, "#", i - 7)
                    if startpos and startpos <= i - 1 then
                        i = startpos + 7
                    end
                    if utfSub(text, i - 1, i - 1) == "#" then
                        text = utfSub(text, 1, i - 2) .. "\n" .. utfSub(text, i - 1, #text)
                    else
                        text = utfSub(text, 1, i - 1) .. "\n" .. utfSub(text, i, #text)
                    end
                    start = i
                elseif i + 1 >= #text then
                    break
                end
                i = i + 1
            end
        end
        text = string.gsub(text, name, "")
        options["renderText"] = text
    end
end

function interactButton(b)
    if b == "enter" or b == "num_enter" then
        return interactText()
    end
    
    if b == "pgup" then
        return upMove()
    end
    
    if b == "pgdn" then
        return downMove()
    end
    
    return
end

function keyInteracts(b, s)
    if not s then
        if b == "backspace" then
            if isTimer(backspaceRepeatTimer) then
                killTimer(backspaceRepeatTimer)
            end
        elseif b == _b then
            if isTimer(buttonTimer) then
                killTimer(buttonTimer)
            end
            
            if isTimer(buttonTimerRepeatTimer) then
                killTimer(buttonTimerRepeatTimer)
            end
        end
    end
    if s and typing or s and b == "pgup" or s and b == "pgdn" then
        if b == "backspace" then
            backspace()
            if isTimer(backspaceTimer) then
                killTimer(backspaceTimer)
            end

            if isTimer(backspaceRepeatTimer) then
                killTimer(backspaceRepeatTimer)
            end
            
            return
        elseif b == "home" then
            if getKeyState("lshift") or getKeyState("rshift") then
                allSelected = true
                return
            end
        elseif b == "lshift" or b == "rshift" then
            if getKeyState("home") then
                allSelected = true
                return
            end
        elseif b == "-" then
            if getKeyState("lshift") or getKeyState("rshift") then
                b = "_"
            end
        end

        if isTimer(buttonTimer) then
            killTimer(buttonTimer)
        end

        if isTimer(buttonTimerRepeatTimer) then
            killTimer(buttonTimerRepeatTimer)
        end

        _b = b
        if b == "enter" or b == "num_enter" or b == "pgup" or b == "pgdn" then
            interactButton(b)
            if b == "pgup" or b == "pgdn" then
                buttonTimer = setTimer(
                    function()
                        if getKeyState(_b) then
                            interactButton(_b)
                            buttonTimerRepeatTimer = setTimer(
                                function()
                                    if getKeyState(_b) then
                                        interactButton(_b)
                                    end
                                end, 50, 0
                            )
                        end
                    end, 500, 1
                )
            end
        else
            cancelEvent()
        end
    end
end
addEventHandler("onClientKey", root, keyInteracts)

function addMessageToCache(text, r,g,b)
    if not customChatEnabled then return end
    if not text or #text <= 0 then return end
    
    if #cache >= options["lines"] + options["cacheRemain"] then
        table.remove(cache, options["lines"] + options["cacheRemain"])
    end
    
    
    if isTimer(mTimer) then killTimer(mTimer) end
    if maxLines > options["lines"] then
        mTimer = setTimer(
            function()
                downMove()
                if minLines == 1 then
                    killTimer(mTimer)
                end
            end, 50, 0
        )
    end
    
    local font = exports['cr_fonts']:getFont(fontNames[options["font"]], options["fontsize"], options["bold"] == 1)
    local length = dxGetTextWidth(text, 1, font, true)
    
    local text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
    text = string.gsub(text, "\n", "")
    
    local a = 0
    local breaks = 0
    local textSub = {}
    if length > width then
        local i = 1
        local start = 1
        local i2 = 1
        local remainText = ""
        while true do
            local length = dxGetTextWidth(utfSub(text, start, i), 1, font, true)
            if length >= width then
                breaks = breaks + 1
                local startpos, endpos = utf8.find(text, "#", i - 7)
                if startpos and startpos <= i - 1 then
                    i = startpos + 7
                end
                if utfSub(text, i - 1, i - 1) == "#" then
                    table.insert(textSub, utfSub(text, i2, i - 2) .. "\n")
                    i2 = i - 1
                    remainText = utfSub(text, i2, #text)
                    text = utfSub(text, 1, i - 2) .. "\n" .. utfSub(text, i - 1, #text)
                else
                    table.insert(textSub, utfSub(text, i2, i - 1) .. "\n")
                    i2 = i
                    remainText = utfSub(text, i2, #text)
                    text = utfSub(text, 1, i - 1) .. "\n" .. utfSub(text, i, #text)
                end
                start = i
            elseif i + 1 >= #text then
                table.insert(textSub, remainText)
                break
            end
            i = i + 1
        end

        text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
    end
    
    local t = {text, {r,g,b}, breaks + 1, text2, getTickCount(), 255, textSub}
    table.insert(cache, 1, t)
end
addEventHandler("onClientChatMessage", root, addMessageToCache)

function drawnChat()
    if not localPlayer:getData("hudVisible") then return end
    if not localPlayer:getData("loggedIn") then return end
    isChatEnabled, startX, startY, width, height = exports['cr_interface']:getDetails("chat")
    __startY = startY
    local _startY = startY
    if not isChatEnabled then
        customChatEnabled = false
        if not isChatEnabled then
            if not bb then
                bb = true
                _showChat(true)
            end
        end
        return
    else
        bb = false
        customChatEnabled = true
        _showChat(false)
    end    
    if owidth ~= width or oheight ~= height then
        recalculateIC()
    end
    
    owidth, oheight = width, height
    
    local lines = 0
    for k,v in pairs(cache) do
        local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)
        lines = lines + line
    end
    if not lines or not options["lines"] then
        return
    end
    startY = startY + ((math.min(lines, options["lines"])) * options["font-height"])
    
    local r,g,b,a = options["backgroundr"], options["backgroundg"], options["backgroundb"], options["backgrounda"]
    dxDrawRectangle(startX, _startY, width, height, tocolor(r,g,b,a))
    
    local font = exports['cr_fonts']:getFont(fontNames[options["font"]], options["fontsize"], options["bold"] == 1)
    local _maxLines, maxLines = options["lines"], maxLines
    local startY = startY - options["font-height"] 
    local _startY, startY = startY, startY
    if #cache >= 1 then
        if options["fadeout"] == 1 then
            local now = getTickCount() 
            for i, v in pairs(cache) do
                local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)
                if oTick + (options["showtime"] * 1000) < now then
                    local startTick, endTick = oTick + (options["showtime"] * 1000)
                    local elapsedTime = now - startTick
                    local duration = options["fadeoutmultiplier"] * 1000
                    local progress = elapsedTime / duration
                    local alph = interpolateBetween(
                        255, 0, 0,
                        0, 0, 0,
                        progress, "InOutQuad"
                    )
                    
                    cache[i][6] = alph
                    if progress >= 1.25 then
                        table.remove(cache, i)
                    end
                end
            end
        end
        
        for i = minLines, math.min(maxLines, #cache) do 
            if cache[i] then
                local v = cache[i]
                local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)
                local _CA = false
                if i >= minLines and i <= maxLines then

                    if line > 1 and i < minLines + 1 then
                        startY = startY - (options["font-height"] * (line - 1))
                    end
                    
                    if line - 1 > 0 then
                        if i + (line - 1) > maxLines then
                            local terrain = {}
                            local _i = i
                            local tY = math.floor(math.floor(__startY - startY) / options["font-height"])
                            for i = 1, tY do 
                                terrain[i] = true
                            end
                            
                            
                            local newText = ""
                            for BB = 1, #textSub do
                                local v = textSub[BB]
                                local v = v:gsub("\n", "")
                                if not terrain[BB] then
                                    newText = newText .. "#ffffff" .. v .. "\n"
                                end
                            end
                            
                            _CA = true
                            text = newText
                            textWithNoColor = string.gsub(newText, "#%x%x%x%x%x%x", "")
                        end
                    end

                    alpha = math.max(alpha, 0)

                    local r,g,b = unpack(color)
                    if _CA then
                        local startY = __startY
                        if alpha >= 1 then
                            if options["outline"] == 1 then 
                                shadowedText(textWithNoColor, startX, startY, startX + width, startY, tocolor(0,0,0,alpha), 1, font, "left", "top")
                            else 
                                dxDrawText(textWithNoColor, startX + 1, startY + 1, startX + width + 1, startY + 1, tocolor(0,0,0,alpha), 1, font, "left", "top", false, false, false, true)
                            end
                            dxDrawText(text, startX, startY, startX + width, startY, tocolor(r,g,b,alpha), 1, font, "left", "top", false, false, false, true)
                        end
                    else
                        if alpha >= 1 then
                            if options["outline"] == 1 then 
                                shadowedText(textWithNoColor, startX, startY, startX + width, startY + (options["font-height"] * line), tocolor(0,0,0,alpha), 1, font, "left", "top")
                            else 
                                dxDrawText(textWithNoColor, startX + 1, startY + 1, startX + width + 1, startY + (options["font-height"] * line) + 1, tocolor(0,0,0,alpha), 1, font, "left", "top", false, false, false, true)
                            end
                            dxDrawText(text, startX, startY, startX + width, startY + (options["font-height"] * line), tocolor(r,g,b,alpha), 1, font, "left", "top", false, false, false, true)
                        end
                    end

                    if cache[i + 1] then
                        local v = cache[i + 1]
                        local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)
                        local b = math.max(line, 2)
                        if line >= 2 then
                            startY = startY - (options["font-height"] * (b))
                        else
                            startY = startY - (options["font-height"] * (b - 1))
                        end
                    end
                    
                    if line > 1 then
                        maxLines = maxLines - (line - 1)
                    end
                end
            end
        end
    end
    
    local startY = _startY + (1 * options["font-height"])
    if typing then
        if options["outline"] == 1 then 
            shadowedText(name .. options["renderText"], startX, startY, startX + width, startY + (options["font-height"]), tocolor(0,0,0,255), 1, font, "left", "top", false, false, false, false)
        else 
            dxDrawText(name .. options["renderText"], startX + 1, startY + 1, startX + width + 1, startY + (options["font-height"]) + 1, tocolor(0,0,0,255), 1, font, "left", "top", false, false, false, false)
        end 
        dxDrawText(name .. options["renderText"], startX, startY, startX + width, startY + (options["font-height"]), tocolor(255,255,255,255), 1, font, "left", "top", false, false, false, false)
    end
end

function clearChat(cmd)
    isEnabledICChat = localPlayer:getData("chat.enabled")
    if not isEnabledICChat then
        local lines = getChatboxLayout()["chat_lines"]
        for i = 1, lines do
            outputChatBox("")
        end
    end
    cache = {}
    outputChatBox(exports['cr_core']:getServerSyntax() .. "IC Chat sikeresen kiürítve!", 0,255,0,true)
end
addCommandHandler("clearCHAT", clearChat)
addCommandHandler("ClearChat", clearChat)
addCommandHandler("Clearchat", clearChat)
addCommandHandler("clearchat", clearChat)

--
function searchSpace(a)
    local match = {}
    local d = 0
    local s = 0
   
    while true do
        local b, c = utf8.find(a, "%s", s)
        if b then
            s = b + 1
            d = d + 1
            match[d] = b
        else
            break
        end
    end
   
    return match
end
 
function matchConvertToString(text, matchTable)
    local args = ""
    local d = 0
    for i = 1, #matchTable do
        local v = matchTable[i] + 1
        if matchTable[i+1] then
            local v2 = matchTable[i+1] - 1
            local e = utfSub(text, v, v2)
            if #e > 0 then
                d = d + 1
                if tonumber(e) ~= nil then
                    e = tonumber(e)
                end
                args = args .. e .. " "
            end
        else
            d = d + 1
            local e = utfSub(text, v, #text)
            if #e > 0 then
                if tonumber(e) ~= nil then
                    e = tonumber(e)
                end
                args = args .. e .. " "
            end
        end
    end
   
    return args
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        cache = exports.cr_json:jsonGET("iccache")
        cache = {}
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        exports.cr_json:jsonSAVE("iccache", cache)
    end
)

--
local nodes = {}
local nodesT = {}

function getDetails(name)
    if nodes[name] then
        return nodes[name][1], nodes[name][2], nodes[name][3], nodes[name][4], nodes[name][5], nodes[name][6], nodes[name][7], nodes[name][8], nodes[name][9], nodes[name][10]
    else
        nodes[name] = {exports['cr_interface']:getDetails(name)}
        if not (nodesT[name]) then
            nodesT[name] = setTimer(
                function()
                    if nodes[name] ~= {exports['cr_interface']:getDetails(name)} then
                        nodes[name] = {exports['cr_interface']:getDetails(name)}
                    end
                end, 50, 0
            )
        end
        return nodes[name][1], nodes[name][2], nodes[name][3], nodes[name][4], nodes[name][5], nodes[name][6], nodes[name][7], nodes[name][8], nodes[name][9], nodes[name][10]
    end
    
    return exports['cr_interface']:getDetails(name)
end

function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY, ignoreDrawn)
    dxDrawText(text,x,y+1,w,h+1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Fent
    dxDrawText(text,x,y-1,w,h-1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Lent
    dxDrawText(text,x-1,y,w-1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Bal
    dxDrawText(text,x+1,y,w+1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Jobb
end