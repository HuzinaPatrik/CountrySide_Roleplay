widgets = {mySavedConfig = {}, disabledWidgets = {}}
local sX, sY = guiGetScreenSize()
editorState = false
local moveingWidget = false
local currentlyMoveing = false
local currentlyResizeing = false
local resizeingWidget = -1
local offsetX = 0
local offsetY = 0
local animY = 0
local oState, oState2
local fileName = "widgets.json"
-- local hoveredActionButton = ""
local white = tocolor(230, 230, 230, 255)

addCommandHandler("resethud", 
    function()
        cfg = {}
        widget = {}
        local tables = {}
        defPositions["box"] = nil
        for k,v in pairs(defPositions) do
            tables[k] = v
        end
        local a = toJSON(tables)
        cfg = fromJSON(a)
        
        local tables = {}
        for k,v in pairs(defPositions) do
            if not v["showing"] then
                localPlayer:setData(k..".enabled", false)
                table.insert(tables, {k, v["name"]})
            else
                localPlayer:setData(k..".enabled", true)
            end
        end
        local a = toJSON(tables)
        widget = fromJSON(a)
    end
)

function leftMove(multipler)
    if not tonumber(multipler) then multipler = 1 end
    if not moveingWidget and selected then
        if multipler == 1 then
            lastLeftTick = getTickCount()
        end
        local currentlyMoveing = selected
        local cX, cY = cfg[currentlyMoveing]["x"], cfg[currentlyMoveing]["y"]
        cfg[currentlyMoveing]["x"] = cX - multipler
        cfg[currentlyMoveing]["y"] = cY

        if currentlyMoveing == "box" then
            local parents = cfg["box"]["parents"]
            for k,v in pairs(parents) do
                local name = k
                local offsetX, offsetY = v[1], v[2]
                local cX, cY = cfg["box"]["x"], cfg["box"]["y"]
                cfg[name]["x"] = cX + offsetX
                cfg[name]["y"] = cY + offsetY
            end
        end
    end
end
bindKey("arrow_l", "down", leftMove)

function rightMove(multipler)
    if not tonumber(multipler) then multipler = 1 end
    if not moveingWidget and selected then
        if multipler == 1 then
            lastRightTick = getTickCount()
        end
        local currentlyMoveing = selected
        local cX, cY = cfg[currentlyMoveing]["x"], cfg[currentlyMoveing]["y"]
        cfg[currentlyMoveing]["x"] = cX + multipler
        cfg[currentlyMoveing]["y"] = cY

        if currentlyMoveing == "box" then
            local parents = cfg["box"]["parents"]
            for k,v in pairs(parents) do
                local name = k
                local offsetX, offsetY = v[1], v[2]
                local cX, cY = cfg["box"]["x"], cfg["box"]["y"]
                cfg[name]["x"] = cX + offsetX
                cfg[name]["y"] = cY + offsetY
            end
        end
    end
end
bindKey("arrow_r", "down", rightMove)

function upMove(multipler)
    if not tonumber(multipler) then multipler = 1 end
    if not moveingWidget and selected then
        if multipler == 1 then
            lastUpTick = getTickCount()
        end
        local currentlyMoveing = selected
        local cX, cY = cfg[currentlyMoveing]["x"], cfg[currentlyMoveing]["y"]
        cfg[currentlyMoveing]["x"] = cX
        cfg[currentlyMoveing]["y"] = cY - multipler

        if currentlyMoveing == "box" then
            local parents = cfg["box"]["parents"]
            for k,v in pairs(parents) do
                local name = k
                local offsetX, offsetY = v[1], v[2]
                local cX, cY = cfg["box"]["x"], cfg["box"]["y"]
                cfg[name]["x"] = cX + offsetX
                cfg[name]["y"] = cY + offsetY
            end
        end
    end
end
bindKey("arrow_u", "down", upMove)

function downMove(multipler)
    if not tonumber(multipler) then multipler = 1 end
    if not moveingWidget and selected then
        if multipler == 1 then
            lastDownTick = getTickCount()
        end
        local currentlyMoveing = selected
        local cX, cY = cfg[currentlyMoveing]["x"], cfg[currentlyMoveing]["y"]
        cfg[currentlyMoveing]["x"] = cX
        cfg[currentlyMoveing]["y"] = cY + multipler

        if currentlyMoveing == "box" then
            local parents = cfg["box"]["parents"]
            for k,v in pairs(parents) do
                local name = k
                local offsetX, offsetY = v[1], v[2]
                local cX, cY = cfg["box"]["x"], cfg["box"]["y"]
                cfg[name]["x"] = cX + offsetX
                cfg[name]["y"] = cY + offsetY
            end
        end
    end
end
bindKey("arrow_d", "down", downMove)

