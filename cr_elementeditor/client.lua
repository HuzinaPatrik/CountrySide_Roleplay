local screenX, screenY = guiGetScreenSize()
local editorTable = nil

local editorMenu = {
	{"move", "Mozgatás"},
	{"rotate", "Forgatás"},
--	{"scale", "Méret"},
	{"reset", "Reset"},
	{"save", "Mentés"},
	{"delete", "Törlés"},
}

_isElementAttached = isElementAttached
function isElementAttached(e)
    if _isElementAttached(e) then
        return true, "original"
    elseif exports['cr_bone_attach']:isElementAttachedToBone(e) then
        return true, "bone_attach"
    else
        return false
    end
end

_getElementAttachedOffsets = getElementAttachedOffsets
function getElementAttachedOffsets(e, typ)
    local x,y,z,rx,ry,rz
    if typ == "bone_attach" then
        _, _, x, y, z, rx, ry, rz = exports['cr_bone_attach']:getElementBoneAttachmentDetails(e)
    elseif typ == "original" then
        x, y, z, rx, ry, rz = _getElementAttachedOffsets(e)
    end 
    
    return x,y,z, rx, ry, rz
end

_getElementAttachedTo = getElementAttachedTo
function getElementAttachedTo(e, typ)
    local val
    
    if typ == "bone_attach" then
        val = exports['cr_bone_attach']:getElementBoneAttachmentDetails(e)
    elseif typ == "original" then
        val = _getElementAttachedTo(e)
    end
    
    return val
end

_setElementAttachedOffsets = setElementAttachedOffsets
function setElementAttachedOffsets(e, typ, x, y, z, rx, ry, rz)
    if typ == "bone_attach" then
        exports['cr_bone_attach']:setElementBonePositionOffset(e, x, y, z)
        exports['cr_bone_attach']:setElementBoneRotationOffset(e, rx, ry, rz)
    elseif typ == "original" then
        setElementAttachedOffsets(e, x, y, z, rx, ry, rz)
    end
    
    return true
end

local iconSize = 16
local iconHalfSize = iconSize / 2

local axisLineThickness = 1.5

local editorColors = {
	axisX = {44, 44, 44},
	axisY = {44, 44, 44},
	axisZ = {44, 44, 44},
	
	activeMode = {22, 22, 22},
	inactiveMode = {22, 22, 22, 200}
}

--[[local editedObject
bindKey("F4", "down", function()
	if not isElement(editedObject) then
		local x, y, z = getElementPosition(localPlayer)
		editedObject = createObject(1663, x, y, z)
			
		setElementCollisionsEnabled(editedObject, false)
		toggleEditor(editedObject, "saveObject")
	end
end)


addEvent("saveObject", true)
addEventHandler("saveObject", root, function(obj)
	if obj == editedObject then
		destroyElement(editedObject)
		outputChatBox("save")
	end
end)--]]

