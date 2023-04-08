local driver = false
local shooting = false
local helpText,helpAnimation
lastSlot = 0
settings = {}

function boneBreaked(e)
    --char >> bone felépítése = {Has, Bal kéz, Jobb kéz, Bal láb, Jobb láb}
    local bone = getElementData(e, "char >> bone") or {true, true, true, true, true}
    if not bone[2] or not bone[3] then 
        return true
    end
    return false
end

--This function simply sets up the driveby upon vehicle entry
local function setupDriveby( player, seat )
	--If his seat is 0, store the fact that he's a driver
	if seat == 0 then 
		driver = true
	else
		driver = false
	end
	--By default, we set the player's equiped weapon to nothing.
	--setPedWeaponSlot( localPlayer, 0 )
	--[[
    if settings.autoEquip then
		toggleDriveby()
	end
    ]]
end
addEventHandler( "onClientPlayerVehicleEnter", localPlayer, setupDriveby )

--Tell the server the clientside script was downloaded and started
addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),
	function()
		--bindKey ( "mouse2", "down", "Toggle Driveby", "" )
		--bindKey ( "e", "down", "Next driveby weapon", "1" )
		--bindKey ( "q", "down", "Previous driveby weapon", "-1" )
		--toggleControl ( "vehicle_next_weapon",false )
		--toggleControl ( "vehicle_previous_weapon",false )
		triggerServerEvent ( "driveby_clientScriptLoaded", localPlayer )
		--helpText = dxText:create("",0.5,0.85)
		--helpText:scale(1)
		--helpText:type("stroke",1)
	end
)

addEventHandler("onClientResourceStop",getResourceRootElement(getThisResource()),
	function()
		--toggleControl ( "vehicle_next_weapon",true )
		--toggleControl ( "vehicle_previous_weapon",true )
	end
)

--Get the settings details from the server, and act appropriately according to them
addEvent ( "doSendDriveBySettings", true )
addEventHandler("doSendDriveBySettings",localPlayer,
	function(newSettings)
		settings = newSettings
		--We change the blocked vehicles into an indexed table that's easier to check
		local newTable = {}
		for key,vehicleID in ipairs(settings.blockedVehicles) do
			newTable[vehicleID] = true
		end
		settings.blockedVehicles = newTable
	end
)

local doingDriveBY = false

local convert = {
    [0] = 4,
    [1] = 2,
    [2] = 5,
    [3] = 3,
}

