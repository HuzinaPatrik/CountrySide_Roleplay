local isRender, gMarker, selected, selected2

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        for k,v in pairs(markerPositions) do 
            local x,y,z,dim,int,rot = unpack(v)
            
            exports['cr_radar']:createStayBlip("Tuningműhely: "..k, Blip(x, y, z, 0, 2, 255, 0, 0, 255, 0, 0), 0, "tuning_workshop", 24, 24, 255, 255, 255)
        end 
    end
)

addEventHandler("onClientMarkerHit", resourceRoot,
    function(hitPlayer, matchingDimension)
        if source:getData("tuning.marker") then
            if hitPlayer == localPlayer and matchingDimension then 
                if localPlayer.vehicle then                     
                    if not localPlayer.vehicle:getData("veh >> id") or localPlayer.vehicle:getData("veh >> id") < 0 then 
                        exports['cr_infobox']:addBox("error", "Munkakocsival / ideiglenes kocsit nem lehet tuningolni!")
                        return 
                    end

                    if localPlayer.vehicleSeat ~= 0 then 
                        --exports['cr_infobox']:addBox("error", "Csak vezetői ülésben!")
                        return 
                    end 

                    --if localPlayer.vehicle:getData("veh >> owner") == localPlayer:getData("acc >> id") then 
                        if localPlayer.vehicle.vehicleType:lower() ~= ("Automobile"):lower() then 
                            exports['cr_infobox']:addBox("error", "Csak kocsit tuningolhatsz!")
                            return 
                        end 

                        if getDistanceBetweenPoints3D(localPlayer.position, source.position) < 5 then 
                            if not source:getData("tuning.marker.inPlayer") then 
                                triggerLatentServerEvent("enterTuningMarker", 5000, false, localPlayer, localPlayer, source)
                            end 
                        end 
                    --else
                        --exports['cr_infobox']:addBox("error", "Ez nem a te járműved!")
                    --end 
                end 
            end
        end 
    end
)

function getRealFontSize(a)
    local a = a * dxDrawMultipler
    local val = ((a) - math.floor(a))
    if val < 0.5 then
        return math.floor(a)
    elseif val >= 0.5 then
        return math.ceil(a)
    end
end

local fontsize = {12, 14, 15, 22}

