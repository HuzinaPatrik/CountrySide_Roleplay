local maxDistNearby = 18
function getNearbyATMs(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "nearbyatm") then
        local target = false
        local px, py, pz = getElementPosition(localPlayer)
        local green = exports['cr_core']:getServerColor("orange", true)
        local syntax = exports['cr_core']:getServerSyntax("ATM", "info")
        local white = "#ffffff"
        local hasVeh = false
        for k,v in pairs(getElementsByType("object", root, true)) do
            local x,y,z = getElementPosition(v)
            local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
            if dist <= maxDistNearby then
                local id = getElementData(v, "bank >> atm") or 0
                if id > 0 then
                    local model = getElementModel(v)
                    outputChatBox(syntax.."Model: "..green..model..white..", ID: "..green..id..white..", Távolság: "..green..math.floor(dist)..white.." yard", 255,255,255,true)
                    hasVeh = true
                end
            end
        end
        if not hasVeh then
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax("ATM", "error")
            outputChatBox(syntax .. "Nincs traffipax a közeledben!", 255,255,255,true)
        end
    end
end
addCommandHandler("getNearbyatm", getNearbyATMs)
addCommandHandler("getnearbyatms", getNearbyATMs)
addCommandHandler("getnearbyAtms", getNearbyATMs)
addCommandHandler("getnearbyAtm", getNearbyATMs)

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        for k,v in pairs(getElementsByType("object", _, true)) do 
            local id = getElementData(v, "bank >> atm") or 0
            if id > 0 then
                v.breakable = false
            end 
        end 
    end 
)

addEventHandler("onClientElementStreamIn", resourceRoot, 
    function()
        if source and source:getData("bank >> atm") then 
            source.breakable = false
        end 
    end 
)

function openATM(ped, value)
    local val = bankCardNumberToID[tonumber(value)]
    if val then 
        if bank_accounts[val] then 
            gPed = ped
            openPinPanel(
                {
                    ["ID"] = val, 
                    ["Text"] = "", 
                    ["onEnter"] = function()
                        openATMPanel(pinData["ID"])
                    end 
                }
            )
        end 
    end 
end 

local isRender, selectedMenu, hover, moneyText, pinHover

lastClickTick = -5000
local function enterInteraction()
    if isRender then  
        if selectedMenu == 2 then 
            local now = getTickCount()
            if now <= lastClickTick + 5000 then
                return
            end

            if exports['cr_network']:getNetworkStatus() then 
                return 
            end 

            if not tonumber(moneyText) or #moneyText < 1 then 
                exports['cr_infobox']:addBox("error", "Az összegnek minimum 1 karakterből kell állnia!")
                return 
            end 

            if tonumber(moneyText) <= 0 then 
                exports['cr_infobox']:addBox("error", "Az összegnek minimum 1nek kell lennie!")
                return 
            end 

            if tonumber(moneyText) > bank_accounts[gId][4] then 
                exports['cr_infobox']:addBox("error", "Nincs ennyi pénz a bankszámládon!")
                return 
            end 

            local green = exports['cr_core']:getServerColor('green', true)
            local red = exports['cr_core']:getServerColor('red', true)
            exports['cr_infobox']:addBox('success', 'Sikeresen kivettél az atmből '..green..'$ '..moneyText..'#F2F2F2-ot(et)! (Adó: '..red..'$ '..(tonumber(moneyText) * 0.1)..'#F2F2F2)')

            lastClickTick = getTickCount()
            triggerLatentServerEvent("takeMoneyFromBank.ATM", 5000, false, localPlayer, localPlayer, gId, bank_accounts[gId][4], moneyText)
            bank_accounts[gId][4] = bank_accounts[gId][4] - tonumber(moneyText)
            moneyText = ""
        elseif selectedMenu == 3 then 
            local now = getTickCount()
            if now <= lastClickTick + 5000 then
                return
            end

            if exports['cr_network']:getNetworkStatus() then 
                return 
            end 

            if not tonumber(moneyText) or #moneyText < 1 then 
                exports['cr_infobox']:addBox("error", "Az összegnek minimum 1 karakterből kell állnia!")
                return 
            end 

            if tonumber(moneyText) <= 0 then 
                exports['cr_infobox']:addBox("error", "Az összegnek minimum 1nek kell lennie!")
                return 
            end 

            if not exports['cr_core']:hasMoney(localPlayer, tonumber(moneyText)) then 
                exports['cr_infobox']:addBox("error", "Nincs elég pénzed!")
                return 
            end 

            local green = exports['cr_core']:getServerColor('green', true)
            local red = exports['cr_core']:getServerColor('red', true)
            exports['cr_infobox']:addBox('success', 'Sikeresen beraktál a bankba '..green..'$ ' .. moneyText .. '#F2F2F2-ot(et)! (Adó: '..red..'$ '..(tonumber(moneyText) * 0.1)..'#F2F2F2)')

            lastClickTick = getTickCount()
            triggerLatentServerEvent("addMoneyToBank.ATM", 5000, false, localPlayer, localPlayer, gId, bank_accounts[gId][4], moneyText)
            moneyText = ""
        end 
    end 
