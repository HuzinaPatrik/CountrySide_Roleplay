local function drawnIcon(x, y, icon)
    dxDrawImage(x - 30/2, y - 30/2, 30, 30, "stamina/files/"..icon..".png");
end

local id = getElementData(localPlayer, "id") or -1;

local sx, sy = guiGetScreenSize();

staminaIcon = "";
stamina = 100;
staminaMultipler = stamina / 100;

function getElementSpeed2(theElement, unit)
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")");
    local elementType = getElementType(theElement);
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")");
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)");
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit));
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456);
    return math.floor((Vector3(getElementVelocity(theElement)) * mult).length);
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    if getElementData(localPlayer, "loggedIn") then
        addEventHandler("onClientPreRender", root, staminaCheck, true, "low-1");
    end
end);

addEventHandler("onClientElementDataChange", localPlayer, function(dName, oValue)
    if dName == "loggedIn" then
        addEventHandler("onClientPreRender", root, staminaCheck, true, "low-1");
    end
end);

local animed = false
local oneRevive = false

function animOn()
    if not animed then 
        animed = true;
        exports['cr_controls']:toggleAllControls(false, "instant");
        setElementData(localPlayer, "stamina.freeze", true);
        
        setElementData(localPlayer, "forceAnimation", {" ", " "});
        setElementData(localPlayer, "forceAnimation", {"ped", "idle_tired"});
        
        if isTimer(timer1) then killTimer(timer1) end
        if isTimer(timer2) then killTimer(timer2) end
        
        timer1 = setTimer(function()
            setElementData(localPlayer, "forceAnimation", {" ", " "});
            setElementData(localPlayer, "forceAnimation", {"ped", "idle_tired"});
        end, 250, 1);
        
        timer2 = setTimer(function()
            setElementData(localPlayer, "forceAnimation", {" ", " "});
            setElementData(localPlayer, "forceAnimation", {"ped", "idle_tired"});
        end, 500, 1);
    end 
end

function animOff()
    if animed then 
        animed = false
        setElementData(localPlayer, "stamina.freeze", false);
        exports['cr_controls']:toggleAllControls(true, "instant")
        
        if isTimer(timer1) then killTimer(timer1) end
        
        timer1 = setTimer(function()
            setElementData(localPlayer, "forceAnimation", {" ", " "});
            setElementData(localPlayer, "forceAnimation", {"", ""});
        end, 200, 1);
    end
end

lastJumpTick = getTickCount()
bindKey("jump", "down",
    function()
        if lastJumpTick + 1000 > getTickCount() then
            return
        end
        lastJumpTick = getTickCount()
        --outputChatBox("sad")
        if getElementData(localPlayer, "inDeath") then return end
        if not getElementData(localPlayer, "loggedIn") then return end
        local forceAnim = localPlayer:getData("forceAnimation") or {"", ""}
        if forceAnim[1] ~= "" or forceAnim[2] ~= "" then
            forceAnim = true
        else
            forceAnim = false
        end

        local anim = localPlayer:getData("realAnimation")

        setTimer(
            function()
                local speed = getElementSpeed2(localPlayer, "m/s");
                if speed >= 5 then
                    if not localPlayer:getData("admin >> duty") and not localPlayer:getData("parachuting") then
                        if getPedOccupiedVehicle(localPlayer) then return end
                        if localPlayer.contactElement and localPlayer.contactElement.type == "vehicle" then 
                            return 
                        end 
                        if stamina >= 0 then
                            if speed >= 2 then
                                stamina = stamina - 15;
                                if stamina <= 0 then
                                    stamina = 0
                                    if not animed then
                                        animOn()
                                    end
                                end
                            end
                        end
                    end
                end
            end, 250, 1
        )
    end
)

function staminaCheck(frame)
    local multiplier = (20 / frame)

    if getElementData(localPlayer, "inDeath") then return end
    if not getElementData(localPlayer, "loggedIn") then return end
    local forceAnim = localPlayer:getData("forceAnimation") or {"", ""}
    if forceAnim[1] ~= "" or forceAnim[2] ~= "" then
        forceAnim = true
    else
        forceAnim = false
    end
    
    local anim = localPlayer:getData("realAnimation")
    
    local speed = getElementSpeed2(localPlayer, "m/s");

    local multiplier2 = speed / 5

    local _multiplier = multiplier
    local multiplier = (multiplier + multiplier2) / 2
    if speed >= 2 then
        if not localPlayer:getData("admin >> duty") and not localPlayer:getData("parachuting") then
            if getPedControlState("forwards") or getPedControlState("sprint") or anim then
                if getPedOccupiedVehicle(localPlayer) then return end
                if localPlayer.contactElement and localPlayer.contactElement.type == "vehicle" then 
                    return 
                end 
                if stamina >= 0 then
                    if getPedControlState("forwards") or getPedControlState("sprint") or anim then
                        stamina = stamina - (0.02 * multiplier);
                        if stamina <= 0 then
                            stamina = 0
                            if not animed then
                                animOn()
                            end
                        end
                    end
                end
            end
        end    
    else
        if stamina >= 20 and stamina <= 100 then
            stamina = stamina + (0.05 * _multiplier)
            if animed then
                animOff()
            end
        elseif stamina <= 20 then
            stamina = stamina + (0.05 * _multiplier);
        end
    end
end

maxStamina = localPlayer:getData("stamina.max") or 100

function drawnStamina()
    if not getElementData(localPlayer, "hudVisible") then return end
    local enabled,x,y,w,h,sizable,turnable = getDetails("stamina");
    drawnIcon(x - 18, y + h/2, "stamina");
    dxDrawRectangle(x,y, w,h, tocolor(90,90,90,180));
    lineddRectangle(x,y, w,h, tocolor(0,0,0,0), tocolor(0,0,0,200));
    staminaMultipler = (stamina / maxStamina);
    dxDrawRectangle(x, y, w * staminaMultipler, h, tocolor(255, 255, 255,200));
end

function getStamina()
    return stamina;
end

local walkingEnabled = true 

function changeWalkingStatus(e)
    walkingEnabled = e
end 

setTimer(function()
    if not localPlayer.vehicle then 
        if getPedWeapon(localPlayer) ~= 0 then 
            if getPedControlState("aim_weapon") then 
                setPedControlState("walk", true);
                return
            end 
        end 

        if walkingEnabled then 
            if not getKeyState('lalt') then 
                setPedControlState("walk", true);
            else 
                setPedControlState("walk", false);
            end 
        else 
            if not getKeyState('lalt') then 
                setPedControlState("walk", false);
            else 
                setPedControlState("walk", true);
            end 
        end 
    end
end, 125, 0);

function onKey(button, press)
    if button == 'lalt' and press then
        if not localPlayer.vehicle then 
            if not localPlayer:getData('keysDenied') then 
                if walkingEnabled then 
                    setPedControlState("walk", false);
                else 
                    setPedControlState("walk", true);
                end 

                cancelEvent()
            end 
        end
    end
end
addEventHandler("onClientKey", root, onKey)

bindKey("forwards", "down", 
    function()
        if getPedWeapon(localPlayer) ~= 0 then 
            if getPedControlState("aim_weapon") then 
                setPedControlState("walk", false);
                return
            end 
        end 
    end 
)

bindKey("aim_weapon", "down", 
    function()
        if getPedWeapon(localPlayer) ~= 0 then 
            if getPedControlState("aim_weapon") then 
                setPedControlState("walk", false);
                return
            end 
        end 
    end 
)

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue, nValue)
        if dName == "stamina.max" and source == localPlayer then
            maxStamina = nValue
        end
    end
)