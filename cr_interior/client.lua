local screenX, screenY = guiGetScreenSize()
local boxWidth, boxHeight = 420, 110

local sourceMarker = false 
local interiorDatas = {}

local lastInteriorUse = 0
local lastInteriorLock = 0
local lastBellUse = 0
local lastKnockUse = 0

local start = false
local startTick = getTickCount()

local startAnimationTime = 250
local startAnimation = "InOutQuad"

local buyHover = false 
local cancelHover = false

local start2 = false
local startTick2 = getTickCount()

local start3 = true
local startTick3 = getTickCount()

local buyTick = getTickCount()
local buyKey = false
local progressBar = 0
local tempClose = 0

local cancelTick = getTickCount()
local cancelKey = false 
local progressBar2 = 0 
local tempClose2 = 0

local expireTick = getTickCount()
local expireKey = false
local progressBar3 = 0
local tempClose3 = 0

local resignationTick = getTickCount()
local resignationKey = false 
local progressBar4 = 0 
local tempClose4 = 0

local closeTick = getTickCount()
local closeKey = false 
local progressBar5 = 0 
local tempClose5 = 0

local customInteriorObjects = {}
local customMarkerTextures = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for key = 0, 4 do 
            setInteriorFurnitureEnabled(key, false)
        end

        local customInterior = localPlayer:getData("customInterior")
        if customInterior and customInterior > 0 then 
            loadCustomInterior(customInterior, localPlayer)
        end

        customMarkerTextures = {}

        for k, v in pairs(customMarkerTextures) do 
            if isElement(v) then 
                v:destroy()
            end
        end

        for k, v in pairs(interiorTypes) do 
            if fileExists("files/images/" .. k .. ".png") then 
                customMarkerTextures[k] = dxCreateTexture("files/images/" .. k .. ".png", "argb")
            end
        end
    end
)

addEventHandler("onClientMarkerHit", root,
    function(hitElement, mDim)
        if hitElement == localPlayer then 
            if mDim then 
                if not source:getData("parent") and not source:getData("marker >> data") then
                    return 
                end

                if getDistanceBetweenPoints3D(localPlayer.position, source.position) > 2 then 
                    return 
                end

                removeEventHandler("onClientKey", root, onKey)
                addEventHandler("onClientKey", root, onKey)

                local data = (source ~= source:getData("parent") and source:getData("marker >> data") or source:getData("parent"):getData("marker >> data"))
                local id = data["id"]
                local name = data["name"]
                local owner = data["owner"]
                local locked = data["locked"]
                local type = data["type"]
                local price = data["price"]
                
                createRender("renderInterior", renderInterior)
                start = true 
                startTick = getTickCount()

                sourceMarker = source 
                interiorDatas = {id, name, owner, locked, type, price}
            end
        end
    end
)

addEventHandler("onClientMarkerLeave", root,
    function(hitElement, mDim)
        if hitElement == localPlayer then 
            if mDim then 
                if checkRender("renderInterior") then 
                    if not source:getData("parent") and not source:getData("marker >> data") then
                        return 
                    end

                    if sourceMarker ~= source then 
                        return 
                    end

                    removeEventHandler("onClientKey", root, onKey)

                    start = false 
                    startTick = getTickCount()

                    start2 = false 
                    startTick2 = getTickCount()

                    sourceMarker = false
                end
            end
        end
    end
)

addEventHandler("onClientElementDataChange", resourceRoot,
    function(dataName, oldValue, newValue)
        if source:getType() == "marker" then 
            if source:getData("parent") then 
                if dataName == "marker >> data" then 
                    if interiorDatas and #interiorDatas > 0 then 
                        if sourceMarker == source then 
                            if interiorDatas[5] == newValue["type"] then 
                                interiorDatas = {newValue["id"], newValue["name"], newValue["owner"], newValue["locked"], newValue["type"], newValue["price"]}
                            end
                        end
                    end
                end
            end
        end
    end
)

function getActiveInterior()
    return sourceMarker
end

local bellHover = false 
local knockHover = false
local manageHover = false

function renderInterior()
    local screenX, screenY = screenX, screenY
    local nowTick = getTickCount()
    local alpha
    if start then
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph, y = interpolateBetween(
            0, screenY, 0,
            255, screenY - 200, 0,
            progress, startAnimation
        )
        
        alpha = alph
        screenY = y
    else
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph, y = interpolateBetween(
            255, screenY - 200, 0,
            0, screenY, 0,
            progress, startAnimation
        )
        
        alpha = alph
        screenY = y
        
        if progress >= 1 then
            alpha = 0
            interiorDatas = {}
            destroyRender("renderInterior")
        end
    end

    if not isElement(sourceMarker) then 
        if checkRender("renderInterior") and start or checkRender("renderInterior") and start2 then 
            removeEventHandler("onClientKey", root, onKey)

            start = false 
            startTick = getTickCount()

            start2 = false 
            startTick2 = getTickCount()
        end
    end 

    local font = exports['cr_fonts']:getFont('Poppins-Bold', 18)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 14)

    local w,h = 550, 115
    local x,y = screenX / 2- w/2, screenY

    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))

    if interiorDatas and #interiorDatas > 0 then 
        dxDrawRectangle(x + 150, y + h/2 - 89/2, 2, 89, tocolor(159, 56, 56, alpha))

        dxDrawImage(x + 150/2 - 84/2, y + h/2 - 84/2, 84, 84, "files/images/"..interiorDatas[5]..".png", 0, 0, 0, tocolor(242, 242, 242, alpha))

        dxDrawText(interiorDatas[3] and interiorDatas[2] or interiorDatas[2].." - #61b15a$ "..formatMoney(interiorDatas[6]), x + 170, y + 25, x + 170, y + 25, tocolor(242, 242, 242, alpha), 1, font, "left", "top", false, false, false, true)

        if not interiorDatas[3] and interiorDatas[5] == 1 then 
            dxDrawText("Nyomj #ff3b3b[H]#f2f2f2 gombot az ingatlan megtekintéséhez.", x + 170, y + 75, x + 170, y + 75, tocolor(242, 242, 242, alpha), 1, font2, "left", "top", false, false, false, true)
            dxDrawText("Nyomj #ff3b3b[E]#f2f2f2 gombot a vásárláshoz.", x + 170, y + 55, x + 170, y + 55, tocolor(242, 242, 242, alpha), 1, font2, "left", "top", false, false, false, true)
        elseif not interiorDatas[3] and interiorDatas[5] == 3 or not interiorDatas[3] and interiorDatas[5] == 7 then 
            dxDrawText("Nyomj #ff3b3b[H]#f2f2f2 gombot az ingatlan megtekintéséhez.", x + 170, y + 75, x + 170, y + 75, tocolor(242, 242, 242, alpha), 1, font2, "left", "top", false, false, false, true)
            dxDrawText("Nyomj #ff3b3b[E]#f2f2f2 gombot a bérléshez.", x + 170, y + 55, x + 170, y + 55, tocolor(242, 242, 242, alpha), 1, font2, "left", "top", false, false, false, true)
        elseif not interiorDatas[3] and interiorDatas[5] == 4 then 
            dxDrawText("Nyomj #ff3b3b[H]#f2f2f2 gombot az ingatlan megtekintéséhez.", x + 170, y + 75, x + 170, y + 75, tocolor(242, 242, 242, alpha), 1, font2, "left", "top", false, false, false, true)
            dxDrawText("Nyomj #ff3b3b[E]#f2f2f2 gombot a vásárláshoz.", x + 170, y + 55, x + 170, y + 55, tocolor(242, 242, 242, alpha), 1, font2, "left", "top", false, false, false, true)
        else
            dxDrawImage(x + 510, y + 16, 20, 20, "files/images/bell.png", 0, 0, 0, (bellHover and tocolor(242, 242, 242, alpha) or tocolor(242, 242, 242, alpha * 0.6)))
            dxDrawImage(x + 510, y + 36 + 7, 20, 20, "files/images/knock.png", 0, 0, 0, (knockHover and tocolor(242, 242, 242, alpha) or tocolor(242, 242, 242, alpha * 0.6)))
            dxDrawImage(x + 510, y + 56 + 14, 20, 20, (interiorDatas[4] and "files/images/lock.png" or "files/images/unlock.png"), 0, 0, 0, (manageHover and tocolor(242, 242, 242, alpha) or tocolor(242, 242, 242, alpha * 0.6)))
            dxDrawText("Nyomj #ff3b3b[E]#f2f2f2 gombot a használathoz.", x + 170, y + 75, x + 170, y + 75, tocolor(242, 242, 242, alpha), 1, font2, "left", "top", false, false, false, true)
        end

        local cursorX, cursorY = exports["cr_core"]:getCursorPosition()
        bellHover = false 
        knockHover = false 
        manageHover = false
        if isInSlot(x + 510, y + 16, 20, 20) and interiorDatas[3] and (interiorDatas[5] == 1 or interiorDatas[5] == 3) then 
            bellHover = true 
            drawTooltip(2, "#f2f2f2Csengetés", {cursorX, cursorY, {["alpha"] = alpha}})
        elseif isInSlot(x + 510, y + 36 + 7, 20, 20) and interiorDatas[3] and (interiorDatas[5] == 1 or interiorDatas[5] == 3 or interiorDatas[5] == 4) then 
            knockHover = true
            drawTooltip(2, "#f2f2f2Kopogás", {cursorX, cursorY, {["alpha"] = alpha}})
        elseif isInSlot(x + 510, y + 56 + 14, 20, 20) and interiorDatas[3] and (interiorDatas[5] == 1 or interiorDatas[5] == 3 or interiorDatas[5] == 5) then 
            manageHover = true
            drawTooltip(2, (interiorDatas[4] and "#f2f2f2Kinyitás" or "#f2f2f2Bezárás"), {cursorX, cursorY, {["alpha"] = alpha}})
        end
    end 
