local sx, sy = guiGetScreenSize();
local scrolling, minLines, maxLines, _maxLines
local shops = {};
local basket = {
	items = {},
	weight = 0,
	total = 0,
};
local shelfDetails = {};
local streamedInShelves = {};
local playerCol = false;
local playerBasket = false;
local payDetails = {
	payMenu = false,
	clickedNPC = false,
}

function isHoveredOn3DPanel(startX,startY,startZ,endX,endY,endZ)
	if isCursorShowing() then
		local cX,cY = getCursorPosition()
		if cX and cY then
			cX,cY = cX*sx,cY*sy
			local eX,sY,_ = getScreenFromWorldPosition(startX,startY,startZ,1000,false)
			local sX,eY,_ = getScreenFromWorldPosition(endX,endY,endZ,1000,false)
			if sX and sY and eX and eY then
				if cX > sX and cX < eX and cY > sY and cY < eY then
					return true
				elseif cX < sX and cX > eX and cY > sY and cY < eY then
					return true
				else
					return false
				end
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	local txd = engineLoadTXD("files/basket.txd")
	engineImportTXD(txd, 324)
	local dff = engineLoadDFF("files/basket.dff")
	engineReplaceModel(dff, 324)
end)

function dxDrawMaterialText(text, startPos, endPos, w, h, size, color, font, direction)
	local target = dxCreateRenderTarget(sx, sy, true)
	dxSetRenderTarget(target,true)
	dxDrawText(text,0,0,w,h,color,size,font,"left","center")
	dxSetRenderTarget()
	dxDrawMaterialLine3D(startPos, endPos,target,size*14, tocolor(255, 255, 255), direction)
	target:destroy()
end

addEventHandler("onClientResourceStart", resourceRoot, function() 
	triggerServerEvent("requestShops", localPlayer, localPlayer)
	outputDebugString("Shop table requested.")
end)

addEvent("receiveShops", true)
addEventHandler("receiveShops", localPlayer, function(t) 
	shops = t
	outputDebugString("Shop table received.")
end)

local editor = {
	p = {sx/2-160, sy/2+200, 320, 110},
	enabled = false,
	mode = 0,
	selectedObject = false,
	tempObject = false,
	updateTime = 0,
	shop = 1,
	modes = {
		[0] = "select.png",
		[1] = "add.png",
		[2] = "remove.png",
	},
};
function renderEditor()
	local font = exports['cr_fonts']:getFont("Roboto", 11)
	local x, y, w, h = unpack(editor.p)
	dxDrawRectangle(x, y, w, h, tocolor(33, 33, 33, 255))
	for i = 0, 2 do
		dxDrawRectangle(x+5+(i*105), y+5, 100, h-10, tocolor(44, 44, 44, 255))
		local color = editor.mode == i and tocolor(61, 122, 188, 255) or tocolor(255, 255, 255, 255)
		dxDrawImage(x+5+(i*105)+25, y+5+25, 100-50, h-10-50, "files/"..editor.modes[i], 0, 0, 0, isCursorHover(x+5+(i*105), y+5, 100, h-10) and tocolor(61, 122, 188, 255) or color)
	end
	for i, v in pairs(getElementsByType("object", resourceRoot, true)) do
		if(v.model == global.object[editor.globalId] and editor.tempObject ~= v) then
			local pos = v.position
			local px, py = getScreenFromWorldPosition(pos.x, pos.y, pos.z+1.25)
			local dist = getDistanceBetweenPoints3D(pos, localPlayer.position)
			if(px and py and dist <= 5) then
				dxDrawText("Polc ID: "..v:getData("shop >> objectid"), px, py, nil, nil, tocolor(255, 255, 255, 255), 1, "default-bold", nil, nil, false, false, true, true)
				local leftMx, rightMx = Matrix(v.position, Vector3(v.rotation.x, v.rotation.y, v.rotation.z+90)), Matrix(v.position, Vector3(v.rotation.x, v.rotation.y, v.rotation.z-90))
				local left = leftMx:transformPosition(Vector3(0, 1, 2))
				local right = rightMx:transformPosition(Vector3(0, 1, 2))
				local leftX, leftY = getScreenFromWorldPosition(left.x, left.y, left.z)
				local rightX, rightY = getScreenFromWorldPosition(right.x, right.y, right.z)
				if(leftX and leftY) then
					dxDrawText("Side: left", leftX, leftY, nil, nil, tocolor(255, 255, 255, 255), 1, "default-bold", nil, nil, false, false, true, true)
				end
				if(rightX and rightY) then
					dxDrawText("Side: right", rightX, rightY, nil, nil, tocolor(255, 255, 255, 255), 1, "default-bold", nil, nil, false, false, true, true)
				end
			end
		end
	end
	if(editor.updateTime+250 <= getTickCount()) then
		editor.updateTime = getTickCount()
		local col = getElementColShape(localPlayer)
		if(not isElement(col) or not col:getData("shop >> radius")) then
			editor.enabled = false
			destroyRender("renderEditor")
			removeEventHandler("onClientKey", root, onEditorKey)
			removeEventHandler("onClientClick", root, onEditorKey)
			if(isElement(editor.tempObject)) then
				editor.tempObject:destroy()
			end
			exports["cr_infobox"]:addBox("error", "Nem tartózkodsz bolti területen belül.")
		end
	end
