local minFontSize = 6
local maxFontSize = 16
local screenSize = {guiGetScreenSize()}

local disabledHUD = {
    {"all", false},
}

local devSerials = {}
local devNames = {}

addEvent("client >> devserials >> saveCache", true)
addEventHandler("client >> devserials >> saveCache", root,
    function(table1, table2)
        outputDebugString("Return value from serverside >> DevSerials, DevNames")
        devSerials = table1
        devNames = table2
    end
)

function getPlayerDeveloper(player)
    if getElementData(player, "loggedIn") or devMode then
        local serial = getElementData(player, "mtaserial")
        if devSerials[serial] then
            return true, devNames[serial]
        else
            return false
        end
    end
end

addEventHandler("onClientElementDataChange", localPlayer, 
    function(dName, oValue, nValue)
        if dName == "loggedIn" then 
            if nValue then 
                colshapeMinimum = createColSphere(localPlayer.position, 8)
                colshapeMinimum:attach(localPlayer)

                colshapeMedium = createColSphere(localPlayer.position, 16)
                colshapeMedium:attach(localPlayer)

                colshapeMaximum = createColSphere(localPlayer.position, 32)
                colshapeMaximum:attach(localPlayer)
            end 
        end 
    end 
)

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        if localPlayer:getData("loggedIn") then 
            colshapeMinimum = createColSphere(localPlayer.position, 8)
            colshapeMinimum:attach(localPlayer)

            colshapeMedium = createColSphere(localPlayer.position, 16)
            colshapeMedium:attach(localPlayer)

            colshapeMaximum = createColSphere(localPlayer.position, 32)
            colshapeMaximum:attach(localPlayer)
        end

    	setPedTargetingMarkerEnabled(false)
        setBlurLevel(serverData["defaultBlurLevel"])
		for k,v in pairs(disabledHUD) do
		    setPlayerHudComponentVisible(v[1], v[2])
		end

        triggerLatentServerEvent("server >> devserials >> getCacheToReturnClient", 5000, false, localPlayer, localPlayer)
	end
)

addEventHandler('onClientElementModelChange', root, 
    function(oldModel, newModel)
        if oldModel and newModel and isElement(source) then 
            if source.type == 'object' then 
                local x,y,z = getElementPosition(source)

                source.streamable = false
                source.position = Vector3(2500, 2500, 2500)
                source.streamable = true 
                source.position = Vector3(x,y,z)
            end 
        end 
    end 
)

screenSize = {guiGetScreenSize()}
getCursorPos = getCursorPosition
function getCursorPosition()
    if isCursorShowing() then
        local x,y = getCursorPos()
        x, y = x * screenSize[1], y * screenSize[2] 
        return x,y
    else
        return -5000, -5000
    end
end

cursorState = isCursorShowing()
cursorX, cursorY = getCursorPosition()

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end

function isInSlot(xS,yS,wS,hS)
    if isCursorShowing() then
        local cursorX, cursorY = getCursorPosition()
        if isInBox(xS,yS,wS,hS, cursorX, cursorY) then
            return true
        else
            return false
        end
    end 
end

cursorDisabled = false
cursorState = isCursorShowing()
bindKey("m", "down", 
    function()   
        if getElementData(localPlayer, "bar >> Use") then return end
        if getElementData(localPlayer, "inventory.bar-Use") then return end
        if cursorDisabled then return end
        cursorState = not cursorState
	    showCursor(cursorState)
        if cursorState then
            setCursorAlpha(255)
        end
	end
)

function intCursor(state, force)
    cursorState = state
    showCursor(cursorState)
    if cursorState then
        setCursorAlpha(255)
    end
    cursorDisabled = force
end

function getFonts()
    return fonts
end

function dxCreateBorder(x,y,w,h,color)
    if not color then
        color = tocolor(0,0,0,180)
    end
	dxDrawRectangle(x,y,w+1,1,color) -- Fent
	dxDrawRectangle(x,y+1,1,h,color) -- Bal Oldal
	dxDrawRectangle(x+1,y+h,w,1,color) -- Lent Oldal
	dxDrawRectangle(x+w,y+1,1,h,color) -- Jobb Oldal
end

function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY, ignoreDrawn, alpha)
    if not alpha then 
        alpha = 255
    end 

    dxDrawText(text,x,y+1,w,h+1,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY, false, false, false, true) -- Fent
    dxDrawText(text,x,y-1,w,h-1,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY, false, false, false, true) -- Lent
    dxDrawText(text,x-1,y,w-1,h,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY, false, false, false, true) -- Bal
    dxDrawText(text,x+1,y,w+1,h,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY, false, false, false, true) -- Jobb
    
    if not ignoreDrawn then 
        dxDrawText(text,x,y,w,h,color,fontsize,font,aligX,alignY, false, false, false, true)
    end 
end

