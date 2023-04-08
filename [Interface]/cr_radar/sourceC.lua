local screenW,screenH = guiGetScreenSize()
local mapTextureSize = 3072
local mapRatio = 6000 / mapTextureSize

toggleControl("radar", false)

local texture = nil

local minimap = 1

local blipanimation = true
local zoomanimation = true 
local gpsLostConnectionEnabled = true
local radarRotation = false

local hudVisible_ostate = getElementData( localPlayer, "hudVisible")
local keys_denied_ostate = getElementData( localPlayer, "keysDenied")


local optionMenuState = false
local optionMenuAnimationStart = nil
local isoptionMenuAnimation = false
local optionMenuAlpha = 0

local blipsMenuState = false
local blipsMenuAnimationStart = nil
local isblipsMenuAnimation = false
local blipsMenuAlpha = 0

navigatorSound = true
state3DBlip = thblipstate

function setNavigatorSound(state)
	navigatorSound = state
end

function getNavigatorSound()
	return navigatorSound
end

local textures = {}

_dxDrawImage = dxDrawImage
local function dxDrawImage(x,y,w,h,img, r, rx, ry, color, postgui)
    if type(img) == "string" then
        if not textures[img] then
            textures[img] = dxCreateTexture(img, "dxt3", true, "wrap")
        end
        img = textures[img]
    end
    return _dxDrawImage(x,y,w,h,img, r, rx, ry, color, postgui)
end

local Map_blips_timer = false
local Map_blips = {}
local Map_blips_radar = {}
local now_time = 0

local gps_anim_start = nil

local custom_blip_choosed_type = 0
local custom_blip_choosed = {"mark_1", "mark_2", "mark_3", "mark_4", "garage", "house", "vehicle", "speedcam"}

local hexCode;
local hovered_blip = nil
local gps_icon_x,gps_icon_y = 20,15

local minimapPosX = 0
local minimapPosY = 0
local minimapWidth = 320
local minimapHeight = 225
local minimapCenterX = minimapPosX + minimapWidth / 2
local minimapCenterY = minimapPosY + minimapHeight / 2
local minimapRenderSize = 400
local minimapRenderHalfSize = minimapRenderSize * 0.5
local minimapRender = dxCreateRenderTarget(minimapRenderSize, minimapRenderSize,true)
local playerMinimapZoom = 0.5
local minimapZoom = playerMinimapZoom
local minimapIsVisible = false
local gpsIsVisible = false

local bigmapPosX = 60
local bigmapPosY = 60
local bigmapWidth = screenW - 120
local bigmapWidthRoot = bigmapWidth
local bigmapHeight = screenH - 120
local bigmapCenterX = bigmapPosX + bigmapWidth / 2
local bigmapCenterY = bigmapPosY + bigmapHeight / 2
local bigmapZoom = 0.5
bigmapIsVisible = false

local blipsMinLines = 1
local blipsMaxLines = math.floor((bigmapHeight + 8) / (23 + 4))
local _blipsMaxLines = blipsMaxLines

local blipsData = {}
local usedInBlipsData = {}

local lastCursorPos = false
local mapDifferencePos = false
local mapMovedPos = false
local lastDifferencePos = false
local mapIsMoving = false
local lastMapPosX, lastMapPosY = 0, 0
local mapPlayerPosX, mapPlayerPosY = 0, 0

local zoneLineHeight = 25
local screenSource = dxCreateScreenSource(screenW, screenH)

local gpsLineWidth = 60
local gpsLineIconSize = 30
local gpsLineIconHalfSize = gpsLineIconSize / 2

occupiedVehicle = nil

local way_say ={
	["left"] = {"Forduljon balra "," után!"},
	["right"] = {"Forduljon jobbra "," után!"},
	["forward"] = {"Haladjon tovább egyenesen ","t!"},
	["finish"] = {"Hamarosan megérkezik","az úticélhoz!"},
	["around"] = {"Forduljon vissza ","ahol lehetséges!"},
}

local renderWidget = {}
renderWidget.__index = renderWidget

.minimap

createdBlips = {}
local mainBlips = {

}

local blipTooltips = {
	
}

local hoveredWaypointBlip = false

local farshowBlips = {}
local farshowBlipsData = {}

carCanGPSVal = 1
local gpsHello = false
local gpsLines = {}
local gpsRouteImage = false
local gpsRouteImageData = {}

local hover3DBlipCb = false

local playerCanSeePlayers = false

local getZoneNameEx = getZoneName
function getZoneName(x, y, z, citiesonly)
	local zoneName = getZoneNameEx(x, y, z, citiesonly)
	if zoneName == "Greenglass College" then
		return "Las Venturas City Hall"
	else
		return zoneName
	end
end

function textureLoading()
	texture = dxCreateTexture("assets/images/map.png", "dxt3", true, "wrap")
	if not texture then
		setTimer(textureLoading,500,1)
	end
end

addCommandHandler('resetmap', 
	function()
		textureLoading()
		if texture then
			dxSetTextureEdge(texture, "border", tocolor(61, 80, 84,255))
		end

		local syntax = exports['cr_core']:getServerSyntax('Radar', 'success')
		outputChatBox(syntax .. 'Sikeres művelet!', 255, 255, 255, true)
	end 
)

local save_data = {
	["3D"] = false,
	["Sounds"] = true,
	["Animation"] = true,
	['gpsLostConnectionEnabled'] = true,
	['radarRotation'] = false,
}

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        local save_data = {
            ["3D"] = thblipstate,
            ["Sounds"] = navigatorSound,
			["Animation"] = blipanimation,
			["ZoomAnimation"] = zoomanimation,
			['gpsLostConnectionEnabled'] = gpsLostConnectionEnabled,
			['radarRotation'] = radarRotation,
        }
        exports['cr_json']:jsonSAVE("radar/option.json", save_data, true)
    end
)

addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		--jsonCheck()
		save_data = exports['cr_json']:jsonGET("radar/option.json", true, {
            ["3D"] = false,
            ["Sounds"] = true,
			["Animation"] = true,
			["ZoomAnimation"] = true, 
			['gpsLostConnectionEnabled'] = true,
			['radarRotation'] = true,
        })
		thblipstate = save_data["3D"]
        toggle3DBlip(thblipstate)
		navigatorSound = save_data["Sounds"]
		blipanimation = save_data["Animation"]
		zoomanimation = save_data["ZoomAnimation"]
		gpsLostConnectionEnabled = save_data['gpsLostConnectionEnabled']
		radarRotation = save_data['radarRotation']
		
		textureLoading()
		if getPedOccupiedVehicle( localPlayer ) then
			occupiedVehicle = getPedOccupiedVehicle( localPlayer )
		end
		if texture then
			dxSetTextureEdge(texture, "border", tocolor(61, 80, 84,255))
		end
		
		for k,v in ipairs(getElementsByType("blip")) do
			blipTooltips[v] = getElementData(v, "tooltipText")
		end
		

		if getElementData( localPlayer, "loggedIn") then
			minimapIsVisible = true
			gpsIsVisible = true 
		else
			minimapIsVisible = false
			gpsIsVisible = false 
		end

		if getElementData( localPlayer, "hudVisible") then
			minimapIsVisible = true
			gpsIsVisible = true
		else
			minimapIsVisible = false
			gpsIsVisible = false 
		end
        
        if minimapIsVisible then
            createRender("renderWidget.minimap", renderWidget.minimap)
        else
            destroyRender("renderWidget.minimap")    
		end
		
		if gpsIsVisible then 
			createRender("drawnGPS", drawnGPS)
		else 
			destroyRender("drawnGPS")
		end 
		
		if occupiedVehicle then
			carCanGPS()
		end		

		usedInBlipsData['fishing'] = true
		table.insert(blipsData, {'fishing', 'Horgászat', {255, 255, 255}})

		usedInBlipsData['butcher'] = true
		table.insert(blipsData, {'butcher', 'Hentes', {255, 255, 255}})

		usedInBlipsData['target'] = true
		table.insert(blipsData, {'target', 'Cél', {255, 255, 255}})

		usedInBlipsData['job'] = true
		table.insert(blipsData, {'job', 'Munka', {255, 255, 255}})

		usedInBlipsData['job_vehicle'] = true
		table.insert(blipsData, {'job_vehicle', 'Munkakocsi', {255, 255, 255}})

		usedInBlipsData['mark'] = true
		table.insert(blipsData, {'mark', 'Jelölés', {255, 255, 255}})

		usedInBlipsData['hunting_down'] = true
		table.insert(blipsData, {'hunting_down', 'Vadászfelvásárló', {255, 255, 255}})

		for k,v in pairs(radarBlips) do 
			if not usedInBlipsData[v[4]] then 
				usedInBlipsData[v[4]] = true 
		
				table.insert(blipsData, {v[4], v[1]:gsub(':', ''):gsub('[^a-z]"', ''), {v[7], v[8], v[9]}})
			end 
		end 
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue, nValue)
		if source == occupiedVehicle then
			if dataName == "veh >> tuningData" then
				if nValue and type(nValue) == "table" then 
					carCanGPSVal = nValue["gps"] == 1
					
					if not carCanGPSVal then
						if getElementData(source, "gpsDestination") then
							endRoute()
						end
					end
				else
					carCanGPSVal = false
					
					if not carCanGPSVal then
						if getElementData(source, "gpsDestination") then
							endRoute()
						end
					end
				end 
			elseif dataName == "gpsDestination" then
				local dataValue = getElementData(source, dataName) or false
				
				if dataValue then
					
					gpsThread = coroutine.create(makeRoute)
					coroutine.resume(gpsThread, unpack(dataValue))
					waypointInterpolation = false
				else
					endRoute()
				end
			end
		elseif source == localPlayer and dataName == "hudVisible" then
			minimapIsVisible = getElementData( localPlayer, "hudVisible")
			gpsIsVisible = getElementData( localPlayer, "hudVisible")
		elseif source == localPlayer and dataName == "loggedIn"then
			if localPlayer:getData("hudVisible") then 
				minimapIsVisible = true
				gpsIsVisible = true
			end 
		elseif source == localPlayer and dataName == "inDeath" then
			if occupiedVehicle and getElementData( localPlayer,"inDeath") then
				occupiedVehicle = nil
			end
		end
        
        if minimapIsVisible then
            createRender("renderWidget.minimap", renderWidget.minimap)
        else
            destroyRender("renderWidget.minimap")    
		end
		
		if gpsIsVisible then 
			createRender("drawnGPS", drawnGPS)
		else 
			destroyRender("drawnGPS")
		end 
		
		if getElementType(source) == "blip" and dataName == "tooltipText" then
			blipTooltips[source] = getElementData(source, dataName)
		end
	end
)



function getHudCursorPos()
	if isCursorShowing() then
		return getCursorPosition()
	end
	return false
end



