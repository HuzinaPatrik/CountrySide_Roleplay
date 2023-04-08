addEvent("[Minigame - StartMinigame]", true)
addEvent("[Minigame - StopMinigame]", true)

local minigame2Cache = {}
local minigame3Cache = {}
local guitarHeroCache = {}

local sx, sy = guiGetScreenSize()

function createMinigame(e, id, detailName, extra)
    if e == localPlayer then
        startMinigame(id, detailName, extra)
        triggerEvent("[Minigame - StartMinigame]", e, e, id, detailName, extra)
        outputDebugString("[Minigame] Started, ID:"..id, 0, 87,255,255)
    end
end

function startMinigame(id, detailName, extra)
    if id == 1 then -- Újraélesztési cucckombó
        if not minigameStatus then
            minigameStatus = true 

            local max = 15
            local needed = max/2
            
            startTime = getTickCount()
            endTime = startTime + math.random(375, 1250)

            if extra then
                max = extra["max"]
                needed = extra["needed"]
            end

            nowMinigame = detailName
            local syntax = exports['cr_core']:getServerSyntax("Minigame", "warning")
            outputChatBox(syntax .. "A minigame megkezdődött! Interakciójához használd a Bal Alt -ot (lalt)!", 255,255,255,true)
            resetMinigame(id, max, needed, multipler)
            setElementData(localPlayer, "inMinigame", true)

            oDatas = {
                ['keysDenied'] = localPlayer:getData('keysDenied'),
            }
            localPlayer:setData('keysDenied', true)
            bindKey("lalt", "down", doMinigame1)

            exports['cr_dx']:startFade("minigame1", 
                {
                    ["startTick"] = getTickCount(),
                    ["lastUpdateTick"] = getTickCount(),
                    ["time"] = 250,
                    ["animation"] = "InOutQuad",
                    ["from"] = 0,
                    ["to"] = 255,
                    ["alpha"] = 0,
                    ["progress"] = 0,
                }
            )

            createRender("drawnMinigame1", drawnMinigame1)
        end 
    elseif id == 2 then
        if not minigameStatus then 
            minigameStatus = true 

            local max = 30
            local needed = max/2
            local speed = 1250
            if extra then
                max = extra["max"]
                needed = extra["needed"]
                speed = extra["speed"]
            end
            nowMinigame = detailName
            buttonAnimation = {}

            local syntax = exports['cr_core']:getServerSyntax("Minigame", "warning")
            outputChatBox(syntax .. "A minigame megkezdődött! Ha az ikon elérte rendes helyét akkor használd a megfelelő nyilat !", 255,255,255,true)
            
            exports['cr_controls']:toggleAllControls(false, "instant")
            resetMinigame(id, max, needed)
            setElementData(localPlayer, "inMinigame", true)
            addAnimation()
            minigame2Timer = setTimer(
                function()
                    addAnimation()
                end, speed, max
            )
            
            exports['cr_dx']:startFade("minigame2", 
                {
                    ["startTick"] = getTickCount(),
                    ["lastUpdateTick"] = getTickCount(),
                    ["time"] = 250,
                    ["animation"] = "InOutQuad",
                    ["from"] = 0,
                    ["to"] = 255,
                    ["alpha"] = 0,
                    ["progress"] = 0,
                }
            )

            createRender("drawnMinigame2", drawnMinigame2)

            addEventHandler("onClientKey", root, doMinigame2)
        end 
    elseif id == 3 then
        local max = 30
        local needed = max/2
        local speed = 500
        local speedMulti = 6
        if extra then
            max = extra["max"]
            needed = extra["needed"]
            speed = extra["speed"]
            speedMulti = extra["speedMultipler"]
        end
        nowMinigame = detailName
        speedMultipler = speedMulti
        local syntax = exports['cr_core']:getServerSyntax("Minigame", "warning")
        outputChatBox(syntax .. "A minigame megkezdődött! Ha a betű elérte a kört akkor használd a Bal Alt -ot (lalt)!", 255,255,255,true)
        resetMinigame(id, max, needed)
        setElementData(localPlayer, "inMinigame", true)
        addAnimation2()
        minigame3Timer = setTimer(
            function()
                addAnimation2()
            end, speed, max
        )
        --addEventHandler("onClientRender", root, drawnMinigame3, true, "low-5")
        createRender("drawnMinigame3", drawnMinigame3)
        oDatas = {
            ['keysDenied'] = localPlayer:getData('keysDenied'),
        }
        localPlayer:setData('keysDenied', true)
        bindKey("lalt", "down", doMinigame3)    
    elseif id == 4 then 
        if not minigameStatus then 
            minigameStatus = true 

            local max = math.random(20, 100)
            if extra then 
                max = extra['max']
            end 

            nowMinigame = detailName

            exports['cr_controls']:toggleAllControls(false, "instant")
            resetMinigame(id, max)

            local syntax = exports['cr_core']:getServerSyntax("Minigame", "warning")
            outputChatBox(syntax .. "A minigame megkezdődött! Használd a Fel/Le nyílat a minigame végzéséhez!", 255,255,255,true)
            setElementData(localPlayer, "inMinigame", true)

            bindKey("arrow_u", "down", minigame4ArrowUP)    
            bindKey("arrow_d", "down", minigame4ArrowDown)    

            createRender("drawnMinigame4", drawnMinigame4)

            exports['cr_dx']:startFade("minigame4", 
                {
                    ["startTick"] = getTickCount(),
                    ["lastUpdateTick"] = getTickCount(),
                    ["time"] = 250,
                    ["animation"] = "InOutQuad",
                    ["from"] = 0,
                    ["to"] = 255,
                    ["alpha"] = 0,
                    ["progress"] = 0,
                }
            )
        end 
    end