function linedRectangle(x,y,w,h,color,color2,size)
    if not color then
        color = tocolor(0,0,0,180)
    end
    if not color2 then
        color2 = color
    end
    if not size then
        size = 3
    end
	dxDrawRectangle(x, y, w, h, color) -- Háttér
	dxDrawRectangle(x - size, y - size, w + (size * 2), size, color2) -- felső
	dxDrawRectangle(x - size, y + h, w + (size * 2), size, color2) -- alsó
	dxDrawRectangle(x - size, y, size, h, color2) -- bal
	dxDrawRectangle(x + w, y, size, h, color2) -- jobb
end

function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(0, 0, 0, 180)
		end
		if (not bgColor) then
			bgColor = borderColor
		end
		dxDrawRectangle(x, y, w, h, bgColor, postGUI);
		dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI);
		dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI);
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI);
		dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI);
	end
end

addEventHandler("onClientPedDamage", root,
    function()
        if getElementData(source, "char >> noDamage") then
            cancelEvent()
        end    
    end
)

addEventHandler("onClientPlayerStealthKill", localPlayer,
    function(target)
        if getElementData(target, "char >> noDamage") then
            cancelEvent()
        end    
    end
)

addEventHandler("onClientGUIChanged", root,
    function()
        if not getElementData(source, "onlyNumber") then return end
        guiSetText(source, guiGetText(source):gsub("[^0-9]", "")) 
    end
)

local _addCommandHandler = addCommandHandler
function addCommandHandler(cmd, ...)
	if type(cmd) == "table" then
		for k, v in ipairs(cmd) do
			_addCommandHandler(v, ...)
		end
	else
		_addCommandHandler(cmd, ...)
	end
end

local sm = {}
sm.moov = 0
sm.object1, sm.object2 = nil, nil

local function camRender()
	local x1, y1, z1 = getElementPosition(sm.object1)
	local x2, y2, z2 = getElementPosition(sm.object2)
	setCameraMatrix(x1, y1, z1, x2, y2, z2)
end

local function removeCamHandler()
	if (sm.moov == 1) then
		sm.moov = 0
		removeEventHandler("onClientPreRender", root, camRender)
	end
end

function stopSmoothMoveCamera()
	if (sm.moov == 1) then
		if (isTimer(sm.timer1)) then killTimer(sm.timer1) end
		if (isTimer(sm.timer2)) then killTimer(sm.timer2) end
		if (isTimer(sm.timer3)) then killTimer(sm.timer3) end
		if (isElement(sm.object1)) then destroyElement(sm.object1) end
		if (isElement(sm.object2)) then destroyElement(sm.object2) end
		removeCamHandler()
		sm.moov = 0
	end
end

function smoothMoveCamera(x1, y1, z1, x1t, y1t, z1t, x2, y2, z2, x2t, y2t, z2t, time, easing)
	if (sm.moov == 1) then return false end
	sm.object1 = createObject(1337, x1, y1, z1)
	sm.object2 = createObject(1337, x1t, y1t, z1t)
	setElementAlpha(sm.object1, 0)
	setElementAlpha(sm.object2, 0)
    setElementCollisionsEnabled(sm.object1, false)
    setElementCollisionsEnabled(sm.object2, false)
	setObjectScale(sm.object1, 0.01)
	setObjectScale(sm.object2, 0.01)
	moveObject(sm.object1, time, x2, y2, z2, 0, 0, 0, (easing and easing or "InOutQuad"))
	moveObject(sm.object2, time, x2t, y2t, z2t, 0, 0, 0, (easing and easing or "InOutQuad"))
	
	addEventHandler("onClientPreRender", root, camRender, true, "low")
	sm.moov = 1
	sm.timer1 = setTimer(removeCamHandler, time, 1)
	sm.timer2 = setTimer(destroyElement, time, 1, sm.object1)
	sm.timer3 = setTimer(destroyElement, time, 1, sm.object2)
	
	return true
end

local show = true

bindKey("F9", "down",
    function()
        if not getElementData(localPlayer, "loggedIn") then return end
        if getElementData(localPlayer, "keysDenied") then return end
        show = not show
        showChat(show)
        setElementData(localPlayer, "hudVisible", show)
    end
) 

function sendMessageToAdmin(element, text, neededLevel)
    local pair = {}
    for k,v in pairs(getElementsByType("player")) do
        local adminlevel = getElementData(v, "admin >> level") or 0
        if adminlevel >= neededLevel then
            -- pair[k] = v
            table.insert(pair, v)
        end
    end

    triggerServerEvent("outputChatBoxC", localPlayer, pair, text)

    -- for k,v in pairs(pair) do
    --     triggerLatentServerEvent("outputChatBox", 5000, false, localPlayer, k, text)
    -- end
end

function receiveSoundPlay(e, url, looped, throttled)
    if e == localPlayer then
        playSound(url, looped, throttled)
    end    
end
addEvent("receiveSoundPlay", true)
addEventHandler("receiveSoundPlay", root, receiveSoundPlay)

