local screenX, screenY = guiGetScreenSize()
local sx, sy = guiGetScreenSize()
local boxWidth_def, boxHeight_def = 804, 383
local boxWidth, boxHeight = 402, 383

local isActive = false
local activeInfo = false

local mapTextureSize = 3072
local mapRatio = 6000 / mapTextureSize

local mapZoom = 1

local alpha = 0
local alpha2 = 0

local texture = DxTexture(":cr_radar/assets/images/map.png")

local anim = false
local anim2 = false
local alphaStart = false
local animTick = getTickCount()

local start = false 
local startTick = getTickCount()

local startAnimationTime = 250
local startAnimation = "InOutQuad"

local animHeight = 280
local locationX, locationY, locationZ = 0, 0, 0
local forcedByBackspace = false

local playerDetails = {
	["mapZoom"] = 0,
	["realmapZoom"] = 0,
}

function updatePlayerDetails()
    if not localPlayer:getData("loggedIn") then return end
    
	if playerDetails["mapZoom"] ~= mapZoom then
        playerDetails["mapZoom"] = mapZoom
        playerDetails["mapZoomAnimation"] = true
        playerDetails["mapZoomAnimationTick"] = getTickCount()
	end
end
setTimer(updatePlayerDetails, 150, 0)

function renderJobPanel()
    if not isActive then 
        return 
    end

    local nowTick = getTickCount()

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

        if forcedByBackspace then 
            alpha2 = alph
        end

        if progress >= 1 then 
            destroyRender("renderJobPanel")
            removeEventHandler("onClientKey", root, onKey)

            isActive = false
            faded = false
            forcedByBackspace = false
            pressed = false
            anim = false 
            activeInfo = false
            alphaStart = false
            textAnim = false
            oldX, oldY, oldZ = 0, 0, 0
            animHeight = 280
            alpha2 = 0
            breaked = false
            return 
        end
    end

    if anim then 
        local elapsedTime = nowTick - animTick
        local duration = (animTick + 1000) - animTick
        local progress = elapsedTime / duration

        animHeight = interpolateBetween(280, 0, 0, 620, 0, 0, progress, startAnimation)

        if progress >= 1 then 
            if not breaked then 
                anim2 = true 
                alphaTick = getTickCount()
                breaked = true
            end
        end

        if anim2 then 
            local _elapsedTime = nowTick - alphaTick
            local _duration = (alphaTick + 500) - alphaTick
            local _progress = _elapsedTime / _duration
            local _alph = interpolateBetween(
                0, 0, 0,
                255, 0, 0,
                _progress, startAnimation
            )

            alpha2 = _alph

            if progress >= 1 then 
                alphaStart = true
            end
        else 
            if alphaStart then 
                local _elapsedTime = nowTick - alphaTick
                local _duration = (alphaTick + 500) - alphaTick
                local _progress = _elapsedTime / _duration
                local _alph = interpolateBetween(
                    255, 0, 0,
                    0, 0, 0,
                    _progress, startAnimation
                )

                alpha2 = _alph

                if _progress >= 1 then 
                    anim = false 
                    anim2 = false
                    forced = true
                    animTick = getTickCount()
                end
            end
        end
    else 
        if forced then 
            local elapsedTime = nowTick - animTick
            local duration = (animTick + 1000) - animTick
            local progress = elapsedTime / duration

            animHeight = interpolateBetween(620, 0, 0, 280, 0, 0, progress, startAnimation)

            if progress >= 1 then 
                anim = false
                alphaStart = false
                textAnim = false
                forced = false
                breaked = false
                activeInfo = false
            end
        end
    end

    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    local font2 = exports['cr_fonts']:getFont('Poppins-SemiBold', 12)
    local font3 = exports['cr_fonts']:getFont('Poppins-Medium', 14)
    local font4 = exports['cr_fonts']:getFont('Poppins-Medium', 12)
    hover = nil 
    hoverJob = nil
    hoverInfo = nil

    local w, h = 500, animHeight --280 
    local x,y = sx/2 - w/2, sy/2 - h/2
    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))

    canScroll = false
    if isInSlot(x, y, w, 280) then 
        canScroll = true 
    end

    dxDrawImage(x + 10, y + 10, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("Munkaközvetítő", x + 10 + 26 + 5, y + 10, x + 10 + 26 + 5, y + 10 + 30 + 2, tocolor(242, 242, 242, alpha), 1, font, "left", "center")

    if exports['cr_core']:isInSlot(x + w - 15 - 10, y + 10, 15, 15) then 
        hover = "close"

        dxDrawImage(x + w - 15 - 10, y + 10, 15, 15, "files/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha)) 
    else 
        dxDrawImage(x + w - 15 - 10, y + 10, 15, 15, "files/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.7)) 
    end 

    local startX, startY = x + 25, y + 50
    local _startY = startY

    for key = scrollMinLines, scrollMaxLines do 
        local value = jobsList[key]
        if value then 
            local data = value[1] 
            if data then 
                local w2, h2 = 221, 66

                if jobSelected == data["id"] then 
                    dxDrawRectangle(startX, startY, w2, h2, tocolor(51, 51, 51, alpha * 0.8))
                    dxDrawText(data["name"], startX + 10 + 32 + 15, startY + 7, startX + 10 + 32 + 15, startY + h2, tocolor(242, 242, 242, alpha), 1, font, "left", "top")

                    if isInSlot(startX, startY, w2, h2) then 
                        hover = "SelectingJob:"..data["id"]
                    end 
                    
                    if data["id"] == playerJob then 
                        if exports['cr_core']:isInSlot(startX + 60, startY + 31, 100, 19) then 
                            hoverJob = data["id"]

                            dxDrawRectangle(startX + 60, startY + 31, 100, 19, tocolor(255, 59, 59, alpha))
                            dxDrawText("Felmondás", startX + 60, startY + 31 + 4, startX + 60 + 100, startY + 31 + 19, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
                        else 
                            dxDrawRectangle(startX + 60, startY + 31, 100, 19, tocolor(255, 59, 59, alpha * 0.7))
                            dxDrawText("Felmondás", startX + 60, startY + 31 + 4, startX + 60 + 100, startY + 31 + 19, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
                        end 
                    else 
                        if exports['cr_core']:isInSlot(startX + 60, startY + 31, 100, 19) then 
                            hoverJob = data["id"]

                            dxDrawRectangle(startX + 60, startY + 31, 100, 19, tocolor(97, 177, 90, alpha))
                            dxDrawText("Elvállal", startX + 60, startY + 31 + 4, startX + 60 + 100, startY + 31 + 19, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
                        else 
                            dxDrawRectangle(startX + 60, startY + 31, 100, 19, tocolor(97, 177, 90, alpha * 0.7))
                            dxDrawText("Elvállal", startX + 60, startY + 31 + 4, startX + 60 + 100, startY + 31 + 19, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
                        end 
                    end 

                    dxDrawImage(startX + 10, startY + h2/2 - 32/2, 32, 32, (File.exists("files/images/jobs/"..data["id"]..".png") and "files/images/jobs/"..data["id"]..".png" or "files/images/jobs/1.png"), 0, 0, 0, tocolor(255, 255, 255, alpha))

                    if exports['cr_core']:isInSlot(startX + 180, startY + h2/2 - 25/2, 25, 25) then 
                        hover = nil
                        hoverInfo = data["id"]

                        dxDrawImage(startX + 180, startY + h2/2 - 25/2, 25, 25, "files/images/info.png", 0, 0, 0, tocolor(47, 128, 237, alpha))
                    else 
                        dxDrawImage(startX + 180, startY + h2/2 - 25/2, 25, 25, "files/images/info.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
                    end 
                else 
                    if isInSlot(startX, startY, w2, h2) then 
                        hover = "SelectingJob:"..data["id"]

                        dxDrawRectangle(startX, startY, w2, h2, tocolor(51, 51, 51, alpha * 0.8))
                        dxDrawText(data["name"], startX + 10 + 32 + 15, startY + 7, startX + 10 + 32 + 15, startY + h2, tocolor(242, 242, 242, alpha * 0.6), 1, font, "left", "top")
                    else 
                        dxDrawRectangle(startX, startY, w2, h2, tocolor(51, 51, 51, alpha * 0.6))
                        dxDrawText(data["name"], startX + 10 + 32 + 15, startY + 7, startX + 10 + 32 + 15, startY + h2, tocolor(242, 242, 242, alpha * 0.6), 1, font, "left", "top")
                    end 

                    dxDrawImage(startX + 10 + 32 + 15, startY + 30, 10, 10, "files/images/cash.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
                    dxDrawText("$"..formatMoney(data["payment"] * exports['cr_salary']:getMultiplier()), startX + 10 + 32 + 15 + 10 + 5, startY + 25, startX + 10 + 32 + 15 + 10 + 5, startY + 30, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "left", "top")
                    dxDrawImage(startX + 11 + 32 + 15, startY + 30 + 10 + 2, 8, 10, "files/images/location.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
                    dxDrawText(data["location"]["name"], startX + 10 + 32 + 15 + 10 + 5, startY + 25 + 10 + 2, startX + 10 + 32 + 15 + 10 + 5, startY + 50, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "left", "top")

                    dxDrawImage(startX + 10, startY + h2/2 - 32/2, 32, 32, (File.exists("files/images/jobs/"..data["id"]..".png") and "files/images/jobs/"..data["id"]..".png" or "files/images/jobs/1.png"), 0, 0, 0, tocolor(255, 255, 255, alpha))
                end 
            end 

            local data = value[2] 
            if data then
                local w2, h2 = 221, 66

                local startX = startX + w2 + 10

                if jobSelected == data["id"] then 
                    dxDrawRectangle(startX, startY, w2, h2, tocolor(51, 51, 51, alpha * 0.8))
                    dxDrawText(data["name"], startX + 10 + 32 + 15, startY + 7, startX + 10 + 32 + 15, startY + h2, tocolor(242, 242, 242, alpha), 1, font, "left", "top")

                    if isInSlot(startX, startY, w2, h2) then 
                        hover = "SelectingJob:"..data["id"]
                    end 
                    
                    if data["id"] == playerJob then 
                        if exports['cr_core']:isInSlot(startX + 60, startY + 31, 100, 19) then 
                            hoverJob = data["id"]

                            dxDrawRectangle(startX + 60, startY + 31, 100, 19, tocolor(255, 59, 59, alpha))
                            dxDrawText("Felmondás", startX + 60, startY + 31 + 4, startX + 60 + 100, startY + 31 + 19, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
                        else 
                            dxDrawRectangle(startX + 60, startY + 31, 100, 19, tocolor(255, 59, 59, alpha * 0.7))
                            dxDrawText("Felmondás", startX + 60, startY + 31 + 4, startX + 60 + 100, startY + 31 + 19, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
                        end 
                    else 
                        if exports['cr_core']:isInSlot(startX + 60, startY + 31, 100, 19) then 
                            hoverJob = data["id"]

                            dxDrawRectangle(startX + 60, startY + 31, 100, 19, tocolor(97, 177, 90, alpha))
                            dxDrawText("Elvállal", startX + 60, startY + 31 + 4, startX + 60 + 100, startY + 31 + 19, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
                        else 
                            dxDrawRectangle(startX + 60, startY + 31, 100, 19, tocolor(97, 177, 90, alpha * 0.7))
                            dxDrawText("Elvállal", startX + 60, startY + 31 + 4, startX + 60 + 100, startY + 31 + 19, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
                        end 
                    end 

                    dxDrawImage(startX + 10, startY + h2/2 - 32/2, 32, 32, (File.exists("files/images/jobs/"..data["id"]..".png") and "files/images/jobs/"..data["id"]..".png" or "files/images/jobs/1.png"), 0, 0, 0, tocolor(255, 255, 255, alpha))

                    if exports['cr_core']:isInSlot(startX + 180, startY + h2/2 - 25/2, 25, 25) then 
                        hover = nil
                        hoverInfo = data["id"]

                        dxDrawImage(startX + 180, startY + h2/2 - 25/2, 25, 25, "files/images/info.png", 0, 0, 0, tocolor(47, 128, 237, alpha))
                    else 
                        dxDrawImage(startX + 180, startY + h2/2 - 25/2, 25, 25, "files/images/info.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
                    end 
                else 
                    if isInSlot(startX, startY, w2, h2) then 
                        hover = "SelectingJob:"..data["id"]

                        dxDrawRectangle(startX, startY, w2, h2, tocolor(51, 51, 51, alpha * 0.8))
                        dxDrawText(data["name"], startX + 10 + 32 + 15, startY + 7, startX + 10 + 32 + 15, startY + h2, tocolor(242, 242, 242, alpha * 0.6), 1, font, "left", "top")
                    else 
                        dxDrawRectangle(startX, startY, w2, h2, tocolor(51, 51, 51, alpha * 0.6))
                        dxDrawText(data["name"], startX + 10 + 32 + 15, startY + 7, startX + 10 + 32 + 15, startY + h2, tocolor(242, 242, 242, alpha * 0.6), 1, font, "left", "top")
                    end 

                    dxDrawImage(startX + 10 + 32 + 15, startY + 30, 10, 10, "files/images/cash.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
                    dxDrawText("$"..formatMoney(data["payment"] * exports['cr_salary']:getMultiplier()), startX + 10 + 32 + 15 + 10 + 5, startY + 25, startX + 10 + 32 + 15 + 10 + 5, startY + 30, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "left", "top")
                    dxDrawImage(startX + 11 + 32 + 15, startY + 30 + 10 + 2, 8, 10, "files/images/location.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
                    dxDrawText(data["location"]["name"], startX + 10 + 32 + 15 + 10 + 5, startY + 25 + 10 + 2, startX + 10 + 32 + 15 + 10 + 5, startY + 50, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "left", "top")

                    dxDrawImage(startX + 10, startY + h2/2 - 32/2, 32, 32, (File.exists("files/images/jobs/"..data["id"]..".png") and "files/images/jobs/"..data["id"]..".png" or "files/images/jobs/1.png"), 0, 0, 0, tocolor(255, 255, 255, alpha))
                end 

                startY = startY + h2 + 5
            end 
        end 
    end 

    -- Scrollbar

    dxDrawRectangle(x + w - 3, _startY, 3, 205, tocolor(242, 242, 242, alpha * 0.6))

    local percent = #jobsList

    if percent >= 1 then
        local gW, gH = 3, 205
        local gX, gY = x + w - 3, _startY
        
        scrollingHover = isInSlot(gX, gY, gW, gH)

        if scrolling then
            if isCursorShowing() then
                if getKeyState("mouse1") then
                    local cx, cy = exports["cr_core"]:getCursorPosition()
                    local cy = math.min(math.max(cy, gY), gY + gH)
                    local y = (cy - gY) / (gH)
                    local num = percent * y
                    scrollMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 3) + 1)))
                    scrollMaxLines = scrollMinLines + (3 - 1)
                end
            else
                scrolling = false
            end
        end

        local multiplier = math.min(math.max((scrollMaxLines - (scrollMinLines - 1)) / percent, 0), 1)
        local multiplier2 = math.min(math.max((scrollMinLines - 1) / percent, 0), 1)
        local gY = gY + ((gH) * multiplier2)
        local gH = gH * multiplier

        local r, g, b = 51, 51, 51
        dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
    end

    if activeInfo then 
        dxDrawImage(startX, startY, 12, 15, "files/images/location-high.png", 0, 0, 0, tocolor(255, 255, 255, alpha2))

        dxDrawText("Helyszín", startX + 12 + 10, startY + 2, startX + 12 + 10, startY + 2 + 15, tocolor(242, 242, 242, alpha2), 1, font3, "left", "center")

        dxDrawRectangle(startX, startY + 15 + 8, 453, 188, tocolor(51, 51, 51, alpha2 * 0.8))

        local nowY = startY + 15 + 8 + 188 + 6
        dxDrawImage(startX, nowY, 15, 15, "files/images/info.png", 0, 0, 0, tocolor(47, 128, 237, alpha2))
        dxDrawText("Információk", startX + 15 + 10, nowY + 2, startX + 15 + 10, nowY + 2 + 15, tocolor(242, 242, 242, alpha2), 1, font3, "left", "center")

        dxDrawRectangle(startX, nowY + 15 + 5, 453, 94, tocolor(51, 51, 51, alpha2 * 0.8))
        dxDrawText(jobs[activeInfo]["description"], startX + 5, nowY + 15 + 5 + 5, startX + 453 - 5, nowY + 15 + 5 + 94 - 5, tocolor(242, 242, 242, alpha2), 1, font4, "left", "center", false, true)

        if exports['cr_core']:isInSlot(x + w - 15 - 10, y + h - 9 - 10, 15, 9) then 
            hover = "close-anim"

            dxDrawImage(x + w - 15 - 10, y + h - 9 - 10, 15, 9, "files/images/close-anim.png", 0, 0, 0, tocolor(255, 255, 255, alpha2))
        else 
            dxDrawImage(x + w - 15 - 10, y + h - 9 - 10, 15, 9, "files/images/close-anim.png", 0, 0, 0, tocolor(255, 255, 255, alpha2 * 0.6))
        end 

        if activeInfo then 
            if locationAnim then 
                local elapsedTime = nowTick - locationTick
                local duration = (locationTick + 1000) - locationTick
                local progress = elapsedTime / duration
    
                if progress >= 1 then 
                    locationAnim = false
                end
    
                locationX, locationY, locationZ = interpolateBetween(oldX, oldY, oldZ, jobs[activeInfo]["location"]["position"][1], jobs[activeInfo]["location"]["position"][2], jobs[activeInfo]["location"]["position"][3], progress, startAnimation)
            end
        end
    
        local key = "mapZoom"
        if playerDetails[key.."Animation"] then
            local startTick = playerDetails[key.."AnimationTick"]
            local endTick = startTick + 250
            
            local elapsedTime = nowTick - startTick
            local duration = 250
            local progress = elapsedTime / duration
            local alph = interpolateBetween(
                playerDetails["real"..key], 0, 0,
                playerDetails[key], 0, 0,
                progress, "InOutQuad"
            )
            playerDetails["real"..key] = alph
            
            if progress >= 1 then
                playerDetails[key.."Animation"] = false
            end
        end
    
        local mapX, mapY, mapWidth, mapHeight = startX + 4, startY + 15 + 8 + 4, 453 - 8, 188 - 8
        local mapZoom = playerDetails["real"..key]
        mapHover = false 
        if isInSlot(mapX, mapY, mapWidth, mapHeight) and alpha2 > 0 then 
            mapHover = true 
        end

        dxDrawImageSection(mapX, mapY, mapWidth, mapHeight, remapTheSecondWay(locationX) - mapWidth / mapZoom / 2, remapTheFirstWay(locationY) - mapHeight / mapZoom / 2, mapWidth / mapZoom, mapHeight / mapZoom, texture, 0, 0, 0, tocolor(255, 255, 255, alpha2))
    end 

    if clickedPed then 
        if getDistanceBetweenPoints3D(localPlayer.position, clickedPed.position) >= 3 then 
            if not faded then 
                faded = true 
                start = false 
                startTick = getTickCount()
            end
        end
    end
end

local spamTick = 0
function onKey(button, state)
    if not isActive then 
        return 
    end

    if getNetworkStatus() then 
        return 
    end

    if button == "mouse1" then 
        if state then 
            if scrollingHover then 
                scrolling = true 
                scrollingHover = false
            end

            if hoverJob then 
                if spamTick + 250 > getTickCount() then 
                    return 
                end

                
                if playerJob ~= 0 and hoverJob ~= playerJob then 
                    return addBox("error", "Neked már van munkád, új munka vállalásához mond fel az előző munkád!")
                end

                if playerJob == hoverJob then 
                    addBox("success", "Sikeresen felmondtál a "..jobs[playerJob]["name"].." munkából!")
                    localPlayer:setData("char >> job", 0)
                    playerJob = 0
                else 
                    addBox("success", "Sikeresen felvetted a "..jobs[hoverJob]["name"].." munkát!")
                    localPlayer:setData("char >> job", hoverJob)
                    playerJob = hoverJob
                end

                hoverJob = false
                spamTick = getTickCount()

                return
            end

            if hover then 
                if hover:sub(1, 13):lower() == ("SelectingJob:"):lower() then 
                    local id = tonumber(hover:sub(14, #hover))

                    if jobSelected == id then 
                        jobSelected = 0
                    else 
                        jobSelected = id 
                    end
                elseif hover == "close" then 
                    if state then 
                        if isActive then 
                            if not pressed then 
                                pressed = true
                                start = false 
            
                                if anim2 and alphaStart then 
                                    forcedByBackspace = true
                                    anim2 = false 
                                    alphaStart = false 
                                end
            
                                startTick = getTickCount()
                            end
                        end
                    end
                elseif hover == "close-anim" then 
                    if alphaStart then 
                        if anim2 then 
                            if locationAnim then 
                                return 
                            end

                            anim2 = false 
                            alphaStart = true
                            alphaTick = getTickCount()
                        end
                    end
                end 

                hover = nil 

                return
            end 

            if hoverInfo then 
                if activeInfo ~= hoverInfo then 
                    if not oldX or not oldY or not oldZ or not activeInfo then 
                        oldX, oldY, oldZ = 0, 0, 0
                    else 
                        if locationAnim then 
                            return 
                        end

                        oldX, oldY, oldZ = jobs[activeInfo]["location"]["position"][1], jobs[activeInfo]["location"]["position"][2], jobs[activeInfo]["location"]["position"][3]
                    end
                    
                    activeInfo = hoverInfo

                    if not anim then 
                        anim = true 
                        textAnim = true
                        animTick = getTickCount()
                    end

                    if not locationAnim then 
                        locationAnim = true 
                        locationTick = getTickCount()
                    end
                else 
                    if alphaStart then 
                        if anim2 then 
                            if locationAnim then 
                                return 
                            end

                            anim2 = false 
                            alphaStart = true
                            alphaTick = getTickCount()
                        end
                    end
                end

                hoverInfo = false 

                return
            end
        else 
            if scrolling then 
                scrolling = false
            end
        end
    elseif button == "mouse_wheel_down" then 
        if state then 
            if canScroll and not mapHover then 
                scrollDown()
            end

            -- if mapHover then 
            --     if mapZoom - 0.1 >= 0.5 then 
            --         mapZoom = mapZoom - 0.1
            --     end
            -- end
        end
    elseif button == "mouse_wheel_up" then 
        if state then 
            if canScroll and not mapHover then 
                scrollUp()
            end

            -- if mapHover then 
            --     if mapZoom + 0.1 <= 1 then 
            --         mapZoom = mapZoom + 0.1
            --     end
            -- end
        end
    elseif button == "backspace" then 
        if state then 
            if isActive then 
                if not pressed then 
                    pressed = true
                    start = false 

                    if anim2 and alphaStart then 
                        forcedByBackspace = true
                        anim2 = false 
                        alphaStart = false 
                    end

                    startTick = getTickCount()
                end
            end
        end
    end
end

function onPedClick(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
    if button == "left" then 
        if state == "down" then 
            if isElement(clickedElement) then 
                if clickedElement.type ~= "ped" then 
                    return 
                end

                if not clickedElement:getData("job >> ped") then 
                    return 
                end

                if not localPlayer:getData("hudVisible") then 
                    return 
                end

                if getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position) <= 3 then 
                    if not isActive then 
                        isActive = true
                        start = true 
                        startTick = getTickCount()
                        playerJob = localPlayer:getData("char >> job")
                        clickedPed = clickedElement
                        jobSelected = 0

                        if not texture then 
                            texture = DxTexture(":cr_radar/assets/images/map.png")
                        end

                        createRender("renderJobPanel", renderJobPanel)
                        removeEventHandler("onClientKey", root, onKey)
                        addEventHandler("onClientKey", root, onKey)
                    end
                end
            end
        end
    end
end
addEventHandler("onClientClick", root, onPedClick)

function scrollDown()
    if scrollMaxLines + 1 <= #jobsList then
        scrollMinLines = scrollMinLines + 1
        scrollMaxLines = scrollMaxLines + 1
    end
end

function scrollUp()
    if scrollMinLines - 1 >= 1 then
        scrollMinLines = scrollMinLines - 1
        scrollMaxLines = scrollMaxLines - 1
    end
end

function getFont(font, size)
    return exports["cr_fonts"]:getFont(font, size)
end

function isInSlot(x, y, w, h)
    return exports["cr_core"]:isInSlot(x, y, w, h)
end

function getServerColor(color, hex)
    return exports["cr_core"]:getServerColor(color, hex)
end

function addBox(type, ...)
    return exports["cr_infobox"]:addBox(type, ...)
end

function formatMoney(value)
    return exports["cr_dx"]:formatMoney(value)
end

function remapTheFirstWay(coord)
	return (-coord + 3000) / mapRatio
end

function remapTheSecondWay(coord)
	return (coord + 3000) / mapRatio
end

function getNetworkStatus()
    return exports["cr_network"]:getNetworkStatus()
end

function dxDrawImageWithText(imagePath, text, x, y, w, h, imageColor, textColor, imageW, imageH, textScale, textFont, between)
    return exports["cr_dx"]:dxDrawImageWithText(imagePath, text, x, y, w, h, imageColor, textColor, imageW, imageH, textScale, textFont, between)
end