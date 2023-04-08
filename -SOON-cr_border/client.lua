local sx,sy = guiGetScreenSize()
local selected

local panel_state = {
	["pay"] = false,
	["manage"] = false
}

local sounds = 1

local cols = {
    --{group,x,y,z,w,d,h,rot}
    {1,29.00263, -1540.60095,3.3,7,8,4},
    {2,67.30491, -1529.83484,4.1,7,8,4},
    {3,-9.61811, -1370.02075, 9.8,6,6,4},
    {4,-18.40753, -1333.54517, 9.9,6,6,4},
    {5,-95.079124450684, -936.41394042969, 19,6,5.3,4},
    {6,-78.74015045166, -888.55877685547, 14,6,5.3,4},
    {7,-957.72650146484, -262.66864013672, 35,6,6,4},
    {8,-967.75988769531, -349.01000976563, 35,5.5,6,4}
}

local placed_collisions = {}

for k,v in pairs(cols) do
    placed_collisions[v[1]] = createColCuboid(v[2],v[3],v[4],v[5],v[6],v[7])
end

function saveXML(parameter, value)
	local xmlFileName = "settings.xml"
	local xmlFile = xmlLoadFile ( xmlFileName )
	if not (xmlFile) then
		xmlFile = xmlCreateFile( xmlFileName, "sound" )
	end
	
	local xmlNode = xmlFindChild (xmlFile, parameter, 0)
	if not (xmlNode) then
		xmlNode = xmlCreateChild(xmlFile, parameter)
	end
	xmlNodeSetValue (xmlNode,value)
	xmlSaveFile(xmlFile)
	xmlUnloadFile(xmlFile)
end 

function toggleSounds()
    if sounds == 0 then
        sounds = 1
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        outputChatBox(syntax.. "Sikeresen kikapcsoltad a határhangot!", 255,255,255,true)
    else
        sounds = 0
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        outputChatBox(syntax.. "Sikeresen bekapcsoltad a határhangot!", 255,255,255,true)
    end
    saveXML("sound",sounds)
end
addCommandHandler("togbordersound",toggleSounds)
addCommandHandler("toghatarhang",toggleSounds)
addCommandHandler("toghatarsound",toggleSounds)
addCommandHandler("togborderhang",toggleSounds)

function loadSettings()
    local xmlfile = xmlLoadFile("settings.xml")
	if xmlfile then
		local as = xmlFindChild(xmlfile, "sound", 0)
		
		if as then
			local s = xmlNodeGetValue(as)
			if s then
				sounds = s
            end
		end
	end
end
loadSettings()

addEvent("playSound",true)
addEventHandler("playSound",root,
	function (element)
	    if tonumber(sounds) == 0 then return end
	    local x,y,z = getElementPosition(element)
	    sound = playSound3D("sound.mp3",x,y,z,false)
	    setSoundMaxDistance(sound, 40)
	end
)

hatar_manual = {}

startAnimationTime = 500
startAnimation = "InOutQuad"
white = "#7d7d7d"

