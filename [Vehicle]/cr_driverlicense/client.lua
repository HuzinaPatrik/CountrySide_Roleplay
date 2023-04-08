local anims, builtins = {}, {"Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve"}
local sx,sy = guiGetScreenSize()
local scriptVersion = "0.1"
local showdPanel = false
local clickedNpc = false
local page = "unknow"
local selectedActor = nil
local shopType = nil
local buttons = {}
local bSAnim = {}
local alpha = 0
local closed = false
local activeTestID = 0
local isTestID = 1
local testEnd = {0,0}
local categoryID = nil
local categoryModel = nil
setElementData(localPlayer,"char.routin",false)
local positionPed = {0.0,0.0,0.0}
local pedVoiceTimer = nil

function clickDriving(button,state,absoluteX,absoluteY,worldX,worldY,worldZ,clickedElement)
	if (clickedElement) and not(showdPanel) then
		if not(state == "down") then return end
		if (showdPanel) then return end
		if not(button == "right") then return end
		local eType = getElementData(clickedElement,"ped.driveLicense") or false
		if (eType) then
			showCategoryList(clickedElement)
		end
	elseif (showdPanel) then
		if (page == "category") and (button == "left") and (state == "down") then
			if not(alpha == 255) then return end

			if exports['cr_core']:isInSlot(left + width - 10 - 15, top + 10, 15, 15) then 
				closeDrivingCategoryList()
				return 
			end 

			if buttonHover then 
				clickCategoryButton(buttonHover)

				buttonHover = nil 
				return 
			end 

			return
		end

		if (page == "test") and (button == "left") and (state == "down") then
			if not(alpha == 255) then return end
			if buttonHover then 
				activeTestID = tonumber(buttonHover)
				buttonHover = nil 

				createAnimate(255,0,4,400,
					function(value) 
						alpha = value 
					end,

					function()
						setTimer(function()
							if (licenseReason[isTestID][5] == activeTestID) then
								--SUCCESs
								testEnd[2] = testEnd[2] + 1
							else
								--ERROR
								testEnd[1] = testEnd[1] + 1
							end

							if ((isTestID + 1) > #licenseReason) then
								if (math.floor(100/(#licenseReason)*testEnd[2])) >= 80 then
									--SUCCES
									page = "test >> success"
								else
									--ERROR
									page = "test >> error"
								end
								width,height = 550,300
								left,top = (sx/2)-(width/2),(sy/2)-(height/2)
							else
								isTestID = isTestID + 1
								testLoading = 0
								activeTestID = 0

								width,height = 0,300
								left,top = (sx/2)-(width/2),(sy/2)-(height/2)
							end

							testLoading = 0
							activeTestID = 0

							createAnimate(0,255,4,400,
								function(value) 
									alpha = value 
								end
							)
						end,300,1)
					end
				)

				return 
			end 
		end
		if (page == "test >> success") and (state == "down") then
			if not(alpha == 255) then return end
			if buttonHover and buttonHover == "startRutin" then
				createAnimate(255,0,4,700,function(value) alpha = value end,function()
					showdPanel = false
					testEnd = {0,0}
					testLoading = 0
					isTestID = 1
					alpha = 255
					activeTestID = 0
					page = "unknow"
					local pX,pY,pZ = getElementPosition(localPlayer)
					positionPed = {pX,pY,pZ}
					local x,y,z,rz,int,dim = unpack(getElementData(selectedActor,"ped.driveStartPos"))
					triggerServerEvent("createTeacherVehicle",localPlayer,localPlayer,categoryModel,260,x,y,z,rz,int,dim, "dontDelete")
					startRoutin()
				end)

				buttonHover = nil
				return 
			end
		end
		if (page == "test >> error") and (state == "down") then
			if not(alpha == 255) then return end
			if buttonHover and buttonHover == "close" then
				testEnd = {0,0}
				testLoading = 0
				isTestID = 1
				alpha = 255
				activeTestID = 0
				createAnimate(255,0,4,700,function(value) alpha = value end, function()
					selectedActor = nil
					showdPanel = false
					page = "unknow"
					destroyRender("renderTest")
				end)
			end
		end
	end
end

addEventHandler("onClientClick",root,clickDriving)

function clickCategoryButton(k)
	local price = getElementData(selectedActor,"ped.driving.category."..k..".price") or 0
	if exports['cr_core']:takeMoney(localPlayer, tonumber(price)) then
		showTest(licenseShop[shopType][k])
		categoryID = licenseShop[shopType][k]
		closeDrivingCategoryList()
		
		triggerLatentServerEvent("giveMoneyToFaction", 5000, false, localPlayer, localPlayer, 4, math.floor(price * 0.05)) -- GOVERMENT MONEY GIVING
	else
		exports["cr_infobox"]:addBox("error","Nincs elég pénzed! ("..price.."$)")
	end
end

function showCategoryList(actor)
	closed = false
	forced = false
	alpha = 0
	bSAnim = {}
	selectedActor = actor
	local actorName = getElementData(actor,"ped.name"):gsub("_"," ") or "Unknow Name"
	shopType = getElementData(actor,"ped.driveLicense.shopType") or 1

	outputChatBox(actorName.." mondja: Üdvözlöm, segíthetek valamiben?",255,255,255,true)

	local sizableHeight = (35+5)*(#licenseShop[shopType])

	width,height = 550,265+sizableHeight
	left,top = (sx/2)-(width/2),(sy/2)-(height/2)
	bottomHeight = 48+sizableHeight

	for k,v in pairs(licenseShop[shopType]) do
		buttons[k] = {left+25,top+307+((30+2)*k),width-50,30}
	end

	createRender("renderDriving", renderDriving)
	showdPanel = true
	page = "category"
	showCursor(true)
	createAnimate(0,255,4,500,function(value)
		alpha = value
	end)
end

function closeDrivingCategoryList()
	closed = true
	createAnimate(255,0,4,500,function(value) alpha = value end,function()
		alpha = 0
		bSAnim = {}
		showdPanel = false
		forced = false
		page = "unknow"
		shopType = nil
		destroyRender("renderDriving")
		showCursor(false)
	end)
end

function renderDriving()
	if (showdPanel) then
		font = exports['cr_fonts']:getFont("Poppins-SemiBold", 16)
		font2 = exports['cr_fonts']:getFont("Poppins-Medium", 14)

		if (page == "category") then
			dxDrawRectangle(left,top,550,height,tocolor(51,51,51,alpha * 0.8))
			dxDrawImage(left + 10, top + 10, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
			dxDrawText(getElementData(selectedActor,"ped.drivingShop.name"),left + 10 + 26 + 10,top+10,left+width,top+10+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

			if exports['cr_core']:isInSlot(left + width - 10 - 15, top + 10, 15, 15) then 
				dxDrawImage(left + width - 10 - 15, top + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
			else 
				dxDrawImage(left + width - 10 - 15, top + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
			end 

			dxDrawImage(left + width/2 - 80/2, top + 35, 80, 90, "files/icon-1.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawText("A vezetői engedély megszerzéséhez két sikeres vizsgára lesz szükséged.\nAz elméleti vizsga 14 kérdést tartalmaz, legalább 8 kérdésre helyes feleletet kell adnod a sikeres vizsgához.", left + 35, top + 35 + 90 + 20, left + width - 35, top + 35 + 90 + 20, tocolor(242, 242, 242, alpha), 1, font2, "left", "top", false, true)

			local startX, startY = left + 50, top + 255
			buttonHover = nil 
			for k,v in pairs(licenseShop[shopType]) do
				local price = getElementData(selectedActor,"ped.driving.category."..k..".price") or 0
				if exports['cr_core']:isInSlot(startX, startY, (width - 100), 35) then 
					buttonHover = k
					dxDrawRectangle(startX, startY, (width - 100), 35, tocolor(255, 59, 59, alpha))
					dxDrawText(licenseType[v][1].." ("..price.."$)",startX, startY, startX + (width - 100), startY + 35 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center","center", false,false,false,true)
				else 
					dxDrawRectangle(startX, startY, (width - 100), 35, tocolor(255, 59, 59, alpha * 0.7))
					dxDrawText(licenseType[v][1].." ("..price.."$)",startX, startY, startX + (width - 100), startY + 35 + 4, tocolor(242, 242, 242, alpha * 0.7), 1, font2, "center","center", false,false,false,true)
				end 

				startY = startY + 35 + 5
			end
		end
	end
end

function clientKey(button,state)
	if (showdPanel) then
		if (page == "category") then
			if (button == "backspace") then
				if (state) then
					closeDrivingCategoryList()
				end
			end
		end
	end
end
addEventHandler("onClientKey",root,clientKey)

function showTest(testID)
	setTimer(function()
		testEnd = {0,0}
		testLoading = 0
		isTestID = 1
		width,height = 0,300
		left,top = (sx/2)-(width/2),(sy/2)-(height/2)
		alpha = 0
		showdPanel = true
		page = "test"
		activeTestID = 0
		createRender("renderTest", renderTest)
		categoryModel = licenseType[testID][2]
		createAnimate(0,255,4,500,function(value) alpha = value end)
	end,1000,1)
end

function renderTest()
	if (showdPanel) and (page == "test") then
		font = exports['cr_fonts']:getFont("Poppins-SemiBold", 16)
		font2 = exports['cr_fonts']:getFont("Poppins-Medium", 14)
		font3 = exports['cr_fonts']:getFont("Poppins-SemiBold", 18)
		font4 = exports['cr_fonts']:getFont("Poppins-Medium", 12)
		font5 = exports['cr_fonts']:getFont("Poppins-SemiBold", 36)

		dxDrawRectangle(left,top,width,height,tocolor(51,51,51,alpha * 0.8))
		dxDrawImage(left + 10, top + 10, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
		dxDrawText("Elméleti teszt",left + 10 + 26 + 10,top+10,left+width,top+10+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

		dxDrawText(licenseReason[isTestID][1], left + 35, top + 50, left + width - 35, top + 50, tocolor(242, 242, 242, alpha), 1, font3, "center", "top", false, true)

		local tWidth = dxGetTextWidth(licenseReason[isTestID][1], 1, font3, true) + 75
		if tWidth > width then 
			width = tWidth
			left = (sx/2)-(width/2)
		end 

		dxDrawText(isTestID.."/"..#licenseReason, left + 25, top + 105, left + 25 + (width - 50), top + 105 - 5 + 4, tocolor(242, 242, 242, alpha), 1, font4, "right", "bottom")
		dxDrawRectangle(left + 25,top + 105,(width - 50),5,tocolor(242, 242, 242, alpha * 0.6))
		dxDrawRectangle(left + 25,top + 105,((width - 50)/#licenseReason) * (isTestID),5,tocolor(255, 59, 59, alpha))

		local startX, startY = left + 25, top + 120
		buttonHover = nil 

		local tWidth = dxGetTextWidth(licenseReason[isTestID][2], 1, font4, true) + 75
		if tWidth > width then 
			width = tWidth
			left = (sx/2)-(width/2)
		end 

		if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) or activeTestID == 1 then 
			if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) then 
				buttonHover = 1
			end 

			dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.8))
			dxDrawText("A", startX, startY, startX + 50, startY + 50 + 4, tocolor(51, 51, 51, alpha), 1, font5, "center", "center")
			dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.8))
			dxDrawText(licenseReason[isTestID][2], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha), 1, font4, "left", "center", true, true)
		else 
			dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.6))
			dxDrawText("A", startX, startY, startX + 50, startY + 50 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font5, "center", "center")
			dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.6))
			dxDrawText(licenseReason[isTestID][2], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha * 0.6), 1, font4, "left", "center", true, true)
		end 

		startY = startY + 50 + 5

		local tWidth = dxGetTextWidth(licenseReason[isTestID][3], 1, font3, true) + 75
		if tWidth > width then 
			width = tWidth
			left = (sx/2)-(width/2)
		end 

		if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) or activeTestID == 2 then 
			if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) then 
				buttonHover = 2
			end 

			dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.8))
			dxDrawText("B", startX, startY, startX + 50, startY + 50 + 4, tocolor(51, 51, 51, alpha), 1, font5, "center", "center")
			dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.8))
			dxDrawText(licenseReason[isTestID][3], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha), 1, font4, "left", "center", true, true)
		else 
			dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.6))
			dxDrawText("B", startX, startY, startX + 50, startY + 50 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font5, "center", "center")
			dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.6))
			dxDrawText(licenseReason[isTestID][3], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha * 0.6), 1, font4, "left", "center", true, true)
		end 

		startY = startY + 50 + 5

		local tWidth = dxGetTextWidth(licenseReason[isTestID][4], 1, font3, true) + 75
		if tWidth > width then 
			width = tWidth
			left = (sx/2)-(width/2)
		end 

		if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) or activeTestID == 3 then 
			if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) then 
				buttonHover = 3
			end 

			dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.8))
			dxDrawText("C", startX, startY, startX + 50, startY + 50 + 4, tocolor(51, 51, 51, alpha), 1, font5, "center", "center")
			dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.8))
			dxDrawText(licenseReason[isTestID][4], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha), 1, font4, "left", "center", true, true)
		else 
			dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.6))
			dxDrawText("C", startX, startY, startX + 50, startY + 50 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font5, "center", "center")
			dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.6))
			dxDrawText(licenseReason[isTestID][4], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha * 0.6), 1, font4, "left", "center", true, true)
		end 
	elseif (showdPanel) and (page == "test >> success") then
		font = exports['cr_fonts']:getFont("Poppins-SemiBold", 16)
		font2 = exports['cr_fonts']:getFont("Poppins-SemiBold", 18)
		font3 = exports['cr_fonts']:getFont("Poppins-Medium", 14)

		dxDrawRectangle(left,top,550,height,tocolor(51,51,51,alpha * 0.8))
		dxDrawImage(left + 10, top + 10, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
		dxDrawText(getElementData(selectedActor,"ped.drivingShop.name"),left + 10 + 26 + 10,top+10,left+width,top+10+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")
		dxDrawImage(left + width/2 - 40/2, top + 50, 40, 50, "files/icon-2.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
		dxDrawText("Gratulálunk, sikeres vizsgát tettél!", left, top + 115, left + width, top + 115, tocolor(97, 177, 90, alpha), 1, font2, "center", "top")
		dxDrawText("Kezdd el a rutin vizsgát, menj a kijelölt járműhöz és kövesd az oktató utasításait. Ügyelj az autó állapotára, sikeres vizsgához sértetlenül kell visszahoznod!\nSok sikert a rutin vizsgához", left + 35, top + 35 + 90 + 20, left + width - 35, top + 35 + 90 + 20, tocolor(242, 242, 242, alpha), 1, font3, "left", "top", false, true)

		local startX, startY = left + 50, top + 250
		buttonHover = nil 
		if exports['cr_core']:isInSlot(startX, startY, 450, 35) then 
			buttonHover = "startRutin"
			dxDrawRectangle(startX, startY, 450, 35, tocolor(255, 59, 59, alpha))
			dxDrawText("Rutin vizsga kezdése",startX, startY, startX + 450, startY + 35, tocolor(242, 242, 242, alpha), 1, font3, "center","center", false,false,false,true)
		else 
			dxDrawRectangle(startX, startY, 450, 35, tocolor(255, 59, 59, alpha * 0.7))
			dxDrawText("Rutin vizsga kezdése",startX, startY, startX + 450, startY + 35, tocolor(242, 242, 242, alpha * 0.7), 1, font3, "center","center", false,false,false,true)
		end 
	elseif (showdPanel) and (page == "test >> error") then
		font = exports['cr_fonts']:getFont("Poppins-SemiBold", 16)
		font2 = exports['cr_fonts']:getFont("Poppins-SemiBold", 18)
		font3 = exports['cr_fonts']:getFont("Poppins-Medium", 14)

		dxDrawRectangle(left,top,550,height,tocolor(51,51,51,alpha * 0.8))
		dxDrawImage(left + 10, top + 10, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
		dxDrawText(getElementData(selectedActor,"ped.drivingShop.name"),left + 10 + 26 + 10,top+10,left+width,top+10+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")
		dxDrawImage(left + width/2 - 40/2, top + 50, 40, 50, "files/icon-3.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
		dxDrawText("Sajnáljuk, sikertelen vizsgát tettél!", left, top + 115, left + width, top + 115, tocolor(255, 59, 59, alpha), 1, font2, "center", "top")
		dxDrawText("Sikertelenül abszolváltad a Kresz vizsgát, próbálkozz újra!\nSok sikert a Kresz vizsgához!", left + 35, top + 35 + 90 + 20 + 20, left + width - 35, top + 35 + 90 + 20 + 20, tocolor(242, 242, 242, alpha), 1, font3, "left", "top", false, true)

		local startX, startY = left + 50, top + 250
		buttonHover = nil 
		if exports['cr_core']:isInSlot(startX, startY, 450, 35) then 
			buttonHover = "close"
			dxDrawRectangle(startX, startY, 450, 35, tocolor(255, 59, 59, alpha))
			dxDrawText("Bezárás",startX, startY, startX + 450, startY + 35, tocolor(242, 242, 242, alpha), 1, font3, "center","center", false,false,false,true)
		else 
			dxDrawRectangle(startX, startY, 450, 35, tocolor(255, 59, 59, alpha * 0.7))
			dxDrawText("Bezárás",startX, startY, startX + 450, startY + 35, tocolor(242, 242, 242, alpha * 0.7), 1, font3, "center","center", false,false,false,true)
		end 
	end

	if selectedActor and isElement(selectedActor) then 
		if getDistanceBetweenPoints3D(localPlayer.position, selectedActor.position) >= 3 then 
			if not forced then 
				forced = true 
				closeDrivingCategoryList()
			end
		end
	end
end

local cpValue = 1
local routinMarker = false
local routinParkTimer = false
local routinTimer,routinWarning = nil,0
function startRoutin()
	routinTimer,routinWarning = nil,0
	setElementData(localPlayer,"char.routin",true)
	cpValue = 1
	local routinType = categoryID --tonumber(getElementData(selectedActor,"ped.driveRoutin"))
	addEventHandler("onClientMarkerHit",getRootElement(),hitRoutinMarker)
	addEventHandler("onClientMarkerLeave",getRootElement(),leaveRoutinMarker)
	addEventHandler("onClientVehicleDamage",root,handleVehicleDamage)
	routinMarker = createMarker(licenseRoutin[routinType][cpValue][1], licenseRoutin[routinType][cpValue][2], licenseRoutin[routinType][cpValue][3], "checkpoint", 2.5, 255, 87, 87)
	exports['cr_radar']:createStayBlip("RutinVizsga",createBlip(licenseRoutin[routinType][cpValue][1], licenseRoutin[routinType][cpValue][2], licenseRoutin[routinType][cpValue][3],0,2,255,0,0,255,0,0),0,"target",24,24,255,87,87)
	setElementData(routinMarker,"marker.routinMarker",true)
	setElementData(routinMarker,"marker.routinMarker.type",licenseRoutin[routinType][cpValue][4])

	return
end

function handleVehicleDamage(attacker,weapon,loss,x,y,z,tire)
	local playerRoutin = getElementData(localPlayer,"char.routin") or false
    if (playerRoutin) then
		local myVeh = getPedOccupiedVehicle(localPlayer)
		if (myVeh == source) then
			resetTimer(pedVoiceTimer)
			local pedName = localPlayer:getData("driverPed"):getData("ped.name")
		    outputChatBox(pedName.." mondja: "..getActorInteract(1,"damage-veh"),255,255,255,true)
		end
	end
end

function onClientColShapeHit( theElement, matchingDimension )
	if (theElement == localPlayer) then
    	local playerRoutin = getElementData(localPlayer,"char.routin") or false
    	if (playerRoutin) then
	        local colShape = source
	        local routinColShape = getElementData(colShape,"colShape.routin") or false
	        if (routinColShape) then
	        	if isTimer(routinTimer) then
	  				resetTimer(pedVoiceTimer)
	        		killTimer(routinTimer)
	        		local pedName = localPlayer:getData("driverPed"):getData("ped.name")
	        		outputChatBox(pedName.." mondja: "..getActorInteract(1,"col-shape-hit"),255,255,255,true)
	        		routinTimer = nil
	        	end
	        end
	    end
    end
end
addEventHandler("onClientColShapeHit", root, onClientColShapeHit)

function onClientColShapeLeave(theElement, matchingDimension)
    if (theElement == localPlayer) then
    	local playerRoutin = getElementData(localPlayer,"char.routin") or false
    	if (playerRoutin) then
	        local colShape = source
	        local routinColShape = getElementData(colShape,"colShape.routin") or false
	        if (routinColShape) and isElement(localPlayer:getData("driverPed")) then
	        	local pedName = localPlayer:getData("driverPed"):getData("ped.name")
	        	outputChatBox(pedName.." mondja: "..getActorInteract(1,"col-shape-leave"),255,255,255,true)
	        	resetTimer(pedVoiceTimer)
	        	routinTimer = setTimer(function()
	        		routinWarning = routinWarning + 1
	        		if not(routinWarning >= 3) then
	        			outputChatBox(pedName.." mondja: "..getActorInteract(1,"col-shape-leave"),255,255,255,true)
	        			resetTimer(pedVoiceTimer)
	        		else
	        			outputChatBox(pedName.." mondja: "..getActorInteract(1,"col-shape-warning"),255,255,255,true)
	        			if isTimer(pedVoiceTimer) then
	        				killTimer(pedVoiceTimer)
	        				pedVoiceTimer = nil
	        			end
	        			if isTimer(routinTimer) then
	        				killTimer(routinTimer)
	        				routinTimer = nil
	        			end
	        			routinWarning = 0
	        			if isElement(routinMarker) then
							destroyElement(routinMarker)
							exports['cr_radar']:destroyStayBlip("RutinVizsga")
						end
						if isTimer(routinParkTimer) then
							killTimer(routinParkTimer)
						end
						cpValue = 1
						routinMarker = false
						routinParkTimer = false
						removeEventHandler("onClientMarkerHit",getRootElement(),hitRoutinMarker)
						removeEventHandler("onClientMarkerLeave",getRootElement(),leaveRoutinMarker)
						removeEventHandler("onClientVehicleDamage",root,handleVehicleDamage)
						setElementData(localPlayer,"char.routin",false)

						exports["cr_infobox"]:addBox("error","Elhagytad a vizsga területet, ezért megbuktál a vizsgán.")
						local pX,pY,pZ = unpack(positionPed)
						triggerServerEvent("deleteTeacherVehicle",localPlayer,localPlayer,true,pX,pY,pZ)
	        		end
	        	end,7000,0)
	        end
	    end
    end
end
addEventHandler("onClientColShapeLeave", root, onClientColShapeLeave)

function hitRoutinMarker(hitPlayer,matchingDimension)
	local marker = source
	if (hitPlayer == localPlayer) then
		local mLicense = getElementData(marker,"marker.routinMarker")
        local vehicle = localPlayer.vehicle

		if (mLicense) and vehicle and vehicle == localPlayer:getData("driverVehicle") then
			local mType = getElementData(marker,"marker.routinMarker.type")
			if (mType == "park") then
				exports["cr_infobox"]:addBox("info","Várj egy kicsit..","Rutin vizsga",{1,3400})
				routinParkTimer = setTimer(function()
					cpValue = cpValue + 1
					if isElement(routinMarker) then
						destroyElement(routinMarker)
						exports['cr_radar']:destroyStayBlip("RutinVizsga")
					end
					local routinType = categoryID --tonumber(getElementData(selectedActor,"ped.driveRoutin"))
					routinMarker = createMarker(licenseRoutin[routinType][cpValue][1], licenseRoutin[routinType][cpValue][2], licenseRoutin[routinType][cpValue][3], "checkpoint", 2.5, 255, 87, 87)
					exports['cr_radar']:createStayBlip("RutinVizsga",createBlip(licenseRoutin[routinType][cpValue][1], licenseRoutin[routinType][cpValue][2], licenseRoutin[routinType][cpValue][3],0,2,255,0,0,255,0,0),0,"target",24,24,255,87,87)
					setElementData(routinMarker,"marker.routinMarker",true)
					setElementData(routinMarker,"marker.routinMarker.type",licenseRoutin[routinType][cpValue][4])
				end,5000,1)
			elseif (mType == "end") then
				if isTimer(pedVoiceTimer) then
	        		killTimer(pedVoiceTimer)
	        		pedVoiceTimer = nil
	        	end
				if isTimer(routinTimer) then
	        		killTimer(routinTimer)
	        		routinTimer = nil
	        	end
	        	routinWarning = 0
				if isElement(routinMarker) then
					destroyElement(routinMarker)
					exports['cr_radar']:destroyStayBlip("RutinVizsga")
				end
				if isTimer(routinParkTimer) then
					killTimer(routinParkTimer)
				end
				cpValue = 1
				routinMarker = false
				routinParkTimer = false
				removeEventHandler("onClientMarkerHit",getRootElement(),hitRoutinMarker)
				removeEventHandler("onClientMarkerLeave",getRootElement(),leaveRoutinMarker)
				removeEventHandler("onClientVehicleDamage",root,handleVehicleDamage)
				setElementData(localPlayer,"char.routin",false)
				local vehHealth = getElementHealth(getPedOccupiedVehicle(localPlayer))
				if not(vehHealth >= 900) then
					exports["cr_infobox"]:addBox("error","A kocsi túlságosan összetört, ezért megbuktál a vizsgán.")
					local pX,pY,pZ = unpack(positionPed)
					triggerServerEvent("deleteTeacherVehicle",localPlayer,localPlayer,true,pX,pY,pZ)
				else
					exports["cr_infobox"]:addBox("success","Sikeresen átmentél a rutin vizsgán, elkezdheted a forgalmi vizsgát!")
					triggerServerEvent("deleteTeacherVehicle",localPlayer,localPlayer,false)
					startTraffic()
				end
			else
				cpValue = cpValue + 1
				if isElement(routinMarker) then
					destroyElement(routinMarker)
					exports['cr_radar']:destroyStayBlip("RutinVizsga")
				end
				local routinType = categoryID --tonumber(getElementData(selectedActor,"ped.driveRoutin"))
				routinMarker = createMarker(licenseRoutin[routinType][cpValue][1], licenseRoutin[routinType][cpValue][2], licenseRoutin[routinType][cpValue][3], "checkpoint", 2.5, 255, 87, 87)
				exports['cr_radar']:createStayBlip("RutinVizsga",createBlip(licenseRoutin[routinType][cpValue][1], licenseRoutin[routinType][cpValue][2], licenseRoutin[routinType][cpValue][3],0,2,255,0,0,255,0,0),0,"target",24,24,255,87,87)
				setElementData(routinMarker,"marker.routinMarker",true)
				setElementData(routinMarker,"marker.routinMarker.type",licenseRoutin[routinType][cpValue][4])
			end
		end
	end
end

function leaveRoutinMarker(leavePlayer,matchingDimension)
	local marker = source
	if (leavePlayer == localPlayer) then
		local mLicense = getElementData(marker,"marker.routinMarker")
        local vehicle = localPlayer.vehicle

		if (mLicense) and vehicle and vehicle == localPlayer:getData("driverVehicle") then
			local mType = getElementData(marker,"marker.routinMarker.type")
			if (mType == "park") then
				if isTimer(routinParkTimer) then
					killTimer(routinParkTimer)
				end
				exports["cr_infobox"]:addBox("error","Túl hamar hagytad el a parkolót!")
			end
		end
	end
end


function getElementSpeed( element, unit )
    if isElement( element ) then
        local x,y,z = getElementVelocity( element )
        if unit == "mph" or unit == 1 or unit == "1" then
            return ( x ^ 2 + y ^ 2 + z ^ 2 ) ^ 0.5 * 100
        else
            return ( x ^ 2 + y ^ 2 + z ^ 2 ) ^ 0.5 * 1.8 * 100
        end
    else
        outputDebugString( "Not an element. Can't get speed" )
        return false
    end
end

local trafficType,trafficMarker,trafficCpValue,trafficSpeedTimer,speedMessageTimer,trafficWarning,maxTrafficSpeed = nil,nil,nil,nil,nil,0,90
function startTraffic()
	trafficType,trafficMarker,trafficCpValue,trafficSpeedTimer,speedMessageTimer,trafficWarning,maxTrafficSpeed = nil,nil,nil,nil,nil,0,90
	trafficType = tonumber(getElementData(selectedActor,"ped.driveTraffic"))
	trafficCpValue = 1
	local x,y,z,rz,int,dim = unpack(getElementData(selectedActor,"ped.traficStartPos"))
	triggerServerEvent("createTeacherVehicle",localPlayer,localPlayer,categoryModel,260,x,y,z,rz,int,dim)

	trafficMarker = createMarker(licenseTraffic[trafficType][categoryID][trafficCpValue][1], licenseTraffic[trafficType][categoryID][trafficCpValue][2], licenseTraffic[trafficType][categoryID][trafficCpValue][3], "checkpoint", 2.5, 255, 87, 87)
	exports['cr_radar']:createStayBlip("ForgalmiVizsga",createBlip(licenseTraffic[trafficType][categoryID][trafficCpValue][1], licenseTraffic[trafficType][categoryID][trafficCpValue][2], licenseTraffic[trafficType][categoryID][trafficCpValue][3],0,2,255,0,0,255,0,0),0,"target",24,24,255,87,87)
	setElementData(trafficMarker,"marker.trafficMarker",true)
	setElementData(trafficMarker,"marker.trafficMarker.type",licenseTraffic[trafficType][categoryID][trafficCpValue][4])

	addEventHandler("onClientMarkerHit",getRootElement(),hitTrafficMarker)

	trafficSpeedTimer = setTimer(function()
		if isTimer(speedMessageTimer) then return end
		local veh = getPedOccupiedVehicle(localPlayer)
        if not veh then return end
        local speed = getElementSpeed(veh)
		if (speed > maxTrafficSpeed) then
            if isElement(localPlayer:getData("driverPed")) then 
                speedMessageTimer = setTimer(function() end, 2000, 1)
                trafficWarning = trafficWarning + 1
                local pedName = localPlayer:getData("driverPed"):getData("ped.name")
                outputChatBox(pedName.." mondja: "..getActorInteract(1,"speed-veh"),255,255,255,true)
                local syntax = exports['cr_core']:getServerSyntax("License","red")
                outputChatBox(syntax.."Figyelmeztetést kaptál gyorshajtásért! #d23131("..trafficWarning.."/5)",255,255,255,true)
            end
		end

		if (trafficWarning >= 5) then
			if isTimer(trafficSpeedTimer) then
				killTimer(trafficSpeedTimer)
			end
			if isElement(trafficMarker) then
				destroyElement(trafficMarker)
				exports['cr_radar']:destroyStayBlip("ForgalmiVizsga")
			end
			removeEventHandler("onClientMarkerHit",getRootElement(),hitTrafficMarker)
			trafficType,trafficMarker,trafficCpValue,trafficSpeedTimer,speedMessageTimer,trafficWarning,maxTrafficSpeed = nil,nil,nil,nil,nil,0,90
			selectedActor = nil
			local pX,pY,pZ = unpack(positionPed)
			triggerServerEvent("deleteTeacherVehicle",localPlayer,localPlayer,true,pX,pY,pZ)
			exports['cr_infobox']:addBox("error", "A vizsgád sikertelen lett, túl sokszor lettél figyelmeztetve hogy gyorsan mész.")
		end
	end,2000,0)
end

function hitTrafficMarker(hitPlayer)
	local marker = source
	if (hitPlayer == localPlayer) then
		local mLicense = getElementData(marker,"marker.trafficMarker")
        local vehicle = localPlayer.vehicle

		if (mLicense) and vehicle and vehicle == localPlayer:getData("driverVehicle") then
			local mType = getElementData(marker,"marker.trafficMarker.type")
			if (mType == "next") then
				if isElement(trafficMarker) then
					destroyElement(trafficMarker)
					exports['cr_radar']:destroyStayBlip("ForgalmiVizsga")
					trafficMarker = nil
				end
				trafficCpValue = trafficCpValue + 1
				trafficMarker = createMarker(licenseTraffic[trafficType][categoryID][trafficCpValue][1], licenseTraffic[trafficType][categoryID][trafficCpValue][2], licenseTraffic[trafficType][categoryID][trafficCpValue][3], "checkpoint", 2.5, 255, 87, 87)
				exports['cr_radar']:createStayBlip("ForgalmiVizsga",createBlip(licenseTraffic[trafficType][categoryID][trafficCpValue][1], licenseTraffic[trafficType][categoryID][trafficCpValue][2], licenseTraffic[trafficType][categoryID][trafficCpValue][3],0,2,255,0,0,255,0,0),0,"target",24,24,255,87,87)
				setElementData(trafficMarker,"marker.trafficMarker",true)
				setElementData(trafficMarker,"marker.trafficMarker.type",licenseTraffic[trafficType][categoryID][trafficCpValue][4])
			elseif (mType == "end") then
				if isTimer(trafficSpeedTimer) then
					killTimer(trafficSpeedTimer)
				end
				if isElement(trafficMarker) then
					destroyElement(trafficMarker)
					exports['cr_radar']:destroyStayBlip("ForgalmiVizsga")
				end
				removeEventHandler("onClientMarkerHit",getRootElement(),hitTrafficMarker)
				trafficType,trafficMarker,trafficCpValue,trafficSpeedTimer,speedMessageTimer,trafficWarning,maxTrafficSpeed = nil,nil,nil,nil,nil,0,90
				
				local vehHealth = getElementHealth(getPedOccupiedVehicle(localPlayer))
				if not(vehHealth >= 800) then
					exports["cr_infobox"]:addBox("error","A kocsi túlságosan összetört, ezért megbuktál a vizsgán.")
				else
					exports["cr_infobox"]:addBox("success","Sikeresen leraktad a jogosítványt!")

                    local categoryType = licenseType[categoryID][1]:gsub(" kategória", "")
                    local data = {
                        ['name'] = exports['cr_admin']:getAdminName(localPlayer),
                        ['gender'] = localPlayer:getData('char >> details')['neme'] or 1,
                        ['startDate'] = getRealTime()['timestamp'],
                        ['endDate'] = getRealTime()['timestamp'] + (1 * 31 * 24 * 60 * 60),
                        ['skinID'] = localPlayer.model,
                        ['category'] = categoryType or 'A',
                    }

                    exports['cr_inventory']:giveItem(localPlayer, 77, data)
				end

				selectedActor = nil
				local pX,pY,pZ = unpack(positionPed)
				triggerServerEvent("deleteTeacherVehicle",localPlayer,localPlayer,false,pX,pY,pZ)
			end
		end
	end
end

function stopRes(stopped)
	if (getResourceName(stopped) == "cr_license_new") then
		if isElement(routinMarker) then
			destroyElement(routinMarker)
			exports['cr_radar']:destroyStayBlip("RutinVizsga")
		end
	end
end
addEventHandler("onClientResourceStop",getRootElement(),stopRes)

function onClientVehicleEnter(thePlayer, seat)
    if thePlayer == localPlayer then 
        if source:getData("licenseDriverPed") then 
            if localPlayer:getData("driverVehicle") and localPlayer:getData("driverVehicle") == source then 
                if not isTimer(pedVoiceTimer) then 
                    pedVoiceTimer = setTimer(function()
                        local gTyp = "random-voice"
                        local pedName = localPlayer:getData("driverPed"):getData("ped.name")
                        if not(getElementData(localPlayer,"char >> belt") == true) and categoryID ~= 1 then
                            gTyp = "ped-belt"
                        end
                        outputChatBox(pedName.." mondja: "..getActorInteract(1,gTyp),255,255,255,true)
                    end, 10 * 1000, 0)
                end
            end
        end
    end
end
addEventHandler("onClientVehicleEnter", root, onClientVehicleEnter)

function onClientVehicleExit(thePlayer, seat)
    if thePlayer == localPlayer then 
        if source:getData("licenseDriverPed") then 
            if localPlayer:getData("driverVehicle") and localPlayer:getData("driverVehicle") == source then 
                if isTimer(pedVoiceTimer) then 
                    killTimer(pedVoiceTimer)
                    pedVoiceTimer = nil
                end
            end
        end
    end
end
addEventHandler("onClientVehicleExit", root, onClientVehicleExit)

function resetLicenseHandler()
    if isElement(routinMarker) then 
        routinMarker:destroy()
        routinMarker = nil 

        exports.cr_radar:destroyStayBlip("RutinVizsga")
    end

    if isElement(trafficMarker) then 
        trafficMarker:destroy()
        trafficMarker = nil

        exports.cr_radar:destroyStayBlip("ForgalmiVizsga")
    end

    if isTimer(pedVoiceTimer) then 
        killTimer(pedVoiceTimer)
        pedVoiceTimer = nil
    end

    if isTimer(trafficSpeedTimer) then 
        killTimer(trafficSpeedTimer)
        trafficSpeedTimer = nil
    end
end
addEvent("driverLicense.resetLicense", true)
addEventHandler("driverLicense.resetLicense", root, resetLicenseHandler)

function dxDrawBorder(x,y,w,h,c,s)
	dxDrawRectangle(x-s,y-s,w+(s*2),s,c)
	dxDrawRectangle(x-s,y+h,w+(s*2),s,c)
	dxDrawRectangle(x-s,y,s,h,c)
	dxDrawRectangle(x+w,y,s,h,c)
end

function isInBox(dX, dY, dSZ, dM)
	if isCursorShowing() then
		local cX, cY = getCursorPosition()
		eX, eY = sx*cX, sy*cY
		if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
			return true
		else
			return false
		end
	end
end

function table.find(t, v)
	for k, a in ipairs(t) do
		if a == v then
			return k
		end
	end
	return false
end

function createAnimate(f, t, easing, duration, onChange, onEnd)
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

function onAnimateRender()
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
end
createRender("onAnimateRender", onAnimateRender)