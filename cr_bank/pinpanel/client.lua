local hover, pinHover, isRender, inSlot, startX, startY, x, y
oText = "*****************************************************************************************************************************************"

local function enterInteraction()
    if isRender then  
        if #pinData["Text"] ~= 4 then 
            exports['cr_infobox']:addBox("error", "A pinkódnak minimum 4 karakternek kell lennie!")
            return 
        end 

        local nowPin = bank_accounts[pinData["ID"]][6]
        if tonumber(pinData["Text"]) == nowPin then 
            exports['cr_infobox']:addBox("success", "Sikeres bejelentkezés!")
            closePinPanel()
            if pinData["onEnter"] then 
                pinData["onEnter"]()
            end 
        else 
            exports['cr_infobox']:addBox("error", "Hibás pinkód!")
        end 
    end 
end 

local function onClick(b, s)
    if isRender then 
        if b == "left" and s == "down" then 
            if tonumber(hover) then 
                if hover == 1 then 
                    enterInteraction()
                elseif hover == 2 then 
                    closePinPanel()
                end 
                hover = nil 
            elseif pinHover then 
                if pinHover == "backspace" then 
                    if #pinData["Text"] >= 1 then
                        pinData["Text"] = utfSub(pinData["Text"], 0, #pinData["Text"] - 1)
                        playSound(":cr_account/files/key.mp3")
                    end
                elseif tonumber(pinHover) then 
                    local text = tonumber(pinHover) 
                    if text == 10 then text = "X" elseif text == 11 then text = "0" elseif text == 12 then text = "*" end
                    if tonumber(text) then
                        if #pinData["Text"] <= 3 then 
                            pinData["Text"] = pinData["Text"] .. text
                            playSound(":cr_account/files/key.mp3")
                        end 
                    elseif text == 'X' then 
                        pinData["Text"] = ''
                    end 
                end 
                pinHover = nil 
            end 
        end 
    end 
end 

local function backspaceInteraction()
    if #pinData["Text"] >= 1 then
        pinData["Text"] = utfSub(pinData["Text"], 0, #pinData["Text"] - 1)
        playSound(":cr_account/files/key.mp3")
    else 
        closePinPanel()
    end
end 

local function onKey(b, s)
    if b == "enter" and s then 
        enterInteraction()
        cancelEvent()
    elseif tonumber(b:sub(#b, #b)) and s and b:sub(1, 5):lower() ~= ("mouse"):lower() and b:sub(1, 1):lower() ~= ("F"):lower() then 
        if #pinData["Text"] <= 3 then 
            pinData["Text"] = pinData["Text"] .. b:sub(#b, #b)
            playSound(":cr_account/files/key.mp3")
        end 
        cancelEvent()
    elseif b:lower() == ('X'):lower() and s then 
        pinData["Text"] = ''
        playSound(":cr_account/files/key.mp3")

        cancelEvent()
    end 
end 

function openPinPanel(data)
    if not isRender then 
        isRender = true 

        exports['cr_dx']:startFade("bank >> pinPanel", 
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

        pinData = data
        createRender("renderPinPanel", renderPinPanel)

        bindKey("enter", "down", enterInteraction)
        bindKey("backspace", "down", backspaceInteraction)
        addEventHandler("onClientKey", root, onKey)
        addEventHandler("onClientClick", root, onClick)
    end 
end 

function closePinPanel()
    if isRender then 
        isRender = false 

        exports['cr_dx']:startFade("bank >> pinPanel", 
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
        
        unbindKey("enter", "down", enterInteraction)
        unbindKey("backspace", "down", backspaceInteraction)

        removeEventHandler("onClientKey", root, onKey)
        removeEventHandler("onClientClick", root, onClick)
    end 
end 

function renderPinPanel()
    local alpha, progress = exports['cr_dx']:getFade("bank >> pinPanel")
    if not isRender then 
        if progress >= 1 then 
            destroyRender("renderPinPanel")
            return 
        end  
    end 

    if getDistanceBetweenPoints3D(gPed.position, localPlayer.position) > 3 then 
        closePinPanel()
    end 

    --[[
        BG
    ]]
    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 10)
    local font3 = exports['cr_fonts']:getFont('Poppins-Medium', 25)

	local w, h = 300, 430
	local x, y = sx/2 - w/2, sy/2 - h/2

    hover = nil

	dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
	dxDrawImage(x + w/2 - 39/2, y + 10, 39, 45, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText('Kérlek add meg a pinkódod!', x, y + 70, x + w, y + 70, tocolor(242, 242, 242, alpha), 1, font2, "center", "top")

	if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
        hover = 2

        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
    else 
        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
    end 

    --[[
        Pincode
    ]]

    local startX, startY = x + w/2 - ((((20 + 15) * 4) - 15)/2), y + 100
    for i = 1, 4 do 
        if #pinData["Text"] >= i then 
            dxDrawImage(startX, startY, 20, 20, "assets/images/pin-full.png", 0, 0, 0, tocolor(242, 242, 242, alpha))
        else 
            dxDrawImage(startX, startY, 20, 20, "assets/images/pin-bg.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
        end 

        startX = startX + 20 + 15
    end 

    --[[
        Pin Buttons
    ]]

    local w2, h2 = 80, 70
    local rw2, rh2 = 50, 40

    pinHover = nil 
    local count = 1
    local startX, startY = x + w/2 - ((((rw2 + 13) * 3) - 13)/2), y + 150
    local _startX = startX
    for i = 1, 12 do 

        local text = i 
        if text == 10 then text = "X" elseif text == 11 then text = "0" elseif text == 12 then text = "backspace" end

        local inSlot = exports['cr_core']:isInSlot(startX, startY, rw2, rh2)
        if inSlot or getKeyState(text) then 
            if inSlot then 
                pinHover = text == 'backspace' and 'backspace' or i
            end 

            dxDrawImage(startX + rw2/2 - w2/2, startY + rh2/2 - h2/2, w2, h2, 'assets/images/pin-button.png', 0, 0, 0, tocolor(255, 59, 59, alpha * 0.7))
            if text == 'backspace' then 
                dxDrawImage(startX + rw2/2 - 22/2, startY + rh2/2 - 16/2, 22, 16, backspaceTex, 0, 0, 0, tocolor(242, 242, 242, alpha))
            else 
                dxDrawText(text, startX, startY, startX + rw2, startY + rh2 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
            end
        else 
            dxDrawImage(startX + rw2/2 - w2/2, startY + rh2/2 - h2/2, w2, h2, 'assets/images/pin-button.png', 0, 0, 0, tocolor(23, 23, 23, alpha * 0.9))
            if text == 'backspace' then 
                dxDrawImage(startX + rw2/2 - 22/2, startY + rh2/2 - 16/2, 22, 16, backspaceTex, 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
            else 
                dxDrawText(text, startX, startY, startX + rw2, startY + rh2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
            end 
        end 

        count = count + 1
        startX = startX + rw2 + 13
        if count > 3 then 
            count = 1 
            startX = _startX 
            startY = startY + rh2 + 13
        end 
    end 

    --[[
        Finish Button
    ]]

    local w2, h2 = 207, 60
    local rw2, rh2 = 177, 30

    if exports['cr_core']:isInSlot(startX, y + 355, rw2, rh2) then 
        hover = 1

        dxDrawImage(startX + rw2/2 - w2/2, y + 355 + rh2/2 - h2/2, w2, h2, "assets/images/pin-finish-button.png", 0, 0, 0, tocolor(97, 177, 90, alpha * 0.7))
        dxDrawText('Belépés', startX, y + 355, startX + rw2, y + 355 + rh2 + 4, tocolor(242, 242, 242, alpha), 1, font, "center", "center")
    else 
        dxDrawImage(startX + rw2/2 - w2/2, y + 355 + rh2/2 - h2/2, w2, h2, "assets/images/pin-finish-button.png", 0, 0, 0, tocolor(23, 23, 23, alpha * 0.9))
        dxDrawText('Belépés', startX, y + 355, startX + rw2, y + 355 + rh2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font, "center", "center")
    end 
end 