
isPickerRender, pickerData = false, {}

local selected 

function createPicker(data)
	if data then  
		pickerData = data
		
		isMoving, pickingColor, pickingLuminance = false, false, false
        
        Clear()
        updatePaletteColor()
        
        bindKey("backspace", "down", destroyPicker)
        bindKey("enter", "down", onEnter)

        exports['cr_dx']:startFade("pickerPanel", 
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

        if not isPickerRender then 
            isPickerRender = true 
            createRender("drawnPicker", drawnPicker)
            addEventHandler("onClientClick", root, pickerClickEvent)
		end 
	end
end 

function destroyPicker()
    if isPickerRender then 
        unbindKey("enter", "down", onEnter)
        unbindKey("backspace", "down", destroyPicker)
        removeEventHandler("onClientClick", root, pickerClickEvent)
		isPickerRender = false 
        
        Clear()
        local val = 2
        for k,v in pairs(options[optionsSelected]["options"]) do 
            if v["type"] == 3 then 
                local text = ""
                if v["getDefaultValue"] then 
                    text = v["getDefaultValue"]()
                end 
                CreateNewBar(k .. ">>inputBar", {0, 0, 0, 0}, {25, text, false, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "center", false, true}, val)
                val = val + 1
            end 
        end 
        CreateNewBar("Options >> search", {0, 0, 0, 0}, {16, "", false, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "center", false, true}, 1)
		
		isMoving, pickingColor, pickingLuminance = false, false, false

		resetCrosshairColors()

        exports['cr_dx']:startFade("pickerPanel", 
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

function onEnter()
    if pickerData["onEnter"] then 
        pickerData["onEnter"]()
    end 
end 

function resetCrosshairColors()
	local data = pickerData["old"]
	if data then 
		localPlayer:setData("char >> crosshairColor", data["color"])
	end 
end 

function pickerClickEvent(b, s)
    if isPickerRender then 
        if b == "left" and s == "down" then 
            if selected == 1 then 
				isMoving, pickingColor, pickingLuminance = true, true, false
				
                selected = nil 
                return 
            elseif selected == 2 then 
				isMoving, pickingColor, pickingLuminance = true, false, true
				
                selected = nil 
                return 
            elseif selected == "finish" then 
                if pickerData["onEnter"] then 
                    pickerData["onEnter"]()
                end 
                selected = nil 
                return 
			end 
		else 
			isMoving, pickingColor, pickingLuminance = false, false, false
        end 
    end 
end 

function drawnPicker()
    local alpha, progress = exports['cr_dx']:getFade("pickerPanel")
    if not isPickerRender then 
        if progress >= 1 then 
            if pickerData["onFinish"] then 
                pickerData["onFinish"]()
            end 
            pickerData = nil
            destroyRender("drawnPicker")
            return 
        end 
	end 

	local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
	
	if isPickerRender and progress >= 1 then 
        local selectedR, selectedG, selectedB = pickerData["color"][1], pickerData["color"][2], pickerData["color"][3]
        localPlayer:setData("char >> crosshairColor", {selectedR, selectedG, selectedB})
	end

	selected = nil 

    local w, h = 252, 174
    local x, y = sx/2 - w/2, sy/2 - h/2
	dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
	dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	if isInSlot(x, y, w, h, true) then 
        isCursorInPanel = true
	end 
	
	dxDrawText('Színválasztó', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

    local w3, h3 = 72, 22
	dxDrawRectangle(x + 2 + 4, y + h - 4 - h3, w3, h3, tocolor(51, 51, 51, alpha * 0.8)) -- hex
	UpdatePos("hex", {x + 2 + 4, y + h - 4 - h3, w3, h3})
	UpdateAlpha("hex", tocolor(242, 242, 242, alpha))

	local y = y + 40

    local w4, h4 = 53, 22
    local _y = y
	dxDrawRectangle(x + 2 + 4 + w3 - w4, y + 4, w4, h4, tocolor(51, 51, 51, alpha * 0.8)) -- r
	UpdatePos("R", {x + 2 + 4 + w3 - w4, y + 4, w4, h4})
	UpdateAlpha("R", tocolor(242, 242, 242, alpha))
    y = y + 4 + h4
	dxDrawRectangle(x + 2 + 4 + w3 - w4, y + 4, w4, h4, tocolor(51, 51, 51, alpha * 0.8)) -- g
	UpdatePos("G", {x + 2 + 4 + w3 - w4, y + 4, w4, h4})
	UpdateAlpha("G", tocolor(242, 242, 242, alpha))
    y = y + 4 + h4
	dxDrawRectangle(x + 2 + 4 + w3 - w4, y + 4, w4, h4, tocolor(51, 51, 51, alpha * 0.8)) -- b
	UpdatePos("B", {x + 2 + 4 + w3 - w4, y + 4, w4, h4})
	UpdateAlpha("B", tocolor(242, 242, 242, alpha))

    local w4, h4 = 136, 136
	local y = _y - 5
    x = x + 2 + 4 + w3 + 4
    dxDrawRectangle(x, y, w4, h4, tocolor(23, 23, 23, alpha * 0.8))

	local px, py, pw, ph = x + 2, y + 2, w4 - 4, h4 - 4
	if isInSlot(px, py, pw, ph, true) then 
		selected = 1
	end 
    dxDrawImage(x + 2, y + 2, w4 - 4, h4 - 4, ":cr_tuning/files/colorpicker/paletteHandle.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    drawBorderedRectangle(((x + 2) + (pickerData["hue"] * (w4 - 4) - 1)) - (8 / 2), ((y + 2) + ((1 - pickerData["saturation"]) * (h4 - 4) - 1)) - (8 / 2), 8, 8, 1, tocolor(23, 23, 23, alpha - 0.8), tocolor(pickerData["selectedColor"][1], pickerData["selectedColor"][2], pickerData["selectedColor"][3], alpha))

    x = x + w4 + 4 

	local px2, py2, pw2, ph2 = x, y, 21, h4
	if isInSlot(px2, py2, pw2, ph2, true) then 
		selected = 2
	end 
    dxDrawRectangle(x, y, 21, h4, tocolor(23, 23, 23, alpha * 0.8))

    for i = 0, (h4 - 4) do
        local luminanceR, luminanceG, luminanceB = HSLToRGB(pickerData["hue"], pickerData["saturation"], ((h4 - 4) - i) / (h4 - 4))
        
        dxDrawRectangle(x + 2, y + 2 + i, 21 - 4, 1, tocolor(luminanceR * 255, luminanceG * 255, luminanceB * 255, alpha))
    end
    
    local arrowY = y + 2 + ((1 - pickerData["lightness"]) * (h4 - 4))
    arrowY = math.max(y + 2, math.min(y + (h4 - 4), arrowY))
    dxDrawRectangle(x + 2, arrowY - 1, 21 - 4, 2, tocolor(242, 242, 242, alpha * 0.8))

	if isCursorShowing() then
        if isMoving then 
			local cursorX, cursorY = exports['cr_core']:getCursorPosition()
			
			if getKeyState("mouse1") and pickingColor then
				cursorX = math.max(px, math.min(px + pw, cursorX))
				cursorY = math.max(py, math.min(py + ph, cursorY))
				setCursorPosition(cursorX, cursorY)
				
				pickerData["hue"], pickerData["saturation"] = (cursorX - px) / (pw - 1), ((ph - 1) - cursorY + py) / (ph - 1)
				
				local convertedR, convertedG, convertedB = HSLToRGB(pickerData["hue"], pickerData["saturation"], pickerData["lightness"])
				local oldR, oldG, oldB = HSLToRGB(pickerData["hue"], pickerData["saturation"], 0.5)
				
				pickerData["selectedColor"] = convertColor({oldR * 255, oldG * 255, oldB * 255})
				pickerData["color"] = convertColor({convertedR * 255, convertedG * 255, convertedB * 255})

				SetText("R", pickerData["color"][1])
				SetText("G", pickerData["color"][2])
				SetText("B", pickerData["color"][3])
				SetText("hex", RGBToHex(unpack(pickerData["color"])))

			elseif getKeyState("mouse1") and pickingLuminance then
				cursorX = math.max(px2, math.min(px2 + pw2, cursorX))
				cursorY = math.max(py2, math.min(py2 + ph2, cursorY))
				setCursorPosition(cursorX, cursorY)
				
				pickerData["lightness"] = ((ph2) - cursorY + py2) / (ph2)
				
				local convertedR, convertedG, convertedB = HSLToRGB(pickerData["hue"], pickerData["saturation"], pickerData["lightness"])
				
				pickerData["color"] = convertColor({convertedR * 255, convertedG * 255, convertedB * 255})

				SetText("R", pickerData["color"][1])
				SetText("G", pickerData["color"][2])
				SetText("B", pickerData["color"][3])
				SetText("hex", RGBToHex(unpack(pickerData["color"])))
			end
		end 
	else 
		if isMoving or pickingColor or pickingLuminance then 
			isMoving, pickingColor, pickingLuminance = false, false, false
		end 
    end
end 

function updatePaletteColor()
    local color = localPlayer:getData("char >> crosshairColor") or {255, 255, 255}

    CreateNewBar("R", {0,0,0,0}, {3, color[1], true, tocolor(255,255,255,0), {"Poppins-Regular", 12}, 1, "center", "center", false}, 1)
    CreateNewBar("G", {0,0,0,0}, {3, color[2], true, tocolor(255,255,255,0), {"Poppins-Regular", 12}, 1, "center", "center", false}, 2)
    CreateNewBar("B", {0,0,0,0}, {3, color[3], true, tocolor(255,255,255,0), {"Poppins-Regular", 12}, 1, "center", "center", false}, 3)
    CreateNewBar("hex", {0,0,0,0}, {6, RGBToHex(unpack(color)), false, tocolor(255,255,255,0), {"Poppins-Regular", 12}, 1, "center", "center", false}, 4)

    pickerData["color"] = convertColor({color[1], color[2], color[3]})
    pickerData["hue"], pickerData["saturation"], pickerData["lightness"] = RGBToHSL(pickerData["color"][1] / 255, pickerData["color"][2] / 255, pickerData["color"][3] / 255)
    
    local currentR, currentG, currentB = HSLToRGB(pickerData["hue"], pickerData["saturation"], 0.5)
    pickerData["selectedColor"] = convertColor({currentR * 255, currentG * 255, currentB * 255})
end

function RGBToHex(red, green, blue)
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end
	return string.format("%.2X%.2X%.2X", red, green, blue)
end

function convertColor(color)
	color[1] = fixColorValue(color[1])
	color[2] = fixColorValue(color[2])
	color[3] = fixColorValue(color[3])
	color[4] = fixColorValue(color[4])

	return color
end

function fixColorValue(value)
	if not value then
		return 255
	end
	
	value = math.floor(tonumber(value))
	
	if value < 0 then
		return 0
	elseif value > 255 then
		return 255
	else
		return value
	end
end

function HSLToRGB(hue, saturation, lightness)
	local lightnessValue2
	
	if lightness < 0.5 then
		lightnessValue2 = lightness * (saturation + 1)
	else
		lightnessValue2 = (lightness + saturation) - (lightness * saturation)
	end
	
	local lightnessValue1 = lightness * 2 - lightnessValue2
	local r = HUEToRGB(lightnessValue1, lightnessValue2, hue + 1 / 3)
	local g = HUEToRGB(lightnessValue1, lightnessValue2, hue)
	local b = HUEToRGB(lightnessValue1, lightnessValue2, hue - 1 / 3)
	
	return r, g, b
end

function HUEToRGB(lightness1, lightness2, hue)
	if hue < 0 then
		hue = hue + 1
	elseif hue > 1 then
		hue = hue - 1
	end

	if hue * 6 < 1 then
		return lightness1 + (lightness2 - lightness1) * hue * 6
	elseif hue * 2 < 1 then
		return lightness2
	elseif hue * 3 < 2 then
		return lightness1 + (lightness2 - lightness1) * (2 / 3 - hue) * 6
	else
		return lightness1
	end
end

function RGBToHSL(red, green, blue)
	local max = math.max(red, green, blue)
	local min = math.min(red, green, blue)
	local hue, saturation, lightness = 0, 0, (min + max) / 2

	if max == min then
		hue, saturation = 0, 0
	else
		local different = max - min

		if lightness < 0.5 then
			saturation = different / (max + min)
		else
			saturation = different / (2 - max - min)
		end

		if max == red then
			hue = (green - blue) / different
			
			if green < blue then
				hue = hue + 6
			end
		elseif max == green then
			hue = (blue - red) / different + 2
		else
			hue = (red - green) / different + 4
		end

		hue = hue / 6
	end

	return hue, saturation, lightness
end

function drawBorder(x, y, w, h, size, color, postGUI)
	size = size or 2
	
	dxDrawRectangle(x - size, y, size, h, color or tocolor(0, 0, 0, 200), postGUI)
	dxDrawRectangle(x + w, y, size, h, color or tocolor(0, 0, 0, 200), postGUI)
	dxDrawRectangle(x - size, y - size, w + (size * 2), size, color or tocolor(0, 0, 0, 200), postGUI)
	dxDrawRectangle(x - size, y + h, w + (size * 2), size, color or tocolor(0, 0, 0, 200), postGUI)
end

function drawBorderedRectangle(x, y, w, h, borderSize, borderColor, bgColor, postGUI)
	borderSize = borderSize or 2
	borderColor = borderColor or tocolor(0, 0, 0, 200)
	bgColor = bgColor or borderColor
	
	dxDrawRectangle(x, y, w, h, bgColor, postGUI)
	drawBorder(x, y, w, h, borderSize, borderColor, postGUI)
end