end

function doMinigame1()
    if animY > 125 and animY < 225 then
        success = success + 1
        max = max - 1
        if max <= 0 then
            stopMinigame(1)
            return
        elseif success >= needed then
            stopMinigame(1)
            return
        end
    else
        failed = failed + 1
        max = max - 1
        if max <= 0 then
            stopMinigame(1)
            return
        end
    end

    if math.random(1, 2) == 1 then 
        animY = 0
        animState = "+"
    else 
        animY = 350
        animState = "-"
    end 

    startTime = getTickCount()
    endTime = startTime + math.random(375, 1250)
end

local isAllowed = {
    ["arrow_l"] = true,
    ["arrow_r"] = true,
    ["arrow_u"] = true,
    ["arrow_d"] = true,
}

local typeDatas = {
    {0, 0, 'arrow_u'}, -- 1
    {55, 90, 'arrow_r'}, -- 2
    {110, 180, 'arrow_d'}, -- 3
    {165, 270, 'arrow_l'}, -- 4
}

function doMinigame2(bt2, press)
    if isAllowed[bt2] and press then
        local now = getTickCount()

        local startY, h2 = getMinigame2RenderOffsets()

        for k,v in ipairs(minigame2Cache) do 
            local type, status, startTime, endTime = unpack(v)

            local x, rot, bt = unpack(typeDatas[type])

            local elapsedTime = now - startTime
            local duration = endTime - startTime
            local progress = elapsedTime / duration

            if progress <= 1 then 
                local y = interpolateBetween(-250, 0, 0, sy + 250, 0, 0, progress, 'Linear')

                if y < sy then 
                    if y > (startY - 15) and (y + h2) < (startY + h2 + 15) then 
                        if bt2:lower() == bt:lower() then 
                            minigame2Cache[k][2] = 'success'

                            buttonAnimation[type] = {true, 'success'}

                            exports['cr_dx']:startFade("minigame2 >> buttonAnimation >> " .. type, 
                                {
                                    ["startTick"] = getTickCount(),
                                    ["lastUpdateTick"] = getTickCount(),
                                    ["time"] = 250,
                                    ["animation"] = "InOutQuad",
                                    ["from"] = 0,
                                    ["to"] = 255,
                                    ["alpha"] = 0,
                                    ["progress"] = 0,
                                }
                            )

                            success = success + 1
                        else
                            minigame2Cache[k][2] = 'failed'

                            buttonAnimation[type] = {true, 'failed'}

                            exports['cr_dx']:startFade("minigame2 >> buttonAnimation >> " .. type, 
                                {
                                    ["startTick"] = getTickCount(),
                                    ["lastUpdateTick"] = getTickCount(),
                                    ["time"] = 250,
                                    ["animation"] = "InOutQuad",
                                    ["from"] = 0,
                                    ["to"] = 255,
                                    ["alpha"] = 0,
                                    ["progress"] = 0,
                                }
                            )

                            failed = failed + 1
                        end 
                    end 
                end 
            end 
        end

        --[[
        for k = 1, #minigame2Cache do --k,v in ipairs(minigame2Cache) do
            local v = minigame2Cache[k]
            local data, y, isFailed, try = unpack(v) 
            local type, rot, x, bt = unpack(data)
            --dxDrawRectangle(sx/2 + x, y, 50, 10) -- Teteje

            --dxDrawRectangle(sx/2 + x, y + 50, 50, 10) -- Teteje
            if y + 50 >= sy - 150 then
                if y - 10 <= sy - 100 then
                    --outputChatBox(bt2)
                    if bt2 == bt then
                        if isFailed and not try then
                            if not minigame2Cache[k][4] then
                                minigame2Cache[k][3] = false
                                minigame2Cache[k][4] = true
                                last = k + 1
                                return
                            end
                        end
                    else
                        if not minigame2Cache[k][4] then
                            minigame2Cache[k][3] = true
                            minigame2Cache[k][4] = true
                            last = k + 1
                            return
                        end
                    end
                else
                    if not minigame2Cache[k][4] then
                        minigame2Cache[k][3] = true
                        minigame2Cache[k][4] = true
                        last = k + 1
                        return
                    end
                end
            else
                if not minigame2Cache[k][4] then
                    minigame2Cache[k][3] = true
                    minigame2Cache[k][4] = true
                    last = k + 1
                    return
                end
            end
        end]]
    end