end

function renderConfirm()
    local nowTick = getTickCount()
    local alpha
    if start2 then
        local elapsedTime = nowTick - startTick2
        local duration = (startTick2 + startAnimationTime) - startTick2
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            0, 0, 0,
            255, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph
    else
        local elapsedTime = nowTick - startTick2
        local duration = (startTick2 + startAnimationTime) - startTick2
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            255, 0, 0,
            0, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph
        
        if progress >= 1 then
            destroyRender("renderConfirm")
            removeEventHandler("onClientKey", root, onConfirmKey)
        end
    end

    local w, h = 515, 171
    local x, y = screenX / 2 - w / 2, screenY / 2 - h / 2
    local font = exports['cr_fonts']:getFont("Poppins-SemiBold", 16)
    local font2 = exports['cr_fonts']:getFont("Poppins-SemiBold", 18)
    local font3 = exports['cr_fonts']:getFont("Poppins-Medium", 14)

    dxDrawRectangle(screenX / 2 - w / 2, screenY / 2 - h / 2, w, h, tocolor(51, 51, 51, alpha * 0.8))
    dxDrawImage(x + 10, y + 10, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	dxDrawText("Ingatlan vásárlás", x + 10 + 26 + 10,y+10,x+w,y+10+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

    local text = "Biztosan meg szeretnéd vásárolni az ingatlant?"
    if interiorDatas[5] == 3 then 
        text = "Biztosan ki szeretnéd bérelni az ingatlant?"
    elseif interiorDatas[5] == 7 then 
        text = "Biztosan ki szeretnéd bérelni a farmot?"
    end

    dxDrawText(text, x, y + 60, x + w, y + 60, tocolor(242, 242, 242, alpha), 1, font2, "center", "top", false, false, false, true)

    buyHover = false 
    cancelHover = false

    local buyText = "Megvétel"
    if interiorDatas[5] == 3 or interiorDatas[5] == 7 then 
        buyText = "Bérlés"
    end

    if exports['cr_core']:isInSlot(x + 45, y + 110, 200, 35) then 
        buyHover = true 

        dxDrawRectangle(x + 45, y + 110, 200, 35, tocolor(97, 177, 90, alpha))
        dxDrawText(buyText, x + 45, y + 110, x + 45 + 200, y + 110 + 35 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
    else 
        dxDrawRectangle(x + 45, y + 110, 200, 35, tocolor(97, 177, 90, alpha * 0.7))
        dxDrawText(buyText, x + 45, y + 110, x + 45 + 200, y + 110 + 35 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
    end 

    if exports['cr_core']:isInSlot(x + 270, y + 110, 200, 35) then 
        cancelHover = true 
        
        dxDrawRectangle(x + 270, y + 110, 200, 35, tocolor(255, 59, 59, alpha))
        dxDrawText("Mégse", x + 270, y + 110, x + 270 + 200, y + 110 + 35 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
    else 
        dxDrawRectangle(x + 270, y + 110, 200, 35, tocolor(255, 59, 59, alpha * 0.7))
        dxDrawText("Mégse", x + 270, y + 110, x + 270 + 200, y + 110 + 35 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
    end 
end

local oldSourceMarker = {}

function onKey(button, state)
    if button == "e" then 
        if state then 
            if exports["cr_network"]:getNetworkStatus() then 
                return 
            end

            if localPlayer:getData("char >> chat") or localPlayer:getData("char >> console") then 
                return 
            end

            if not sourceMarker then 
                return 
            end

            if lastInteriorUse + 2000 > getTickCount() then 
                return
            end

            local data = (sourceMarker ~= sourceMarker:getData("parent") and sourceMarker:getData("marker >> data") or sourceMarker:getData("parent"):getData("marker >> data"))
            if data and data["owner"] then 
                if data["type"] ~= 6 then -- lift
                    if not data["locked"] then 
                        if data["type"] ~= 5 and localPlayer:isInVehicle() then 
                            exports["cr_infobox"]:addBox("error", "Ez nem egy garázs, emiatt nem tudsz bemenni.")
                            return 
                        end

                        local element = (sourceMarker ~= sourceMarker:getData("parent") and sourceMarker:getData("parent") or sourceMarker)

                        if sourceMarker:getData("marker >> data") then 
                            oldSourceMarker[(sourceMarker:getData("marker >> data") or {})["id"]] = localPlayer:getData("inInterior")
                            localPlayer:setData("inInterior", sourceMarker)
                        elseif sourceMarker:getData("parent") then 
                            if sourceMarker:getData("parent").dimension == 0 then 
                                localPlayer:setData("inInterior", nil)
                            else 
                                localPlayer:setData("inInterior", oldSourceMarker[(sourceMarker:getData("parent"):getData("marker >> data") or {})["id"]])
                            end 
                        end

                        if localPlayer:getData("usingWaterCan") then 
                            exports.cr_inventory:findAndUseItemByIDAndValue(188, localPlayer:getData("usingWaterCan"))
                            triggerServerEvent("plant.manageWaterCan", localPlayer, false, "destroy")
                        end

                        local vehicle = localPlayer.vehicle
                        if vehicle then 
                            local vehicleType = getVehicleType(vehicle)

                            if vehicleType == "BMX" or vehicleType == "Bike" then 
                                setPedCanBeKnockedOffBike(localPlayer, false)
                                setTimer(setPedCanBeKnockedOffBike, 3000, 1, localPlayer, true)
                            end
                        end

                        playSound("files/sounds/interiorenter.wav")
                        triggerServerEvent("changeElementInterior", localPlayer, localPlayer, (sourceMarker ~= sourceMarker:getData("parent") and sourceMarker:getData("parent") or sourceMarker))
                    else 
                        playSound("files/sounds/locked.mp3")
                        exports["cr_infobox"]:addBox("error", "Az ingatlan zárva van.")
                        return 
                    end
                else 
                    if not data["locked"] then 
                        if localPlayer:isInVehicle() then 
                            exports["cr_infobox"]:addBox("error", "Nem tudod járműben ülve használni a liftet.")
                            return 
                        end

                        if sourceMarker:getData("parent") then 
                            if sourceMarker:getData("parent"):getData("marker >> data") then 
                                if sourceMarker:getData("parent").dimension ~= 0 then 
                                    oldSourceMarker[(sourceMarker:getData("parent"):getData("marker >> data") or {})["id"]] = localPlayer:getData("inInterior")

                                    localPlayer:setData("inInterior", sourceMarker:getData("parent"))
                                end
                            elseif sourceMarker:getData("marker >> data") then 
                                if sourceMarker.dimension == 0 then 
                                    localPlayer:setData("inInterior", nil)
                                else 
                                    localPlayer:setData("inInterior", oldSourceMarker[(sourceMarker:getData("parent"):getData("marker >> data") or {})["id"]])
                                end 
                            end

                            playSound("files/sounds/interiorenter.wav")
                            triggerServerEvent("useElevator", localPlayer, localPlayer, (sourceMarker ~= sourceMarker:getData("parent") and sourceMarker:getData("parent") or sourceMarker))
                        else 
                            return exports["cr_infobox"]:addBox("error", "A liftnek nincs beállítva a kijárata ezért nem tudod használni.")
                        end
                    else 
                        playSound("files/sounds/locked.mp3")
                        exports["cr_infobox"]:addBox("error", "A lift zárva van.")
                        return 
                    end
                end
            elseif data and not data["owner"] then 
                if checkRender("renderConfirm") then 
                    return 
                end
                
                createRender("renderConfirm", renderConfirm)
                removeEventHandler("onClientKey", root, onConfirmKey)
                addEventHandler("onClientKey", root, onConfirmKey)

                progressBar = 0
                progressBar2 = 0
                start2 = true
                startTick2 = getTickCount()
            end
            lastInteriorUse = getTickCount()
        end
    elseif button == "h" then 
        if state then 
            if exports["cr_network"]:getNetworkStatus() then 
                return 
            end

            if localPlayer:getData("char >> chat") or localPlayer:getData("char >> console") then 
                return 
            end

            if not sourceMarker then 
                return 
            end

            if lastInteriorUse + 2000 > getTickCount() then 
                return
            end

            if localPlayer.vehicle then 
                return
            end

            if not interiorDatas[3] then 
                local other = sourceMarker:getData("parent")
                if other then 
                    local data = (sourceMarker ~= sourceMarker:getData("parent") and sourceMarker:getData("marker >> data") or sourceMarker:getData("parent"):getData("marker >> data"))
                    
                    if sourceMarker:getData("marker >> data") then 
                        oldSourceMarker[(sourceMarker:getData("marker >> data") or {})["id"]] = localPlayer:getData("inInterior")
                        localPlayer:setData("inInterior", sourceMarker)
                    elseif sourceMarker:getData("parent") then 
                        if sourceMarker:getData("parent").dimension == 0 then 
                            localPlayer:setData("inInterior", nil)
                        else 
                            localPlayer:setData("inInterior", oldSourceMarker[(sourceMarker:getData("parent"):getData("marker >> data") or {})["id"]])
                        end 
                    end
                    
                    local vehicle = localPlayer.vehicle
                    if vehicle then 
                        local vehicleType = getVehicleType(vehicle)

                        if vehicleType == "BMX" or vehicleType == "Bike" then 
                            setPedCanBeKnockedOffBike(localPlayer, false)
                            setTimer(setPedCanBeKnockedOffBike, 3000, 1, localPlayer, true)
                        end
                    end

                    playSound("files/sounds/interiorenter.wav")
                    triggerServerEvent("changeElementInterior", localPlayer, localPlayer, other)

                    if getElementInterior(other) ~= 0 then 
                        if data["type"] and data["type"] ~= 3 and data.type ~= 7 then 
                            outputChatBox(exports["cr_core"]:getServerSyntax(false, "green").."Ez az ingatlan eladó. Megvásárláshoz használd az "..exports["cr_core"]:getServerColor("green", true).."[E]#ffffff gombot a markerben állva.", 255, 0, 0, true)
                            outputChatBox(exports["cr_core"]:getServerSyntax(false, "green").."Ár: "..exports["cr_core"]:getServerColor("green", true)..formatMoney(data["price"]).."#ffffff dollár.", 255, 0, 0, true)
                        else 
                            if data.type == 3 then 
                                outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Ez az ingatlan bérelhető. Bérléshez használd az "..exports["cr_core"]:getServerColor("red", true).."[E]#ffffff gombot a markerben állva.", 255, 0, 0, true)
                                outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Ár: "..exports["cr_core"]:getServerColor("red", true)..formatMoney(data["price"]).."#ffffff dollár / hét.", 255, 0, 0, true)
                            end
                        end
                    else
                        if data.type == 7 then
                            local elementData = sourceMarker:getData("marker >> data")

                            if elementData then 
                                local syntax = exports.cr_core:getServerSyntax("Farm", "info")
                                local hexColor = exports.cr_core:getServerColor("yellow", true)

                                outputChatBox(syntax .. "Ez a farm bérelhető. Bérléshez használd az " .. hexColor .. "[E]#ffffff gombot a markerben állva.", 255, 0, 0, true)
                                outputChatBox(syntax .. "Ár: " .. hexColor .. formatMoney(data.price) .. "#ffffff dollár / hét.", 255, 0, 0, true)
                            end
                        end
                    end
                end
            end
            lastInteriorUse = getTickCount()
        end
    elseif button == "k" then 
        if state then 
            if exports["cr_network"]:getNetworkStatus() then 
                return 
            end

            if localPlayer:getData("char >> chat") or localPlayer:getData("char >> console") then 
                return 
            end

            if not sourceMarker then 
                return 
            end

            if lastInteriorLock + 2000 > getTickCount() then 
                return
            end

            if interiorDatas[3] then 
                local data = (sourceMarker ~= sourceMarker:getData("parent") and sourceMarker:getData("marker >> data") or sourceMarker:getData("parent"):getData("marker >> data"))
                if data then 
                    if exports["cr_inventory"]:hasItem(localPlayer, 17, data["id"]) or exports["cr_permission"]:hasPermission(localPlayer, "forceInteriorLock") then 
                        playSound("files/sounds/openclose.mp3")
                        
                        if data["type"] ~= 6 then 
                            triggerServerEvent("lockInterior", localPlayer, localPlayer, (localPlayer:getInterior() > 0 and sourceMarker:getData("parent") or sourceMarker))
                        else 
                            triggerServerEvent("lockInterior", localPlayer, localPlayer, (not sourceMarker:getData("parent"):getData("marker >> data") and sourceMarker or sourceMarker:getData("parent")))
                        end

                        if not data["locked"] then 
                            exports["cr_chat"]:createMessage(localPlayer, "bezárja egy ingatlan ajtaját.", 1)
                        else 
                            exports["cr_chat"]:createMessage(localPlayer, "kinyitja egy ingatlan ajtaját.", 1)
                        end
                    else 
                        exports["cr_infobox"]:addBox("error", "Nincs kulcsod az ingatlanhoz.")
                    end
                end
            end
            lastInteriorLock = getTickCount()
        end
    elseif button == "mouse1" then 
        if state then 
            if exports["cr_network"]:getNetworkStatus() then 
                return 
            end

            if bellHover then 
                if localPlayer:getData("char >> chat") or localPlayer:getData("char >> console") then 
                    return 
                end
    
                if not sourceMarker then 
                    return 
                end
    
                if getElementDimension(localPlayer) ~= 0 then 
                    return 
                end

                local data = (sourceMarker ~= sourceMarker:getData("parent") and sourceMarker:getData("marker >> data") or sourceMarker:getData("parent"):getData("marker >> data"))
                if data["type"] ~= 1 and data["type"] ~= 3 and data["type"] ~= 4 then 
                    exports["cr_infobox"]:addBox("error", "Ez nem egy ház típusú ingatlan, ezért nem tudsz csengetni.")
                    return 
                end

                if lastBellUse + 2000 > getTickCount() then 
                    return
                end

                if interiorDatas[3] then 
                    local other = sourceMarker:getData("parent")
                    if other then 
                        local players = getPlayersInTheSameInterior(other)
                        triggerServerEvent("bellInterior", localPlayer, localPlayer, other, players)
                    end
                end

                lastBellUse = getTickCount()
                bellHover = false 
            end

            if knockHover then 
                if localPlayer:getData("char >> chat") or localPlayer:getData("char >> console") then 
                    return 
                end
    
                if not sourceMarker then 
                    return 
                end
    
                if getElementDimension(localPlayer) ~= 0 then 
                    return 
                end

                local data = (sourceMarker ~= sourceMarker:getData("parent") and sourceMarker:getData("marker >> data") or sourceMarker:getData("parent"):getData("marker >> data"))
                if data["type"] ~= 1 and data["type"] ~= 3 and data["type"] ~= 4 then 
                    exports["cr_infobox"]:addBox("error", "Ez nem egy ház típusú ingatlan, ezért nem tudsz kopogni.")
                    return 
                end

                if lastKnockUse + 2000 > getTickCount() then 
                    return
                end

                if interiorDatas[3] then 
                    local other = sourceMarker:getData("parent")
                    if other then 
                        local players = getPlayersInTheSameInterior(other)
                        triggerServerEvent("knockInterior", localPlayer, localPlayer, other, players)
                    end
                end

                lastKnockUse = getTickCount()
                knockHover = false 
            end

            if manageHover then 
                if localPlayer:getData("char >> chat") or localPlayer:getData("char >> console") then 
                    return 
                end
    
                if not sourceMarker then 
                    return 
                end
    
                if lastInteriorLock + 2000 > getTickCount() then 
                    return
                end
    
                if interiorDatas[3] then 
                    local data = (sourceMarker ~= sourceMarker:getData("parent") and sourceMarker:getData("marker >> data") or sourceMarker:getData("parent"):getData("marker >> data"))
                    if data then 
                        if exports["cr_inventory"]:hasItem(localPlayer, 17, data["id"]) or exports["cr_permission"]:hasPermission(localPlayer, "forceInteriorLock") then 
                            playSound("files/sounds/openclose.mp3")

                            if data["type"] ~= 5 then 
                                triggerServerEvent("lockInterior", localPlayer, localPlayer, (localPlayer:getInterior() > 0 and sourceMarker:getData("parent") or sourceMarker))
                            else 
                                triggerServerEvent("lockInterior", localPlayer, localPlayer, (not sourceMarker:getData("parent"):getData("marker >> data") and sourceMarker or sourceMarker:getData("parent")))
                            end
    
                            if not data["locked"] then 
                                exports["cr_chat"]:createMessage(localPlayer, "bezárja egy ingatlan ajtaját.", 1)
                            else 
                                exports["cr_chat"]:createMessage(localPlayer, "kinyitja egy ingatlan ajtaját.", 1)
                            end
                        else 
                            exports["cr_infobox"]:addBox("error", "Nincs kulcsod az ingatlanhoz.")
                        end
                    end
                end
                lastInteriorLock = getTickCount()
                manageHover = false
            end
        end
    end
end

function getNearbyInteriors(cmd)
    if exports["cr_permission"]:hasPermission(localPlayer, cmd) then 
        local count = 0
        local dimension = localPlayer:getDimension()
        local syntax = exports.cr_core:getServerSyntax(false, "info")
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        for key, value in pairs(getElementsByType("marker", root, true)) do 
            if value:getData("parent") then 
                local data = (value ~= value:getData("parent") and value:getData("marker >> data") or value:getData("parent"):getData("marker >> data"))
                local distance = getDistanceBetweenPoints3D(localPlayer.position, value.position)
                if distance <= 15 then 
                    if value:getDimension() == dimension then 
                        if not data["elevator"] then 
                            outputChatBox(syntax .. "ID: " .. hexColor .. data["id"] .. "#ffffff | Név: " .. hexColor .. data["name"], 255, 0, 0, true)
                            
                            if data.owner and data.owner ~= "Önkormányzat" and data.owner > 0 then 
                                outputChatBox(syntax .. "Tulajdonos account idje: " .. hexColor .. data.owner, 255, 0, 0, true)
                            end

                            count = count + 1
                        end
                    end
                end
            end
        end
        if count == 0 then 
            return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Nincs a közeledben interior.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("nearbyinteriors", getNearbyInteriors, false, false)

local rentData = {}
local rentDataByDbId = {}

local rentExpireHover = false 
local rentResignationHover = false 

local clickedPed = false
local closing = false

local lastElementClick = 0

local rentMinLines = 1
local _rentMaxLines = 5
local rentMaxLines = _rentMaxLines

local hoverInteriorRow = false
local selectedInteriors = {}

addEventHandler("onClientClick", root,
    function(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
        if button == "left" and state == "down" then 
            if clickedElement then 
                if exports["cr_network"]:getNetworkStatus() then 
                    return 
                end
                
                if clickedElement:getData("ped.id") ~= "rentPed" then 
                    return 
                end

                if checkRender("renderRent") then 
                    return 
                end

                if getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position) > 3 then 
                    return 
                end

                if lastElementClick + 2000 > getTickCount() then 
                    return
                end

                lastElementClick = getTickCount()
                triggerServerEvent("getRentedInterior", localPlayer, localPlayer)
                clickedPed = clickedElement
                progressBar3 = 0
                progressBar4 = 0
            end
        end
    end
)

function renderRent()
    local nowTick = getTickCount()
    local alpha
    if start3 then
        local elapsedTime = nowTick - startTick3
        local duration = (startTick3 + startAnimationTime) - startTick3
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            0, 0, 0,
            255, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph

        if alpha < 255 then
            progressBar5 = alpha
        end
    else
        local elapsedTime = nowTick - startTick3
        local duration = (startTick3 + startAnimationTime) - startTick3
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            255, 0, 0,
            0, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph
        
        if progress >= 1 then
            closing = false
            clickedPed = false
            destroyRender("renderRent")
            removeEventHandler("onClientKey", root, onConfirmKey)

            rentData = {}
            rentDataByDbId = {}
            selectedInteriors = {}
        end
    end

    local w, h = 515, 181
    local rowH = 20 -- rentRowH

    if #rentData > 0 then 
        h = h + (#rentData * (rowH + 2))
    end

    local x, y = screenX / 2 - w / 2, screenY / 2 - h / 2
    local font = exports['cr_fonts']:getFont("Poppins-SemiBold", 16)
    local font2 = exports['cr_fonts']:getFont("Poppins-SemiBold", 18)
    local font3 = exports['cr_fonts']:getFont("Poppins-Medium", 14)

    dxDrawRectangle(screenX / 2 - w / 2, screenY / 2 - h / 2, w, h, tocolor(51, 51, 51, alpha * 0.8))
    dxDrawImage(x + 10, y + 10, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	dxDrawText("Ingatlan kezelés", x + 10 + 26 + 10,y+10,x+w,y+10+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

    local allMoney = 0

    if #rentData > 0 then
        for k, v in pairs(selectedInteriors) do 
            if rentDataByDbId[k] then 
                allMoney = allMoney + tonumber(rentDataByDbId[k].price)
            end
        end

        dxDrawText("Válaszd ki azokat az ingatlanokat\namelyeket kezelni szeretnél", x, y + 50, x + w, y + 50, tocolor(242, 242, 242, alpha), 1, font2, "center", "top", false, false, false, true)

        local hexColor = exports.cr_core:getServerColor("yellow", true)

        local rowW = w - 20
        local rowX, rowY = x + 10, y + 120

        hoverInteriorRow = false

        for i = rentMinLines, rentMaxLines do 
            local v = rentData[i]

            if v then 
                local id = tonumber(v.id)

                local rowColor = tocolor(51, 51, 51, alpha * 0.29)
                local textColor = tocolor(255, 255, 255, alpha)
                local inSlot = exports.cr_core:isInSlot(rowX, rowY, rowW, rowH)

                if inSlot then 
                    hoverInteriorRow = id
    
                    rowColor = tocolor(242, 242, 242, alpha)
                    textColor = tocolor(51, 51, 51, alpha)
                else
                    if selectedInteriors[id] then 
                        rowColor = tocolor(242, 242, 242, alpha)
                        textColor = tocolor(51, 51, 51, alpha)
                    end
                end

                local typ = "Típus: " .. hexColor .. convertInteriorType(v.type)

                if inSlot or selectedInteriors[id] then 
                    typ = string.gsub(typ, "#" .. (6 and string.rep("%x", 6) or "%x+"), "")
                end

                dxDrawRectangle(rowX, rowY, rowW, rowH, rowColor)
                dxDrawText(v.name, rowX + 5, rowY + 4, rowX + rowW, rowY + rowH, textColor, 1, font3, "left", "center")
                dxDrawText(typ, rowX, rowY + 4, rowX + rowW - 5, rowY + rowH, textColor, 1, font3, "right", "center", false, false, false, true)
            end

            rowY = rowY + rowH + 2
        end

        rentResignationHover = false
        rentExpireHover = false 

        local expireButtonW, expireButtonH = 200, 35
        local expireButtonX, expireButtonY = x + 45, y + h - expireButtonH - 10
        local inSlot = exports.cr_core:isInSlot(expireButtonX, expireButtonY, expireButtonW, expireButtonH)

        local expireButtonColor = tocolor(97, 177, 90, alpha * 0.7)
        local expireButtonTextColor = tocolor(255, 255, 255, alpha * 0.6)

        if inSlot then 
            rentExpireHover = true
            expireButtonColor = tocolor(97, 177, 90, alpha)
            expireButtonTextColor = tocolor(255, 255, 255, alpha)
        end

        dxDrawRectangle(expireButtonX, expireButtonY, expireButtonW, expireButtonH, expireButtonColor)
        dxDrawText("Meghosszabítás ($" .. allMoney .. ")", expireButtonX, expireButtonY + 4, expireButtonX + expireButtonW, expireButtonY + expireButtonH, expireButtonTextColor, 1, font3, "center", "center")

        local resignateButtonW, resignateButtonH = 200, 35
        local resignateButtonX, resignateButtonY = x + w - resignateButtonW - 45, expireButtonY
        local inSlot = exports.cr_core:isInSlot(resignateButtonX, resignateButtonY, resignateButtonW, resignateButtonH)

        local resignateButtonColor = tocolor(255, 59, 59, alpha * 0.7)
        local resignateButtonTextColor = tocolor(255, 255, 255, alpha * 0.6)

        if inSlot then 
            rentResignationHover = true
            resignateButtonColor = tocolor(255, 59, 59, alpha)
            resignateButtonTextColor = tocolor(255, 255, 255, alpha)
        end

        dxDrawRectangle(resignateButtonX, resignateButtonY, resignateButtonW, resignateButtonH, resignateButtonColor)
        dxDrawText("Lemondás ($" .. math.floor(allMoney / 10) .. ")", resignateButtonX, resignateButtonY + 4, resignateButtonX + resignateButtonW, resignateButtonY + resignateButtonH, resignateButtonTextColor, 1, font3, "center", "center")
    end

    -- if exports['cr_core']:isInSlot(x + 45, y + 110, 200, 35) then 
    --     rentExpireHover = true 

    --     dxDrawRectangle(x + 45, y + 110, 200, 35, tocolor(97, 177, 90, alpha))
    --     dxDrawText("Meghosszabítás ("..formatMoney(allMoney).." $)", x + 45, y + 110, x + 45 + 200, y + 110 + 35 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
    -- else 
    --     dxDrawRectangle(x + 45, y + 110, 200, 35, tocolor(97, 177, 90, alpha * 0.7))
    --     dxDrawText("Meghosszabítás ("..formatMoney(allMoney).." $)", x + 45, y + 110, x + 45 + 200, y + 110 + 35 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
    -- end 

    -- if exports['cr_core']:isInSlot(x + 270, y + 110, 200, 35) then 
    --     rentResignationHover = true 
        
    --     dxDrawRectangle(x + 270, y + 110, 200, 35, tocolor(255, 59, 59, alpha))
    --     dxDrawText("Lemondás ("..formatMoney((math.floor(allMoney / 10))).." $)", x + 270, y + 110, x + 270 + 200, y + 110 + 35 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
    -- else 
    --     dxDrawRectangle(x + 270, y + 110, 200, 35, tocolor(255, 59, 59, alpha * 0.7))
    --     dxDrawText("Lemondás ("..formatMoney((math.floor(allMoney / 10))).." $)", x + 270, y + 110, x + 270 + 200, y + 110 + 35 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
    -- end 

    --[[
    local width, height = 374, 365 + 60
    local serverHex = exports["cr_core"]:getServerColor("blue", true)
    local r, g, b = exports["cr_core"]:getServerColor("blue", false)

    fonts = {}
    fonts["Roboto-11"] = exports["cr_fonts"]:getFont("Roboto", 11)

    dxDrawRectangle(screenX / 2 - width / 2, screenY / 2 - height / 2, width, height, tocolor(33, 33, 33, alpha))
    dxDrawOuterBorder(screenX / 2 - width / 2, screenY / 2 - height / 2, width, height, 2, tocolor(44, 44, 44, alpha))
    dxDrawRectangle(screenX / 2 - width / 2, screenY / 2 - 70 / 2 + 70, width, 70, tocolor(44, 44, 44, alpha))

    dxDrawImage(screenX / 2 - 200 / 2, screenY / 2 - 200 / 2 - 100, 200, 200, "files/images/rent.png", 0, 0, 0, tocolor(r, g, b, alpha))
    dxDrawRectangle(screenX / 2 - width / 2 + 60, screenY / 2 - 70 / 2 + 160, width - 120, 30, tocolor(44, 44, 44, alpha))
    dxDrawRectangle(screenX / 2 - width / 2 + 60, screenY / 2 - 70 / 2 + 160 + 30 - 2, (width - 120) / 255 * progressBar3, 2, tocolor(r, g, b, alpha))

    dxDrawRectangle(screenX / 2 - width / 2 + 60, screenY / 2 - 70 / 2 + 202 - 9, width - 120, 30, tocolor(44, 44, 44, alpha))
    dxDrawRectangle(screenX / 2 - width / 2 + 60, screenY / 2 - 70 / 2 + 202 - 9 + 30 - 2, (width - 120) / 255 * progressBar4, 2, tocolor(r, g, b, alpha))

    dxDrawRectangle(screenX / 2 - width / 2, screenY / 2 - height / 2 + height - 2, (width) / 255 * progressBar5, 2, tocolor(r, g, b, alpha))

    local inSlot = isInSlot(screenX / 2 - width / 2 + 60, screenY / 2 - 70 / 2 + 160, width - 120, 30)
    local inSlot2 = isInSlot(screenX / 2 - width / 2 + 60, screenY / 2 - 70 / 2 + 202 - 9, width - 120, 30)

    rentExpireHover = false 
    rentResignationHover = false 
    if inSlot then 
        rentExpireHover = true 
    end

    if inSlot2 then 
        rentResignationHover = true
    end

    dxDrawText("Meghosszabítás "..(inSlot and "#828282" or serverHex).."("..formatMoney(rentPrice).." $)", screenX / 2 - width / 2 + 60, screenY / 2 - 70 / 2 + 160, screenX / 2 - width / 2 + 60 + width - 120, screenY / 2 - 70 / 2 + 160 + 30, (inSlot and tocolor(r, g, b, alpha) or tocolor(130, 130, 130, alpha)), 1, fonts["Roboto-11"], "center", "center", false, false, false, true)
    dxDrawText("Lemondás "..(inSlot2 and "#828282" or serverHex).."("..formatMoney((math.floor(rentPrice / 10))).." $)", screenX / 2 - width / 2 + 60, screenY / 2 - 70 / 2 + 202 - 9, screenX / 2 - width / 2 + 60 + width - 120, screenY / 2 - 70 / 2 + 202 - 9 + 30, (inSlot2 and tocolor(r, g, b, alpha) or tocolor(130, 130, 130, alpha)), 1, fonts["Roboto-11"], "center", "center", false, false, false, true)

    dxDrawText("Megszeretnéd hosszabítani az adott ingatlant?\nIngatlan név: "..serverHex..rentedInteriorName, screenX / 2 - width / 2, screenY / 2 - 70 / 2 + 70, screenX / 2 - width / 2 + width, screenY / 2 - 70 / 2 + 70 + 70, tocolor(130, 130, 130, alpha), 1, fonts["Roboto-11"], "center", "center", false, false, false, true)]]

    if clickedPed and isElement(clickedPed) and getDistanceBetweenPoints3D(localPlayer.position, clickedPed.position) > 3 then 
        if not closing then 
            start3 = false 
            startTick3 = getTickCount()
            closing = true 
        end
    end
end

function onConfirmKey(button, state)
    if exports["cr_network"]:getNetworkStatus() then 
        return 
    end

    if button == "mouse1" then 
        if state then 
            if checkRender("renderConfirm") then 
                if buyHover then 
                    if start2 then 
                        startTick2 = getTickCount()
                        start2 = false
                        buyKey = false
                        buyTick = 0
    
                        if interiorDatas[5] ~= 3 and interiorDatas[5] ~= 7 then 
                            if localPlayer:getData("char >> interiorLimit") >= getPlayerInteriors() + 1 then 
                                triggerServerEvent("buyInterior", localPlayer, localPlayer, (not sourceMarker:getData("marker >> data") and sourceMarker:getData("parent") or sourceMarker))
                            else 
                                return exports["cr_infobox"]:addBox("error", "Nem tudod megvenni az ingatlant, mivel az már meghaladná a limitet.")
                            end
                        else 
                            if localPlayer:getData("char >> interiorLimit") >= getPlayerInteriors() + 1 then 
                                triggerServerEvent("rentInterior", localPlayer, localPlayer, (not sourceMarker:getData("marker >> data") and sourceMarker:getData("parent") or sourceMarker), interiorDatas[5])
                            else 
                                local text = interiorDatas[5] == 3 and "Nem tudod kibérelni az ingatlant, mivel az már meghaladná a limitet." or "Nem tudod kibérelni a farmot, mivel az már meghaladná a limitet."
                                
                                exports["cr_infobox"]:addBox("error", text)
                                return
                            end
                        end
                    end
                elseif cancelHover then 
                    startTick2 = getTickCount()
                    start2 = false
                    cancelKey = false
                    cancelTick = 0
                end
            elseif checkRender("renderRent") then 
                if rentExpireHover then 
                    if start3 then 
                        -- local allMoney = 0

                        -- if #rentData == 1 then 
                        --     allMoney = tonumber(rentData[1].price)
                        -- elseif #rentData > 1 then
                        --     for k, v in pairs(rentData) do 
                        --         allMoney = allMoney + tonumber(v.price)
                        --     end
                        -- end

                        local data = {}

                        for k, v in pairs(selectedInteriors) do 
                            if rentDataByDbId[k] then 
                                table.insert(data, rentDataByDbId[k])
                            end
                        end

                        if #data > 0 then 
                            startTick3 = getTickCount()
                            start3 = false
                            expireTick = 0
                            triggerServerEvent("renewInterior", localPlayer, data)
                        else
                            exports.cr_infobox:addBox("error", "Legalább 1 ingatlant kell kiválasztanod.")
                        end
                    end
                elseif rentResignationHover then 
                    if start3 then 
                        -- local allMoney = 0

                        -- if #rentData == 1 then 
                        --     allMoney = tonumber(rentData[1].price)
                        -- elseif #rentData > 1 then
                        --     for k, v in pairs(rentData) do 
                        --         allMoney = allMoney + tonumber(v.price)
                        --     end
                        -- end

                        local data = {}

                        for k, v in pairs(selectedInteriors) do 
                            if rentDataByDbId[k] then 
                                table.insert(data, rentDataByDbId[k])
                            end
                        end

                        if #data > 0 then 
                            startTick3 = getTickCount()
                            start3 = false
                            resignationTick = 0
                            triggerServerEvent("resignateInterior", localPlayer, data)
                        else 
                            exports.cr_infobox:addBox("error", "Legalább 1 ingatlant kell kiválasztanod.")
                        end
                    end
                elseif hoverInteriorRow then
                    if not selectedInteriors[hoverInteriorRow] then 
                        selectedInteriors[hoverInteriorRow] = true
                    else
                        selectedInteriors[hoverInteriorRow] = nil
                    end
                end
            end
        end
    elseif button == "backspace" then 
        if state then 
            if checkRender("renderRent") then 
                if not closing then 
                    start3 = false 
                    startTick3 = getTickCount()
                    closing = true 
                end
            end
        end
    end
end

function destroyCustomInterior(id)
    if #customInteriorObjects > 0 then 
        for i = 1, #customInteriorObjects do 
            local v = customInteriorObjects[i]

            if isElement(v) then 
                v:destroy()
            end
        end

        customInteriorObjects = {}
    end
end
addEvent("destroyCustomInterior", true)
addEventHandler("destroyCustomInterior", root, destroyCustomInterior)

function loadCustomInterior(id, element)
    if id then 
        if customGameInteriors[id] then 
            destroyCustomInterior(id)

            for k, v in pairs(customGameInteriors[id]) do 
                local id, x, y, z, rx, ry, rz = unpack(v)
                local obj = createObject(id, x, y, z, rx, ry, rz)

                if isElement(obj) then 
                    setElementInterior(obj, element.interior)
                    setElementDimension(obj, element.dimension)

                    setObjectBreakable(obj, false)
                    setElementDoubleSided(obj, true)

                    table.insert(customInteriorObjects, obj)
                end
            end
        end
    end
end
addEvent("loadCustomInterior", true)
addEventHandler("loadCustomInterior", root, loadCustomInterior)

-- CUSTOM MARKER

local cache = {}
local maxDistance = 45
local renderCache = {}

function createDisc(sourceElement)
    if sourceElement:getData("parent") or (sourceElement:getData("marker >> data") and sourceElement:getData("marker >> data")["elevator"]) then 
        local element = Object(1962, sourceElement.position)
        element.collisions = false 
        element.alpha = 0
        element.scale = 0.01
        element.dimension = sourceElement.dimension 
        element.interior = sourceElement.interior 
        element:attach(sourceElement, 0, 0, 0.5)
        cache[sourceElement] = {
            ["element"] = element,
            ["color"] = {convertColor((sourceElement ~= sourceElement:getData("parent") and sourceElement:getData("marker >> data") or sourceElement:getData("parent"):getData("marker >> data")))},
            ["type"] = (sourceElement ~= sourceElement:getData("parent") and sourceElement:getData("marker >> data") or sourceElement:getData("parent"):getData("marker >> data"))["type"],
        } 
    end 
end
addEvent("interior.createDisc", true)
addEventHandler("interior.createDisc", root, createDisc)

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        for k,v in pairs(getElementsByType("marker", root, true)) do 
            createDisc(v)
        end 
    end 
)

addEventHandler("onClientElementStreamIn", root,
	function()
        if source.type == "marker" then 
            createDisc(source) 
        end 
	end
)

addEventHandler("onClientElementStreamOut", root,
    function()
        if cache[source] then 
            if isElement(cache[source]["element"]) then 
                cache[source]["element"]:destroy()
            end 
            cache[source] = nil
            renderCache[source] = nil 
            collectgarbage("collect")
        end 
	end
)

addEventHandler("onClientElementDestroy", root,
	function()
        if cache[source] then 
            if isElement(cache[source]["element"]) then 
                cache[source]["element"]:destroy()
            end 
            cache[source] = nil
            renderCache[source] = nil 
            collectgarbage("collect")
        end 
	end
)

addEventHandler("onClientElementDataChange", root,
    function(dataName, oldValue, newValue)
        if source.type == "marker" then 
            if dataName == "marker >> data" then 
                if cache[source] or cache[source:getData("parent")] then 
                    if cache[source] then 
                        cache[source]["color"] = {convertColor((localPlayer:getInterior() > 0 and source:getData("parent"):getData("marker >> data") or source:getData("marker >> data")))}
                    elseif cache[source:getData("parent")] then 
                        cache[source:getData("parent")]["color"] = {convertColor(source:getData("marker >> data"))}
                    end
                end
            end
        -- elseif source.type == "player" and source == localPlayer then
        --     if dataName == "customInterior" then 
        --         if newValue ~= oldValue then 
        --             loadCustomInterior(newValue, source)
        --         end
        --     end
        end
    end
)

setTimer(
    function()
        renderCache = {}

        local cameraX, cameraY, cameraZ = getCameraMatrix()
        local bigmapIsVisible = localPlayer:getData("bigmapIsVisible")

        for k, v in pairs(cache) do
            local boneX, boneY, boneZ = getElementPosition(v["element"])
            if isElement(k) and isElementStreamedIn(k) and not k:getData("marker >> invisible") then
                local distance = math.sqrt((cameraX - boneX) ^ 2 + (cameraY - boneY) ^ 2 + (cameraZ - boneZ) ^ 2)
                local sightLine = isLineOfSightClear(cameraX, cameraY, cameraZ, boneX, boneY, boneZ, true, true, false, true, false, false, false, localPlayer)

                cache[k].distance = distance
                cache[k].sightLine = sightLine
                cache[k].bigmapIsVisible = bigmapIsVisible

                if distance <= maxDistance then
                    renderCache[k] = v
                end
            end
        end
    end, 150, 0
)

local textures = {}
    
_dxDrawImage = dxDrawImage
function dxDrawImage(x,y,w,h,img, r, rx, ry, color, postgui)
    if type(img) == "string" then
        if not textures[img] then
            textures[img] = dxCreateTexture(img, "argb", true, "clamp")
        end
        img = textures[img]
    end
    return _dxDrawImage(x,y,w,h,img, r, rx, ry, color, postgui)
end

function convertColor(data)
    local r, g, b = 255, 255, 255
    if not data["owner"] then 
        if data["type"] == 3 then 
            r, g, b = 226, 55, 55
        elseif data["type"] == 5 then 
            r, g, b = 255, 255, 255
        else
            if not data["owner"] and data["type"] == 1 then 
                r, g, b = exports["cr_core"]:getServerColor("green", false)
            else
                r, g, b = convertType(data["type"])
            end
        end
    else
        r, g, b = convertType(data["type"])
    end

    return r, g, b
end

local realMaxDistance = 30

function renderIcons()
    local nowTick = getTickCount()
    local y, z, _alpha = interpolateBetween(0, 0, 0.1, 25, 0.05, 1, (nowTick - startTick) / 2000, "CosineCurve")

    for key, value in pairs(renderCache) do 
        local markerX, markerY, markerZ = getElementPosition(key)
        local distance = value["distance"]
        if distance <= maxDistance then 
            local r, g, b = unpack(value["color"])
            local type = value["type"]

            local size = 1 - (distance / maxDistance)
            local _alpha = (255 * size) * _alpha
            local theX, theY = getScreenFromWorldPosition(key.position.x, key.position.y, key.position.z + 1.0)
            
            if theX and theY and value.sightLine and not value.bigmapIsVisible then 
                if distance <= realMaxDistance then 
                    local size = 1 - (distance / realMaxDistance)
                    local iconSize = 128 * size

                    dxDrawImage(theX - iconSize / 2, theY + (y * size) - iconSize / 2, iconSize, iconSize, customMarkerTextures[type], 0, 0, 0, tocolor(r, g, b, _alpha))
                end 
            end

            local markerSize = getMarkerSize(key)
            dxDrawCircle3D(markerX, markerY, ((markerZ + 0.15)) + (0 * 0.1), markerSize * 0.5, tocolor(r, g, b, _alpha), 2, 10)
            dxDrawCircle3D(markerX, markerY, ((markerZ + 0.15 + z)) + (1 * 0.1), markerSize * 0.5, tocolor(r, g, b, _alpha), 1.5, 10)
            dxDrawCircle3D(markerX, markerY, ((markerZ + 0.15 + z)) + (2 * 0.1), markerSize * 0.5, tocolor(r, g, b, _alpha), 1.5, 10)
            
            -- markerZ = markerZ + 0.8 + z
            -- dxDrawMaterialLine3D(markerX, markerY, markerZ + 0.32, markerX, markerY, markerZ - 0.32, customMarkerTextures[type], 0.64, tocolor(r, g, b))
        end
    end
end
createRender("renderIcons", renderIcons)

function dxDrawCircle3D(x, y, z, radius, color, width, segments)
    segments = segments or 6
    color = color --or tocolor(248, 126, 136, 200)  
    width = width or 1 

    local segAngle = 360 / segments 
    local fX, fY, tX, tY  
    local alpha = 20
    for key = 1, segments do 
        fX = x + math.cos(math.rad(segAngle * key)) * radius 
        fY = y + math.sin(math.rad(segAngle * key)) * radius 
        tX = x + math.cos(math.rad(segAngle * (key + 1))) * radius  
        tY = y + math.sin(math.rad(segAngle * (key + 1))) * radius 
        dxDrawLine3D(fX, fY, z, tX, tY, z, color, width)
    end 
end

function receiveSound(thePlayer, element, file)
    local soundElement = Sound3D("files/sounds/"..file..".mp3", element.position)
    soundElement:setVolume(0.7)
    soundElement:setMaxDistance(35)
    soundElement:setInterior(element.interior)
    soundElement:setDimension(element.dimension)
end
addEvent("receiveSound", true)
addEventHandler("receiveSound", root, receiveSound)

addEvent("receiveRentedInterior", true)
addEventHandler("receiveRentedInterior", root,
    function(data)
        -- iprint(data.isFarm, type(data.isFarm), data)
        rentData = {}
        rentDataByDbId = {}
        rentMaxLines = math.min(_rentMaxLines, #data)

        for k, v in pairs(data) do 
            table.insert(rentData, v)

            rentDataByDbId[tonumber(v.id)] = v
        end

        if #data > 0 then
            createRender("renderRent", renderRent)
            removeEventHandler("onClientKey", root, onConfirmKey)
            addEventHandler("onClientKey", root, onConfirmKey)

            start3 = true 
            startTick3 = getTickCount()
        else 
            exports.cr_infobox:addBox("error", "Neked jelenleg nincsen ingatlanod, amit kezelni tudnál.")
        end
    end
)

function getPlayerInteriors()
    local playerInteriors = 0
    local ownerId = localPlayer:getData("acc >> id")
    for key, value in pairs(getElementsByType("marker", resourceRoot)) do 
        local data = value:getData("marker >> data")
        if data then 
            if data["owner"] then
                if tonumber(data["owner"]) == ownerId then
                    playerInteriors = playerInteriors + 1
                end
            end
        end
    end
    return playerInteriors
end

function getPlayersInTheSameInterior(element)
    local cache = {}
    for key, value in pairs(getElementsByType("player")) do 
        if value:getData("loggedIn") then 
            if value.interior == element.interior and value.dimension == element.dimension then 
                table.insert(cache, value)
            end
        end
    end
    return cache
end

function getAdminSyntax()
    return exports["cr_admin"]:getAdminSyntax()
end

function getAdminName(thePlayer, bool)
    return exports["cr_admin"]:getAdminName(thePlayer, bool)
end

function sendMessageToAdmin(thePlayer, text, level)
    return exports["cr_core"]:sendMessageToAdmin(thePlayer, text, level)
end

function getServerColor(color, bool)
    return exports["cr_core"]:getServerColor(color, bool)
end

function alertAdmins(text)
    sendMessageToAdmin(localPlayer, getAdminSyntax()..getServerColor("yellow", true)..getAdminName(localPlayer, true)..text, 3)
end
addEvent("alertAdmins", true)
addEventHandler("alertAdmins", root, alertAdmins)

-- UTILS

function dxDrawOuterBorder(x, y, w, h, borderSize, borderColor, postGUI)
	borderSize = borderSize or 2
	borderColor = borderColor or tocolor(0, 0, 0, 255)
	
	dxDrawRectangle(x - borderSize, y - borderSize, w + (borderSize * 2), borderSize, borderColor, postGUI)
	dxDrawRectangle(x, y + h, w, borderSize, borderColor, postGUI)
	dxDrawRectangle(x - borderSize, y, borderSize, h + borderSize, borderColor, postGUI)
	dxDrawRectangle(x + w, y, borderSize, h + borderSize, borderColor, postGUI)
end

function formatMoney(value)
    return exports["cr_dx"]:formatMoney(value)
end

function isInSlot(x, y, w, h)
    return exports["cr_core"]:isInSlot(x, y, w, h)
end

function drawTooltip(type, text, spec)
    return exports["cr_dx"]:drawTooltip(type, text, spec)
end