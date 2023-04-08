--[[
char >> bone felépítése = {Has, Bal kéz, Jobb kéz, Bal láb, Jobb láb}
]]

local damageTypes = {
	[19] = "Rocket",
	[37] = "Burnt",
	[49] = "Rammed",
	[50] = "Ranover/Helicopter Blades",
	[51] = "Explosion",
	[52] = "Driveby",
	[53] = "Drowned",
	[54] = "Fall",
	[55] = "Unknown",
	[56] = "Melee",
	--[57] = "Weapon",
	[59] = "Tank Grenade",
	[63] = "Blown"
}

local disabledWeapon = {
    --1,2,3,4,5,6,7,14,15,10,11,12
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [14] = true,
    [15] = true,
    [19] = true,
    [59] = true,
    [35] = true,
    [36] = true,
    [37] = true,
    [38] = true,
    [39] = true,
    [40] = true,
    [17] = true,
    [41] = true,
    [42] = true,
}

addEventHandler("onClientPlayerDamage", localPlayer,
    function(attacker, weapon, bodypart, loss)
        if not getElementData(localPlayer, "loggedIn") then return end
        if getElementData(localPlayer, "admin >> duty") then return end
        if getElementData(localPlayer, "inDeath") then
            cancelEvent()
            return
        end

        if localPlayer:getData("char >> tazed") then
            return
        end

        if attacker and attacker:getData("taser>obj") then return end

        --if getElementType(attacker) == "player" then
        local newBone = getElementData(localPlayer, "char >> bone") or {true, true, true, true, true}
        if weapon == 54 then
            if not loss then 
                loss = 0 
            end
            if loss > 10 and loss < 20 then
                if newBone[4] then
                    newBone[4] = false
                    exports['cr_infobox']:addBox("warning", "Eltörted a Bal lábadat!")
                else
                    if newBone[5] then
                        newBone[5] = false
                        exports['cr_infobox']:addBox("warning", "Eltörted a Jobb lábadat!")
                        triggerServerEvent("anim - give", localPlayer, localPlayer, {"ped", "KO_shot_front", 500, false, true, true}, true)
                        localPlayer:setData("falled>2legs", true)
                    end
                end
                setElementData(localPlayer, "char >> bone", newBone)
            elseif loss > 20 then
                local d = false
                if newBone[4] then
                    newBone[4] = false
                    d = true
                end
                if newBone[5] then
                    newBone[5] = false
                    d = true
                end
                if d then
                    exports['cr_infobox']:addBox("warning", "Eltörted mindkét lábadat a nagy esés következtében!")
                    setElementData(localPlayer, "char >> bone", newBone)
                    
                    triggerServerEvent("anim - give", localPlayer, localPlayer, {"ped", "KO_shot_front", 500, false, true, true}, true)
                    localPlayer:setData("falled>2legs", true)
                end
            end
        elseif bodypart == 5 then -- Bal kéz
            if newBone[2] then
                local num = tonumber(getElementData(localPlayer, "bone2 >> chance")) or 2 -- "Def: 50%" / Ha ez 4 akk már csak 25
                local chance = math.random(1, num)
                if num == 2 then
                    newBone[2] = false
                    setElementData(localPlayer, "char >> bone", newBone)
                    exports['cr_infobox']:addBox("warning", "Eltörted a Bal kezedet!")
                    --outputChatBox("Asd")
                end
            end
        elseif bodypart == 6 then -- Jobb kéz
            if newBone[3] then
                local num = tonumber(getElementData(localPlayer, "bone3 >> chance")) or 2 -- "Def: 50%" / Ha ez 4 akk már csak 25
                local chance = math.random(1, num)
                if num == 2 then
                    newBone[3] = false
                    setElementData(localPlayer, "char >> bone", newBone)
                    exports['cr_infobox']:addBox("warning", "Eltörted a Jobb kezedet!")
                end    
            end
        elseif bodypart == 7 then -- Bal láb
            if newBone[4] then
                local num = tonumber(getElementData(localPlayer, "bone4 >> chance")) or 2 -- "Def: 50%" / Ha ez 4 akk már csak 25
                local chance = math.random(1, num)
                if num == 2 then
                    newBone[4] = false
                    setElementData(localPlayer, "char >> bone", newBone)
                    exports['cr_infobox']:addBox("warning", "Eltörted a Bal lábadat!")
                    
                    if not newBone[4] and not newBone[5] then
                        triggerServerEvent("anim - give", localPlayer, localPlayer, {"ped", "KO_shot_front", 500, false, true, true}, true)
                        localPlayer:setData("falled>2legs", true)
                    end
                end
            end
        elseif bodypart == 8 then -- Jobb láb
            if newBone[5] then
                local num = tonumber(getElementData(localPlayer, "bone5 >> chance")) or 2 -- "Def: 50%" / Ha ez 4 akk már csak 25
                local chance = math.random(1, num)
                if num == 2 then
                    newBone[5] = false
                    setElementData(localPlayer, "char >> bone", newBone)
                    exports['cr_infobox']:addBox("warning", "Eltörted a Jobb lábadat!")
                    
                    if not newBone[4] and not newBone[5] then
                        triggerServerEvent("anim - give", localPlayer, localPlayer, {"ped", "KO_shot_front", 500, false, true, true}, true)
                        localPlayer:setData("falled>2legs", true)
                    end
                end
            end
        end
        --end
    end
)