--This function handles the driveby toggling key.
function toggleDriveby(b, s)
    if string.lower(b) ~= "x" or not s then return end
    if isChatBoxInputActive() then return end
    if boneBreaked(localPlayer) then return end
	--If he's not in a vehicle dont bother
	if not isPedInVehicle( localPlayer ) then return end
    if getPedOccupiedVehicleSeat(localPlayer) == 0 then return end
	--If its a blocked vehicle dont allow it
    local veh = getPedOccupiedVehicle(localPlayer)
	local vehicleID = getElementModel(veh)
	if settings.blockedVehicles[vehicleID] then return end
    local weaponDatas = localPlayer:getData("weaponDatas")
    
    if not doingDriveBY then
        --Has he got a weapon equiped?
        --Decide whether he is a driver or passenger
        if ( driver ) then weaponsTable = settings.driver
        else weaponsTable = settings.passenger end
        --local isWindowableVeh = exports['cr_vehicle']:isWindowableVeh(getElementModel(veh))
        local convertSeatIntoName = {
            ["door_lf_dummy"] = true,
            ["door_rf_dummy"] = true,
            ["door_lr_dummy"] = true,
            ["door_rr_dummy"] = true,
        }
        local windowSeatName = convertSeatIntoName[getPedOccupiedVehicleSeat(localPlayer)]
        if windowSeatName and getVehicleComponentVisible(getPedOccupiedVehicle(localPlayer, windowSeatName)) then
            local num = convert[getPedOccupiedVehicleSeat(localPlayer)]
            if not getElementData(veh, "veh >> window"..num.."State") then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "Csak lehúzott ablaknál tudsz kihajolni!",255,255,255,true)
                return
            end
        end
        --We need to get the switchTo weapon by finding any valid IDs
        local equipedWeapon = getPedWeapon( localPlayer )
        local enabledTable = {}
        local switchTo = false
        for k,v in pairs(weaponsTable) do
            --outputChatBox(v)
            enabledTable[v] = true
        end
        --outputChatBox(equipedWeapon .. "S")
        if equipedWeapon ~= 0 and enabledTable[equipedWeapon] then
            local ammo = getPedTotalAmmo(localPlayer)
            if ammo >= 1 then
                local slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData = unpack(weaponDatas)
                local slot2, data = unpack(hasData) 
                if ammo <= 0 then
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "Csak betárazott fegyverrel tudsz tudsz kihajolni!",255,255,255,true)
                    return
                end
                
                if getElementData(localPlayer, "taser>obj") then
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "Sokkolóval kihajolni nem tudsz",255,255,255,true)
                    return
                end
                
                local slot = getSlotFromWeapon(equipedWeapon)
                local oSlot = getPedWeaponSlot(localPlayer)
                triggerServerEvent("useDriveBY", localPlayer, localPlayer, oSlot)
                --setPedWeaponSlot(localPlayer, 0)
                --setPedWeaponSlot(localPlayer, oSlot)
                switchTo = slot
                switchToWeapon = equipedWeapon
            else
                return
            end    
        else
            return
        end
    --[[
	if equipedWeapon ~= 0 then
		--Decide whether he is a driver or passenger
		if ( driver ) then weaponsTable = settings.driver
		else weaponsTable = settings.passenger end
		--We need to get the switchTo weapon by finding any valid IDs
		local switchTo
		local switchToWeapon
		local lastSlotAmmo = getPedTotalAmmo ( localPlayer, lastSlot )
		if not lastSlotAmmo or lastSlotAmmo == 0 or getSlotFromWeapon(getPedWeapon (localPlayer,lastSlot)) == 0 then
			for key,weaponID in ipairs(weaponsTable) do
				local slot = getSlotFromWeapon ( weaponID )
				local weapon = getPedWeapon ( localPlayer, slot )
				if weapon == 1 then weapon = 0 end --If its a brass knuckle, set it to a fist to avoid confusion
				--if the weapon the player has is valid
				if weapon == weaponID then
					--If the ammo isn't 0
					if getPedTotalAmmo ( localPlayer, slot ) ~= 0 then
						--If no switchTo slot was defined, or the slot was 4 (SMG slot takes priority)
						if not switchTo or slot == 4 then
							switchTo = slot
							switchToWeapon = weaponID
						end
					end
				end
			end
		else
			local lastSlotWeapon = getPedWeapon ( localPlayer, lastSlot )
			for key,weaponID in ipairs(weaponsTable) do --If our last used weapon is a valid weapon
				if weaponID == lastSlotWeapon then
					switchTo = lastSlot
					switchToWeapon = lastSlotWeapon
					break
				end
			end
		end
        --]]
		--If a valid weapon was not found, dont set anything.
		if not switchTo then return end
        doingDriveBY = true
        setElementData(localPlayer, "pulling", true)
--		setPedDoingGangDriveby ( localPlayer, true )
		--setPedWeaponSlot( localPlayer, switchTo )
		--Setup our driveby limiter
		limitDrivebySpeed ( switchToWeapon )
		--Disable look left/right keys, they seem to become accelerate/decelerate (carried over from PS2 version)
		--toggleControl ( "vehicle_look_left",false )
		--toggleControl ( "vehicle_look_right",false )
		--toggleControl ( "vehicle_secondary_fire",false )
		toggleTurningKeys(vehicleID,false)
		addEventHandler ( "onClientPlayerVehicleExit",localPlayer,removeKeyToggles )
        --[[
		local prevw,nextw = next(getBoundKeys ( "Previous driveby weapon" )),next(getBoundKeys ( "Next driveby weapon" ))
		if prevw and nextw then
			if animation then Animation:remove() end
			helpText:text( "Press '"..prevw.."' or '"..nextw.."' to change weapon" )
			fadeInHelp()
			setTimer ( fadeOutHelp, 10000, 1 )
		end
        ]]
	else
        doingDriveBY = false
		--If so, unequip it
		setPedDoingGangDriveby ( localPlayer, false )
        setElementData(localPlayer, "pulling", false)
		--setPedWeaponSlot( localPlayer, 0 )
		limitDrivebySpeed ( switchToWeapon )
		----toggleControl ( "vehicle_look_left",true )
		----toggleControl ( "vehicle_look_right",true )
		----toggleControl ( "vehicle_secondary_fire",true )
		toggleTurningKeys(vehicleID,true)
		--fadeOutHelp()
		removeEventHandler ( "onClientPlayerVehicleExit",localPlayer,removeKeyToggles )
	end
