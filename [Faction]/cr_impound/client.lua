local screenX, screenY = guiGetScreenSize()
local boxWidth, boxHeight = 500, 223

local cache = {}

local forced = false
local clicked = false
local showing = false

local impoundDatas = false

local impoundPed = Ped(21, 907.70465087891, -1440.5660400391, 13.520354270935)
impoundPed:setData("ped.name", "Jack Monroe")
impoundPed:setData("ped.type", "Lefoglalt járművek")
impoundPed:setData("char >> noDamage", true)

function onKey(button, state)
    if checkRender("renderImpound") then 
        if button == "mouse1" then 
            if state then 
                if scrollingHover then 
                    if not scrolling then 
                        scrolling = true 
                    end
                end

                if hoverButton then 
                    if not showing then 
                        showing = true 
                        impoundDatas = cache[hoverButton]
                        local serverHex = exports["cr_core"]:getServerColor("blue", true)

                        exports["cr_dashboard"]:createAlert(
                            {
                                ["title"] = {"Biztosan ki akarod váltani a járművedet "..serverHex..exports["cr_dx"]:formatMoney(impoundDatas[8]).."#9c9c9c dollárért?"},
                                ["buttons"] = {
                                    {
                                        ["name"] = "Igen", 
                                        ["pressFunc"] = "impound.takeVehicle",
                                        ["onCreate"] = function()
                                        end,
                                        ["color"] = {exports["cr_core"]:getServerColor("blue", false)},
                                    },

                                    {
                                        ["name"] = "Nem", 
                                        ["onClear"] = true,
                                        ["pressFunc"] = "impound.cancelTake",
                                        ["color"] = {exports["cr_core"]:getServerColor("red", false)},
                                    },
                                },
                            }
                        )
                    end

                    hoverButton = nil 
                end

                if closeHover then 
                    if not clicked then 
                        clicked = true 

                        exports["cr_dx"]:startFade("impoundPanel", 
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

                    closeHover = nil 
                end
            else 
                if scrolling then 
                    scrolling = false 
                end
            end
        elseif button == "mouse_wheel_down" then 
            if state then 
                if inBox then 
                    scrollDown()
                end
            end
        elseif button == "mouse_wheel_up" then 
            if state then 
                if inBox then 
                    scrollUP()
                end
            end
        end
    end
end

function onPedClick(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
    if state == "down" then 
        if clickedElement and clickedElement == impoundPed then 
            if getDistanceBetweenPoints3D(localPlayer.position, impoundPed.position) <= 3 then 
                if not checkRender("renderImpound") then
                    triggerLatentServerEvent("impound.getImpoundedVehicles", 5000, false, localPlayer, localPlayer, localPlayer:getData("acc >> id"))

                    createRender("renderImpound", renderImpound)
                    removeEventHandler("onClientKey", root, onKey)
                    addEventHandler("onClientKey", root, onKey)

                    exports["cr_dx"]:startFade("impoundPanel", 
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
    end
end
addEventHandler("onClientClick", root, onPedClick)

function renderImpound()
    if localPlayer:getData("char >> name") ~= "Hugh_Wiley" and localPlayer:getData("char >> name") ~= "Chris_Mckenzie" then 
        return 
    end

    local alpha, progress = exports["cr_dx"]:getFade("impoundPanel")
    if alpha and progress then 
        if progress >= 1 then 
            if alpha <= 0 then 
                destroyRender("renderImpound")
                removeEventHandler("onClientKey", root, onKey)

                cache = {}

                forced = false
                clicked = false
            end
        end
    end

    local r, g, b = exports["cr_core"]:getServerColor("red", false)

    local height2 = 33

    if maxLines > 0 then 
        height = height2 + 1 + ((30 + 1) * ((maxLines - minLines) + 1)) + 3
    else 
        height = height2 + 1 + ((30 + 1) * ((maxLines - minLines) + 1)) + 25
    end

    closeHover = nil 
    if exports["cr_core"]:isInSlot(screenX / 2 + boxWidth / 2 - 15 - 5, screenY / 2 - height / 2 + 4 - 5, 20, 20) then 
        closeHover = true
    end

    inBox = nil 
    if exports["cr_core"]:isInSlot(screenX / 2 - boxWidth / 2, screenY / 2 - height / 2, boxWidth, height) then 
        inBox = true
    end

    dxDrawRectangle(screenX / 2 - boxWidth / 2, screenY / 2 - height / 2, boxWidth, height, tocolor(44, 44, 44, alpha))
    dxDrawRectangle(screenX / 2 - boxWidth / 2 + 5, screenY / 2 - height / 2 + 25, boxWidth - 10, 2, tocolor(0, 0, 0, alpha * 0.15))
    dxDrawImage(screenX / 2 + boxWidth / 2 - 15 - 5, screenY / 2 - height / 2 + 4 - 5, 20, 20, "files/images/close.png", 0, 0, 0, (closeHover and tocolor(r, g, b, alpha) or tocolor(255, 255, 255, alpha)))
    dxDrawText("LEFOGLALT JÁRMŰVEID", screenX / 2 - boxWidth / 2 + 2, screenY / 2 - height / 2, screenX / 2 - boxWidth / 2 + 2 + boxWidth, screenY / 2 - height / 2 + 27, tocolor(130, 130, 130, alpha), 1, exports["cr_fonts"]:getFont("Roboto", 11), "center", "center")

    if maxLines <= 0 then 
        dxDrawText("Neked nincsen egy járműved sem lefoglalva.", screenX / 2 - boxWidth / 2 + 2, screenY / 2 - height / 2 + 28, screenX / 2 - boxWidth / 2 + 2 + boxWidth, screenY / 2 - height / 2 + 28 + 27, tocolor(130, 130, 130, alpha), 1, exports["cr_fonts"]:getFont("Roboto", 11), "center", "center")
    end

    local r, g, b = exports["cr_core"]:getServerColor("blue", false)
    local rr, rg, rb = exports["cr_core"]:getServerColor("green", false)
    local serverHex = exports["cr_core"]:getServerColor("blue", true)

    local startY = screenY / 2 - height / 2 + 30
    hoverButton = nil 
    for key = minLines, maxLines do 
        local value = cache[key]
        local inSlot = exports["cr_core"]:isInSlot(screenX / 2 - boxWidth / 2 + 3, startY, boxWidth - 5 - 6, 25)
        local inSlot2 = exports["cr_core"]:isInSlot(screenX / 2 + boxWidth / 2 - 115, startY + 2, 100, 26)

        dxDrawRectangle(screenX / 2 - boxWidth / 2 + 3, startY, boxWidth - 5 - 6, 30, (inSlot and tocolor(r, g, b, alpha) or tocolor(0, 0, 0, alpha * 0.15)))

        if value then 
            local text = value[3]..(inSlot and "#000000" or serverHex).." ($"..exports["cr_dx"]:formatMoney(value[8])..")"
            local inSlot3 = exports["cr_core"]:isInSlot(screenX / 2 - boxWidth / 2 + 3 - 2 - 45 + dxGetTextWidth(text, 1, exports["cr_fonts"]:getFont("Roboto", 11)), startY + 5, 10, 18)

            dxDrawRectangle(screenX / 2 + boxWidth / 2 - 115, startY + 2, 100, 26, ((inSlot2 and tocolor(rr, rg, rb, alpha) or tocolor(0, 0, 0, alpha * 0.15))))
            dxDrawText(text, screenX / 2 - boxWidth / 2 + 3 + 5, startY, screenX / 2 - boxWidth / 2 + 3 + 5 + boxWidth - 5 - 6, startY + 30, (inSlot and tocolor(0, 0, 0, alpha) or tocolor(130, 130, 130, alpha)), 1, exports["cr_fonts"]:getFont("Roboto", 11), "left", "center", false, false, false, true)
            dxDrawText("", screenX / 2 - boxWidth / 2 + 3 - 45 + dxGetTextWidth(text, 1, exports["cr_fonts"]:getFont("Roboto", 11)), startY, screenX / 2 - boxWidth / 2 + 3 + 5 + boxWidth - 5 - 6, startY + 30, (inSlot and tocolor(0, 0, 0, alpha) or tocolor(130, 130, 130, alpha)), 1, exports["cr_fonts"]:getFont("FontAwesome", 11), "left", "center")
            dxDrawText("Kiváltás", screenX / 2 + boxWidth / 2 - 115, startY + 2, screenX / 2 + boxWidth / 2 - 115 + 100, startY + 2 + 26, (inSlot2 and tocolor(0, 0, 0, alpha) or tocolor(130, 130, 130, alpha)), 1, exports["cr_fonts"]:getFont("Roboto", 10), "center", "center")

            if inSlot2 then 
                hoverButton = key
            end

            if inSlot3 then 
                local cursorX, cursorY = exports["cr_core"]:getCursorPosition()

                if cursorX and cursorY then 
                    exports["cr_dx"]:drawTooltip(2, "#9c9c9cLefoglalás időpontja: "..serverHex..value[7].."#9c9c9c\nVégrehajtó szerv: "..serverHex..value[6], {cursorX, cursorY, {}})
                end
            end
        end

        startY = startY + 32
    end

    dxDrawRectangle(screenX / 2 + boxWidth / 2 - 4.55, screenY / 2 - height / 2 + 30, 1, height - 38, tocolor(130, 130, 130, alpha))

    -- Scrollbar

    local percent = #cache

    if percent >= 1 then
        local gW, gH = 3, height - 38
        local gX, gY = screenX / 2 + boxWidth / 2 - 5.5, screenY / 2 - height / 2 + 30
        
        scrollingHover = exports["cr_core"]:isInSlot(gX, gY, gW, gH)

        if scrolling then
            if isCursorShowing() then
                if getKeyState("mouse1") then
                    local cx, cy = exports["cr_core"]:getCursorPosition()
                    local cy = math.min(math.max(cy, gY), gY + gH)
                    local y = (cy - gY) / (gH)
                    local num = percent * y
                    minLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _maxLines) + 1)))
                    maxLines = minLines + (_maxLines - 1)
                end
            else
                scrolling = false
            end
        end

        local multiplier = math.min(math.max((maxLines - (minLines - 1)) / percent, 0), 1)
        local multiplier2 = math.min(math.max((minLines - 1) / percent, 0), 1)
        local gY = gY + ((gH) * multiplier2)
        local gH = gH * multiplier

        dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
    end

    if impoundPed and isElement(impoundPed) then 
        if getDistanceBetweenPoints3D(localPlayer.position, impoundPed.position) > 3 then 
            if not forced then 
                forced = true 

                exports["cr_dx"]:startFade("impoundPanel", 
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
end

addEvent("impound.getImpoundedVehicles", true)
addEventHandler("impound.getImpoundedVehicles", root,
    function(tbl)
        cache = tbl

        for key, value in pairs(cache) do 
            local vehicleModel = value[3]
            local realtime = getRealTime(value[7])
            local formattedTime = ("%i.%.2i.%.2i. %.2i:%.2i:%.2i"):format(realtime["year"] + 1900, realtime["month"] + 1, realtime["monthday"], realtime["hour"], realtime["minute"], realtime["second"])

            cache[key][3] = exports["cr_vehicle"]:getVehicleName(vehicleModel)
            cache[key][7] = formattedTime
            cache[key][8] = exports["cr_carshop"]:getVehiclePrice(vehicleModel) * 0.5
        end

        if maxLines >= #cache then 
            maxLines = #cache
        end 
        maxLines = maxLines
        _maxLines = maxLines
    end
)

addEvent("impound.takeVehicle", true)
addEventHandler("impound.takeVehicle", root,
    function()
        if impoundDatas then 
            if exports["cr_core"]:takeMoney(localPlayer, tonumber(impoundDatas[8]), nil, false) then 
                triggerLatentServerEvent("impound.takeVehicle", 5000, false, localPlayer, localPlayer, impoundDatas)
            else
                return exports["cr_infobox"]:addBox("error", "Nincs elég pénzed.")
            end
        end
    end
)

addEvent("impound.cancelTake", true)
addEventHandler("impound.cancelTake", root,
    function()
        showing = false 
        impoundDatas = false
    end
)

function scrollDown()
    if maxLines + 1 <= #cache then
        minLines = minLines + 1
        maxLines = maxLines + 1

        playSound(":cr_scoreboard/files/wheel.wav")
    end
end

function scrollUP()
    if minLines - 1 >= 1 then
        minLines = minLines - 1
        maxLines = maxLines - 1

        playSound(":cr_scoreboard/files/wheel.wav")
    end
end