reMap = function(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end


local w_x, w_y, w_w, w_h = 0,0,0,0
local diagonal = 0

local logoRotation = 0
function renderWidget.minimap(x, y, w, h)
	
	enabled, w_x, w_y, w_w, w_h, sizable, turnable = exports["cr_interface"]:getDetails("radar")

	if not minimapIsVisible or not enabled then return end 

	x, y, minimapWidth, minimapHeight = w_x, w_y, w_w, w_h
	diagonal =  math.sqrt((w_w/2)^2+(w_h/2)^2)

	hexCode = exports['cr_core']:getServerColor(nil, true)
	local font = exports['cr_fonts']:getFont("RobotoB", 11)
	local font_small = exports["cr_fonts"]:getFont("Roboto",8)

	local playerDimension = getElementDimension(localPlayer)
	if lostConnection then playerDimension = -1 end

	if playerDimension == 0 then


	if getPedOccupiedVehicle(localPlayer) then occupiedVehicle = getPedOccupiedVehicle(localPlayer)
	else occupiedVehicle = nil end


	if (minimapWidth > 445 or minimapHeight > 400) and minimapRenderSize < 800 then
		minimapRenderSize = 800
		minimapRenderHalfSize = minimapRenderSize * 0.5
		destroyElement(minimapRender)
		minimapRender = dxCreateRenderTarget(minimapRenderSize, minimapRenderSize,true)
	end
	if minimapWidth <= 445 and minimapHeight <= 400 and minimapRenderSize > 600 then
		minimapRenderSize = 600
		minimapRenderHalfSize = minimapRenderSize * 0.5
		destroyElement(minimapRender)
		minimapRender = dxCreateRenderTarget(minimapRenderSize, minimapRenderSize,true)
	end 
	if (minimapWidth > 325 or minimapHeight > 235) and minimapRenderSize < 600 then
		minimapRenderSize = 600
		minimapRenderHalfSize = minimapRenderSize * 0.5
		destroyElement(minimapRender)
		minimapRender = dxCreateRenderTarget(minimapRenderSize, minimapRenderSize,true)
	end
	if minimapWidth <= 325 and minimapHeight <= 235 and minimapRenderSize > 400 then
		minimapRenderSize = 400
		minimapRenderHalfSize = minimapRenderSize * 0.5
		destroyElement(minimapRender)
		minimapRender = dxCreateRenderTarget(minimapRenderSize, minimapRenderSize,true)
	end
	
	if minimapPosX ~= x or minimapPosY ~= y then
		minimapPosX = x
		minimapPosY = y
	end
	
		minimapCenterX = minimapPosX + minimapWidth / 2
		minimapCenterY = minimapPosY + minimapHeight / 2
		local minimapRenderSizeOffset = (minimapRenderSize * 2)

		if radarRotation then 
			dxUpdateScreenSource(screenSource, true)
		end 

		--dxUpdateScreenSource(screenSource, true)

		if getKeyState("num_add") and playerMinimapZoom < 1.2 then
			if not occupiedVehicle then
				playerMinimapZoom = playerMinimapZoom + 0.01
				calculateBlip() 
			end
		elseif getKeyState("num_sub") and playerMinimapZoom > 0.31 then
			if not occupiedVehicle then
				playerMinimapZoom = playerMinimapZoom - 0.01
				calculateBlip() 
			end
		end

		minimapZoom = playerMinimapZoom

		if occupiedVehicle then
			local vehicleZoom = getVehicleSpeed(occupiedVehicle) / 1300
			if vehicleZoom >= 0.4 then
				vehicleZoom = 0.4
			end
			minimapZoom = minimapZoom - vehicleZoom
		end

		playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
		
		local cameraX, cameraY, _, faceTowardX, faceTowardY = getCameraMatrix()
		cameraRotation = radarRotation and math.deg(math.atan2(faceTowardY - cameraY, faceTowardX - cameraX)) + 360 + 90 or 0
	
		remapPlayerPosX, remapPlayerPosY = remapTheFirstWay(playerPosX), remapTheFirstWay(playerPosY)
		
		if radarRotation then 
			dxDrawImageSection(minimapPosX - minimapRenderSize / 2 + minimapWidth / 2, minimapPosY - minimapRenderSize / 2 + minimapHeight / 2, minimapRenderSize, minimapRenderSize, remapTheSecondWay(playerPosX) - minimapRenderSize / minimapZoom / 2, remapTheFirstWay(playerPosY) - minimapRenderSize / minimapZoom / 2, minimapRenderSize / minimapZoom, minimapRenderSize / minimapZoom, texture,cameraRotation - 180)  
		else 
			dxDrawImageSection(minimapPosX, minimapPosY, minimapWidth, minimapHeight, remapTheSecondWay(playerPosX) - minimapWidth / minimapZoom / 2, remapTheFirstWay(playerPosY) - minimapHeight / minimapZoom / 2, minimapWidth / minimapZoom, minimapHeight / minimapZoom, texture)
		end 

		if gpsRouteImage then
			if radarRotation then 
				dxSetRenderTarget(minimapRender,true)
				dxSetBlendMode("add")
					dxDrawImage(minimapRenderSize / 2 + (remapTheFirstWay(playerPosX) - (gpsRouteImageData[1] + gpsRouteImageData[3] / 2)) * minimapZoom - gpsRouteImageData[3] * minimapZoom / 2, minimapRenderSize / 2 - (remapTheFirstWay(playerPosY) - (gpsRouteImageData[2] + gpsRouteImageData[4] / 2)) * minimapZoom + gpsRouteImageData[4] * minimapZoom / 2, gpsRouteImageData[3] * minimapZoom, -(gpsRouteImageData[4] * minimapZoom), gpsRouteImage, 180, 0, 0,  tocolor(255, 212, 5))
				dxSetBlendMode("blend")
				dxSetRenderTarget()

				dxSetBlendMode("add")
				dxDrawImage(minimapPosX - minimapRenderSize / 2 + minimapWidth / 2, minimapPosY - minimapRenderSize / 2 + minimapHeight / 2, minimapRenderSize, minimapRenderSize, minimapRender, cameraRotation - 180)
				dxSetBlendMode("blend")
			else 
				dxUpdateScreenSource(screenSource, true)
				dxSetBlendMode("add")
					dxDrawImage(minimapCenterX + (remapTheFirstWay(playerPosX) - (gpsRouteImageData[1] + gpsRouteImageData[3] / 2)) * minimapZoom - gpsRouteImageData[3] * minimapZoom / 2, minimapCenterY - (remapTheFirstWay(playerPosY) - (gpsRouteImageData[2] + gpsRouteImageData[4] / 2)) * minimapZoom + gpsRouteImageData[4] * minimapZoom / 2, gpsRouteImageData[3] * minimapZoom, -(gpsRouteImageData[4] * minimapZoom), gpsRouteImage, 180, 0, 0, tocolor(255, 212, 5))
				dxSetBlendMode("blend")
				dxDrawImageSection(minimapPosX - minimapRenderSizeOffset, minimapPosY - minimapRenderSizeOffset, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, minimapPosX - minimapRenderSizeOffset, minimapPosY - minimapRenderSizeOffset, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, screenSource)
				dxDrawImageSection(minimapPosX - minimapRenderSizeOffset, minimapPosY + minimapHeight, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, minimapPosX - minimapRenderSizeOffset, minimapPosY + minimapHeight, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, screenSource)
				dxDrawImageSection(minimapPosX - minimapRenderSizeOffset, minimapPosY, minimapRenderSizeOffset, minimapHeight, minimapPosX - minimapRenderSizeOffset, minimapPosY, minimapRenderSizeOffset, minimapHeight, screenSource)
				dxDrawImageSection(minimapPosX + minimapWidth, minimapPosY, minimapRenderSizeOffset, minimapHeight, minimapPosX + minimapWidth, minimapPosY, minimapRenderSizeOffset, minimapHeight, screenSource)
			end 
		end	
		
		if not blipanimation then  
			renderBlip() 
		end

		if radarRotation then 		
			local minimapRenderSizeOffset = minimapRenderSize * 0.75

			dxDrawImageSection(minimapPosX - minimapRenderSizeOffset, minimapPosY - minimapRenderSizeOffset, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, minimapPosX - minimapRenderSizeOffset, minimapPosY - minimapRenderSizeOffset, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, screenSource)
			dxDrawImageSection(minimapPosX - minimapRenderSizeOffset, minimapPosY + minimapHeight, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, minimapPosX - minimapRenderSizeOffset, minimapPosY + minimapHeight, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, screenSource)
			dxDrawImageSection(minimapPosX - minimapRenderSizeOffset, minimapPosY, minimapRenderSizeOffset, minimapHeight, minimapPosX - minimapRenderSizeOffset, minimapPosY, minimapRenderSizeOffset, minimapHeight, screenSource)
			dxDrawImageSection(minimapPosX + minimapWidth, minimapPosY, minimapRenderSizeOffset, minimapHeight, minimapPosX + minimapWidth, minimapPosY, minimapRenderSizeOffset, minimapHeight, screenSource)
		end 
		
		local playerArrowSize = 65 / (4 - minimapZoom) + 3
		local playerArrowHalfSize = playerArrowSize / 2
		_, _, playerRotation = getElementRotation(localPlayer)

		dxDrawOuterBorder(minimapPosX, minimapPosY, minimapWidth,minimapHeight, 4, tocolor(22, 21, 18, 255))
		dxDrawRectangle(minimapPosX, minimapPosY, minimapWidth, 22, tocolor(0,0,0, 255 * 0.25))
		_dxDrawImage(minimapPosX + 12, minimapPosY + 22/2 - 12/2, 10,12, 'assets/images/design/location.png')

		local zoneName = getZoneName(playerPosX, playerPosY, playerPosZ,false)
		local font_bold = exports['cr_fonts']:getFont("Poppins-Medium", 14)
		local text_width = dxGetTextWidth( zoneName, 1, font_bold )
		if w_w > text_width + 32 then 
			dxDrawText(zoneName, minimapPosX+30, minimapPosY, minimapPosX + minimapWidth - 10, minimapPosY + 22 + 4, tocolor(242, 242, 242, 255), 1, font_bold, "left", "center",false,false,false,true)
		end

		if now_time <= getTickCount() then
			now_time = getTickCount()+30
			calculateBlip() 
		end

		if blipanimation then  renderBlip() end
		dxDrawImage(minimapCenterX - playerArrowHalfSize, minimapCenterY - playerArrowHalfSize, playerArrowSize, playerArrowSize, "assets/images/player.png", math.abs(360 - playerRotation) + (radarRotation and (cameraRotation - 180) or 0))
    else
        if minimapPosX ~= x or minimapPosY ~= y then
            minimapPosX = x
            minimapPosY = y
        end
        
        local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, getTickCount() / 5000, "SineCurve")
        minimapCenterX = minimapPosX + minimapWidth / 2
        minimapCenterY = minimapPosY + minimapHeight / 2
        dxDrawOuterBorder(minimapPosX, minimapPosY, minimapWidth,minimapHeight, 4, tocolor(22, 21, 18, 255))
        dxDrawRectangle(minimapPosX, minimapPosY, minimapWidth,minimapHeight, tocolor(20, 20, 20, 255))
        
        local startX, startY = minimapPosX + 15, minimapPosY + 15
        local _startX, _startY = startX, startY
        local between1, between2 = 25, 25
        local columns = math.floor((minimapWidth - 15) / between1)
        local lines = math.floor((minimapHeight - 15) / between2)
        local nowColumn = 1
        local nowLine = 1
        
        for i = 1, columns * lines do 
            dxDrawRectangle(startX, startY, 2, 2, tocolor(6, 6, 6, 255))
            startX = startX + between1
            
            nowColumn = nowColumn + 1
            if nowColumn > columns then
                nowColumn = 1
                nowLine = nowLine + 1
                startX = _startX
                startY = startY + between2
            end
        end
        
        local between1, between2 = 5, 5
        local columns = math.floor((minimapWidth - 15) / between1)
        local lines = math.floor((minimapHeight - 15) / between2)
        
        local columns = math.max(2, math.floor(columns * 0.1))
        if columns % 2 == 1 then
            columns = columns + 1
        end
        for i = 1, columns do
            if i % 2 == 1 then
                --outputChatBox("asd")
                local x = interpolateBetween(0, 0, 0, minimapWidth, 0, 0, getTickCount() / (20000 * (i / columns)), "SineCurve")
                dxDrawRectangle(minimapPosX + x, minimapPosY, 2, minimapHeight, tocolor(6, 6, 6, 255))
            else
                --outputChatBox("asd2")
                local x = interpolateBetween(2, 0, 0, minimapWidth, 0, 0, getTickCount() / (20000 * (i / columns)), "SineCurve")
                dxDrawRectangle((minimapPosX + minimapWidth) - x, minimapPosY, 2, minimapHeight, tocolor(6, 6, 6, 255))
            end
        end
        
        local lines = math.max(2, math.floor(lines * 0.1))
        if lines % 2 == 1 then
            lines = lines + 1
        end
        for i = 1, lines do
            if i % 2 == 1 then
                local y = interpolateBetween(0, 0, 0, minimapHeight, 0, 0, getTickCount() / (20000 * (i / lines)), "SineCurve")
                dxDrawRectangle(minimapPosX, minimapPosY + y, minimapWidth, 2, tocolor(6, 6, 6, 255))
            else
                local y = interpolateBetween(2, 0, 0, minimapHeight, 0, 0, getTickCount() / (20000 * (i / lines)), "SineCurve")
                dxDrawRectangle(minimapPosX, (minimapPosY + minimapHeight) - y, minimapWidth, 2, tocolor(6, 6, 6, 255))
            end
        end
        
        local r,g,b = exports['cr_core']:getServerColor("red")
        local font = exports['cr_fonts']:getFont("Poppins-SemiBold", 13)
		local startY = -(62/2 + dxGetFontHeight(1, font)/2)
        dxDrawImage(minimapCenterX - 54/2, minimapCenterY + startY, 54, 62, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
		startY = startY + 62 + 5 + dxGetFontHeight(1, font)/2
		if dxGetTextWidth("LOST CONNECTION...", 1, font, true) <= minimapWidth then 
			dxDrawText("LOST CONNECTION...", minimapCenterX, minimapCenterY + startY, minimapCenterX, minimapCenterY + startY, tocolor(r, g, b, alpha), 1, font, "center", "center")
		end
	end
end

function drawnGPS()
	---
	-- GPS irányzék
	---

	local enabled, w_x, w_y, w_w, w_h, sizable, turnable = exports["cr_interface"]:getDetails("gps")

	--[[
	if w_w*0.81 > 300 then
		w_w = 300
	else
		w_w = w_w*0.81
	end]]

	w_y = w_y+5
	w_x = w_x-10

	if not gpsIsVisible or not enabled then return end 

	hexCode = exports['cr_core']:getServerColor(nil, true)
	local font = exports['cr_fonts']:getFont("Poppins-SemiBold", 12)
	local font_small = exports["cr_fonts"]:getFont("Poppins-Medium", 10)

	if w_x+gps_icon_x+gpsLineIconSize <= w_x+w_w then
		if gpsRoute or (not gpsRoute and waypointEndInterpolation) then
		
			if waypointEndInterpolation then
				local interpolationProgress = (getTickCount() - waypointEndInterpolation) / 1550
				interpolatePosition,interpolateAlpha = interpolateBetween(0, 150, 0, 75, 0, 0, interpolationProgress, "Linear") 
				
				dxDrawRectangle( w_x+10, w_y-5, w_w,60 ,tocolor(23, 23, 23,interpolateAlpha * 0.5))

				w_y = w_y - 5
				
				dxDrawImage(w_x+gps_icon_x , w_y+ gps_icon_y, gpsLineIconSize, gpsLineIconSize, "assets/images/gps/finish.png", 0, 0, 0, tocolor(255, 255, 255, interpolateAlpha))
				
				if interpolationProgress > 1 then
					waypointEndInterpolation = false
				end
			elseif nextWp then
				dxDrawRectangle( w_x+10, w_y-5, w_w,60 ,tocolor(23, 23, 23,255 * 0.5))

				w_y = w_y - 5
				if currentWaypoint ~= nextWp and not tonumber(reRouting) then
					if nextWp > 1 then
						waypointInterpolation = {getTickCount(), currentWaypoint}
					end

					currentWaypoint = nextWp
				end
				
				if tonumber(reRouting) then
					currentWaypoint = nextWp
				

					local reRouteProgress = (getTickCount() - reRouting) / 1250
					local refreshAngle_1, refreshAngle_2 = interpolateBetween(360, 0, 0, 0, 360, 0, reRouteProgress, "Linear")

					dxDrawImage(w_x+gps_icon_x , w_y+ gps_icon_y, gpsLineIconSize, gpsLineIconSize, "assets/images/gps/circleout.png", refreshAngle_1,0,0,tocolor( 200,200,200,firstAlpha))
					dxDrawImage(w_x+gps_icon_x , w_y+ gps_icon_y, gpsLineIconSize, gpsLineIconSize, "assets/images/gps/circlein.png", refreshAngle_2,0,0,tocolor( 200,200,200,firstAlpha))

					local msg_length = {dxGetTextWidth(way_say["around"][1]..""..way_say["around"][2], 1,font),dxGetTextWidth(way_say["around"][1].."\n"..way_say["around"][2], 1,font)}
					if  w_x+70+msg_length[1]+2 < w_x+w_w then
						dxDrawText(way_say["around"][1]..""..way_say["around"][2],  w_x+70,w_y,  w_x+70+100, w_y+55, tocolor(200,200,200, firstAlpha), 1,1, font, "left", "center")
					elseif w_x+70+msg_length[2]+2 < w_x+w_w then
						dxDrawText(way_say["around"][1].."\n"..way_say["around"][2],  w_x+70,w_y,  w_x+70+100, w_y+55, tocolor(200,200,200, firstAlpha), 1,1, font, "left", "center")
					end

					if reRouteProgress > 1 then
						reRouting = getTickCount()
					end
				elseif turnAround then
					currentWaypoint = nextWp
						if not gps_anim_start then gps_anim_start = getTickCount() end
					local startPolation, endPolation = (getTickCount() - gps_anim_start) / 600, 0
					local firstAlpha = interpolateBetween(0,0,0, 255,0,0,startPolation, "Linear")

					dxDrawImage(w_x+gps_icon_x , w_y+ gps_icon_y, gpsLineIconSize, gpsLineIconSize, "assets/images/gps/around.png",0,0,0,tocolor( 200,200,200,firstAlpha))
					local msg_length = {dxGetTextWidth(way_say["around"][1]..""..way_say["around"][2], 1,font),dxGetTextWidth(way_say["around"][1].."\n"..way_say["around"][2], 1,font)}
					if  w_x+70+msg_length[1]+2 < w_x+w_w then
						dxDrawText(way_say["around"][1]..""..way_say["around"][2],  w_x+70,w_y,  w_x+70+100, w_y+55, tocolor(200,200,200, firstAlpha), 1,1, font, "left", "center")
					elseif w_x+70+msg_length[2]+2 < w_x+w_w then
						dxDrawText(way_say["around"][1].."\n"..way_say["around"][2],  w_x+70,w_y,  w_x+70+100, w_y+55, tocolor(200,200,200, firstAlpha), 1,1, font, "left", "center")
					end

					

				elseif not waypointInterpolation then
					dxDrawImage(w_x+gps_icon_x , w_y+gps_icon_y, gpsLineIconSize, gpsLineIconSize, "assets/images/gps/" .. gpsWaypoints[nextWp][2] .. ".png",0,0,0,tocolor(200,200,200,255))
					if gps_anim_start then gps_anim_start = nil end
					
						local root_distance = math.floor((gpsWaypoints[nextWp][3] or 0) / 10) * 10
						local msg = {{"",""},{"",""},{"",""}}

						if root_distance >= 1000 then
							root_distance = math.round((root_distance/1000),1,"floor")
							msg[1][1] = root_distance.. " kilóméter"
							msg[1][2] = way_say[gpsWaypoints[nextWp][2]][1]..""..root_distance.. " kilóméter"..way_say[gpsWaypoints[nextWp][2]][2]
							msg[2] = root_distance.. " kilóméter"
							msg[3][1] = root_distance.. " km\n"
						else
							msg[1][1] = root_distance.. " méter"
							msg[1][2] = way_say[gpsWaypoints[nextWp][2]][1]..""..root_distance.. " méter"..way_say[gpsWaypoints[nextWp][2]][2]
							msg[2] = root_distance.. " méter"
							msg[3] = root_distance.. " m\n"
						end

						local msg_length = {dxGetTextWidth(msg[1][2], 1,font_small),dxGetTextWidth(msg[2], 1,font),dxGetTextWidth(msg[3], 1,font)}
						if w_x+70+msg_length[1]+2 < w_x+w_w then
							dxDrawText(msg[1][1],  w_x+70,w_y,  w_x+70+100, w_y+40, tocolor(200,200,200, 255), 1,1, font, "left", "center")
							dxDrawText(msg[1][2],  w_x+70,w_y+40,  w_x+70+100, w_y+45, tocolor(150, 150, 150, 255), 1,1, font_small, "left", "center")
						elseif  w_x+70+msg_length[2]+2 < w_x+w_w then
							dxDrawText(msg[2],  w_x+70,w_y,  w_x+70+100, w_y+40, tocolor(200,200,200, 255), 1,1, font, "left", "center")
						elseif  w_x+70+msg_length[3]+2 < w_x+w_w then
							dxDrawText(msg[3],  w_x+70,w_y,  w_x+70+100, w_y+40, tocolor(200,200,200, 255), 1,1, font, "left", "center")
						end
					

				else
					local startPolation, endPolation = (getTickCount() - waypointInterpolation[1]) / 1000, 0
					local firstAlpha,mover_x,mover_y = interpolateBetween(255,10,0, 0,gps_icon_x,gps_icon_y,startPolation, "Linear")
					
					dxDrawImage(w_x+gps_icon_x, w_y+ gps_icon_y-mover_y, gpsLineIconSize, gpsLineIconSize, "assets/images/gps/" .. gpsWaypoints[waypointInterpolation[2]][2] .. ".png",0,0,0,tocolor(200,200,200,firstAlpha))
					
					local root_distance = math.floor((gpsWaypoints[nextWp][3] or 0) / 10) * 10
						local msg = {{"",""},{"",""},{"",""}}

						if root_distance >= 1000 then 
							root_distance = math.round((root_distance/1000),1,"floor")
							msg[1][1] = root_distance.. " kilóméter"
							msg[1][2] = way_say[gpsWaypoints[waypointInterpolation[2]][2]][1]..""..root_distance.. " kilóméter"..way_say[gpsWaypoints[waypointInterpolation[2]][2]][2]
							msg[2] = root_distance.. " kilóméter"
							msg[3] = root_distance.. " km\n"	
						else
							msg[1][1] = root_distance.. " méter"
							msg[1][2] = way_say[gpsWaypoints[waypointInterpolation[2]][2]][1]..""..root_distance.. " méter"..way_say[gpsWaypoints[waypointInterpolation[2]][2]][2]
							msg[2] = root_distance.. " méter"
							msg[3] = root_distance.. " m\n"
						end
						local msg_length = {dxGetTextWidth(msg[1][2], 1,font_small),dxGetTextWidth(msg[2], 1,font),dxGetTextWidth(msg[3], 1,font)}
						if w_x+70+msg_length[1]+2 < w_x+w_w then
							dxDrawText(msg[1][1],  w_x+70,w_y-mover_y,  w_x+70+100, w_y+40-mover_y, tocolor(200,200,200, firstAlpha), 1,1, font, "left", "center")
							dxDrawText(msg[1][2],  w_x+70,w_y-mover_y+40,  w_x+70+100, w_y+45-mover_y, tocolor(150, 150, 150, firstAlpha), 1,1, font_small, "left", "center")
						elseif  w_x+70+msg_length[2]+2 < w_x+w_w then
							dxDrawText(msg[2],  w_x+70,w_y-mover_y,  w_x+70+100, w_y+40-mover_y, tocolor(200,200,200, firstAlpha), 1,1, font, "left", "center")
							elseif  w_x+70+msg_length[3]+2 < w_x+w_w then
							dxDrawText(msg[3],  w_x+70,w_y-mover_y,  w_x+70+100, w_y+40-mover_y, tocolor(200,200,200, firstAlpha), 1,1, font, "left", "center")
						end

					if gpsWaypoints[waypointInterpolation[2] + 1] then
											
						dxDrawImage(w_x+gps_icon_x-(gps_icon_x-mover_x), w_y+ gps_icon_y, gpsLineIconSize, gpsLineIconSize, "assets/images/gps/" .. gpsWaypoints[waypointInterpolation[2]+1][2] .. ".png",0,0,0,tocolor(200,200,200,255-firstAlpha))
						
						
						local root_distance = math.floor((gpsWaypoints[nextWp][3] or 0) / 10) * 10
						local msg = {{"",""},{"",""},{"",""}}

						if root_distance >= 1000 then 
							root_distance = math.round((root_distance/1000),1,"floor")
							msg[1][1] = root_distance.. " kilóméter"
							msg[1][2] = way_say[gpsWaypoints[waypointInterpolation[2]+1][2]][1]..""..root_distance.. " kilóméter"..way_say[gpsWaypoints[waypointInterpolation[2]+1][2]][2]
							msg[2] = root_distance.. " kilóméter"
							msg[3] = root_distance.. " km\n"	
						else
							msg[1][1] = root_distance.. " méter"
							msg[1][2] = way_say[gpsWaypoints[waypointInterpolation[2]+1][2]][1]..""..root_distance.. " kilóméter"..way_say[gpsWaypoints[waypointInterpolation[2]+1][2]][2]
							msg[2] = root_distance.. " méter"
							msg[3] = root_distance.. " m\n"
						end
						local msg_length = {dxGetTextWidth(msg[1][2], 1,font),dxGetTextWidth(msg[2], 1,font_small),dxGetTextWidth(msg[3], 1,font)}
						if w_x+70+msg_length[1]+2 < w_x+w_w then
							dxDrawText(msg[1][1],  w_x+70,w_y+gps_icon_y-mover_y,  w_x+70+100, w_y+40+gps_icon_y-mover_y, tocolor(200,200,200, 255-firstAlpha), 1,1, font, "left", "center")
							dxDrawText(msg[1][2],  w_x+70,w_y+gps_icon_y+40-mover_y,  w_x+70+100, w_y+45+gps_icon_y-mover_y, tocolor(150, 150, 150, 255-firstAlpha), 1,1, font_small, "left", "center")
						elseif  w_x+70+msg_length[2]+2 < w_x+w_w then
							dxDrawText(msg[2],  w_x+70,w_y+gps_icon_y-mover_y,  w_x+70+100, w_y+40+gps_icon_y-mover_y, tocolor(200,200,200, 255-firstAlpha), 1,1, font, "left", "center")
							elseif  w_x+70+msg_length[3]+2 < w_x+w_w then
							dxDrawText(msg[3],  w_x+70,w_y+gps_icon_y-mover_y,  w_x+70+100, w_y+40+gps_icon_y-mover_y, tocolor(200,200,200, 255-firstAlpha), 1,1, font, "left", "center")
						end
					end
					
					if startPolation > 1 then
						endPolation = (getTickCount() - waypointInterpolation[1] - 750) / 500
					end
					
					if endPolation > 1 then
						waypointInterpolation = false
					end
				end
			end
		end 
	end
end 

local gpsTimer;

setTimer(
    function()
		if gpsLostConnectionEnabled then 
			local x,y,z = getElementPosition(localPlayer)
			if not isLineOfSightClear(x,y,z,x,y,z+50, true, false, false, false, false) then 
				if not lostConnection then 
					if not isTimer(gpsTimer) then 
						gpsTimer = setTimer(
							function()
								lostConnection = true
							end, 5000, 1
						)
					end
				end 
			else 
				lostConnection = false

				if isTimer(gpsTimer) then killTimer(gpsTimer) end
			end 
			--outputChatBox(tostring(lostConnection))
		else 
			lostConnection = false 

			if isTimer(gpsTimer) then killTimer(gpsTimer) end
		end 
    end, 300, 0
)

local playerDetails = {
	["bigmapZoom"] = 0,
	["realbigmapZoom"] = 0,
}

function updatePlayerDetails()
    if not localPlayer:getData("loggedIn") then return end
    
	if playerDetails["bigmapZoom"] ~= bigmapZoom then
        playerDetails["bigmapZoom"] = bigmapZoom
        playerDetails["bigmapZoomAnimation"] = true
        playerDetails["bigmapZoomAnimationTick"] = getTickCount()
	end
end
setTimer(updatePlayerDetails, 150, 0)

function renderTheBigmap()
	if not bigmapIsVisible then return end
	local font = exports['cr_fonts']:getFont("Roboto", 10)
	if hoveredWaypointBlip then
		hoveredWaypointBlip = false
	end
	
	 _, _, playerRotation = getElementRotation(localPlayer)

	local bigmapZoom = bigmapZoom
	if zoomanimation then 
		local nowTick = getTickCount()
		local k = "bigmapZoom"
		if playerDetails[k.."Animation"] then
			local startTick = playerDetails[k.."AnimationTick"]
			local endTick = startTick + 250
			
			local elapsedTime = nowTick - startTick
			local duration = 250
			local progress = elapsedTime / duration
			local alph = interpolateBetween(
				playerDetails["real"..k], 0, 0,
				playerDetails[k], 0, 0,
				progress, "InOutQuad"
			)
			playerDetails["real"..k] = alph
			
			if progress >= 1 then
				playerDetails[k.."Animation"] = false
			end
			--multipler = alph / 100
		end

		bigmapZoom = playerDetails["real"..k]
	end 
		
	local playerDimension = getElementDimension(localPlayer)
    if lostConnection then playerDimension = -1 end
    
	if playerDimension == 0 then
		local zoneName = getZoneName(playerPosX, playerPosY, playerPosZ,false)
		playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)

		cursorX, cursorY = getHudCursorPos()
		if cursorX and cursorY then
			cursorX, cursorY = cursorX * screenW, cursorY * screenH

			
			if getKeyState("mouse1") and cursorX>= bigmapPosX and cursorX<= bigmapPosX+bigmapWidth and cursorY>= bigmapPosY and cursorY<= bigmapPosY+bigmapHeight then
				if not lastCursorPos then
					lastCursorPos = {cursorX, cursorY}
				end
				
				if not mapDifferencePos then
					mapDifferencePos = {0, 0}
				end
				
				if not lastDifferencePos then
					if not mapMovedPos then
						lastDifferencePos = {0, 0}
					else
						lastDifferencePos = {mapMovedPos[1], mapMovedPos[2]}
					end
				end
				
				mapDifferencePos = {mapDifferencePos[1] + cursorX - lastCursorPos[1], mapDifferencePos[2] + cursorY - lastCursorPos[2]}
				
				if not mapMovedPos then
					if math.abs(mapDifferencePos[1]) >= 3 or math.abs(mapDifferencePos[2]) >= 3 then
						mapMovedPos = {lastDifferencePos[1] - mapDifferencePos[1] / bigmapZoom, lastDifferencePos[2] + mapDifferencePos[2] / bigmapZoom}
						mapIsMoving = true
					end
				elseif mapDifferencePos[1] ~= 0 or mapDifferencePos[2] ~= 0 then
					mapMovedPos = {lastDifferencePos[1] - mapDifferencePos[1] / bigmapZoom, lastDifferencePos[2] + mapDifferencePos[2] / bigmapZoom}
					mapIsMoving = true
				end
	
				lastCursorPos = {cursorX, cursorY}
			else
				if mapMovedPos then
					lastDifferencePos = {mapMovedPos[1], mapMovedPos[2]}
				end
				
				lastCursorPos = false
				mapDifferencePos = false
			end
		end
		
		mapPlayerPosX, mapPlayerPosY = lastMapPosX, lastMapPosY
		
		if mapMovedPos then
			mapPlayerPosX = mapPlayerPosX + mapMovedPos[1]
			mapPlayerPosY = mapPlayerPosY + mapMovedPos[2]
		else
			mapPlayerPosX, mapPlayerPosY = playerPosX, playerPosY
			lastMapPosX, lastMapPosY = mapPlayerPosX, mapPlayerPosY
		end
		
		dxDrawImageSection(bigmapPosX, bigmapPosY, bigmapWidth, bigmapHeight, remapTheSecondWay(mapPlayerPosX) - bigmapWidth / bigmapZoom / 2, remapTheFirstWay(mapPlayerPosY) - bigmapHeight / bigmapZoom / 2, bigmapWidth / bigmapZoom, bigmapHeight / bigmapZoom, texture)
		--_dxDrawImage(bigmapPosX, bigmapPosY, bigmapWidth, bigmapHeight, 'assets/images/design/vignetta.png',0,0,0, tocolor(255, 255, 255, 255))
		
		if gpsRouteImage then
			dxUpdateScreenSource(screenSource, true)
			dxSetBlendMode("add")
				dxDrawImage(bigmapCenterX + (remapTheFirstWay(mapPlayerPosX) - (gpsRouteImageData[1] + gpsRouteImageData[3] / 2)) * bigmapZoom - gpsRouteImageData[3] * bigmapZoom / 2, bigmapCenterY - (remapTheFirstWay(mapPlayerPosY) - (gpsRouteImageData[2] + gpsRouteImageData[4] / 2)) * bigmapZoom + gpsRouteImageData[4] * bigmapZoom / 2, gpsRouteImageData[3] * bigmapZoom, -(gpsRouteImageData[4] * bigmapZoom), gpsRouteImage, 180, 0, 0, tocolor(255, 212, 5))
			dxSetBlendMode("blend")
			dxDrawImageSection(0, 0, bigmapPosX, screenH, 0, 0, bigmapPosX, screenH, screenSource)
			dxDrawImageSection(screenW - bigmapPosX, 0, bigmapPosX, screenH, screenW - bigmapPosX, 0, bigmapPosX, screenH, screenSource)
			dxDrawImageSection(bigmapPosX, 0, screenW - 2 * bigmapPosX, bigmapPosY, bigmapPosX, 0, screenW - 2 * bigmapPosX, bigmapPosY, screenSource)
			dxDrawImageSection(bigmapPosX, screenH - bigmapPosY, screenW - 2 * bigmapPosX, bigmapPosY, bigmapPosX, screenH - bigmapPosY, screenW - 2 * bigmapPosX, bigmapPosY, screenSource)
		end
			
		hover = nil

		dxDrawOuterBorder(bigmapPosX, bigmapPosY, bigmapWidth, bigmapHeight, 4, tocolor(51, 51, 51, 255))
		_dxDrawImage(bigmapPosX + bigmapWidth - 176, bigmapPosY + bigmapHeight - 23, 176, 23, "assets/images/design/footer.png")
		if exports['cr_core']:isInSlot(bigmapPosX + bigmapWidth - 35, bigmapPosY + 10, 25, 15) or blipsMenuState or isblipsMenuAnimation then 
			if exports['cr_core']:isInSlot(bigmapPosX + bigmapWidth - 35, bigmapPosY + 10, 25, 15) then 
				hover = "blips-icon"
			end 

			if blipsMenuState or isblipsMenuAnimation then 
				_dxDrawImage(bigmapPosX + bigmapWidth - 35 + 25/2 - 9/2, bigmapPosY + 10, 9, 15, "assets/images/design/blips-icon-back.png", 0, 0, 0, tocolor(255, 255, 255, 255))
			else 
				_dxDrawImage(bigmapPosX + bigmapWidth - 35, bigmapPosY + 10, 25, 15, "assets/images/design/blips-icon.png", 0, 0, 0, tocolor(255, 255, 255, 255))
			end 
		else 
			_dxDrawImage(bigmapPosX + bigmapWidth - 35, bigmapPosY + 10, 25, 15, "assets/images/design/blips-icon.png", 0, 0, 0, tocolor(255, 255, 255, 255 * 0.6))
		end 

		if exports['cr_core']:isInSlot(bigmapPosX + bigmapWidth - 35, bigmapPosY + 40, 25, 25) or optionMenuState or isoptionMenuAnimation then 
			if exports['cr_core']:isInSlot(bigmapPosX + bigmapWidth - 35, bigmapPosY + 40, 25, 25) then 
				hover = "settings-icon"
			end 

			_dxDrawImage(bigmapPosX + bigmapWidth - 35, bigmapPosY + 40, 25, 25, "assets/images/design/settings-icon.png", 0, 0, 0, tocolor(255, 255, 255, 255))
		else 
			_dxDrawImage(bigmapPosX + bigmapWidth - 35, bigmapPosY + 40, 25, 25, "assets/images/design/settings-icon.png", 0, 0, 0, tocolor(255, 255, 255, 255 * 0.6))
		end 



		if not Map_blips_timer then
			Map_blips_timer = setTimer( calculateBlipRadar, 50, 1) 
		end

		renderBlipRadar()

		
		cursorX, cursorY = getHudCursorPos()
		if cursorX and cursorY then cursorX, cursorY = cursorX * screenW, cursorY * screenH end

		if cursorX and cursorY and cursorX> bigmapPosX and cursorX< bigmapPosX+bigmapWidth and cursorY> bigmapPosY and cursorY< bigmapPosY+bigmapHeight and not hover then
			if getCursorAlpha() ~= 0 then 
				setCursorAlpha(0) 
			end

			if custom_blip_choosed_type == 0 then 	
				dxDrawImage( cursorX-128/2+4, cursorY-128/2-1, 128, 128, "assets/images/design/cross.png")
			else
				local width,height = (12/ (4 - bigmapZoom) + 3) * 2.25,(12 / (4 - bigmapZoom) + 3) * 2.25
				dxDrawImage(cursorX-width/2, cursorY-height/2, width, height, "assets/images/blips/"..custom_blip_choosed[custom_blip_choosed_type]..".png")
			end
		elseif cursorX and cursorY then  
			if getCursorAlpha() == 0 then 
				setCursorAlpha(255) 
			end
		end


		local font_big = exports["cr_fonts"]:getFont("Poppins-Medium",14)
		local font_small = exports["cr_fonts"]:getFont("Poppins-Regular",12)
		local font_awesome = exports["cr_fonts"]:getFont("FontAwesome",10)
		
		if optionMenuState or isoptionMenuAnimation then
			dxDrawRectangle(bigmapPosX+bigmapWidth+4, bigmapPosY-4, 140, 160, tocolor(51, 51, 51, optionMenuAlpha * 0.9))
			dxDrawRectangle(bigmapPosX+bigmapWidth+4, bigmapPosY-4, 140, 30, tocolor(51, 51, 51, optionMenuAlpha * 0.9))
			dxDrawText('Beállítások', bigmapPosX+bigmapWidth+4, bigmapPosY-4, bigmapPosX+bigmapWidth+4+140, bigmapPosY - 4 + 30, tocolor(242, 242, 242, optionMenuAlpha), 1, font_big, "center", "center")

			if thblipstate then
				_dxDrawImage(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5, 12, 12, "assets/images/design/settings-checkbox-active.png", 0, 0, 0, tocolor(255, 255, 255, optionMenuAlpha))
			else 
				_dxDrawImage(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5, 12, 12, "assets/images/design/settings-checkbox-deactive.png", 0, 0, 0, tocolor(255, 255, 255, optionMenuAlpha))
			end 

			if exports['cr_core']:isInSlot(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5, 12, 12) then 
				hover = "thblipstate"
			end 

			dxDrawText("3D Blippek", bigmapPosX+bigmapWidth+4+10+12+10, bigmapPosY-4 + 30 + 5, bigmapPosX+bigmapWidth+4+10+12+10, bigmapPosY-4 + 30 + 5 + 12 + 2, tocolor(242, 242, 242, optionMenuAlpha), 1, font_small, "left", "center")

			if navigatorSound then
				_dxDrawImage(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5 + (8 + 12), 12, 12, "assets/images/design/settings-checkbox-active.png", 0, 0, 0, tocolor(255, 255, 255, optionMenuAlpha))
			else 
				_dxDrawImage(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5 + (8 + 12), 12, 12, "assets/images/design/settings-checkbox-deactive.png", 0, 0, 0, tocolor(255, 255, 255, optionMenuAlpha))
			end 

			if exports['cr_core']:isInSlot(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5 + (8 + 12), 12, 12) then 
				hover = "navigatorSound"
			end 

			dxDrawText("GPS hangok", bigmapPosX+bigmapWidth+4+10+12+10, bigmapPosY-4 + 30 + 5 + (8 + 12), bigmapPosX+bigmapWidth+4+10+12+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + 12 + 2, tocolor(242, 242, 242, optionMenuAlpha), 1, font_small, "left", "center")

			if blipanimation then
				_dxDrawImage(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12), 12, 12, "assets/images/design/settings-checkbox-active.png", 0, 0, 0, tocolor(255, 255, 255, optionMenuAlpha))
			else 
				_dxDrawImage(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12), 12, 12, "assets/images/design/settings-checkbox-deactive.png", 0, 0, 0, tocolor(255, 255, 255, optionMenuAlpha))
			end 

			if exports['cr_core']:isInSlot(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12), 12, 12) then 
				hover = "blipanimation"
			end 

			dxDrawText("Blip animáció", bigmapPosX+bigmapWidth+4+10+12+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12), bigmapPosX+bigmapWidth+4+10+12+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + 12 + 2, tocolor(242, 242, 242, optionMenuAlpha), 1, font_small, "left", "center")

			if zoomanimation then
				_dxDrawImage(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + (8 + 12), 12, 12, "assets/images/design/settings-checkbox-active.png", 0, 0, 0, tocolor(255, 255, 255, optionMenuAlpha))
			else 
				_dxDrawImage(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + (8 + 12), 12, 12, "assets/images/design/settings-checkbox-deactive.png", 0, 0, 0, tocolor(255, 255, 255, optionMenuAlpha))
			end 

			if exports['cr_core']:isInSlot(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + (8 + 12), 12, 12) then 
				hover = "zoomanimation"
			end 

			dxDrawText("Zoom animáció", bigmapPosX+bigmapWidth+4+10+12+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + (8 + 12), bigmapPosX+bigmapWidth+4+10+12+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + (8 + 12) + 12 + 2, tocolor(242, 242, 242, optionMenuAlpha), 1, font_small, "left", "center")

			if gpsLostConnectionEnabled then 
				_dxDrawImage(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + (8 + 12) + (8 + 12), 12, 12, "assets/images/design/settings-checkbox-active.png", 0, 0, 0, tocolor(255, 255, 255, optionMenuAlpha))
			else 
				_dxDrawImage(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + (8 + 12) + (8 + 12), 12, 12, "assets/images/design/settings-checkbox-deactive.png", 0, 0, 0, tocolor(255, 255, 255, optionMenuAlpha))
			end 

			if exports['cr_core']:isInSlot(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + (8 + 12) + (8 + 12), 12, 12) then 
				hover = "gpsLostConnectionEnabled"
			end 

			dxDrawText("GPS realizmus", bigmapPosX+bigmapWidth+4+10+12+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + (8 + 12) + (8 + 12) + (8 + 12), bigmapPosX+bigmapWidth+4+10+12+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + (8 + 12) + 12 + 2, tocolor(242, 242, 242, optionMenuAlpha), 1, font_small, "left", "center")

			if radarRotation then 
				_dxDrawImage(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + (8 + 12) + (8 + 12) + (8 + 12), 12, 12, "assets/images/design/settings-checkbox-active.png", 0, 0, 0, tocolor(255, 255, 255, optionMenuAlpha))
			else 
				_dxDrawImage(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + (8 + 12) + (8 + 12) + (8 + 12), 12, 12, "assets/images/design/settings-checkbox-deactive.png", 0, 0, 0, tocolor(255, 255, 255, optionMenuAlpha))
			end 

			if exports['cr_core']:isInSlot(bigmapPosX+bigmapWidth+4+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + (8 + 12) + (8 + 12) + (8 + 12), 12, 12) then 
				hover = "radarRotation"
			end 

			dxDrawText("Radar forgatás", bigmapPosX+bigmapWidth+4+10+12+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + (8 + 12) + (8 + 12) + (8 + 12) + (8 + 12) + (8 + 12), bigmapPosX+bigmapWidth+4+10+12+10, bigmapPosY-4 + 30 + 5 + (8 + 12) + (8 + 12) + (8 + 12) + 12 + 2, tocolor(242, 242, 242, optionMenuAlpha), 1, font_small, "left", "center")
		end

		if blipsMenuState or isblipsMenuAnimation then
			dxDrawRectangle(bigmapPosX+bigmapWidth+4, bigmapPosY-4, 150, bigmapHeight + 8, tocolor(51, 51, 51, blipsMenuAlpha * 0.9))

			local startY = bigmapPosY - 4 + 9 

			for i = blipsMinLines, blipsMaxLines do
				if blipsData[i] then
					local v = blipsData[i]

					local blipImage, blipName, color = unpack(v)

					local r,g,b = unpack(color)

					dxDrawImage(bigmapPosX+bigmapWidth+4+10, startY, 23, 23, "assets/images/blips/" .. blipImage .. ".png", 0, 0, 0, tocolor(r,g,b,blipsMenuAlpha))

					dxDrawText(blipName, bigmapPosX+bigmapWidth+4+10+23+10, startY, bigmapPosX+bigmapWidth+4+10+23+10, startY + 23, tocolor(242, 242, 242, blipsMenuAlpha), 1, font_small, "left", "center")

					startY = startY + 23 + 4
				end 
			end 

			local percent = #blipsData
			
			if percent >= 1  then
				local gW, gH = 5, bigmapHeight + 8
				local gX, gY = bigmapPosX+bigmapWidth+4+150 - gW, bigmapPosY-4
				_sX, _sY, _sW, _sH = gX, gY, gW, gH
				
				if blipsScrolling then
					if isCursorShowing() then
						if getKeyState("mouse1") then
							local cx, cy = exports['cr_core']:getCursorPosition()
							local cy = math.min(math.max(cy, _sY), _sY + _sH)
							local y = (cy - _sY) / (_sH)
							local num = percent * y
							blipsMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _blipsMaxLines) + 1)))
							blipsMaxLines = blipsMinLines + (_blipsMaxLines - 1)
						end
					else
						blipsScrolling = false
					end
				end
				
				dxDrawRectangle(gX,gY,gW,gH, tocolor(242,242,242,blipsMenuAlpha * 0.6))

				local multiplier = math.min(math.max((blipsMaxLines - (blipsMinLines - 1)) / percent, 0), 1)
				local multiplier2 = math.min(math.max((blipsMinLines - 1) / percent, 0), 1)
				local gY = gY + ((gH) * multiplier2)
				local gH = gH * multiplier
				dxDrawRectangle(gX, gY, gW, gH, tocolor(51,51,51, blipsMenuAlpha))
			end
		end 

		--[[
		if mapMovedPos then
			if isCursorShowing() then 
				local zoneX = reMap((cursorX - bigmapPosX) / bigmapZoom + (remapTheSecondWay(mapPlayerPosX) - bigmapWidth / bigmapZoom / 2), 0, mapTextureSize, -3000, 3000)
				local zoneY = reMap((cursorY - bigmapPosY) / bigmapZoom + (remapTheFirstWay(mapPlayerPosY) - bigmapHeight / bigmapZoom / 2), 0, mapTextureSize, 3000, -3000)
				local movedpos_zoneName = getZoneName(zoneX, zoneY, 0,false)
				dxDrawText(zoneName, bigmapPosX + 10, bigmapPosY + bigmapHeight, bigmapPosX + bigmapWidth, bigmapPosY + bigmapHeight+zoneLineHeight, tocolor(200,200,200,230), 1, font_big, "left", "center")
				dxDrawText("A visszaállításhoz nyomd meg a #3d7abcSpace #c0c0c0billentyűt.", bigmapPosX, bigmapPosY + bigmapHeight, bigmapPosX + bigmapWidth, bigmapPosY + bigmapHeight + zoneLineHeight, tocolor(200,200,200,230), 1, font_big, "center", "center", false, false, false, true)
				if getKeyState("space") then
					mapMovedPos = false
					lastDifferencePos = false
					setCursorPosition(screenW/2,screenH/2)
				end
			end 
		else
			dxDrawText(zoneName, bigmapPosX + 10, bigmapPosY + bigmapHeight, bigmapPosX + bigmapWidth, bigmapPosY + bigmapHeight+zoneLineHeight, tocolor(200,200,200,230), 1, font_big, "left", "center")
		end]]
	else
		local bigmapHeight = bigmapHeight + zoneLineHeight
		dxDrawOuterBorder(bigmapPosX, bigmapPosY, bigmapWidth, bigmapHeight, 4, tocolor(51, 51, 51, 255))
        dxDrawRectangle(bigmapPosX, bigmapPosY, bigmapWidth, bigmapHeight, tocolor(20, 20, 20, 255))

		local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, getTickCount() / 5000, "SineCurve")
        bigmapCenterX = bigmapPosX + bigmapWidth / 2
        bigmapCenterY = bigmapPosY + bigmapHeight / 2
        
        local startX, startY = bigmapPosX + 15, bigmapPosY + 15
        local _startX, _startY = startX, startY
        local between1, between2 = 25, 25
        local columns = math.floor((bigmapWidth - 15) / between1)
        local lines = math.floor((bigmapHeight - 15) / between2)
        local nowColumn = 1
        local nowLine = 1
        
        for i = 1, columns * lines do 
            dxDrawRectangle(startX, startY, 2, 2, tocolor(6, 6, 6, 255))
            startX = startX + between1
            
            nowColumn = nowColumn + 1
            if nowColumn > columns then
                nowColumn = 1
                nowLine = nowLine + 1
                startX = _startX
                startY = startY + between2
            end
        end
        
        local between1, between2 = 5, 5
        local columns = math.floor((bigmapWidth - 15) / between1)
        local lines = math.floor((bigmapHeight - 15) / between2)
        
        local columns = math.max(2, math.floor(columns * 0.1))
        if columns % 2 == 1 then
            columns = columns + 1
        end
        for i = 1, columns do
            if i % 2 == 1 then
                --outputChatBox("asd")
                local x = interpolateBetween(0, 0, 0, bigmapWidth, 0, 0, getTickCount() / (20000 * (i / columns)), "SineCurve")
                dxDrawRectangle(bigmapPosX + x, bigmapPosY, 2, bigmapHeight, tocolor(6, 6, 6, 255))
            else
                --outputChatBox("asd2")
                local x = interpolateBetween(2, 0, 0, bigmapWidth, 0, 0, getTickCount() / (20000 * (i / columns)), "SineCurve")
                dxDrawRectangle((bigmapPosX + bigmapWidth) - x, bigmapPosY, 2, bigmapHeight, tocolor(6, 6, 6, 255))
            end
        end
        
        local lines = math.max(2, math.floor(lines * 0.1))
        if lines % 2 == 1 then
            lines = lines + 1
        end
        for i = 1, lines do
            if i % 2 == 1 then
                local y = interpolateBetween(0, 0, 0, bigmapHeight, 0, 0, getTickCount() / (20000 * (i / lines)), "SineCurve")
                dxDrawRectangle(bigmapPosX, bigmapPosY + y, bigmapWidth, 2, tocolor(6, 6, 6, 255))
            else
                local y = interpolateBetween(2, 0, 0, bigmapHeight, 0, 0, getTickCount() / (20000 * (i / lines)), "SineCurve")
                dxDrawRectangle(bigmapPosX, (bigmapPosY + bigmapHeight) - y, bigmapWidth, 2, tocolor(6, 6, 6, 255))
            end
        end
        
        local r,g,b = exports['cr_core']:getServerColor("red")
        local font = exports['cr_fonts']:getFont("Poppins-SemiBold", 13)
		local startY = -(62/2 + dxGetFontHeight(1, font)/2)
        dxDrawImage(bigmapCenterX - 54/2, bigmapCenterY + startY, 54, 62, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
        startY = startY + 62 + 5 + dxGetFontHeight(1, font)/2
        dxDrawText("LOST CONNECTION...", bigmapCenterX, bigmapCenterY + startY, bigmapCenterX, bigmapCenterY + startY, tocolor(r, g, b, alpha), 1, font, "center", "center")
	end
end

--[[
addEventHandler( "onClientResourceStart", resourceRoot, function()
	--addEventHandler( "onClientRender", root, renderWidget.minimap )
    if minimapIsVisible then
        createRender(renderWidget.minimap, "renderWidget.minimap")
    else
        destroyRender("renderWidget.minimap")    
    end
end)

addEventHandler( "onClientResourceStart", resourceRoot, function()
	--addEventHandler( "onClientRender", root, renderTheBigmap )
    createRender(renderTheBigmap, "renderTheBigmap")
end)]]

addEventHandler("onClientKey", getRootElement(),
	function (key, pressDown)
		if key == "radar" then 
			setPlayerHudComponentVisible("radar", false)
            cancelEvent()
		end
		if key == "F11" and pressDown then
			cancelEvent()
			if not localPlayer:getData("loggedIn") then 
				return 
			end 
			if localPlayer:getData("keysDenied") and not bigmapIsVisible then 
				return 
			end 
            custom_blip_choosed_type = 0
            bigmapIsVisible = not bigmapIsVisible
			if not bigmapIsVisible then 
				if getCursorAlpha() ~= 255 then 
					setCursorAlpha(255) 
				end
			end 
			minimapIsVisible = not bigmapIsVisible
			gpsIsVisible = not bigmapIsVisible
			blipsScrolling = false
            --showChat( minimapIsVisible )
            --setElementData(localPlayer, "keysDenied", bigmapIsVisible)
            setElementData(localPlayer, "bigmapIsVisible", bigmapIsVisible, false)
            if bigmapIsVisible then
                hudVisible_ostate = getElementData( localPlayer, "hudVisible")
                keys_denied_ostate = getElementData( localPlayer, "keysDenied")
                chat_ostate = exports['cr_custom-chat']:isChatVisible()
                setElementData( localPlayer,"hudVisible",false)
                setElementData( localPlayer, "keysDenied", true)
                exports['cr_custom-chat']:showChat(false)
            else
                setElementData( localPlayer,"hudVisible",hudVisible_ostate)
                setElementData( localPlayer, "keysDenied",keys_denied_ostate)
                exports['cr_custom-chat']:showChat(chat_ostate)
            end

            if not getElementData(localPlayer,"hudVisible") and  minimapIsVisible then 
				minimapIsVisible = false 
				gpsIsVisible = false
            end 
            
            if bigmapIsVisible then
                createRender("renderTheBigmap", renderTheBigmap)
            else
                destroyRender("renderTheBigmap")    
            end

            if minimapIsVisible then
                createRender("renderWidget.minimap", renderWidget.minimap)
            else
                destroyRender("renderWidget.minimap")    
			end
			
			if gpsIsVisible then 
				createRender("drawnGPS", drawnGPS)
			else 
				destroyRender("drawnGPS")
			end 

            mapMovedPos = false
            lastDifferencePos = false
            bigmapZoom = 1
		elseif key == "mouse_wheel_up" then
			if pressDown then
				if exports['cr_core']:isInSlot(bigmapPosX, bigmapPosY, bigmapWidth, bigmapHeight) and bigmapIsVisible and bigmapZoom + 0.1 <= 2.1 then
					bigmapZoom = bigmapZoom + 0.1
				end

				if blipsMenuState then 
					if exports['cr_core']:isInSlot(bigmapPosX+bigmapWidth+4, bigmapPosY-4, 150, bigmapHeight + 8) then 
						if blipsMinLines - 1 >= 1 then
							playSound(":cr_scorebaord/files/wheel.wav")
							blipsMinLines = blipsMinLines - 1
							blipsMaxLines = blipsMaxLines - 1
						end
					end 
				end 
			end
		elseif key == "mouse_wheel_down" then
			if pressDown then
				if exports['cr_core']:isInSlot(bigmapPosX, bigmapPosY, bigmapWidth, bigmapHeight) and bigmapIsVisible and bigmapZoom - 0.1 >= 0.1 then
					bigmapZoom = bigmapZoom - 0.1
				end

				if blipsMenuState then 
					if exports['cr_core']:isInSlot(bigmapPosX+bigmapWidth+4, bigmapPosY-4, 150, bigmapHeight + 8) then 
						if blipsMaxLines + 1 <= #blipsData then
							playSound("files/wheel.wav")
							blipsMinLines = blipsMinLines + 1
							blipsMaxLines = blipsMaxLines + 1
						end
					end 
				end 
			end		
		end
	end
)

function optionMenuAnimation()
	local progress = 0
	if not optionMenuState then
		progress,difference,_ = animcore(optionMenuAnimationStart,500,0,0,0,1,140,0,"Linear")
		bigmapWidth = bigmapWidthRoot-difference
		bigmapCenterX = bigmapPosX + bigmapWidth / 2
	else
		progress,optionMenuAlpha,_ = animcore(optionMenuAnimationStart,140,0,255,0,1,0,0,"Linear")
	end
	if progress >=1 then
	   removeEventHandler("onClientRender",root,optionMenuAnimation) 
        --destroyRender("optionMenuAnimationSecond")
	   optionMenuAnimationStart = getTickCount()
	   addEventHandler( "onClientRender", root, optionMenuAnimationSecond)
        --createRender("optionMenuAnimationSecond", optionMenuAnimationSecond)
	end
end

function optionMenuAnimationSecond()
	local progress = 0
	if not optionMenuState then
		progress,optionMenuAlpha,_ = animcore(optionMenuAnimationStart,140,0,0,0,1,255,0,"Linear")
	else
		progress,difference,_ = animcore(optionMenuAnimationStart,500,0,140,0,1,0,0,"Linear")
		bigmapWidth = bigmapWidthRoot-difference
		bigmapCenterX = bigmapPosX + bigmapWidth / 2
	end
	if progress >=1 then
		 removeEventHandler("onClientRender",root,optionMenuAnimationSecond)
     	--   destroyRender("optionMenuAnimationSecond")
	 	isoptionMenuAnimation = false
	 	optionMenuState = not optionMenuState
	end
end

function blipsMenuAnimation()
	local progress = 0
	if not blipsMenuState then
		progress,difference,_ = animcore(blipsMenuAnimationStart,500,0,0,0,1,150,0,"Linear")
		bigmapWidth = bigmapWidthRoot-difference
		bigmapCenterX = bigmapPosX + bigmapWidth / 2
	else
		progress,blipsMenuAlpha,_ = animcore(blipsMenuAnimationStart,150,0,255,0,1,0,0,"Linear")
	end
	if progress >=1 then
	   removeEventHandler("onClientRender",root,blipsMenuAnimation) 
        --destroyRender("blipsMenuAnimationSecond")
	   blipsMenuAnimationStart = getTickCount()
	   addEventHandler( "onClientRender", root, blipsMenuAnimationSecond)
        --createRender("blipsMenuAnimationSecond", blipsMenuAnimationSecond)
	end
end

function blipsMenuAnimationSecond()
	local progress = 0
	if not blipsMenuState then
		progress,blipsMenuAlpha,_ = animcore(blipsMenuAnimationStart,150,0,0,0,1,255,0,"Linear")
	else
		progress,difference,_ = animcore(blipsMenuAnimationStart,500,0,150,0,1,0,0,"Linear")
		bigmapWidth = bigmapWidthRoot-difference
		bigmapCenterX = bigmapPosX + bigmapWidth / 2
	end
	if progress >=1 then
		 removeEventHandler("onClientRender",root,blipsMenuAnimationSecond)
     	--   destroyRender("blipsMenuAnimationSecond")
	 	isblipsMenuAnimation = false
	 	blipsMenuState = not blipsMenuState
	end
end

addEventHandler("onClientClick", getRootElement(),
	function (button, state, cursorX, cursorY)
			
	if getElementDimension( localPlayer ) ~= 0 then return end

		if state == "up" and mapIsMoving then
			mapIsMoving = false
			return
		end
		
		local gpsRouteProcess = false
		
		if button == "left" and state == "up" then
			if bigmapIsVisible and occupiedVehicle and carCanGPS() then
				if not getPedOccupiedVehicleSeat( localPlayer ) == 0 and  not getPedOccupiedVehicleSeat( localPlayer ) == 1 then return end
				if getElementData(occupiedVehicle, "gpsDestination") then
					setElementData(occupiedVehicle, "gpsDestination", false)
				elseif cursorX > bigmapPosX and cursorX<bigmapPosX+bigmapWidth and cursorY>bigmapPosY and cursorY<bigmapPosY+bigmapHeight then
					setElementData(occupiedVehicle, "gpsDestination", {
						reMap((cursorX - bigmapPosX) / bigmapZoom + (remapTheSecondWay(mapPlayerPosX) - bigmapWidth / bigmapZoom / 2), 0, mapTextureSize, -3000, 3000),
						reMap((cursorY - bigmapPosY) / bigmapZoom + (remapTheFirstWay(mapPlayerPosY) - bigmapHeight / bigmapZoom / 2), 0, mapTextureSize, 3000, -3000)
					})
				end
				gpsRouteProcess = true
			end
		end
		
		if bigmapIsVisible then
			if button == "right" and state == "down" and custom_blip_choosed_type ~= 0 then
				if hovered_blip then
					deleteOwnBlip(hovered_blip)
				else
					local blipPosX = reMap((cursorX - bigmapPosX) / bigmapZoom + (remapTheSecondWay(mapPlayerPosX) - bigmapWidth / bigmapZoom / 2), 0, mapTextureSize, -3000, 3000)
					local blipPosY = reMap((cursorY - bigmapPosY) / bigmapZoom + (remapTheFirstWay(mapPlayerPosY) - bigmapHeight / bigmapZoom / 2), 0, mapTextureSize, 3000, -3000)
					createOwnBlip(custom_blip_choosed[custom_blip_choosed_type],blipPosX,blipPosY)
					
				end
			elseif button == "middle" and state == "down" then
				if custom_blip_choosed_type < #custom_blip_choosed then custom_blip_choosed_type = custom_blip_choosed_type +1 
				else custom_blip_choosed_type = 0 end
			elseif button == "left" and state == "down" and blipsMenuState and _sX and exports['cr_core']:isInSlot(_sX, _sY, _sW, _sH) then
				blipsScrolling = true
			elseif button == "left" and state == "up" then
				if blipsScrolling then
					blipsScrolling = false
				end
			elseif button == "left" and state == "down" and not isoptionMenuAnimation and not isblipsMenuAnimation and not blipsMenuState and hover == "settings-icon" then
				addEventHandler( "onClientRender",root,optionMenuAnimation)
                --createRender("optionMenuAnimationSecond", optionMenuAnimationSecond)
				optionMenuAnimationStart = getTickCount()
				isoptionMenuAnimation = true

				hover = nil
			elseif button == "left" and state == "down" and not isblipsMenuAnimation and not isoptionMenuAnimation and not optionMenuState and hover == "blips-icon" then
				addEventHandler( "onClientRender",root,blipsMenuAnimation)
                --createRender("blipsMenuAnimationSecond", blipsMenuAnimationSecond)
				blipsMenuAnimationStart = getTickCount()
				isblipsMenuAnimation = true

				hover = nil
			elseif button == "left" and state == "down" and not isoptionMenuAnimation and optionMenuState and hover == "thblipstate" then
				thblipstate = not thblipstate
				toggle3DBlip(thblipstate)

				hover = nil
			elseif button == "left" and state == "down" and not isoptionMenuAnimation and optionMenuState and hover == "navigatorSound" then
				navigatorSound = not navigatorSound

				hover = nil
			elseif button == "left" and state == "down" and not isoptionMenuAnimation and optionMenuState and hover == "blipanimation" then
				blipanimation = not blipanimation

				hover = nil
			elseif button == "left" and state == "down" and not isoptionMenuAnimation and optionMenuState and hover == "zoomanimation" then
				zoomanimation = not zoomanimation

				hover = nil
			elseif button == "left" and state == "down" and not isoptionMenuAnimation and optionMenuState and hover == "gpsLostConnectionEnabled" then
				gpsLostConnectionEnabled = not gpsLostConnectionEnabled

				hover = nil
			elseif button == "left" and state == "down" and not isoptionMenuAnimation and optionMenuState and hover == "radarRotation" then
				radarRotation = not radarRotation

				hover = nil
			end		
		end
	end
)

function setGPSDestination(world_x,world_y)
	if occupiedVehicle and carCanGPS() then
		setElementData(occupiedVehicle, "gpsDestination", nil)
		setElementData(occupiedVehicle, "gpsDestination", {world_x,world_y})
	end
end


addEventHandler("onClientRestore", getRootElement(),
	function ()
		if gpsRoute then
			processGPSLines()
		end
	end
)


function calculateBlip()
	Map_blips = {}
	for k,value in pairs(radarBlips) do
		if isElement(value[2]) then 
			local blip_x,blip_y,_ = getElementPosition(value[2])
			local blip_dis = getDistanceBetweenPoints2D(playerPosX, playerPosY, blip_x, blip_y)
			blip_dis = blip_dis/mapRatio*minimapZoom
			local dx_distance = diagonal*1.2
		
			if blip_dis < dx_distance or value[3]== 1 then 
				Map_blips[k] = value
				Map_blips[k]["blip_x"] = blip_x
				Map_blips[k]["blip_y"] = blip_y
				Map_blips[k]["blip_dis"] = blip_dis
				Map_blips[k]["blip_alpha"] = (1-((blip_dis-diagonal)/(diagonal*0.2)))*255
			else
				Map_blips[k] = nil
			end
		else 
			radarBlips[k] = nil 
		end 
    end
	Map_blips_timer = nil
end


function renderBlipContinue(value)
	local width,height,blip_dis = (value[5]/ (4 - minimapZoom) + 3) * 2.25,(value[6] / (4 - minimapZoom) + 3) * 2.25, value["blip_dis"]
	local map_x,map_y = value["blip_x"], value["blip_y"]

	if radarRotation then 
		local rotation = findRotation(map_x, map_y,playerPosX, playerPosY) - cameraRotation - 180
        map_x, map_y = getPointFromDistanceRotation(w_x+minimapWidth/2, w_y+minimapHeight/2, blip_dis, rotation)
	else 
		map_x = minimapCenterX + (remapTheFirstWay(playerPosX) - remapTheFirstWay(map_x)) * minimapZoom
		map_y = minimapCenterY - (remapTheFirstWay(playerPosY) - remapTheFirstWay(map_y)) * minimapZoom
	end 

	local blip_x = math.max(minimapPosX,math.min(minimapPosX + minimapWidth,map_x))
	local blip_y = math.max(minimapPosY,math.min(minimapPosY + minimapHeight,map_y))

	local blip_alpha = 255
	if not blipanimation then 
		if blip_x < w_x-10 or blip_x > w_x+minimapWidth+10 or blip_y < w_y-10 or blip_y > w_y+minimapHeight+10 then 
			return 
		end
	else	
		blip_x,blip_y = math.max(w_x + width/2, math.min(w_x+minimapWidth-width/2,blip_x)),math.max(w_y + 22 + (height /2), math.min(w_y+minimapHeight-height/2, blip_y))	   
		
		if blip_dis > diagonal and value[3] ~= 1 then
			blip_alpha = math.max(0,math.min(255,value["blip_alpha"]))
		end
	end
	
	dxDrawImage(blip_x - width/2, blip_y - height/2, width, height, "assets/images/blips/" .. value[4]..".png",0,0,0,tocolor(value[7],value[8],value[9], blip_alpha)) 
end


function renderBlip()
	for k , value in pairs(Map_blips) do
       renderBlipContinue(value)
	end
end

function calculateBlipRadar()
	 Map_blips_radar = {}
	for k,value in pairs(radarBlips) do
	 	local blip_x,blip_y,_ = getElementPosition(value[2])
        Map_blips_radar[k] = value
        Map_blips_radar[k]["blip_x"] = blip_x
        Map_blips_radar[k]["blip_y"] = blip_y
    end
    Map_blips_radar["player"] = {"",localPlayer,0,"arrow",32,32,255,255,255} 
    local blip_x,blip_y,_ = getElementPosition(localPlayer)
    Map_blips_radar["player"]["blip_x"] = blip_x
    Map_blips_radar["player"]["blip_y"] = blip_y
	Map_blips_timer = nil
end



function renderBlipRadar()
	local k = "bigmapZoom"
	local bigmapZoom = bigmapZoom
	if zoomanimation then 
		bigmapZoom = playerDetails["real"..k]
	end 

	local blip_hoover = nil
	for k , value in pairs(Map_blips_radar) do
		width,height = (value[5]/ (4 - bigmapZoom) + 3) * 2.25,(value[6] / (4 - bigmapZoom) + 3) * 2.25
		local map_x,map_y =  Map_blips_radar[k]["blip_x"], Map_blips_radar[k]["blip_y"]
		map_x =  bigmapCenterX + (remapTheFirstWay(mapPlayerPosX) - remapTheFirstWay(map_x)) * bigmapZoom
		map_y =  bigmapCenterY - (remapTheFirstWay(mapPlayerPosY) - remapTheFirstWay(map_y)) * bigmapZoom
		if evisible == 0 then
			if map_x > bigmapPosX + bigmapWidth or map_y > bigmapCenterY + bigmapHeight then 
				return			
			elseif map_x < bigmapPosX or map_y < bigmapCenterY then
				return
			end 
		end
		local blip_x = math.max(bigmapPosX,math.min(bigmapPosX + bigmapWidth,map_x))
		local blip_y =  math.max(bigmapPosX,math.min(bigmapPosY + bigmapHeight,map_y))
		
		if value[4] == "arrow" then
			dxDrawImage(blip_x - width/2, blip_y - height/2, width, height, "assets/images/blips/arrow.png", math.abs(360 - playerRotation))
		else
			dxDrawImage(blip_x - width/2, blip_y - height/2, width, height, "assets/images/blips/" .. value[4]..".png",0,0,0,tocolor(value[7],value[8],value[9])) 
		end

		local cursorX,cursorY = getCursorPosition()
		if cursorX and cursorY then
			cursorX,cursorY = cursorX*screenW,cursorY*screenH  
		else
			cursorX,cursorY = -10,-10
		end


		if cursorX > blip_x - width/2 and cursorX < blip_x - width/2+width and cursorY >  blip_y - height/2 and cursorY <  blip_y - height/2+height and value[1] ~= "" then
			local font = exports['cr_fonts']:getFont("Roboto", 10)
			local text_width = dxGetTextWidth(value[1],1,font)
			blip_hoover = value[1]
			dxDrawRectangle(blip_x-text_width/2-3,blip_y + height/2+1,text_width+6,18,tocolor(55,55,55))
			dxDrawRoundedRectangle(blip_x -text_width/2-4,blip_y + height/2,text_width+8,20,tocolor(55,55,55),tocolor(55,55,55))
			dxDrawText( value[1],blip_x-text_width/2-4, blip_y + height/2+5,blip_x -text_width/2-4+text_width+8,blip_y - height/2+height+18, tocolor(200,200,200),1,font,"center","center")
		end	

	end
	if blip_hoover then hovered_blip = blip_hoover
	else hovered_blip = nil end
end



function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle) 
    local dx = math.cos(a) * dist
    local dy = math.sin(a) * dist 
    return x+dx, y+dy