local logoRotation = 0
function widgets.draw()
    if not moveingWidget and selected and getKeyState("arrow_l") and lastLeftTick + 250 <= getTickCount() then
        leftMove(0.25)
    end
    
    if not moveingWidget and selected and getKeyState("arrow_r") and lastRightTick + 250 <= getTickCount() then
        rightMove(0.25)
    end
    
    if not moveingWidget and selected and getKeyState("arrow_u") and lastUpTick + 250 <= getTickCount() then
        upMove(0.25)
    end
    
    if not moveingWidget and selected and getKeyState("arrow_d") and lastDownTick + 250 <= getTickCount() then
        downMove(0.25)
    end
    
    font = exports['cr_fonts']:getFont("Poppins-Medium", 12)
    
	--dxDrawRectangle(0, 0, sX, sY, tocolor(0, 0, 0, 50))
	
    if selected and moveingWidget then
        local r,g,b = exports['cr_core']:getServerColor('red')
        dxDrawImage(sx/2 - 70, 20, 60, 60, "images/bin.png", 0, 0, animation1FOV, tocolor(r,g,b, 255)) 
        local r,g,b = exports['cr_core']:getServerColor('blue')
        dxDrawImage(sx/2 + 10, 20, 60, 60, "images/reset.png", 0, 0, animation2FOV, tocolor(r,g,b, 255))
    end
    
    local now = getTickCount()
    dxDrawImage(sx / 2 - 130 / 2, sy / 2 - 150 / 2, 130, 150, ":cr_account/files/logo.png", 0, 0, 0, tocolor(255, 255, 255, 255 * 0.35))

	for name, v in pairs(cfg) do
        local _name = name
		if widgets.convertToBool(v["showing"]) and not v["invisible"] then
            if selected ~= name then
                local name = v["name"]
                dxDrawRectangle(v["x"], v["y"], v["width"], v["height"], tocolor(51, 51, 51, 255 * 0.35), true)
                dxDrawText(name, v["x"], v["y"], v["width"] + v["x"], v["height"] + v["y"], tocolor(242,242,242, 180), 1, font, "center", "center", false, false, true, true)
            else
                local name = v["name"]
                dxDrawRectangle(v["x"], v["y"], v["width"], v["height"], tocolor(51, 51, 51, 255 * 0.75), true)
                dxDrawText(name, v["x"], v["y"], v["width"] + v["x"], v["height"] + v["y"], tocolor(242,242,242, 255), 1, font, "center", "center", false, false, true, true)
            end
			--dxDrawRectangle(v["x"], v["y"], v["width"], 30, tocolor(0, 0, 0, 255 * 0.5), true)
            local a = 5

			if v["sizeable"] then
                if widgets.isInBox(v["x"] + v["width"] - 16, v["y"] + v["height"] - 16, 16, 16) then
                    dxDrawImage(v["x"] + v["width"] - 16, v["y"] + v["height"] - 16, 16, 16, "images/resize.png", 0, 0, 0, tocolor(255, 255, 255, 220), 
                    true)
                else
				    dxDrawImage(v["x"] + v["width"] - 16, v["y"] + v["height"] - 16, 16, 16, "images/resize.png", 0, 0, 0, tocolor(255, 255, 255, 180), 
                    true)
                end
			end
		end
	end
    
    if startedSelecting then
        local x, y = selectX, selectY
        local cX, cY = getCursorPosition()
        cX, cY = cX * sX, cY * sY   
        local w, h = cX - x, cY - y
        
        if w <= 0 then
            x = x + w
            w = w * -1
        end
        
        if h <= 0 then
            y = y + h
            h = h * -1
        end
        dxDrawRectangle(x, y, w, h, tocolor(124,197,118, 180))
    end
	
	-- Disabled Widgets
	if #widget > 0 then
        --if isInSlot(250 - 8, 20 + 10, 16, 16) then
        dxDrawRectangle(20, 20, 250, 35, tocolor(33, 33, 33, 255 * 0.85), true)
        local fullY = 35
        if widgetsEnabled then
            if anim then
                fullY = animY
            else
                fullY = 35 + (#widget * 33) + 10
            end
        else
            if anim then
                fullY = animY
            end
        end
        dxDrawRectangle(20, 20, 250, fullY, tocolor(51, 51, 51, 255 * 0.65), true)
        dxDrawText("Widgetek", 20, 20, 250 + 20, 55, white, 1, font, "center", "center", false, false, true, true)
        
        local animColor
        if not widgetsEnabled and anim then
            animColor = {210, 49, 49}
        end
        if animFOVStarted and not animFOVStarted2 then
            local now = getTickCount()
            local elapsedTime = now - startTime
            local duration = endTime - startTime
            local progress = elapsedTime / duration

            local r, g, b = interpolateBetween ( 
            124, 197, 118,
            210, 49, 49, 
            progress, "OutBounce")

            animColor = {r,g,b}
        end
        
        if animFOVStarted2 and not animFOVStarted then
            local now = getTickCount()
            local elapsedTime = now - startTime
            local duration = endTime - startTime
            local progress = elapsedTime / duration

            local r, g, b = interpolateBetween ( 
            210, 49, 49,
            124, 197, 118, 
            progress, "OutBounce")

            animColor = {r,g,b}
        end
        
        if widgets.isInBox(250 - 10, 20 + 35/2 - 24/2, 24, 24) then
            dxDrawImage(250 - 10, 20 + 35/2 - 24/2, 24, 24, "images/add.png", animFOV or 0, 0, 0, animColor and tocolor(animColor[1], animColor[2], animColor[3], 220) or tocolor(124,197,118, 220), true)
        else
            dxDrawImage(250 - 10, 20 + 35/2 - 24/2, 24, 24, "images/add.png", animFOV or 0, 0, 0, animColor and tocolor(animColor[1], animColor[2], animColor[3], 180) or tocolor(124,197,118, 180), true)
        end

        if widgetsEnabled or anim then
            local startY = (2) * 32.5
            for k, v in pairs(widget) do
                if startY + 33 <= animY or not anim then
                    dxDrawRectangle(25, startY, 240, 30, tocolor(44, 44, 44, 255 * 0.85), true)
                    if widgets.isInBox(250 - 10, startY + 30/2 - 24/2, 16, 16) then
                        dxDrawImage(250 - 10, startY + 30/2 - 24/2, 24, 24, "images/add.png", 0, 0, 0, tocolor(124,197,118, 220), true)
                    else
                        dxDrawImage(250 - 10, startY + 30/2 - 24/2, 24, 24, "images/add.png", 0, 0, 0, tocolor(124,197,118, 180), true)
                    end
                    dxDrawText(v[2], 30, startY, 250, startY + 30, white, 1, font, "center", "center", false, false, true, true)
                    startY = startY + 33
                end
            end
        end
        --end
    end
end
--addEventHandler("onClientRender", root, widgets.draw, true, "low-5")

addEventHandler("onClientCursorMove", root,
    function()
        --outputChatBox("asd")
        if moveingWidget then
            --outputChatBox("asd2")
            if isCursorShowing() then
                --outputChatBox("asd3")
                local cX, cY = getCursorPosition()
                cX, cY = cX * sX, cY * sY
                cfg[currentlyMoveing]["x"] = cX + offsetX
                cfg[currentlyMoveing]["y"] = cY + offsetY
                
                if currentlyMoveing == "box" then
                    local parents = cfg["box"]["parents"]
                    for k,v in pairs(parents) do
                        local name = k
                        local offsetX, offsetY = v[1], v[2]
                        local cX, cY = cfg["box"]["x"], cfg["box"]["y"]
                        cfg[name]["x"] = cX + offsetX
                        cfg[name]["y"] = cY + offsetY
                    end
                end
                --parents[k] = {selectX - v["y"], selectY - v["y"]}
            end
        end

        if currentlyResizeing then
            if isCursorShowing() then
                local cX, cY = getCursorPosition()
                cX, cY = cX * sX, cY * sY
                cfg[resizeingWidget]["width"] = cX - cfg[resizeingWidget]["x"]
                cfg[resizeingWidget]["height"] = cY - cfg[resizeingWidget]["y"]
                if (cfg[resizeingWidget]["width"] <= defPositions[resizeingWidget]["minWidth"]) then
                    cfg[resizeingWidget]["width"] = defPositions[resizeingWidget]["minWidth"]
                elseif (cfg[resizeingWidget]["width"] >= defPositions[resizeingWidget]["maxWidth"]) then
                    cfg[resizeingWidget]["width"] = defPositions[resizeingWidget]["maxWidth"]
                end
                
                if (cfg[resizeingWidget]["height"] <= defPositions[resizeingWidget]["minHeight"]) then
                    cfg[resizeingWidget]["height"] = defPositions[resizeingWidget]["minHeight"]
                elseif (cfg[resizeingWidget]["height"] >= defPositions[resizeingWidget]["maxHeight"]) then
                    cfg[resizeingWidget]["height"] = defPositions[resizeingWidget]["maxHeight"]    
                end
            end
        end
    end
)

lastClickTick = -500

function widgets.click(button, state, absX, absY)
    if button == "left" and state == "down" and editorState and lastClickTick + 1020 <= getTickCount() then
        if widgets.isInBox(250 - 8, 20 + 10, 24, 24) then
            lastClickTick = getTickCount()
            widgetsEnabled = not widgetsEnabled
            selected = nil
            if widgetsEnabled then
                anim = true --120
                widgets.animate(35, 35 + (#widget * 33) + 10, 4, 520, function(v) 
                    animY = v
                    if animY >= 35 + (#widget * 33) + 10 then
                        anim = false
                    end
                    --cfg[k] = fromJSON(toJSON(defPositions[k]))
                end, false)
                
                animFOVStarted = false
                animFOVStarted2 = false
                widgets.animate(0, 45, 4, 520, function(v) 
                    animFOV = v
                    --cfg[k] = fromJSON(toJSON(defPositions[k]))
                end, function()
                    animFOVStarted2 = false
                    animFOVStarted = true
                    startTime = getTickCount()
                    endTime = startTime + 500
                end)
            else
                
                --widgetsEnabled = true
                
                --outputChatBox("BEZÁRÁS")
                
                anim = true
                local y = 35 + (#widget * 33) + 10
                
                --outputChatBox("Y: "..y)
                widgets.animate(y, 35, 4, 520, function(v) 
                    animY = v
                    if animY <= 35 then
                        anim = false
                    end
                    --cfg[k] = fromJSON(toJSON(defPositions[k]))
                end)
                
                animFOVStarted = false
                animFOVStarted2 = false
                widgets.animate(45, 0, 4, 520, function(v) 
                    animFOV = v
                    --cfg[k] = fromJSON(toJSON(defPositions[k]))
                end, function()
                    animFOVStarted2 = true
                    animFOVStarted = false
                    startTime = getTickCount()
                    endTime = startTime + 500
                end)
            end
            return
        end
            
        if widgetsEnabled then
            local startY = (2) * 32.5
            for k, v in ipairs(widget) do
                --local k = v
                if widgets.isInBox(250 - 10, startY + 30/2 - 24/2, 16, 16, absX, absY) then
                    --outputChatBox("interface."..v.."-visible")
                    localPlayer:setData(v[1]..".enabled", true)
                    --cfg[v]["x"] = defPositions[v]["x"]
                    --cfg[v]["y"] = defPositions[v]["y"]
                    local val = toJSON(defPositions[v[1]])
                    cfg[v[1]] = fromJSON(val)
                    cfg[v[1]]["showing"] = true
                    table.remove(widget, k)
                    return
                end				
                startY = startY + 33
            end
        end
	end
    
    if button == "left" and state == "down" and not editorState then
        local shortest = 9999
        selected = nil
		for k, v in pairs(cfg) do
            if widgets.convertToBool(v["showing"]) then
                local ns = v["height"] + v["width"]

                -- Resize/Move
                if v["invisible"] and v["active"] then
                    if not widgets.isInBox(v["x"] + v["width"] - 16, v["y"] + v["height"] - 16, 16, 16, absX, absY) then
                        if widgets.isInBox(cfg[k]["x"], cfg[k]["y"], cfg[k]["width"], cfg[k]["height"], absX, absY) then
                            if ns < shortest then
                                shortest = ns
                                currentlyMoveing = k
                                moveingWidget = true
                                selected = k
                                offsetX = cfg[k]["x"] - absX
                                offsetY = cfg[k]["y"] - absY
                            end
                        end
                    end
                end
            end
        end
    elseif button == "middle" and state == "down" and not editorState then
        local shortest = 9999
        local selected = nil
		for k, v in pairs(cfg) do
            if widgets.convertToBool(v["showing"]) then
                local ns = v["height"] + v["width"]

                -- Resize/Move
                if v["invisible"] and v["active"] then
                    if not widgets.isInBox(v["x"] + v["width"] - 16, v["y"] + v["height"] - 16, 16, 16, absX, absY) then
                        if widgets.isInBox(cfg[k]["x"], cfg[k]["y"], cfg[k]["width"], cfg[k]["height"], absX, absY) then
                            if ns < shortest then
                                shortest = ns
                                selected = k
                            end
                        end
                    end
                end
            end
        end
        
        local k = selected
        
        if k then
            if not defPositions[k] and cfg[k]['defPositions'] then 
                defPositions[k] = fromJSON(toJSON(cfg[k]['defPositions']))
            end 

            if not defPositions[k] then 
                return 
            end 
            widgets.animate(cfg[k]["x"], defPositions[k]["x"], 4, 120, function(v) 
                cfg[k]["x"]  = v

                if k == "box" then
                    local parents = cfg["box"]["parents"]
                    for k,v in pairs(parents) do
                        local name = k
                        local offsetX, offsetY = v[1], v[2]
                        local cX, cY = cfg["box"]["x"], cfg["box"]["y"]
                        cfg[name]["x"] = cX + offsetX
                        cfg[name]["y"] = cY + offsetY
                    end
                end
            end, false)

            widgets.animate(cfg[k]["y"], defPositions[k]["y"], 4, 120, function(v) 
                cfg[k]["y"]  = v
            end, false)

            widgets.animate(cfg[k]["width"], defPositions[k]["width"], 4, 120, function(v) 
                cfg[k]["width"]  = v
                --cfg[k] = fromJSON(toJSON(defPositions[k]))
            end, false)

            widgets.animate(cfg[k]["height"], defPositions[k]["height"], 4, 120, function(v) 
                cfg[k]["height"]  = v
                --cfg[k] = fromJSON(toJSON(defPositions[k]))
            end, false)

            cfg[k]["type"] = defPositions[k]["type"]
            cfg[k]["columns"] = defPositions[k]["columns"]
        end
	elseif button == "left" and state == "down" and editorState then
        
        --outputChatBox("asd"
        
        --cfg["box"] = nil
        --defPositions["box"] = nil
        --startedSelecting = false
        
        local shortest = 9999
        selected = nil
		for k, v in pairs(cfg) do
            if widgets.convertToBool(v["showing"]) and not v["invisible"] then
                local ns = v["height"] + v["width"]

                -- Resize/Move
                if not widgets.isInBox(v["x"] + v["width"] - 16, v["y"] + v["height"] - 16, 16, 16, absX, absY) then
                    if widgets.isInBox(cfg[k]["x"], cfg[k]["y"], cfg[k]["width"], cfg[k]["height"], absX, absY) then
                        if k == "box" then
                            ns = -1
                        end
                        if ns < shortest then
                            shortest = ns
                            currentlyMoveing = k
                            moveingWidget = true
                            selected = k
                            offsetX = cfg[k]["x"] - absX
                            offsetY = cfg[k]["y"] - absY
                        end
                    end
                else
                    moveingWidget = nil
                    selected = nil
                end

                if widgets.isInBox(v["x"] + v["width"] - 16, v["y"] + v["height"] - 16, 16, 16, absX, absY) and not moveingWidget then
                    if (defPositions[k]["sizeable"]) then
                        currentlyResizeing = true
                        resizeingWidget = k
                        selected = k
                       -- outputChatBox("resize")
                        break
                    end
                end
            end
		end
        
        if selected then
            if selected ~= "box" then
                if cfg["box"] then
                    moveingWidget = nil
                    cfg["box"] = nil
                    defPositions["box"] = nil
                    startedSelecting = false
                end
            end
        end
        
        if not selected then
            if isTimer(ccTimer) then killTimer(ccTimer) end
            cfg["box"] = nil
            defPositions["box"] = nil
            startedSelecting = false
            local cX, cY = getCursorPosition()
            cX, cY = cX * sX, cY * sY
            selectX, selectY = cX, cY
            ccTimer = setTimer(
                function()
                    if getKeyState("mouse1") then
                        startedSelecting = true
                        --outputChatBox("asd2")
                    end
                end, 125, 1
            )
        end
	elseif button == "left" and state == "up" then    
        if startedSelecting then
            startedSelecting = false
            local x, y = selectX, selectY
            local cX, cY = getCursorPosition()
            cX, cY = cX * sX, cY * sY   
            local w, h = cX - x, cY - y

            if w <= 0 then
                x = x + w
                w = w * -1
            end

            if h <= 0 then
                y = y + h
                h = h * -1
            end
            
            if math.abs(w) <= 20 then return end
            if math.abs(h) <= 20 then return end
            
            local parents = {}
            
            for k, v in pairs(cfg) do
                if widgets.convertToBool(v["showing"]) and not v["invisible"] then
                    if isWidgetInSelectedBox(x, y, w, h, v) then
                        --outputChatBox("True"..k)
                        parents[k] = {v["x"] - x, v["y"] - y}
                    end
                end    
            end
            
            
            local cfgTable = toJSON({
                ["name"] = "Kijelölt terület",
                ["turnable"] = true,
                ["showing"] = true,
                ["sizeable"] = false,
                ["width"] = w,
                ["height"] = h,
                ["x"] = x,
                ["y"] = y,
                ["parents"] = parents
            })
            cfg["box"] = fromJSON(cfgTable)
            defPositions["box"] = fromJSON(cfgTable)
        end
		if moveingWidget then
            local k = selected
            if widgets.isInBox(sx/2 - 70, 20, 60, 60) then
                if cfg[k]["turnable"] then
                    cfg[k]["showing"] = false
                    --outputChatBox("interface."..k.."-visible")
                    localPlayer:setData(k..".enabled", false)
                    if k ~= "box" then
                        table.insert(widget, {k, cfg[k]["name"]})
                    end
                    
                    if k == "box" then
                        
                        local parents = cfg["box"]["parents"]
                        
                        widgets.animate(cfg[k]["x"], defPositions[k]["x"], 4, 120, function(v) 
                            --cfg[k]["x"]  = v

                            if k == "box" then
                                local _v = v
                                for k,v in pairs(parents) do
                                    local name = k
                                    local offsetX, offsetY = v[1], v[2]
                                    local cX = _v --, cfg["box"]["y"]
                                    cfg[name]["x"] = cX + offsetX
                                    --cfg[name]["y"] = cY + offsetY
                                end
                            end
                        end, 
                            function()
                                defPositions["box"] = nil
                            end
                        )
                        
                        widgets.animate(cfg[k]["y"], defPositions[k]["y"], 4, 120, function(v) 
                            --cfg[k]["x"]  = v

                            if k == "box" then
                                local _v = v
                                for k,v in pairs(parents) do
                                    local name = k
                                    local offsetX, offsetY = v[1], v[2]
                                    local cY = _v
                                    --cfg[name]["x"] = cY + offsetX
                                    cfg[name]["y"] = cY + offsetY
                                end
                            end
                        end, 
                            function()
                                defPositions["box"] = nil
                            end
                        )
                        
                        cfg["box"] = nil
                        --defPositions["box"] = nil
                    end
                end
            elseif widgets.isInBox(sx/2 + 10, 20, 60, 60) then
                widgets.animate(cfg[k]["x"], defPositions[k]["x"], 4, 120, function(v) 
                    cfg[k]["x"]  = v
                        
                    if k == "box" then
                        local parents = cfg["box"]["parents"]
                        for k,v in pairs(parents) do
                            local name = k
                            local offsetX, offsetY = v[1], v[2]
                            local cX, cY = cfg["box"]["x"], cfg["box"]["y"]
                            cfg[name]["x"] = cX + offsetX
                            cfg[name]["y"] = cY + offsetY
                        end
                    end
                end, false)

                widgets.animate(cfg[k]["y"], defPositions[k]["y"], 4, 120, function(v) 
                    cfg[k]["y"]  = v
                end, false)

                widgets.animate(cfg[k]["width"], defPositions[k]["width"], 4, 120, function(v) 
                    cfg[k]["width"]  = v
                    --cfg[k] = fromJSON(toJSON(defPositions[k]))
                end, false)

                widgets.animate(cfg[k]["height"], defPositions[k]["height"], 4, 120, function(v) 
                    cfg[k]["height"]  = v
                    --cfg[k] = fromJSON(toJSON(defPositions[k]))
                end, false)

                cfg[k]["type"] = defPositions[k]["type"]
                cfg[k]["columns"] = defPositions[k]["columns"]
                -- cfg[k]["x"] = defPositions[k]["x"]
                -- cfg[k]["y"] = defPositions[k]["y"]
            end
			moveingWidget = false
			currentlyMoveing = false
		end
		if currentlyResizeing then
			currentlyResizeing = false
			resizeingWidget = -1
		end
	end
end
addEventHandler("onClientClick", root, widgets.click)

function jsonGET(file)
    local fileHandle
    local jsonDATA = {}
    if not fileExists(file) then
        fileHandle = fileCreate(file)
        local table = {}
        for k,v in pairs(defPositions) do
            --if v["showing"] then
                table[k] = v
            --end
        end
        fileWrite(fileHandle, toJSON(table))
        fileClose(fileHandle)
        fileHandle = fileOpen(file)
    else
        fileHandle = fileOpen(file)
    end
    if fileHandle then
        local buffer
        local allBuffer = ""
        while not fileIsEOF(fileHandle) do
            buffer = fileRead(fileHandle, 500)
            allBuffer = allBuffer..buffer
        end
        jsonDATA = fromJSON(allBuffer)
        fileClose(fileHandle)
    end
    return jsonDATA
end

function jsonGET2(file)
    local fileHandle
    local jsonDATA = {}
    if not fileExists(file) then
        fileHandle = fileCreate(file)
        local tables = {}
        for k,v in pairs(defPositions) do
            if not v["showing"] then
                table.insert(tables, k)
            end
        end
        fileWrite(fileHandle, toJSON(tables))
        fileClose(fileHandle)
        fileHandle = fileOpen(file)
    else
        fileHandle = fileOpen(file)
    end
    if fileHandle then
        local buffer
        local allBuffer = ""
        while not fileIsEOF(fileHandle) do
            buffer = fileRead(fileHandle, 500)
            allBuffer = allBuffer..buffer
        end
        jsonDATA = fromJSON(allBuffer)
        fileClose(fileHandle)
    end
    return jsonDATA
end
 
 
function jsonSAVE(file, data)
    if fileExists(file) then
        fileDelete(file)
    end
    local fileHandle = fileCreate(file)
    fileWrite(fileHandle, toJSON(data))
    fileFlush(fileHandle)
    fileClose(fileHandle)
    return true
end

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        cfg = jsonGET("save/@cfg.json")
        
        for k,v in pairs(cfg) do 
            if not defPositions[k] then
                cfg[k] = nil
                outputDebugString("Old: "..k)
            end
            
            local visible = v["showing"]
            localPlayer:setData(k..".enabled", visible)
        end
        
        widget = jsonGET2("save/@widget.json")
        
        if type(widget) ~= "table" then
            widget = {}
        end
        --outputChatBox(toJSON(widget))
        
        for k,v in pairs(defPositions) do
            if not cfg[k] then
                local data = fromJSON(toJSON(v))
                cfg[k] = data
                outputDebugString("New: "..k)
            end
        end
    end
)
addEventHandler("onClientResourceStop", resourceRoot,
    function()
        jsonSAVE("save/@cfg.json", cfg)
        --outputChatBox(toJSON(widget))
        jsonSAVE("save/@widget.json", widget)
    end
)

function isWidgetInSelectedBox(x, y, w, h, v)
    --dxDrawRectangle(x,y,10, 10)
    local wX, wY = v["x"], v["y"]
    if wX >= x and wX <= x + w and wY >= y and wY <= y + h then
        return true
    end
    
    local wX, wY = v["x"] + v["width"]/2, v["y"]
    if wX >= x and wX <= x + w and wY >= y and wY <= y + h then
        return true
    end
    
    local wX, wY = v["x"] + v["width"]/2, v["y"] + v["height"]
    if wX >= x and wX <= x + w and wY >= y and wY <= y + h then
        return true
    end
    
    local wX, wY = v["x"], v["y"] + v["height"]/2
    if wX >= x and wX <= x + w and wY >= y and wY <= y + h then
        return true
    end
    
    
    local wX, wY = v["x"] + v["width"], v["y"] + v["height"]/2
    if wX >= x and wX <= x + w and wY >= y and wY <= y + h then
        return true
    end
    
    local wX, wY = v["x"] + v["width"]/2, v["y"] + v["height"]/2
    if wX >= x and wX <= x + w and wY >= y and wY <= y + h then
        return true
    end
    
    local wX, wY = v["x"] + v["width"], v["y"]
    if wX >= x and wX <= x + w and wY >= y and wY <= y + h then
        return true
    end
    
    local wX, wY = v["x"], v["y"] + v["height"]
    if wX >= x and wX <= x + w and wY >= y and wY <= y + h then
        return true
    end
    
    local wX, wY = v["x"] + v["width"], v["y"] + v["height"]
    if wX >= x and wX <= x + w and wY >= y and wY <= y + h then
        return true
    end
    
    local wX, wY = v["x"] + v["width"]/2/2, v["y"] + v["height"]
    if wX >= x and wX <= x + w and wY >= y and wY <= y + h then
        return true
    end

    local wX, wY = v["x"] + v["width"]/2/2, v["y"] + v["height"]/2
    if wX >= x and wX <= x + w and wY >= y and wY <= y + h then
        return true
    end

    local wX, wY = v["x"] + v["width"]/2/2, v["y"]
    if wX >= x and wX <= x + w and wY >= y and wY <= y + h then
        return true
    end

    local wX, wY = v["x"] + v["width"] * 0.75, v["y"] + v["height"]            
    if wX >= x and wX <= x + w and wY >= y and wY <= y + h then
        return true
    end

    local wX, wY = v["x"] + v["width"] * 0.75, v["y"] + v["height"]/2
    if wX >= x and wX <= x + w and wY >= y and wY <= y + h then
        return true
    end

    local wX, wY = v["x"] + v["width"] * 0.75, v["y"]
    if wX >= x and wX <= x + w and wY >= y and wY <= y + h then
        return true
    end

    
    return false
end

function widgets.convertToBool(string)
	if tostring(string) == "true" then
		return true
	else
		return false
	end
end

function widgets.isInBox(dX, dY, dSZ, dM, eX, eY)
    local eX, eY = getCursorPosition()
    eX, eY = eX * sX, eY * sY
    if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
        return true
    else
        return false
    end
end

function getNode(id, node)
	if cfg[id] and cfg[id][node] then
		return cfg[id][node]
	end
end

function getDefaultNode(id, node)
	if defPositions[id] and defPositions[id][node] then
		return defPositions[id][node]
	end
end

function createNode(id, data)
    if not cfg[id] then 
        cfg[id] = data
        return true 
    end 

    return false
end 

--[[
function setNode(id, node, value)
	if cfg[id] and cfg[id][node] then
		cfg[id][node] = value
	end
end]]

function getDetails(id)
	--if(localPlayer:getData("loggedIn")) then
		if cfg[id] then
			--local x,y,w,h,sizable,turnable, sizeDetails, t, columns = unpack(positions[id]);
			local a = cfg[id]["showing"]
			
			local x = cfg[id]["x"]
			local y = cfg[id]["y"]
			local w = cfg[id]["width"]
			local h = cfg[id]["height"]
			local t = cfg[id]["type"]
			local columns = cfg[id]["columns"]
			
			return a,x,y,w,h,nil,nil,nil,t,columns;
		end
	--else
--		return false, 0, 0, 0, 0, 0,nil,nil,nil, nil, nil;
	--end
end

local convert = {
    ["x"] = 1,
    ["y"] = 2,
    ["w"] = 3,
    ["h"] = 4,
    ["width"] = 3,
    ["height"] = 4,
    ["sizable"] = 5,
    ["turnable"] = 6,
    ["sizeDetails"] = 7,
    ["type"] = 8,
    ["t"] = 8,
    ["columns"] = 9,
};

function setNode(id, node, value)
    if cfg[id] then
        cfg[id][node] = value;
        return true;
    end
end

function widgets.toggle(button, state)
    if not getElementData(localPlayer, "loggedIn") then return end
    animFOVStarted = nil
    animFOV = nil
    anim = nil
    anims = {}
    startedSelecting = nil
    cfg["box"] = nil
    defPositions["box"] = nil
    --outputChatBox(tostring(state))
    if not editorState and isCursorShowing() and state == "down" then
        if getElementData(localPlayer, "keysDenied") then return end
        editorState = true
        --addEventHandler("onClientRender", root, widgets.draw, true, "low-5")
        createRender("widgets.draw", widgets.draw)
        --showCursor(true)
        widgetsEnabled = false
        createShader()
        oState = getElementData(localPlayer, "keysDenied")
        oState2 = exports['cr_custom-chat']:isChatVisible()
        showCursor(true)
        selected = nil
        currentlyMoveing = false
        moveingWidget = false
        setElementData(localPlayer, "keysDenied", true)
        setElementData(localPlayer, "interface.drawn", true)
        setElementData(localPlayer, "script >> drawn", true)
        soundElement = playSound("sounds/loop.mp3", true)
        --showChat(false)
        currentlyResizeing = false
        animation2FOV = 0
        animation1FOV = 0
        --localPlayer:setData("hudVisible", )
        exports['cr_custom-chat']:showChat(false)
        --widgets.checkJSON()
    elseif editorState and isCursorShowing() and state == "up" then
        editorState = false
        showCursor(not isCursorShowing())
        createShader()
        if isElement(soundElement) then destroyElement(soundElement) end
        --removeEventHandler("onClientRender", root, widgets.draw)
        destroyRender("widgets.draw")
        --showCursor(false)
        setElementData(localPlayer, "keysDenied", oState)
        --showChat(oState2)
        setElementData(localPlayer, "interface.drawn", false)
        setElementData(localPlayer, "script >> drawn", false)
        exports['cr_custom-chat']:showChat(oState2)
        selected = nil
        currentlyMoveing = false
        moveingWidget = false
        currentlyResizeing = false
        --widgets.save()
    end
end
bindKey("lctrl", "down", widgets.toggle, "down")
bindKey("lctrl", "up", widgets.toggle, "up")

-- Animate
anims, builtins = {}, {"Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve"}

function table.find(t, v)
	for k, a in ipairs(t) do
		if a == v then
			return k
		end
	end
	return false
end

function widgets.animate(f, t, easing, duration, onChange, onEnd)
	assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
	assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
	assert(type(easing) == "string" or (type(easing) == "number" and (easing >= 1 or easing <= #builtins)), "Bad argument @ 'animate' [Invalid easing at argument 3]")
	assert(type(duration) == "number", "Bad argument @ 'animate' [expected function at argument 4, got "..type(duration).."]")
	assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
	table.insert(anims, {from = f, to = t, easing = table.find(builtins, easing) and easing or builtins[easing], duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})
	return #anims
end

function destroyAnimation(a)
	if anims[a] then
		table.remove(anims, a)
	end
end

addEventHandler("onClientRender", root, function( )
	local now = getTickCount( )
	for k,v in ipairs(anims) do
		v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
		if now >= v.start+v.duration then
			if type(v.onEnd) == "function" then
				v.onEnd( )
			end
			table.remove(anims, k)
		end
	end      
end, true, "low-5")

--Shader
local screenWidth, screenHeight = guiGetScreenSize()
local myScreenSource = dxCreateScreenSource(screenWidth, screenHeight)
local showHud = "false"
local flickerStrength = 10
local blurStrength = 0.001 
local noiseStrength = 0.001
local sstate = false

function createShader()
    if sstate then
        if oldFilmShader then
			destroyElement(oldFilmShader)
			--destroyElement(myScreenSource)
			oldFilmShader = nil
			removeEventHandler("onClientPreRender", root, updateShader)
            sstate = false
		end
    else
        --myScreenSource = dxCreateScreenSource(screenWidth, screenHeight)
        oldFilmShader, oldFilmTec = dxCreateShader("shaders/old_film.fx")
        addEventHandler("onClientPreRender", root, updateShader, false, "low-1")
        sstate = true
    end
end


function updateShader()
    upDateScreenSource()

    if (oldFilmShader) then
        local flickering = math.random(100 - flickerStrength, 100)/100
        dxSetShaderValue(oldFilmShader, "ScreenSource", myScreenSource);
        dxSetShaderValue(oldFilmShader, "Flickering", flickering);
        dxSetShaderValue(oldFilmShader, "Blurring", blurStrength);
        dxSetShaderValue(oldFilmShader, "Noise", noiseStrength);
        dxDrawImage(0, 0, screenWidth, screenHeight, oldFilmShader)
    end
end
--addEventHandler("onClientPreRender", root, updateShader)


function upDateScreenSource()
    dxUpdateScreenSource(myScreenSource)
end

_dxDrawRectangle = dxDrawRectangle
function dxDrawRectangle(x, y, w, h, bgColor, postGUI)
	if (x and y and w and h) then
        
		local borderColor = bgColor
        
		_dxDrawRectangle(x, y, w, h, bgColor, postGUI);
		_dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI);
		_dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI);
		_dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI);
		_dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI);
        
        --Sarkokba pötty:
        --dxDrawRectangle(x + 0.5, y + 0.5, 1, 2, borderColor, postGUI); -- bal felső
        --dxDrawRectangle(x + 0.5, y + h - 1.5, 1, 2, borderColor, postGUI); -- bal alsó
        --dxDrawRectangle(x + w - 2, y + 0.5, 1, 2, tocolor(0,0,0,255), postGUI); -- bal felső
        --dxDrawRectangle(x + w - 2, y + h - 1.5, 1, 2, borderColor, postGUI); -- bal alsó
	end
end