function getNearestVeh()
    local nearest, nearestE = 9999
    for k,v in pairs(getElementsByType("vehicle", _, true))  do
        local dist = getDistanceBetweenPoints3D(localPlayer.position, v.position)
        if dist <= nearest and dist <= 2.5 then
            nearest = dist
            nearestE = v
        end
    end
    
    return nearest, nearestE
end

function checkPedTask()
    if fight and fightE and isElement(fightE) and fightE.type == "vehicle" then
        local nowHp = fightE.health
        if oldHp ~= nowHp then -- nem egyenlő a 2 érték és legalább 2 hpval kevesebb
            if not getElementData(localPlayer, "loggedIn") then return end
            if getElementData(localPlayer, "admin >> duty") then return end
            if getElementData(localPlayer, "inDeath") then
                cancelEvent()
                return
            end

            if getPedWeapon(localPlayer) ~= 0 then 
                return 
            end

            local x,y,z = getElementPosition(fightE)
            local px,py,pz = getElementPosition(localPlayer)
            local newBone = getElementData(localPlayer, "char >> bone") or {true, true, true, true, true}
            if pz > z + 0.5 then
                local attackOnHand = getElementData(localPlayer, "attackOnHand") or 0
                attackOnHand = attackOnHand + 1
                setElementData(localPlayer, "attackOnHand", attackOnHand)
                if attackOnHand >= 2 then
                    if newBone[4] then
                        newBone[4] = false
                        setElementData(localPlayer, "char >> bone", newBone)
                        exports['cr_infobox']:addBox("warning", "Eltörted a Bal lábad!")
                        setElementData(localPlayer, "attackOnHand", 0)
                    else
                        if newBone[5] then
                            newBone[5] = false
                            setElementData(localPlayer, "char >> bone", newBone)
                            exports['cr_infobox']:addBox("warning", "Eltörted a Jobb lábad!")
                            setElementData(localPlayer, "attackOnHand", 0)
                            
                            if not newBone[4] and not newBone[5] then
                                triggerServerEvent("anim - give", localPlayer, localPlayer, {"ped", "KO_shot_front", 500, false, true, true}, true)
                                localPlayer:setData("falled>2legs", true)
                            end
                        end
                    end
                end
            else
                local attackOnHand = getElementData(localPlayer, "attackOnHand") or 0
                attackOnHand = attackOnHand + 1
                setElementData(localPlayer, "attackOnHand", attackOnHand)
                if attackOnHand >= 2 then
                    if newBone[2] then
                        newBone[2] = false
                        setElementData(localPlayer, "char >> bone", newBone)
                        exports['cr_infobox']:addBox("warning", "Eltörted a Bal kezedet!")
                        setElementData(localPlayer, "attackOnHand", 0)
                    else
                        if newBone[3] then
                            newBone[3] = false
                            setElementData(localPlayer, "char >> bone", newBone)
                            exports['cr_infobox']:addBox("warning", "Eltörted a Jobb kezedet!")
                            setElementData(localPlayer, "attackOnHand", 0)
                        end
                    end
                end
            end
        end
        
        fight = false
    end
    
    for k=0,5 do
        local task,b,c,d = getPedTask ( getLocalPlayer(), "secondary", k )
        if task then
            if string.lower(task) == string.lower("TASK_SIMPLE_FIGHT") then
                local target = getPedTarget(localPlayer)
                local dist, veh = getNearestVeh()
                
                if not target or not isElement(target) then
                    target = veh    
                end
                
                if target and isElement(target) then
                    if target.type == "vehicle" then
                        fight = true
                        fightE = target
                        oldHp = fightE.health
                    end
                end
            end
        end
    end
end
setTimer(checkPedTask, 400, 0)

function toggleMoveControls(value)
    exports['cr_controls']:toggleControl("forwards", value, "medium")
    exports['cr_controls']:toggleControl("backwards", value, "medium")
    exports['cr_controls']:toggleControl("left", value, "medium")
    exports['cr_controls']:toggleControl("right", value, "medium")
    exports['cr_controls']:toggleControl("jump", value, "medium")
    exports['cr_controls']:toggleControl("fire", value, "medium")
    exports['cr_controls']:toggleControl("aim_weapon", value, "medium")
    exports['cr_controls']:toggleControl("enter_exit", value, "medium")
    exports['cr_controls']:toggleControl("action", false, "medium")
end

