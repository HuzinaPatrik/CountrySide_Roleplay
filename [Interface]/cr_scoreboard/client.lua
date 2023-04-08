cache = {}
white = "#e5e5e5"
options = {}
screen = Vector2(guiGetScreenSize())
center = Vector2(screen.x/2, screen.y/2)
size = Vector2(200, 500)
sizes = {
    ["top"] = Vector2(500, 45),
    ["center"] = Vector2(500, 85),
    ["text"] = Vector2(500, 16),
    ["bottom"] = Vector2(500, 45),
    ["search"] = Vector2(470, 25),
}
a = "files/"

minLines = 1
maxLines = math.floor((screen.y - 150 - (sizes["top"].y + sizes["bottom"].y + sizes["center"].y + 160)) / 16)
if maxLines >= 20 then maxLines = 20 end
_maxLines = maxLines

--
import("*"):from("cr_core")

addEventHandler("onClientResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_core" then
            import("*"):from("cr_core")
            --startCustomChat()
        end
    end
)

bindKey("tab", "down",
    function()
        if not localPlayer:getData("loggedIn") then return end
        if localPlayer:getData("keysDenied") then return end
        if not freezeInteract then
            sTimer = setTimer(
                function()
                    if getKeyState("tab") then
                        freezeInteract = true
                    end
                end, 2000, 1
            )
            startScore()
        else
            freezeInteract = false
            stopScore()
        end
    end
)

bindKey("tab", "up",
    function()
        if not freezeInteract then
            stopScore()
        end
    end
)

bindKey("mouse_wheel_up", "down",
    function()
        if state then
            if minLines - 1 >= 1 then
                playSound("files/wheel.wav")
                minLines = minLines - 1
                maxLines = maxLines - 1
            end
        end
    end
)

bindKey("mouse_wheel_down", "down",
    function()
        if state then
            local text = "" 
            if textbars["search"] then
                text = textbars["search"][2][2]
            end
            local count = #cache

            if #text > 0 then
                count = #searchCache
            end
            
            if maxLines + 1 <= count then
                playSound("files/wheel.wav")
                minLines = minLines + 1
                maxLines = maxLines + 1
            end
        end
    end
)

addEventHandler("onClientClick", root,
    function(b, s)
        if state then
            if b == "left" and s == "down" then
                if isInSlot(_sX, _sY, _sW, _sH) then
                    scrolling = true
                end
            elseif b == "left" and s == "up" then
                if scrolling then
                    scrolling = false
                end
            end
        end
    end
)

startAnimation = "InOutQuad"
startAnimationTime = 250 -- / 1000 = 0.2 másodperc
function startScore()
    if not localPlayer:getData("loggedIn") then return end   
    _state = state
    scrolling = false
    state = true
    slots = root:getData("serverslot") or 512
    multipler = 20
    alpha = 0
    cacheCreate()
    if not _state then
        --addEventHandler("onClientRender", root, drawnScoreboard, true, "low-5")
        createRender("drawnScoreboard", drawnScoreboard)
    end
    if not start then
        start = true
        startTick = getTickCount()
    end
    bar = false
    
    exports['cr_dx']:createLogoAnimation("score", 1, {0, 0, 130, 150}, {10000, 1000})
end

function stopScore()
    if not localPlayer:getData("loggedIn") then return end
    if isTimer(sTimer) then
        killTimer(sTimer)
    end
    if start then
    --  Clear()
        --removeEventHandler("onClientRender", root, drawnScoreboard)
        --state = false
        start = false
        exports['cr_dx']:stopLogoAnimation("score")
        startTick = getTickCount()
    --    cacheDestroy()
    end
end

