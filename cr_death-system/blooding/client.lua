local bloodData = {}

local damage = {
    [1] = 1, --kézi
    [4] = 5,
    [8] = 10,
    [10] = 2, -- Balta
    [22] = 2.5, --pistols
    [23] = 1.5,
    [24] = 3,
    [25] = 3.35, --shotguns
    [26] = 3.45,
    [27] = 3.55,
    [28] = 2.2, --smgs
    [32] = 2.25,
    [29] = 2,
    [30] = 3, --ARS
    [31] = 3.5,
    [33] = 4, --snipers
    [34] = 4.5, 
}

local oddsData = {
    [1] = 25, --kézi
    [4] = 100,
    [8] = 100,
    [10] = 50, -- Balta
    [22] = 65, --pistols
    [23] = 60,
    [24] = 70,
    [25] = 80, --shotguns
    [26] = 80,
    [27] = 80,
    [28] = 65, --smgs
    [32] = 65,
    [29] = 65,
    [30] = 85, --ARS
    [31] = 85,
    [33] = 90, --snipers
    [34] = 100,
}

local bodyMultiplier = {
    [3] = 1, -- has
    [4] = 1, -- segg 
    [5] = 1.3, -- bal kéz 
    [6] = 1.3,  -- jobb kéz
    [7] = 1.2, -- bal láb 
    [8] = 1.2, -- jobb láb 
    [9] = 3, -- fej
}

function checkBlood(attacker, weapon, bodypart) 
    if localPlayer:getData("admin >> duty") then return end
    if damage[weapon] and bodyMultiplier[bodypart] and attacker and attacker.type == "player" then 
        if attacker:getData("taser>obj") then return end
        if math.random(1, 100) <= oddsData[weapon] then 
            local minus = damage[weapon] * bodyMultiplier[bodypart]
            table.insert(bloodData, 1, {minus, weapon, bodypart})
            localPlayer:setData("bloodData", bloodData)    
        end 
    end 
end
addEventHandler("onClientPlayerDamage", localPlayer, checkBlood)

function addBloodDamage(player, attacker, weapon, bodypart)
    if player == localPlayer then 
        if localPlayer:getData("admin >> duty") then return end
        if damage[weapon] and bodyMultiplier[bodypart] and attacker and attacker.type == "player" then 
            if attacker:getData("taser>obj") then return end
            if math.random(1, 100) <= oddsData[weapon] then 
                local minus = damage[weapon] * bodyMultiplier[bodypart]
                table.insert(bloodData, 1, {minus, weapon, bodypart})
                localPlayer:setData("bloodData", bloodData)    
            end 
        end 
    end 
end 

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        bloodData = localPlayer:getData("bloodData") or {}
    end 
)

addEventHandler("onClientElementDataChange", localPlayer, 
    function(dName, oValue, nValue)
        if dName == "bloodData" then 
            if nValue ~= bloodData then 
                bloodData = nValue
            end 
        end 
    end 
)

setTimer(
    function()
        if localPlayer.health > 15 then 
            local bloodData = localPlayer:getData("bloodData") or {}
            if #bloodData >= 1 then 
                for k,v in pairs(bloodData) do 
                    local minus, weapon, bodypart = unpack(v)
                    localPlayer.health = math.max(0, localPlayer.health - minus)
                end 

                fxAddBlood(localPlayer.position, 0,0,0 , #bloodData * 15, 100)
            end 
        end
    end, 15 * 1000, 0
)

addEventHandler("onClientPlayerWasted", localPlayer, 
    function()
        localPlayer:setData("bloodData", {})
        bloodData = {}
    end 
)