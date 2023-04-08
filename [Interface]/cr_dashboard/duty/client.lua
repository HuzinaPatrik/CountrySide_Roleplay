local maxDistNearby = 18
function getNearbyDutyLocations(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "getnearbydutylocations") then 
        local px, py, pz = getElementPosition(localPlayer)
        local white = "#ffffff"
        local green = exports['cr_core']:getServerColor("orange", true)
        local syntax = exports['cr_core']:getServerSyntax("DutyLocation", "info")
        local hasVeh = false
        for k,v in pairs(getElementsByType("marker", root, true)) do
            local x,y,z = getElementPosition(v)
            local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
            if dist <= maxDistNearby then
                local id = getElementData(v, "dutyLocation >> id") or 0
                if id > 0 then
                    local factionID = getElementData(v, "dutyLocation >> factionID") or 0
                    outputChatBox(syntax.."ID: "..green..id..white..", Frakció: "..green..factionID..white..", Távolság: "..green..math.floor(dist)..white.." yard", 255,255,255,true)
                    hasVeh = true
                end
            end
        end
        if not hasVeh then
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax("DutyLocation", "error")
            outputChatBox(syntax .. "Nincsen dutycp a közeledben!", 255,255,255,true)
        end
    end 
end 
addCommandHandler("getNearbydutylocation", getNearbyDutyLocations)
addCommandHandler("getnearbydutylocations", getNearbyDutyLocations)

function dutyOffHandler(spec, factionName)
    localPlayer:setData("char >> duty", nil)
    localPlayer:setData("char >> dutyskin", nil)
    local skinID = localPlayer:getData("char >> skin") 
    localPlayer:setData("char >> skin", nil)
    localPlayer:setData("char >> skin", skinID)

    setTimer(
        function()
            for i = 1, 4 do
                local items = exports['cr_inventory']:getItems(localPlayer, i)
                for slot, data in pairs(items) do
                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                    if dutyitem == 1 then 
                        exports['cr_inventory']:deleteItem(localPlayer, slot, itemid, false, "removeDutyItems")
                    end 
                end 
            end
        end, 1500, 1
    ) 

    local text = "Sikeresen leadtad a szolgálatot!"
    local infoType = "success"

    if spec then 
        if spec == "removedFromFaction" then 
            text = "Ki lettél rúgva a(z) " .. factionName .. " frakcióból, ezért a rendszer visszaállított mindent a régi állapotra."
            infoType = "info"
        end
    end

    exports['cr_infobox']:addBox(infoType, text)
end
addEvent("dutyOffHandler", true)
addEventHandler("dutyOffHandler", root, dutyOffHandler)

addEventHandler("onClientMarkerHit", root, 
    function(hitPlayer, matchingDimension)
        if hitPlayer == localPlayer and matchingDimension then 
            if source:getData("dutyLocation >> id") then 
                if getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 3 then 
                    local factionID = source:getData("dutyLocation >> factionID")
                    if isPlayerInFaction(localPlayer, factionID) then 
                        local dutyData = source:getData("dutyLocation >> data")
                        local factionRank = getPlayerFactionRank(localPlayer, factionID)
                        if dutyData[factionRank] then 
                            local id, items = unpack(dutyData[factionRank])

                            local dutyskin = factionCache[factionID][3][tonumber(localPlayer:getData("acc >> id"))][9]

                            if tonumber(dutyskin) and tonumber(dutyskin) >= 1 then 
                                if tonumber(localPlayer:getData("char >> duty")) then 
                                    if localPlayer:getData("char >> duty") == factionID then 
                                        local blue = exports['cr_core']:getServerColor("yellow", true)
                                        local red = exports['cr_core']:getServerColor("red", true)
                                        local white = "#F2F2F2"
                                        local r,g,b = exports['cr_core']:getServerColor("green")
                                        local r2,g2,b2 = exports['cr_core']:getServerColor("red")
                                        
                                        createAlert(
                                            {
                                                ['headerText'] = 'Szolgálat',
                                                ["title"] = {"Leszeretnéd "..blue.."adni"..white.." a szolgálatot?"},
                                                ["buttons"] = {
                                                    {
                                                        ["name"] = "Igen", 
                                                        ["pressFunc"] = function()
                                                            dutyOffHandler()
                                                        end,
                                                        ["onCreate"] = function()
                                                        end,
                                                        ["color"] = {r,g,b},
                                                    },

                                                    {
                                                        ["name"] = "Nem", 
                                                        ["onClear"] = true,
                                                        ["pressFunc"] = function()
                                                        end,
                                                        ["color"] = {r2, g2, b2},
                                                    },
                                                },
                                            }
                                        )
                                    end 
                                else 
                                    local blue = exports['cr_core']:getServerColor("yellow", true)
                                    local red = exports['cr_core']:getServerColor("red", true)
                                    local white = "#F2F2F2"
                                    local r,g,b = exports['cr_core']:getServerColor("green")
                                    local r2,g2,b2 = exports['cr_core']:getServerColor("red")
                                    
                                    createAlert(
                                        {
                                            ['headerText'] = 'Szolgálat',
                                            ["title"] = {"Szeretnél "..blue.."belépni"..white.." a szolgálatba?"},
                                            ["buttons"] = {
                                                {
                                                    ["name"] = "Igen", 
                                                    ["pressFunc"] = function()
                                                        localPlayer:setData("char >> dutyskin", dutyskin)
                                                        localPlayer:setData("char >> duty", factionID)

                                                        for k,v in pairs(items) do 
                                                            local itemid, value, count, nbt = unpack(v)
                                                            exports['cr_inventory']:giveItem(localPlayer, itemid, value, count, 100, 1, 0, nbt)
                                                        end 

                                                        exports['cr_infobox']:addBox("success", "Sikeresen felvetted a szolgálatot!")
                                                    end,
                                                    ["onCreate"] = function()
                                                        items = items
                                                        factionID = factionID
                                                    end,
                                                    ["color"] = {r,g,b},
                                                },

                                                {
                                                    ["name"] = "Nem", 
                                                    ["onClear"] = true,
                                                    ["pressFunc"] = function()
                                                    end,
                                                    ["color"] = {r2, g2, b2},
                                                },
                                            },
                                        }
                                    )
                                end 
                            else
                                exports['cr_infobox']:addBox("error", "Nincs beállítva szolgálati ruha, előbb állíts be egyet!")
                            end 
                        end 
                    end 
                end 
            end 
        end 
    end 
)

addEventHandler("onClientMarkerLeave", root, 
    function(hitPlayer, matchingDimension)
        if hitPlayer == localPlayer and matchingDimension then 
            if source:getData("dutyLocation >> id") then 
                local factionID = source:getData("dutyLocation >> factionID")
                if isPlayerInFaction(localPlayer, factionID) then 
                    local dutyData = source:getData("dutyLocation >> data")
                    local factionRank = getPlayerFactionRank(localPlayer, factionID)
                    if dutyData[factionRank] then 
                        local id, items = unpack(dutyData[factionRank])

                        local dutyskin = factionCache[factionID][3][tonumber(localPlayer:getData("acc >> id"))][9]

                        if tonumber(dutyskin) and tonumber(dutyskin) >= 1 then 
                            clearAlerts()
                        end 
                    end 
                end 
            end 
        end 
    end 
)