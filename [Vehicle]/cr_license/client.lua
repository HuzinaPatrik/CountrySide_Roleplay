local screenX, screenY = guiGetScreenSize()

function openIdentity(id, itemid, value, nbt, slot)
    if not start then 
        start = true 

        gId = id 
        gData = value
        gItemID = itemid
        gSlot = slot
        gNBT = nbt

        if itemid == 78 then 
            exports['cr_chat']:createMessage(localPlayer, 'elővesz egy személyi igazolványt', 1)
        elseif itemid == 77 then 
            exports['cr_chat']:createMessage(localPlayer, 'elővesz egy vezetői engedélyt', 1)
        elseif itemid == 25 then
            exports['cr_chat']:createMessage(localPlayer, 'elővesz egy fegyverviselési engedélyt', 1)
        elseif itemid == 28 then 
            exports['cr_chat']:createMessage(localPlayer, 'elővesz egy horgász engedélyt', 1)
        elseif itemid == 148 then
            exports['cr_chat']:createMessage(localPlayer, 'elővesz egy egészségügyi kártyát', 1)
        elseif itemid == 149 then
            exports['cr_chat']:createMessage(localPlayer, 'elővesz egy önkormányzati azonosítót', 1)
        end 

        createRender("renderIdentity", renderIdentity)

        exports['cr_interface']:setNode("identity", "active", true)

        exports["cr_dx"]:startFade("identity", 
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

        return true 
    else 
        if id == gId then 
            start = false 

            if itemid == 78 then 
                exports['cr_chat']:createMessage(localPlayer, 'elrak egy személyi igazolványt', 1)
            elseif itemid == 77 then 
                exports['cr_chat']:createMessage(localPlayer, 'elrak egy vezetői engedélyt', 1)
            elseif itemid == 25 then
                exports['cr_chat']:createMessage(localPlayer, 'elrak egy fegyverviselési engedélyt', 1)
            elseif itemid == 28 then 
                exports['cr_chat']:createMessage(localPlayer, 'elrak egy horgász engedélyt', 1)
            elseif itemid == 148 then 
                exports['cr_chat']:createMessage(localPlayer, 'elrak egy egészségügyi kártyát', 1)
            elseif itemid == 149 then 
                exports['cr_chat']:createMessage(localPlayer, 'elrak egy önkormányzati azonosítót', 1)
            end 

            exports['cr_interface']:setNode("identity", "active", false)

            exports["cr_dx"]:startFade("identity", 
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

            return false 
        end 
    end 

    return '' 
end 

col = createColSphere(2275.240234375, -69.23193359375, 26.78125, 10)

local sx, sy = guiGetScreenSize()
function renderIdentity()
    local alpha, progress = exports["cr_dx"]:getFade("identity")
    if not start then
        if progress >= 1 then 
            destroyRender("renderIdentity")

            return
        end
    end

    local font = exports['cr_fonts']:getFont('Poppins-Bold', 14)
    local font2 = exports['cr_fonts']:getFont('Poppins-Regular', 12)
    local signatureFont = exports['cr_fonts']:getFont('DanielsSignature', 14)

    hover = nil

    local imagePath = paths[gItemID]
    local w, h = 375, 175
    local x, y = exports['cr_interface']:getNode("identity", "x"), exports['cr_interface']:getNode("identity", "y")

    dxDrawImage(x, y, w, h, imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha))

    if gItemID == 25 then
        local font3 = exports.cr_fonts:getFont("Poppins-Medium", 14)
        local font4 = exports.cr_fonts:getFont("Poppins-Medium", 13)
        local signatureFont = exports.cr_fonts:getFont("DanielsSignature", 17)
        local orange = "#f2994a"

        dxDrawText("Név: " .. orange .. gData.name, x + 40, y + 65, x + 40, y + 65, tocolor(242, 242, 242, alpha), 1, font3, "left", "top", false, false, false, true)
        dxDrawText("Nem: " .. orange .. genders[gData.gender], x + 40, y + 85, x + 40, y + 85, tocolor(242, 242, 242, alpha), 1, font4, "left", "top", false, false, false, true)
        dxDrawText("Érvényesség: " .. orange .. exports.cr_core:formatTimeStamp(gData.endDate, true), x + 40, y + 105, x + 40, y + 105, tocolor(242, 242, 242, alpha), 1, font4, "left", "top", false, false, false, true)
        dxDrawText(gData.name, x + 105, y + 133, x + 105, y + 133, tocolor(242, 242, 242, alpha), 1, signatureFont, "center", "top")
    elseif gItemID == 82 then
        local font3 = exports.cr_fonts:getFont("Poppins-Medium", 14)
        local font4 = exports.cr_fonts:getFont("Poppins-Medium", 13)
        local signatureFont = exports.cr_fonts:getFont("DanielsSignature", 17)
        local orange = "#f2994a"

        dxDrawText("Név: " .. orange .. gData.name, x + 50, y + 60, x + 50, y + 65, tocolor(242, 242, 242, alpha), 1, font3, "left", "top", false, false, false, true)
        dxDrawText("Nem: " .. orange .. genders[gData.gender], x + 50, y + 80, x + 50, y + 85, tocolor(242, 242, 242, alpha), 1, font4, "left", "top", false, false, false, true)
        dxDrawText("Érvényesség: " .. orange .. exports.cr_core:formatTimeStamp(gData.endDate, true), x + 50, y + 100, x + 50, y + 105, tocolor(242, 242, 242, alpha), 1, font4, "left", "top", false, false, false, true)
        dxDrawText(gData.name, x + 125, y + 125, x + 105, y + 133, tocolor(242, 242, 242, alpha), 1, signatureFont, "center", "top")
    elseif gItemID == 148 then 
        local font3 = exports.cr_fonts:getFont("Poppins-Medium", 14)
        local font4 = exports.cr_fonts:getFont("Poppins-Medium", 13)
        local orange = "#f2994a"

        dxDrawText("Név: " .. orange .. gData.name, x + 120, y + 45, x + 120, y + 45, tocolor(242, 242, 242, alpha), 1, font3, "left", "top", false, false, false, true)
        dxDrawText("Nem: " .. orange .. genders[gData.gender], x + 120, y + 65, x + 120, y + 45, tocolor(242, 242, 242, alpha), 1, font4, "left", "top", false, false, false, true)
        dxDrawText("Érvényesség: " .. orange .. exports.cr_core:formatTimeStamp(gData.endDate, true), x + 120, y + 85, x + 120, y + 45, tocolor(242, 242, 242, alpha), 1, font4, "left", "top", false, false, false, true)
    elseif gItemID == 149 then
        local font3 = exports.cr_fonts:getFont("Poppins-Medium", 14)
        local font4 = exports.cr_fonts:getFont("Poppins-Medium", 13)
        local font5 = exports.cr_fonts:getFont("Poppins-Medium", 16)
        local orange = "#f2994a"

        dxDrawText("Identity Card", x + 25, y + 60, x + 25, y + 60, tocolor(242, 242, 242, alpha), 1, font5, "left", "top")
        dxDrawText("Név: " .. orange .. gData.name, x + 25, y + 85, x + 25, y + 85, tocolor(242, 242, 242, alpha), 1, font3, "left", "top", false, false, false, true)
        dxDrawText("Beosztás: " .. orange .. gData.rank, x + 25, y + 105, x + 25, y + 105, tocolor(242, 242, 242, alpha), 1, font4, "left", "top", false, false, false, true)
        dxDrawText("Azonosító: " .. orange .. "#" .. orange .. gData.serial, x + 25, y + 125, x + 25, y + 125, tocolor(242, 242, 242, alpha), 1, font4, "left", "top", false, false, false, true)
    else 
        local identityPath = fileExists("assets/images/peds/" .. (gData.skinID or 0) .. ".png") and "assets/images/peds/" .. (gData.skinID or 0) .. ".png" or "assets/images/peds/0.png"

        dxDrawRectangle(x + 15, y + 35, 345, 2, tocolor(57, 57, 57, alpha * 0.8))
        dxDrawRectangle(x + 20, y + 45, 80, 100, tocolor(242, 242, 242, alpha * 0.8))
        dxDrawImage(x + 21, y + 46, 78, 98, identityPath, 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText(gData['name'], x + 280, y + 140, x + 280 + 80, y + 140, tocolor(242, 242, 242, alpha),1,signatureFont,"center","top",false, false, false)

        local orange = '#f2994a'
        dxDrawText('Név: '..orange..gData['name']..'#F2F2F2\nNem: '..orange..genders[gData['gender']]..'#F2F2F2' .. (gItemID ~= 77 and '' or ('\nKategória: '..orange..gData['category']..'#F2F2F2')) .. '\nKiállitás dátuma: '..orange..exports['cr_core']:formatTimeStamp(gData['startDate'], true)..'#F2F2F2\nÉrvényesség: '..orange..exports['cr_core']:formatTimeStamp(gData['endDate'], true), x + 120, y + 45, x + 120, y + 45, tocolor(242, 242, 242, alpha),1,font,"left","top",false, false, false, true)
    end

    if localPlayer:isWithinColShape(col) then
        if getRealTime()['timestamp'] > gData['endDate'] - (7 * 24 * 60 * 60) then
            local buttonW, buttonH = 200, 20
            local startY = y + h + 20

            if exports['cr_core']:isInSlot(x + w/2 - buttonW/2, startY, buttonW, buttonH) then 
                hover = true

                dxDrawRectangle(x + w/2 - buttonW/2, startY, buttonW, buttonH, tocolor(97, 177, 90, alpha)) 
                dxDrawText('Megújítás ($ '..cost..')', x, startY, x + w, startY + buttonH + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
            else
                dxDrawRectangle(x + w/2 - buttonW/2, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                dxDrawText('Megújítás ($ '..cost..')', x, startY, x + w, startY + buttonH + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
            end 
        end 
    end 
end 

lastClickTick = -1000
addEventHandler('onClientClick', root, 
    function(b, s)
        if b == 'left' and s == 'down' then 
            if start then 
                if hover then 
                    if exports['cr_network']:getNetworkStatus() then return end 

                    local now = getTickCount()
                    local a = 1
                    if now <= lastClickTick + a * 1000 then
                        return
                    end
                    lastClickTick = getTickCount()

                    if exports['cr_core']:takeMoney(localPlayer, cost) then 
                        gData['endDate'] = gData['endDate'] + (1 * 31 * 24 * 60 * 60)

                        exports['cr_inventory']:updateItemDetails(localPlayer, gSlot, exports['cr_inventory']:GetData(gItemID, gData, gNBT, 'invType'), {"value", gData}, true)

                        exports['cr_infobox']:addBox('success', 'Sikeresen megújítottad az iratot!')
                    end 

                    hover = nil
                end 
            end 
        end 
    end 
)
