local _dxDrawRectangle = dxDrawRectangle;

function dxDrawOuterBorder(x, y, w, h, borderSize, borderColor, postGUI)
	borderSize = borderSize or 2
	borderColor = borderColor or tocolor(0, 0, 0, 255)
	
	_dxDrawRectangle(x - borderSize, y - borderSize, w + (borderSize * 2), borderSize, borderColor, postGUI)
	_dxDrawRectangle(x, y + h, w, borderSize, borderColor, postGUI)
	_dxDrawRectangle(x - borderSize, y, borderSize, h + borderSize, borderColor, postGUI)
	_dxDrawRectangle(x + w, y, borderSize, h + borderSize, borderColor, postGUI)
end

local dxDrawRectangle = function(left, top, width, height, color, postgui)
	if not postgui then
		postgui = false;
	end

	left, top = left + 2, top + 2;
	width, height = width - 4, height - 4;

	_dxDrawRectangle(left - 2, top, 2, height, color, postgui);
	_dxDrawRectangle(left + width, top, 2, height, color, postgui);
	_dxDrawRectangle(left, top - 2, width, 2, color, postgui);
	_dxDrawRectangle(left, top + height, width, 2, color, postgui);

	_dxDrawRectangle(left - 1, top - 1, 1, 1, color, postgui);
	_dxDrawRectangle(left + width, top - 1, 1, 1, color, postgui);
	_dxDrawRectangle(left - 1, top + height, 1, 1, color, postgui);
	_dxDrawRectangle(left + width, top + height, 1, 1, color, postgui);

	_dxDrawRectangle(left, top, width, height, color, postgui);
end

textHeightsTooltip = {}
textHeightsTooltip2 = {}
local sx, sy = guiGetScreenSize()
function drawTooltip(type, text, spec)
    if not type then type = 1 end
    if type == 1 then
        local font = exports['cr_fonts']:getFont("Poppins-Medium", 12)
        --local text = "Asd"
        local cx, cy = exports['cr_core']:getCursorPosition()
        local w = dxGetTextWidth(text,1,font, true) + 15
        if not textHeightsTooltip[text] then
            local count = 0
            local last = 0
            while true do
                local startpos, endpos = utf8.find(text,'\n',last,true)
                if startpos and endpos then
                    count = count + 1
                    last = endpos + 1
                else
                    break
                end
            end
            
            if count == 0 then
                count = 1
            end

            textHeightsTooltip[text] = count
        end
        local h = (textHeightsTooltip[text] * dxGetFontHeight(1, font))
        cx = cx - w/2
        cy = cy - h
        dxDrawRectangle(cx,cy,w,h,tocolor(51,51,51, 255 * 0.8))
        --dxDrawRoundedRectangle(cx-4,cy + h/2,w+8,20,tocolor(55,55,55),tocolor(55,55,55))
        dxDrawText(text,cx,cy,cx+w,cy+h, tocolor(242,242,242,255),1,font,"center","center", false, false, false, true)
    elseif type == 2 then
        local font3 = exports['cr_fonts']:getFont("Poppins-Medium", 12)
        if not textHeightsTooltip2[text] then
            local count = 0
            local last = 0
            while true do
                local startpos, endpos = utf8.find(text,'\n',last,true)
                if startpos and endpos then
                    count = count + 1
                    last = endpos + 1
                else
                    break
                end
            end

            if count == 0 then
                count = 1
            end
            
            textHeightsTooltip2[text] = count
        end
        
        --outputChatBox(textHeightsTooltip2[text])
        local h = (textHeightsTooltip2[text] * dxGetFontHeight(1, font3))
        local length = dxGetTextWidth(text, 1, font3, true) + 10
        
        local alpha = 255
        local size = 1
        local startX, startY = exports['cr_core']:getCursorPosition()
        if spec then
            startX, startY, specData = unpack(spec)
            
            if specData["alpha"] then
                alpha = specData["alpha"]
            end
            
            if specData["size"] then
                size = specData["size"]
            end
        end
        
        local length = length * size
        local h = h * size
        
        if startX + length/2 >= sx then
            startX = sx - length/2 - 2
        end

        if startX <= length/2 then
            startX = length/2 + 2
        end

        if startY <= h then
            startY = h + 2
        end

        dxDrawOuterBorder(startX - length/2, startY - h, length, h, 2 * size, tocolor(41,41,41,math.max(alpha - 105, 0)))
        _dxDrawRectangle(startX - length/2, startY - h, length, h, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(text,startX, startY - h, startX, startY, tocolor(242,242,242,alpha), size, font3, "center", "center", false, false, false, true)
    end
end
--addEventHandler("onClientRender", root, drawTooltip)