end

function doMinigame3()
    for k,v in pairs(minigame3Cache) do
        local string, x, isFailed, try = unpack(v) 
        if x > sx/2 - 60/2 then
            if x < sx + 60/2 then
                if isFailed and not try then
                    minigame3Cache[k][3] = false
                    minigame3Cache[k][4] = true
                end
            else
                minigame3Cache[k][3] = true
                minigame3Cache[k][4] = true
            end
            return
        end
    end
end

function stopMinigame(id, ignoreTrigger)
    if id == 1 then
        minigameStatus = false 

        outputDebugString("[Minigame] Stopped, ID:"..minigame..", Success:"..success..", Failed:"..failed..", Needed:"..needed, 0, 87,255,255)

        if not ignoreTrigger then 
            triggerEvent("[Minigame - StopMinigame]", localPlayer, localPlayer, {minigame, nowMinigame, success, failed, needed})
        end 
        
        unbindKey("lalt", "down", doMinigame1)
        
        exports['cr_dx']:startFade("minigame1", 
            {
                ["startTick"] = getTickCount(),
                ["lastUpdateTick"] = getTickCount(),
                ["time"] = 250,
                ["animation"] = "InOutQuad",
                ["from"] = 255,
                ["to"] = 0,
                ["alpha"] = 255,
                ["progress"] = 0,
            }
        )
        
        localPlayer:setData('keysDenied', oDatas['keysDenied'])

        localPlayer:setData('inMinigame', false)
    elseif id == 2 then
        minigameStatus = false 

        outputDebugString("[Minigame] Stopped, ID:"..minigame..", Success:"..success..", Failed:"..failed..", Needed:"..needed, 0, 87,255,255)

        if not ignoreTrigger then 
            triggerEvent("[Minigame - StopMinigame]", localPlayer, localPlayer, {minigame, nowMinigame, success, failed, needed})
        end 

        exports['cr_controls']:toggleAllControls(true, "instant")
        if success >= needed then
            --outputChatBox(nowMinigame)
            if string.lower(nowMinigame) == string.lower("death > respawn") then
                --outputChatBox("TRIGGER>TRUE")
                triggerEvent("SuccessMinigame", localPlayer, localPlayer)
            end
        else
            --outputChatBox(nowMinigame)
            if string.lower(nowMinigame) == string.lower("death > respawn") then
                --outputChatBox("TRIGGER>FALSE")
                triggerEvent("FailedMinigame", localPlayer, localPlayer)
            end
        end
        
        removeEventHandler("onClientKey", root, doMinigame2)
        
        exports['cr_dx']:startFade("minigame2", 
            {
                ["startTick"] = getTickCount(),
                ["lastUpdateTick"] = getTickCount(),
                ["time"] = 250,
                ["animation"] = "InOutQuad",
                ["from"] = 255,
                ["to"] = 0,
                ["alpha"] = 255,
                ["progress"] = 0,
            }
        )

        localPlayer:setData('inMinigame', false)
    elseif id == 3 then
        outputDebugString("[Minigame] Stopped, ID:"..minigame..", Success:"..success..", Failed:"..failed..", Needed:"..needed, 0, 87,255,255)

        if not ignoreTrigger then 
            triggerEvent("[Minigame - StopMinigame]", localPlayer, localPlayer, {minigame, nowMinigame, success, failed, needed})
        end 

        unbindKey("lalt", "down", doMinigame3)
        --removeEventHandler("onClientRender", root, drawnMinigame3)    
        destroyRender("drawnMinigame3")

        localPlayer:setData('keysDenied', oDatas['keysDenied'])

        localPlayer:setData('inMinigame', false)
    elseif id == 4 then 
        minigameStatus = false 

        outputDebugString("[Minigame] Stopped, ID:"..minigame..", Success:"..success..", Failed:"..failed..", Needed:"..needed, 0, 87,255,255)

        if not ignoreTrigger then 
            triggerEvent("[Minigame - StopMinigame]", localPlayer, localPlayer, {minigame, nowMinigame, success, failed, needed})
        end 

        exports['cr_controls']:toggleAllControls(true, "instant")

        localPlayer:setData('inMinigame', false)

        unbindKey("arrow_u", "down", minigame4ArrowUP)    
        unbindKey("arrow_d", "down", minigame4ArrowDown)    

        exports['cr_dx']:startFade("minigame4", 
            {
                ["startTick"] = getTickCount(),
                ["lastUpdateTick"] = getTickCount(),
                ["time"] = 250,
                ["animation"] = "InOutQuad",
                ["from"] = 255,
                ["to"] = 0,
                ["alpha"] = 255,
                ["progress"] = 0,
            }
        )
    end