function panelRender()
    local alpha
    local nowTick = getTickCount()
    if start then
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            0, 0, 0,
            255, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph
    else
        
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            255, 0, 0,
            0, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph
        
        if progress >= 1 then
            alpha = 0
            --removeEventHandler("onClientRender",root,panelRender)
            destroyRender("panelRender")
            return
        end
    end
    
    selected = nil
    
    if not hatar_manual[key] then
        local w, h = 535, 350
        local x, y = sx/2-w/2, sy/2-h/2

        local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
        local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 14)

        dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawImage(x + 10, y + 10, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText("Határátkelő", x + 10 + 26 + 10,y+10,x+w,y+10+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

        dxDrawImage(x + w/2 - 104/2, y + 50, 104, 90, "files/icon.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText("A határátkelés díjköteles, amennyiben át szeretnél kelni nyomj az\n“#61b15aÁtkelés#f2f2f2” gombra és a kapú automatikusan nyilík.\nHa mégsem szeretnél átkelni  akkor kattints a “#ff3b3bMégsem#f2f2f2” gombra.\n\nAz átkelés díja #61b15a$25#f2f2f2 dollár.", x + 35, y + 50 + 90 + 30, x + 35, y + 50 + 90 + 30, tocolor(242, 242, 242, alpha), 1, font2, "left", "top", false, false, false, true)

        if exports['cr_core']:isInSlot(x + 53, y + 300, 200, 35) then 
            selected = 1
            
            dxDrawRectangle(x + 53, y + 300, 200, 35, tocolor(97, 177, 90, alpha))
            dxDrawText('Átkelés', x + 53, y + 300, x + 53 + 200, y + 300 + 35 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
        else 
            dxDrawRectangle(x + 53, y + 300, 200, 35, tocolor(97, 177, 90, alpha * 0.7))
            dxDrawText('Átkelés', x + 53, y + 300, x + 53 + 200, y + 300 + 35 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
        end 

        if exports['cr_core']:isInSlot(x + 283, y + 300, 200, 35) then 
            selected = 2
            
            dxDrawRectangle(x + 283, y + 300, 200, 35, tocolor(255, 59, 59, alpha))
            dxDrawText('Mégsem', x + 283, y + 300, x + 283 + 200, y + 300 + 35 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
        else 
            dxDrawRectangle(x + 283, y + 300, 200, 35, tocolor(255, 59, 59, alpha * 0.7))
            dxDrawText('Mégsem', x + 283, y + 300, x + 283 + 200, y + 300 + 35 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
        end 
    else
        local w, h = 535, 50 + 90 + 30 + 30 + 15
        local x, y = sx/2-w/2, sy/2-h/2

        local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
        local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 14)

        dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawImage(x + 10, y + 10, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText("Határátkelő", x + 10 + 26 + 10,y+10,x+w,y+10+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

        dxDrawImage(x + w/2 - 104/2, y + 50, 104, 90, "files/icon.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText("A határ jelenleg #ff3b3bzárva#f2f2f2 van!", x, y + 50 + 90 + 30, x + w, y + 50 + 90 + 30, tocolor(242, 242, 242, alpha), 1, font2, "center", "top", false, false, false, true)
    end
end

function manualRender()
    local alpha
    local nowTick = getTickCount()
    if start then
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            0, 0, 0,
            255, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph
    else
        
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            255, 0, 0,
            0, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph
        
        if progress >= 1 then
            alpha = 0
            --removeEventHandler("onClientRender",root,manualRender)
            destroyRender("manualRender")
            return
        end
    end
    
    selected = nil

    local w, h = 535, 240
    local x, y = sx/2-w/2, sy/2-h/2

    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 14)

    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
    dxDrawImage(x + 10, y + 10, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("Határátkelő", x + 10 + 26 + 10,y+10,x+w,y+10+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

    dxDrawImage(x + w/2 - 104/2, y + 50, 104, 90, "files/icon.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

    dxDrawText("Határkezelési funkciók:", x, y + 50 + 90 + 15, x + w, y + 50 + 90 + 15, tocolor(242, 242, 242, alpha), 1, font2, "center", "top", false, false, false, true)

    if exports['cr_core']:isInSlot(x + 53, y + 190, 200, 35) then 
        selected = 1
        
        dxDrawRectangle(x + 53, y + 190, 200, 35, tocolor(97, 177, 90, alpha))
        dxDrawText('Nyit', x + 53, y + 190, x + 53 + 200, y + 190 + 35 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
    else 
        dxDrawRectangle(x + 53, y + 190, 200, 35, tocolor(97, 177, 90, alpha * 0.7))
        dxDrawText('Nyit', x + 53, y + 190, x + 53 + 200, y + 190 + 35 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
    end 

    if exports['cr_core']:isInSlot(x + 283, y + 190, 200, 35) then 
        selected = 2
        
        dxDrawRectangle(x + 283, y + 190, 200, 35, tocolor(255, 59, 59, alpha))
        dxDrawText('Zár', x + 283, y + 190, x + 283 + 200, y + 190 + 35 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
    else 
        dxDrawRectangle(x + 283, y + 190, 200, 35, tocolor(255, 59, 59, alpha * 0.7))
        dxDrawText('Zár', x + 283, y + 190, x + 283 + 200, y + 190 + 35 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
    end 
end
--Egyéb funkciók
addEvent("sendManuals",true)
addEventHandler("sendManuals",root,
	function (table)
		hatar_manual = table
	end
)

function money(player)
	exports['cr_core']:takeMoney(player, 25,false)
end
addEvent("money",true)
addEventHandler("money",root,money)

addEvent("writeInChat",true)
addEventHandler("writeInChat",root,
	function (type,text,sectype)
		if type == "me" then
			exports['cr_chat']:createMessage(localPlayer, text, 1)
		elseif type == "outputChatBox" then
			local syntax = exports['cr_core']:getServerSyntax(false,sectype)
            outputChatBox(syntax..text, 255,255,255,true) 
		end
	end
)

function closePay()
    startTick = getTickCount()
    start = false
    panel_state["pay"] = false
end

addEventHandler("onClientResourceStop", resourceRoot, closePay)

function hatar(back,lo)
    --outputChatBox(key)
    if key and cols[key] and cols[key][1] then
        --outputChatBox(cols[key][1])
        local breaked = false 
        for k,v in pairs(factions) do 
            if exports['cr_dashboard']:isPlayerInFaction(localPlayer, v) then 
                breaked = true 
                break 
            end 
        end 
        if breaked then
            if back == 1 then
                if lo == false then
                    start = false
                    startTick = getTickCount()
                    return
                end
                panel_state["manage"] = not panel_state["manage"]
                if panel_state["manage"] then
                    --addEventHandler("onClientRender",root,manualRender, true, "low-5")
                    createRender("manualRender", manualRender)
                    start = true
                    startTick = getTickCount()
                elseif not panel_state["manage"] then
                    start = false
                    startTick = getTickCount()
                end
            else
                triggerServerEvent("checkManualEnable",localPlayer,key)
            end
        end
    end
end
addEvent("toggleHatar",true)
addEventHandler("toggleHatar",root,hatar)

function selecting()
    --outputChatBox(key)
    if key and cols[key] and cols[key][1] then
        --outputChatBox(cols[key][1])
        local breaked = false 
        for k,v in pairs(factions) do 
            if exports['cr_dashboard']:isPlayerInFaction(localPlayer, v) then 
                breaked = true 
                break 
            end 
        end 
        if breaked then
            choose = not choose
            if choose then
                local syntax = exports['cr_core']:getServerSyntax(false,"warning")
                outputChatBox(syntax.."Határválasztás bekapcsolva! Kattints egy határcölöpre!", 255,255,255,true)
            else
                local syntax = exports['cr_core']:getServerSyntax(false,"warning")
                outputChatBox(syntax.."Határválasztás kikapcsolva!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("setborderstate",selecting)
addCommandHandler("sethatarmanual",selecting)
addCommandHandler("setbordermanual",selecting)
addCommandHandler("toghatarmanual",selecting)
addCommandHandler("togbordermanual",selecting)

function onClick(mouse,press,ax,ay,wx,wy,wz,element)
	if mouse == "left" and press == "down" then
		if panel_state["pay"] then
			if selected == 1 then
				if exports['cr_network']:getNetworkStatus() then return end
                if exports['cr_core']:hasMoney(localPlayer, 25, false)then
                    triggerServerEvent("moveSync",localPlayer,key,true,true)
                    closePay()
                else
                    local syntax = exports['cr_core']:getServerSyntax(false,"error")
                    --outputChatBox(syntax.."Nincs elég pénzed ahhoz, hogy átlépj a határon!", 255,255,255,true)
                    exports['cr_infobox']:addBox("error", "Nincs elég pénzed ahhoz, hogy átlépj a határon!")
                    closePay()
                end
	        elseif selected == 2 then
	            closePay()
	        end

            selected = nil
		elseif panel_state["manage"] then
			if selected == 1 then
                triggerServerEvent("moveSync",localPlayer,key,true,false)
	        elseif selected == 2 then
                triggerServerEvent("moveSync",localPlayer,key,false,false,localPlayer)
	        end
            selected = nil
	    elseif choose then
            local breaked = false 
            for k,v in pairs(factions) do 
                if exports['cr_dashboard']:isPlayerInFaction(localPlayer, v) then 
                    breaked = true 
                    break 
                end 
            end 
            if breaked then
                if isElement(element) then
                    triggerServerEvent("toggleManual",localPlayer,element)
                    choose = false
                end
            end
		end
	end
end
addEventHandler("onClientClick",root,onClick)

addEventHandler("onClientVehicleExit",root,
	function (player,dim)
		if localPlayer == player and panel_state["pay"] then
			closePay()
		end
	end
)

addEventHandler("onClientKey",root,
	function(bill,press)
        --outputChatBox(tostring(press))
		if bill == "enter" and panel_state["pay"] and not isChatBoxInputActive() then
            cancelEvent()
            if press then
                if exports['cr_network']:getNetworkStatus() then return end
                if exports['cr_core']:hasMoney(localPlayer, 25, false)then
                    triggerServerEvent("moveSync",localPlayer,key,true,true)
                    closePay()
                else
                    local syntax = exports['cr_core']:getServerSyntax(false,"error")
                    --outputChatBox(syntax.."Nincs elég pénzed ahhoz, hogy átlépj a határon!", 255,255,255,true)
                    exports['cr_infobox']:addBox("error", "Nincs elég pénzed ahhoz, hogy átlépj a határon!")
                    closePay()
                end
            end
		elseif bill == "backspace" and panel_state["pay"] and not isChatBoxInputActive() then
			if press then
                closePay()
            end
		end
	end
)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        setTimer(
            function()
                for k,v in pairs(getElementsByType("object")) do
                    if v.model == 1214 then
                        setObjectBreakable(v, false)
                    end
                end
            end, 10 * 1000, 1
        )
    end
)

--Colshape funckiók
function onClientColShapeHit( theElement, matchingDimension )
    --outputChatBox("asd")
    if (theElement == localPlayer) and matchingDimension and source then
        --outputChatBox("asd2")
        for k,v in pairs(placed_collisions) do
            --outputChatBox("asd3")
            if source == v and getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer)==0 and not panel_state["pay"] then
                --outputChatBox("asd4")
                key = k
                --outputChatBox(key)
                
                panel_state["pay"] = true
                --addEventHandler("onClientRender",root,panelRender, true, "low-5")
                createRender("panelRender", panelRender)
                startTick = getTickCount()
                start = true
                
                triggerServerEvent("refreshManual",localPlayer)
                break
            elseif source == v and not getPedOccupiedVehicle(localPlayer) then
                --outputChatBox("asd5")
                key = k
                --outputChatBox(key)--if isTimer(renderTimer2) then killTimer(renderTimer2) end
                addCommandHandler("hatarmanage",hatar)
                addCommandHandler("borderstate",hatar)
                triggerServerEvent("refreshManual",localPlayer)
                break
            end
        end
    end
end
addEventHandler("onClientColShapeHit", root, onClientColShapeHit)

function leave( theElement, matchingDimension )
    if theElement == localPlayer and panel_state["pay"] then
        closePay()
    elseif theElement == localPlayer and panel_state["manage"] then
        start = false
        startTick = getTickCount()
    	panel_state["manage"] = false
    end
    removeCommandHandler("hatarmanage",hatar)
    removeCommandHandler("borderstate",hatar)
end
addEventHandler("onClientColShapeLeave", root, leave)

--Kiegészítő funkciók
       
screenSize = {guiGetScreenSize()}
getCursorPos = getCursorPosition
function getCursorPosition()

    --outputChatBox(tostring(isCursorShowing()))
    if isCursorShowing() then
        --outputChatBox("asd")
        local x,y = getCursorPos()
        --outputChatBox("x"..tostring(x))
        --outputChatBox("y"..tostring(y))
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