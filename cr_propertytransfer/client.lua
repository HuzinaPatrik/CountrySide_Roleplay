local screenX, screenY = guiGetScreenSize()
local dxDrawMultiplier = math.min(1, screenX / 1280)

function resp(val)
    return val * dxDrawMultiplier
end

function getRealFontSize(a)
    local a = resp(a)
    local val = ((a) - math.floor(a))
    if val < 0.5 then
        return math.floor(a)
    elseif val >= 0.5 then
        return math.ceil(a)
    end
end

local selectedPage = 1
local hoverSignature = false
local signatureSound = false

local isRender = false
local activeId = false

local propertyData = {
    sellerName = "Chiff Lee",
    buyerName = "Big Lee",

    vehiclePlateText = "ABC-123",
    vehicleChassis = "JCHEMDWXCV313JCHE",
    vehicleName = "McLaren P1",
    vehicleColor = {0, 0, 0, 0, 0, 0},
    hasExtra = "Van",

    engineLevel = 1,
    engineControllerLevel = 1,
    gearBoxLevel = 2,

    turboLevel = 3,
    suspensionLevel = 4,

    wheelsLevel = 5,
    weightLevel = 6,

    price = 5000,
    date = exports.cr_core:getDatum("."),

    registry = "Los Santos Government",
    interiorId = 15,

    interiorName = "Anystreet in Los Santos",
    interiorType = "Ház",
    interiorInnerId = 189
}

local lastTransferTick = -10000