end

function getMinigameStatus(id)
    if id == 1 then 
        return minigameStatus
    elseif id == 2 then 
        return minigameStatus
    elseif id == 4 then 
        return minigameStatus
    end 

    return false
end 

function resetMinigame(id, i, i2, i3)
    if id == 1 then
        minigame = id
        success = 0
        failed = 0
        max = i
        needed = i2

        startTime = getTickCount()
        endTime = startTime + (i3 and i3 or math.random(375, 1250))

        if math.random(1, 2) == 1 then 
            animY = 0
            animState = "+"
        else 
            animY = 350
            animState = "-"
        end 
    elseif id == 2 then
        minigame = id
        success = 0
        failed = 0
        max = i
        needed = i2
        minigame2Cache = {}
        buttonAnimation = {}
        if isTimer(minigame2Timer) then
            killTimer(minigame2Timer)
        end
    elseif id == 3 then
        minigame = id
        success = 0
        failed = 0
        max = i
        needed = i2
        minigame3Cache = {}
        if isTimer(minigame3Timer) then
            killTimer(minigame3Timer)
        end
    elseif id == 4 then 
        minigame = id
        success = 0
        max = i
        failed = 0
        needed = i
        now = 0
    end

    return true
end

function linedRectangle(x,y,w,h,color,color2,size)
    if not color then
        color = tocolor(0,0,0,180)
    end
    if not color2 then
        color2 = color
    end
    if not size then
        size = 1.7
    end
	dxDrawRectangle(x, y, w, h, color) -- Háttér
	dxDrawRectangle(x - size, y - size, w + (size * 2), size, color2) -- felső
	dxDrawRectangle(x - size, y + h, w + (size * 2), size, color2) -- alsó
	dxDrawRectangle(x - size, y, size, h, color2) -- bal
	dxDrawRectangle(x + w, y, size, h, color2) -- jobb
end

function getColor(animY) 
    local color = {255,51,51}

    if animY > 125 and animY < 225 then
        color = {51,255,51}
    elseif animY <= 125 then 
        local r, g, b = interpolateBetween(255, 51, 51, 51, 255, 51, animY / 125, 'Linear')

        color = {r, g, b}
    elseif animY >= 225 then 
        local r, g, b = interpolateBetween(51, 255, 51, 255, 51, 51, (animY - 225) / 125, 'Linear')

        color = {r, g, b}
    end

    return unpack(color)