addEventHandler("onClientRender", getRootElement(),
	function ()
		if not editorTable then
			return
		end
		
		local absX, absY = 0, 0
			
		if isCursorShowing() then
			if not isMTAWindowActive() then
				local relX, relY = getCursorPosition()
				
				absX, absY = relX * screenX, relY * screenY
			end
		end
		
		local elementX, elementY, elementZ = getElementPosition(editorTable["element"])
		
		local startX, startY = getScreenFromWorldPosition(elementX, elementY, elementZ, 128)
		
		local xX, xY, xZ = getPositionFromElementOffset(editorTable["element"], editorTable["elementRadius"], 0, 0)
		local yX, yY, yZ = getPositionFromElementOffset(editorTable["element"], 0, editorTable["elementRadius"], 0)
		local zX, zY, zZ = getPositionFromElementOffset(editorTable["element"], 0, 0, editorTable["elementRadius"])
		
		endXX, endXY = getScreenFromWorldPosition(xX, xY, xZ, 128)
		endYX, endYY = getScreenFromWorldPosition(yX, yY, yZ, 128)
		endZX, endZY = getScreenFromWorldPosition(zX, zY, zZ, 128)
		
		if not endXX or not endYX or not endZX or not endXY or not endYY or not endZY then
			return
		end
		
		dxDrawLine(startX, startY, endXX, endXY, tocolor(editorColors["axisX"][1], editorColors["axisX"][2], editorColors["axisX"][3], 255), axisLineThickness, false)
		dxDrawLine(startX, startY, endYX, endYY, tocolor(editorColors["axisY"][1], editorColors["axisY"][2], editorColors["axisY"][3], 255), axisLineThickness, false)
		dxDrawLine(startX, startY, endZX, endZY, tocolor(editorColors["axisZ"][1], editorColors["axisZ"][2], editorColors["axisZ"][3], 255), axisLineThickness, false)
		
		dxDrawRectangle(endXX - iconHalfSize, endXY - iconHalfSize, iconSize, iconSize, tocolor(editorColors["axisX"][1], editorColors["axisX"][2], editorColors["axisX"][3], 255))
		dxDrawRectangle(endYX - iconHalfSize, endYY - iconHalfSize, iconSize, iconSize, tocolor(editorColors["axisY"][1], editorColors["axisY"][2], editorColors["axisY"][3], 255))
		dxDrawRectangle(endZX - iconHalfSize, endZY - iconHalfSize, iconSize, iconSize, tocolor(editorColors["axisZ"][1], editorColors["axisZ"][2], editorColors["axisZ"][3], 255))
		
		dxDrawImage(endXX - iconHalfSize, endXY - iconHalfSize, iconSize, iconSize, "files/" .. editorTable["currentMode"] .. ".png")
		dxDrawImage(endYX - iconHalfSize, endYY - iconHalfSize, iconSize, iconSize, "files/" .. editorTable["currentMode"] .. ".png")
		dxDrawImage(endZX - iconHalfSize, endZY - iconHalfSize, iconSize, iconSize, "files/" .. editorTable["currentMode"] .. ".png")
		
		if editorTable["hoveredMenuIcon"] then
			editorTable["hoveredMenuIcon"] = false
		end
		
		if not editorTable["activeAxis"] then
			for i = 1, #editorMenu do
				local currentColor = editorColors["inactiveMode"]
				
				if editorMenu[i][1] == "save" then
					if editorTable["currentMode"] == editorMenu[i][1] then
						currentColor = {22, 22, 22}
					else
						currentColor = {22, 22, 22, 200}
					end
				elseif editorMenu[i][1] == "reset" then
					if editorTable["currentMode"] == editorMenu[i][1] then
						currentColor = {22, 22, 22}
					else
						currentColor = {22, 22, 22, 200}
					end
				elseif editorMenu[i][1] == "delete" then
					currentColor = {22, 22, 22, 200}
				elseif editorTable["currentMode"] == editorMenu[i][1] then
					currentColor = editorColors["activeMode"]
				end
				
				local iconX = ((startX - iconHalfSize) + ((i - 1) * (iconSize + 5))) + 32
				local iconY = (startY - iconHalfSize) + 32
				
				dxDrawRectangle(iconX, iconY, iconSize, iconSize, tocolor(currentColor[1], currentColor[2], currentColor[3], currentColor[4] or 255))
				dxDrawImage(iconX, iconY, iconSize, iconSize, "files/" .. editorMenu[i][1] .. ".png")
				
				if absX >= iconX and absX <= iconX + iconSize and absY >= iconY and absY <= iconY + iconSize then
					editorTable["hoveredMenuIcon"] = i
				end
			end
		end
		
		if editorTable["hoveredMenuIcon"] then
            exports['cr_dx']:drawTooltip(2, "#F2F2F2" .. editorMenu[editorTable["hoveredMenuIcon"]][2])
			if getKeyState("mouse1") then
				local hoveredMenuIcon = editorMenu[editorTable["hoveredMenuIcon"]][1]
			
				if editorTable["currentMode"] ~= hoveredMenuIcon then
					if hoveredMenuIcon == "reset" then
						resetEditorElementChanges()
					elseif hoveredMenuIcon == "save" then
						saveEditorElementChanges()
					elseif hoveredMenuIcon == "delete" then
						quitEditor()
					else
						editorTable["currentMode"] = hoveredMenuIcon
					end
				end
			end
		end
		
		if editorTable and editorTable["hoveredMode"] then
			editorTable["hoveredMode"] = false
		end
		
		if absX >= endXX - iconHalfSize and absX <= endXX - iconHalfSize + iconSize and absY >= endXY - iconHalfSize and absY <= endXY - iconHalfSize + iconSize then
			editorTable["hoveredMode"] = "X"
		elseif absX >= endYX - iconHalfSize and absX <= endYX - iconHalfSize + iconSize and absY >= endYY - iconHalfSize and absY <= endYY - iconHalfSize + iconSize then
			editorTable["hoveredMode"] = "Y"
		elseif absX >= endZX - iconHalfSize and absX <= endZX - iconHalfSize + iconSize and absY >= endZY - iconHalfSize and absY <= endZY - iconHalfSize + iconSize then
			editorTable["hoveredMode"] = "Z"
		end
		
		-- OBJECT MOVE BY AXLES/CURSOR
		if editorTable and editorTable["activeAxis"] then
			if isCursorShowing() and getKeyState("mouse1") then
				local relX, relY = getCursorPosition()

				local absX, absY = (relX - 0.5), (relY - 0.5)
				local absolute = absX + absY
				local absoluteMethod = "x"
				if math.abs(absY) > math.abs(absX) then 
					absoluteMethod = "y"
				end 

				local cameraRotation = getCameraRotation()

				local elementX, elementY, elementZ = 0, 0, 0
				local elementRX, elementRY, elementRZ = 0, 0, 0
				local elementSX, elementSY, elementSZ = 0, 0, 0
				
                local attached, typ = isElementAttached(editorTable["element"])
				if attached then
					elementX, elementY, elementZ, elementRX, elementRY, elementRZ = getElementAttachedOffsets(editorTable["element"], typ)
					
					local attachedElementRX, attachedElementRY, attachedElementRZ = getElementRotation(getElementAttachedTo(editorTable["element"], typ))
					
					cameraRotation = cameraRotation + attachedElementRZ
				else
					elementX, elementY, elementZ = getElementPosition(editorTable["element"])
					elementRX, elementRY, elementRZ = getElementRotation(editorTable["element"])
				end
				
				if getElementType(editorTable["element"]) == "object" then
					elementSX, elementSY, elementSZ = getObjectScale(editorTable["element"])
				end
				
				if editorTable["currentMode"] == "move" then
					if editorTable["activeAxis"] == "X" then
						if absoluteMethod == "y" then 
							elementX = elementX - ((absolute) * 15)
						else 
							elementX = elementX + ((absolute) * 15)
						end
					elseif editorTable["activeAxis"] == "Y" then
						--elementY = getInFrontOf(false, elementY, -cameraRotation, -((relY - 0.5) * 5))
						if absoluteMethod == "y" then 
							elementY = elementY - ((absolute) * 15)
						else 
							elementY = elementY + ((absolute) * 15)
						end
					elseif editorTable["activeAxis"] == "Z" then
						if absoluteMethod == "y" then 
							elementZ = elementZ - ((absolute) * 15)
						else 
							elementZ = elementZ + ((absolute) * 15)
						end
					end
				elseif editorTable["currentMode"] == "rotate" then
					if editorTable["activeAxis"] == "X" then
						if absoluteMethod == "y" then 
							elementRX = elementRX - ((absolute) * 100)
						else 
							elementRX = elementRX + ((absolute) * 100)
						end
					elseif editorTable["activeAxis"] == "Y" then
						if absoluteMethod == "y" then 
							elementRY = elementRY - ((absolute) * 100)
						else 
							elementRY = elementRY + ((absolute) * 100)
						end
					elseif editorTable["activeAxis"] == "Z" then
						if absoluteMethod == "y" then 
							elementRZ = elementRZ - ((absolute) * 100)
						else 
							elementRZ = elementRZ + ((absolute) * 100)
						end
					end
				elseif editorTable["currentMode"] == "scale" then
					if editorTable["activeAxis"] == "X" then
						if absoluteMethod == "y" then 
							elementSX = elementSX - ((absolute) * 15)
						else 
							elementSX = elementSX + ((absolute) * 15)
						end
					elseif editorTable["activeAxis"] == "Y" then
						if absoluteMethod == "y" then 
							elementSY = elementSY - ((absolute) * 15)
						else 
							elementSY = elementSY + ((absolute) * 15)
						end
					elseif editorTable["activeAxis"] == "Z" then
						if absoluteMethod == "y" then 
							elementSZ = elementSZ - ((absolute) * 15)
						else 
							elementSZ = elementSZ + ((absolute) * 15)
						end
					end
				end
				
				if attached then
					setElementAttachedOffsets(editorTable["element"], typ, elementX, elementY, elementZ, elementRX, elementRY, elementRZ)
				else
					setElementPosition(editorTable["element"], elementX, elementY, elementZ)
					setElementRotation(editorTable["element"], elementRX, elementRY, elementRZ)
				end
				
				if getElementType(editorTable["element"]) == "object" then
					elementSX = math.max(0.5, math.min(2.0, elementSX))
					elementSY = math.max(0.5, math.min(2.0, elementSY))
					elementSZ = math.max(0.5, math.min(2.0, elementSZ))
					
					setObjectScale(editorTable["element"], elementSX, elementSY, elementSZ)
				end
				
				setCursorPosition(screenX / 2, screenY / 2)
				setCursorAlpha(0)
			else
				if editorTable["activeAxis"] then
					editorTable["activeAxis"] = false
					setCursorAlpha(255)
				end
			end
		end
	end, true, "low-5"
)

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absX, absY)
		if not editorTable then
			return
		end
		
		if button == "left" then
			if state == "down" then
				if editorTable["hoveredMode"] then
					setCursorPosition(screenX / 2, screenY / 2)
					setCursorAlpha(0)
					
					editorTable["activeAxis"] = editorTable["hoveredMode"]
				end
			elseif state == "up" then
				local oldActiveAxis = editorTable["activeAxis"]
				
				if oldActiveAxis then
					editorTable["activeAxis"] = false
					
					if oldActiveAxis == "X" then
						setCursorPosition(endXX, endXY)
					elseif oldActiveAxis == "Y" then
						setCursorPosition(endYX, endYY)
					elseif oldActiveAxis == "Z" then
						setCursorPosition(endZX, endZY)
					end
					
					setCursorAlpha(255)
				end
			end
		end
	end
)

