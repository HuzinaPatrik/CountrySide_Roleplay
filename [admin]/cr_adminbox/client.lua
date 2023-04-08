local cache = {}
local sx, sy = guiGetScreenSize()
local renderState = false
local types = {}
local details = {
    ["warning"] = {"Kirúgás", "kick"},
    ["error"] = {"Kitiltás", "ban"},
    ["info"] = {"Börtön", "jail"},
}

addEventHandler('onClientResourceStart', resourceRoot, 
    function()
        tex = {
            ['ban'] = dxCreateTexture("notificationIcons/ban.png", "argb", true, 'clamp'),
            ['kick'] = dxCreateTexture("notificationIcons/kick.png", "argb", true, 'clamp'),
            ['jail'] = dxCreateTexture("notificationIcons/jail.png", "argb", true, 'clamp'),
        }
    end 
)

addCommandHandler('pina123', 
    function()
        local red = exports['cr_core']:getServerColor("red", true)
        local blue = exports['cr_core']:getServerColor('yellow', true)
        local white = "#F2F2F2"

        adminName = 'Pina123'
        jatekosName = 'Pina4'
        jailTime = 'Korlátlan'
        reason = 'Adminuralom Zéro Tolerancia'

        addBox(blue..adminName..white.." bebörtönözte "..red..jatekosName..white.." játékost\nIdőtartam: "..red..jailTime..white.."\nIndok: "..red..reason, "info")                        

        text = 'Fejlesztőuralom vissza ne gyere!'
        addBox(blue..adminName..white.." kirúgta "..red..jatekosName..white.." játékost"..white.."\nIndok: "..red..text, "warning")

        aName = 'Lagzi Lajos'
        targetName = 'Pina5'
        banText = 'Örökre'
        reason = 'Kurva édesanyád vissza ne gyere!'
        addBox(blue .. aName.. white .. " kitiltotta "..red..targetName..white.."-at/et a szerverről! "..red.."[Offline]"..white.."\n"..banText.."\nIndok: "..red..reason, "error")
    end 
)

function addBox(msg, type)
    notificationFont = exports['cr_fonts']:getFont("Poppins-Medium", 14);
    engine = exports['cr_core']
    types = {
        --[type] = {"awesomeIcon", r,g,b}
        ["warning"] = {"", {engine:getServerColor('white', false)}},
        ["error"] = {"", {engine:getServerColor('red', false)}},
        ["info"] = {"", {engine:getServerColor('orange', false)}},
    }

    if types[type] then
        local showtime = #msg * 100
        
        local textLength = dxGetTextWidth(msg, 1, notificationFont, true) + 10
                    
        local line = 0
        local latest = 0
        
        while true do
            local a, b = utf8.find(msg, "\n", latest)
            if a and b then
                latest = b + 1
                line = line + 1
            else
                break
            end
        end            

        line = math.max(1, line)
        
        playSound("files/beep.mp3")
        table.insert(cache, 
            {
                ["key"] = key or #cache + 1,
                ["msg"] = msg, 
                ["length"] = textLength, 
                ["now"] = getTickCount(), 
                ["end"] = getTickCount() + 1600, 
                ["state"] = "fadeIn", 
                ["type"] = type, 
                ["tick"] = 0,
                ["lines"] = line,
                ["showtime"] = showtime,
            }
        )
        
        if #cache >= 1 then
            if not renderState then
                renderState = true
                addEventHandler("onClientRender", root, drawnBoxes, true, "low-5")
            end
        end
    end
end
addEvent("showAdminBox", true)
addEventHandler("showAdminBox", root, addBox)
    
local between = 32
function drawnBoxes()
    notificationFont = exports['cr_fonts']:getFont("Poppins-Medium", 14);
    fontHeight = dxGetFontHeight(1, notificationFont)
    _sx, _sy = sx, sy
    local enabled, sx, nowY, w,h,sizable,turnable, sizeDetails, t, columns = exports['cr_interface']:getDetails("kick/ban")
    _nowY = nowY
    local now = getTickCount()
    for k,v in ipairs(cache) do
        local msg = v["msg"]
        local length = v["length"]
        local startTime = v["now"]
        local endTime = v["end"]
        local state = v["state"]
        local type = v["type"]
        local lines = v["lines"]
        local tick = v["tick"]
        local showtime = v["showtime"] or 8000
        local boxSize = 25 
        local pos, alpha -- = v["pos"], v["alpha"]
        
        local r,g,b = unpack(types[type][2])
        local icon = types[type][1]
        local timeLine = false
        local timeLineProg
        
        if state == "fadeIn" then
            local elapsedTime = now - startTime
            local duration = endTime - startTime
            local progress = elapsedTime / duration
            
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
                        removeEventHandler("onClientRender", root, drawnBoxes)
                    end
                end
            end
        end
        
        local boxWidth = length + 70
        local h = (lines * fontHeight) + 10
        dxDrawRectangle(pos[1], pos[2], boxWidth, h, tocolor(51, 51, 51, alpha[1]),true)

        dxDrawText(msg, pos[1] + 55, pos[2], pos[1] + 55, pos[2] + h + 4, tocolor(200, 200, 200, alpha[2]), 1, notificationFont, 'left', 'center',false,false,true,true,false)
        dxDrawImage(pos[1] + 15, pos[2] + h/2 - 30/2, 30, 30, tex[details[type][2]], 0,0,0, tocolor(r, g, b, alpha[2]),true)
        
        if timeLine then
            timeLineSize = interpolateBetween(h, 0,0, 0, 0,0, timeLineProg or 1, 'OutQuad')
        else
            timeLineSize = h
        end
        
        dxDrawRectangle(pos[1], pos[2], 5, timeLineSize, tocolor(r, g, b, alpha[2]),true)
        
        nowY = nowY + h + 5
    end
end            