end

function drawnMinigame1()
    local alpha, progress = exports['cr_dx']:getFade("minigame1")
    if not minigameStatus then 
        if progress >= 1 then 
            destroyRender("drawnMinigame1")
            return 
        end  
    end 

    local now = getTickCount()
	local elapsedTime = now - startTime
	local duration = endTime - startTime
	local progress = elapsedTime / duration

    if animState == "+" then
        animY = interpolateBetween(0, 0, 0, 350, 0, 0, progress, 'Linear')

        if progress >= 1 then
            startTime = getTickCount()
            endTime = startTime + math.random(375, 1250)

            animY = 350
            animState = "-"
        end
    elseif animState == "-" then
        animY = interpolateBetween(350, 0, 0, 0, 0, 0, progress, 'Linear')

        if progress >= 1 then
            startTime = getTickCount()
            endTime = startTime + math.random(375, 1250)

            animY = 0
            animState = "+"
        end
    end

    local w, h = 40, 350
    local x, y = sx - w - 20, sy/2 - h/2
    local r,g,b = getColor(animY)

    linedRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8), tocolor(41, 41, 41, alpha * 0.8), 2)
    dxDrawRectangle(x, y + h, w, -animY, tocolor(r, g, b, alpha))
end

function addAnimation()
    local type = math.random(1,4)

    table.insert(minigame2Cache, 1, {type, 'default', getTickCount(), getTickCount() + math.random(4000, 17500)})
end

