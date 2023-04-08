local minLines, maxLines = 0,0
local startX, startY = 0,0
local _startX, _startY, __startY = 0,0,0
local width, height = 0,0
local owidth,oheight = 0,0
local state = false
local x,y = 20, 500
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

function setOOCOption(name, val)
    options[name] = val
end 

local function initWidgets()
    startOOC()
end

addEventHandler("onClientResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_interface" then
            setTimer(initWidgets, 1000, 1)
        elseif startedRes == getThisResource() then
            if(getResourceState(getResourceFromName("cr_interface")) == "running")then
                setTimer(initWidgets, 1000, 1)
            end
        end
    end
)

function recalculateOOC()
    local font = exports['cr_fonts']:getFont(fontNames[options["font"]], options["fontsize"], options["bold"] == 1)
    options["font-height"] = dxGetFontHeight(1, font)
    options["lines"] = math.floor(height / options["font-height"])
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

            local a = 0
            local breaks = 0
            local textSub = {}
            local inserted = {}
            if length >= width then
                local i = 1
                local i2 = 1
                local start = 1
                local remainText = ""
                while true do
                    local length = dxGetTextWidth(utfSub(text, start, i), 1, font, true)
                    if length >= width then
                        breaks = breaks + 1
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
    end
end

function refreshOOC()
    for i, v in pairs(cache) do
        local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)
        cache[i][5] = getTickCount()
        cache[i][6] = 255
    end
end

function startOOC()
    _, startX, startY, width, height = exports['cr_interface']:getDetails("oocchat") --exports['cr_widget']:getPosition(oocchat)
    isEnabledOOCChat = localPlayer:getData("oocchat.enabled")
    local font = exports['cr_fonts']:getFont(fontNames[options["font"]], options["fontsize"], options["bold"] == 1)
    options["font-height"] = dxGetFontHeight(1, font)
    if isEnabledOOCChat then
        createRender("drawnOOC", drawnOOC)
        owidth, oheight = width, height
        options["font-height"] = dxGetFontHeight(1, font)
        options["lines"] = math.floor(height / options["font-height"])
        startY = startY + ((options["lines"]) * options["font-height"])
        minLines = 1
        maxLines = options["lines"]
    else
        destroyRender("drawnOOC")
    end
end

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName)
        if dName == "oocchat.enabled" then
            startOOC()
        end
    end
)

function clearOOC(cmd)
    cache = {}
end
addCommandHandler("clearOOC", clearOOC)
addCommandHandler("ClearOOC", clearOOC)
addCommandHandler("Clearooc", clearOOC)
addCommandHandler("clearooc", clearOOC)

function insertOOC(text, color)
    if not color then
        color = {255,255,255}
    end
    local r,g,b = unpack(color)
    
    if #cache >= options["lines"] + options["cacheRemain"] then
        table.remove(cache, options["lines"] + options["cacheRemain"])
    end
    
    local font = exports['cr_fonts']:getFont(fontNames[options["font"]], options["fontsize"], options["bold"] == 1)
    local length = dxGetTextWidth(text, 1, font, true)
    
    local text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
    text = string.gsub(text, "\n", "")
    
    local a = 0
    local breaks = 0
    local textSub = {}
    local inserted = {}
    if length > width then
        local i = 1
        local i2 = 1
        local start = 1
        local remainText = ""
        while true do
            local length = dxGetTextWidth(utfSub(text, start, i), 1, font, true)
            if length >= width then
                breaks = breaks + 1
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

function drawnOOC()
    if not localPlayer:getData("hudVisible") then return end
    if not localPlayer:getData("loggedIn") then return end
    isOOCEnabled, startX, startY, width, height = exports['cr_interface']:getDetails("oocchat")
    if not isOOCEnabled then return end
    __startY = startY
    startY = startY - 20
    _startY = startY
    if owidth ~= width or oheight ~= height then
        recalculateOOC()
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
    dxDrawRectangle(startX, __startY, width, height, tocolor(r,g,b,a))
    local _maxLines, maxLines = options["lines"], maxLines
    local _startY, startY = startY, startY
    if #cache >= 1 then
        local font = exports['cr_fonts']:getFont(fontNames[options["font"]], options["fontsize"], options["bold"] == 1)
        local now = getTickCount() 
        if options["fadeout"] == 1 then
            for i, v in pairs(cache) do
                local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)
                if oTick + (options["showtime"] * 1000) < now then
                    local startTick = oTick + (options["showtime"] * 1000)
                    local elapsedTime = now - startTick
                    local duration = options["fadeoutmultiplier"] + 1000
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
                                    newText = newText .. v .. "\n"
                                end
                            end
                            
                            _CA = true
                            text = newText
                            textWithNoColor = string.gsub(text, "#%x%x%x%x%x%x", "")
                        end
                    end

                    alpha = math.max(alpha, 0)

                    local r,g,b = unpack(color)
                    if _CA then
                        if alpha >= 1 then
                            local startY = __startY
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
end

function getHourAndMinute()
	local realtime = getRealTime()
	hours = realtime.hour
	minute = realtime.minute
	if hours < 10 then
		hours = "0"..hours
	end
	if minute < 10 then
		minute = "0"..minute
	end
	return hours..":"..minute
end

function onOOCMessageSend(message, typ, p)
    if not typ then
        typ = 0
    end
    local text = "["..getHourAndMinute().."] "..message
    local r,g,b = 255, 255, 255
	if getElementData(p, "admin >> duty") or tostring(typ) == "gb" then
		r,g,b = exports['cr_admin']:getAdminColor(p)
    end
    
    if tostring(typ) == "gb" then 
        r,g,b = 255, 0, 0
    end 

	insertOOC(text, {r,g,b})
	outputConsole("[OOC]"..text)
end
addEvent("onOOCMessageSend", true)
addEventHandler("onOOCMessageSend", root, onOOCMessageSend)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        cache = exports.cr_json:jsonGET("ooccache")
        cache = {}
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        exports.cr_json:jsonSAVE("ooccache", cache)
    end
)