end

function remapTheFirstWay(coord)
	return (-coord + 3000) / mapRatio
end

function remapTheSecondWay(coord)
	return (coord + 3000) / mapRatio
end

function carCanGPS()
	carCanGPSVal = tonumber((occupiedVehicle:getData("veh >> tuningData") or {})["gps"] or 0) == 1
	return carCanGPSVal
end

function addGPSLine(x, y)
	table.insert(gpsLines, {remapTheFirstWay(x), remapTheFirstWay(y)})
end

function processGPSLines()
	local routeStartPosX, routeStartPosY = 99999, 99999
	local routeEndPosX, routeEndPosY = -99999, -99999
	
	for i = 1, #gpsLines do
		if gpsLines[i][1] < routeStartPosX then
			routeStartPosX = gpsLines[i][1]
		end
		
		if gpsLines[i][2] < routeStartPosY then
			routeStartPosY = gpsLines[i][2]
		end
		
		if gpsLines[i][1] > routeEndPosX then
			routeEndPosX = gpsLines[i][1]
		end
		
		if gpsLines[i][2] > routeEndPosY then
			routeEndPosY = gpsLines[i][2]
		end
	end
	
	local routeWidth = (routeEndPosX - routeStartPosX) + 16
	local routeHeight = (routeEndPosY - routeStartPosY) + 16
	
	if isElement(gpsRouteImage) then
		destroyElement(gpsRouteImage)
	end
	
	gpsRouteImage = dxCreateRenderTarget(routeWidth, routeHeight, true)
	gpsRouteImageData = {routeStartPosX - 8, routeStartPosY - 8, routeWidth, routeHeight}
	
	dxSetRenderTarget(gpsRouteImage)
	dxSetBlendMode("modulate_add")
	
	--dxDrawImage(gpsLines[1][1] - routeStartPosX + 8 - 4, gpsLines[1][2] - routeStartPosY + 8 - 4, 8, 8, "gps/images/dot.png")
	
	for i = 2, #gpsLines do
		if gpsLines[i - 1] then
			local startX = gpsLines[i][1] - routeStartPosX + 8
			local startY = gpsLines[i][2] - routeStartPosY + 8
			local endX = gpsLines[i - 1][1] - routeStartPosX + 8
			local endY = gpsLines[i - 1][2] - routeStartPosY + 8
			
			--dxDrawImage(startX - 4, startY - 4, 8, 8, "gps/images/dot.png")

			dxDrawLine(startX, startY, endX, endY, tocolor(255, 255, 255), 9)
		end
	end
	
	dxSetBlendMode("blend")
	dxSetRenderTarget()
