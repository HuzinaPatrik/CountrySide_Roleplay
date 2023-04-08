local sounds = {}
local soundActive, moving;

local inHover
local currentMusic, randomMusic
local loginMusics = {
	"Ain't No Sunshine",
    'Take Me Home, Country Roads',
    'Sweet Home Alabama',
    'He Stopped Loving Her Today',
    'Swinging Doors'
};

function startLoginSound()
    randomMusic = math.random(1, #loginMusics);
    currentMusic = randomMusic
    soundActive = saveJSON['soundActive']

    sounds["element"] = playSound('http://51.75.79.239/music/' .. randomMusic .. '.mp3', true)
    a = setTimer(
        function()
            setSoundVolume(sounds["element"], saveJSON["soundVolume"])

            setSoundPaused(sounds["element"], not soundActive)
        end, 350, 1
    )

    setSoundPaused(sounds["element"], not soundActive)

    --addEventHandler("onClientRender", root, onSoundPlayRender, true, "low-5")
    addEventHandler("onClientRender", root, drawnSoundMultipler, true, "low-5")
    --addEventHandler("onClientRender", root, drawExtraButtons, true, "low-5")
end

function stopLoginSound()
    --removeEventHandler("onClientRender", root, drawExtraButtons)

    if isTimer(a) then
        killTimer(a)
    end
    if isElement(sounds["element"]) then
        destroyElement(sounds["element"])
        sounds["element"] = nil
    end
    --soundActive = false
    
    removeEventHandler("onClientRender", root, drawnSoundMultipler)
    --removeEventHandler("onClientRender", root, onSoundPlayRender)
end

function drawnSoundMultipler()    
    if page ~= "Unknown" then
        local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 12)
        local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 10)

        local w, h = 350, 65
        local x, y = sx - 20 - w, sy - 20 - h
        dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, 255 * 0.8))      
        
        dxDrawImage(x + 20, y + h/2 - 41/2, 31, 41, 'files/music-icon.png', 0, 0, 0, tocolor(242, 242, 242, 255 * 0.8))

        inHover = false 

        local startX = x + 125
        if exports['cr_core']:isInSlot(startX, y + 37, 26, 15) then 
            inHover = 'back' 

            local r,g,b = exports['cr_core']:getServerColor('red')
            dxDrawImage(startX, y + 37, 26, 15, 'files/music-next-icon.png', 0, 0, 0, tocolor(r, g, b, 255))
        else 
            dxDrawImage(startX, y + 37, 26, 15, 'files/music-next-icon.png', 0, 0, 0, tocolor(242, 242, 242, 255 * 0.8))
        end 
        
        startX = startX + 26 + 20

        if exports['cr_core']:isInSlot(startX, y + (soundActive and 35 or 33), 20, soundActive and 20 or 24) then 
            inHover = soundActive and 'pause' or 'play'

            local r,g,b = exports['cr_core']:getServerColor('red')
            dxDrawImage(startX, y + (soundActive and 35 or 33), 20, soundActive and 20 or 24, soundActive and 'files/music-pause-icon.png' or 'files/music-play-icon.png', 0, 0, 0, tocolor(r, g, b, 255))
        else 
            dxDrawImage(startX, y + (soundActive and 35 or 33), 20, soundActive and 20 or 24, soundActive and 'files/music-pause-icon.png' or 'files/music-play-icon.png', 0, 0, 0, tocolor(242, 242, 242, 255 * 0.8))
        end 

        local musicName = loginMusics[currentMusic]
        dxDrawText(musicName, startX, y, startX + 20, y + 35, tocolor(242, 242, 242, 255), 1, font, 'center', 'center')

        startX = startX + 20 + 20

        if exports['cr_core']:isInSlot(startX, y + 37, 26, 15) then 
            inHover = 'next' 

            local r,g,b = exports['cr_core']:getServerColor('red')
            dxDrawImage(startX, y + 37, 26, 15, 'files/music-next-icon.png', 180, 0, 0, tocolor(r, g, b, 255))
        else 
            dxDrawImage(startX, y + 37, 26, 15, 'files/music-next-icon.png', 180, 0, 0, tocolor(242, 242, 242, 255 * 0.8))
        end 

        --[[Progressbar]]
        dxDrawImage(x + 320, y + 15, 18, 15, 'files/music-volume-icon.png', 0, 0, 0, tocolor(242, 242, 242, 255 * 0.8))
        dxDrawText(math.floor(saveJSON["soundVolume"] * 100) .. ' %', x + 320, y + 40, x + 320 + 18, y + 40, tocolor(242, 242, 242, 255), 1, font2, 'center', 'top')
        dxDrawRectangle(x + 306, y + 5, 3, 55, tocolor(242, 242, 242, 255 * 0.6))
        if exports['cr_core']:isInSlot(x + 305, y + 5, 5, 55) then 
            inHover = 'progressbar'
        end 

        local r,g,b = exports['cr_core']:getServerColor('red')
        dxDrawRectangle(x + 306, y + 5 + 55, 3, (55 * saveJSON["soundVolume"]) * -1, tocolor(r, g, b, 255))
        dxDrawRectangle(x + 305, y + 5 + 55 + (math.max((55 * saveJSON["soundVolume"]), 5) * -1), 5, 5, tocolor(r, g, b, 255))

        if moving then
            if isCursorShowing() then
                if getKeyState("mouse1") then
                    local cx, cy = exports['cr_core']:getCursorPosition()
                    local a = 1 - ((cy - (y + 5)) / 55)
                    if a ~= saveJSON["soundVolume"] then
                        saveJSON["soundVolume"] = 0 + ((1 - 0) * math.max(math.min(a, 1), 0))

                        setSoundVolume(sounds["element"], saveJSON["soundVolume"])
                    end
                end
            else
                moving = false
            end
        end
    end