function toggleEditor(element, saveFunction, removeFunction, ignoreCursor, ...)
	if element then
		local x, y, z = getElementPosition(element)
		local rx, ry, rz = getElementRotation(element)
		local scale = getObjectScale(element)
		local radius = getElementRadius(element) * 1.25

        local attachmentParent = element:getData("attachmentParent")

        if attachmentParent then 
            radius = 0.5
        end

		if radius >= 2 then
			radius = 2
		end
        
        if element:getData("mask") or attachmentParent then
            editorMenu = {
                {"move", "Mozgatás"},
                {"rotate", "Forgatás"},
                {"scale", "Méretezés"},
                {"reset", "Visszaállítás"},
                {"save", "Mentés"},
                {"delete", "Törlés"},
            }
        else
            editorMenu = {
                {"move", "Mozgatás"},
                {"rotate", "Forgatás"},
                {"reset", "Visszaállítás"},
                {"save", "Mentés"},
                {"delete", "Törlés"},
            }
        end
        
		editorTable = {
			element = element,
			elementRadius = radius,
			
			defaultX = x,
			defaultY = y,
			defaultZ = z,
			defaultRX = rx,
			defaultRY = ry,
			defaultRZ = rz,
			defaultScale = scale,
			
			saveFunction = saveFunction,
			removeFunction = removeFunction,
			others = {...},

			currentMode = "move",
			hoveredMode = false,
			hoveredMenuIcon = false,
			activeAxis = false,
		}
        
        if not ignoreCursor then
            exports['cr_core']:intCursor(true, false)
            exports['cr_head']:initHeadMove(true)
        end
	else
        if not ignoreCursor then
            exports['cr_core']:intCursor(false, false)
            exports['cr_head']:initHeadMove(false)
        end
		editorTable = nil
		setCursorAlpha(255)
	end