end

function clearGPSRoute()
	gpsLines = {}
	
	if isElement(gpsRouteImage) then
		destroyElement(gpsRouteImage)
	end
	gpsRouteImage = false
end

addEventHandler( "onClientVehicleEnter", root, function(player) 
	if player == localPlayer then
		occupiedVehicle = source
	end	
end)


function getVehicleSpeed(vehicle)
	local velocityX, velocityY, velocityZ = getElementVelocity(vehicle)
	return ((velocityX * velocityX + velocityY * velocityY + velocityZ * velocityZ) ^ 0.5) * 187.5
end


function dxDrawRoundedRectangle(left, top, width, height, color, color2)
	if not postgui then
		postgui = false;
	end

	left, top = left + 2, top + 2;
	width, height = width - 4, height - 4;
    dxDrawRectangle(left - 2, top, 2, height, color2, postgui);
	dxDrawRectangle(left + width, top, 2, height, color2, postgui);
	dxDrawRectangle(left, top - 2, width, 2, color2, postgui);
	dxDrawRectangle(left, top + height, width, 2, color2, postgui);

	dxDrawRectangle(left - 1, top - 1, 1, 1, color2, postgui);
	dxDrawRectangle(left + width, top - 1, 1, 1, color2, postgui);
	dxDrawRectangle(left - 1, top + height, 1, 1, color2, postgui);
	dxDrawRectangle(left + width, top + height, 1, 1, color2, postgui)
