local start, text, lines

function startInfoBar(a)
    if not start then
        start = true 
        text = a or ""
        createRender("drawnInfoBar", drawnInfoBar)

        exports["cr_dx"]:startFade("drawnInfoBar", 
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

        local line = 0
        local latest = 0
        
        while true do
            local a, b = utf8.find(text, "\n", latest)
            if a and b then
                latest = b + 1
                line = line + 1
            else
                break
            end
        end            

        lines = math.max(1, line)
    end
end 

function closeInfoBar()
    if start then 
        start = false

        exports["cr_dx"]:startFade("drawnInfoBar", 
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

function setInfoBarText(a)
    if start then 
        if text ~= a then 
            text = a or ""

            local line = 0
            local latest = 0
            
            while true do
                local a, b = utf8.find(text, "\n", latest)
                if a and b then
                    latest = b + 1
                    line = line + 1
                else
                    break
                end
            end            

            lines = math.max(1, line)
        end
    end 
end 

local sx, sy = guiGetScreenSize()
function drawnInfoBar()
    local alpha, progress = exports["cr_dx"]:getFade("drawnInfoBar")
    if not start then 
        if progress >= 1 then 
            destroyRender("drawnInfoBar")
        end
    end
    
    local font = exports['cr_fonts']:getFont("Poppins-Medium", 12)
    
    local width = dxGetTextWidth(text, 1, font, true) + 20
    local height = (dxGetFontHeight(1, font) * lines) + 10
    
    dxDrawRectangle(sx/2 - width/2, 50 - height/2, width, height, tocolor(51,51,51,alpha * 0.8))
    dxDrawText(text, sx/2, 50, sx/2, 50, tocolor(242,242,242,alpha),1, font, "center", "center", false, false, false, true)
end