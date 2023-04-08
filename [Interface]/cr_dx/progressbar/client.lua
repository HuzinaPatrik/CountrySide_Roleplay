local isRender, startTick, gId, gData, animX, now = nil, nil, nil, {}, 0, 1;

addEvent('ProgressBarStart', true)
addEvent('ProgressBarEnd', true)

function startProgressBar(id, data)
    if not isRender then 
        gId = id
        isRender = true 
        startTick = getTickCount()
        animX = 0 
        now = 1
        gData = data

        exports['cr_dx']:startFade("ProgressBar", 
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
        
        createRender("drawnProgress", drawnProgress)

        triggerEvent('ProgressBarStart', localPlayer, gId, gData)
    end 
end 

function setProgressBarData(id, data)
    if isRender and not id or isRender and id and gId == id then  
        gData = data
    end 
end 

function resetProgressBar(id, ignoreTrigger)
    if isRender and not id or isRender and id and gId == id then 
        animX = 0 
        now = 1

        if not ignoreTrigger then 
            triggerEvent('ProgressBarStart', localPlayer, gId, gData)
        end 
    end 
end 

function endProgressBar(id)
    if isRender and not id or isRender and id and gId == id then 
        isRender = false 
        exports['cr_dx']:startFade("ProgressBar", 
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

        triggerEvent('ProgressBarEnd', localPlayer, gId, gData)
    end 
end 

function isProgressBarActive(id)
    if id then 
        return isRender and gId == id
    end

    return isRender
end 

local sx, sy = guiGetScreenSize()
function drawnProgress()
    local alpha, progress = exports['cr_dx']:getFade("ProgressBar")
    if not isRender then 
        if progress >= 1 then 
            destroyRender("drawnProgress")
            return 
        end  
    end 

    local font = exports['cr_fonts']:getFont("Poppins-Medium", 10)

    local enabled, ax,ay,aw,ah,sizable,turnable, sizeDetails, acType, columns = exports['cr_interface']:getDetails("Actionbar")

    local nowTick = getTickCount()
    local elapsedTime = nowTick - startTick
    local duration = gData[now][2]
    local progress = elapsedTime / duration
    local alph = interpolateBetween(
        0, 0, 0,
        400, 0, 0,
        progress, "InOutQuad"
    )
    animX = alph

    dxDrawRectangle(ax + aw/2 - 400/2,ay - 20,400, 15, tocolor(51,51,51,alpha * 0.8))

    if progress >= 1 then
        if gData[now + 1] then
            startTick = getTickCount()
            now = now + 1
            animX = 0
        else
            endProgressBar()
        end 
    end 

    dxDrawRectangle(ax + aw/2 - 400/2, ay - 20, animX, 15, tocolor(255, 59, 59, alpha))
    dxDrawText("#F2F2F2" .. gData[now][1] .. " " .. (math.floor((animX / 400) * 100)).."%", ax + aw/2, ay - 20, ax + aw/2, ay - 20 + 15 + 4, tocolor(242,242,242, alpha), 1, font, "center", "center", false, false, false, true)
end 