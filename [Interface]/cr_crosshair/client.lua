setPlayerHudComponentVisible("crosshair", false)

local fireMultiplier = 0

sx, sy = guiGetScreenSize()
dxDrawMultipler = (sx / 1920) * 1.5

if sx >= 1920 then
    dxDrawMultipler = 1.2
end

function toggleCrosshair(_, status)
    local weapon = getPedWeapon(localPlayer)
    if status == "down" then 
        oWeapon = weapon
        if weapon == 43 then 
            specialCrosshair = true
            oData = {localPlayer:getData("hudVisible"), localPlayer:getData("keysDenied"), localPlayer:getData("toggleCursor"), exports['cr_custom-chat']:isChatVisible(), localPlayer.alpha}
            setElementData(localPlayer, "hudVisible", false)
            setElementData(localPlayer, "keysDenied", true)
            setElementData(localPlayer, "toggleCursor", true)
            exports['cr_custom-chat']:showChat(false)
            createRender("renderCameraCrosshair", renderCameraCrosshair)
            localPlayer.alpha = 0
        elseif weapon == 34 then
            specialCrosshair = true
            oData = {localPlayer:getData("hudVisible"), localPlayer:getData("keysDenied"), localPlayer:getData("toggleCursor"), exports['cr_custom-chat']:isChatVisible(), localPlayer.alpha}
            setElementData(localPlayer, "hudVisible", false)
            setElementData(localPlayer, "keysDenied", true)
            setElementData(localPlayer, "toggleCursor", true)
            exports['cr_custom-chat']:showChat(false)
            createRender("renderSniperCrosshair", renderSniperCrosshair)
            localPlayer.alpha = 0
        else 
            createRender("renderCrosshair", renderCrosshair)
        end
    else 
        if oWeapon == 43 then 
            specialCrosshair = false
            setElementData(localPlayer, "hudVisible", oData[1])
            setElementData(localPlayer, "keysDenied", oData[2])
            setElementData(localPlayer, "toggleCursor", oData[3])
            exports['cr_custom-chat']:showChat(oData[4])
            destroyRender("renderCameraCrosshair")
            localPlayer.alpha = oData[5]
        elseif oWeapon == 34 then
            specialCrosshair = false
            setElementData(localPlayer, "hudVisible", oData[1])
            setElementData(localPlayer, "keysDenied", oData[2])
            setElementData(localPlayer, "toggleCursor", oData[3])
            exports['cr_custom-chat']:showChat(oData[4])
            destroyRender("renderSniperCrosshair")
            localPlayer.alpha = oData[5]
        else
            destroyRender("renderCrosshair")
        end  
	end
end

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName, oValue, nValue)
        if specialCrosshair then
            if dName == "toggleCursor" then
                oData[3] = nValue
            end
        end
    end
)

addEventHandler("onClientResourceStart", resourceRoot,
	function() 
		bindKey("aim_weapon", "both", toggleCrosshair)
	end
)
	
addEventHandler("onClientResourceStop", resourceRoot,
    function()
        unbindKey("aim_weapon", "both", toggleCrosshair)
    end
)

local skillID = {
    [22] = 69,
    [23] = 70,
    [24] = 71,
    [25] = 72,
    [26] = 73,
    [27] = 74,
    [28] = 75,
    [29] = 76,
    [32] = 69,
    [30] = 77,
    [31] = 78,
    [33] = 79,
}

local textures = {}
    
_dxDrawImage = dxDrawImage
function dxDrawImage(x,y,w,h,img, r, rx, ry, color, postgui)
    if type(img) == "string" then
        if not textures[img] then
            textures[img] = dxCreateTexture(img, "argb", true, "clamp")
        end
        img = textures[img]
    end
    return _dxDrawImage(x,y,w,h,img, r, rx, ry, color, postgui)
end

function armBreaked(e)
    local bone = getElementData(e, "char >> bone") or {true, true, true, true, true}
    if not bone[2] or not bone[3] then 
        return true
    end
    return false
end

function legBreaked(e)
    local bone = getElementData(e, "char >> bone") or {true, true, true, true, true}
    if not bone[4] or not bone[5] then 
        return true
    end
    return false
end

function renderCrosshair()
    if localPlayer:getData("inDeath") or isPedDead(localPlayer) then 
        destroyRender("renderCrosshair")
        return 
    end 

    if armBreaked(localPlayer) then 
        toggleCrosshair(_, "up")
        return 
    end 

    if getPedWeapon(localPlayer) == 0 or isCursorShowing() then 
        toggleCrosshair(_, "up")
        return 
    end 

    if not localPlayer:getAnimation() then 
        local x,y,z = getPedTargetEnd(localPlayer)
        local sx, sy = getScreenFromWorldPosition(x, y, z)
        if skillID[localPlayer:getWeapon()] then 
            if getControlState("fire") then 
                fireMultiplier = math.min(0.5, fireMultiplier + 0.005)
            else 
                fireMultiplier = math.max(0, fireMultiplier - 0.0025)
            end 
        end 

        if sx and sy and skillID[localPlayer:getWeapon()] then 
            local skill = (localPlayer:getStat(skillID[localPlayer:getWeapon()]) / 1000) * 0.25
            local size = 1 - skill + fireMultiplier
            if localPlayer.ducked then 
                size = size - 0.2 
            end 

            local w, h = (30 * dxDrawMultipler) * size, (30 * dxDrawMultipler) * size

            local crosshair = tonumber(localPlayer:getData("char >> crosshair")) or 1
            local r,g,b = unpack(localPlayer:getData("char >> crosshairColor") or {255, 0, 0})
            dxDrawImage(sx - w/2, sy - h/2, w, h, "files/"..crosshair..".png", 0, 0, 0, tocolor(r,g,b, 255))
        end
    end 
end 

local sx, sy = guiGetScreenSize()
function renderSniperCrosshair()
    if localPlayer:getData("inDeath") or isPedDead(localPlayer) then 
        specialCrosshair = false
        setElementData(localPlayer, "toggleCursor", oData[3])
        destroyRender("renderSniperCrosshair")
        localPlayer.alpha = oData[5]
        oWeapon = 0
        return 
    end 

    if legBreaked(localPlayer) or armBreaked(localPlayer) then 
        toggleCrosshair(_, "up")
        return 
    end 

    if isCursorShowing() then 
        toggleCrosshair(_, "up")
        return 
    end 

    if not localPlayer:getAnimation() then 
        dxDrawImage(0, 0, sx, sy, "files/snipercrosshair.png")
    end 
end 

local sx, sy = guiGetScreenSize()
function renderCameraCrosshair()
    if localPlayer:getData("inDeath") or isPedDead(localPlayer) then 
        specialCrosshair = false
        setElementData(localPlayer, "toggleCursor", oData[3])
        destroyRender("renderCameraCrosshair")
        localPlayer.alpha = oData[5]
        oWeapon = 0
        return 
    end 

    if legBreaked(localPlayer) or armBreaked(localPlayer) then 
        toggleCrosshair(_, "up")
        return 
    end 

    if isCursorShowing() then 
        toggleCrosshair(_, "up")
        return 
    end 

    if not localPlayer:getAnimation() then 
        dxDrawImage(0, 0, sx, sy, "files/cameracrosshair.png")
    end
end 