end

function onEditorKey(b, s, _, _, _, _, _, e)
	local x, y, w, h = unpack(editor.p)
	if(b == "left") then
		if(s == "down") then
			local hover = false
			for i = 0, 2 do
				if(isCursorHover(x+5+(i*105), y+5, 100, h-10)) then
					if(isElement(editor.tempObject)) then
						editor.tempObject:destroy()
					end
					editor.mode = i
					hover = true
					break
				end
			end
			if(not isElement(editor.tempObject)) then
				if(not hover) then
					if(editor.mode == 2) then
						if(isElement(e) and tonumber(e:getData("shop >> id")) == editor.shop) then
							triggerServerEvent("deleteShopElement", localPlayer, localPlayer, e)
						end
					end
				end
			end
			local cx, cy = getCursorPosition()
			cx, cy = cx*sx, cy*sy
			local x, y, z = getWorldFromScreenPosition(cx, cy, 10)
			local _, x, y, z = processLineOfSight(localPlayer.position.x, localPlayer.position.y, localPlayer.position.z+1.2, x, y, z, true, false, false, true, false, false, false, false, nil, false, false)
			if(editor.mode == 0) then
				if(isElement(e) and e:getData("shop >> object") and tonumber(e:getData("shop >> id")) == editor.shop or isElement(editor.tempObject) and editor.tempObject:getData("shop >> tempid")) then
					if(not isElement(editor.tempObject)) then
						editor.tempObject = createObject(e.model, Vector3(x, y, z))
					else
						editor.tempObject.position = Vector3(x, y, z)
					end
					if(isElement(e) and e:getData("shop >> object")) then
						editor.tempObject:setData("shop >> tempid", tonumber(e:getData("shop >> objectid")))
					end
					editor.tempObject.collisions = false
					editor.tempObject.alpha = 150
				end
			elseif(editor.mode == 1) then
				if(not isElement(editor.tempObject)) then
					editor.tempObject = createObject(global.object[editor.globalId], Vector3(x, y, z))
				else
					if(not editor.tempObject.model == global.object[editor.globalId]) then
						editor.tempObject.model = global.object[editor.globalId]
					end
					editor.tempObject.position = Vector3(x, y, z)
					
				end
				editor.tempObject.collisions = false
				editor.tempObject.alpha = 150
			end
		end
	elseif(b == "enter") then
		if(s) then
			if(editor.mode == 0) then
				if(isElement(editor.tempObject)) then
					triggerServerEvent("moveObject", localPlayer, localPlayer, editor.shop, editor.tempObject:getData("shop >> tempid"), {editor.tempObject.position.x, editor.tempObject.position.y, editor.tempObject.position.z}, {editor.tempObject.rotation.x, editor.tempObject.rotation.y, editor.tempObject.rotation.z})
					if(isElement(editor.tempObject)) then
						editor.tempObject:destroy()
					end
				end
			elseif(editor.mode == 1) then
				triggerServerEvent("addObject", localPlayer, localPlayer, editor.shop, {editor.tempObject.position.x, editor.tempObject.position.y, editor.tempObject.position.z}, {editor.tempObject.rotation.x, editor.tempObject.rotation.y, editor.tempObject.rotation.z}, editor.globalId)
				if(isElement(editor.tempObject)) then
					editor.tempObject:destroy()
				end
			else
				
			end
		end
	elseif(b == "mouse_wheel_up") then
		if(s) then
			if(isElement(editor.tempObject)) then
				editor.tempObject.rotation = Vector3(editor.tempObject.rotation.x, editor.tempObject.rotation.y, editor.tempObject.rotation.z+5)
			end
		end
	elseif(b == "mouse_wheel_down") then
		if(s) then
			if(isElement(editor.tempObject)) then
				editor.tempObject.rotation =  Vector3(editor.tempObject.rotation.x, editor.tempObject.rotation.y, editor.tempObject.rotation.z-5)
			end
		end
	end
end

addCommandHandler("shopeditor", function(cmd, globalid) 
	if(exports['cr_permission']:hasPermission(localPlayer, cmd)) then
		local col = getElementColShape(localPlayer)
		if(isElement(col) and col:getData("shop >> radius")) then
			if(not globalid) then
				editor.globalId = 1
			else
				if(global.object[tonumber(globalid)]) then
					editor.globalId = tonumber(globalid)
				else
					editor.globalId = 1
				end
			end
			editor.updateTime = getTickCount()
			editor.enabled = not editor.enabled
			editor.shop = col:getData("shop >> id")
			if(editor.enabled) then
				--addEventHandler("onClientRender", root, renderEditor, true, "low-5")
				createRender("renderEditor", renderEditor)
				addEventHandler("onClientKey", root, onEditorKey)
				addEventHandler("onClientClick", root, onEditorKey)
			else
				--removeEventHandler("onClientRender", root, renderEditor)
				destroyRender("renderEditor")
				removeEventHandler("onClientKey", root, onEditorKey)
				removeEventHandler("onClientClick", root, onEditorKey)
				if(isElement(editor.tempObject)) then
					editor.tempObject:destroy()
				end
			end
		else
			exports["cr_infobox"]:addBox("error", "Nem tartózkodsz bolti területen belül.")
		end
	end
end)

