local driver = false
local shooting = false
local helpText,helpAnimation
lastSlot = 0
settings = {}

function boneBreaked(e)
    local bone = getElementData(e, "char >> bone") or {true, true, true, true, true}
    if not bone[2] or not bone[3] then 
        return true
    end
    return false
end

local function setupDriveby(player, seat)
	if seat == 0 then 
		driver = true
	else
		driver = false
	end
end
addEventHandler( "onClientPlayerVehicleEnter", localPlayer, setupDriveby )

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		triggerServerEvent ( "driveby_clientScriptLoaded", localPlayer )
	end
)

addEvent ( "doSendDriveBySettings", true )
addEventHandler("doSendDriveBySettings",localPlayer,
	function(newSettings)
		settings = newSettings
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

function toggleDriveby(b, s)
    if string.lower(b) ~= "x" or not s then return end
    if isChatBoxInputActive() then return end
    if boneBreaked(localPlayer) then return end
	if not isPedInVehicle( localPlayer ) then return end
    if getPedOccupiedVehicleSeat(localPlayer) == 0 then return end
    local veh = getPedOccupiedVehicle(localPlayer)
	local vehicleID = getElementModel(veh)
	if settings.blockedVehicles[vehicleID] then return end
    local weaponDatas = localPlayer:getData("weaponDatas")
    
    if not doingDriveBY then
        if ( driver ) then weaponsTable = settings.driver
        else weaponsTable = settings.passenger end
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
        local equipedWeapon = getPedWeapon( localPlayer )
        local enabledTable = {}
        local switchTo = false
        for k,v in pairs(weaponsTable) do
            enabledTable[v] = true
        end
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
                switchTo = slot
                switchToWeapon = equipedWeapon
            else
                return
            end    
        else
            return
        end
		if not switchTo then return end
        doingDriveBY = true
		setElementData(localPlayer, "pulling", true)
		exports['cr_crosshair']:toggleCrosshair(_, "down")
		limitDrivebySpeed ( switchToWeapon )
		addEventHandler ( "onClientPlayerVehicleExit",localPlayer,removeKeyToggles )
		exports['cr_chat']:createMessage(localPlayer, "kihajol az ablakon", 1)
	else
        doingDriveBY = false
		setPedDoingGangDriveby ( localPlayer, false )
		setElementData(localPlayer, "pulling", false)
		exports['cr_chat']:createMessage(localPlayer, "visszahajol a kocsiba", 1)
		exports['cr_crosshair']:toggleCrosshair(_, "up")
		limitDrivebySpeed ( switchToWeapon )
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
					exports['cr_chat']:createMessage(localPlayer, "visszahajol a kocsiba", 1)
					exports['cr_crosshair']:toggleCrosshair(_, "up")
                    limitDrivebySpeed ( switchToWeapon )
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
			exports['cr_chat']:createMessage(localPlayer, "visszahajol a kocsiba", 1)
			exports['cr_crosshair']:toggleCrosshair(_, "up")
            limitDrivebySpeed ( switchToWeapon )
            removeEventHandler ( "onClientPlayerVehicleExit",localPlayer,removeKeyToggles)
        end
    end
)

function removeKeyToggles(vehicle)
    doingDriveBY = false
	setElementData(localPlayer, "pulling", false)
	exports['cr_chat']:createMessage(localPlayer, "visszahajol a kocsiba", 1)
	exports['cr_crosshair']:toggleCrosshair(_, "up")
	removeEventHandler ( "onClientPlayerVehicleExit",localPlayer,removeKeyToggles )
end


function switchDrivebyWeapon(key,progress)
	progress = tonumber(progress)
	if not progress then return end
	if shooting then return end
	if not isPedInVehicle( localPlayer ) then return end
	local currentWeapon = getPedWeapon( localPlayer )
	if currentWeapon == 1 then currentWeapon = 0 end --If its a brass knuckle, set it to a fist to avoid confusion
	local currentSlot = getPedWeaponSlot(localPlayer)
	if currentSlot == 0 then return end
	if ( driver ) then weaponsTable = settings.driver
	else weaponsTable = settings.passenger end
	local switchTo
	for key,weaponID in ipairs(weaponsTable) do
		if weaponID == currentWeapon then
			local i = key + progress
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
	if not switchTo then return end
	lastSlot = switchTo
	limitDrivebySpeed ( switchToWeapon )
end

local limiterTimer
function limitDrivebySpeed ( weaponID )
	local speed = settings.shotdelay[tostring(weaponID)]
	if not speed then 
		removeEventHandler("onClientPlayerVehicleExit",localPlayer,unbindFire)
		removeEventHandler("onClientPlayerWasted",localPlayer,unbindFire)
		unbindKey ( "vehicle_fire", "both", limitedKeyPress )
	else
		if isControlEnabled ( "vehicle_fire" ) then 
			addEventHandler("onClientPlayerVehicleExit",localPlayer,unbindFire)
			addEventHandler("onClientPlayerWasted",localPlayer,unbindFire)
			bindKey ( "vehicle_fire","both",limitedKeyPress,speed)
		end
	end
end

function unbindFire()
	unbindKey ( "vehicle_fire", "both", limitedKeyPress )
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
	setPedControlState ( controlName, true )
	setTimer ( setPedControlState, 150, 1, controlName, false )
end
	
local function onWeaponSwitchWhileDriveby (prevSlot, curSlot)
	if isPedDoingGangDriveby(source) then	
		limitDrivebySpeed(getPedWeapon(source, curSlot))
	end
end
addEventHandler("onClientPlayerWeaponSwitch", localPlayer, onWeaponSwitchWhileDriveby)
