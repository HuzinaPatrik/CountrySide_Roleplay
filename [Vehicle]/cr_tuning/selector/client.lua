isSelectorRender, selectorCache = false, {}

local selected, hornSound

function createSelector(data)
    if gSelected and gSelected2 then 
        playSound("files/sounds/menuenter.mp3")

        if not data then  
            data = {
                ["type"] = 1,
                ["now"] = 1,
                ["max"] = 5,  
            }
        end

        data["gSelected"] = gSelected
        data["gSelected2"] = gSelected2

        selectorCache = data

        if data["type"] == 8 then 
            CreateNewBar("plateText", {0,0,0,0}, {8, localPlayer.vehicle.plateText, false, tocolor(242,242,242,0), {'Poppins-Bold', realFontSize[12]}, 1, "center", "center", false}, 1)
        end 

        if data["type"] == 9 then 
            data["old"] = localPlayer.vehicle:getVariant()
        end 

        if selectorCache["lsdDoor"] then 
            local tuningData = localPlayer.vehicle:getData("veh >> tuningData") or {}
            if tonumber(tuningData["lsdDoor"] or 0) > 0 then 
                for i=2,5 do
                    setVehicleDoorOpenRatio(localPlayer.vehicle, i, 1, 250)
                end
            end 
        end

        exports['cr_dx']:startFade("selectorPanel", 
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

        if not isSelectorRender then 
            isSelectorRender = true 
            createRender("drawnSelector", drawnSelector)
            addEventHandler("onClientClick", root, selectorClickEvent)
        end 
    end
end 

function updateSelectorPosition(x, y)
    selectorCache["x"] = x
    selectorCache["y"] = y
end 

function destroySelector()
    if isSelectorRender then 
        removeEventHandler("onClientClick", root, selectorClickEvent)
        isSelectorRender = false 

        if selectorCache["type"] == 8 then 
            Clear()
        end 

        if isElement(hornSound) then 
            hornSound:destroy()
        end 

        if selectorCache["paintjob"] then 
            local tuningData = localPlayer.vehicle:getData("veh >> tuningData") or {}
            if tonumber(tuningData["paintjob"] or 0) > 0 then 
                applyPaintjob(localPlayer.vehicle, tonumber(tuningData["paintjob"] or 0))
            else 
                destroyPaintjob(localPlayer.vehicle)
            end 
        end 

        if selectorCache["lsdDoor"] then 
            for i=2,5 do
                setVehicleDoorOpenRatio(localPlayer.vehicle, i, 0, 250)
            end

            local tuningData = localPlayer.vehicle:getData("veh >> tuningData") or {}
            if tonumber(tuningData["lsdDoor"] or 0) > 0 then 
                addToCache(localPlayer.vehicle)
            else 
                removeFromCache(localPlayer.vehicle)
            end 
        end

        if selectorCache["type"] == 5 then 
            local val
            if selectorCache["tuningID"] == 3 then 
                val = selectorCache["specData"][tonumber((localPlayer.vehicle:getData("veh >> tuningData") or {})["frontwheel"] or 3)][1]
                setVehicleHandlingFlags(localPlayer.vehicle, 3, val)
            elseif selectorCache["tuningID"] == 4 then
                val = selectorCache["specData"][tonumber((localPlayer.vehicle:getData("veh >> tuningData") or {})["rearwheel"] or 3)][1]
                setVehicleHandlingFlags(localPlayer.vehicle, 4, val)
            end 
        end 

        if selectorCache["type"] == 2 or selectorCache["type"] == 3 then 
            local val = tonumber((localPlayer.vehicle:getData("veh >> tuningData") or {})["optical." .. selectorCache["tuningID"]] or 0)
            if val ~= selectorCache["now"] then 
                if selectorCache["now"] > 0 then 
                    removeVehicleUpgrade(localPlayer.vehicle, selectorCache["specData"][selectorCache["now"]])
                end

                if val > 0 then 
                    if selectorCache["specData"][val] then 
                        addVehicleUpgrade(localPlayer.vehicle, selectorCache["specData"][val])
                    end
                end 
            end 
        end 

        if selectorCache["type"] == 10 then 
            local val = tonumber((localPlayer.vehicle:getData("veh >> tuningData") or {})["neon"] or 0)
            if localPlayer.vehicle:getData("veh >> neon >> active") then 
                if val > 0 then 
                    addNeon(localPlayer.vehicle, val)
                else 
                    destroyNeon(localPlayer.vehicle)
                end 
            else
                destroyNeon(localPlayer.vehicle)
            end 
        end

        if selectorCache["type"] == 9 then 
            --triggerLatentServerEvent("addVariantTuning", 5000, false, localPlayer, localPlayer.vehicle, selectorCache["old"])
            local val = selectorCache["old"]
            localPlayer.vehicle:setVariant(val, val)
        end 


        exports['cr_dx']:startFade("selectorPanel", 
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

function drawnSelector()
    if not gSelected2 or selectorCache["gSelected2"] ~= gSelected2 then 
        destroySelector()
    end 

    if not gSelected or selectorCache["gSelected"] ~= gSelected then 
        destroySelector()
    end 

    local alpha, progress = exports['cr_dx']:getFade("selectorPanel")
    if not isSelectorRender then 
        if progress >= 1 then 
            if selectorCache["onFinish"] then 
                selectorCache["onFinish"]()
            end 
            selectorCache = nil
            destroyRender("drawnSelector")
            return 
        end 
    end 

    local x, y = selectorCache["x"], selectorCache["y"]
    if x and y then 
        local now, max = selectorCache["now"], selectorCache["max"]

        local font = exports['cr_fonts']:getFont('Poppins-Medium', realFontSize[14])
        local font2 = exports['cr_fonts']:getFont('Poppins-Bold', realFontSize[12])
        
        local w, h = respc(60) + (respc(10) * 2) + (respc(10) * 2) + (respc(16) * 2), respc(160)
        x = x - w/2
        y = y - h - respc(35)

        dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
        if exports['cr_core']:isInSlot(x, y, w, h) then 
            isCursorInPanel = true
        end 

        local w2, h2 = respc(60), respc(100)
        local startX, startY = x + respc(10) + respc(10) + respc(16), y + respc(15)

        local text = selectorCache["now"]
        if selectorCache["type"] == 3 or selectorCache["type"] == 4 then 
            text = tonumber(text) == 1 and "Igen" or "Nem"
        elseif selectorCache["type"] == 5 or selectorCache["type"] == 6 or selectorCache["type"] == 7 or selectorCache["type"] == 10 then 
            text = selectorCache["specData"][selectorCache["now"]][2]
        elseif selectorCache["type"] == 8 then 
            text = ""
            UpdatePos("plateText", {startX, startY + h2 - respc(2) - respc(20), w2, respc(20) + respc(4)})
	        UpdateAlpha("plateText", tocolor(242, 242, 242, alpha))
        end 

        dxDrawRectangle(startX, startY, w2, h2, tocolor(242,242,242,alpha))
        if gSelected and gSelected2 then 
            exports['cr_dx']:dxDrawImageAsTexture(startX + respc(2), startY + respc(2), w2 - respc(4), h2 - respc(4), ':cr_tuning/' .. buttons[gSelected]["buttons"][gSelected2]['imagePath'], 0, 0, 0, tocolor(255, 255, 255, alpha))
        end

        if text then 
            dxDrawRectangle(startX + respc(2), startY + h2 - respc(2) - respc(20), w2 - respc(4), respc(20), tocolor(51,51,51,alpha * 0.8))
            dxDrawText(text, startX, startY + h2 - respc(2) - respc(20), startX + w2, startY + h2 - respc(2) + respc(4), tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, true)
        end

        selected = nil 
        if selectorCache["type"] ~= 8 then 
            if exports['cr_core']:isInSlot(x + respc(10), startY + h2/2 - respc(31)/2, respc(16), respc(31)) then
                selected = "left"
                exports['cr_dx']:dxDrawImageAsTexture(x + respc(10), startY + h2/2 - respc(31)/2, respc(16), respc(31), ':cr_dashboard/assets/images/arrow.png', 180, 0, 0, tocolor(242, 242, 242, alpha))
            elseif getKeyState("arrow_l") and not isBuyRender then 
                exports['cr_dx']:dxDrawImageAsTexture(x + respc(10), startY + h2/2 - respc(31)/2, respc(16), respc(31), ':cr_dashboard/assets/images/arrow.png', 180, 0, 0, tocolor(242, 242, 242, alpha))
            else 
                exports['cr_dx']:dxDrawImageAsTexture(x + respc(10), startY + h2/2 - respc(31)/2, respc(16), respc(31), ':cr_dashboard/assets/images/arrow.png', 180, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
            end 

            if exports['cr_core']:isInSlot(x + respc(10) + respc(16) + respc(10) + respc(60) + respc(10), startY + h2/2 - respc(31)/2, respc(16), respc(31)) then
                selected = "right"
                exports['cr_dx']:dxDrawImageAsTexture(x + respc(10) + respc(16) + respc(10) + respc(60) + respc(10), startY + h2/2 - respc(31)/2, respc(16), respc(31), ':cr_dashboard/assets/images/arrow.png', 0, 0, 0, tocolor(242, 242, 242, alpha))
            elseif getKeyState("arrow_r") and not isBuyRender then 
                exports['cr_dx']:dxDrawImageAsTexture(x + respc(10) + respc(16) + respc(10) + respc(60) + respc(10), startY + h2/2 - respc(31)/2, respc(16), respc(31), ':cr_dashboard/assets/images/arrow.png', 0, 0, 0, tocolor(242, 242, 242, alpha))
            else 
                exports['cr_dx']:dxDrawImageAsTexture(x + respc(10) + respc(16) + respc(10) + respc(60) + respc(10), startY + h2/2 - respc(31)/2, respc(16), respc(31), ':cr_dashboard/assets/images/arrow.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
            end 
        end

        local y = y + respc(125)

        local w2, h2 = respc(110), respc(25)
        if getKeyState("enter") and progress >= 1 and isBuyRender and buyProgress < 1 or  getKeyState("enter") and progress >= 1 and not isBuyRender and not buyCache then 
            dxDrawRectangle(x + w/2 - w2/2, y, w2, h2, tocolor(97, 177, 90, alpha))
            dxDrawText("Vásárlás", x, y, x + w, y + h2 + respc(4), tocolor(242, 242, 242, alpha), 1, font, "center", "center")
        elseif exports['cr_core']:isInSlot(x + 2, y, w2, h2) then 
            selected = "finish"
            dxDrawRectangle(x + w/2 - w2/2, y, w2, h2, tocolor(97, 177, 90, alpha))
            dxDrawText("Vásárlás", x, y, x + w, y + h2 + respc(4), tocolor(242, 242, 242, alpha), 1, font, "center", "center")
        else 
            dxDrawRectangle(x + w/2 - w2/2, y, w2, h2, tocolor(97, 177, 90, alpha * 0.6))
            dxDrawText("Vásárlás", x, y, x + w, y + h2 + respc(4), tocolor(242, 242, 242, alpha * 0.7), 1, font, "center", "center")
        end 
    end
end

function selectorClickEvent(b, s)
    if isSelectorRender then 
        if b == "left" and s == "down" then 
            if selected == "left" then 
                selectorBack()
                selected = nil 
                return 
            elseif selected == "right" then 
                selectorNext()
                selected = nil 
                return 
            elseif selected == "finish" then 
                if selectorCache["type"] == 8 then 
                    selectorCache["now"] = GetText("plateText")
                end 
                if selectorCache["onEnter"] then 
                    selectorCache["onEnter"]()
                end 
                selected = nil 
                return 
            end 
        end 
    end 
end 

function selectorBack()
    if selectorCache["type"] == 8 then 
        return 
    end 

    local val = 0 
    if selectorCache["type"] == 5 or selectorCache["type"] == 6 or selectorCache["type"] == 7 then 
        val = 1
    end 

    if selectorCache["now"] - 1 >= val then 
        selectorCache["now"] = selectorCache["now"] - 1
        playSound("files/sounds/menunavigate.mp3")

        if selectorCache["isHorn"] then 
            if isElement(hornSound) then 
                hornSound:destroy()
            end 
            hornSound = playSound(horns[selectorCache["now"]])
        end 

        if selectorCache["paintjob"] then 
            if selectorCache["now"] > 0 then 
                applyPaintjob(localPlayer.vehicle, selectorCache["now"], true)
            else 
                destroyPaintjob(localPlayer.vehicle, true)
            end 
        end 

        if selectorCache["lsdDoor"] then 
            if selectorCache["now"] > 0 then 
                for i=2,5 do
                    setVehicleDoorOpenRatio(localPlayer.vehicle, i, 1, 250)
                end
                addToCache(localPlayer.vehicle)
            else 
                for i=2,5 do
                    setVehicleDoorOpenRatio(localPlayer.vehicle, i, 0, 250)
                end
                removeFromCache(localPlayer.vehicle)
            end 
        end

        if selectorCache["type"] == 2 or selectorCache["type"] == 3 then 
            if selectorCache["now"] > 0 then     
                addVehicleUpgrade(localPlayer.vehicle, selectorCache["specData"][selectorCache["now"]])
            else 
                removeVehicleUpgrade(localPlayer.vehicle, selectorCache["specData"][selectorCache["now"] + 1])
            end
        elseif selectorCache["type"] == 5 then 
            local val = selectorCache["specData"][selectorCache["now"]][1]
            if selectorCache["tuningID"] == 3 then 
                setVehicleHandlingFlags(localPlayer.vehicle, 3, val)
            elseif selectorCache["tuningID"] == 4 then
                setVehicleHandlingFlags(localPlayer.vehicle, 4, val)
            end 
        elseif selectorCache["type"] == 9 then 
            --triggerLatentServerEvent("addVariantTuning", 5000, false, localPlayer, localPlayer.vehicle, selectorCache["now"])
            local val = selectorCache["now"]
            localPlayer.vehicle:setVariant(val, val)
        elseif selectorCache["type"] == 10 then 
            if selectorCache["now"] > 0 then 
                addNeon(localPlayer.vehicle, selectorCache["now"])
            else 
                destroyNeon(localPlayer.vehicle)
            end 
        end 
    elseif selectorCache["now"] - 1 < val then 
        if selectorCache["type"] == 9 then 
            selectorCache["now"] = selectorCache["max"]
            playSound("files/sounds/menunavigate.mp3")

            --triggerLatentServerEvent("addVariantTuning", 5000, false, localPlayer, localPlayer.vehicle, selectorCache["now"])
            local val = selectorCache["now"]
            localPlayer.vehicle:setVariant(val, val)
        end
    end 
end 

function selectorNext()
    if selectorCache["type"] == 8 then 
        return 
    end 

    if selectorCache["now"] + 1 <= selectorCache["max"] then 
        selectorCache["now"] = selectorCache["now"] + 1
        playSound("files/sounds/menunavigate.mp3")

        if selectorCache["isHorn"] then 
            if isElement(hornSound) then 
                hornSound:destroy()
            end 
            hornSound = playSound(horns[selectorCache["now"]])
        end 

        if selectorCache["paintjob"] then 
            if selectorCache["now"] > 0 then 
                applyPaintjob(localPlayer.vehicle, selectorCache["now"], true)
            else 
                destroyPaintjob(localPlayer.vehicle, true)
            end 
        end 

        if selectorCache["lsdDoor"] then 
            if selectorCache["now"] > 0 then 
                for i=2,5 do
                    setVehicleDoorOpenRatio(localPlayer.vehicle, i, 1, 250)
                end
                addToCache(localPlayer.vehicle)
            else 
                for i=2,5 do
                    setVehicleDoorOpenRatio(localPlayer.vehicle, i, 0, 250)
                end
                removeFromCache(localPlayer.vehicle)
            end 
        end

        if selectorCache["type"] == 2 or selectorCache["type"] == 3 then 
            if selectorCache["now"] > 0 then     
                addVehicleUpgrade(localPlayer.vehicle, selectorCache["specData"][selectorCache["now"]])
            else 
                removeVehicleUpgrade(localPlayer.vehicle, selectorCache["specData"][selectorCache["now"] - 1])
            end
        elseif selectorCache["type"] == 5 then 
            local val = selectorCache["specData"][selectorCache["now"]][1]
            if selectorCache["tuningID"] == 3 then 
                setVehicleHandlingFlags(localPlayer.vehicle, 3, val)
            elseif selectorCache["tuningID"] == 4 then
                setVehicleHandlingFlags(localPlayer.vehicle, 4, val)
            end 
        elseif selectorCache["type"] == 9 then 
            --triggerLatentServerEvent("addVariantTuning", 5000, false, localPlayer, localPlayer.vehicle, selectorCache["now"])
            local val = selectorCache["now"]
            localPlayer.vehicle:setVariant(val, val)
        elseif selectorCache["type"] == 10 then 
            if selectorCache["now"] > 0 then 
                addNeon(localPlayer.vehicle, selectorCache["now"])
            else 
                destroyNeon(localPlayer.vehicle)
            end 
        end
    elseif selectorCache["now"] + 1 > selectorCache["max"] then 
        if selectorCache["type"] == 9 then 
            selectorCache["now"] = 0
            playSound("files/sounds/menunavigate.mp3")

            --triggerLatentServerEvent("addVariantTuning", 5000, false, localPlayer, localPlayer.vehicle, selectorCache["now"])
            local val = selectorCache["now"]
            localPlayer.vehicle:setVariant(val, val)
        end
    end 
end 


--
function setVehicleHandlingFlags(vehicle, byte, value)
    triggerLatentServerEvent("setVehicleHandlingFlags", 50000, false, localPlayer, vehicle, byte, value)
end