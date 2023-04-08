local cache = {}
local sx, sy = guiGetScreenSize()
local renderState = false
local types = {}
local details = {
    ["warning"] = {"Figyelmeztetés", "warning", "w.mp3"},
    ["error"] = {"Hiba", "error", "error.wav"},
    ["info"] = {"Információ", "information", "i.mp3"},
    ["vehicles"] = {"Járművek betöltése folyamatban...", "vehicles", "i.mp3"},
    ["tuningparts"] = {"Tuningpartok betöltése folyamatban...", "vehicles", "i.mp3"},
    ["skins"] = {"Skinek betöltése folyamatban...", "skins", "i.mp3"},
    ["weapons"] = {"Fegyverek betöltése folyamatban...", "weapons", "i.mp3"},
    ["models"] = {"Modellezések betöltése folyamatban...", "models", "i.mp3"},
    ["success"] = {"Siker", "success", "s.mp3"},
    ["aduty"] = {"Adminszolgálat", "adminduty", "adminduty.mp3"},
}

function searchBox(key)
    local val
    for k,v in pairs(cache) do
        if v["key"] == key then
            val = k
            break
        end
    end
    
    return val
end

function updateBoxDetails(key, detailID, nValue)
    if detailID == "msg" then
        local k = searchBox(key)
        if k then
            local type = cache[k]["type"]
            local msg = nValue
            local textLength = dxGetTextWidth(msg, 1, notificationFont, true) + 20
            
            cache[k]["msg"] = msg
            cache[k]["length"] = textLength
        end
    elseif detailID == "custom2.details" then
        local k = searchBox(key)
        if k then
            cache[k]["customProg"] = nValue
        end
    end
end

local lastClickTick = -500
function getColors(render)
    local enabled = true
    if render then
        if lastClickTick + 250 > getTickCount() then
            enabled = false
        end
        lastClickTick = getTickCount()
    end
    
    if enabled then
        engine = exports['cr_core']
        types = {
            --[type] = {"awesomeIcon", r,g,b}
            ["warning"] = {"", {engine:getServerColor('lightyellow', false)}},
            ["error"] = {"", {engine:getServerColor('red', false)}},
            ["info"] = {"", {engine:getServerColor('blue', false)}},
            ["models"] = {"", {engine:getServerColor('blue', false)}},
            ["vehicles"] = {"", {engine:getServerColor('blue', false)}},
            ["tuningparts"] = {"", {engine:getServerColor('blue', false)}},
            ["skins"] = {"", {engine:getServerColor('blue', false)}},
            ["weapons"] = {"", {engine:getServerColor('blue', false)}},
            ["success"] = {"", {engine:getServerColor('green', false)}},
            ["aduty"] = {engine:getIcon("fa-users"), {255, 200, 0}},
        }
    end
end

function addBox(type, msg, key, customDetails)
    notificationFont = exports['cr_fonts']:getFont("Poppins-Medium", 12);
    getColors()
    
    if types[type] then
        playSound("files/sounds/"..details[type][3])
        outputConsole("["..type.."] "..string.gsub(msg, "#%x%x%x%x%x%x", ""))

        for k,v in pairs(cache) do 
            if v["msg"]:lower() == msg:lower() then 
                cache[k]["now"] = getTickCount()
                cache[k]["end"] = getTickCount() + v["showtime"]
                cache[k]["state"] = "timeLineStart"
                return 
            end 
        end 

        local customData = {}
        local showtime = #msg * 200
        local customProg
        local typ, data = unpack(customDetails or {0, 0})
        if typ == 1 then
            showtime = tonumber(data)
        elseif typ == 2 then
            customProg = data
        end
        
        local textLength = dxGetTextWidth(msg, 1, notificationFont, true) + 20
        
        table.insert(cache, 
            {
                ["key"] = key or #cache + 1,
                ["msg"] = msg, 
                ["length"] = textLength, 
                ["now"] = getTickCount(), 
                ["end"] = getTickCount() + 1600, 
                ["state"] = "fadeIn", 
                ["type"] = type, 
                ["showtime"] = showtime,
                ["customProg"] = customProg,
            }
        )
        
        if #cache >= 1 then
            if not renderState then
                renderState = true
                --addEventHandler("onClientRender", root, drawnBoxes, true, "low-5")
                createRender("drawnBoxes", drawnBoxes)
            end
        end
    end
