groupCache = {}

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName, oValue, nValue)
        if dName == "loggedIn" then
            if nValue then
                triggerLatentServerEvent("checkPlayerGroup", 5000, false, localPlayer, localPlayer)
            end
        end
    end
)


addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        if localPlayer:getData("loggedIn") then 
            triggerLatentServerEvent("checkPlayerGroup", 5000, false, localPlayer, localPlayer)
        end 
    end 
)

function getGroupData(element, groupID, data, typ)
    if typ == "all" then
        groupCache[groupID] = data
        
        local breaked = false 
        if isElement(element) then 
            if cache["element"] == element then 
                breaked = true
            end 
        elseif type(element) == "table" then 
            for k,v in pairs(element) do 
                if cache["element"] == v then 
                    breaked = true 
                    break 
                end 
            end 
        end 

        if breaked then
            local groups = {}

            local data = groupCache[tonumber(cache["element"]:getData("char >> group") or 0)] or {}
            table.insert(groups, selectedGroup, {
                ["name"] = data[2] or "Szinkronizálás alatt",
                ["data"] = data,
            })
            
            if not data[2] then
                groups = nil
            end

            if cache["page"] == 5 and state then 
                if not cache["playerDatas"]["group"] or #cache["playerDatas"]["group"] == 0 then 
                    triggerLatentServerEvent("openPanel", 5000, false, localPlayer, tonumber(cache["element"]:getData("char >> group")), localPlayer)
                end 
            end

            if groups and groups[selectedGroup] and groups[selectedGroup]["data"] then 
                table.sort(groups[selectedGroup]["data"][3], 
                    function(a, b)
                        if a[1] and b[1] then
                            return tonumber(a[1]) < tonumber(b[1])
                        end
                    end
                )

                local data
                for k,v in pairs(groups[selectedGroup]["data"][3]) do 
                    local leader = v[3]
                    if v[3] == 1 then 
                        data = v
                        table.remove(groups[selectedGroup]["data"][3], k)

                        break 
                    end 
                end 

                if data then 
                    table.insert(groups[selectedGroup]["data"][3], 1, data)
                end 
            end

            cache["playerDatas"]["group"] = groups
        end
    end
end
addEvent("getGroupData", true)
addEventHandler("getGroupData", root, getGroupData)

local lastCall = -1
local lastCallTick = -5000
function triggerGroupData(element, groupID, typ)
    local now = getTickCount()
    if now <= lastCallTick + 1000 then
        cancelLatentEvent(lastCall)
    end 
    triggerLatentServerEvent("getGroupData", 1000, false, localPlayer, localPlayer, element, groupID, "all")
    lastCall = getLatentEventHandles()[#getLatentEventHandles()] 
    lastCallTick = getTickCount()
end

function inviteToGroup(sourcePlayer, groupID, groupName)
    if isElement(sourcePlayer) and tonumber(groupID) then 
        local blue = exports['cr_core']:getServerColor("yellow", true)
        local red = exports['cr_core']:getServerColor("red", true)
        local white = "#F2F2F2"
        local r,g,b = exports['cr_core']:getServerColor("green")
        local r2,g2,b2 = exports['cr_core']:getServerColor("red")
        
        createAlert(
            {
                ['headerText'] = 'Csoport',
                ["title"] = {white .. blue .. exports['cr_admin']:getAdminName(sourcePlayer) .. white .." meghívott a ".. blue .. groupName .. white .. " nevű csoportba!"},
                ["buttons"] = {
                    {
                        ["name"] = "Elfogadás", 
                        ["pressFunc"] = function()
                            triggerLatentServerEvent("addPlayerToGroup", 5000, false, localPlayer, sourcePlayer, localPlayer, groupID, 0)

                            exports['cr_infobox']:addBox("success", "Sikeresen csatlakoztál "..groupName.." nevű csoportba!")
                        end,
                        ["onCreate"] = function()
                            sourcePlayer = sourcePlayer
                            groupID = groupID
                            groupName = groupName
                        end,
                        ["color"] = {r,g,b},
                    },

                    {
                        ["name"] = "Elutasítás", 
                        ["onClear"] = true,
                        ["pressFunc"] = function()
                        end,
                        ["color"] = {r2, g2, b2},
                    },
                },
            }
        )
    end 
end
addEvent("inviteToGroup", true)
addEventHandler("inviteToGroup", root, inviteToGroup)