function drawnMinigame2()
    local alpha, progress = exports['cr_dx']:getFade("minigame2")
    if not minigameStatus then 
        if progress >= 1 then 
            destroyRender("drawnMinigame2")
            return 
        end  
    end 

    local enabled, ax,ay,aw,ah,sizable,turnable, sizeDetails, acType, columns = exports['cr_interface']:getDetails("Actionbar")

    local w, h = 235, 70 
    local x, y = ax + aw/2 - w/2, ay - h - 20

    dxDrawRectangle(x, y, w, h, tocolor(41, 41, 41, alpha * 0.9))

    local startX, startY = x + 10, y + 10
    local _startX = startX

    local w2, h2 = 50, 50
    local w3, h3 = 26, 28
    dxDrawRectangle(startX, startY, w2, h2, tocolor(242, 242, 242, alpha * 0.2))

    local id = 1
    if buttonAnimation[id] then 
        local alpha, progress;
        if buttonAnimation[id][1] then -- befade
            alpha, progress = exports['cr_dx']:getFade("minigame2 >> buttonAnimation >> " .. id)

            if progress >= 1 then 
                buttonAnimation[id][1] = false

                exports['cr_dx']:startFade("minigame2 >> buttonAnimation >> " .. id, 
                    {
                        ["startTick"] = getTickCount(),
                        ["lastUpdateTick"] = getTickCount(),
                        ["time"] = 250,
                        ["animation"] = "InOutQuad",
                        ["from"] = 255,
                        ["to"] = 0,
                        ["alpha"] = 255,
                        ["progress"] = 0,
                    }
                )
            end 
        else -- kifade
            alpha, progress = exports['cr_dx']:getFade("minigame2")

            if progress >= 1 then 
                buttonAnimation[id] = nil
            end 
        end 

        if buttonAnimation[id] then 
            if buttonAnimation[id][2] == 'success' then 
                dxDrawRectangle(startX, startY, w2, h2, tocolor(97, 177, 90, alpha * 0.7))
            elseif buttonAnimation[id][2] == 'failed' then  
                dxDrawRectangle(startX, startY, w2, h2, tocolor(255, 59, 59, alpha * 0.7))
            end 
        end
    end 

    dxDrawImage(startX + w2/2 - w3/2, startY + h2/2 - h3/2, w3, h3, 'files/2/arrow.png', 0, 0, 0, tocolor(242, 242, 242, alpha))

    startX = startX + w2 + 5

    dxDrawRectangle(startX, startY, w2, h2, tocolor(242, 242, 242, alpha * 0.2))

    local id = 2
    if buttonAnimation[id] then 
        local alpha, progress;
        if buttonAnimation[id][1] then -- befade
            alpha, progress = exports['cr_dx']:getFade("minigame2 >> buttonAnimation >> " .. id)

            if progress >= 1 then 
                buttonAnimation[id][1] = false

                exports['cr_dx']:startFade("minigame2 >> buttonAnimation >> " .. id, 
                    {
                        ["startTick"] = getTickCount(),
                        ["lastUpdateTick"] = getTickCount(),
                        ["time"] = 250,
                        ["animation"] = "InOutQuad",
                        ["from"] = 255,
                        ["to"] = 0,
                        ["alpha"] = 255,
                        ["progress"] = 0,
                    }
                )
            end 
        else -- kifade
            alpha, progress = exports['cr_dx']:getFade("minigame2")

            if progress >= 1 then 
                buttonAnimation[id] = nil
            end 
        end 

        if buttonAnimation[id] then 
            if buttonAnimation[id][2] == 'success' then 
                dxDrawRectangle(startX, startY, w2, h2, tocolor(97, 177, 90, alpha * 0.7))
            elseif buttonAnimation[id][2] == 'failed' then  
                dxDrawRectangle(startX, startY, w2, h2, tocolor(255, 59, 59, alpha * 0.7))
            end 
        end 
    end 

    dxDrawImage(startX + w2/2 - w3/2, startY + h2/2 - h3/2, w3, h3, 'files/2/arrow.png', 90, 0, 0, tocolor(242, 242, 242, alpha))

    startX = startX + w2 + 5

    dxDrawRectangle(startX, startY, w2, h2, tocolor(242, 242, 242, alpha * 0.2))

    local id = 3
    if buttonAnimation[id] then 
        local alpha, progress;
        if buttonAnimation[id][1] then -- befade
            alpha, progress = exports['cr_dx']:getFade("minigame2 >> buttonAnimation >> " .. id)

            if progress >= 1 then 
                buttonAnimation[id][1] = false

                exports['cr_dx']:startFade("minigame2 >> buttonAnimation >> " .. id, 
                    {
                        ["startTick"] = getTickCount(),
                        ["lastUpdateTick"] = getTickCount(),
                        ["time"] = 250,
                        ["animation"] = "InOutQuad",
                        ["from"] = 255,
                        ["to"] = 0,
                        ["alpha"] = 255,
                        ["progress"] = 0,
                    }
                )
            end 
        else -- kifade
            alpha, progress = exports['cr_dx']:getFade("minigame2")

            if progress >= 1 then 
                buttonAnimation[id] = nil
            end 
        end 

        if buttonAnimation[id] then 
            if buttonAnimation[id][2] == 'success' then 
                dxDrawRectangle(startX, startY, w2, h2, tocolor(97, 177, 90, alpha * 0.7))
            elseif buttonAnimation[id][2] == 'failed' then  
                dxDrawRectangle(startX, startY, w2, h2, tocolor(255, 59, 59, alpha * 0.7))
            end 
        end
    end 

    dxDrawImage(startX + w2/2 - w3/2, startY + h2/2 - h3/2, w3, h3, 'files/2/arrow.png', 180, 0, 0, tocolor(242, 242, 242, alpha))

    startX = startX + w2 + 5

    dxDrawRectangle(startX, startY, w2, h2, tocolor(242, 242, 242, alpha * 0.2))

    local id = 4
    if buttonAnimation[id] then 
        local alpha, progress;
        if buttonAnimation[id][1] then -- befade
            alpha, progress = exports['cr_dx']:getFade("minigame2 >> buttonAnimation >> " .. id)

            if progress >= 1 then 
                buttonAnimation[id][1] = false

                exports['cr_dx']:startFade("minigame2 >> buttonAnimation >> " .. id, 
                    {
                        ["startTick"] = getTickCount(),
                        ["lastUpdateTick"] = getTickCount(),
                        ["time"] = 250,
                        ["animation"] = "InOutQuad",
                        ["from"] = 255,
                        ["to"] = 0,
                        ["alpha"] = 255,
                        ["progress"] = 0,
                    }
                )
            end 
        else -- kifade
            alpha, progress = exports['cr_dx']:getFade("minigame2")

            if progress >= 1 then 
                buttonAnimation[id] = nil
            end 
        end 

        if buttonAnimation[id] then 
            if buttonAnimation[id][2] == 'success' then 
                dxDrawRectangle(startX, startY, w2, h2, tocolor(97, 177, 90, alpha * 0.7))
            elseif buttonAnimation[id][2] == 'failed' then  
                dxDrawRectangle(startX, startY, w2, h2, tocolor(255, 59, 59, alpha * 0.7))
            end 
        end
    end 

    dxDrawImage(startX + w2/2 - w3/2, startY + h2/2 - h3/2, w3, h3, 'files/2/arrow.png', 270, 0, 0, tocolor(242, 242, 242, alpha))

    local now = getTickCount()

    local count = 0

    for k,v in ipairs(minigame2Cache) do 
        local type, status, startTime, endTime = unpack(v)

        local x, rot, bt = unpack(typeDatas[type])

        local x = _startX + x

        local elapsedTime = now - startTime
        local duration = endTime - startTime
        local progress = elapsedTime / duration

        if progress <= 1 then 
            local y = interpolateBetween(-250, 0, 0, sy + 250, 0, 0, progress, 'Linear')

            if y < sy then 
                count = count + 1

                if status == 'failed' then 
                    dxDrawRectangle(x, y, w2, h2, tocolor(255, 59, 59, alpha * 0.7))
                elseif status == 'success' then 
                    dxDrawRectangle(x, y, w2, h2, tocolor(97, 177, 90, alpha * 0.7))
                elseif status == 'default' then 
                    dxDrawRectangle(x, y, w2, h2, tocolor(51, 51, 51, alpha * 0.6))
                end 
                dxDrawImage(x + w2/2 - w3/2, y + h2/2 - h3/2, w3, h3, 'files/2/arrow.png', rot, 0, 0, tocolor(242, 242, 242, alpha))

                --[[Ha túl lép a startY + h2 + 15-en ami a limitje akkor auto fail]]
                if (y + h2) > (startY + h2 + 15) then 
                    if status == 'default' then
                        minigame2Cache[k][2] = 'failed'
                    end
                end 
            end 
        end 
    end 

    function getMinigame2RenderOffsets()
        return startY, h2
    end 

    if minigameStatus and count <= 0 then
        stopMinigame(2)
    end

    --[[

    dxDrawRectangle(sx/2 - 250 - 2, sy - 150 - 10 - 2, (sx/2+160)-(sx/2 - 240)+70 + 4, 70 + 4, tocolor(44, 44, 44,255))
    dxDrawRectangle(sx/2 - 250, sy - 150 - 10, (sx/2+160)-(sx/2 - 240)+70, 70, tocolor(33, 33, 33,255))
    dxDrawImage(sx/2 - 240, sy - 150, 50, 50, "files/2/arrow.png", 0, 0, 0, tocolor(255,255,255,255))
    dxDrawImage(sx/2 - 120, sy - 150, 50, 50, "files/2/arrow.png", 90, 0, 0, tocolor(255,255,255,255))
    dxDrawImage(sx/2 + 20, sy - 150, 50, 50, "files/2/arrow.png", 180, 0, 0, tocolor(255,255,255,255))
    dxDrawImage(sx/2 + 160, sy - 150, 50, 50, "files/2/arrow.png", 270, 0, 0, tocolor(255,255,255,255))
    
    --dxDrawRectangle(sx/2 + 160, sy - 150, 50, 10, tocolor(255, 0, 0, 255)) -- Teteje
    --dxDrawRectangle(sx/2 + 160, sy - 100, 50, 10, tocolor(255, 0, 255, 255)) -- Alja
    for k,v in pairs(minigame2Cache) do
        local data, y, isFailed, try = unpack(v) 
        y = y + speedMultipler
        minigame2Cache[k][2] = y
        local type, rot, x, bt = unpack(data)
        
        --dxDrawRectangle(sx/2 + x, y, 50, 10) -- Teteje

        --dxDrawRectangle(sx/2 + x, y + 50, 50, 10) -- Teteje
        
        --dxDrawRectangle(sx/2 + x, y + 50, 50, 10, tocolor(0,255,0, 255)) -- Alja
        --dxDrawRectangle(sx/2 + x, y - 10, 50, 10, tocolor(0,0,255, 255)) -- Teteje
        local r,g,b = 255,255,255
        if not isFailed and try then
            r,g,b = 87, 255, 87
        end
        if y >= sy then
            table.remove(minigame2Cache, k)
            --last = k
            if isFailed then
                failed = failed + 1
            else
                success = success + 1
            end
        end
        --outputChatBox(k .. ":"..tostring(isFailed).."-"..tostring(try))
        if isFailed and try then
            r,g,b = 255,87,87
        end
        dxDrawImage(sx/2 + x, y, 50, 50, "files/2/arrow.png", rot, 0, 0, tocolor(r,g,b,255))
    end]]