end

function resetEditorElementChanges(quit)
	if not editorTable then
		return
	end
	
	if not editorTable["element"] or not isElement(editorTable["element"]) then
		return
	end
	
	setElementPosition(editorTable["element"], editorTable.defaultX, editorTable.defaultY, editorTable.defaultZ)
    local attached, typ = isElementAttached(editorTable["element"])
    if attached then
        setElementAttachedOffsets(editorTable["element"], typ, 0,0,0,0,0,0)
    end
	setElementRotation(editorTable["element"], editorTable.defaultRX, editorTable.defaultRY, editorTable.defaultRZ)
	setObjectScale(editorTable["element"], editorTable.defaultScale)
	
	if quit then
		toggleEditor(false)
	end
end

function saveEditorElementChanges()
	if not editorTable then
		return
	end
	
	if not editorTable["element"] or not isElement(editorTable["element"]) then
		return
	end
	
	if editorTable["saveFunction"] then
        local attached, typ = isElementAttached(editorTable["element"])
		
		if tostring(editorTable["saveFunction"]) == "onSaveFurniturePositionEditor" then
			if getDistanceBetweenPoints3D(editorTable["element"].position, Vector3(editorTable.defaultX, editorTable.defaultY, editorTable.defaultZ)) > 5 then
				setElementPosition(editorTable["element"], editorTable.defaultX, editorTable.defaultY, editorTable.defaultZ)
				if attached then
					setElementAttachedOffsets(editorTable["element"], typ, 0,0,0,0,0,0)
				end
				setElementRotation(editorTable["element"], editorTable.defaultRX, editorTable.defaultRY, editorTable.defaultRZ)
				setObjectScale(editorTable["element"], editorTable.defaultScale)
			end
		elseif tostring(editorTable["saveFunction"]) == "placedoSaveTrigger" then
			if getDistanceBetweenPoints3D(editorTable["element"].position, Vector3(editorTable.defaultX, editorTable.defaultY, editorTable.defaultZ)) > 10 then
				setElementPosition(editorTable["element"], editorTable.defaultX, editorTable.defaultY, editorTable.defaultZ)
				if attached then
					setElementAttachedOffsets(editorTable["element"], typ, 0,0,0,0,0,0)
				end
				setElementRotation(editorTable["element"], editorTable.defaultRX, editorTable.defaultRY, editorTable.defaultRZ)
				setObjectScale(editorTable["element"], editorTable.defaultScale)
			end
		elseif tostring(editorTable["saveFunction"]) == "roadblockSaveTrigger" or tostring(editorTable["saveFunction"]) == "roadblockEditSaveTrigger" then 
			if getDistanceBetweenPoints3D(editorTable["element"].position, Vector3(editorTable.defaultX, editorTable.defaultY, editorTable.defaultZ)) > 5 then
				setElementPosition(editorTable["element"], editorTable.defaultX, editorTable.defaultY, editorTable.defaultZ)
				if attached then
					setElementAttachedOffsets(editorTable["element"], typ, 0,0,0,0,0,0)
				end
				setElementRotation(editorTable["element"], editorTable.defaultRX, editorTable.defaultRY, editorTable.defaultRZ)
				setObjectScale(editorTable["element"], editorTable.defaultScale)
			end
		elseif tostring(editorTable["saveFunction"]) == 'attachmentSaveTrigger' then 
			if getDistanceBetweenPoints3D(editorTable["element"].position, Vector3(editorTable.defaultX, editorTable.defaultY, editorTable.defaultZ)) > 2.5 then
				setElementPosition(editorTable["element"], editorTable.defaultX, editorTable.defaultY, editorTable.defaultZ)
				if attached then
					setElementAttachedOffsets(editorTable["element"], typ, 0,0,0,0,0,0)
				end
				setElementRotation(editorTable["element"], editorTable.defaultRX, editorTable.defaultRY, editorTable.defaultRZ)
				setObjectScale(editorTable["element"], editorTable.defaultScale)
			end
        elseif tostring(editorTable["saveFunction"]) == 'cameraSaveTrigger' then
            if getDistanceBetweenPoints3D(editorTable["element"].position, Vector3(editorTable.defaultX, editorTable.defaultY, editorTable.defaultZ)) > 2.5 then
				setElementPosition(editorTable["element"], editorTable.defaultX, editorTable.defaultY, editorTable.defaultZ)
				if attached then
					setElementAttachedOffsets(editorTable["element"], typ, 0,0,0,0,0,0)
				end
				setElementRotation(editorTable["element"], editorTable.defaultRX, editorTable.defaultRY, editorTable.defaultRZ)
				setObjectScale(editorTable["element"], editorTable.defaultScale)
			end
		elseif tostring(editorTable["saveFunction"]) ~= "onSaveTrafficPositionEditor" then 
			if getDistanceBetweenPoints3D(editorTable["element"].position, Vector3(editorTable.defaultX, editorTable.defaultY, editorTable.defaultZ)) > 1 then
				setElementPosition(editorTable["element"], editorTable.defaultX, editorTable.defaultY, editorTable.defaultZ)
				if attached then
					setElementAttachedOffsets(editorTable["element"], typ, 0,0,0,0,0,0)
				end
				setElementRotation(editorTable["element"], editorTable.defaultRX, editorTable.defaultRY, editorTable.defaultRZ)
				setObjectScale(editorTable["element"], editorTable.defaultScale)
			end
		end 
        
		if attached then
			local x, y, z, rx, ry, rz = getElementAttachedOffsets(editorTable["element"], typ)
			
            --outputChatBox(editorTable["saveFunction"])
			triggerEvent(editorTable["saveFunction"], localPlayer, editorTable["element"], x, y, z, rx, ry, rz, getObjectScale(editorTable["element"]), unpack(editorTable["others"]))
		else
			local x, y, z = getElementPosition(editorTable["element"])
			local rx, ry, rz = getElementRotation(editorTable["element"])
            
