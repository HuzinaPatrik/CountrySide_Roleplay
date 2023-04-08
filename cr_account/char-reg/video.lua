local sx, sy = guiGetScreenSize()

local ped_pos = {
	-- skinid , x, y, z, rot
	{61, 1185.3984375, -1773.5905761719, 13.5703125, 270, "COP_AMBIENT", "Coplook_think"},
	--{76, -1313.3597412109, -212.09132385254, 14.1484375, 160, "COP_AMBIENT", "Coplook_loop"},
	--{91, -1312.2592773438, -212.82049560547, 14.1484375, 100, "COP_AMBIENT", "Coplook_loop"},
	--{16, -1329.1708984375, -231.74711608887, 14.1484375, 20, "LOWRIDER", "RAP_B_Loop"},
}

local ped = {}
local vehs_bag = {}

local startAnimation = "InOutQuad"
local startAnimationTime = 250
local alpha, multipler, start, startTick, onEndFunc
local function drawnText()
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
            onEndFunc()
            return
        end
    end
	
	local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 18)
    dxDrawText(text, sx/2, sy/2, sx/2, sy/2, tocolor(229, 229, 229,alpha), 1, font, "center", "center")
end

function startVideo(cmd) 
    setFarClipDistance(3000)
    fadeCamera(false)
    text = "Eljött a változás ideje... itt az idő új életet kezdeni egy új helyen..."
    start = true
    startTick = getTickCount()
    addEventHandler("onClientRender", root, drawnText, true, "low-5") 
    setTimer(function() 
        start = false
		startTick = getTickCount()
		onEndFunc = function()
			removeEventHandler("onClientRender", root, drawnText)
			first_position()			
		end
    end, 1000*5, 1)
end

function first_position()
	fadeCamera(true)
	setCameraMatrix(1190.4191894531, -1763.8021240234, 13.5703125, 1182.248046875, -1772.5681152344, 13.836064338684) 
	bus = createVehicle(431, 1182.248046875, -1772.5681152344, 13.836064338684, 0, 0, 0)
    setElementDimension(bus, getElementDimension(localPlayer))

	busPed = createPed(100, 1182.248046875, -1772.5681152344, 10.836064338684)
	setElementDimension(busPed, getElementDimension(localPlayer))
	warpPedIntoVehicle(busPed, bus)
	
	for k,v in ipairs(ped_pos) do
		ped[k] = createPed(v[1], v[2], v[3], v[4])
		setElementRotation(ped[k], 0, 0, v[5])
		setPedAnimation(ped[k], v[6], v[7], -1, true, false, false)
		setElementFrozen(ped[k], true)
        setElementDimension(ped[k], getElementDimension(localPlayer))
	end	
	
	player_ped = createPed(details["skin"],1186.4997558594, -1772.0573730469, 13.5703125)
    setElementDimension(player_ped, getElementDimension(localPlayer))
	setElementRotation(player_ped, 0, 0, 90)
	setPedAnimation(player_ped, "ped", "walk_gang1")
    
    bus:setDoorOpenRatio(3, 1)
	
	-- Go to Next Situation
	setTimer(function()
        bus:setDoorOpenRatio(3, 0)
        bus:setDoorOpenRatio(2, 0)
		fadeCamera(false)
	    text = "5 perccel később... "
        start = true
        startTick = getTickCount()
        addEventHandler("onClientRender", root, drawnText, true, "low-5") 		
		setTimer(function() 
			for k,v in ipairs(ped_pos) do
				destroyElement(ped[k])
			end			
                    
            start = false
            startTick = getTickCount()
            onEndFunc = function()
                removeEventHandler("onClientRender", root, drawnText)
                second_position() 			
            end		
		end, 1000*5, 1)
	end, 1000*2, 1)
end

function second_position()
	warpPedIntoVehicle(player_ped, bus, 2)
	fadeCamera(true)
	setPedControlState(busPed, "accelerate", true)
	
	-- Go to Next Situation
	setTimer(function()
		fadeCamera(false)
	    text = "1 órával később..."
        start = true
        startTick = getTickCount()
        addEventHandler("onClientRender", root, drawnText, true, "low-5") 			
		setTimer(function() 
            start = false
            startTick = getTickCount()
            onEndFunc = function()
                removeEventHandler("onClientRender", root, drawnText)
                third_position() 			
            end
		end, 1000*5, 1)
	end, 1000*2.5, 1)
end

function third_position()
	fadeCamera(true)
	setCameraMatrix(2295.6953125, -105.55944824219, 31.27739906311, 2207.5666503906, -61.212287902832, 14.947855949402)
	setPedControlState(busPed, "accelerate", false)
	setElementFrozen(bus,true)
	setElementPosition(bus, 2275.3798828125, -92.213218688965, 26.895030975342)
	setElementRotation(bus, 0, 0, 270)

	-- Go to Next Situation
	setTimer(function()
		fadeCamera(false)
	    text = "Megérkeztünk Red Countyba.. itt az idő ,hogy kiismerd magad és felépítsd az új életed."
        start = true
        startTick = getTickCount()
		addEventHandler("onClientRender", root, drawnText, true, "low-5") 		
		setTimer(function()
			destroyElement(bus)
			destroyElement(busPed)
			destroyElement(player_ped)
                    
            start = false
            startTick = getTickCount()
            onEndFunc = function()
                removeEventHandler("onClientRender", root, drawnText)
                fourth_position() 			
            end		
		end, 1000*5, 1)
	end, 1000*2.5, 1)		
end

function fourth_position()
	setTimer(function() fadeCamera(true) end, 1000, 1)
	--setCameraTarget(localPlayer)
    
    resetFarClipDistance()
    
	startTour()
end

