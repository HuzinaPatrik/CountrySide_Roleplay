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

local textures = {}

function createTextures()
    textures = {}

    textures.notepad = ":cr_faction_scripts/ticket/files/images/notepad.png"
    textures.paper = ":cr_faction_scripts/ticket/files/images/paper.png"
    textures.small_logo = ":cr_faction_scripts/ticket/files/images/small_logo.png"
    textures.big_logo = ":cr_faction_scripts/ticket/files/images/big_logo.png"
end

local ticketData = {
    page = "createNewTicketMD",

    offenderName = "",
    offenderNameSignature = "",
    offenderLength = false,
    offenderNameLength = false,
    signedOffender = false,

    superVisorName = "",
    superVisorNameSignature = "",
    superVisorLength = false,
    superVisorNameLength = false,
    signedSuperVisor = false,

    reason = false,
    location = false,
    vehiclePlateText = false,
    issuingAuthority = false,
    date = false,
    penalty = false,
    otherReason = false
}

local hoverSignature = false
local hoverButton = false

local signatureTick = false
local signatureSound = false
local isRender = false
local specData = false

local textureDeleteTimer = false

function renderTicket()
    local nowTick = getTickCount()

    local alpha, progress = exports.cr_dx:getFade("ticketPanel")

    if alpha and progress then 
        if progress >= 1 and alpha <= 0 then 
            destroyRender("renderTicket")
            
            if isTimer(textureDeleteTimer) then 
                killTimer(textureDeleteTimer)
                textureDeleteTimer = nil
            end

            textureDeleteTimer = setTimer(
                function()
                    manageTextbars("destroy")
                    textures = {}

                    ticketData = {
                        page = "createNewTicketMD",
            
                        offenderName = "",
                        offenderNameSignature = "",
                        offenderLength = false,
                        offenderNameLength = false,
                        signedOffender = false,
                    
                        superVisorName = "",
                        superVisorNameSignature = "",
                        superVisorLength = false,
                        superVisorNameLength = false,
                        signedSuperVisor = false,
                    
                        reason = false,
                        location = false,
                        vehiclePlateText = false,
                        issuingAuthority = false,
                        date = false,
                        penalty = false,
                        otherReason = false
                    }
        
                    collectgarbage("collect")
                end, 500, 1
            )
        end
    end

    local font = exports.cr_fonts:getFont("Poppins-Bold", getRealFontSize(28))
    local font2 = exports.cr_fonts:getFont("Poppins-SemiBold", getRealFontSize(14))
    local font3 = exports.cr_fonts:getFont("Poppins-Medium", getRealFontSize(14))
    local font4 = exports.cr_fonts:getFont("Poppins-SemiBold", getRealFontSize(19))
    local font5 = exports.cr_fonts:getFont("Poppins-Bold", getRealFontSize(25))
    local font6 = exports.cr_fonts:getFont("Poppins-Regular", getRealFontSize(13))
    local font7 = exports.cr_fonts:getFont("BrushScriptMT", getRealFontSize(16))
    local font8 = exports.cr_fonts:getFont("Poppins-Bold", getRealFontSize(23))

    local redR, redG, redB = exports.cr_core:getServerColor("red", false)
    local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)

    if ticketData.page == "createNewTicket" then
        local bgW, bgH = resp(430), resp(662)
        local bgX, bgY = screenX / 2 - bgW / 2, screenY / 2 - bgH / 2

        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.notepad, 0, 0, 0, tocolor(255, 255, 255, alpha))

        local bgLogoW, bgLogoH = resp(232), resp(267)
        local bgLogoX, bgLogoY = bgX + bgW / 2 - bgLogoW / 2, bgY + bgH / 2 - bgLogoH / 2

        exports.cr_dx:dxDrawImageAsTexture(bgLogoX, bgLogoY, bgLogoW, bgLogoH, textures.big_logo, 0, 0, 0, tocolor(255, 255, 255, alpha))

        local logoW, logoH = resp(33), resp(38)
        local logoX, logoY = bgX + (logoW - resp(5)), bgY + (logoH * 2) + resp(10)

        exports.cr_dx:dxDrawImageAsTexture(logoX, logoY, logoW, logoH, textures.small_logo, 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText("BÍRSÁG", bgX, logoY + resp(4), bgX + bgW, logoY + logoH, tocolor(redR, redG, redB, alpha), 1, font, "center", "center")
        dxDrawText("Az alább feltüntetett személy szabálysértést\nkövetett el, a szabálysértés oka a következő:", logoX + (logoW / 2), logoY + logoH + resp(4), bgX + bgW, logoY + logoH + resp(70), tocolor(51, 51, 51, alpha), 1, font2, "left", "center")

        local lineW, lineH = bgW - resp(47), resp(1)
        local lineX, lineY = bgX + resp(47 / 2), logoY + logoH + resp(100)

        local reason = GetText("newTicket.reason")
        local inputW, inputH = lineW, resp(20)
        local inputX, inputY = lineX, lineY - inputH

        UpdatePos("newTicket.reason", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.reason", tocolor(51, 51, 51, alpha))

        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(51, 51, 51, alpha))

        local textX, textY = lineX + resp(5), lineY + resp(50)
        local _textX = textX

        dxDrawText("Helyszín:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW, inputH = resp(120), resp(20)
        local textWidth = dxGetTextWidth("Helyszín:", 1, font3)
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2

        UpdatePos("newTicket.location", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.location", tocolor(51, 51, 51, alpha))

        local textX = textX + resp(202)
        dxDrawText("Dátum:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local textWidth = dxGetTextWidth("Dátum:", 1, font3)
        local inputX, inputY = textX + textWidth + resp(5), inputY

        UpdatePos("newTicket.date", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.date", tocolor(51, 51, 51, alpha))

        local textX, textY = _textX, textY + resp(29)
        dxDrawText("Elkövető neve:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW = inputW + resp(150)
        local textWidth = dxGetTextWidth("Elkövető neve:", 1, font3)
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2
        
        UpdatePos("newTicket.offenderName", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.offenderName", tocolor(51, 51, 51, alpha))

        local textY = textY + resp(29)
        dxDrawText("Jármű rendszáma:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW = inputW - resp(30)
        local textWidth = dxGetTextWidth("Jármű rendszáma:", 1, font3)
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2
        
        UpdatePos("newTicket.vehiclePlateText", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.vehiclePlateText", tocolor(51, 51, 51, alpha))

        local textY = textY + resp(29)
        dxDrawText("Kiállító hatóság:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW = inputW + resp(10)
        local textWidth = dxGetTextWidth("Kiállító hatóság:", 1, font3)
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2

        UpdatePos("newTicket.issuingAuthority", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.issuingAuthority", tocolor(51, 51, 51, alpha))

        dxDrawText("Bírság összege:", bgX, bgY + resp(145), bgX + bgW, bgY + bgH, tocolor(51, 51, 51, alpha), 1, font4, "center", "center")

        local lineW = lineW / 2 + resp(30)
        local lineX, lineY = lineX + lineW / 2 - resp(30), lineY + resp(230)

        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(51, 51, 51, alpha))

        local textX, textY = lineX, lineY
        local penalty = GetText("newTicket.penalty")
        local textWidth = dxGetTextWidth(penalty, 1, font4)

        local inputW, inputH = lineW, resp(20)
        local inputX, inputY = textX, textY - inputH + resp(1)

        UpdatePos("newTicket.penalty", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.penalty", tocolor(51, 51, 51, alpha))

        dxDrawText("$", textX - textWidth - resp(25), textY, textX + lineW, textY + lineH + resp(10), tocolor(greenR, greenG, greenB, alpha), 1, font5, "center", "bottom")
        dxDrawText("Bírság infó:", logoX + (logoW / 2), bgY, bgX + bgW, bgY + bgH - resp(165), tocolor(51, 51, 51, alpha), 1, font3, "left", "bottom")

        local inputW, inputH = resp(360), resp(50)
        local inputX, inputY = logoX + (logoW / 2), lineY + resp(40)

        UpdatePos("newTicket.otherReason", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.otherReason", tocolor(51, 51, 51, alpha))

        if signatureTick then 
            if ticketData.offenderNameLength then 
                local elapsedTime = nowTick - signatureTick
                local duration = 3000
                local progress = elapsedTime / duration

                ticketData.offenderLength = interpolateBetween(0, 0, 0, ticketData.offenderNameLength, 0, 0, progress, "Linear")

                if progress >= 1 then 
                    signatureTick = false
                    
                    ticketData.offenderNameLength = false
                    ticketData.signedOffender = true
                    ticketData.offenderLength = false
                end
            elseif ticketData.superVisorNameLength then
                local elapsedTime = nowTick - signatureTick
                local duration = 3000
                local progress = elapsedTime / duration

                ticketData.superVisorLength = interpolateBetween(0, 0, 0, ticketData.superVisorNameLength, 0, 0, progress, "Linear")

                if progress >= 1 then 
                    signatureTick = false
                    
                    ticketData.superVisorNameLength = false
                    ticketData.signedSuperVisor = true
                    ticketData.superVisorLength = false
                end
            end
        end

        local text = ticketData.offenderLength and utf8.sub(ticketData.offenderNameSignature, 1, ticketData.offenderLength) or ticketData.offenderNameSignature
        dxDrawText("Szabályszegő aláírása", logoX - logoW - resp(205), bgY, bgX + bgW, bgY + bgH - resp(70), tocolor(51, 51, 51, alpha), 1, font3, "center", "bottom")
        dxDrawText(text, logoX - logoW - resp(205), bgY, bgX + bgW, bgY + bgH - resp(37), tocolor(51, 51, 51, alpha), 1, font7, "center", "bottom")

        hoverSignature = nil

        local hoverW, hoverH = resp(150), resp(30)
        local hoverX, hoverY = logoX + resp(15), inputY + resp(100)
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)
        if inSlot then 
            hoverSignature = "offender"
        end

        local text = ticketData.superVisorLength and utf8.sub(ticketData.superVisorNameSignature, 1, ticketData.superVisorLength) or ticketData.superVisorNameSignature
        dxDrawText("Eljáró felügyelő", logoX + resp(200), bgY, bgX + bgW, bgY + bgH - resp(70), tocolor(51, 51, 51, alpha), 1, font3, "center", "bottom")
        dxDrawText(text, logoX + resp(200), bgY, bgX + bgW, bgY + bgH - resp(37), tocolor(51, 51, 51, alpha), 1, font7, "center", "bottom")

        local hoverX, hoverY = hoverX + hoverW + resp(60), hoverY
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)
        if inSlot then 
            hoverSignature = "superVisor"
        end

        hoverButton = nil

        local buttonW, buttonH = resp(180), resp(25)
        local buttonX, buttonY = bgX + bgW / 2 - buttonW / 2, bgY + bgH + resp(5)
        local ticketAlpha = alpha * 0.7
        local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
        if inSlot then 
            hoverButton = "ticketButton"
            ticketAlpha = alpha
        end

        dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, tocolor(greenR, greenG, greenB, ticketAlpha))
        dxDrawText("Megírás", buttonX, buttonY + resp(4), buttonX + buttonW, buttonY + buttonH, tocolor(255, 255, 255, ticketAlpha), 1, font3, "center", "center")

        -- local buttonX = bgX + bgW - buttonW - (buttonW / 2)
        -- local cancelAlpha = 255 * 0.7
        -- local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
        -- if inSlot then 
        --     hoverButton = "cancelButton"
        --     cancelAlpha = 255
        -- end

        -- dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, tocolor(redR, redG, redB, cancelAlpha))
        -- dxDrawText("Mégse", buttonX, buttonY + resp(4), buttonX + buttonW, buttonY + buttonH, tocolor(255, 255, 255, cancelAlpha), 1, font3, "center", "center")
    elseif ticketData.page == "createNewTicketMD" then
        local bgW, bgH = resp(430), resp(662)
        local bgX, bgY = screenX / 2 - bgW / 2, screenY / 2 - bgH / 2

        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.notepad, 0, 0, 0, tocolor(255, 255, 255, alpha))

        local bgLogoW, bgLogoH = resp(232), resp(267)
        local bgLogoX, bgLogoY = bgX + bgW / 2 - bgLogoW / 2, bgY + bgH / 2 - bgLogoH / 2

        exports.cr_dx:dxDrawImageAsTexture(bgLogoX, bgLogoY, bgLogoW, bgLogoH, textures.big_logo, 0, 0, 0, tocolor(255, 255, 255, alpha))

        local logoW, logoH = resp(33), resp(38)
        local logoX, logoY = bgX + (logoW - resp(5)), bgY + (logoH * 2) + resp(10)

        exports.cr_dx:dxDrawImageAsTexture(logoX, logoY, logoW, logoH, textures.small_logo, 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText("EGÉSZSÉGÜGYI SZÁMLA", bgX, logoY + resp(4), bgX + bgW, logoY + logoH, tocolor(redR, redG, redB, alpha), 1, font8, "center", "center")
        dxDrawText("Az ellátás adatait alább találja.\nAz ellátás leírása:", logoX + (logoW / 2), logoY + logoH + resp(4), bgX + bgW, logoY + logoH + resp(70), tocolor(51, 51, 51, alpha), 1, font2, "left", "center")

        local lineW, lineH = bgW - resp(47), resp(1)
        local lineX, lineY = bgX + resp(47 / 2), logoY + logoH + resp(100)

        local reason = GetText("newTicket.reason")
        local inputW, inputH = lineW, resp(20)
        local inputX, inputY = lineX, lineY - inputH

        UpdatePos("newTicket.reason", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.reason", tocolor(51, 51, 51, alpha))

        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(51, 51, 51, alpha))

        local textX, textY = lineX + resp(5), lineY + resp(50)
        local _textX = textX

        dxDrawText("Helyszín:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW, inputH = resp(120), resp(20)
        local textWidth = dxGetTextWidth("Helyszín:", 1, font3)
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2

        UpdatePos("newTicket.location", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.location", tocolor(51, 51, 51, alpha))

        local textX = textX + resp(202)
        dxDrawText("Dátum:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local textWidth = dxGetTextWidth("Dátum:", 1, font3)
        local inputX, inputY = textX + textWidth + resp(5), inputY

        UpdatePos("newTicket.date", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.date", tocolor(51, 51, 51, alpha))

        local textX, textY = _textX, textY + resp(29)
        dxDrawText("Sérült neve:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW = inputW + resp(150)
        local textWidth = dxGetTextWidth("Sérült neve:", 1, font3)
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2
        
        UpdatePos("newTicket.offenderName", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.offenderName", tocolor(51, 51, 51, alpha))

        local textY = textY + resp(29)
        dxDrawText("Sérült testrész(ek):", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW = inputW - resp(30)
        local textWidth = dxGetTextWidth("Sérült testrész(ek):", 1, font3)
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2
        
        UpdatePos("newTicket.vehiclePlateText", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.vehiclePlateText", tocolor(51, 51, 51, alpha))

        local textY = textY + resp(29)
        dxDrawText("Ellátó(k) neve:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW = inputW + resp(10)
        local textWidth = dxGetTextWidth("Ellátó(k) neve:", 1, font3)
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2

        UpdatePos("newTicket.issuingAuthority", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.issuingAuthority", tocolor(51, 51, 51, alpha))

        dxDrawText("Ellátás összege:", bgX, bgY + resp(145), bgX + bgW, bgY + bgH, tocolor(51, 51, 51, alpha), 1, font4, "center", "center")

        local lineW = lineW / 2 + resp(30)
        local lineX, lineY = lineX + lineW / 2 - resp(30), lineY + resp(230)

        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(51, 51, 51, alpha))

        local textX, textY = lineX, lineY
        local penalty = GetText("newTicket.penalty")
        local textWidth = dxGetTextWidth(penalty, 1, font4)

        local inputW, inputH = lineW, resp(20)
        local inputX, inputY = textX, textY - inputH + resp(1)

        UpdatePos("newTicket.penalty", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.penalty", tocolor(51, 51, 51, alpha))

        dxDrawText("$", textX - textWidth - resp(25), textY, textX + lineW, textY + lineH + resp(10), tocolor(greenR, greenG, greenB, alpha), 1, font5, "center", "bottom")
        dxDrawText("Diagnózis:", logoX + (logoW / 2), bgY, bgX + bgW, bgY + bgH - resp(165), tocolor(51, 51, 51, alpha), 1, font3, "left", "bottom")

        local inputW, inputH = resp(360), resp(50)
        local inputX, inputY = logoX + (logoW / 2), lineY + resp(40)

        UpdatePos("newTicket.otherReason", {inputX, inputY, inputW, inputH})
        UpdateAlpha("newTicket.otherReason", tocolor(51, 51, 51, alpha))

        if signatureTick then 
            if ticketData.offenderNameLength then 
                local elapsedTime = nowTick - signatureTick
                local duration = 3000
                local progress = elapsedTime / duration

                ticketData.offenderLength = interpolateBetween(0, 0, 0, ticketData.offenderNameLength, 0, 0, progress, "Linear")

                if progress >= 1 then 
                    signatureTick = false
                    
                    ticketData.offenderNameLength = false
                    ticketData.signedOffender = true
                    ticketData.offenderLength = false
                end
            elseif ticketData.superVisorNameLength then
                local elapsedTime = nowTick - signatureTick
                local duration = 3000
                local progress = elapsedTime / duration

                ticketData.superVisorLength = interpolateBetween(0, 0, 0, ticketData.superVisorNameLength, 0, 0, progress, "Linear")

                if progress >= 1 then 
                    signatureTick = false
                    
                    ticketData.superVisorNameLength = false
                    ticketData.signedSuperVisor = true
                    ticketData.superVisorLength = false
                end
            end
        end

        local text = ticketData.offenderLength and utf8.sub(ticketData.offenderNameSignature, 1, ticketData.offenderLength) or ticketData.offenderNameSignature
        dxDrawText("Sérült aláírása", logoX - logoW - resp(205), bgY, bgX + bgW, bgY + bgH - resp(70), tocolor(51, 51, 51, alpha), 1, font3, "center", "bottom")
        dxDrawText(text, logoX - logoW - resp(205), bgY, bgX + bgW, bgY + bgH - resp(37), tocolor(51, 51, 51, alpha), 1, font7, "center", "bottom")

        hoverSignature = nil

        local hoverW, hoverH = resp(150), resp(30)
        local hoverX, hoverY = logoX + resp(15), inputY + resp(100)
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)
        if inSlot then 
            hoverSignature = "offender"
        end

        local text = ticketData.superVisorLength and utf8.sub(ticketData.superVisorNameSignature, 1, ticketData.superVisorLength) or ticketData.superVisorNameSignature
        dxDrawText("Ellátó aláírása", logoX + resp(200), bgY, bgX + bgW, bgY + bgH - resp(70), tocolor(51, 51, 51, alpha), 1, font3, "center", "bottom")
        dxDrawText(text, logoX + resp(200), bgY, bgX + bgW, bgY + bgH - resp(37), tocolor(51, 51, 51, alpha), 1, font7, "center", "bottom")

        local hoverX, hoverY = hoverX + hoverW + resp(60), hoverY
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)
        if inSlot then 
            hoverSignature = "superVisor"
        end

        hoverButton = nil

        local buttonW, buttonH = resp(180), resp(25)
        local buttonX, buttonY = bgX + bgW / 2 - buttonW / 2, bgY + bgH + resp(5)
        local ticketAlpha = alpha * 0.7
        local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
        if inSlot then 
            hoverButton = "ticketButton"
            ticketAlpha = alpha
        end

        dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, tocolor(greenR, greenG, greenB, ticketAlpha))
        dxDrawText("Megírás", buttonX, buttonY + resp(4), buttonX + buttonW, buttonY + buttonH, tocolor(255, 255, 255, ticketAlpha), 1, font3, "center", "center")

        -- local buttonX = bgX + bgW - buttonW - (buttonW / 2)
        -- local cancelAlpha = 255 * 0.7
        -- local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
        -- if inSlot then 
        --     hoverButton = "cancelButton"
        --     cancelAlpha = 255
        -- end

        -- dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, tocolor(redR, redG, redB, cancelAlpha))
        -- dxDrawText("Mégse", buttonX, buttonY + resp(4), buttonX + buttonW, buttonY + buttonH, tocolor(255, 255, 255, cancelAlpha), 1, font3, "center", "center")
    elseif ticketData.page == "viewTicket_offender" then
        local bgW, bgH = resp(430), resp(662)
        local bgX, bgY = screenX / 2 - bgW / 2, screenY / 2 - bgH / 2

        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.paper, 0, 0, 0, tocolor(255, 255, 255, alpha))

        local bgLogoW, bgLogoH = resp(232), resp(267)
        local bgLogoX, bgLogoY = bgX + bgW / 2 - bgLogoW / 2, bgY + bgH / 2 - bgLogoH / 2

        exports.cr_dx:dxDrawImageAsTexture(bgLogoX, bgLogoY, bgLogoW, bgLogoH, textures.big_logo, 0, 0, 0, tocolor(255, 255, 255, alpha))

        local logoW, logoH = resp(33), resp(38)
        local logoX, logoY = bgX + (logoW - resp(5)), bgY + (logoH * 2) + resp(10)

        exports.cr_dx:dxDrawImageAsTexture(logoX, logoY, logoW, logoH, textures.small_logo, 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText("BÍRSÁG", bgX, logoY + resp(4), bgX + bgW, logoY + logoH, tocolor(redR, redG, redB, alpha), 1, font, "center", "center")
        dxDrawText("Az alább feltüntetett személy szabálysértést\nkövetett el, a szabálysértés oka a következő:", logoX + (logoW / 2), logoY + logoH + resp(4), bgX + bgW, logoY + logoH + resp(70), tocolor(51, 51, 51, alpha), 1, font2, "left", "center")

        local lineW, lineH = bgW - resp(47), resp(1)
        local lineX, lineY = bgX + resp(47 / 2), logoY + logoH + resp(100)

        local reason = tostring(ticketData.reason)
        local inputW, inputH = lineW, resp(20)
        local inputX, inputY = lineX, lineY - inputH

        dxDrawText(reason, inputX, inputY, lineX + lineW, lineY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "center", "center")

        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(51, 51, 51, alpha))

        local textX, textY = lineX + resp(5), lineY + resp(46)
        local _textX = textX

        dxDrawText("Helyszín:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW, inputH = resp(120), resp(20)
        local textWidth = dxGetTextWidth("Helyszín:", 1, font3)
        local location = ticketData.location
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2

        dxDrawText(location, inputX, inputY, inputX + inputW, inputY + inputH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", true)

        local textX = textX + resp(202)
        dxDrawText("Dátum:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local textWidth = dxGetTextWidth("Dátum:", 1, font3)
        local date = ticketData.date
        local inputX, inputY = textX + textWidth + resp(5), inputY

        dxDrawText(date, inputX, inputY, inputX + inputW, inputY + inputH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", true)

        local textX, textY = _textX, textY + resp(29)
        dxDrawText("Elkövető neve:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW = inputW + resp(150)
        local textWidth = dxGetTextWidth("Elkövető neve:", 1, font3)
        local offenderName = ticketData.offenderName
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2

        dxDrawText(offenderName, inputX, inputY, inputX + inputW, inputY + inputH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", true)

        local textY = textY + resp(29)
        dxDrawText("Jármű rendszáma:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW = inputW - resp(30)
        local textWidth = dxGetTextWidth("Jármű rendszáma:", 1, font3)
        local vehiclePlateText = ticketData.vehiclePlateText
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2
        
        dxDrawText(vehiclePlateText, inputX, inputY, inputX + inputW, inputY + inputH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", true)

        local textY = textY + resp(29)
        dxDrawText("Kiállító hatóság:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW = inputW + resp(10)
        local textWidth = dxGetTextWidth("Kiállító hatóság:", 1, font3)
        local issuingAuthority = ticketData.issuingAuthority
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2

        dxDrawText(issuingAuthority, inputX, inputY, inputX + inputW, inputY + inputH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", true)

        dxDrawText("Bírság összege:", bgX, bgY + resp(145), bgX + bgW, bgY + bgH, tocolor(51, 51, 51, alpha), 1, font4, "center", "center")

        local lineW = lineW / 2 + resp(30)
        local lineX, lineY = lineX + lineW / 2 - resp(30), lineY + resp(230)

        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(51, 51, 51, alpha))

        local textX, textY = lineX, lineY
        local penalty = tostring(ticketData.penalty)
        local textWidth = dxGetTextWidth(penalty, 1, font4)

        local inputW, inputH = lineW, resp(20)
        local inputX, inputY = textX, textY - inputH + resp(1)

        dxDrawText(penalty, inputX, inputY, inputX + inputW, inputY + inputH, tocolor(51, 51, 51, alpha), 1, font4, "center", "center")

        dxDrawText("$", textX - textWidth - resp(25), textY, textX + lineW, textY + lineH + resp(10), tocolor(greenR, greenG, greenB, alpha), 1, font5, "center", "bottom")
        dxDrawText("Bírság infó:", logoX + (logoW / 2), bgY, bgX + bgW, bgY + bgH - resp(165), tocolor(51, 51, 51, alpha), 1, font3, "left", "bottom")

        local inputW, inputH = resp(360), resp(50)
        local inputX, inputY = logoX + (logoW / 2), lineY + resp(40)

        dxDrawText(tostring(ticketData.otherReason), inputX, inputY, bgX + bgW, bgY + bgH, tocolor(51, 51, 51, alpha), 1, font6, "left", "top", true)

        if signatureTick then 
            if ticketData.offenderNameLength then 
                local elapsedTime = nowTick - signatureTick
                local duration = 3000
                local progress = elapsedTime / duration

                ticketData.offenderLength = interpolateBetween(0, 0, 0, ticketData.offenderNameLength, 0, 0, progress, "Linear")

                if progress >= 1 then 
                    signatureTick = false
                    
                    ticketData.offenderNameLength = false
                    ticketData.signedOffender = true
                    ticketData.offenderLength = false
                    isRender = false

                    manageTicket("destroy")
                    
                    local syntax = exports.cr_core:getServerSyntax("Ticket", "success")
                    outputChatBox(syntax .. "Sikeresen aláírtad a bírságot, mostantól azt az inventorydban találod.", 255, 0, 0, true)
                end
            end
        end

        local text = ticketData.offenderLength and utf8.sub(ticketData.offenderNameSignature, 1, ticketData.offenderLength) or ticketData.signedOffender and ticketData.offenderNameSignature or ""
        dxDrawText("Szabályszegő aláírása", logoX - logoW - resp(205), bgY, bgX + bgW, bgY + bgH - resp(70), tocolor(51, 51, 51, alpha), 1, font3, "center", "bottom")
        dxDrawText(text, logoX - logoW - resp(205), bgY, bgX + bgW, bgY + bgH - resp(37), tocolor(51, 51, 51, alpha), 1, font7, "center", "bottom")

        hoverSignature = nil

        local hoverW, hoverH = resp(150), resp(30)
        local hoverX, hoverY = logoX + resp(15), inputY + resp(100)
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)
        if inSlot then 
            hoverSignature = "offender"
        end

        local text = ticketData.superVisorName
        dxDrawText("Eljáró felügyelő", logoX + resp(200), bgY, bgX + bgW, bgY + bgH - resp(70), tocolor(51, 51, 51, alpha), 1, font3, "center", "bottom")
        dxDrawText(text, logoX + resp(200), bgY, bgX + bgW, bgY + bgH - resp(37), tocolor(51, 51, 51, alpha), 1, font7, "center", "bottom")
    elseif ticketData.page == "viewTicket_injuredperson" then
        local bgW, bgH = resp(430), resp(662)
        local bgX, bgY = screenX / 2 - bgW / 2, screenY / 2 - bgH / 2

        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.paper, 0, 0, 0, tocolor(255, 255, 255, alpha))

        local bgLogoW, bgLogoH = resp(232), resp(267)
        local bgLogoX, bgLogoY = bgX + bgW / 2 - bgLogoW / 2, bgY + bgH / 2 - bgLogoH / 2

        exports.cr_dx:dxDrawImageAsTexture(bgLogoX, bgLogoY, bgLogoW, bgLogoH, textures.big_logo, 0, 0, 0, tocolor(255, 255, 255, alpha))

        local logoW, logoH = resp(33), resp(38)
        local logoX, logoY = bgX + (logoW - resp(5)), bgY + (logoH * 2) + resp(10)

        exports.cr_dx:dxDrawImageAsTexture(logoX, logoY, logoW, logoH, textures.small_logo, 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText("EGÉSZSÉGÜGYI SZÁMLA", bgX, logoY + resp(4), bgX + bgW, logoY + logoH, tocolor(redR, redG, redB, alpha), 1, font8, "center", "center")
        dxDrawText("Az ellátás adatait alább találja.\nAz ellátás leírása:", logoX + (logoW / 2), logoY + logoH + resp(4), bgX + bgW, logoY + logoH + resp(70), tocolor(51, 51, 51, alpha), 1, font2, "left", "center")

        local lineW, lineH = bgW - resp(47), resp(1)
        local lineX, lineY = bgX + resp(47 / 2), logoY + logoH + resp(100)

        local reason = tostring(ticketData.reason)
        local inputW, inputH = lineW, resp(20)
        local inputX, inputY = lineX, lineY - inputH

        dxDrawText(reason, inputX, inputY, lineX + lineW, lineY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "center", "center")

        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(51, 51, 51, alpha))

        local textX, textY = lineX + resp(5), lineY + resp(46)
        local _textX = textX

        dxDrawText("Helyszín:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW, inputH = resp(120), resp(20)
        local textWidth = dxGetTextWidth("Helyszín:", 1, font3)
        local location = ticketData.location
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2

        dxDrawText(location, inputX, inputY, inputX + inputW, inputY + inputH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", true)

        local textX = textX + resp(202)
        dxDrawText("Dátum:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local textWidth = dxGetTextWidth("Dátum:", 1, font3)
        local date = ticketData.date
        local inputX, inputY = textX + textWidth + resp(5), inputY

        dxDrawText(date, inputX, inputY, inputX + inputW, inputY + inputH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", true)

        local textX, textY = _textX, textY + resp(29)
        dxDrawText("Sérült neve:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW = inputW + resp(150)
        local textWidth = dxGetTextWidth("Sérült neve:", 1, font3)
        local offenderName = ticketData.offenderName
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2

        dxDrawText(offenderName, inputX, inputY, inputX + inputW, inputY + inputH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", true)

        local textY = textY + resp(29)
        dxDrawText("Sérült testrész(ek):", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW = inputW - resp(30)
        local textWidth = dxGetTextWidth("Sérült testrész(ek):", 1, font3)
        local vehiclePlateText = ticketData.vehiclePlateText
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2
        
        dxDrawText(vehiclePlateText, inputX, inputY, inputX + inputW, inputY + inputH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", true)

        local textY = textY + resp(29)
        dxDrawText("Ellátó(k) neve:", textX, textY, textX + lineW, textY + lineH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center")

        local inputW = inputW + resp(10)
        local textWidth = dxGetTextWidth("Ellátó(k) neve:", 1, font3)
        local issuingAuthority = ticketData.issuingAuthority
        local inputX, inputY = textX + textWidth + resp(5), textY - inputH / 2

        dxDrawText(issuingAuthority, inputX, inputY, inputX + inputW, inputY + inputH, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", true)

        dxDrawText("Ellátás összege:", bgX, bgY + resp(145), bgX + bgW, bgY + bgH, tocolor(51, 51, 51, alpha), 1, font4, "center", "center")

        local lineW = lineW / 2 + resp(30)
        local lineX, lineY = lineX + lineW / 2 - resp(30), lineY + resp(230)

        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(51, 51, 51, alpha))

        local textX, textY = lineX, lineY
        local penalty = tostring(ticketData.penalty)
        local textWidth = dxGetTextWidth(penalty, 1, font4)

        local inputW, inputH = lineW, resp(20)
        local inputX, inputY = textX, textY - inputH + resp(1)

        dxDrawText(penalty, inputX, inputY, inputX + inputW, inputY + inputH, tocolor(51, 51, 51, alpha), 1, font4, "center", "center")

        dxDrawText("$", textX - textWidth - resp(25), textY, textX + lineW, textY + lineH + resp(10), tocolor(greenR, greenG, greenB, alpha), 1, font5, "center", "bottom")
        dxDrawText("Diagnózis:", logoX + (logoW / 2), bgY, bgX + bgW, bgY + bgH - resp(165), tocolor(51, 51, 51, alpha), 1, font3, "left", "bottom")

        local inputW, inputH = resp(360), resp(50)
        local inputX, inputY = logoX + (logoW / 2), lineY + resp(40)

        dxDrawText(tostring(ticketData.otherReason), inputX, inputY, bgX + bgW, bgY + bgH, tocolor(51, 51, 51, alpha), 1, font6, "left", "top", true)

        if signatureTick then 
            if ticketData.offenderNameLength then 
                local elapsedTime = nowTick - signatureTick
                local duration = 3000
                local progress = elapsedTime / duration

                ticketData.offenderLength = interpolateBetween(0, 0, 0, ticketData.offenderNameLength, 0, 0, progress, "Linear")

                if progress >= 1 then 
                    signatureTick = false
                    
                    ticketData.offenderNameLength = false
                    ticketData.signedOffender = true
                    ticketData.offenderLength = false
                    isRender = false

                    manageTicket("destroy")
                    
                    local syntax = exports.cr_core:getServerSyntax("Ticket", "success")
                    local text = ticketData.page == "viewTicket_offender" and "bírságot" or "számlát"
                    outputChatBox(syntax .. "Sikeresen aláírtad a " .. text .. ", mostantól azt az inventorydban találod.", 255, 0, 0, true)
                end
            end
        end

        local text = ticketData.offenderLength and utf8.sub(ticketData.offenderNameSignature, 1, ticketData.offenderLength) or ticketData.signedOffender and ticketData.offenderNameSignature or ""
        dxDrawText("Sérült aláírása", logoX - logoW - resp(205), bgY, bgX + bgW, bgY + bgH - resp(70), tocolor(51, 51, 51, alpha), 1, font3, "center", "bottom")
        dxDrawText(text, logoX - logoW - resp(205), bgY, bgX + bgW, bgY + bgH - resp(37), tocolor(51, 51, 51, alpha), 1, font7, "center", "bottom")

        hoverSignature = nil

        local hoverW, hoverH = resp(150), resp(30)
        local hoverX, hoverY = logoX + resp(15), inputY + resp(100)
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)
        if inSlot then 
            hoverSignature = "offender"
        end

        local text = ticketData.superVisorName
        dxDrawText("Ellátó aláírása", logoX + resp(200), bgY, bgX + bgW, bgY + bgH - resp(70), tocolor(51, 51, 51, alpha), 1, font3, "center", "bottom")
        dxDrawText(text, logoX + resp(200), bgY, bgX + bgW, bgY + bgH - resp(37), tocolor(51, 51, 51, alpha), 1, font7, "center", "bottom")
    end
end

function onKey(button, state)
    if button == "mouse1" then 
        if state then 
            if hoverSignature == "offender" then 
                if ticketData.page == "viewTicket_offender" or ticketData.page == "viewTicket_injuredperson" then 
                    if not signatureTick then 
                        if not ticketData.signedOffender then 
                            signatureTick = getTickCount()

                            ticketData.offenderNameSignature = exports.cr_admin:getAdminName(localPlayer)
                            ticketData.offenderNameLength = utf8.len(ticketData.offenderNameSignature)

                            if isElement(signatureSound) then 
                                signatureSound:destroy()
                                signatureSound = nil
                            end

                            signatureSound = playSound("ticket/files/sounds/sign.mp3")
                        else 
                            if not specData then 
                                local syntax = exports.cr_core:getServerSyntax("Ticket", "error")
                                local text = ticketData.page == "viewTicket_offender" and "bírságot." or "számlát."

                                outputChatBox(syntax .. "Már aláírtad a " .. text, 255, 0, 0, true)
                            end
                        end
                    end
                end
            elseif hoverSignature == "superVisor" then
                if ticketData.page == "createNewTicket" or ticketData.page == "createNewTicketMD" then 
                    if not signatureTick then 
                        if not ticketData.signedSuperVisor then 
                            signatureTick = getTickCount()

                            ticketData.superVisorNameSignature = exports.cr_admin:getAdminName(localPlayer)
                            ticketData.superVisorNameLength = utf8.len(ticketData.superVisorNameSignature)

                            if isElement(signatureSound) then 
                                signatureSound:destroy()
                                signatureSound = nil
                            end

                            signatureSound = playSound("ticket/files/sounds/sign.mp3")
                        else 
                            local syntax = exports.cr_core:getServerSyntax("Ticket", "error")
                            local text = ticketData.page == "createNewTicket" and "bírságot." or "számlát."

                            outputChatBox(syntax .. "Már aláírtad a " .. text, 255, 0, 0, true)
                        end
                    end
                end
            elseif hoverButton == "ticketButton" then
                local reason = GetText("newTicket.reason")
                local location = GetText("newTicket.location")
                local offenderName = GetText("newTicket.offenderName")
                local vehiclePlateText = GetText("newTicket.vehiclePlateText")
                local issuingAuthority = GetText("newTicket.issuingAuthority")
                local date = GetText("newTicket.date")
                local penalty = GetText("newTicket.penalty")
                local otherReason = GetText("newTicket.otherReason")

                if utf8.len(reason) < 5 or reason == "indoklás" or reason == "leírás" then 
                    local syntax = exports.cr_core:getServerSyntax("Ticket", "error")
                    local text = ticketData.page == "createNewTicket" and "Az indoknak minimum 5 karakternek kell lennie." or "A leírásnak minimum 5 karakternek kell lennie."

                    outputChatBox(syntax .. text, 255, 0, 0, true)
                    return
                end
                
                if utf8.len(location) < 3 then 
                    local syntax = exports.cr_core:getServerSyntax("Ticket", "error")

                    outputChatBox(syntax .. "A helyszínnek minimum 3 karakternek kell lennie.", 255, 0, 0, true)
                    return
                end

                if utf8.len(offenderName) < 2 then 
                    local syntax = exports.cr_core:getServerSyntax("Ticket", "error")

                    outputChatBox(syntax .. "Az névnek minimum 2 karakternek kell lennie.", 255, 0, 0, true)
                    return
                end

                if utf8.len(vehiclePlateText) < 3 then 
                    local syntax = exports.cr_core:getServerSyntax("Ticket", "error")
                    local text = ticketData.page == "createNewTicket" and "A jármű rendszámának minimum 3 karakternek kell lennie." or "Az sérült testrész(ek)-nek minimum 3 karakternek kell lennie."

                    outputChatBox(syntax .. text, 255, 0, 0, true)
                    return
                end

                if utf8.len(issuingAuthority) < 3 then 
                    local syntax = exports.cr_core:getServerSyntax("Ticket", "error")
                    local text = ticketData.page == "createNewTicket" and "A kiállító hatóságnak minimum 3 karakternek kell lennie." or "Az ellátó(k)-nak minimum 3 karakternek kell lennie."

                    outputChatBox(syntax .. text, 255, 0, 0, true)
                    return
                end

                if utf8.len(date) < 3 then 
                    local syntax = exports.cr_core:getServerSyntax("Ticket", "error")

                    outputChatBox(syntax .. "A dátumnak minimum 3 karakternek kell lennie.", 255, 0, 0, true)
                    return
                end

                if utf8.len(penalty) < 1 or penalty == "0" then 
                    local syntax = exports.cr_core:getServerSyntax("Ticket", "error")

                    outputChatBox(syntax .. "Az összegnek minimum 1 számnak kell lennie.", 255, 0, 0, true)
                    return
                end

                if not tonumber(penalty) or math.floor(tonumber(penalty)) <= 0 then 
                    local syntax = exports.cr_core:getServerSyntax("Ticket", "error")

                    outputChatBox(syntax .. "Hibás összeg.", 255, 0, 0, true)
                    return
                end

                if utf8.len(otherReason) < 3 then 
                    local syntax = exports.cr_core:getServerSyntax("Ticket", "error")

                    outputChatBox(syntax .. "Az egyéb információnak minimum 3 karakternek kell lennie.", 255, 0, 0, true)
                    return
                end

                if not ticketData.signedSuperVisor then 
                    local syntax = exports.cr_core:getServerSyntax("Ticket", "error")
                    local text = ticketData.page == "createNewTicket" and "bírságot." or "számlát."

                    outputChatBox(syntax .. "Előbb írd alá a " .. text, 255, 0, 0, true)
                    return
                end

                local offenderElement = exports.cr_core:findPlayer(localPlayer, offenderName)

                if not isElement(offenderElement) then 
                    local syntax = exports.cr_core:getServerSyntax("Ticket", "error")

                    outputChatBox(syntax .. "Nem található a játékos.", 255, 0, 0, true)
                    return
                end

                if offenderElement == localPlayer then 
                    local syntax = exports.cr_core:getServerSyntax("Ticket", "error")

                    outputChatBox(syntax .. "Saját magadat nem tudod megbüntetni.", 255, 0, 0, true)
                    return
                end

                if getDistanceBetweenPoints3D(localPlayer.position, offenderElement.position) > 3 then 
                    local syntax = exports.cr_core:getServerSyntax("Ticket", "error")

                    outputChatBox(syntax .. "Túl messze vagy a játékostól.", 255, 0, 0, true)
                    return
                end

                ticketData.reason = reason
                ticketData.location = location
                ticketData.offenderName = offenderName
                ticketData.offenderElement = offenderElement
                ticketData.superVisorName = exports.cr_admin:getAdminName(localPlayer)
                ticketData.vehiclePlateText = vehiclePlateText
                ticketData.issuingAuthority = issuingAuthority
                ticketData.date = date
                ticketData.penalty = tonumber(penalty)
                ticketData.otherReason = otherReason

                local text = "bírságot."
                local mdTicket = false

                if ticketData.page == "createNewTicketMD" then 
                    text = "számlát."
                    mdTicket = true
                end

                triggerLatentServerEvent("ticket.createTicket", 5000, false, localPlayer, offenderElement, ticketData, mdTicket)
                exports.cr_chat:createMessage(localPlayer, "átnyújt egy " .. text, 1)
                exports.cr_inventory:findAndUseItemByIDAndValue(151, 1)

                manageTicket("destroy")
            elseif hoverButton == "cancelButton" then
                manageTicket("destroy")
            end
        end
    end
end

function manageTextbars(state)
    if state == "create" then 
        if ticketData.page == "createNewTicket" or ticketData.page == "createNewTicketMD" then 
            local text = ticketData.page == "createNewTicket" and "indoklás" or "leírás"

            CreateNewBar("newTicket.reason", {0, 0, 0, 0}, {30, text, false, tocolor(255, 255, 255), {"Poppins-Medium", getRealFontSize(14)}, 1, "center", "center", false, true}, 1)
            CreateNewBar("newTicket.location", {0, 0, 0, 0}, {10, "", false, tocolor(255, 255, 255), {"Poppins-Medium", getRealFontSize(14)}, 1, "left", "center", false, true}, 1)
            CreateNewBar("newTicket.offenderName", {0, 0, 0, 0}, {25, "", false, tocolor(255, 255, 255), {"Poppins-Medium", getRealFontSize(14)}, 1, "left", "center", false, true}, 1)
            CreateNewBar("newTicket.vehiclePlateText", {0, 0, 0, 0}, {25, "", false, tocolor(255, 255, 255), {"Poppins-Medium", getRealFontSize(14)}, 1, "left", "center", false, true}, 1)
            CreateNewBar("newTicket.issuingAuthority", {0, 0, 0, 0}, {25, "", false, tocolor(255, 255, 255), {"Poppins-Medium", getRealFontSize(14)}, 1, "left", "center", false, true}, 1)
            CreateNewBar("newTicket.date", {0, 0, 0, 0}, {18, "", false, tocolor(255, 255, 255), {"Poppins-Medium", getRealFontSize(14)}, 1, "left", "center", false, true}, 1)
            CreateNewBar("newTicket.penalty", {0, 0, 0, 0}, {4, "0", true, tocolor(255, 255, 255), {"Poppins-SemiBold", getRealFontSize(19)}, 1, "center", "center", false}, 2)
            CreateNewBar("newTicket.otherReason", {0, 0, 0, 0}, {70, "Egyéb információk", false, tocolor(255, 255, 255), {"Poppins-Regular", getRealFontSize(13)}, 1, "left", "top", false, false, true}, 2)
        end
    elseif state == "destroy" then
        Clear()
    end
end

function manageTicket(state)
    if state == "init" then 
        -- ticketData.page = "viewTicket_offender"
        isRender = true

        if isTimer(textureDeleteTimer) then 
            killTimer(textureDeleteTimer)
            textureDeleteTimer = nil
        end

        createTextures()
        createRender("renderTicket", renderTicket)

        removeEventHandler("onClientKey", root, onKey)
        addEventHandler("onClientKey", root, onKey)

        manageTextbars("create")

        exports.cr_dx:startFade("ticketPanel", 
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

        hoverButton = nil
    elseif state == "destroy" then
        removeEventHandler("onClientKey", root, onKey)

        exports.cr_dx:startFade("ticketPanel", 
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

function showTicketPanel()
    if hasPlayerPermission(localPlayer, "ticket") then 
        if not isRender then 
            local dutyFaction = localPlayer:getData("char >> duty")

            if dutyFaction then 
                ticketData.page = "createNewTicket"

                if dutyFaction == 2 then 
                    ticketData.page = "createNewTicketMD"
                end

                manageTicket("init")
                exports.cr_chat:createMessage(localPlayer, "elővesz egy csekkfüzetet.", 1)

                return "init"
            end
        else 
            isRender = false

            manageTicket("destroy")
            exports.cr_chat:createMessage(localPlayer, "elrak egy csekkfüzetet.", 1)

            return "destroy"
        end
    end
end

-- function ticketCommand(cmd)
--     if localPlayer:getData("loggedIn") then 
--         if hasPlayerPermission(localPlayer, cmd) then 
--             local dutyFaction = localPlayer:getData("char >> duty")

--             if dutyFaction then 
--                 ticketData.page = "createNewTicket"

--                 if dutyFaction == 2 then 
--                     ticketData.page = "createNewTicketMD"
--                 end

--                 manageTicket("init")
--             end
--         end
--     end
-- end
-- addCommandHandler("ticket", ticketCommand, false, false)

-- setTimer(
--     function()
--         if localPlayer.name ~= "Hugh_Wiley" then 
--             return
--         end

--         manageTicket("init")
--     end, 250, 1
-- )

function showTicket(data, mdTicket, id)
    if data and type(data) == "table" then 
        if not id then 
            if not isRender then 
                ticketData = data
                ticketData.page = mdTicket and "viewTicket_injuredperson" or "viewTicket_offender"

                manageTicket("init")
            end
        else 
            if not isRender then 
                ticketData = data
                specData = id
                ticketData.page = mdTicket and "viewTicket_injuredperson" or "viewTicket_offender"

                manageTicket("init")
                exports.cr_chat:createMessage(localPlayer, "elővesz egy csekket.", 1)

                return "init"
            else
                if id == specData then 
                    isRender = false
                    specData = false

                    manageTicket("destroy")
                    exports.cr_chat:createMessage(localPlayer, "elrak egy csekket.", 1)

                    return "destroy"
                end
            end
        end
    end
end
addEvent("ticket.showTicket", true)
addEventHandler("ticket.showTicket", root, showTicket)

local maxDistance = 30

function getNearbyTicketPeds(cmd)
    if exports.cr_permission:hasPermission(localPlayer, cmd) or exports.cr_core:getPlayerDeveloper(localPlayer) then 
        local count = 0
        local peds = getElementsByType("ped", resourceRoot, true)
        local syntax = exports.cr_core:getServerSyntax("Ticket", "info")

        local hexColor = exports.cr_core:getServerColor("yellow", true)
        local position = localPlayer.position

        for i = 1, #peds do 
            local v = peds[i]
            local id = v:getData("ticketPed")

            if id then 
                local distance = getDistanceBetweenPoints3D(position, v.position)

                if distance <= maxDistance then 
                    local createdBy = v:getData("ticketPed >> createdBy")
                    local createdAt = v:getData("ticketPed >> createdAt")

                    local realTime = getRealTime(createdAt)
                    local formattedString = ("%i.%.2i.%.2i - %.2i:%.2i:%.2i"):format(realTime.year + 1900, realTime.month + 1, realTime.monthday, realTime.hour, realTime.minute, realTime.second)

                    outputChatBox(syntax .. "ID: " .. hexColor .. id .. white .. ", távolság: " .. hexColor .. math.floor(distance) .. white .. " yard.", 255, 0, 0, true)
                    outputChatBox(syntax .. "Létrehozta: " .. hexColor .. createdBy .. white .. ", ekkor: " .. hexColor .. formattedString, 255, 0, 0, true)

                    count = count + 1
                end
            end
        end

        if count == 0 then 
            outputChatBox(syntax .. "Nem található csekk befizetés npc " .. hexColor .. maxDistance .. white .. " yardos körzetben.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("nearbyticketpeds", getNearbyTicketPeds, false, false)