--            outputChatBox(editorTable["saveFunction"])
			triggerEvent(editorTable["saveFunction"], localPlayer, editorTable["element"], x, y, z, rx, ry, rz, getObjectScale(editorTable["element"]), unpack(editorTable["others"]))
			--outputChatBox( "triggered save event->"..editorTable["saveFunction"] ) 
		end
	end
	
	toggleEditor(false)
end

function quitEditor(ignoreRemoveFunc)
	if not editorTable then
		return
	end
	
	if not editorTable["element"] or not isElement(editorTable["element"]) then
		return
	end
    
    if not ignoreRemoveFunc then
        resetEditorElementChanges()
    end
	
    if not ignoreRemoveFunc then
        if editorTable["removeFunction"] then
            triggerEvent(editorTable["removeFunction"], localPlayer, editorTable["element"])
        end
    end
	
	toggleEditor(false)
end

function getPositionFromElementOffset(element, offsetX, offsetY, offsetZ)
	local elementMatrix = getElementMatrix(element, false)
	
    local elementX = offsetX * elementMatrix[1][1] + offsetY * elementMatrix[2][1] + offsetZ * elementMatrix[3][1] + elementMatrix[4][1]
    local elementY = offsetX * elementMatrix[1][2] + offsetY * elementMatrix[2][2] + offsetZ * elementMatrix[3][2] + elementMatrix[4][2]
    local elementZ = offsetX * elementMatrix[1][3] + offsetY * elementMatrix[2][3] + offsetZ * elementMatrix[3][3] + elementMatrix[4][3]
	
    return elementX, elementY, elementZ
end

function getInFrontOf(x, y, angle, distance)
	distance = distance or 1
	
	if x and not y then
		return x + distance * math.sin(math.rad(-angle))
	elseif not x and y then
		return y + distance * math.cos(math.rad(-angle))
	elseif x and y then
		return x + distance * math.sin(math.rad(-angle)), y + distance * math.cos(math.rad(-angle))
	end
end

function getCameraRotation()
	local cx, cy, _, tx, ty = getCameraMatrix()
	
	return math.deg(math.atan2(tx - cx, ty - cy))
end