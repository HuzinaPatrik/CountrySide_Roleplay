local hover, isRender
local lastCall = -1
local lastCallTick = -5000
function openRequestPanel(a)
    if not isRender then 
        isRender = true 

        local now = getTickCount()
        if now <= lastCallTick + 1000 then
            cancelLatentEvent(lastCall)
        end 
        main = a
        triggerLatentServerEvent("generateRandomCardNumber", 5000, false, localPlayer, localPlayer)
        lastCall = getLatentEventHandles()[#getLatentEventHandles()] 
        lastCallTick = getTickCount()
    end 
end 

addEvent("resultCardNumber", true)
addEventHandler("resultCardNumber", localPlayer, 
    function(e, num)
        cardnumber = num 
        formattedCardNumber = formatCardNumber(num)
        exports['cr_dx']:startFade("bank >> requestPanel", 
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
        createRender("renderBankRequestPanel", renderBankRequestPanel)

        bindKey("enter", "down", enterInteraction)
        bindKey("backspace", "down", closeRequestPanel)

        addEventHandler("onClientClick", root, onClick)
    end 
)

function closeRequestPanel()
    if isRender then 
        isRender = false 

        exports['cr_dx']:startFade("bank >> requestPanel", 
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
        unbindKey("backspace", "down", closeRequestPanel)
        removeEventHandler("onClientClick", root, onClick)
    end 
end 

sx, sy = guiGetScreenSize()
function renderBankRequestPanel()
    local alpha, progress = exports['cr_dx']:getFade("bank >> requestPanel")
    if not isRender then 
        if progress >= 1 then 
            destroyRender("renderBankRequestPanel")
            return 
        end  
    end 

    if getDistanceBetweenPoints3D(gPed.position, localPlayer.position) > 3 then 
        closeRequestPanel()
    end 

    --[[
        BG
    ]]
    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 14)
    local font3 = exports['cr_fonts']:getFont('Poppins-Medium', 10)

	local w, h = 325, 250
	local x, y = sx/2 - w/2, sy/2 - h/2

    hover = nil

	dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
	dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	dxDrawText('Új számla igénylése', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

	if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
        hover = 2

        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
    else 
        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
    end 

    --[[
        Icon + Text
    ]]
    dxDrawImage(x + w/2 - 70/2, y + 45, 70, 70, "assets/images/requestIcon.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    local orange = exports['cr_core']:getServerColor("red", true)
    local text = color .. "Számlaszámod: " .. orange .. formattedCardNumber .. color .. "\nPinkód (alapértelmezett): " .. orange .. "1234"
    dxDrawText(text, x + 40, y + 130, x + 40, y + 130, tocolor(242, 242, 242, alpha), 1, font2, "left", "top", false, false, false, true)
    dxDrawText('Kérlek első belépés után változtasd meg a pinkódod!', x + 40, y + 180, x + 40, y + 180, tocolor(242, 242, 242, alpha), 1, font3, "left", "top", false, false, false, true)

    --[[
        Button
    ]]
    if exports['cr_core']:isInSlot(x + 13, y + 215, 300, 20) then 
        hover = 1

        dxDrawRectangle(x + 13, y + 215, 300, 20, tocolor(97, 177, 90, alpha))
        dxDrawText('Számla igénylés', x + 13, y + 215, x + 13 + 300, y + 215 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
    else 
        dxDrawRectangle(x + 13, y + 215, 300, 20, tocolor(97, 177, 90, alpha * 0.7))
        dxDrawText('Számla igénylés', x + 13, y + 215, x + 13 + 300, y + 215 + 20 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
    end 
end 

function onClick(b, s)
    if isRender then 
        if b == "left" and s == "down" then 
            if tonumber(hover) then 
                if hover == 1 then 
                    enterInteraction()
                elseif hover == 2 then 
                    closeRequestPanel()
                end 
                hover = nil 
            end 
        end 
    end 
end 

local lastCall = -1
local lastCallTick = -5000
function enterInteraction()
    if isRender then 
        if exports['cr_network']:getNetworkStatus() then 
            return 
        end 
        
        local now = getTickCount()
        if now <= lastCallTick + 2500 then
            cancelLatentEvent(lastCall)
        end 
        exports['cr_infobox']:addBox("success", "Sikeres igényelés!")
        triggerLatentServerEvent("createNewCard", 5000, false, localPlayer, localPlayer, cardnumber, tonumber(main or 1))
        lastCall = getLatentEventHandles()[#getLatentEventHandles()] 
        lastCallTick = getTickCount()
        closeRequestPanel()
    end 
end 