end

function dxDrawOuterBorder(x, y, w, h, borderSize, borderColor, postGUI)
	borderSize = borderSize or 2
	borderColor = borderColor or tocolor(51, 51, 51, 255)
	
	dxDrawRectangle(x - borderSize, y - borderSize, w + (borderSize * 2), borderSize, borderColor, postGUI)
	dxDrawRectangle(x, y + h, w, borderSize, borderColor, postGUI)
	dxDrawRectangle(x - borderSize, y, borderSize, h + borderSize, borderColor, postGUI)
	dxDrawRectangle(x + w, y, borderSize, h + borderSize, borderColor, postGUI)
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function inArea(x,y,w,h)
	if isCursorShowing() then
		local aX,aY = getCursorPosition()
		aX,aY = aX*screenW,aY*screenH
		if aX > x and aX < x+w and aY>y and aY<y+h then return true
		else return false end
	else return false end
end


function inText(x1,y1,x2,y2)
	if isCursorShowing() then
		local aX,aY = getCursorPosition()
		aX,aY = aX*screenW,aY*screenH
		if aX > x1 and aX < x2 and aY>y1 and aY<y2 then return true
		else return false end
	else return false end
end

addEventHandler( "onClientResourceStop",resourceRoot,function()
	--[[save_data = {
		["3D"] = thblipstate,
		["Sounds"] = navigatorSound,
		["Animation"] = blipanimation,
	}
	--jsonSave()]]
    if bigmapIsVisible then
        setElementData( localPlayer, "hudVisible",hudVisible_ostate)
        setElementData( localPlayer, "keysDenied",keys_denied_ostate)
    end
end)


function animcore(mstart,duration,sn1,sn2,sn3,fn1,fn2,fn3,animtype)
	local now = getTickCount()
	local elapsedTime = now - mstart
	local progress = elapsedTime / duration
	local num1, num2, num3 = interpolateBetween ( sn1, sn2, sn3, fn1, fn2, fn3, progress, ""..tostring(animtype).."")
	return num1, num2,num3
end