end

local allowed = { { 48, 57 }, { 65, 90 }, { 97, 122 } } -- numbers/lowercase chars/uppercase chars

function generateString(len)
    if tonumber(len) then
        math.randomseed(getTickCount())
        local str = ""
        for i = 1, len do
            local charlist = allowed[math.random ( 1, 3 )]
            str = str .. string.upper(string.char(math.random(charlist[1], charlist[2])))
        end
        if tonumber(str) ~= nil then
            return generateString(len)
        end
        return str
    end
    return false
end

function addAnimation2()
    local string = generateString(1)
    local tablee = {string, 0, true, false} -- y, x
    table.insert(minigame3Cache, 1, tablee)
end

function drawnMinigame3()
    dxDrawImage(sx/2 - 50/2, sy - 150, 50, 50, "files/3/belsokor.png", 0, 0, 0, tocolor(180,180,180,255))
    dxDrawImage(sx/2 - 50/2, sy - 150, 50, 50, "files/3/kulsokor.png", 0, 0, 0, tocolor(180,180,180,255))
    for k,v in pairs(minigame3Cache) do
        local string, x, isFailed, try = unpack(v) 
        x = x + speedMultipler
        minigame3Cache[k][2] = x
        local r,g,b = 255,255,255
        if not isFailed then
            r,g,b = 87, 255, 87
        end
        if x >= sx then
            table.remove(minigame3Cache, k)
            if isFailed then
                failed = failed + 1
            else
                success = success + 1
            end
        elseif x > sx/2 + (120/2) then
            if isFailed then
                r,g,b = 255,87,87
            end
        end
        dxDrawText(string, x, sy - (150) + 50/2, x, sy - (150) + 50/2, tocolor(r,g,b,255), 1, "default-bold", "center", "center")
    end
    --outputChatBox(#minigame2Cache)
    if #minigame3Cache <= 0 then
        stopMinigame(3)
    end
end

--[[
    Favágó Minigame
]]

--Render Function
function drawnMinigame4()
    local alpha, progress = exports['cr_dx']:getFade("minigame4")
    if not minigameStatus then 
        if progress >= 1 then 
            destroyRender("drawnMinigame4")
            return 
        end  
    end 

    local enabled, ax,ay,aw,ah,sizable,turnable, sizeDetails, acType, columns = exports['cr_interface']:getDetails("Actionbar")

    local w, h = 222, 22

    linedRectangle(ax + aw/2 - w/2,ay - 95,w, h, tocolor(242,242,242,alpha * 0.6), tocolor(23, 23, 23, alpha * 0.6), 1)

    dxDrawRectangle(ax + aw/2 - w/2,ay - 95,w * (success / needed), h, tocolor(255,59,59,alpha))

    local w2, h2 = 45, 45

    dxDrawImage(ax + aw/2 - w2/2, ay - 95 + h + 15, w2, h2, 'files/4/arrow.png', 180, 0, 0, tocolor(242, 242, 242, alpha * (now == 1 and 1 or 0.6))) -- Down Arrow
    dxDrawImage(ax + aw/2 - w2/2, ay - 95 - 15 - h2, w2, h2, 'files/4/arrow.png', 0, 0, 0, tocolor(242, 242, 242, alpha * (now == 0 and 1 or 0.6))) -- UP Arrow
end 

--Key Functions
function minigame4ArrowUP(b, s)
    if s == 'down' then 
        if now == 0 then 
            now = 1 

            success = success + 1

            if success >= needed then 
                stopMinigame(4)
            end 
        else 
            failed = 1

            stopMinigame(4)
        end 
    end 
end 

function minigame4ArrowDown(b, s)
    if s == 'down' then 
        if now == 1 then 
            now = 0

            success = success + 1

            if success >= needed then 
                stopMinigame(4)
            end 
        else 
            failed = 1

            stopMinigame(4)
        end 
    end 
end 