function renderPropertyTransfer()
    local alpha, progress = exports.cr_dx:getFade("propertyTransfer")
    
    if alpha and progress then 
        if progress >= 1 and alpha <= 0 then 
            destroyRender("renderPropertyTransfer")

            return
        end
    end

    local nowTick = getTickCount()

    local font = exports.cr_fonts:getFont("ArchitectsDaughter-Regular", getRealFontSize(15))
    local font2 = exports.cr_fonts:getFont("ArchitectsDaughter-Regular", getRealFontSize(8))
    local font3 = exports.cr_fonts:getFont("DanielsSignature", getRealFontSize(22))

    local panelW, panelH = resp(540), resp(756)
    local panelX, panelY = screenX / 2 - panelW / 2, screenY / 2 - panelH / 2

    if selectedPage == 1 then 
        dxDrawImage(panelX, panelY, panelW, panelH, "files/images/vehiclebg.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        local textX, textY = panelX + resp(40), panelY + resp(137)
        dxDrawText(propertyData.sellerName, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "top")

        local textX, textY = panelX - resp(65), panelY + resp(158)
        dxDrawText(propertyData.buyerName, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "top")

        local textX, textY = panelX + resp(40), panelY + resp(225)
        dxDrawText(propertyData.vehiclePlateText, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "top")

        local textX, textY = panelX - resp(205), panelY + resp(250)
        local vehicleChassis = propertyData.vehicleChassis

        if utf8.len(vehicleChassis) > 5 then 
            vehicleChassis = utf8.sub(vehicleChassis, 1, -(utf8.len(vehicleChassis) - 5)) .. "..."
        end

        dxDrawText(vehicleChassis, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "top")

        local textX, textY = panelX + resp(65), panelY + resp(248)
        local vehicleName = propertyData.vehicleName

        if utf8.len(vehicleName) > 20 then 
            vehicleName = utf8.sub(vehicleName, 1, -(utf8.len(vehicleName) - 20)) .. "..."
        end

        dxDrawText(vehicleName, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "top")

        local textX, textY = panelX - resp(115), panelY + resp(43)
        dxDrawText(propertyData.vehiclePlateText, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = textX - resp(25), textY + resp(20)
        local vehicleBrand = propertyData.vehicleBrand

        if utf8.len(vehicleBrand) > 7 then 
            vehicleBrand = utf8.sub(vehicleBrand, 1, -(utf8.len(vehicleBrand) - 7)) .. "..."
        end

        dxDrawText(vehicleBrand, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX - resp(87), textY + resp(20)
        local vehicleChassis = propertyData.vehicleChassis

        if utf8.len(vehicleChassis) > 6 then 
            vehicleChassis = utf8.sub(vehicleChassis, 1, -(utf8.len(vehicleChassis) - 6)) .. "..."
        end

        dxDrawText(vehicleChassis, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX - resp(155), textY + resp(20)

        local hexColor1 = RGBToHex(propertyData.vehicleColor[1], propertyData.vehicleColor[2], propertyData.vehicleColor[3])
        local hexColor2 = RGBToHex(propertyData.vehicleColor[4], propertyData.vehicleColor[5], propertyData.vehicleColor[6])

        dxDrawText(hexColor1 .. "szín1 " .. hexColor2 .. "szín2", textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center", false, false, false, true)

        local textX, textY = panelX - resp(135), textY + resp(20)
        dxDrawText(propertyData.hasExtra, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(103), panelY + resp(42)
        dxDrawText(propertyData.engineLevel, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(143), panelY + resp(62)
        dxDrawText(propertyData.engineControllerLevel, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(103), panelY + resp(82)
        dxDrawText(propertyData.gearBoxLevel, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(103), panelY + resp(102)
        dxDrawText(propertyData.turboLevel, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(148), panelY + resp(122)
        dxDrawText(propertyData.suspensionLevel, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(103), panelY + resp(142)
        dxDrawText(propertyData.wheelsLevel, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(159), panelY + resp(162)
        dxDrawText(propertyData.weightLevel, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(118), panelY + resp(192)
        dxDrawText(propertyData.price, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        if signatureTick then 
            if propertyData.sellerNameLength then 
                local elapsedTime = nowTick - signatureTick
                local duration = 3000
                local progress = elapsedTime / duration

                propertyData.sellerLength = interpolateBetween(0, 0, 0, propertyData.sellerNameLength, 0, 0, progress, "Linear")

                if progress >= 1 then 
                    signatureTick = false
                    
                    propertyData.sellerNameLength = false
                    propertyData.signedSeller = true
                    propertyData.sellerLength = false

                    if isElement(propertyData.buyerElement) then 
                        triggerServerEvent("propertyTransfer.showPropertyTransfer", localPlayer, propertyData)

                        managePropertyTransfer("exit")
                    end
                end
            elseif propertyData.buyerNameLength then
                local elapsedTime = nowTick - signatureTick
                local duration = 3000
                local progress = elapsedTime / duration

                propertyData.buyerLength = interpolateBetween(0, 0, 0, propertyData.buyerNameLength, 0, 0, progress, "Linear")

                if progress >= 1 then 
                    signatureTick = false
                    
                    propertyData.buyerNameLength = false
                    propertyData.signedBuyer = true
                    propertyData.buyerLength = false

                    if isElement(propertyData.buyerElement) and isElement(propertyData.sellerElement) then 
                        if exports.cr_network:getNetworkStatus() then 
                            return
                        end

                        local nowTick = getTickCount()
                        local count = 10

                        if nowTick <= lastTransferTick + count * 1000 then
                            return
                        end

                        lastTransferTick = getTickCount()

                        triggerServerEvent("propertyTransfer.transferProperty", localPlayer, propertyData)
                        managePropertyTransfer("exit")
                    end
                end
            end
        end

        hoverSignature = nil

        local hoverW, hoverH = resp(185), resp(25)
        local hoverX, hoverY = panelX + resp(35), panelY + panelH - resp(110)
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

        if inSlot then 
            hoverSignature = "seller"
        end

        -- dxDrawRectangle(hoverX, hoverY, hoverW, hoverH, tocolor(124, 197, 118, math.min(150, alpha)))

        local textX, textY = panelX - resp(138), panelY + resp(277)
        local text = propertyData.sellerLength and utf8.sub(propertyData.sellerNameSignature, 1, propertyData.sellerLength) or propertyData.signedSeller and propertyData.sellerNameSignature or ""
        dxDrawText(text, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font3, "center", "center")

        local hoverW, hoverH = resp(185), resp(25)
        local hoverX, hoverY = panelX + resp(100) + hoverW, panelY + panelH - resp(110)
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)
        
        if inSlot then 
            hoverSignature = "buyer"
        end

        -- dxDrawRectangle(hoverX, hoverY, hoverW, hoverH, tocolor(124, 197, 118, math.min(150, alpha)))

        local textX = panelX + resp(110)
        local text = propertyData.buyerLength and utf8.sub(propertyData.buyerNameSignature, 1, propertyData.buyerLength) or propertyData.buyerNameSignature
        dxDrawText(text, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font3, "center", "center")

        local textX, textY = panelX - resp(145), panelY + resp(340)
        dxDrawText(propertyData.date, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")
    elseif selectedPage == 2 then 
        dxDrawImage(panelX, panelY, panelW, panelH, "files/images/interiorbg.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        local textX, textY = panelX + resp(55), panelY + resp(143)
        dxDrawText(propertyData.sellerName, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "top")

        local textX, textY = panelX - resp(50), panelY + resp(163)
        dxDrawText(propertyData.buyerName, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "top")

        local textX, textY = panelX + resp(15), panelY + resp(27)
        dxDrawText(propertyData.registry, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(15), panelY + resp(47)
        dxDrawText(propertyData.interiorId, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(15), panelY + resp(67)
        dxDrawText(propertyData.interiorName, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(15), panelY + resp(87)
        dxDrawText(propertyData.interiorType, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(15), panelY + resp(107)
        dxDrawText(propertyData.interiorInnerId, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(10), panelY + resp(226)
        dxDrawText(propertyData.price, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        if signatureTick then 
            if propertyData.sellerNameLength then 
                local elapsedTime = nowTick - signatureTick
                local duration = 3000
                local progress = elapsedTime / duration

                propertyData.sellerLength = interpolateBetween(0, 0, 0, propertyData.sellerNameLength, 0, 0, progress, "Linear")

                if progress >= 1 then 
                    signatureTick = false
                    
                    propertyData.sellerNameLength = false
                    propertyData.signedSeller = true
                    propertyData.sellerLength = false

                    if isElement(propertyData.buyerElement) then 
                        triggerServerEvent("propertyTransfer.showPropertyTransfer", localPlayer, propertyData)

                        managePropertyTransfer("exit")
                    end
                end
            elseif propertyData.buyerNameLength then
                local elapsedTime = nowTick - signatureTick
                local duration = 3000
                local progress = elapsedTime / duration

                propertyData.buyerLength = interpolateBetween(0, 0, 0, propertyData.buyerNameLength, 0, 0, progress, "Linear")

                if progress >= 1 then 
                    signatureTick = false
                    
                    propertyData.buyerNameLength = false
                    propertyData.signedBuyer = true
                    propertyData.buyerLength = false

                    if isElement(propertyData.buyerElement) and isElement(propertyData.sellerElement) then 
                        if exports.cr_network:getNetworkStatus() then 
                            return
                        end

                        local nowTick = getTickCount()
                        local count = 10

                        if nowTick <= lastTransferTick + count * 1000 then
                            return
                        end

                        lastTransferTick = getTickCount()

                        triggerServerEvent("propertyTransfer.transferProperty", localPlayer, propertyData)
                        managePropertyTransfer("exit")
                    end
                end
            end
        end

        hoverSignature = nil

        local hoverW, hoverH = resp(185), resp(25)
        local hoverX, hoverY = panelX + resp(50), panelY + panelH - resp(110)
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

        if inSlot then 
            hoverSignature = "seller"
        end

        -- dxDrawRectangle(hoverX, hoverY, hoverW, hoverH, tocolor(124, 197, 118, math.min(150, alpha)))

        local textX, textY = panelX - resp(120), panelY + resp(279)
        local text = propertyData.sellerLength and utf8.sub(propertyData.sellerNameSignature, 1, propertyData.sellerLength) or propertyData.signedSeller and propertyData.sellerNameSignature or ""
        dxDrawText(text, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font3, "center", "center")

        local textX = panelX + resp(125)
        local text = propertyData.buyerLength and utf8.sub(propertyData.buyerNameSignature, 1, propertyData.buyerLength) or propertyData.buyerNameSignature
        dxDrawText(text, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font3, "center", "center")

        local hoverW, hoverH = resp(185), resp(25)
        local hoverX, hoverY = panelX + resp(115) + hoverW, panelY + panelH - resp(110)
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)
        
        if inSlot then 
            hoverSignature = "buyer"
        end

        -- dxDrawRectangle(hoverX, hoverY, hoverW, hoverH, tocolor(124, 197, 118, math.min(150, alpha)))

        local textX, textY = panelX - resp(131), panelY + resp(340)
        dxDrawText(propertyData.date, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")
    elseif selectedPage == 3 then
        dxDrawImage(panelX, panelY, panelW, panelH, "files/images/vehiclebg.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        local textX, textY = panelX + resp(40), panelY + resp(137)
        dxDrawText(propertyData.sellerName, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "top")

        local textX, textY = panelX - resp(65), panelY + resp(158)
        dxDrawText(propertyData.buyerName, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "top")

        local textX, textY = panelX + resp(40), panelY + resp(225)
        dxDrawText(propertyData.vehiclePlateText, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "top")

        local textX, textY = panelX - resp(205), panelY + resp(250)
        local vehicleChassis = propertyData.vehicleChassis

        if utf8.len(vehicleChassis) > 5 then 
            vehicleChassis = utf8.sub(vehicleChassis, 1, -(utf8.len(vehicleChassis) - 5)) .. "..."
        end

        dxDrawText(vehicleChassis, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "top")

        local textX, textY = panelX + resp(65), panelY + resp(248)
        local vehicleName = propertyData.vehicleName

        if utf8.len(vehicleName) > 20 then 
            vehicleName = utf8.sub(vehicleName, 1, -(utf8.len(vehicleName) - 20)) .. "..."
        end

        dxDrawText(vehicleName, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "top")

        local textX, textY = panelX - resp(115), panelY + resp(43)
        dxDrawText(propertyData.vehiclePlateText, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = textX - resp(25), textY + resp(20)
        local vehicleBrand = propertyData.vehicleBrand

        if utf8.len(vehicleBrand) > 7 then 
            vehicleBrand = utf8.sub(vehicleBrand, 1, -(utf8.len(vehicleBrand) - 7)) .. "..."
        end

        dxDrawText(vehicleBrand, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX - resp(87), textY + resp(20)
        local vehicleChassis = propertyData.vehicleChassis

        if utf8.len(vehicleChassis) > 6 then 
            vehicleChassis = utf8.sub(vehicleChassis, 1, -(utf8.len(vehicleChassis) - 6)) .. "..."
        end

        dxDrawText(vehicleChassis, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX - resp(155), textY + resp(20)

        local hexColor1 = RGBToHex(propertyData.vehicleColor[1], propertyData.vehicleColor[2], propertyData.vehicleColor[3])
        local hexColor2 = RGBToHex(propertyData.vehicleColor[4], propertyData.vehicleColor[5], propertyData.vehicleColor[6])

        dxDrawText(hexColor1 .. "szín1 " .. hexColor2 .. "szín2", textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center", false, false, false, true)

        local textX, textY = panelX - resp(135), textY + resp(20)
        dxDrawText(propertyData.hasExtra, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(103), panelY + resp(42)
        dxDrawText(propertyData.engineLevel, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(143), panelY + resp(62)
        dxDrawText(propertyData.engineControllerLevel, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(103), panelY + resp(82)
        dxDrawText(propertyData.gearBoxLevel, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(103), panelY + resp(102)
        dxDrawText(propertyData.turboLevel, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(148), panelY + resp(122)
        dxDrawText(propertyData.suspensionLevel, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(103), panelY + resp(142)
        dxDrawText(propertyData.wheelsLevel, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(159), panelY + resp(162)
        dxDrawText(propertyData.weightLevel, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(118), panelY + resp(192)
        dxDrawText(propertyData.price, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX - resp(138), panelY + resp(277)
        local text = propertyData.sellerLength and utf8.sub(propertyData.sellerNameSignature, 1, propertyData.sellerLength) or propertyData.signedSeller and propertyData.sellerNameSignature or ""
        dxDrawText(text, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font3, "center", "center")

        local textX = panelX + resp(110)
        local text = propertyData.buyerLength and utf8.sub(propertyData.buyerNameSignature, 1, propertyData.buyerLength) or propertyData.buyerNameSignature
        dxDrawText(text, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font3, "center", "center")

        local textX, textY = panelX - resp(145), panelY + resp(340)
        dxDrawText(propertyData.date, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")
    elseif selectedPage == 4 then
        dxDrawImage(panelX, panelY, panelW, panelH, "files/images/interiorbg.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        local textX, textY = panelX + resp(55), panelY + resp(143)
        dxDrawText(propertyData.sellerName, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "top")

        local textX, textY = panelX - resp(50), panelY + resp(163)
        dxDrawText(propertyData.buyerName, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "top")

        local textX, textY = panelX + resp(15), panelY + resp(27)
        dxDrawText(propertyData.registry, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(15), panelY + resp(47)
        dxDrawText(propertyData.interiorId, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(15), panelY + resp(67)
        dxDrawText(propertyData.interiorName, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(15), panelY + resp(87)
        dxDrawText(propertyData.interiorType, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(15), panelY + resp(107)
        dxDrawText(propertyData.interiorInnerId, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX + resp(10), panelY + resp(226)
        dxDrawText(propertyData.price, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")

        local textX, textY = panelX - resp(120), panelY + resp(279)
        local text = propertyData.sellerLength and utf8.sub(propertyData.sellerNameSignature, 1, propertyData.sellerLength) or propertyData.signedSeller and propertyData.sellerNameSignature or ""
        dxDrawText(text, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font3, "center", "center")

        local textX = panelX + resp(125)
        local text = propertyData.buyerLength and utf8.sub(propertyData.buyerNameSignature, 1, propertyData.buyerLength) or propertyData.buyerNameSignature
        dxDrawText(text, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font3, "center", "center")

        local hoverW, hoverH = resp(185), resp(25)
        local hoverX, hoverY = panelX + resp(115) + hoverW, panelY + panelH - resp(110)
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)
        
        if inSlot then 
            hoverSignature = "buyer"
        end

        -- dxDrawRectangle(hoverX, hoverY, hoverW, hoverH, tocolor(124, 197, 118, math.min(150, alpha)))

        local textX, textY = panelX - resp(131), panelY + resp(340)
        dxDrawText(propertyData.date, textX, textY, textX + panelW, textY + panelH, tocolor(0, 86, 255, alpha), 1, font, "center", "center")
    end
end
-- createRender("renderPropertyTransfer", renderPropertyTransfer)

function managePropertyTransfer(state, ignoreKeyHandler)
    if state == "init" then 
        isRender = true

        if not ignoreKeyHandler then 
            removeEventHandler("onClientKey", root, onKey)
            addEventHandler("onClientKey", root, onKey)
        end

        createRender("renderPropertyTransfer", renderPropertyTransfer)

        exports.cr_dx:startFade("propertyTransfer", 
            {
                startTick = getTickCount(),
                lastUpdateTick = getTickCount(),
                time = 250,
                animation = "InOutQuad",
                from = 0,
                to = 255,
                alpha = 0,
                progress = 0
            }
        )
    elseif state == "exit" then
        if not ignoreKeyHandler then 
            removeEventHandler("onClientKey", root, onKey)
        end

        exports.cr_dx:startFade("propertyTransfer", 
            {
                startTick = getTickCount(),
                lastUpdateTick = getTickCount(),
                time = 250,
                animation = "InOutQuad",
                from = 255,
                to = 0,
                alpha = 255,
                progress = 0
            }
        )
    end
end

function showPropertyTransfer(element, targetElement, price)
    if isElement(element) and isElement(targetElement) and price then 
        if not exports.cr_inventory:hasItem(localPlayer, 26) then 
            exports.cr_infobox:addBox("error", "Nincs nálad üres adásvételi szerződés.")
            return
        end

        if localPlayer:getData("hasOnGoingTransfer") then 
            exports.cr_infobox:addBox("error", "Már folyamatban van egy szerződésed.")
            return
        end

        if element.type == "vehicle" then 
            selectedPage = 1

            local sellerAccId = localPlayer:getData("acc >> id")
            local vehicleOwnerId = element:getData("veh >> owner")
            local vehicleId = element:getData("veh >> id")
            local allVehicle = exports.cr_dashboard:getPlayerVehicles()

            if sellerAccId ~= vehicleOwnerId then 
                return
            end

            if getDistanceBetweenPoints3D(localPlayer.position, element.position) > 3 then 
                exports.cr_infobox:addBox("error", "Túl messze vagy a kiválasztott járműtől.")
                return
            end

            if vehicleId <= 0 then 
                exports.cr_infobox:addBox("error", "Munka, vagy bérelt járművet nem tudsz eladni.")
                return
            end

            local sellerName = exports.cr_admin:getAdminName(localPlayer)
            local buyerName = exports.cr_admin:getAdminName(targetElement)

            local vehiclePlateText = element.plateText
            local vehicleChassis = element:getData("veh >> chassis")

            local vehicleName = exports.cr_vehicle:getVehicleName(element)
            local vehicleBrand = exports.cr_carshop:getVehicleBrand(element)

            local r, g, b, r2, g2, b2 = getVehicleColor(element, true)
            local vehicleColor = {r, g, b, r2, g2, b2}

            local hasExtra = false
            local tuningData = element:getData("veh >> tuningData") or {}

            if tuningData.lsdDoor then 
                hasExtra = true
            end

            local engineLevel = tuningData.engine or 0
            local engineControllerLevel = tuningData.ecu or 0

            local gearBoxLevel = tuningData.gearbox or 0
            local turboLevel = tuningData.turbo or 0
            local suspensionLevel = tuningData.suspension or 0

            local wheelsLevel = tuningData.brakes or 0
            local weightLevel = tuningData.weight or 0

            propertyData = {
                sellerName = sellerName,
                buyerName = buyerName,

                sellerElement = localPlayer,
                buyerElement = targetElement,
                elementToSell = element,

                vehiclePlateText = vehiclePlateText,
                vehicleChassis = vehicleChassis,
                vehicleName = vehicleName,
                vehicleBrand = vehicleBrand,
                vehicleColor = vehicleColor,
                hasExtra = hasExtra and "Van" or "Nincs",

                engineLevel = engineLevel,
                engineControllerLevel = engineControllerLevel,
                gearBoxLevel = gearBoxLevel,

                turboLevel = turboLevel,
                suspensionLevel = suspensionLevel,

                wheelsLevel = wheelsLevel,
                weightLevel = weightLevel,

                price = price,
                date = exports.cr_core:getDatum("."),

                buyerNameSignature = "",
                page = "seller",

                allVehicle = #allVehicle,
                isVehicle = true
            }

            exports.cr_dashboard:closeDash()
            managePropertyTransfer("init")
        elseif element.type == "marker" then
            selectedPage = 2

            local sellerAccId = localPlayer:getData("acc >> id")
            local markerData = element:getData("marker >> data") or {}
            local allInterior = exports.cr_dashboard:getPlayerInterior()

            if not markerData then 
                return
            end

            local interiorOwnerId = markerData.owner

            if sellerAccId ~= interiorOwnerId then 
                return
            end

            if getDistanceBetweenPoints3D(localPlayer.position, element.position) > 3 then 
                exports.cr_infobox:addBox("error", "Túl messze vagy a kiválasztott ingatlantól.")
                return
            end

            if markerData.type == 3 then 
                exports.cr_infobox:addBox("error", "Bérházat nem tudsz eladni.")
                return
            end

            local sellerName = exports.cr_admin:getAdminName(localPlayer)
            local buyerName = exports.cr_admin:getAdminName(targetElement)

            local registry = "Red County Government"
            local interiorId = markerData.id

            local zoneName = getZoneName(element.position)
            local interiorName = zoneName .. " (" .. markerData.name .. ")"
            local interiorType = exports.cr_interior:convertInteriorType(markerData.type)

            local innerElement = element:getData("parent")
            local interiorInnerId = 0

            if isElement(innerElement) then 
                interiorInnerId = innerElement.interior
            end

            propertyData = {
                sellerName = sellerName,
                buyerName = buyerName,

                sellerElement = localPlayer,
                buyerElement = targetElement,
                elementToSell = element,

                price = price,
                date = exports.cr_core:getDatum("."),

                registry = registry,
                interiorId = interiorId,

                interiorName = interiorName,
                interiorType = interiorType,
                interiorInnerId = interiorInnerId,

                buyerNameSignature = "",
                page = "seller",

                allInterior = #allInterior,
                isInterior = true
            }

            exports.cr_dashboard:closeDash()
            managePropertyTransfer("init")
        end
    end
end

function showPropertyTransferContract(data, id)
    if data and type(data) == "table" then 
        if not id then 
            if not isRender then 
                propertyData = data
                selectedPage = propertyData.isVehicle and 3 or 4

                managePropertyTransfer("init", true)
            end
        else 
            if not isRender then 
                propertyData = data
                activeId = id
                selectedPage = propertyData.isVehicle and 3 or 4

                managePropertyTransfer("init", true)
                exports.cr_chat:createMessage(localPlayer, "elővesz egy adásvételi szerződést.", 1)

                return "init"
            else
                if id == activeId then 
                    isRender = false
                    activeId = false

                    managePropertyTransfer("exit", true)
                    exports.cr_chat:createMessage(localPlayer, "elrak egy adásvételi szerződést.", 1)

                    return "destroy"
                end
            end
        end
    end
end

function showPropertyTransferCallback(data)
    if activeId then 
        exports.cr_inventory:findAndUseItemByIDAndDBID(80, activeId)

        activeId = false
    end

    managePropertyTransfer("init")

    propertyData = data
    selectedPage = data.isVehicle and 1 or 2
    propertyData.page = "buyer"
end
addEvent("propertyTransfer.showPropertyTransferCallback", true)
addEventHandler("propertyTransfer.showPropertyTransferCallback", root, showPropertyTransferCallback)

function onKey(button, state)
    if button == "mouse1" and state then 
        if hoverSignature then 
            if hoverSignature == "seller" then 
                if propertyData.page == "seller" then 
                    if not signatureTick then 
                        if not propertyData.signedSeller then 
                            signatureTick = getTickCount()

                            propertyData.sellerNameSignature = exports.cr_admin:getAdminName(localPlayer)
                            propertyData.sellerNameLength = utf8.len(propertyData.sellerNameSignature)

                            if isElement(signatureSound) then 
                                signatureSound:destroy()
                                signatureSound = nil
                            end

                            signatureSound = playSound("files/sounds/sign.mp3")
                        else 
                            if not specData then 
                                local syntax = exports.cr_core:getServerSyntax("Property transfer", "error")

                                outputChatBox(syntax .. "Már aláírtad a szerződést.", 255, 0, 0, true)
                            end
                        end
                    end
                end
            elseif hoverSignature == "buyer" then
                if propertyData.page == "buyer" then 
                    if not signatureTick then 
                        if not propertyData.signedBuyer then 
                            signatureTick = getTickCount()

                            propertyData.buyerNameSignature = exports.cr_admin:getAdminName(localPlayer)
                            propertyData.buyerNameLength = utf8.len(propertyData.buyerNameSignature)

                            if isElement(signatureSound) then 
                                signatureSound:destroy()
                                signatureSound = nil
                            end

                            signatureSound = playSound("files/sounds/sign.mp3")
                        else 
                            if not specData then 
                                local syntax = exports.cr_core:getServerSyntax("Property transfer", "error")

                                outputChatBox(syntax .. "Már aláírtad a szerződést.", 255, 0, 0, true)
                            end
                        end
                    end
                end
            end
        end
    elseif button == "backspace" and state then
        if isRender then 
            isRender = false
            
            local sellerElement = propertyData.sellerElement
            if isElement(sellerElement) then 
                if sellerElement:getData("hasOnGoingTransfer") then 
                    sellerElement:setData("hasOnGoingTransfer", nil)
                end
            end

            managePropertyTransfer("exit")
        end
    end
end

function onClientQuit()
    if localPlayer:getData("hasOnGoingTransfer") then 
        local transferElement = localPlayer:getData("hasOnGoingTransfer")

        if transferElement == source then 
            exports.cr_infobox:addBox("error", "A játékos elhagyta a szervert, ezért az eladás megszakadt.")

            localPlayer:setData("hasOnGoingTransfer", nil)

            if isRender then 
                managePropertyTransfer("exit")
            end
        end
    end
end
addEventHandler("onClientPlayerQuit", root, onClientQuit)

function removeItem(id)
    local items = exports.cr_inventory:getItems(localPlayer, 2)

    if items then 
        for k, v in pairs(items) do 
            local dbId, itemid, value, count, status, dutyitem, premium, nbt = unpack(v)

            if itemid == id then 
                exports.cr_inventory:removeItemFromSlot(2, k)

                break
            end
        end
    end
end
addEvent("propertyTransfer.removeItem", true)
addEventHandler("propertyTransfer.removeItem", root, removeItem)

function updateProperty()
    isRender = false

    exports.cr_dashboard:getPlayerVehicles()
    exports.cr_dashboard:getPlayerInterior()
end
addEvent("propertyTransfer.updateProperty", true)
addEventHandler("propertyTransfer.updateProperty", root, updateProperty)

function RGBToHex(red, green, blue, alpha)
	if ((red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255))) then
		return nil
	end

	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end
end