function outputChatBoxC(text)
    if getElementData(source, "admin >> alogDisabled") then
        outputConsole(string.gsub(text, "#%x%x%x%x%x%x", ""), source)
    else
        outputChatBox(text, 255, 255, 255, true)
    end
end
addEvent("outputChatBoxC", true)
addEventHandler("outputChatBoxC", root, outputChatBoxC)

--// MoneyGlobal

function hasMoney(element, money, bankMoney)
    if not bankMoney then
        local oldMoney = getElementData(element, "char >> money") or 0
        if oldMoney >= money then
            return true
        else
            return false
        end
    else
        local oldMoney = exports['cr_bank']:getBankAccountMoney(element)
        if oldMoney >= money then
            return true
        else
            return false
        end
    end
end

function takeMoney(element, money, bankMoney, ignore)
    if not bankMoney then
        if hasMoney(element, money, false) or ignore then
            local oldMoney = getElementData(element, "char >> money") or 0
            setElementData(element, "char >> money", oldMoney - money)
            return true
        else
            return false
        end
    else
        if hasMoney(element, money, true) or ignore then
            exports['cr_bank']:takeMoney(element, nil, money)
            return true
        else
            return false
        end
    end
end

function giveMoney(element, money, bankMoney)
    if not bankMoney then
        local oldMoney = getElementData(element, "char >> money") or 0
        setElementData(element, "char >> money", oldMoney + money)
        return true
    else
        exports['cr_bank']:giveMoney(element, nil, money)
        return true
    end
end

addEvent("ghostMode", true)
addEventHandler("ghostMode", root,
    function(element, state, ignoreAlpha, settings)
        if not isElement(element) then 
            return 
        end

        if not state then 
            return 
        end

        if not settings then 
            settings = {}
        end 

        if state == "on" then
            if element.type == "vehicle" then
                if localPlayer.vehicle and localPlayer.vehicle == element then
                    gElement = element
                    getBackControl = true
                    exports['cr_controls']:toggleControl("enter_exit", false, "instant")
                    oClip1, oClip2 = getCameraClip()
                    setCameraClip(true, false)
                end
            end

            for k,v in pairs(getElementsByType(element.type)) do
                setElementCollidableWith(element, v, false)
            end

            if element.type ~= "player" then
                for k,v in pairs(getElementsByType("player")) do
                    setElementCollidableWith(element, v, false)
                end
            end

            setElementCollidableWith(element, localPlayer, false)

            if not ignoreAlpha or tonumber(ignoreAlpha) then 
                element.alpha = tonumber(ignoreAlpha) or 150 
            end 

            element:setData("ghostMode", true)

            element:setData("ghostMode >> settings", settings)

            if settings['customAlpha'] then 
                element.alpha = tonumber(settings['customAlpha'])
            end 
        elseif state == "off" then
            if getBackControl then 
                exports['cr_controls']:toggleControl("enter_exit", true, "instant")
                getBackControl = false
                setCameraClip(oClip1, oClip2)
                gElement = nil
            end

            for k,v in pairs(getElementsByType(element.type)) do
                if not v:getData("ghostMode") then
                    setElementCollidableWith(element, v, true)
                end
            end

            if element.type ~= "player" then
                for k,v in pairs(getElementsByType("player")) do
                    if not v:getData("ghostMode") then
                        setElementCollidableWith(element, v, true)
                    end
                end
            end

            setElementCollidableWith(element, localPlayer, true)

            if not ignoreAlpha or tonumber(ignoreAlpha) then 
                element.alpha = tonumber(ignoreAlpha) or 255
            end 

            element:setData("ghostMode", false)
            element:setData("ghostMode >> settings", nil)
        end
    end
)

addEventHandler("onClientElementDestroy", root,
    function()
        if gElement == source and getBackControl then
            exports['cr_controls']:toggleControl("enter_exit", true, "instant")
            getBackControl = false
            setCameraClip(oClip1, oClip2)
            gElement = nil
        end
    end
)

function getNearbyPlayers(range)
    if not range then 
        range = "medium"
    end 

    local colshape
    if range == "minimum" or range == "low" then
        colshape = colshapeMinimum
    elseif range == "medium" then
        colshape = colshapeMedium
    elseif range == "high" or range == "big" then 
        colshape = colshapeMaximum
    else 
        return 
    end 

    local players = getElementsWithinColShape(colshape, "player") 

    for k,v in pairs(players) do 
        if v == localPlayer then 
            table.remove(players, k)
            break 
        end 
    end 

    return players
end 

function getPlayerCol(range)
    local colshape
    if range == "minimum" or range == "low" then
        colshape = colshapeMinimum
    elseif range == "medium" then
        colshape = colshapeMedium
    elseif range == "high" or range == "big" then 
        colshape = colshapeMaximum
    else 
        return 
    end 

    return colshape
end 