end
addEventHandler("onClientKey", root, toggleDriveby)
--addCommandHandler ( "Toggle Driveby", toggleDriveby )

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName)
        if dName == "char >> bone" then
            local value = getElementData(source, dName)
            if not value[2] or not value[3] then
                if getElementData(source, "pulling") then
                    doingDriveBY = false
                    setPedDoingGangDriveby ( localPlayer, false )
                    setElementData(localPlayer, "pulling", false)
                    limitDrivebySpeed ( switchToWeapon )
                    --toggleControl ( "vehicle_look_left",true )
                    --toggleControl ( "vehicle_look_right",true )
                    --toggleControl ( "vehicle_secondary_fire",true )
                    toggleTurningKeys(vehicleID,true)
                    fadeOutHelp()
                    removeEventHandler ( "onClientPlayerVehicleExit",localPlayer,removeKeyToggles)
                end
            end
        elseif dName == "pulling" then
            local value = getElementData(source, dName)
            doingDriveBY = value
        end
    end
)

addEvent("offDriveby", true)
addEventHandler("offDriveby", root,
    function()
        if getElementData(source, "pulling") then
            doingDriveBY = false
            setPedDoingGangDriveby ( localPlayer, false )
            setElementData(localPlayer, "pulling", false)
            limitDrivebySpeed ( switchToWeapon )
            --toggleControl ( "vehicle_look_left",true )
            --toggleControl ( "vehicle_look_right",true )
            --toggleControl ( "vehicle_secondary_fire",true )
            toggleTurningKeys(vehicleID,true)
            fadeOutHelp()
            removeEventHandler ( "onClientPlayerVehicleExit",localPlayer,removeKeyToggles)
        end
    end
)

function removeKeyToggles(vehicle)
	--toggleControl ( "vehicle_look_left",true )
	--toggleControl ( "vehicle_look_right",true )
	--toggleControl ( "vehicle_secondary_fire",true )
	toggleTurningKeys(getElementModel(vehicle),true)
	fadeOutHelp()
    doingDriveBY = false
    setElementData(localPlayer, "pulling", false)
	removeEventHandler ( "onClientPlayerVehicleExit",localPlayer,removeKeyToggles )
end


--This function handles the driveby switch weapon key
function switchDrivebyWeapon(key,progress)
	progress = tonumber(progress)
	if not progress then return end
	--If the fire button is being pressed dont switch
	if shooting then return end
	--If he's not in a vehicle dont bother
	if not isPedInVehicle( localPlayer ) then return end
	--If he's not in driveby mode dont bother either
	local currentWeapon = getPedWeapon( localPlayer )
	if currentWeapon == 1 then currentWeapon = 0 end --If its a brass knuckle, set it to a fist to avoid confusion
	local currentSlot = getPedWeaponSlot(localPlayer)
	if currentSlot == 0 then return end
	if ( driver ) then weaponsTable = settings.driver
	else weaponsTable = settings.passenger end
	--Compile a list of the player's weapons
	local switchTo
	for key,weaponID in ipairs(weaponsTable) do
		if weaponID == currentWeapon then
			local i = key + progress
			--We keep looping the table until we go back to our original key
			while i ~= key do
				nextWeapon = weaponsTable[i]
				if nextWeapon then
					local slot = getSlotFromWeapon ( nextWeapon )
					local weapon = getPedWeapon ( localPlayer, slot )
					if ( weapon == nextWeapon  ) then
						switchToWeapon = weapon
						switchTo = slot
						break
					end
				end
				--Go back to the beginning if there is no valid weapons left in the table
				if not weaponsTable[i+progress] then
					if progress < 0 then
						i = #weaponsTable
					else
						i = 1
					end
				else
					i = i + progress
				end
			end
			break
		end
	end
	--If a valid weapon was not found, dont set anything.
	if not switchTo then return end
	lastSlot = switchTo
	--setPedWeaponSlot( localPlayer, switchTo )
	limitDrivebySpeed ( switchToWeapon )