function boneSync(dName, oValue, nValue)
    if not localPlayer:getData("loggedIn") then 
        return 
    end 
    --outputChatBox(dName)
    if dName == "char >> bone" then
        --outputChatBox("asd")
        local value = getElementData(source, dName)
        --outputChatBox(toJSON(value))

        if value[4] or value[5] then -- Bal és Jobb láb megjavult -- Tud mozogni, futni újra
            toggleMoveControls(true) 
        end

        if not value[2] and not value[3] then -- Bal és Jobb kéz eltörve -- Nem tud lőni
            exports['cr_controls']:toggleControl("fire", false, "medium")
            exports['cr_controls']:toggleControl("action", false, "medium")
            --exports['cr_infobox']:addBox("error", "Mivel eltörted mindkét kezed nem tudsz lőni!")
        end

        if value[2] or value[3] then -- Bal és Jobb kéz megjavult -- Tud lőni, célozni újra
            exports['cr_controls']:toggleControl("aim_weapon", true, "medium")
            exports['cr_controls']:toggleControl("action", false, "medium")
        end

        if value[2] and value[3] then
            exports['cr_controls']:toggleControl("fire", true, "medium")
            exports['cr_controls']:toggleControl("action", false, "medium")
        end

        if not value[4] and not value[5] then -- Bal és Jobb láb eltörve -- Nem tud mozogni
            toggleMoveControls(false) 
            --exports['cr_infobox']:addBox("error", "Mivel eltörted mindkét kezed nem tudsz mozogni!")
        end

        if value[4] and value[5] then
            if localPlayer:getData("falled>2legs") then
                setElementData(localPlayer, "falled>2legs", nil)
                setElementData(localPlayer, "forceAnimation", {"", ""})
            end
            exports['cr_controls']:toggleControl("sprint", true, "medium")
        end

        if value[4] or value[5] then
            if localPlayer:getData("falled>2legs") then
                setElementData(localPlayer, "falled>2legs", nil)
                setElementData(localPlayer, "forceAnimation", {"", ""})
            end
        end

        if not value[4] and not value[5] then
            if value[1] and not localPlayer:getData("falled>2legs") then
                triggerServerEvent("anim - give", localPlayer, localPlayer, {"ped", "KO_shot_front", 500, false, true, true}, true)
                localPlayer:setData("falled>2legs", true)
            end
        end

        if not value[2] then
            exports['cr_controls']:toggleControl("aim_weapon", false, "medium")
            exports['cr_controls']:toggleControl("action", false, "medium")
        end

        if not value[3] then
            exports['cr_controls']:toggleControl("aim_weapon", false, "medium")
            exports['cr_controls']:toggleControl("action", false, "medium")
        end

        if not value[4] then
            exports['cr_controls']:toggleControl("sprint", false, "medium")
            exports['cr_controls']:toggleControl("jump", false, "medium")
        end

        if not value[5] then
            exports['cr_controls']:toggleControl("sprint", false, "medium")
            exports['cr_controls']:toggleControl("jump", false, "medium")
        end
    end
end
addEventHandler("onClientElementDataChange", localPlayer, boneSync)

local white = "#ffffff"

addCommandHandler("agyogyit", 
    function(cmd, target)
        if exports['cr_permission']:hasPermission(localPlayer, cmd) then
            if not target then
                local syntax = exports['cr_core']:getServerSyntax(false, "warning")
                outputChatBox(syntax .. "/"..cmd.." [target]", 255,255,255,true)
                return
            else
                local target = exports['cr_core']:findPlayer(localPlayer, target)
                if target then
                    setElementData(target, "char >> bone", {true, true, true, true, true})
                    --resetBone()
                    --toggleMoveControls(true)
                    setElementData(target, "attackOnHand", 0)
                    setElementData(target, "torsoAmmo", 0)
                    setElementData(target, "drunkLevel", 0)
                    setElementData(target, "bloodData", {})
                    setElementData(target, "isRespawning", false)
                    setElementData(target, "isRespawningE", false)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local syntax2 = exports['cr_admin']:getAdminSyntax()
                    local name = exports['cr_admin']:getAdminName(target)
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local hexColor = exports['cr_core']:getServerColor('yellow', true)
                    outputChatBox(syntax .. "Sikeresen meggyógyítottad "..hexColor..name..white.." játékost!", 255,255,255,true)
                    local text = syntax2 .. ""..hexColor..aName..white.." meggyógyította "..hexColor..name..white.." játékost!"
                    exports['cr_core']:sendMessageToAdmin(localPlayer, text, 3)
                    local text = syntax .. "Meggyógyított "..hexColor..aName..white.."!"
                    triggerServerEvent("anim - give", localPlayer, target, {"", ""})
                    triggerServerEvent("health - give", localPlayer, target, true)
                    triggerServerEvent("outputChatBox", localPlayer, target, text)
                end
            end
        end
    end
)