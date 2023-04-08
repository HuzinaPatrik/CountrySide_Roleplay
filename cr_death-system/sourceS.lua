local damage = {
    [4] = 100,
    [8] = 100,
    [22] = 15,
    [23] = 15,
    [24] = 25,
    [25] = 40,
    [26] = 40,
    [27] = 50,
    [28] = 15,
    [32] = 15,
    [29] = 20,
    [30] = 35,
    [31] = 35,
    [33] = 60,
    [34] = 80, 
}

function playerDamage(attacker, weapon, bodypart, loss)
	if bodypart == 9 and getPedArmor(source) == 0 then
	    killPed(source, attacker, weapon, bodypart)
        setElementData(source, "char >> headless", true)
    elseif weapon == 8 then
        killPed(source, attacker, weapon, bodypart)
        setElementData(source, "char >> headless", true)
    elseif bodypart == 9 then
        local armor = getPedArmor(source)
        armor = armor - damage[weapon]
        if armor <= 0 then
            armor = 0
        end
        setPedArmor(source, armor)
	end
end
addEventHandler("onPlayerDamage", root, playerDamage)

addEvent("collisions", true)
addEventHandler("collisions", root,
    function(e, s)
        if e and isElement(e) then
            if not s then
                e.alpha = 180
            else
                e.alpha = 255
            end
            --setElementCollisionsEnabled(e, s)
        end
    end
)

local clones = {}

function createClone(e)
    if not clones[e] then 
        local ped = Ped(e.model, e.position, e.rotation.z)
        ped.dimension = e.dimension 
        ped.interior = e.interior 

        ped:setData("parent", e)
        ped:setData("char >> id", e:getData("char >> id"))
        ped:setData("acc >> id", e:getData("acc >> id"))
        ped:setData("char >> name", e:getData("char >> name"))

        ped:setData("deathReason", e:getData("deathReason"))
        ped:setData("deathReason >> admin", e:getData("deathReason >> admin"))

        ped.headless = e.headless
        ped.frozen = true 
        ped:setData("char >> noDamage", true)

        setTimer(setPedAnimation, 250, 1, ped, "ped", "floor_hit_f", -1, false, false, false, true)

        e:setData("clone", ped)

        clones[e] = ped
    end 
end 

function destroyClone(e)
    if clones[e] then 
        clones[e]:destroy()
        clones[e] = nil 
        e:setData("clone", nil)
        collectgarbage("collect")
    end 
end 

function readyToMoveInNewWorld(e)
    local e = e
    e:removeFromVehicle()
    local skinid = getElementModel(e)
    local x,y,z = getElementPosition(e)
    local interior = getElementInterior(e)
    createClone(e)
    setElementData(e, "char >> death", true)
    setElementData(e, "inDeath", true)
    spawnPlayer(e, x,y,z + 1, 0, skinid)
    e:setData("char >> noDamage", true)
    setElementAlpha(e, 100)

    setElementDimension(e, getElementData(e, "acc >> id"))
    setElementInterior(e, interior)
    setElementFrozen(e, true)
    setTimer(
        function()
            if isElement(e) then
                setElementCollisionsEnabled(e, true)
                setElementFrozen(e, false)
            end
        end, 7000, 1
    )
end
addEvent("readyToMoveInNewWorld", true)
addEventHandler("readyToMoveInNewWorld", root, readyToMoveInNewWorld)

function goToMedical(e, time, x,y,z)
    local dim, int = e.dimension, e.interior
    if not x or not y or not z then
        x,y,z = 1246.6495361328, 337.12835693359, 19.5546875
        dim, int = 0, 0
    end
    
    triggerClientEvent(e, "Clear -> DeathEffect", e, e)
    triggerClientEvent(e, "stopTazedEffect", e, e)
    local skinid = getElementModel(e)
    setElementData(e, "char >> death", false)
    setElementData(e, "char >> bone", {true, true, true, true, true})
    setElementData(e, "bulletsInBody", {})
    setElementData(e, "bloodData", {})
    setElementData(e, "inDeath", false)

    if isPedDead(e) then
        spawnPlayer(e, x,y,z)
    end

    local skin = getElementData(e, "char >> skin")
    setElementModel(e, skin)
    e:setData("char >> noDamage", false)
    setElementData(e, "char >> belt", false)
    --setElementData(e, "")
    setElementPosition(e, x, y, z+0.5)
    setElementRotation(e, 0, 0, 265)
    triggerClientEvent(e, "spawn - event", e, e, time)
    setElementHealth(e, 100)

    local clone = e:getData("clone")
    if clone then 
        if x or y or z then
            dim = clone.dimension
            int = clone.interior
        end
        --local x,y,z = getElementPosition(clone)
        --setElementPosition(e, x,y,z+0.5)
        setElementAlpha(e, 255)
        setElementFrozen(e, false)
        
        destroyClone(e)
    end

    e.dimension = dim
    e.interior = int
 
    --idkwhy
    e:setData("hudVisible", false)
    e:setData("hudVisible", true)
end
addEvent("goToMedical", true)
addEventHandler("goToMedical", root, goToMedical)

addEventHandler("onPlayerQuit", root, 
    function()
        destroyClone(source)
    end 
)

addEventHandler("onResourceStop", resourceRoot, 
    function()
        for k,v in pairs(clones) do 
            k.dimension = v.dimension
            k.interior = v.interior 
            k.alpha = 255 
            k.frozen = false 
        end 
    end 
)