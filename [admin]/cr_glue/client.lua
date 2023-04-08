local enabledVehs = {
    --[id] = true
    ["472"] = true, 
    ["473"] = true, 
    ["493"] = true, 
    ["595"] = true, 
    ["484"] = true, 
    ["430"] = true, 
    ["453"] = true, 
    ["452"] = true, 
    ["446"] = true, 
    ["454"] = true, 
    ["422"] = true, 
    ["478"] = true,
}
lastOpenTick = -5000
enabled = false
glue = localPlayer:getData("glue>state")
if not glue then
    gElement = getPedContactElement(localPlayer)
    if localPlayer.vehicle then
        gElement = nil
    end
    
    if isElement(gElement) then
        if getElementType(gElement) == "vehicle" then
            if enabledVehs[gElement.model] then
                enabled = true
            end
        end
    end
else
    gElement = localPlayer:getData("glue>e")
    --outputChatBox(tostring(gElement))
    if isElement(gElement) then
        enabled = true
    end
end

setTimer(
    function()
        if not glue then
            gElement = getPedContactElement(localPlayer)
            if localPlayer.vehicle then
                gElement = nil
            end
            enabled = false
            if isElement(gElement) then
                if getElementType(gElement) == "vehicle" then
                    if enabledVehs[tostring(gElement.model)] then
                        --outputChatBox(gElement.model)
                        enabled = true
                    end
                end
            end
        else
            enabled = true
        end
        
        --enabled = true
        
        if enabled then
            local text = ""
            local colorCode = exports['cr_core']:getServerColor('red', true)
            if not glue then
                text = "#f2f2f2A járműhöz tapadáshoz használd a(z) ["..colorCode.."X#f2f2f2] billentyűt!"
            else
                text = "#f2f2f2A járműhöz tapadás abbahagyásához használd a(z) ["..colorCode.."X#f2f2f2] billentyűt!"
            end

            if not start then
                exports['cr_dx']:startInfoBar(text)
                start = true
            end

            if start then 
                exports['cr_dx']:setInfoBarText(text)
            end 
        else
            if start then
                start = false
                
                exports['cr_dx']:closeInfoBar()
            end
        end
    end, 50, 0
)

if enabled then
    if not start then
        addEventHandler("onClientRender", root, drawnText, true, "low-5")
        start = true
        startTick = getTickCount()
    end
else
    if start then
        --removeEventHandler("onClientRender", root, drawnText)
        start = false
        startTick = getTickCount()
    end
end

function deatach()
    glue = false
    localPlayer:setData("glue>state", glue)
    localPlayer:setData("glue>e", nil)
    triggerServerEvent("glue>vehicle>deattach",localPlayer)
end

function attach()
    local px, py, pz = getElementPosition(localPlayer)
    local vx, vy, vz = getElementPosition(gElement)
    local sx = px - vx
    local sy = py - vy
    local sz = pz - vz

    local rotpX = 0
    local rotpY = 0
    local a,b,rotpZ = getElementRotation(localPlayer)     

    local rotvX,rotvY,rotvZ = getElementRotation(gElement)

    local t = math.rad(rotvX)
    local p = math.rad(rotvY)
    local f = math.rad(rotvZ)

    local ct = math.cos(t)
    local st = math.sin(t)
    local cp = math.cos(p)
    local sp = math.sin(p)
    local cf = math.cos(f)
    local sf = math.sin(f)

    local z = ct*cp*sz + (sf*st*cp + cf*sp)*sx + (-cf*st*cp + sf*sp)*sy
    local x = -ct*sp*sz + (-sf*st*sp + cf*cp)*sx + (cf*st*sp + sf*cp)*sy
    local y = st*sz - sf*ct*sx + cf*ct*sy

    local rotX = rotpX - rotvX
    local rotY = rotpY - rotvY
    local rotZ = rotpZ - rotvZ

    glue = true
    localPlayer:setData("glue>state", glue)
    localPlayer:setData("glue>e", gElement)

    triggerServerEvent("glue>vehicle>attach",localPlayer,gElement,x, y, z, rotX, rotY, rotZ)
end

bindKey("x", "down",
    function()
        if start then
            if glue then -- Attach
                local now = getTickCount()
                local a = 1
                if now <= lastOpenTick + a * 1000 then
                    return
                end
                deatach()
                
                lastOpenTick = getTickCount()
            else -- Dettach
                local now = getTickCount()
                local a = 1
                if now <= lastOpenTick + a * 1000 then
                    return
                end
                
                attach()
                
                lastOpenTick = getTickCount()
            end
        end
    end
)

addEventHandler("onClientElementDestroy",root,
	function()
		if gElement == source then
			deatach()
		end
	end
)

addEventHandler("onClientElementDataChange",root,
	function(dName)
		if getElementType(source) == "vehicle" and dName == "veh >> loaded" then
			if gElement == source then
				local bool = getElementData(source,dName)
				if not bool then
					deatach()
				end
			end
		end
	end
)