addEventHandler("onClientElementStreamedIn", root, function()
	local e = source
	if(e:getData("shop >> object")) then
		if(not streamedInShelves[e:getData("shop >> id")]) then
			streamedInShelves[e:getData("shop >> id")] = {}
		end
		streamedInShelves[e:getData("shop >> id")][e:getData("shop >> objectid")] = {shelf = e, items = e:getData("shop >> items")}
	end
end)

addEventHandler("onClientElementStreamedOut", root, function() 
	local e = source
	if(streamedInShelves[e:getData("shop >> id")]) then
		streamedInShelves[e:getData("shop >> id")][e:getData("shop >> objectid")] = false
	end
end)

local tx = dxCreateTexture("files/dot.png")
local tick = 0
local spam = 0

createRender("renderFunction", function()
	if(tick+500 <= getTickCount()) then
		tick = getTickCount()
		local col = getElementColShape(localPlayer)
		if(isElement(col) and col:getData("shop >> radius")) then
			local closest, lastdist = false, 999
			if(shops[col:getData("shop >> id")].objects) then
				if(shops[col:getData("shop >> id")].objects) then
					if(shops[col:getData("shop >> id")].objects) then
						for i, v in pairs(shops[col:getData("shop >> id")].objects) do
							local dist = getDistanceBetweenPoints3D(v.position, localPlayer.position)
							if(dist < lastdist) then
								lastdist = dist
								closest = v
							end
						end
					end
				end
			end
			if(isElement(closest)) then
				local dist = getDistanceBetweenPoints3D(closest.position, localPlayer.position)
				if(dist < 5) then	
					local x, y, z, rx, ry, rz, rx2, ry2, rz2 = unpack(global.objectMatrices[closest.model]["values"])
					local matrixLeft, matrixRight = Matrix(closest.position, Vector3(closest.rotation.x+rx, closest.rotation.y+ry, closest.rotation.z+rz)), Matrix(closest.position, Vector3(closest.rotation.x+rx2, closest.rotation.y+ry2, closest.rotation.z+rz2))
					if(not shelfDetails or shelfDetails.id ~= closest:getData("shop >> objectid")) then
						shelfDetails = {
							id = closest:getData("shop >> objectid"), 
							pos = closest.position, 
							rot = closest.rotation, 
							draw = {
								["left"] = {slots = {},},
								["right"] = {slots = {},},
							}
						}
						for i, v in pairs(shelfDetails.draw) do
							for k = 1, 22 do
								local mx = (i == "left" and matrixLeft or matrixRight)
								local index = (k > 11 and k-11 or k)-1
								local ascending = (global.objectMatrices[closest.model]["ascending"]*index)
								local minusCol = (k > 11 and global.objectMatrices[closest.model]["ascending"] or 0)
								table.insert(shelfDetails.draw[i].slots, {s = mx:transformPosition(Vector3(x-ascending, y, z-minusCol)), f = mx:transformPosition(Vector3(x-ascending, y+1, z-minusCol))})
							end
						end
					end
					local leftPoint = matrixLeft:transformPosition(Vector3(0, 1, 1))
					local rightPoint = matrixRight:transformPosition(Vector3(0, 1, 1))
					local side = ""
					if(getDistanceBetweenPoints3D(localPlayer.position, leftPoint) < getDistanceBetweenPoints3D(localPlayer.position, rightPoint)) then
						side = "left"
					else
						side = "right"
					end
					shelfDetails.side = side
					shelfDetails.items = closest:getData("shop >> items")
				end
			end
		end
	end
	if(shelfDetails.id ~= nil and not payDetails.payMenu) then
		local dist = getDistanceBetweenPoints3D(shelfDetails.pos, localPlayer.position)
		local distance_alpha = ((dist-5)/2)*-170
		if(distance_alpha > 200) then
			distance_alpha = 200
		elseif(distance_alpha < 0) then
			distance_alpha = 0
		end
		local dps, dpe, tw = shelfDetails.draw.dps, shelfDetails.draw.dpe, shelfDetails.draw.toward
		local v = shelfDetails.draw[shelfDetails.side]
		shelfDetails.selectedItem = {"", 0}
		for index, value in pairs(v.slots) do
			if(shelfDetails.items and shelfDetails.items[shelfDetails.side] and shelfDetails.items[shelfDetails.side][index]) then
				if(isHoveredOn3DPanel(value.s.x, value.s.y+0.14, value.s.z+0.16, value.s.x, value.s.y-0.14, value.s.z-0.16)) then
					dxDrawMaterialLine3D(value.s.x, value.s.y, value.s.z+0.16, value.s.x, value.s.y, value.s.z-0.16, exports['cr_dx']:getTexture(":cr_inventory/assets/items/"..shelfDetails.items[shelfDetails.side][index]["item"]..".png"), 0.32, tocolor(255, 255, 255, distance_alpha*1), false, value.f.x, value.f.y, value.f.z)
					exports['cr_dx']:drawTooltip(2, "#FFD405"..exports["cr_inventory"]:getItemName(shelfDetails.items[shelfDetails.side][index]["item"]).."\n#f2f2f2Ára: #7cc576$ "..shelfDetails.items[shelfDetails.side][index]["price"].."\n#f2f2f2Súly: #FFD405"..exports["cr_inventory"]:getItemWeight(shelfDetails.items[shelfDetails.side][index]["item"]).." kg")
					
					shelfDetails.selectedItem = {shelfDetails.side, index, shelfDetails.items[shelfDetails.side][index], value.s}
				else
					dxDrawMaterialLine3D(value.s.x, value.s.y, value.s.z+0.16, value.s.x, value.s.y, value.s.z-0.16, exports['cr_dx']:getTexture(":cr_inventory/assets/items/"..shelfDetails.items[shelfDetails.side][index]["item"]..".png"), 0.32, tocolor(255, 255, 255, distance_alpha*0.75), false, value.f.x, value.f.y, value.f.z)
				end
			end
		end
		if(dist > 5) then
			shelfDetails = {}
		end
	elseif(payDetails.payMenu) then
		if (isElement(payDetails.clickedNPC) and getDistanceBetweenPoints3D(payDetails.clickedNPC.position, localPlayer.position) > 2.5) then
			payDetails.payRender = false
			payDetails.clickedNPC = false

			exports['cr_dx']:startFade("shop >> buy", 
				{
					["startTick"] = getTickCount(),
					["lastUpdateTick"] = getTickCount(),
					["time"] = 500,
					["animation"] = "InOutQuad",
					["from"] = 255,
					["to"] = 0,
					["alpha"] = 255,
					["progress"] = 0,
				}
			)
		end

		local nowTick = getTickCount()

    	local alpha, progress = exports['cr_dx']:getFade("shop >> buy")

		if not payDetails.payRender then 
			if progress >= 1 then 
				payDetails.payMenu = false
			end 
		end 

		local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 10)
		local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 10)
		local font3 = exports['cr_fonts']:getFont('Poppins-SemiBold', 12)
		
		local w, h = 240, 125 + (math.min(#basket.items, _maxLines) * (20 + 2)) + 2 + 2 + 4 + 90
		local x, y = sx/2 - w/2, sy/2 - h/2

		dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))

		dxDrawImage(x + 10, y + 5, 16, 18, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Pénztár', x + 10 + 18 + 5,y+5,x+w,y+5+18 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

		closeHover = nil 
		if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
			closeHover = true
			
			dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
		else 
			dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
		end 

		local startX, startY = x + 10, y + 35
		local _startX = startX

		local now = 1
		local line = 1

		basketHover = nil 
		for i = 1, 10 do 
			local w2, h2 = 40, 40

			dxDrawRectangle(startX, startY, w2, h2, tocolor(41, 41, 41, alpha * 0.9))
			
			if basket.items[i] then
				dxDrawImage(startX, startY, w2, h2, exports['cr_dx']:getTexture(":cr_inventory/assets/items/"..basket.items[i]["item"]..".png"), 0, 0, 0, tocolor(255, 255, 255, alpha))
				if exports['cr_core']:isInSlot(startX, startY, w2, h2) then 
					basketHover = i
					dxDrawImage(startX + w2/2 - (w2 * 0.8)/2, startY + h2/2 - (h2 * 0.8)/2, w2 * 0.8, h2 * 0.8, exports['cr_dx']:getTexture(":cr_shop/files/minus.png"), 0, 0, 0, tocolor(255, 255, 255, alpha))
				end 
			end 

			now = now + 1
			startX = startX + w2 + 5

			if now >= 6 then 
				now = 0
				line = line + 1
				startY = startY + h2 + 5
				startX = _startX
			end 
		end 

		local startX, startY = x + 10, y + 125
		local _startY = startY
		local w2, h2 = 220, 20

		canScroll = false
		if exports['cr_core']:isInSlot(startX, startY, w2, (math.min(#basket.items, _maxLines) * (20 + 2)) - 2) then 
			canScroll = true 
		end 

		for i = minLines, maxLines do 
			if basket.items[i] then 
				if exports['cr_core']:isInSlot(startX, startY, w2, h2) then 
					dxDrawRectangle(startX, startY, w2, h2, tocolor(242, 242, 242, alpha * 0.8))
					dxDrawText(exports["cr_inventory"]:getItemName(basket.items[i]["item"]), startX + 5, startY, startX + w2, startY + h2 + 4, tocolor(51, 51, 51, alpha), 1, font2, "left", "center")
					dxDrawText('$ '..basket.items[i]["price"], startX, startY, startX + w2 - 5, startY + h2 + 4, tocolor(51, 51, 51, alpha), 1, font2, "right", "center")
				else
					dxDrawRectangle(startX, startY, w2, h2, tocolor(51, 51, 51, alpha * 0.6))
					dxDrawText(exports["cr_inventory"]:getItemName(basket.items[i]["item"]), startX + 5, startY, startX + w2, startY + h2 + 4, tocolor(242, 242, 242, alpha), 1, font2, "left", "center")
					dxDrawText('$ '..basket.items[i]["price"], startX, startY, startX + w2 - 5, startY + h2 + 4, tocolor(97, 177, 90, alpha), 1, font2, "right", "center") 
				end 

				startY = startY + h2 + 2
			end 
		end 

		--scrollbar
		local percent = math.max(0, #basket.items)
			
		if percent >= 1 then
			local gW, gH = 3, (math.min(#basket.items, _maxLines) * (20 + 2)) - 2
			local gX, gY = startX + w2 + 10/2 - gW/2, _startY
			_sX, _sY, _sW, _sH = gX, gY, gW, gH
			
			if scrolling then
				if isCursorShowing() then
					if getKeyState("mouse1") then
						local cx, cy = exports['cr_core']:getCursorPosition()
						local cy = math.min(math.max(cy, _sY), _sY + _sH)
						local y = (cy - _sY) / (_sH)
						local num = percent * y
						minLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _maxLines) + 1)))
						maxLines = minLines + (_maxLines - 1)
					end
				else
					scrolling = false
				end
			end
			
			dxDrawRectangle(gX,gY,gW,gH, tocolor(242,242,242,alpha * 0.6))
			
			local multiplier = math.min(math.max((maxLines - (minLines - 1)) / percent, 0), 1)
			local multiplier2 = math.min(math.max((minLines - 1) / percent, 0), 1)
			local gY = gY + ((gH) * multiplier2)
			local gH = gH * multiplier
			local r,g,b = 255, 59, 59
			dxDrawRectangle(gX, gY, gW, gH, tocolor(r,g,b, alpha))
		end
		--

		if maxLines > #basket.items then 
			maxLines = math.max(_maxLines, #basket.items)
			minLines = maxLines - (_maxLines - 1)
		end

		startY = startY + 2
		dxDrawRectangle(startX + 5, startY, w2 - 10, 2, tocolor(152, 60, 59, alpha))

		startY = startY + 2 + 4

		if exports['cr_core']:isInSlot(startX, startY, w2, h2) then 
			dxDrawRectangle(startX, startY, w2, h2, tocolor(242, 242, 242, alpha * 0.8))
			dxDrawText('Összesen:', startX + 5, startY, startX + w2, startY + h2 + 4, tocolor(51, 51, 51, alpha), 1, font2, "left", "center")
			dxDrawText('$ '..basket.total, startX, startY, startX + w2 - 5, startY + h2 + 4, tocolor(51, 51, 51, alpha), 1, font2, "right", "center")
		else
			dxDrawRectangle(startX, startY, w2, h2, tocolor(51, 51, 51, alpha * 0.6))
			dxDrawText('Összesen:', startX + 5, startY, startX + w2, startY + h2 + 4, tocolor(242, 242, 242, alpha), 1, font2, "left", "center")
			dxDrawText('$ '..basket.total, startX, startY, startX + w2 - 5, startY + h2 + 4, tocolor(97, 177, 90, alpha), 1, font2, "right", "center") 
		end 

		startY = startY + h2 + 10

		--[[Buttons]]
		buyHover = nil 

		local buttonW, buttonH = 180, 22

		local startX = startX + w2/2 - buttonW/2

		local r,g,b = 97, 177, 90
		local text = "Készpénz"

		if exports['cr_core']:isInSlot(startX, startY, buttonW, buttonH) then 
			buyHover = 1

			dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(r, g, b, alpha)) 
			dxDrawText(text, startX, startY, startX + buttonW, startY + buttonH + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
		else
			dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
			dxDrawText(text, startX, startY, startX + buttonW, startY + buttonH + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
		end 

		startY = startY + buttonH + 5

		local text = "Bankkártya"

		if exports['cr_core']:isInSlot(startX, startY, buttonW, buttonH) then 
			buyHover = 2

			dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(r, g, b, alpha)) 
			dxDrawText(text, startX, startY, startX + buttonW, startY + buttonH + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
		else
			dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
			dxDrawText(text, startX, startY, startX + buttonW, startY + buttonH + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
		end 
	end

	if playerCol then
		if #basket.items > 0 and not payDetails.payMenu then
			local alpha = 255

			local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 10)
			
			local _, x, y = exports["cr_interface"]:getDetails("Playerbasket")
			local w, h = 240, 140

			dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))

			dxDrawImage(x + 10, y + 5, 16, 18, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawText(playerBasket and "A bevásárlókosaradban" or "A kezedben", x + 10 + 18 + 5,y+5,x+w,y+5+18 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

			local red = exports['cr_core']:getServerColor('red', true)
			local green = exports['cr_core']:getServerColor('green', true)

			dxDrawText(#basket.items.." / " .. red ..(playerBasket and global.maxItemsInBasket or global.maxItemsInHand).." db", x + 10 + 18 + 10,y+5,x+w - 10,y+5+18 + 4,tocolor(242, 242, 242, alpha),1,font,"right","center", false, false, false, true)

			dxDrawText("Súly: "..basket.weight.." / ".. red .. (playerBasket and tostring(global.maxWeightInBasket) or tostring(global.maxWeightInHand)).." kg", x + 10 + 18 + 10 + 25,y+5,x+w - 10,y+5+18 + 4 + 35,tocolor(242, 242, 242, alpha),1,font,"right","center", false, false, false, true)

			dxDrawText('Fizetendő: ' .. green .. '$ ' .. basket.total, x + 10,y+5,x+w,y+5+18 + 4 + 35,tocolor(242, 242, 242, alpha),1,font,"left","center", false, false, false, true)

			local startX, startY = x + 10, y + 45
			local _startX = startX

			local now = 1
			local line = 1

			basketHover = nil 
			for i = 1, 10 do 
				local w2, h2 = 40, 40

				dxDrawRectangle(startX, startY, w2, h2, tocolor(41, 41, 41, alpha * 0.9))
				
				if basket.items[i] then
					dxDrawImage(startX, startY, w2, h2, exports['cr_dx']:getTexture(":cr_inventory/assets/items/"..basket.items[i]["item"]..".png"))
					if exports['cr_core']:isInSlot(startX, startY, w2, h2) then 
						basketHover = i
						dxDrawImage(startX + w2/2 - (w2 * 0.8)/2, startY + h2/2 - (h2 * 0.8)/2, w2 * 0.8, h2 * 0.8, exports['cr_dx']:getTexture(":cr_shop/files/minus.png"))
					end 
				end 

				now = now + 1
				startX = startX + w2 + 5

				if now >= 6 then 
					now = 0
					line = line + 1
					startY = startY + h2 + 5
					startX = _startX
				end 
			end 
		end
	end
end, true, "low-5")

addEventHandler("onClientColShapeHit", root, function(p, md)
	if(p == localPlayer and md) then
		if(source:getData("shop >> radius")) then
			playerCol = source
		end
	end
end)

addEventHandler("onClientColShapeLeave", root, function(p, md)
	if(p == localPlayer and md) then
		if(source:getData("shop >> radius") and isElement(playerCol)) then
			playerCol = false
			if(isElement(localPlayer:getData("shop >> basketInHand"))) then
				triggerServerEvent("putdownBasket", localPlayer, localPlayer)
				playerBasket = false
			end
			basket.weight = 0
			basket.total = 0
			basket.items = {}

			exports['cr_interface']:setNode("Playerbasket", "active", false)
		end
	end
end)

local lastClickTick = -5000

addEventHandler("onClientClick", root, function(b, s, _, _, _, _, _, e)
	if(b == "left") then
		if(isElement(playerCol)) then
			if(s == "down") then
				if(isElement(e)) then
					if(e:getData("shop >> cart") and getDistanceBetweenPoints3D(e.position, localPlayer.position) < 2) then
						if(not isElement(localPlayer:getData("shop >> basketInHand"))) then
							triggerServerEvent("pickupBasket", localPlayer, localPlayer)
							playerBasket = true
							return
						else
							triggerServerEvent("putdownBasket", localPlayer, localPlayer)
							playerBasket = false
							if(#basket.items > global.maxItemsInHand or basket.weight > global.maxWeightInHand) then
								basket.items = {}
								basket.total = 0
								basket.weight = 0

								exports['cr_interface']:setNode("Playerbasket", "active", false)
							end
							return
						end
					elseif(e:getData("shop >> npc") and getDistanceBetweenPoints3D(e.position, localPlayer.position) < 2.5) then
						if(not payDetails.payMenu) then
							if(#basket.items > 0) then
								payDetails.payMenu = true
								payDetails.payRender = true
								payDetails.clickedNPC = e

								exports['cr_dx']:startFade("shop >> buy", 
									{
										["startTick"] = getTickCount(),
										["lastUpdateTick"] = getTickCount(),
										["time"] = 500,
										["animation"] = "InOutQuad",
										["from"] = 0,
										["to"] = 255,
										["alpha"] = 0,
										["progress"] = 0,
									}
								)

								scrolling = false
								buyHover = nil
								closeHover = nil 
								basketHover = nil

								minLines = 1
								maxLines = 4
								_maxLines = maxLines
								
								exports['cr_interface']:setNode("Playerbasket", "active", false)

								return
							else
								exports["cr_infobox"]:addBox("info", "A "..(playerBasket and "kosarad" or "kezed").." üres.")
							end
						end
					end
				end
				
				if playerCol then
					if #basket.items > 0 and not payDetails.payMenu then
						if basketHover then
							local i = tonumber(basketHover)
							if basket.items[i] then
								table.remove(basket.items, i)
								basket.total = 0
								basket.weight = 0

								if(#basket.items > 0) then
									for i, v in pairs(basket.items) do
										basket.total = basket.total+tonumber(v["price"])
										basket.weight = basket.weight+exports["cr_inventory"]:getItemWeight(v["item"])
									end
								end

								if #basket.items <= 0 then 
									exports['cr_interface']:setNode("Playerbasket", "active", false)
								end 

								exports["cr_infobox"]:addBox("success", "Visszatettél egy tételt a "..(playerBasket and "kosaradból" or "kezedből").."!")
								return
							end

							basketHover = nil 

							return
						end
					end 
				end

				if(spam <= getTickCount()) then
					if(shelfDetails.selectedItem ~= nil and shelfDetails.selectedItem[1] ~= "") then
						if(getDistanceBetweenPoints3D(localPlayer.position, shelfDetails.selectedItem[4]) < 0.7) then
							if(not playerBasket and #basket.items < global.maxItemsInHand) then
								local w = exports["cr_inventory"]:getItemWeight(shelfDetails.selectedItem[3]["item"])
								if(basket.weight+w < global.maxWeightInHand) then
									table.insert(basket.items, shelfDetails.selectedItem[3])

									exports['cr_interface']:setNode("Playerbasket", "active", true)
									-- anim
									exports["cr_infobox"]:addBox("success", "Egy tárgyat a kezedhez vettél!")
								else
									exports["cr_infobox"]:addBox("error", "Ezt már nem bírod el a kezedben.")
								end
								basket.total = 0
								basket.weight = 0
								if(#basket.items > 0) then
									for i, v in pairs(basket.items) do
										basket.total = basket.total+tonumber(v["price"])
										basket.weight = basket.weight+exports["cr_inventory"]:getItemWeight(v["item"])
									end
								end
								-- spam = getTickCount()+500
								return
							elseif(playerBasket and #basket.items < global.maxItemsInBasket) then
								local w = exports["cr_inventory"]:getItemWeight(shelfDetails.selectedItem[3]["item"])
								if(basket.weight+w < global.maxWeightInBasket) then
									table.insert(basket.items, shelfDetails.selectedItem[3])

									exports['cr_interface']:setNode("Playerbasket", "active", true)
									exports["cr_infobox"]:addBox("success", "Egy tárgyat a kosaradba tettél!")
								else
									exports["cr_infobox"]:addBox("error", "Ez már nem fér el a kosaradban.")
								end
								basket.total = 0
								basket.weight = 0
								if(#basket.items > 0) then
									for i, v in pairs(basket.items) do
										basket.total = basket.total+tonumber(v["price"])
										basket.weight = basket.weight+exports["cr_inventory"]:getItemWeight(v["item"])
									end
								end

								-- spam = getTickCount()+500
								return
							else
								exports["cr_infobox"]:addBox("error", "Nincs több hely a "..(playerBasket and "kosaradban" or "kezedben").."!")
							end
						else
							exports["cr_infobox"]:addBox("error", "Túl messze vagy a tárgytól.")
						end
					end
				else
					exports["cr_infobox"]:addBox("error", "Ne ilyen gyorsan!")
				end
					
				if payDetails.payMenu then
					if _sX and exports['cr_core']:isInSlot(_sX, _sY, _sW, _sH) then
						scrolling = true

						return
					end 

					if closeHover then 
						payDetails.payRender = false
						payDetails.clickedNPC = false

						exports['cr_dx']:startFade("shop >> buy", 
							{
								["startTick"] = getTickCount(),
								["lastUpdateTick"] = getTickCount(),
								["time"] = 500,
								["animation"] = "InOutQuad",
								["from"] = 255,
								["to"] = 0,
								["alpha"] = 255,
								["progress"] = 0,
							}
						)
						
						closeHover = nil 

						return
					end 

					if basketHover then
						local i = tonumber(basketHover)
						if basket.items[i] then
							table.remove(basket.items, i)
							basket.total = 0
							basket.weight = 0

							if(#basket.items > 0) then
								for i, v in pairs(basket.items) do
									basket.total = basket.total+tonumber(v["price"])
									basket.weight = basket.weight+exports["cr_inventory"]:getItemWeight(v["item"])
								end
							end

							exports["cr_infobox"]:addBox("success", "Visszatettél egy tételt a "..(playerBasket and "kosaradból" or "kezedből").."!")

							if(#basket.items == 0) then
								payDetails.payRender = false
								payDetails.clickedNPC = false

								exports['cr_dx']:startFade("shop >> buy", 
									{
										["startTick"] = getTickCount(),
										["lastUpdateTick"] = getTickCount(),
										["time"] = 500,
										["animation"] = "InOutQuad",
										["from"] = 255,
										["to"] = 0,
										["alpha"] = 255,
										["progress"] = 0,
									}
								)

								exports['cr_interface']:setNode("Playerbasket", "active", false)
							end
						end 

						basketHover = nil 

						return
					end 

					if buyHover then 
						local now = getTickCount()
						if now <= lastClickTick + 5000 then
							return 
						end 
						lastClickTick = getTickCount()

						if exports['cr_network']:getNetworkStatus() then 
							return 
						end 

						if payDetails.payRender then 
							local paid = false
							local cashBack, countedWeights = 0, {
								[1] = 0,
								[2] = 0,
								[3] = 0,
								[4] = 0,
							}

							local itemGroups = {}

							local playerWeights = {
								[1] = exports["cr_inventory"]:getWeight(localPlayer, 1),
								[2] = exports["cr_inventory"]:getWeight(localPlayer, 2),
								[3] = exports["cr_inventory"]:getWeight(localPlayer, 3),
								[4] = exports["cr_inventory"]:getWeight(localPlayer, 4),
							}

							local playerMaxWeights = {
								[1] = exports["cr_inventory"]:getMaxWeight(1),
								[2] = exports["cr_inventory"]:getMaxWeight(2),
								[3] = exports["cr_inventory"]:getMaxWeight(3),
								[4] = exports["cr_inventory"]:getMaxWeight(4),
							}

							for i, v in pairs(basket.items) do
								local itemType = tonumber(exports["cr_inventory"]:getItemType(v["item"]))
								local itemWeight = tonumber(exports["cr_inventory"]:getItemWeight(v["item"]))

								if (playerWeights[itemType]+countedWeights[itemType]+itemWeight <= playerMaxWeights[itemType]) then
									if(not itemGroups[v["item"]]) then
										itemGroups[v["item"]] = 1
									else
										itemGroups[v["item"]] = itemGroups[v["item"]]+1
									end

									countedWeights[itemType] = countedWeights[itemType]+itemWeight
								else
									cashBack = cashBack+tonumber(v["price"])
								end
							end

							if exports['cr_core']:takeMoney(localPlayer, basket.total, buyHover == 2) then
								paid = true
							else
								exports["cr_infobox"]:addBox("error", (buyHover == 2 and "Nincs elegendő pénz a bankszámládon!" or 'Nincs elegendő pénzed!'))
							end

							if(paid) then

								if(cashBack > 0) then
									exports['cr_core']:giveMoney(localPlayer, cashBack, buyHover == 2)

									exports["cr_infobox"]:addBox("warning", "Nem volt elég hely az inventorydban, ezért csak annyi tárgy árát vontuk le amennyi elfért nálad!")
								end

								for i, v in pairs(itemGroups) do
									if(exports["cr_inventory"]:isStackable(i)) then
										exports["cr_inventory"]:giveItem(localPlayer, i, 0, v, 100, 0, 0)
									else
										for ind = 1, v do
											exports["cr_inventory"]:giveItem(localPlayer, i, 0, 1, 100, 0, 0)
										end
									end
								end

								payDetails.payRender = false
								payDetails.clickedNPC = false

								exports['cr_dx']:startFade("shop >> buy", 
									{
										["startTick"] = getTickCount(),
										["lastUpdateTick"] = getTickCount(),
										["time"] = 500,
										["animation"] = "InOutQuad",
										["from"] = 255,
										["to"] = 0,
										["alpha"] = 255,
										["progress"] = 0,
									}
								)

								basket.weight = 0
								basket.total = 0
								basket.items = {}

								exports['cr_infobox']:addBox("success", "Sikeres vásárlás!")
							end
						end 

						buyHover = nil 

						return
					end 
				end
			end
		end
	elseif b == "left" and s == "up" then
		if scrolling then
			scrolling = false
		end
	end
end)

addEventHandler("onClientKey", root, 
	function(b, s)
		if(payDetails.payMenu) then
			if(b == "backspace") then
				if s then 
					payDetails.payRender = false
					payDetails.clickedNPC = false

					exports['cr_dx']:startFade("shop >> buy", 
						{
							["startTick"] = getTickCount(),
							["lastUpdateTick"] = getTickCount(),
							["time"] = 500,
							["animation"] = "InOutQuad",
							["from"] = 255,
							["to"] = 0,
							["alpha"] = 255,
							["progress"] = 0,
						}
					)
				end 
			elseif(b == "mouse_wheel_up") then
				if s and canScroll then
					if minLines - 1 >= 1 then
						minLines = minLines - 1
						maxLines = maxLines - 1
					end
				end
			elseif(b == "mouse_wheel_down") then
				if s and canScroll then
					if maxLines + 1 <= #basket.items then
						minLines = minLines + 1
						maxLines = maxLines + 1
					end
				end
			end
		end
	end
)

function joinCheck(key, old, new)
	if(key == "loggedIn" and new) then
		for i, v in pairs(getElementsByType("colshape", resourceRoot)) do
			if(getDistanceBetweenPoints3D(v.position, localPlayer.position) < global.radius/2) then
				playerCol = v
				break
			end
		end
		removeEventHandler("onClientElementDataChange", root, joinCheck)
	end
end
addEventHandler("onClientElementDataChange", root, joinCheck)