end 

local function onClick(b, s)
    if isRender then 
        if b == "left" and s == "down" then 
            if selectedMenu == 1 then 
                if tonumber(hover) then 
                    if tonumber(hover) == 3 then 
                        closeATMPanel()
                    else 
                        selectedMenu = tonumber(hover) + 1
                        if selectedMenu == 2 or selectedMenu == 3 then 
                            moneyText = ""
                        end 
                        hover = nil 
                    end 
                end 
            elseif selectedMenu == 2 or selectedMenu == 3 then 
                if tonumber(hover) then 
                    if hover == 1 then
                        enterInteraction()
                    elseif hover == 2 then 
                        selectedMenu = 1
                    end 
                    hover = nil 
                elseif pinHover then 
                    if pinHover == "backspace" then 
                        if #moneyText >= 1 then
                            moneyText = utfSub(moneyText, 0, #moneyText - 1)
                            playSound(":cr_account/files/key.mp3")
                        end
                    elseif tonumber(pinHover) then 
                        local text = tonumber(pinHover) 
                        if text == 10 then text = "X" elseif text == 11 then text = "0" elseif text == 12 then text = "*" end
                        if tonumber(text) then
                            if #moneyText <= 9 then 
                                moneyText = moneyText .. text
                                playSound(":cr_account/files/key.mp3")
                            end 
                        elseif text == 'X' then 
                            moneyText = ''
                        end 
                    end 
                    pinHover = nil 
                end 
            end 
        end 
    end 
end 

local function backspaceInteraction()
    if selectedMenu == 1 then 
        closeATMPanel()
    elseif selectedMenu == 2 or selectedMenu == 3 then 
        if #moneyText >= 1 and not now then
            moneyText = utfSub(moneyText, 0, #moneyText - 1)
            playSound(":cr_account/files/key.mp3")
        else 
            selectedMenu = 1
        end 
    end 
end 

local function onKey(b, s)
    if selectedMenu == 2 or selectedMenu == 3 then 
        if b == "enter" and s then 
            enterInteraction()
            cancelEvent()
        elseif tonumber(b:sub(#b, #b)) and s and b:sub(1, 5):lower() ~= ("mouse"):lower() and b:sub(1, 1):lower() ~= ("F"):lower() then 
            if #moneyText <= 9 and not now then 
                moneyText = moneyText .. b:sub(#b, #b)
                playSound(":cr_account/files/key.mp3")
            end 
            cancelEvent()
        elseif b:lower() == ('X'):lower() and s then 
            if selectedMenu == 2 and not now or selectedMenu == 3 and not now or selectedMenu == 4 and not now then 
                moneyText = ''
                playSound(":cr_account/files/key.mp3")
            end 

            cancelEvent()
        end 
    end 
end 

function openATMPanel(id)
    if bank_accounts[id] then 
        if not isRender then 
            isRender = true 

            exports['cr_dx']:startFade("bank >> atmPanel", 
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

            gId = id
            selectedMenu = 1
            bindKey("enter", "down", enterInteraction)
            bindKey("backspace", "down", backspaceInteraction)
            addEventHandler("onClientKey", root, onKey)
            addEventHandler("onClientClick", root, onClick)
            
            createRender("renderAtmPanel", renderAtmPanel)
        end 
    end 
end 

function closeATMPanel()
    if isRender then 
        isRender = false 

        exports['cr_dx']:startFade("bank >> atmPanel", 
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

function renderAtmPanel()
    local alpha, progress = exports['cr_dx']:getFade("bank >> atmPanel")
    if not isRender then 
        if progress >= 1 then 
            destroyRender("renderAtmPanel")
            return 
        end  
    end 

    if getDistanceBetweenPoints3D(gPed.position, localPlayer.position) > 3 then 
        closeATMPanel()
    end 

    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 14)
    local font3 = exports['cr_fonts']:getFont('Poppins-SemiBold', 14)
    local font4 = exports['cr_fonts']:getFont('Poppins-Medium', 12)

    if selectedMenu == 1 then 
        local w, h = 330, 180
        local x, y = sx/2 - w/2, sy/2 - h/2 

        dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText('ATM', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

        dxDrawText('Üdvözöllek a bankunk ATM kezelőfelületén.\nKérlek válasz tranzakciót!', x,y+45,x+w,y+45,tocolor(242, 242, 242, alpha),1,font2,"center","top")

        hover = nil
        if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
            hover = 3

            dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
        else 
            dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
        end 

        local w2, h2 = 180, 20
        y = y + 115
        if exports['cr_core']:isInSlot(x + w/2 - w2/2, y, w2, h2) then 
            hover = 2

            dxDrawRectangle(x + w/2 - w2/2, y, w2, h2, tocolor(255, 59, 59, alpha))
            dxDrawText('Készpénz befizetése', x, y, x + w, y + h2 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
        else 
            dxDrawRectangle(x + w/2 - w2/2, y, w2, h2, tocolor(23, 23, 23, alpha * 0.9))
            dxDrawText('Készpénz befizetése', x, y, x + w, y + h2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
        end

        y = y + h2 + 5
        if exports['cr_core']:isInSlot(x + w/2 - w2/2, y, w2, h2) then 
            hover = 1

            dxDrawRectangle(x + w/2 - w2/2, y, w2, h2, tocolor(97, 177, 90, alpha))
            dxDrawText('Készpénz felvétel', x, y, x + w, y + h2 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
        else 
            dxDrawRectangle(x + w/2 - w2/2, y, w2, h2, tocolor(23, 23, 23, alpha * 0.9))
            dxDrawText('Készpénz felvétel', x, y, x + w, y + h2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
        end
    elseif selectedMenu == 2 then 
        local w, h = 330, 320
        local x, y = sx/2 - w/2, sy/2 - h/2 

        dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText('ATM', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

        hover = nil
        if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
            hover = 2

            dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
        else 
            dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
        end 

        --[[
            Amount
        ]]
        local w2, h2 = 150, 20

        dxDrawText('Összeg:', x + 23, y + 51, x + 23, y + 51 + h2 + 4,tocolor(242, 242, 242, alpha),1,font3,"left","center")
        dxDrawRectangle(x + w/2 - w2/2, y + 51, w2, h2, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(moneyText, x + w/2 - w2/2 + 5, y + 51, x + w/2 + w2/2, y + 51 + h2 + 4,tocolor(242, 242, 242, alpha),1,font2,"left","center")

        --[[
            Pinpanel
        ]]

        local w2, h2 = 58, 50
        local rw2, rh2 = 38, 30

        pinHover = nil 
        local count = 1
        local startX, startY = x + 101, y + 85
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
                    dxDrawImage(startX + rw2/2 - 17/2, startY + rh2/2 - 12/2, 17, 12, backspaceTex, 0, 0, 0, tocolor(242, 242, 242, alpha))
                else 
                    dxDrawText(text, startX, startY, startX + rw2, startY + rh2 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
                end
            else 
                dxDrawImage(startX + rw2/2 - w2/2, startY + rh2/2 - h2/2, w2, h2, 'assets/images/pin-button.png', 0, 0, 0, tocolor(23, 23, 23, alpha * 0.9))
                if text == 'backspace' then 
                    dxDrawImage(startX + rw2/2 - 17/2, startY + rh2/2 - 12/2, 17, 12, backspaceTex, 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
                else 
                    dxDrawText(text, startX, startY, startX + rw2, startY + rh2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
                end 
            end 

            count = count + 1
            startX = startX + rw2 + 10
            if count > 3 then 
                count = 1 
                startX = _startX 
                startY = startY + rh2 + 10
            end 
        end 

        --[[
            Money Amount
        ]]
        local colorCode = exports['cr_core']:getServerColor("red", true)
        local green = exports['cr_core']:getServerColor("green", true)
        local moneyColorCode = colorCode
        if tonumber(bank_accounts[gId][4] or 0) >= 0 then 
            moneyColorCode = green
        end 

        dxDrawText('Számla egyenleg:\n' .. moneyColorCode .. '$ ' .. bank_accounts[gId][4], x,y+230,x+w,y+283 + 4,tocolor(242, 242, 242, alpha),1,font4,"center","center", false, false, false, true)

        --[[
            Buttons
        ]]
        local w2, h2 = 150, 20

        y = y + 283
        if exports['cr_core']:isInSlot(x + w/2 - w2/2, y, w2, h2) then 
            hover = 1

            dxDrawRectangle(x + w/2 - w2/2, y, w2, h2, tocolor(97, 177, 90, alpha))
            dxDrawText('Pénz felvétel', x, y, x + w, y + h2 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
        else 
            dxDrawRectangle(x + w/2 - w2/2, y, w2, h2, tocolor(97, 177, 90, alpha * 0.7))
            dxDrawText('Pénz felvétel', x, y, x + w, y + h2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
        end
    elseif selectedMenu == 3 then 
        local w, h = 330, 320
        local x, y = sx/2 - w/2, sy/2 - h/2 

        dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText('ATM', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

        hover = nil
        if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
            hover = 2

            dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
        else 
            dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
        end 

        --[[
            Amount
        ]]
        local w2, h2 = 150, 20

        dxDrawText('Összeg:', x + 23, y + 51, x + 23, y + 51 + h2 + 4,tocolor(242, 242, 242, alpha),1,font3,"left","center")
        dxDrawRectangle(x + w/2 - w2/2, y + 51, w2, h2, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(moneyText, x + w/2 - w2/2 + 5, y + 51, x + w/2 + w2/2, y + 51 + h2 + 4,tocolor(242, 242, 242, alpha),1,font2,"left","center")

        --[[
            Pinpanel
        ]]

        local w2, h2 = 58, 50
        local rw2, rh2 = 38, 30

        pinHover = nil 
        local count = 1
        local startX, startY = x + 101, y + 85
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
                    dxDrawImage(startX + rw2/2 - 17/2, startY + rh2/2 - 12/2, 17, 12, backspaceTex, 0, 0, 0, tocolor(242, 242, 242, alpha))
                else 
                    dxDrawText(text, startX, startY, startX + rw2, startY + rh2 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
                end
            else 
                dxDrawImage(startX + rw2/2 - w2/2, startY + rh2/2 - h2/2, w2, h2, 'assets/images/pin-button.png', 0, 0, 0, tocolor(23, 23, 23, alpha * 0.9))
                if text == 'backspace' then 
                    dxDrawImage(startX + rw2/2 - 17/2, startY + rh2/2 - 12/2, 17, 12, backspaceTex, 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
                else 
                    dxDrawText(text, startX, startY, startX + rw2, startY + rh2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
                end 
            end 

            count = count + 1
            startX = startX + rw2 + 10
            if count > 3 then 
                count = 1 
                startX = _startX 
                startY = startY + rh2 + 10
            end 
        end 

        --[[
            Money Amount
        ]]
        local colorCode = exports['cr_core']:getServerColor("red", true)
        local green = exports['cr_core']:getServerColor("green", true)
        local moneyColorCode = colorCode
        if tonumber(bank_accounts[gId][4] or 0) >= 0 then 
            moneyColorCode = green
        end 

        dxDrawText('Számla egyenleg:\n' .. moneyColorCode .. '$ ' .. bank_accounts[gId][4], x,y+230,x+w,y+283 + 4,tocolor(242, 242, 242, alpha),1,font4,"center","center", false, false, false, true)

        --[[
            Buttons
        ]]
        local w2, h2 = 150, 20

        y = y + 283
        if exports['cr_core']:isInSlot(x + w/2 - w2/2, y, w2, h2) then 
            hover = 1

            dxDrawRectangle(x + w/2 - w2/2, y, w2, h2, tocolor(97, 177, 90, alpha))
            dxDrawText('Befizetés', x, y, x + w, y + h2 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
        else 
            dxDrawRectangle(x + w/2 - w2/2, y, w2, h2, tocolor(97, 177, 90, alpha * 0.7))
            dxDrawText('Befizetés', x, y, x + w, y + h2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
        end

        --[[
        local w, h = 300, 280
        local x, y = sx/2 - w/2, sy/2 - h/2 
        dxDrawRectangle(x, y, w, h, tocolor(44, 44, 44, alpha))
        local h2 = 25
        dxDrawRectangle(x, y, w, h2, tocolor(0, 0, 0, alpha * 0.3))
        exports['cr_dx']:dxDrawTextAwesome(color .. "", color.."ATM", x + w/2, y + h2/2, x + w/2, y + h2/2, tocolor(255, 255, 255, alpha), tocolor(255, 255, 255, alpha), 1, 1, font, awesomeFont, 5)
        y = y + h2 
        local blue = exports['cr_core']:getServerColor("blue", true)
        dxDrawText(color .. "Számla egyenlege: " .. blue .. bank_accounts[gId][4] .. " $", x, y, x + w, y + 19, tocolor(255, 255, 255, alpha), 1, font, "center", "center", false, false, false, true)
        y = y + 19 

        local _w2 = w 
        local w2, h2 = 294, 27
        local _x = x
        local x = x + _w2/2 - w2/2
        pinHover = nil 
        dxDrawRectangle(x, y, w2, h2, tocolor(0,0,0,alpha * 0.3))
        dxDrawText(color .. "Összeg:", x + 5, y, x + w2, y + h2, tocolor(255, 255, 255, alpha), 1, font, "left", "center", false, false, false, true)
        dxDrawText(color .. moneyText, x, y, x + w2, y + h2, tocolor(255, 255, 255, alpha), 1, font, "center", "center", false, false, false, true)
        local w3, h3 = 17, 13
        if exports['cr_core']:isInSlot(x + w2 - 5 - w3, y + h2/2 - h3/2, w3, h3) then 
            pinHover = "backspace"
            local r,g,b = exports['cr_core']:getServerColor("red")
            dxDrawImage(x + w2 - 5 - w3, y + h2/2 - h3/2, w3, h3, "assets/images/backspace.png", 0, 0, 0, tocolor(r, g, b, alpha))
        else 
            dxDrawImage(x + w2 - 5 - w3, y + h2/2 - h3/2, w3, h3, "assets/images/backspace.png", 0, 0, 0, tocolor(130, 130, 130, alpha * 0.5))
        end 

        y = y + h2 + 2

        local startX, startY = x + _w2/2 - (((35 * 3) + (2 * 2))/2), y 
        local _startX = startX 
        local count = 1
        local w2, h2 = 35, 35 
        for i = 1, 12 do 
            local text = i 
            if text == 10 then text = "X" elseif text == 11 then text = "0" elseif text == 12 then text = "*" end
            local inSlot = exports['cr_core']:isInSlot(startX, startY, w2, h2)
            if inSlot or getKeyState(text) then 
                if inSlot then 
                    pinHover = i
                end 
                local r,g,b = exports['cr_core']:getServerColor("blue")
                dxDrawRectangle(startX, startY, w2, h2, tocolor(r,g,b,alpha))
                dxDrawText(text, startX, startY, startX + w2, startY + h2, tocolor(0, 0, 0, alpha), 1, font, "center", "center", false, false, false, true)
            else 
                dxDrawRectangle(startX, startY, w2, h2, tocolor(0,0,0,alpha * 0.3))
                dxDrawText(color .. text, startX, startY, startX + w2, startY + h2, tocolor(255, 255, 255, alpha), 1, font, "center", "center", false, false, false, true)
            end 

            count = count + 1
            startX = startX + w2 + 2
            if count > 3 then 
                count = 1 
                startX = _startX 
                startY = startY + h2 + 2
            end 
        end 

        y = y + ((35 * 4) + (2 * 3)) + 3
        x = _x

        local h3 = 25
        hover = nil 
        if exports['cr_core']:isInSlot(x + 3, y, w - 6, h3) then 
            hover = 1
            local r,g,b = exports['cr_core']:getServerColor("blue")
            dxDrawRectangle(x + 3, y, w - 6, h3, tocolor(r,g,b, alpha))
            exports['cr_dx']:dxDrawTextAwesome("", "Befizetés", x + w/2, y + h3/2, x + w/2, y + h3/2, tocolor(0, 0, 0, alpha), tocolor(0, 0, 0, alpha), 1, 1, font, awesomeFont, 5)
        else 
            dxDrawRectangle(x + 3, y, w - 6, h3, tocolor(0, 0, 0, alpha * 0.3))
            exports['cr_dx']:dxDrawTextAwesome(color .. "", color .. "Befizetés", x + w/2, y + h3/2, x + w/2, y + h3/2, tocolor(255, 255, 255, alpha), tocolor(255, 255, 255, alpha), 1, 1, font, awesomeFont, 5)
        end 

        y = y + h3 + 2

        if exports['cr_core']:isInSlot(x + 3, y, w - 6, h3) then 
            hover = 2
            local r,g,b = exports['cr_core']:getServerColor("red")
            dxDrawRectangle(x + 3, y, w - 6, h3, tocolor(r,g,b, alpha))
            exports['cr_dx']:dxDrawTextAwesome("", "Mégse", x + w/2, y + h3/2, x + w/2, y + h3/2, tocolor(0, 0, 0, alpha), tocolor(0, 0, 0, alpha), 1, 1, font, awesomeFont, 5)
        else 
            dxDrawRectangle(x + 3, y, w - 6, h3, tocolor(0, 0, 0, alpha * 0.3))
            exports['cr_dx']:dxDrawTextAwesome(color .. "", color .. "Mégse", x + w/2, y + h3/2, x + w/2, y + h3/2, tocolor(255, 255, 255, alpha), tocolor(255, 255, 255, alpha), 1, 1, font, awesomeFont, 5)
        end ]]
    end 
end 