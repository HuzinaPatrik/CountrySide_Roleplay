local loadingGlobal = {
    --[[
    [type] = {
        {Szöveg, Multipler},
    },
    ]]
    ["Login"] = {
        {"Karakter adatok összegyűjtése", 7},
        {"Karakter adatok betöltése", 9},
        {"Karakter spawnolása", 15},
    },
    ["Char-Reg"] = {
        {"Adatok összegyűjtése", 3},
        {"Karakter létrehozása", 8},
        {"Bejelentkezés", 13},
    },
}

local sound

function startLoadingScreen(id)
    logginEd = false
    now = 1
    showCursor(false)
    animX = 0
    alpha = 255
    multipler = 1
    textID = id or 1
    startTick = getTickCount()
    sound = playSound("files/loading.mp3", true)
    page = "LoadingScreen"
    addEventHandler("onClientRender", root, drawnLoadingScreen, true, "low-5")
    toggleAllControls(false, false)
end

function stopLoadingScreen()
    removeEventHandler("onClientRender", root, drawnLoadingScreen)
end


function drawnLoadingScreen()
    local font = exports['cr_fonts']:getFont("Poppins-SemiBold", 18)
    
    dxDrawRectangle(0,0,sx,sy, tocolor(16,16,16,255))
    local w, h = 1000, 5
    dxDrawRectangle(sx/2 - w/2,sy - 55,w,h, tocolor(242,242,242,255 * 0.6))
    
    local text, multipler = unpack(loadingGlobal[textID][now])
    
    local nowTick = getTickCount()
    local elapsedTime = nowTick - startTick
    local duration = (multipler * 200)
    local progress = elapsedTime / duration
    local alph = interpolateBetween(
        0, 0, 0,
        w, 0, 0,
        progress, "InOutQuad"
    )
    animX = alph

    if progress >= 1 then
        if loadingGlobal[textID][now + 1] then
            startTick = getTickCount()
            now = now + 1
            animX = 0
        else
            if not logginEd then
                logginEd = true
                fadeCamera(false, 0)
                destroyElement(sound)
                local id, username = getElementData(localPlayer, "acc >> id"), getElementData(localPlayer, "acc >> username")

                triggerServerEvent("loadCharacter", localPlayer, localPlayer, id, username)
            end
        end
    end
    
    dxDrawText(text .. " " .. (math.floor((animX / w) * 100)).."%", sx/2, sy - 55, sx/2, sy - 85, tocolor(242,242,242,255), 1, font, "center", "center", false, false, false, true)
    dxDrawRectangle(sx/2 - w/2,sy - 55,animX,h, tocolor(255, 59, 59, 255))

    local w, h = 329, 380
    dxDrawImage(sx/2 - w/2, sy/2 - h/2, w, h, "files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, 255))
end