end
--addCommandHandler ( "Next driveby weapon", switchDrivebyWeapon )
--addCommandHandler ( "Previous driveby weapon", switchDrivebyWeapon )

--Here lies the stuff that limits shooting speed (so slow weapons dont shoot ridiculously fast)
local limiterTimer
function limitDrivebySpeed ( weaponID )
	local speed = settings.shotdelay[tostring(weaponID)]
	if not speed then 
		if not isControlEnabled ( "vehicle_fire" ) then 
			--toggleControl ( "vehicle_fire", true )
		end
		removeEventHandler("onClientPlayerVehicleExit",localPlayer,unbindFire)
		removeEventHandler("onClientPlayerWasted",localPlayer,unbindFire)
		unbindKey ( "vehicle_fire", "both", limitedKeyPress )
	else
		if isControlEnabled ( "vehicle_fire" ) then 
			--toggleControl ( "vehicle_fire", false )
			addEventHandler("onClientPlayerVehicleExit",localPlayer,unbindFire)
			addEventHandler("onClientPlayerWasted",localPlayer,unbindFire)
			bindKey ( "vehicle_fire","both",limitedKeyPress,speed)
		end
	end
end

function unbindFire()
	unbindKey ( "vehicle_fire", "both", limitedKeyPress )
	if not isControlEnabled ( "vehicle_fire" ) then 
			--toggleControl ( "vehicle_fire", true )
	end
	removeEventHandler("onClientPlayerVehicleExit",localPlayer,unbindFire)
	removeEventHandler("onClientPlayerWasted",localPlayer,unbindFire)
end

local block
function limitedKeyPress (key,keyState,speed)
	if keyState == "down" then
		if block == true then return end
		shooting = true
		pressKey ( "vehicle_fire" )
		block = true
		setTimer ( function() block = false end, speed, 1 )
		limiterTimer = setTimer ( pressKey,speed, 0, "vehicle_fire" )
	else
		shooting = false
		for k,timer in ipairs(getTimers()) do
			if timer == limiterTimer then
				killTimer ( limiterTimer )
			end
		end
	end
end

function pressKey ( controlName )
	setControlState ( controlName, true )
	setTimer ( setControlState, 150, 1, controlName, false )
end

---Left/right toggling
local bikes = { [581]=true,[509]=true,[481]=true,[462]=true,[521]=true,[463]=true,
	[510]=true,[522]=true,[461]=true,[448]=true,[468]=true,[586]=true }
function toggleTurningKeys(vehicleID, state)
	if bikes[vehicleID] then
		if not settings.steerBikes then
			--toggleControl ( "vehicle_left", state )
			--toggleControl ( "vehicle_right", state )
		end
	else
		if not settings.steerCars then
			--toggleControl ( "vehicle_left", state )
			--toggleControl ( "vehicle_right", state )
		end
	end
end
	
function fadeInHelp()
    --[[
	if helpAnimation then helpAnimation:remove() end
	local _,_,_,a = helpText:color()
	if a == 255 then return end
	helpAnimation = Animation.createAndPlay(helpText, Animation.presets.dxTextFadeIn(300))
	setTimer ( function() helpText:color(255,255,255,255) end, 300, 1 )
    ]]
end

function fadeOutHelp()
    --[[
	if helpAnimation then helpAnimation:remove() end
	local _,_,_,a = helpText:color()
	if a == 0 then return end
	helpAnimation = Animation.createAndPlay(helpText, Animation.presets.dxTextFadeOut(300))
	setTimer ( function() helpText:color(255,255,255,0) end, 300, 1 )
    ]]
end

local function onWeaponSwitchWhileDriveby (prevSlot, curSlot)
	if isPedDoingGangDriveby(source) then	
		limitDrivebySpeed(getPedWeapon(source, curSlot))
	end
end
addEventHandler ("onClientPlayerWeaponSwitch", localPlayer, onWeaponSwitchWhileDriveby)
