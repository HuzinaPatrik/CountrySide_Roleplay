local maxDistNearby = 18
function getNearbyShopNPCS(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "getnearbyshopnpc") then
        local target = false
        local px, py, pz = getElementPosition(localPlayer)
        local green = exports['cr_core']:getServerColor("orange", true)
        local syntax = exports['cr_core']:getServerSyntax("Shop", "info")
        local white = "#ffffff"
        local hasVeh = false
        for k,v in pairs(getElementsByType("ped", root, true)) do
            local x,y,z = getElementPosition(v)
            local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
            if dist <= maxDistNearby then
                local id = getElementData(v, "shop >> id") or 0
                if id > 0 then
                    local model = getElementModel(v)
                    local name = v:getData("ped.name")
                    outputChatBox(syntax.."Model: "..green..model..white..", ID: "..green..id..white..", Név: "..green..name..white..", Távolság: "..green..math.floor(dist)..white.." yard", 255,255,255,true)
                    hasVeh = true
                end
            end
        end
        if not hasVeh then
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax("Shop", "error")
            outputChatBox(syntax .. "Nincs shop npc a közeledben!", 255,255,255,true)
        end
    end
end
addCommandHandler("getnearbyshopnpc", getNearbyShopNPCS)
addCommandHandler("getnearbyShopnpc", getNearbyShopNPCS)
addCommandHandler("getNearbyShopNpc", getNearbyShopNPCS)
addCommandHandler("getnearbyShopnpc", getNearbyShopNPCS)

local minLines, maxLines, _maxLines
local isRender, gPed, type, w, h

function getPed()
    return gPed
end 

local function onClick(b, s)
    if isRender then 
        if b == "left" and s == "down" then 
            if closeHover then 
                closeShopPanel()
                closeHover = nil 
            elseif ScrollingHover then
                Scrolling = true
                ScrollingHover = false
            elseif tonumber(buttonHover) then 
                if not exports['cr_dashboard']:isAlertsActive() then 
                    local data = items[tonumber(buttonHover)]

                    if shopSearchCache then
                        data = shopSearchCache[tonumber(buttonHover)]
                    end

                    if data then 
                        closeShopPanel()
                        
                        triggerEvent("shop.buyItem", localPlayer, type, data)
                    end 
                end 
                buttonHover = nil 
            end 
        elseif b == "left" and s == "up" then 
            if Scrolling then
                Scrolling = false
            end
        end 
    end 
end 

local function ScrollBarUP()
    if isRender then 
        if ScrollBarHover then
            if minLines - 1 >= 1 then
                playSound(":cr_scoreboard/files/wheel.wav")
                minLines = minLines - 1
                maxLines = maxLines - 1
            end
        end
    end 
end 

local function ScrollBarDown()
    if isRender then 
        if ScrollBarHover then 
            local percent = #items
            if shopSearchCache then
                percent = #shopSearchCache
            end

            if maxLines + 1 <= percent then
                playSound(":cr_scoreboard/files/wheel.wav")
                minLines = minLines + 1
                maxLines = maxLines + 1
            end
        end 
    end 
end 

local function backspaceInteraction()
    if isRender then 
        if not now or now == "" then 
            closeShopPanel()
        end 
    end 
end 