end

addEvent("addBox", true)
addEventHandler("addBox", root, addBox)
    
function drawnBoxes()
    notificationFont = exports['cr_fonts']:getFont("Poppins-Medium", 12);

    _sx, _sy = sx, sy
    local enabled, sx, nowY, w,h,sizable,turnable, sizeDetails, t, columns = exports['cr_interface']:getDetails("infobox")
    _nowY = nowY
    local now = getTickCount()
    for k,v in ipairs(cache) do
        local msg = v["msg"]
        local length = v["length"]
        local startTime = v["now"]
        local endTime = v["end"]
        local state = v["state"]
        local type = v["type"]
        local showtime = v["showtime"] or 8000
        local customProg = v["customProg"]
        local boxSize = 25 
        local pos, alpha -- = v["pos"], v["alpha"]
        
        local r,g,b = unpack(types[type][2])
        if not r or not g or not b then
            getColors(true)
        end
        
        local icon = types[type][1]
        local timeLine = false
        local timeLineProg
        
        if state == "fadeIn" then
            local elapsedTime = now - startTime
            local duration = endTime - startTime
            local progress = elapsedTime / duration

            if customProg and customProg[1] and customProg[2] then
                local progress = customProg[2] / customProg[1] -- now / max
                timeLine = true
                timeLineProg = progress
            end
            
            if progress < 1 then
                pos = {interpolateBetween(sx - 80, nowY, 0, sx, nowY, 0, progress, 'OutQuad')}
                alpha = {interpolateBetween(0,0,0, 220,255,0, progress, 'OutQuad')}
            else
                alpha = {220, 255, 0}
                pos = {sx, nowY, 0}
                cache[k]["now"] = getTickCount()
                cache[k]["end"] = getTickCount() + showtime
                cache[k]["state"] = "timeLineStart"
            end
        elseif state == "timeLineStart" then
            alpha = {220, 255, 0}
            pos = {sx, nowY, 0}
            local elapsedTime = now - startTime
            local duration = endTime - startTime
            local progress = elapsedTime / duration
            
            if customProg and customProg[1] and customProg[2] then
                progress = customProg[2] / customProg[1] -- now / max
            end
            
            timeLine = true
            
            timeLineProg = progress
            if progress >= 1 then
                cache[k]["now"] = getTickCount()
                cache[k]["end"] = getTickCount() + 1600
                cache[k]["state"] = "fadeOut"
            end
        elseif state == "fadeOut" then
            timeLine = true
            local now = getTickCount()
            local elapsedTime = now - startTime
            local duration = endTime - startTime
            local progress = elapsedTime / duration
            
            pos = {interpolateBetween(sx, nowY, 0, sx, nowY, 0, progress, 'OutQuad')}
            alpha = {interpolateBetween(220, 255,0, 0,0,0, progress, 'OutQuad')}

            if progress >= 0.95 then
                table.remove(cache, k)
                if #cache <= 0 then
                    if renderState then
                        renderState = false
                        destroyRender("drawnBoxes")
                    end
                end
            end
        end
        
        local boxWidth = length -- + 70
        dxDrawRectangle(pos[1], pos[2], boxWidth, 40, tocolor(51, 51, 51, alpha[1]),true)
        dxDrawText(msg, pos[1] + 5, pos[2] + 40/2, pos[1] + boxWidth, pos[2] + 40/2, tocolor(229, 229, 229, alpha[2]), 1, notificationFont, 'center', 'center',false,false,true,true,false)
        
        if timeLine then
            timeLineSize = interpolateBetween(40, 0,0, 0, 0,0, timeLineProg or 1, customProg and "Linear" or 'OutQuad')
        else
            timeLineSize = 40
        end
        dxDrawRectangle(pos[1], pos[2], 5, timeLineSize, tocolor(r, g, b, alpha[2]),true)
        
        nowY = nowY + 45
    end
end