function dxDrawTextAwesome(icon, text, x, y, w, h, iconColor, textColor, iconScale, textScale, textFont, iconFont, between, extra1, extra2)
    if not between then between = 10 end
    if not extra1 then extra1 = 1 end
    if not extra2 then extra2 = 1 end
    local tWidth = between
    
    tWidth = tWidth + dxGetTextWidth(icon, iconScale, iconFont, true) + dxGetTextWidth(text, textScale, textFont, true)
    
    local cx = x - tWidth/2
    dxDrawText(icon, cx, y, cx, h, iconColor, iconScale, iconFont, "left", "center", false, false, false, true)
    local cx = cx + (between + dxGetTextWidth(icon, iconScale, iconFont, true))
    dxDrawText(text, cx, y + extra1, cx, h + extra2, textColor, textScale, textFont, "left", "center", false, false, false, true)
end

function dxDrawImageWithText(imagePath, text, x, y, w, h, imageColor, textColor, imageW, imageH, textScale, textFont, between, yBetween)
    if not between then between = 10 end
    if not yBetween then yBetween = 0 end
    local tWidth = between
    
    tWidth = tWidth + imageW + dxGetTextWidth(text, textScale, textFont, true)
    
    local cx = x - tWidth/2
    dxDrawImage(cx, y + ((h - y)/2) - imageH/2 + yBetween, imageW, imageH, imagePath, 0, 0, 0, imageColor)
    local cx = cx + (between + imageW)
    dxDrawText(text, cx, y, cx, h, textColor, textScale, textFont, "left", "center", false, false, false, true)
end

function getAwesomeTextStartPosition(icon, text, x, y, w, h, iconColor, textColor, iconScale, textScale, textFont, iconFont, between)
    if not between then between = 10 end
    local tWidth = between
    
    tWidth = tWidth + dxGetTextWidth(icon, iconScale, iconFont, true) + dxGetTextWidth(text, textScale, textFont, true)
    
    local cx = x - tWidth/2
    local cx2 = cx + (between + dxGetTextWidth(icon, iconScale, iconFont, true))
    
    return cx, cx2
end

function getAwesomeTextWidth(icon, text, x, y, w, h, iconColor, textColor, iconScale, textScale, textFont, iconFont, between)
    if not between then between = 10 end
    local tWidth = between
    
    tWidth = tWidth + dxGetTextWidth(icon, iconScale, iconFont, true) + dxGetTextWidth(text, textScale, textFont, true)
    
    return tWidth
end

function getAwesomeTextHeight(icon, text, x, y, w, h, iconColor, textColor, iconScale, textScale, textFont, iconFont, between)
    if not between then between = 10 end
    
    local fontHeight = dxGetFontHeight(textScale, textFont)
    local fontHeight2 = dxGetFontHeight(iconScale, iconFont)
    
    if fontHeight2 > fontHeight then
        fontHeight = fontHeight2
    end
    
    return fontHeight
end

function getAwesomeImageStartPosition(imagePath, text, x, y, w, h, imageColor, textColor, imageW, imageH, textScale, textFont, between)
    if not between then between = 10 end
    local tWidth = between
    
    tWidth = tWidth + imageW + dxGetTextWidth(text, textScale, textFont, true)
    
    local cx = x - tWidth/2
    local cx2 = cx + (between + imageW)
    
    return cx, cx2
end

function getAwesomeImageWidth(imagePath, text, x, y, w, h, imageColor, textColor, imageW, imageH, textScale, textFont, between)
    if not between then between = 10 end
    local tWidth = between
    
    tWidth = tWidth + imageW + dxGetTextWidth(text, textScale, textFont, true)
    
    return tWidth
end

function getAwesomeImageHeight(imagePath, text, x, y, w, h, imageColor, textColor, imageW, imageH, textScale, textFont, between)
    if not between then between = 10 end
    
    local fontHeight = dxGetFontHeight(textScale, textFont)
    local fontHeight2 = imageH
    
    if fontHeight2 > fontHeight then
        fontHeight = fontHeight2
    end
    
    return fontHeight
end

--[[
addEventHandler("onClientRender", root,
    function()
        local font = exports['cr_fonts']:getFont("Roboto", 10)
        local awesomeFont = exports['cr_fonts']:getFont("awesomeFont", 10)
        local w, h = getAwesomeImageWidth(textures["lock"], "Elne mond", sx/2, sy/2, sx/2, sy/2, tocolor(255, 0, 0, 255), tocolor(255, 255, 255, 255), 15, 15, 1, font, 5), getAwesomeImageHeight(textures["lock"], "Elne mond", sx/2, sy/2, sx/2, sy/2, tocolor(255, 0, 0, 255), tocolor(255, 255, 255, 255), 15, 15, 1, font, 5)
        
        if isInSlot(sx/2 - w/2, sy/2 - h/2, w, h) then
            dxDrawImageWithText(textures["lock"], "Elne mond", sx/2, sy/2, sx/2, sy/2, tocolor(255, 0, 0, 255), tocolor(255, 0, 0, 255), 15, 15, 1, font, 5)
        else
            dxDrawImageWithText(textures["lock"], "Elne mond", sx/2, sy/2, sx/2, sy/2, tocolor(255, 0, 0, 255), tocolor(255, 255, 255, 255), 15, 15, 1, font, 5)
        end
        
        local icon, text, b = "", "JÁRMŰ INFORMÁCIÓK", 50
        local w, h = getAwesomeTextWidth(icon, text, sx/2, sy/2 + b, sx/2, sy/2 + b, tocolor(255, 255, 255, 255), tocolor(255, 255, 255, 255), 1, 1, font, awesomeFont, 5), getAwesomeTextHeight(icon, text, sx/2, sy/2 + b, sx/2, sy/2 + b, tocolor(255, 255, 255, 255), tocolor(255, 255, 255, 255), 1, 1, font, awesomeFont, 5)
        if isInSlot(sx/2 - w/2, sy/2 + b - h/2, w, h) then
            dxDrawTextAwesome(icon, text, sx/2, sy/2 + b, sx/2, sy/2 + b, tocolor(255, 0, 0, 255), tocolor(255, 0, 0, 255), 1, 1, font, awesomeFont, 5)
        else
            dxDrawTextAwesome(icon, text, sx/2, sy/2 + b, sx/2, sy/2 + b, tocolor(255, 255, 255, 255), tocolor(255, 255, 255, 255), 1, 1, font, awesomeFont, 5)
        end
        
        local icon, text, b = "", "INGATLAN INFORMÁCIÓK", 100
        local w, h = getAwesomeTextWidth(icon, text, sx/2, sy/2 + b, sx/2, sy/2 + b, tocolor(255, 255, 255, 255), tocolor(255, 255, 255, 255), 1, 1, font, awesomeFont, 5), getAwesomeTextHeight(icon, text, sx/2, sy/2 + b, sx/2, sy/2 + b, tocolor(255, 255, 255, 255), tocolor(255, 255, 255, 255), 1, 1, font, awesomeFont, 5)
        if isInSlot(sx/2 - w/2, sy/2 + b - h/2, w, h) then
            dxDrawTextAwesome(icon, text, sx/2, sy/2 + b, sx/2, sy/2 + b, tocolor(255, 0, 0, 255), tocolor(255, 0, 0, 255), 1, 1, font, awesomeFont, 5)
        else
            dxDrawTextAwesome(icon, text, sx/2, sy/2 + b, sx/2, sy/2 + b, tocolor(255, 255, 255, 255), tocolor(255, 255, 255, 255), 1, 1, font, awesomeFont, 5)
        end
    end
)]]