addEventHandler("onClientClick", root, 
    function(b, s, _, _, _, _, _, worldE)
        if b == "right" and s == "down" then 
            if worldE and worldE:getData("shop >> id") then 
                if getDistanceBetweenPoints3D(localPlayer.position, worldE.position) <= 3 then 
                    if not isRender then 
                        isRender = true 
                        gPed = worldE

                        exports['cr_dx']:startFade("shop >> panel", 
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

                        items = gPed:getData("shop >> items") or {}
                        type = tonumber(gPed:getData("shop >> type") or 1)

                        if gPed:getData('shop >> static') then 
                            items = shopTypes[type] or {}
                        end 

                        if #items < 1 then 
                            isRender = false 
                            return 
                        end 

                        resetMinLines()
                        CreateNewBar("Shop >> search", {0, 0, 0, 0}, {25, "", false, tocolor(242, 242, 242, 255), {"Poppins-Medium", 14}, 1, "left", "center", false, true}, 1)

                        Scrolling = false 
                        
                        w = 320
                        createRender("renderShopPanel", renderShopPanel)
                        --exports['cr_dx']:createLogoAnimation("shop", 1, {0, 0, 80, 80}, {10000, 1000})

                        bindKey("backspace", "down", backspaceInteraction)
                        addEventHandler("onClientClick", root, onClick)
                        bindKey("mouse_wheel_up", "down", ScrollBarUP)
                        bindKey("mouse_wheel_down", "down", ScrollBarDown)
                    end 
                end 
            end 
        end 
    end 
)

function resetMinLines()
    local percent = #items
    if shopSearchCache then
        percent = #shopSearchCache
    end

    minLines = 1
    maxLines = math.min(10, percent)
    _maxLines = maxLines
end 

addEventHandler('onClientResourceStart', resourceRoot, 
    function()
        searchTex = dxCreateTexture(":cr_scoreboard/files/search.png", "argb", true, 'clamp')
    end 
)

function closeShopPanel()
    if isRender then 
        isRender = false 

        exports['cr_dx']:startFade("shop >> panel", 
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

        Clear()
        --exports['cr_dx']:stopLogoAnimation("shop")

        exports['cr_dashboard']:clearAlerts()
        destroyFinishPage()
        
        unbindKey("backspace", "down", backspaceInteraction)
        removeEventHandler("onClientClick", root, onClick)
        unbindKey("mouse_wheel_up", "down", ScrollBarUP)
        unbindKey("mouse_wheel_down", "down", ScrollBarDown)
    end 
end 

local sx, sy = guiGetScreenSize()
function renderShopPanel()
    local alpha, progress = exports['cr_dx']:getFade("shop >> panel")
    if not isRender then 
        if progress >= 1 then 
            destroyRender("renderShopPanel")
            return 
        end  
    end 

    if getDistanceBetweenPoints3D(gPed.position, localPlayer.position) > 3 then 
        closeShopPanel()
    end 

    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 14)

    h = 85 + (_maxLines * (40 + 3)) + 9
    local x, y = sx/2 - w/2, sy/2 - h/2

    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
	dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

	dxDrawText(type == 2 and 'Okmányiroda' or "Bolt", x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

    closeHover = nil
	if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
		closeHover = true 

        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
    else 
        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
    end 

    dxDrawRectangle(x + w/2 - (w - 35)/2, y + 50, (w - 35), 20, tocolor(51, 51, 51, alpha * 0.8))
    dxDrawImage(x + w/2 + (w - 35)/2 - 20 , y + 50 + 20/2 - 15/2, 15, 15, searchTex, 0, 0, 0, tocolor(255, 255, 255, alpha))
    UpdatePos("Shop >> search", {x + w/2 - (w - 35)/2 + 5, y + 50 + 2, (w - 35), 20})

    local startY = y + 85

    local nx, ny = x, startY
    local nw, nh = w, math.max(0, (_maxLines * (40 + 3)) - 3)
    ScrollBarHover = exports['cr_core']:isInSlot(nx, ny, nw, nh)
    
    --scrollbar
    local scrollx, scrolly = nx + nw - 8, ny
    local scrollh = nh
    dxDrawRectangle(scrollx, scrolly, 3, scrollh, tocolor(242, 242, 242, alpha * 0.6))

    local percent = #items
    if shopSearchCache then
        percent = #shopSearchCache
    end

    if maxLines > percent then
        minLines = 1
        maxLines = math.min(10, percent)
        _maxLines = maxLines
    end

    if percent >= 1 then
        local gW, gH = 3, scrollh
        local gX, gY = scrollx, scrolly

        ScrollingHover = exports['cr_core']:isInSlot(gX, gY, gW, gH)

        if Scrolling then
            if isCursorShowing() then
                if getKeyState("mouse1") then
                    local cx, cy = exports['cr_core']:getCursorPosition()
                    local cy = math.min(math.max(cy, gY), gY + gH)
                    local y = (cy - gY) / (gH)
                    local num = percent * y
                    minLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _maxLines) + 1)))
                    maxLines = minLines + (_maxLines - 1)
                end
            else
                Scrolling = false
            end
        end

        local multiplier = math.min(math.max((maxLines - (minLines - 1)) / percent, 0), 1)
        local multiplier2 = math.min(math.max((minLines - 1) / percent, 0), 1)
        local gY = gY + ((gH) * multiplier2)
        local gH = gH * multiplier

        local r,g,b = 255, 59, 59
        dxDrawRectangle(gX, gY, gW, gH, tocolor(r,g,b, alpha))
    end

    buttonHover = nil 
    for i = minLines, maxLines do 
        local data = items[i]

        if shopSearchCache then
            data = shopSearchCache[i]
        end
        if data then 
            local itemid, value, nbt, price = unpack(data)
            dxDrawRectangle(x + 15, startY, 40, 40, tocolor(41, 41, 41, alpha))
            dxDrawImage(x + 15 + 1, startY + 1, 39, 39, exports['cr_inventory']:getItemPNG(itemid, value, nbt), 0, 0, 0, tocolor(255, 255, 255, alpha))
            if exports['cr_core']:isInSlot(x + 15, startY, 40, 40) then 
                exports['cr_dx']:drawTooltip(1, "ItemID: " .. itemid)
            end 
            
            dxDrawText(exports['cr_inventory']:getItemName(itemid, value, nbt), x + 15 + 40 + 20, startY + 4, x + 15 + 40 + 20, startY + 4, tocolor(242, 242, 242, alpha * 0.8), 1, font2, "left", "top")
            dxDrawText("Ár: #61b15a$ ".. price, x + 15 + 40 + 20, startY + 20, x + 15 + 40 + 20, startY + 20, tocolor(242, 242, 242, alpha * 0.8), 1, font2, "left", "top", false, false, false, true)

            local textWidth = dxGetTextWidth(exports['cr_inventory']:getItemName(itemid, value, nbt), 1, font2)

            local bw, bh = 125, 25 
            if exports['cr_core']:isInSlot(x + w - bw - 25, startY + 7, bw, bh) then 
                buttonHover = i

                dxDrawRectangle(x + w - bw - 25, startY + 7, bw, bh, tocolor(97, 177, 90, alpha))
                dxDrawText(type == 2 and 'Kivált' or "Vásárlás", x + w - bw - 25, startY + 7, x + w - bw - 25 + bw, startY + 7 + bh + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, false, false, true)
            else 
                dxDrawRectangle(x + w - bw - 25, startY + 7, bw, bh, tocolor(97, 177, 90, alpha * 0.7))
                dxDrawText(type == 2 and 'Kivált' or "Vásárlás", x + w - bw - 25, startY + 7, x + w - bw - 25 + bw, startY + 7 + bh + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center", false, false, false, true)
            end 

            local lineWidth = 15 + 40 + 20 + textWidth + 15 + 125 + 25
            if lineWidth > w then 
                w = lineWidth
            end 

            startY = startY + 40 + 3 
        end 
    end 
end 