local s = Vector2(guiGetScreenSize());
local state = false;

function isCursorHover(x, y, width, height)
	if(not isCursorShowing()) then
		return false
	end
	local sx, sy = guiGetScreenSize()
	local cx, cy = getCursorPosition()
	local cx, cy = (cx*sx), (cy*sy)
	return ((cx >= x and cx <= x+width ) and (cy >= y and cy <= y+height))
end

function isHover(px, py, pw, ph, x, y, w, h)
	return ((px+(pw/2) >= x and py+(ph/2) <= x+w ) and (py >= y and py <= y+h))
end

function renderHandbrake()
    if not localPlayer.vehicle or localPlayer:getData("inDeath") or localPlayer:getData('handbrakeDisabled') then 
        if state then 
            --removeEventHandler("onClientRender", root, renderHandbrake)
            exports['cr_dx']:startFade("handbrake", 
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
            state = false 
        end 
    end 

    local alpha, progress = exports['cr_dx']:getFade("handbrake")
    if not state then 
        if progress >= 1 then 
            showCursor(false)
            localPlayer:setData("keysDenied", oldData["keysDenied"])
            destroyRender("renderHandbrake")
            return 
        end 
    end 

    local e, x, y, w, h = exports["cr_interface"]:getDetails("handbrake")
    if (e) then
        dxDrawImage(x, y, w, h, "files/handBrakeBG.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
        local cx, cy = getCursorPosition()
        cx, cy = cx*s.x, cy*s.y
        local _y = isCursorHover(0, y+2, s.x, h-20) and cy or (cy < y+2 and y+2 or y+h-20) 
        dxDrawImage(x + w/2 - 32/2, _y, 32, 18, "files/handBrakePointer.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        if localPlayer.vehicle then 
            if(isHover(x, _y, 32, 18, x, y+h-20, w, h)) then
                if(not localPlayer.vehicle:getData("veh >> handbrake")) then
                    playSound("files/handbrake.wav")
                    localPlayer.vehicle:setData("veh >> handbrake", true)
                    triggerServerEvent("toggleHandbrake", localPlayer, localPlayer.vehicle, true)
                end
            end
            if(isHover(x, _y, 32, 18, x, y, w, 20)) then
                if(localPlayer.vehicle:getData("veh >> handbrake")) then
                    playSound("files/handbrakeoff.wav")
                    localPlayer.vehicle:setData("veh >> handbrake", false)
                    triggerServerEvent("toggleHandbrake", localPlayer, localPlayer.vehicle, false)
                end
            end
        end 
    end
end

bindKey("lalt", "down", function() 
    if (localPlayer.vehicle and localPlayer.vehicleSeat == 0 and not localPlayer:getData("inDeath") and not isCursorShowing() and not localPlayer:getData("keysDenied") and not localPlayer:getData('handbrakeDisabled')) then
        if(not state) then
            local speed = localPlayer.vehicle.velocity
            local kmh = ((speed.x^2 + speed.y^2 + speed.z^2)^(0.5))*180
            if(kmh <= 1) then
                exports['cr_dx']:startFade("handbrake", 
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
                createRender("renderHandbrake", renderHandbrake)    
                showCursor(true)
                setCursorAlpha(0)
                --addEventHandler("onClientRender", root, renderHandbrake)
                local e, x, y, w, h = exports["cr_interface"]:getDetails("handbrake")
                setCursorPosition(x+w/2, y+h/2)
                state = true
                oldData = {
                    ["keysDenied"] = localPlayer:getData("keysDenied"),
                }
                localPlayer:setData("keysDenied", true)

                exports['cr_interface']:setNode('handbrake', 'active', true)
            end
        end
    end
end)

bindKey("lalt", "up", function() 
    if(state) then
        --removeEventHandler("onClientRender", root, renderHandbrake)
        exports['cr_dx']:startFade("handbrake", 
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

        exports['cr_interface']:setNode('handbrake', 'active', false)
        
        state = false
    end
end)