function drawnScoreboard()
    if localPlayer:getData("keysDenied") then 
        stopScore()
    end 

    local now = getTickCount()
    local nowTick = now
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
        
        if progress >= 1 then
            animState = true
        end
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
            animState = false
            alpha = 0
            Clear()
            cacheDestroy()
            state = false
            --removeEventHandler("onClientRender", root, drawnScoreboard)
            destroyRender("drawnScoreboard")
        end
    end

    --fontBig = exports['cr_fonts']:getFont("Roboto", 12)
    --local count = #cache
    local text = "" 
    if textbars["search"] then
        text = textbars["search"][2][2]
    end
    local count = count
    local _count = count
    
    if #text > 0 then
        count = #searchCache
        _count = count
    end
    --outputChatBox("countStart: " .. count)
    if count >= _maxLines then
        count = _maxLines
    end
    
    --outputChatBox("count: " .. count)
    --outputChatBox("maxLines: " .. maxLines)
    local y = center.y - ((((count) * sizes["text"].y + 5) + (sizes["top"].y + sizes["center"].y + sizes["bottom"].y)) / 2)
    --a Cikklus helyett kell 1 matematikai egyenlet
    local centerY = sizes["center"].y
    --local count = 0
    
    for i = minLines, maxLines do
        if #text > 0 and searchCache[i] or #text <= 0 and cache[i] then
            local v = searchCache[i]
            if not v then
                v = cache[i]
            end
            
            centerY = centerY + sizes["text"].y + 5
        end
    end
    
    exports['cr_dx']:updateLogoPos("score", {center.x, y - 100, 130, 150})
    --dxDrawImage(center.x - sizes["top"].x/2, y, sizes["top"].x, sizes["top"].y, sources["top"], 0,0,0, tocolor(255,255,255,alpha))
    --dxDrawRectangle(center.x - sizes["top"].x/2 - 2, y - 2, 452 + 4, fullY + 2, tocolor(31,31,31,math.min(255 * 0.95, alpha)))

    font = exports['cr_fonts']:getFont('Poppins-SemiBold', 18)
    font2 = exports['cr_fonts']:getFont('Poppins-Medium', 14)
    dxDrawRectangle(center.x - sizes["top"].x/2, y, sizes["top"].x, sizes["top"].y, tocolor(51, 51, 51, alpha * 0.9))

    local tx = center.x - sizes["top"].x/2
    local gColor = "#e5e5e5"
    dxDrawText("ID", tx + 47, y, tx + 47, y + sizes["top"].y, tocolor(242, 242, 242, alpha), 1, font, "center", "center")
    dxDrawText("Név", tx + 155, y, tx + 155, y + sizes["top"].y, tocolor(242, 242, 242, alpha), 1, font, "center", "center")
    dxDrawText("Szint", tx + 272, y, tx + 272, y + sizes["top"].y, tocolor(242, 242, 242, alpha), 1, font, "center", "center")
    dxDrawText("Online idő", tx + 367, y, tx + 367, y + sizes["top"].y, tocolor(242, 242, 242, alpha), 1, font, "center", "center")
    dxDrawText("Ping", tx + 460, y, tx + 460, y + sizes["top"].y, tocolor(242, 242, 242, alpha), 1, font, "center", "center")
    
    y = y + sizes["top"].y + 2

    dxDrawRectangle(center.x - sizes["center"].x/2, y, sizes["center"].x, centerY, tocolor(51, 51, 51, alpha * 0.8))

    local __StartY = y

    y = y + 15
    dxDrawRectangle(center.x - sizes["search"].x/2, y, sizes["search"].x, sizes["search"].y, tocolor(51, 51, 51, alpha * 0.8))
    dxDrawImage(center.x + sizes["search"].x/2 - 20, y + sizes["search"].y/2 - 15/2, 15, 15, "files/search.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    if not bar then
        CreateNewBar("search", {center.x - sizes["search"].x/2 + 10, y + 2, sizes["search"].x, sizes["search"].y}, {25, "", false, nil, font2, 1, "left", "center"}, 1)
        bar = true
    else
        UpdatePos("search", {center.x - sizes["search"].x/2 + 10, y + 2, sizes["search"].x, sizes["search"].y, alpha})
    end

    dxDrawText("Játékosok", center.x - sizes["search"].x/2 + 10, y + sizes["search"].y + 2, center.x - sizes["search"].x/2 + 10, y + 2 + sizes["search"].y + 35, tocolor(242, 242, 242, alpha), 1, font, "left", "center")

    dxDrawRectangle(center.x - 485/2, y + sizes["search"].y + 35, 485, 2, tocolor(165, 165, 165, alpha * 0.6))

    y = y + sizes["center"].y - 15
    --local count = 

    local avatarSelected = nil
    
    for i = minLines, maxLines do
        if #text > 0 and searchCache[i] or #text <= 0 and cache[i] then
            local tooltip, tooltipLines = false, 0
            local v = searchCache[i]
            if not v then
                v = cache[i]
            end
            local loggedin = v["loggedin"]
            local timedout = v["timedout"]
            local id = v["id"]
            local aduty = v["aduty"]
            local aColor = v["aColor"]
            local aTitle = v["aTitle"]
            local name = v["name"]
            local lvl = v["lvl"]
            local avatar = v["avatar"]
            local onlineTime = v["onlineTime"]
            local ping = v["ping"]
            local pingColor = v["pingColor"]

            --[[Avatar]]
            local rx = center.x - sizes["top"].x/2 + 10 -- avatar
            dxDrawRectangle(rx, y + 2, 15, 15, tocolor(23, 23, 23, alpha * 0.8))
            dxDrawImage(rx + 1, y + 2 + 1, 13, 13, ":cr_interface/hud/files/avatars/"..avatar..".png", 0,0,0, tocolor(255,255,255,alpha))

            if exports['cr_core']:isInSlot(rx, y + 2, 15, 15) then 
                avatarSelected = avatar
            end 
            --[[//Avatar]]

            local rx = center.x - sizes["top"].x/2 + 47 -- id
            dxDrawText(id, rx, y, rx, y, tocolor(242, 242, 242,(loggedin and alpha) or math.min(255 * 0.25, alpha)), 1, font2, "center", "top",false,false,false,true)

            if loggedin then
                local rx = center.x - sizes["top"].x/2 + 272 -- szint
                dxDrawText(lvl, rx, y, rx, y, tocolor(242, 242, 242,alpha), 1, font2, "center", "top",false,false,false,true)
            end

            local rx = center.x - sizes["top"].x/2 + 367 -- playedtime
            dxDrawText(onlineTime .. " perc", rx, y, rx, y, tocolor(242, 242, 242,(loggedin and alpha) or math.min(255 * 0.25, alpha)), 1, font2, "center", "top",false,false,false,true)

            local rx = center.x - sizes["top"].x/2 + 460 -- ping
            dxDrawText(pingColor .. ping .. white .. " ms", rx, y, rx, y, tocolor(242, 242, 242,(loggedin and alpha) or math.min(255 * 0.25, alpha)), 1, font2, "center", "top",false,false,false,true)
            
            if aduty then
                name = aColor .. "[" .. aTitle .. "] " .. white .. name
            end

            local alpha = alpha
            if not loggedin then
                --name = "#F2F2F2" .. name .
                local w = dxGetTextWidth(name,1,font, true)
                local h = 16 -- dxGetFontHeight(1, font)
                local x,y = center.x - sizes["top"].x/2 + 155 - w/2, y
                if isInSlot(x, y, w, h) then
                    --exports['cr_dx']:drawTooltip("#F2F2F2Nincs bejelentkezve", 1)
                    tooltip = "#F2F2F2Nincs bejelentkezve"
                    tooltipLines = tooltipLines + 1
                end
            end

            if timedout then
                local _, newAlpha = interpolateBetween(-5, 0, 0, 5, alpha, 0, now / 2500, "CosineCurve")
                alpha = newAlpha
                
                local w = dxGetTextWidth(name,1,font, true)
                local h = 16 -- dxGetFontHeight(1, font)
                local x,y = center.x - sizes["top"].x/2 + 155 - w/2, y
                --dxDrawRectangle(x,y,w,h)
                if isInSlot(x, y, w, h) then
                    --exports['cr_dx']:drawTooltip("#d23131Internethiba", 1)
                    tooltip = (tooltipLines >= 1 and tooltip.."\n" or "") .. "#d23131Internethiba"
                    tooltipLines = tooltipLines + 1
                end
                
                --name = "#d23131" .. name .. " (Internethiba)"
            end

            local rx = center.x - sizes["top"].x/2 + 155 -- név
            dxDrawText(name, rx, y - 1, rx, y - 1, tocolor(242, 242, 242,(loggedin and alpha) or math.min(255 * 0.25, alpha)), 1, font2, "center", "top",false,false,false,true)
            
            if tooltip then
                exports['cr_dx']:drawTooltip(1, tooltip)
            end

            y = y + sizes["text"].y + 5
        end
    end
    
    y = y + 2
    
    --scrollboard
    
    local percent = #cache
    if #text > 0 then
        percent = #searchCache
    end
    
    if percent >= 1  then
        local gW, gH = 5, centerY
        local gX, gY = center.x + sizes["center"].x/2 - gW, __StartY
        _sX, _sY, _sW, _sH = gX, gY, gW, gH
        
        if scrolling then
            if isCursorShowing() then
                if getKeyState("mouse1") then
                    local cx, cy = exports['cr_core']:getCursorPosition()
                    local cy = math.min(math.max(cy, _sY), _sY + _sH)
                    local y = (cy - _sY) / (_sH)
                    local num = percent * y
                    minLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _maxLines) + 1)))
                    maxLines = minLines + (_maxLines - 1)
                end
            else
                scrolling = false
            end
        end
        
        dxDrawRectangle(gX,gY,gW,gH, tocolor(242,242,242,alpha * 0.6))
        --[[
        if not percent[key + (maxColumns * (maxLines - 1))] then
            key = 1
            _key = key - 1
        end

        local percent = #percent
        local _percent = percent

        if percent / maxColumns ~= math.floor(percent / maxColumns) then
            --percent = ((percent / maxColumns) + (math.ceil(percent / maxColumns) - (percent / maxColumns))) * maxColumns
            percent = math.ceil(percent / maxColumns) * maxColumns
        end]]

        --outputChatBox("1>"..(maxColumns * (maxLines - 1)))
        --outputChatBox("2>"..percent)
        local multiplier = math.min(math.max((maxLines - (minLines - 1)) / percent, 0), 1)
        --outputChatBox("3>".._key)
        local multiplier2 = math.min(math.max((minLines - 1) / percent, 0), 1)
        local gY = gY + ((gH) * multiplier2)
        local gH = gH * multiplier
        local r,g,b = 51, 51, 51
        dxDrawRectangle(gX, gY, gW, gH, tocolor(r,g,b, alpha))
        --
        --dxDrawImage(center.x - sizes["bottom"].x/2, y, sizes["bottom"].x, sizes["bottom"].y, sources["bottom"], 0,0,0, tocolor(255,255,255,alpha))
        --local rx = center.x - sizes["bottom"].x/2 + 10
        --local ry = y + 5
    end
    
    dxDrawRectangle(center.x - sizes["bottom"].x/2, y, sizes["bottom"].x, sizes["bottom"].y, tocolor(51, 51, 51, alpha * 0.9))
    dxDrawText("www.csrp.hu", center.x - sizes["bottom"].x/2 + 25, y + 2, center.x + sizes["bottom"].x/2, y + sizes["bottom"].y, tocolor(242, 242, 242, alpha), 1, font, "left", "center", false, false, false, true)
    dxDrawText("Online játékosok:        "..(#cache).."/"..slots, center.x - sizes["bottom"].x/2, y + 2, center.x + sizes["bottom"].x/2 - 25, y + sizes["bottom"].y, tocolor(242, 242, 242, alpha), 1, font, "right", "center", false, false, false, true)
    --dxDrawRectangle(rx - sizes["search"].x/2, ry - sizes["search"].y/2, sizes["search"].x, sizes["search"].y)
    
    --local rx = center.x + sizes["center"].x/2 - 10
    
    --dxDrawText("Online játékosok: #d97c0e"..#cache.."/"..slots, rx, y, rx, y + sizes["center"].y, tocolor(255,255,255,alpha), 1, font, "right", "center",false,false,false,true)
    --y = y + sizes["bottom"].y
    --dxDrawImage(center.x - sizes["staymta"].x/2, y, sizes["staymta"].x, sizes["staymta"].y, sources["staymta"], 0,0,0, tocolor(255,255,255,alpha))

    if tonumber(avatarSelected) then 
        local cx, cy = exports['cr_core']:getCursorPosition()

        dxDrawRectangle(cx - 45/2, cy - 45/2, 45, 45, tocolor(23, 23, 23, alpha * 0.8))
        dxDrawImage(cx - 43/2, cy - 43/2, 45, 45, ":cr_interface/hud/files/avatars/"..tonumber(avatarSelected)..".png", 0,0,0, tocolor(255,255,255,alpha))
    end 
end

--Cache Function
function cacheCreate()
    if state then
        --outputChatBox("asd")
        cacheDestroy()

        local a = 1
        for k,v in pairs(getElementsByType("player")) do
            if v ~= localPlayer then
                local details = cacheGetDetails(v)
                table.insert(cache, details)
                a = a + 1
            end
        end
        
        --[[local names = {
            "Thomas_Stevens",
            "Joey_Briton",
            "Emanuel_Estephan",
            "Elliot_Carney",
            "Bobby_Morse",
            "Maison_Gould",
            "Frederick_John",
            "Corey_Sargent",
            "Deangelo_Bernard",
            "Michael_Taylor",
            "Oliver_Morgan",
            "Griffin_Powell",
            "May_Brighton",
            "Jack_Emanuel",
            "Jack_Stephen",
            "Joe_Boe",
            "Joe_Boe",
            "Joe_Boe",
        }

        for i = 3, 500 do
            local ped = createPed(107, 0, 0,0)
            ped:setData("char >> level", math.random(2, 15))
            local num = math.random(1, 15)
            local num2 = math.random(1, 2)
            if num == 10 then num = 1 end
            if num2 == 1 then
                num2 = true
            else
                num2 = false
            end
            --local name = names[i - 3]
            if num2 then
                ped:setData("char >> onlineTime", num)
                ped:setData("loggedIn", num2)
            end
            --ped:setData("char >> name", names[math.random(1, 2)])
            --outputChatBox(names[i - 3])
            local details = cacheGetDetails(ped, names[math.random(1, #names)])
            details["id"] = i
            table.insert(cache, details)
            a = a + 1
        end--]]
        
        count = a

        local details = cacheGetDetails(localPlayer)
        table.insert(cache, 1, details)
        
        table.sort(cache, function(a, b)
            if a["element"] and b["element"] and a["element"] ~= localPlayer and b["element"] ~= localPlayer and a["id"] and b["id"] then
                return tonumber(a["id"]) < tonumber(b["id"])
            end
        end);

        if maxLines > #cache then
            minLines = 1
            maxLines = minLines + (_maxLines - 1)
        end

        if isTimer(pingUpdateTimer) then destroyElement(pingUpdateTimer) end
        pingUpdateTimer = setTimer(
            function()
                --cacheCreate()
                for i = minLines, maxLines do
                    if cache[i] then
                        local _i = i
                        local i = cache[i]
                        local v = i["element"]
                        if isElement(v) then
                            cache[_i]["ping"] = v.ping or -1
                            cache[_i]["pingColor"] = getPingColor(v.ping or -1)
                        else
                            cacheCreate()
                        end
                    end
                end
            end, 1000, 0
        )

        --outputDebugString("Score: Cache - created")
    end
end

addEventHandler("onClientPlayerJoin", root, 
    function()
        setTimer(cacheCreate, 150, 1)
    end
)
addEventHandler("onClientPlayerQuit", root, cacheCreate)

function cacheGetDetails(v, a2)
    local a = {}

    local aTitle = exports['cr_admin']:getAdminTitle(v) or "Ismeretlen"
    local adutyState = v:getData("admin >> duty") or false

    if aTitle == "Ideiglenes Adminsegéd" then 
        aTitle = "Idg. AS"
        adutyState = true
    elseif aTitle == "Adminsegéd" then
        aTitle = "AS"
        adutyState = true
    end

    a["loggedin"] = v:getData("loggedIn")
    a["timedout"] = v:getData("timedout")
    a["id"] = v:getData("char >> id") or 0
    a["aduty"] = adutyState
    a["aColor"] = exports['cr_admin']:getAdminColor(v, nil, true) or "#ffffff"

    a["aTitle"] = aTitle
    local name = a2 or exports['cr_admin']:getAdminName(v) or "Ismeretlen"
    name = string.gsub(name, "_", " ")
    name = string.gsub(name, "#" .. (6 and string.rep("%x", 6) or "%x+"), "")
    a["name"] = string.gsub(name, "#%x%x%x%x%x%x", "")
    a["lvl"] = v:getData("char >> level") or 1
    a["avatar"] = v:getData("char >> avatar") or 0
    a["onlineTime"] = v:getData("char >> onlineTime") or 0
    a["ping"] = v.ping or -1
    a["pingColor"] = getPingColor(v.ping or -1)
    a["element"] = v
    return a
end

function cacheDestroy()
    cache = {}
    
    if isTimer(pingUpdateTimer) then
        killTimer(pingUpdateTimer)
    end
end

function search(e)
    for a, b in pairs(cache) do
        local x = b["element"]
        if x == e then
            return a
        end
    end
    
    --outputChatBox(i)
    return false
end

function getPingColor(ping)
    local color = "#ffffff"
    
    if ping <= 60 then -- zöld
        color = "#7cc576"
    elseif ping <= 130 then -- sárga
        color = "#d09924"
    elseif ping >= 130 then -- piros
        color = "#d02424"
    end
    
    return color
end

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue, nValue)
        if state then
            if dName == "serverslot" then 
                slots = nValue
            elseif dName == "loggedIn" then
                local k = search(source)
                if k then
                    local value = source:getData(dName)
                    cache[k]["loggedin"] = value
                end
            elseif dName == "char >> id" then
                local k = search(source)
                if k then
                    local value = source:getData(dName)
                    cache[k]["id"] = value
                end
            elseif dName == "timedout" then
                local k = search(source)
                if k then
                    local value = source:getData(dName)
                    cache[k]["timedout"] = value
                end
            elseif dName == "admin >> duty" or dName == "admin >> nick" or dName == "admin >> name" or dName == "admin >> level" then
                local k = search(source)
                if source == localPlayer then
                    --outputChatBox("asd2")
                    --cacheCreate()
                end
                
                if k then
                    local value = source:getData(dName)
                    if dName == "admin >> duty" then
                        cache[k]["aduty"] = value
                    end
                    
                    local name = exports['cr_admin']:getAdminName(source)
                    name = string.gsub(name, "_", " ")
                    cache[k]["name"] = string.gsub(name, "#%x%x%x%x%x%x", "")
                    cache[k]["aColor"] = exports['cr_admin']:getAdminColor(source, nil, true)
                    cache[k]["aTitle"] = exports['cr_admin']:getAdminTitle(source)
                    searchCache = {}
                    if textbars["search"] and textbars["search"][2] and textbars["search"][2] then
                        local text = string.lower(textbars["search"][2][2])
                        if #text > 0 then
                            for k,v in pairs(cache) do
                                local text2 = string.lower(v["name"])
                                local e = v["element"]
                                if utf8.find(text2, text) then
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
                    end
                end
            elseif dName == "char >> name" then
                local k = search(source)
                if k then
                    local name = exports['cr_admin']:getAdminName(source)
                    name = string.gsub(name, "_", " ")
                    cache[k]["name"] = string.gsub(name, "#%x%x%x%x%x%x", "")
                    searchCache = {}
                    local text = string.lower(textbars["search"][2][2])
                    if #text > 0 then
                        for k,v in pairs(cache) do
                            local text2 = string.lower(v["name"])
                            local e = v["element"]
                            if utf8.find(text2, text) then
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
                end
            elseif dName == "char >> level" then
                local k = search(source)
                if k then
                    local value = source:getData(dName)
                    cache[k]["lvl"] = value
                end
            elseif dName == "char >> onlineTime" then
                local k = search(source)
                if k then
                    local value = source:getData(dName)
                    cache[k]["onlineTime"] = value
                end    
            elseif dName == "char >> avatar" then
                local k = search(source)
                if k then
                    local value = source:getData(dName)
                    cache[k]["avatar"] = value
                end   
            end
        end
    end
)

setTimer(
    function()
        localPlayer:setData("char >> onlineTime", tonumber(localPlayer:getData("char >> onlineTime") or 0) + 1)
    end, 1 * 60 * 1000, 0
)