function enterTuningMarker(marker)
    if isElement(marker) then 
        if not isRender then 
            gMarker = marker
            isRender = true 
            selected = nil 
            nowSelected = 1
            gSelected = nil
            selected2 = nil 
            gSelected2 = 1
            isCursorInPanel = false

            exports['cr_controls']:toggleAllControls(false, 4)
            oData = {
                ["hudVisible"] = localPlayer:getData("hudVisible"),
                ["keysDenied"] = localPlayer:getData("keysDenied"),
                ["chat"] = exports['cr_custom-chat']:isChatVisible(),
            }

            if not realFontSize then 
                realFontSize = {}

                for k,v in ipairs(fontsize) do 
                    realFontSize[v] = getRealFontSize(v)
                end 
            end 
            
            localPlayer:setData("hudVisible", false)
            localPlayer:setData("keysDenied", true)
            exports['cr_custom-chat']:showChat(false)
            addEventHandler("onClientClick", root, onTuningMenuClick)
            bindKey("backspace", "down", exitTuningMarker)
            bindKey("enter", "down", onEnter)
            bindKey("arrow_u", "down", upMove)
            bindKey("arrow_d", "down", downMove)
            bindKey("arrow_l", "down", leftMove)
            bindKey("arrow_r", "down", rightMove)

            getVehicleStatistic(localPlayer.vehicle)
            getPlayerDatas()

            if isTimer(viewerTimer) then 
                killTimer(viewerTimer)
            end 

            viewerTimer = setTimer(
                function() 
                    setupViewer(localPlayer.vehicle)
                    cameraInit(true)
                end, 500, 1
            )

            exports['cr_dx']:startFade("tuningPanel", 
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
            createRender("renderTuningPanel", renderTuningPanel)
        end 
    end 
end 
addEvent("enterTuningMarker", true)
addEventHandler("enterTuningMarker", localPlayer, enterTuningMarker)

function exitTuningMarker()
    if isBuyRender then 
        destroyBuy()
    elseif isPickerRender then 
        destroyPicker()
    elseif isSelectorRender then 
        destroySelector()
    elseif isRender then
        if tonumber(gSelected) then 
            gSelected = nil 
        else 
            isRender = false 
            gMarker = nil
            isCursorInPanel = false

            exports['cr_controls']:toggleAllControls(true, 4)
            localPlayer:setData("hudVisible", oData["hudVisible"])
            localPlayer:setData("keysDenied", oData["keysDenied"])
            exports['cr_custom-chat']:showChat(oData["chat"])
            oData = nil

            removeEventHandler("onClientClick", root, onTuningMenuClick)
            unbindKey("backspace", "down", exitTuningMarker)
            unbindKey("enter", "down", onEnter)
            unbindKey("arrow_u", "down", upMove)
            unbindKey("arrow_d", "down", downMove)
            unbindKey("arrow_l", "down", leftMove)
            unbindKey("arrow_r", "down", rightMove)
            triggerLatentServerEvent("exitTuningMarker", 5000, false, localPlayer, localPlayer)

            if isTimer(viewerTimer) then 
                killTimer(viewerTimer)
            else 
                cameraInit(false)
            end 

            exports['cr_dx']:startFade("tuningPanel", 
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
end
addEventHandler("onClientResourceStop", resourceRoot, exitTuningMarker)

function onEnter()
    if isBuyRender then 
        buyEnter()
    elseif isPickerRender then 
        if pickerData["onEnter"] then 
            pickerData["onEnter"]()
        end 
    elseif isSelectorRender then 
        if selectorCache["onEnter"] then 
            selectorCache["onEnter"]()
        end 
    elseif isRender then 
        if not gSelected then 
            if isSelectorRender or isBuyRender or isPickerRender then 
                return 
            end 

            gSelected = tonumber(nowSelected)
            playSound("files/sounds/menunavigate.mp3")
            gSelected2 = 1

            if buttons[gSelected]["onClick"] then 
                buttons[gSelected]["onClick"]()
            end 
        else 
            if buttons[gSelected]["buttons"] then 
                if buttons[gSelected]["buttons"][gSelected2] then 
                    if buttons[gSelected]["buttons"][gSelected2]["onEnter"] then 
                        buttons[gSelected]["buttons"][gSelected2]["onEnter"]()
                    end 
                end 
            end 
        end 
    end 
end 

sx, sy = guiGetScreenSize()
dxDrawMultipler = math.min(1.25, sx / 1600)

addCommandHandler('dxTest', 
    function(cmd, a)
        dxDrawMultipler = tonumber(a)
    end 
)

function respc(a)
    return a * dxDrawMultipler
end 

function renderTuningPanel()
    local alpha, progress = exports['cr_dx']:getFade("tuningPanel")
    if not isRender then 
        if progress >= 1 then 
            nowSelected = nil
            gSelected = nil 
            selected = nil 
            selected2 = nil

            destroyVehicleStatisticData()
            destroyPlayerDatas()
            destroyRender("renderTuningPanel")
            return 
        end  
    end 

    if not localPlayer.vehicle then 
        exitTuningMarker()
    end 

    local nowTick = getTickCount()
    isCursorInPanel = nil 

    --[[
        Fonts
    ]]

    local font = exports['cr_fonts']:getFont('Poppins-Bold', realFontSize[22])
    local font2 = exports['cr_fonts']:getFont('Poppins-Bold', realFontSize[15])
    local font3 = exports['cr_fonts']:getFont('Poppins-Bold', realFontSize[12])

    --[[
        Money
    ]]

    local startY = respc(10)

	local hexCode = '#61b15a'
	if datas["char >> money"] < 0 then 
		hexCode = '#FF3B3B'
	end 
	local moneyText = hexCode .. "$ "..datas["char >> money"]
	local tWidth = dxGetTextWidth(moneyText, 1, font2, true) + respc(20)
	local tHeight = dxGetFontHeight(1, font2)
	dxDrawRectangle(sx - respc(20) - tWidth, startY, tWidth, tHeight, tocolor(51, 51, 51, alpha * 0.8))
    if exports['cr_core']:isInSlot(sx - respc(20) - tWidth, startY, tWidth, tHeight) then 
        isCursorInPanel = true
    end 
	dxDrawText(moneyText, sx - respc(20) - tWidth, startY, sx - respc(20) - tWidth + tWidth, startY + tHeight + respc(4), tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, false, false, true)

	startY = startY + tHeight + respc(1)

	local bankMoney = exports['cr_bank']:getBankAccountMoney(localPlayer)
	local hexCode = exports['cr_core']:getServerColor('yellow', true)
	local r,g,b = exports['cr_core']:getServerColor('yellow')
	if bankMoney < 0 then 
		hexCode = '#FF3B3B'
	end 
	local moneyText = hexCode .. "$ "..bankMoney
	local tWidth = dxGetTextWidth(moneyText, 1, font2, true) + respc(20) + respc(20)
	local tHeight = dxGetFontHeight(1, font2)
	dxDrawRectangle(sx - respc(20) - tWidth, startY, tWidth, tHeight, tocolor(51, 51, 51, alpha * 0.8))
    if exports['cr_core']:isInSlot(sx - respc(20) - tWidth, startY, tWidth, tHeight) then 
        isCursorInPanel = true
    end 
	exports['cr_dx']:dxDrawImageWithText(":cr_carshop/files/imgs/cardIcon.png", moneyText, sx - respc(20) - tWidth + tWidth/2, startY, sx - respc(20) - tWidth + tWidth, startY + tHeight + respc(4), tocolor(r,g,b, alpha), tocolor(242, 242, 242, alpha), 20, 15, 1, font2, 5, -2)

	startY = startY + tHeight + respc(1)

	local premiumPoints = datas["char >> premiumPoints"]
	local hexCode = exports['cr_core']:getServerColor('orange', true)
	if premiumPoints < 0 then 
		hexCode = '#FF3B3B'
	end 
	local moneyText = hexCode .. premiumPoints .. " PP"
	local tWidth = dxGetTextWidth(moneyText, 1, font2, true) + respc(20)
	local tHeight = dxGetFontHeight(1, font2)
	dxDrawRectangle(sx - respc(20) - tWidth, startY, tWidth, tHeight, tocolor(51, 51, 51, alpha * 0.8))
    if exports['cr_core']:isInSlot(sx - respc(20) - tWidth, startY, tWidth, tHeight) then 
        isCursorInPanel = true
    end 
	dxDrawText(moneyText, sx - respc(20) - tWidth, startY, sx - respc(20) - tWidth + tWidth, startY + tHeight + respc(4), tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, false, false, true)

    --[[
        Stats
    ]]

    --[[Stats BG]]
    local w, h = respc(400), respc(340)
	local x, y = sx - w - respc(20), sy/2 - h/2 - respc(170)
	dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
    if exports['cr_core']:isInSlot(x, y, w, h) then 
        isCursorInPanel = true
    end 
	dxDrawRectangle(x, y, w, respc(1), tocolor(255, 59, 59, alpha))
	dxDrawRectangle(x, y + h - respc(1), w, respc(1), tocolor(255, 59, 59, alpha))

    local brandName = exports['cr_carshop']:getVehicleBrand(localPlayer.vehicle)

	dxDrawText(brandName, x + respc(30), y + respc(30), x + respc(30), y + respc(30), tocolor(242, 242, 242, alpha), 1, font, "left", "top")
	dxDrawText(exports["cr_vehicle"]:getVehicleName(localPlayer.vehicle):gsub(brandName .. ' ', ''), x + respc(30), y + respc(55), x + respc(30), y + respc(55), tocolor(242, 242, 242, alpha), 1, font2, "left", "top")

    --[[Stats Bars]]
    local startY = y + respc(95)

    for k,v in pairs(statistic) do 
        if statisticDetails[k.."Animation"] then
            local startTick = statisticDetails[k.."AnimationTick"]
            local endTick = startTick + 250
            
            local elapsedTime = nowTick - startTick
            local duration = 2500
            local progress = elapsedTime / duration
            local alph = interpolateBetween(
                statisticDetails["real"..k], 0, 0,
                statisticDetails[k], 0, 0,
                progress, "InOutQuad"
            )

            statisticDetails["real"..k] = alph
            
            if progress >= 1 then
                statisticDetails[k.."Animation"] = false
            end
            --multipler = alph / 100
        end

        local name = statisticText[k]
        local val = statisticDetails["real"..k]

        dxDrawText(name, x + respc(30), startY, x + respc(30), startY, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")

        dxDrawRectangle(x + respc(30), startY + respc(25), respc(300), respc(15), tocolor(51, 51, 51, alpha * 0.6))
        dxDrawRectangle(x + respc(31), startY + respc(26), respc(298), respc(13), tocolor(242, 242, 242, alpha * 0.6))

        dxDrawRectangle(x + respc(30), startY + respc(25), respc(300) * val, respc(15), tocolor(255, 59, 59, alpha))
	    dxDrawRectangle(x + respc(30) + (respc(300) * val) - 2, startY + respc(23), respc(2), respc(19), tocolor(242, 242, 242, alpha))

        startY = startY + respc(55)
    end 

    --[[
        Menus
    ]]
    selected = nil
    local startX, startY = respc(25), sy - respc(25) - respc(50)

    local _startX, _startY;
    for k,v in pairs(buttons) do 
        local name = v["name"]
        local w2, h2 = gSelected == k and (respc(15) + ((respc(60) + respc(10)) * #buttons[gSelected]["buttons"]) + respc(5)) or (dxGetTextWidth(name, 1, font) + respc(60)), respc(50)
        local inSlot = exports['cr_core']:isInSlot(startX, startY, w2, h2)
        if inSlot then 
            isCursorInPanel = true 
        end 
        dxDrawRectangle(startX, startY, w2, h2, tocolor(0,0,0,alpha * 0.3))       

        if gSelected == k then 
            _startX, _startY = startX, startY
            dxDrawRectangle(startX, startY, w2, h2, tocolor(242, 242, 242, alpha))
            dxDrawText(name, startX + respc(30), startY, startX + respc(30), startY + h2 + respc(4), tocolor(51, 51, 51, alpha), 1, font, "left", "center")
        elseif inSlot or nowSelected == k then 
            if inSlot then 
                selected = "button" .. k
            end 
            
            dxDrawRectangle(startX, startY, w2, h2, tocolor(242, 242, 242, alpha * 0.8))
            dxDrawText(name, startX, startY, startX + w2, startY + h2 + respc(4), tocolor(51, 51, 51, alpha), 1, font, "center", "center")
        else 
            dxDrawRectangle(startX, startY, w2, h2, tocolor(23, 23, 23, alpha * 0.8))
            dxDrawText(name, startX, startY, startX + w2, startY + h2 + respc(4), tocolor(242, 242, 242, alpha), 1, font, "center", "center")
        end 

        startX = startX + w2 + respc(10)
    end 

    --[[Sub Menus]]
    if gSelected then 
        if buttons[gSelected]["buttons"] then 
            local w, h = (respc(15) + ((respc(60) + respc(10)) * #buttons[gSelected]["buttons"]) + respc(5)), respc(130)

            local x, y = _startX, _startY - h

            dxDrawRectangle(x, y, w, h, tocolor(23, 23, 23, alpha * 0.6))
            if exports['cr_core']:isInSlot(x, y, w, h) then 
                isCursorInPanel = true
            end 

            local startX, startY = x + respc(15), y + respc(15)

            for k, v in pairs(buttons[gSelected]["buttons"]) do 
                local name;
                local imagePath = v["imagePath"]
                local w2, h2 = respc(60), respc(100)
                local specialY
    
                if isSelectorRender then 
                    if k == gSelected2 then 
                        if selectorCache["gSelected2"] == gSelected2 then 
                            updateSelectorPosition(startX + w2/2, y)

                            specialY = true
                        end 
                    end
                end 

                if v['tuningName'] then 
                    name = tonumber((localPlayer.vehicle:getData("veh >> tuningData") or {})[v['tuningName']] or 1)

                    if v['tuningName'] == 'driveType' then 
                        name = tonumber((localPlayer.vehicle:getData("veh >> tuningData") or {})[v['tuningName']] or (getVehicleHandling(localPlayer.vehicle)["driveType"] == "fwd" and 1 or getVehicleHandling(localPlayer.vehicle)["driveType"] == "awd" and 2 or getVehicleHandling(localPlayer.vehicle)["driveType"] == "rwd" and 3))
                    end 
                end 
    
                if gSelected2 == k then 
                    dxDrawRectangle(startX, startY, w2, h2, tocolor(242,242,242,alpha))
                    exports['cr_dx']:dxDrawImageAsTexture(startX + respc(2), startY + respc(2), w2 - respc(4), h2 - respc(4), ':cr_tuning/' .. imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha))

                    if name then 
                        dxDrawRectangle(startX + respc(2), startY + h2 - respc(2) - respc(20), w2 - respc(4), respc(20), tocolor(51,51,51,alpha * 0.8))
                        dxDrawText(name, startX, startY + h2 - respc(2) - 20, startX + w2, startY + h2 - respc(2) + respc(4), tocolor(242, 242, 242, alpha), 1, font3, "center", "center", false, true)
                    end

                    local y = y;
                    if specialY then 
                        y = y - respc(195)
                    end 
                    local tWidth = dxGetTextWidth(v['name'], 1, font3) + respc(40)
                    dxDrawRectangle(startX + w2/2 - tWidth/2, y - respc(20) - respc(15), tWidth, 20, tocolor(242, 242, 242))
                    dxDrawText(v['name'], startX, y - respc(20) - respc(15), startX + w2, y - respc(20) - respc(15) + respc(20) + respc(4), tocolor(51, 51, 51, alpha), 1, font3, "center", "center")
                elseif exports['cr_core']:isInSlot(startX, startY, w2, h2) then 
                    selected2 = "button" .. k
    
                    dxDrawRectangle(startX, startY, w2, h2, tocolor(242,242,242,alpha))
                    exports['cr_dx']:dxDrawImageAsTexture(startX + respc(2), startY + respc(2), w2 - respc(4), h2 - respc(4), ':cr_tuning/' .. imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha))

                    if name then 
                        dxDrawRectangle(startX + respc(2), startY + h2 - respc(2) - respc(20), w2 - respc(4), respc(20), tocolor(51,51,51,alpha * 0.8))
                        dxDrawText(name, startX, startY + h2 - respc(2) - respc(20), startX + w2, startY + h2 - respc(2) + respc(4), tocolor(242, 242, 242, alpha), 1, font3, "center", "center", false, true)
                    end 
                    --dxDrawImage(startX, startY + h/2 - h2/2, w2, h2, imagePath, 0, 0, 0, tocolor(0, 0, 0, alpha))
                else 
                    dxDrawRectangle(startX, startY, w2, h2, tocolor(242,242,242,alpha * 0.4))
                    exports['cr_dx']:dxDrawImageAsTexture(startX + respc(2), startY + respc(2), w2 - respc(4), h2 - respc(4), ':cr_tuning/' .. imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha * 0.4))

                    if name then 
                        dxDrawRectangle(startX + respc(2), startY + h2 - respc(2) - respc(20), w2 - respc(4), respc(20), tocolor(51,51,51,alpha * 0.8 * 0.4))
                        dxDrawText(name, startX, startY + h2 - respc(2) - respc(20), startX + w2, startY + h2 - respc(2) + respc(4), tocolor(242, 242, 242, alpha * 0.6 * 0.4), 1, font3, "center", "center", false, true)
                    end
                    --dxDrawImage(startX, startY + h/2 - h2/2, w2, h2, imagePath, 0, 0, 0, tocolor(130, 130, 130, alpha))
                end 
    
                startX = startX + w2 + respc(10)
            end 
        end 
    end
end  

function onTuningMenuClick(b, s)
    if isRender then 
        if b == "left" and s == "down" then 
            if selected then 
                if selected:sub(1, 6) == "button" then 
                    if isSelectorRender or isBuyRender or isPickerRender then 
                        return 
                    end 

                    local num = tonumber(selected:sub(7, #selected))
                    if buttons[num]["onClick"] then 
                        buttons[num]["onClick"]()
                    end 
                    gSelected = num
                    playSound("files/sounds/menunavigate.mp3")
                    gSelected2 = 1
                    selected = nil 
                    nowSelected = num
                    
                    return
                end 
            elseif selected2 then 
                if selected2:sub(1, 6) == "button" then 
                    if isSelectorRender or isBuyRender or isPickerRender then 
                        return 
                    end 

                    local num = tonumber(selected2:sub(7, #selected2))
                    if buttons[gSelected]["buttons"][num]["onClick"] then 
                        buttons[gSelected]["buttons"][num]["onClick"]()
                    end 
                    gSelected2 = num
                    playSound("files/sounds/menunavigate.mp3")
                    selected2 = nil 
                    
                    return
                end 
            end 
        end 
    end 
end 

function upMove()
    if isBuyRender then 
        return
    elseif isPickerRender then 
        return 
    elseif isSelectorRender then 
        return 
    elseif isRender then 
        return
    end 
end 

function downMove()
    if isBuyRender then 
        return
    elseif isPickerRender then 
        return
    elseif isSelectorRender then 
        return 
    elseif isRender then 
        return
    end 
end 

function rightMove()
    if isBuyRender then 
        buyDown()
    elseif isPickerRender then 
        return
    elseif isSelectorRender then 
        selectorNext()
    elseif isRender then 
        if not gSelected then 
            if nowSelected + 1 <= #buttons then 
                if isSelectorRender or isBuyRender or isPickerRender then 
                    return 
                end 
    
                nowSelected = nowSelected + 1 
                playSound("files/sounds/menunavigate.mp3")
            end 
        elseif buttons[gSelected]["buttons"] then 
            if gSelected2 + 1 <= #buttons[gSelected]["buttons"] then 
                if isSelectorRender or isBuyRender or isPickerRender then 
                    return 
                end 

                gSelected2 = gSelected2 + 1
                playSound("files/sounds/menunavigate.mp3")

                if buttons[gSelected]["buttons"][gSelected2]["onClick"] then 
                    buttons[gSelected]["buttons"][gSelected2]["onClick"]()
                end 
            end 
        end
    end 
end 

function leftMove()
    if isBuyRender then 
        buyUp()
    elseif isPickerRender then 
        return 
    elseif isSelectorRender then 
        selectorBack()
    elseif isRender then 
        if not gSelected then 
            if nowSelected - 1 > 0 then 
                if isSelectorRender or isBuyRender or isPickerRender then 
                    return 
                end 
    
                nowSelected = nowSelected - 1 
                playSound("files/sounds/menunavigate.mp3")
            end 
        elseif gSelected2 - 1 > 0 then 
            if isSelectorRender or isBuyRender or isPickerRender then 
                return 
            end 

            gSelected2 = gSelected2 - 1
            playSound("files/sounds/menunavigate.mp3")

            if buttons[gSelected]["buttons"][gSelected2]["onClick"] then 
                buttons[gSelected]["buttons"][gSelected2]["onClick"]()
            end 
        end 
    end 
end

--
function shadowedText(text,x,y,w,h,color,fontisze,font,alignX,alignY,alpha)
    dxDrawText(text,x, y+1, w, h+1, tocolor(0,0,0,alpha * 0.5), fontsize, font, alignX, alignY, false, false, false, true)
    dxDrawText(text,x, y-1, w, h-1, tocolor(0,0,0,alpha * 0.5), fontsize, font, alignX, alignY, false, false, false, true)
    dxDrawText(text,x-1, y, w-1, h, tocolor(0,0,0,alpha * 0.5), fontsize, font, alignX, alignY, false, false, false, true)
    dxDrawText(text,x+1, y, w+1, h, tocolor(0,0,0,alpha * 0.5), fontsize, font, alignX, alignY, false, false, false, true)
    dxDrawText(text,x, y, w, h, color, fontsize, font, alignX, alignY, false, false, false, true)
end 