end

function sounds.onClick(b, s)
--    outputChatBox(page)
    if page == "Login" or page == "Register" or page == "RPTest" then
        if b == "left" and s == "down" then
            if inHover == 'play' then
                if lastClickTick + 500 > getTickCount() then
                    return
                end
                playSound("files/bubble.mp3")

                inHover = nil 

                saveJSON['soundActive'] = true 
                soundActive = saveJSON['soundActive']
                setSoundPaused(sounds["element"], not soundActive)
            elseif inHover == 'pause' then 
                if lastClickTick + 500 > getTickCount() then
                    return
                end
                playSound("files/bubble.mp3")

                inHover = nil 

                saveJSON['soundActive'] = false 
                soundActive = saveJSON['soundActive']
                setSoundPaused(sounds["element"], not soundActive)
            elseif inHover == 'next' then 
                if lastClickTick + 500 > getTickCount() then
                    return
                end
                playSound("files/bubble.mp3")

                inHover = nil 

                currentMusic = currentMusic + 1 
                if currentMusic > #loginMusics then 
                    currentMusic = 1
                end 

                if isElement(sounds["element"]) then
                    destroyElement(sounds["element"])
                end
                sounds["element"] = playSound('http://51.75.79.239/music/' .. currentMusic .. '.mp3', true)
                a = setTimer(
                    function()
                        setSoundVolume(sounds["element"], saveJSON["soundVolume"])
                    end, 350, 1
                )
            elseif inHover == 'back' then 
                if lastClickTick + 500 > getTickCount() then
                    return
                end
                playSound("files/bubble.mp3")

                inHover = nil 
                
                currentMusic = currentMusic - 1 
                if currentMusic <= 0 then 
                    currentMusic = #loginMusics
                end             

                if isElement(sounds["element"]) then
                    destroyElement(sounds["element"])
                end
                sounds["element"] = playSound('http://51.75.79.239/music/' .. currentMusic .. '.mp3', true)
                a = setTimer(
                    function()
                        setSoundVolume(sounds["element"], saveJSON["soundVolume"])
                    end, 350, 1
                )
            elseif inHover == 'progressbar' then
                if lastClickTick + 500 > getTickCount() then
                    return
                end
                playSound("files/bubble.mp3")

                inHover = nil 
                
                moving = true
            end 
        elseif b == "left" and s == "up" then
            if moving then
                moving = false
            end
        end
    end
end
addEventHandler("onClientClick", root, sounds.onClick)

--[[

local sx2, sy2 = guiGetScreenSize();
local bx, by = sx2, sy2

local boxes = 40;
local startColor, endColor = {150, 150, 150}, {255, 255, 255}
function onSoundPlayRender()
    if isElement(sounds["element"]) and not isSoundPaused(sounds["element"]) then
        local soundFFT = getSoundFFTData(sounds["element"], 8192, 256) or {};
        if (soundFFT) then
            local l = sx2/2 - bx/2
            local t = sy2/2 + by/2
            local w = bx/boxes

            local soundVolume = saveJSON["soundVolume"];
            local multipler = 2.0 * (soundVolume)
            for i = 0, boxes do
            	if (soundFFT) ~= nil then
            		local numb = soundFFT[i] or 0
                	local sr = (numb * multipler) or 0

	                if sr > 0 then
		                local r, g, b = interpolateBetween(startColor[1], startColor[2], startColor[3], endColor[1], endColor[2], endColor[3], sr, "Linear")
		                dxDrawRectangle(l + (i*w), t, w, -1 * sr * 256, tocolor(r, g, b, 240))
		            end
		        end
            end
        end
    end
end]]