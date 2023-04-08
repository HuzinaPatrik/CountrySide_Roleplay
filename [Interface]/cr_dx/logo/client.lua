renderTimers = {}

function createRender(id, func)
    if not isTimer(renderTimers[id]) then
        renderTimers[id] = setTimer(func, 5, 0)
    end
end

function destroyRender(id)
    if isTimer(renderTimers[id]) then
        killTimer(renderTimers[id])
        renderTimers[id] = nil
        collectgarbage("collect")
    end
end

local animations = {}
local timers = {}
local animRender = false
local r, g, b = 70,137,197
local showtime = 20000
local dr, dg, db = 255,255,255

function createLogoAnimation(name, type, pos, animtime)
    if type == 1 then
        if not animations[name] then
            --outputChatBox("Created: "..name)
            local details = {}
            details["x"] = pos[1]
            details["y"] = pos[2]
            details["w"] = pos[3]
            details["h"] = pos[4]
            details["type"] = type
            details["alpha"] = 0
            details["state"] = 1
            details["index"] = 0
            details["state"] = "start"
            details["r"] = 255
            details["g"] = 255
            details["b"] = 255
            if isTimer(timer) then
                killTimer(timer)
            end
            if not animtime then
                animtime = {20000, 2000}
            end
            local showtime = animtime[1]
            details["animtime"] = animtime
            details["startTime"] = getTickCount()
            details["endTime"] = details["startTime"] + animtime[2]
            animations[name] = details
            if not animRender then
                animRender = true
                --addEventHandler("onClientRender", root, drawnAnim, true, "low-5")
                createRender("drawnAnim", drawnAnim)
            end
        end
    end
end

function updateLogoPos(name, a)
    if animations[name] then
        if animRender then
            
            local details = animations[name]
            
            details["x"] = a[1]
            details["y"] = a[2]
            details["w"] = a[3]
            details["h"] = a[4]
            
            animations[name] = details
        end
    end
end

function getLogoPosition(name)
    if animations[name] then   
        local details = animations[name]
        return details["x"], details["y"]
    end
end

function stopLogoAnimation(name)
    if animations[name] then
        --outputChatBox("Deleted: "..name)
        animations[name] = nil
        collectgarbage("collect")

        local x = 0
        for k,v in pairs(animations) do
            x = x + 1
            break
        end
        
        if x == 0 then
            if animRender then
                animRender = false
               -- removeEventHandler("onClientRender", root, drawnAnim)
                destroyRender("drawnAnim")
            end
        end
    end
end

local multipler = 1
startAnimation = "InOutQuad"
startAnimationTime = 1000 -- / 1000 = 0.2 másodperc
function drawnAnim()
    for k, details in pairs(animations) do

        ----outputChatBox("ASD2")
        if details["type"] == 1 then
            ----outputChatBox("ASD")
            local now = getTickCount()
            local elapsedTime = now - details["startTime"]
            local duration = details["endTime"] - details["startTime"]
            local progress = elapsedTime / duration
            local red, green, blue  = details["r"], details["g"], details["b"]
            
            --local rotation = interpolateBetween(0, 0, 0, 360, 0, 0, now / 5000, "SineCurve")

            local nowTick = now
            if details["state"] == "start" then
                local alph = interpolateBetween(
                    0, 0, 0,
                    255, 0, 0,
                    progress, startAnimation
                )
                
                --outputChatBox("Start: "..progress.. "-"..alph)
                details["alpha"] = alph

                if progress >= 1 then
                    --[[
                    details["state"] = "color"
                    details["startTime"] = now
                    details["endTime"] = now + details["animtime"][2] ]]

                    details["state"] = "color-show"
                    details["startTime"] = now
                    details["endTime"] = now + details["animtime"][1]
                end
            elseif details["state"] == "end" then
                local alph = interpolateBetween(
                    255, 0, 0,
                    0, 0, 0,
                    progress, startAnimation
                )

                --outputChatBox("End: "..progress.. "-"..alph)
                details["alpha"] = alph

                if progress >= 1 then
                    details["state"] = "end-show"
                    details["startTime"] = now
                    details["endTime"] = now + details["animtime"][1]
                end -- utána showtime ig
            elseif details["state"] == "end-show" then
                --red, green, blue = r, g, b
                
                --outputChatBox("Color-show: "..progress)
                if progress >= 1 then
                    details["state"] = "start"
                    details["startTime"] = now
                    details["endTime"] = now + details["animtime"][2]
                end
            --[[
            elseif details["state"] == "color" then
                red, green, blue = interpolateBetween( 
                    dr, dg, db,
                    r, g, b, 
                progress, "OutBounce")
                
                --outputChatBox("Color: "..progress)
                if progress >= 1 then
                    details["state"] = "color-show"
                    details["startTime"] = now
                    details["endTime"] = now + details["animtime"][1]
                end
            ]] 
            elseif details["state"] == "color-show" then
                --red, green, blue = r, g, b
                
                if progress >= 1 then
                    --[[
                    details["state"] = "color-back"
                    details["startTime"] = now
                    details["endTime"] = now + details["animtime"][2] ]]

                    details["state"] = "end"
                    details["startTime"] = now
                    details["endTime"] = now + details["animtime"][2]
                end
            --[[
            elseif details["state"] == "color-back" then
                red, green, blue = interpolateBetween( 
                    r, g, b,
                    dr, dg, db, 
                progress, "OutBounce")
                
                if progress >= 1 then
                    details["state"] = "end"
                    details["startTime"] = now
                    details["endTime"] = now + details["animtime"][2]
                end]]
            end -- ha eléri a dg-t

            if not red then red = dr end
            if not green then green = dg end
            if not blue then blue = db end

            local w,h = details["w"], details["h"]
            dxDrawImage(details["x"] - w/2, details["y"] - h/2, w, h, ":cr_account/files/logo.png", 0,0,0, tocolor(red,green,blue, details["alpha"]))
            --dxDrawImage(details["x"] - w/2, details["y"] - h/2, w, h, ":cr_account/files/logolines.png", -rotation,0,0, tocolor(red,green,blue, details["alpha"]))
            --dxDrawImage(details["x"] - w/2, details["y"] - h/2, w, h, ":cr_account/files/logolines2.png", rotation,0,0, tocolor(red,green,blue, details["alpha"]))
        end
    end
end