--dxDrawMultipler = 0.6
addEventHandler("onClientKey", root,
    function(b, s)
        --Shift + num7 = "Home"
        if b == "home" and s then
            cancelEvent()
            openDash(localPlayer, 1)
        end
    end
)

function toggleHud(state)
    if not state then
        oDatas = {
            ["hudVisible"] = localPlayer:getData("hudVisible"),
            ["keysDenied"] = localPlayer:getData("keysDenied"),
            ["chat"] = exports['cr_custom-chat']:isChatVisible(),
        }
        
        localPlayer:setData("hudVisible", false)
        localPlayer:setData("keysDenied", true)
        exports['cr_custom-chat']:showChat(false)
        exports['cr_core']:intCursor(true, true)
    else
        localPlayer:setData("hudVisible", oDatas["hudVisible"])
        localPlayer:setData("keysDenied", oDatas["keysDenied"])
        exports['cr_custom-chat']:showChat(oDatas["chat"])
        exports['cr_core']:intCursor(false, false)
    end
end

local refreshDatas = {
    ["char >> avatar"] = "avatar",
    ["char >> crosshair"] = "crosshair",
    ["char >> crosshairColor"] = "crosshairColor",
    ["char >> name"] = function()
        cache["playerDatas"]["charName"] = exports['cr_admin']:getAdminName(source)
    end,
    ["admin >> name"] = function()
        cache["playerDatas"]["charName"] = exports['cr_admin']:getAdminName(source)
    end,
    ["admin >> duty"] = function()
        cache["playerDatas"]["charName"] = exports['cr_admin']:getAdminName(source)
    end,
    ["admin >> level"] = function()
        local title = exports['cr_admin']:getAdminTitle(source)
        local title = title == "Ideiglenes Adminsegéd" and "Idg. Adminsegéd" or title

        cache["playerDatas"]["adminTitle"] = title
    end,
    ["char >> playedtime"] = function()
        local lvl = tonumber(source:getData("char >> level")) or 1
        local playedtime = tonumber(source:getData("char >> playedtime")) or 1
        cache["playerDatas"]["lvl"] = lvl
        cache["playerDatas"]["playedtime"] = playedtime
        cache["playerDatas"]["playedtime2"] = math.floor((playedtime / 60) + 0.5)
        local lvlTime1 = playedtime
        local lvlTime2 = exports['cr_level']:getLevelTime(lvl + 1)
        local lvlUPTime = lvlTime2 - lvlTime1
        cache["playerDatas"]["lvlUp"] = lvlUPTime
        cache["playerDatas"]["lvlUp2"] = math.floor((lvlUPTime / 60) + 0.5)
        cache["playerDatas"]["payTime"] = math.floor(60 - ((playedtime / 60) - math.floor(playedtime / 60)) * 60 + 0.5)
    end,
    ["char >> lvl"] = function(dName, oValue, nValue)
        local lvl = nValue
        local playedtime = tonumber(source:getData("char >> playedtime")) or 1
        cache["playerDatas"]["lvl"] = lvl
        cache["playerDatas"]["playedtime"] = playedtime
        cache["playerDatas"]["playedtime2"] = math.floor((playedtime / 60) + 0.5)
        local lvlTime1 = playedtime
        local lvlTime2 = exports['cr_level']:getLevelTime(lvl + 1)
        local lvlUPTime = lvlTime2 - lvlTime1
        cache["playerDatas"]["lvlUp"] = lvlUPTime
        cache["playerDatas"]["lvlUp2"] = math.floor((lvlUPTime / 60) + 0.5)
        cache["playerDatas"]["payTime"] = math.floor(60 - ((playedtime / 60) - math.floor(playedtime / 60)) * 60 + 0.5)
    end,
    ["char >> job"] = function(dName, oValue, nValue)
        cache["playerDatas"]["job"] = exports['cr_jobpanel']:getJobName(nValue) or "Ismeretlen"
    end,
    ["char >> description"] = "description",
    ["char >> premiumPoints"] = "pp",
    ["char >> vehicleLimit"] = "vehSlots",
    ["char >> interiorLimit"] = "intSlots",
    ["char >> money"] = "money",
    ["char >> details"] = function(dName, oValue, nValue)
        local details = nValue
        cache["playerDatas"]["age"] = details["age"]
        cache["playerDatas"]["born"] = details["born"]
        cache["playerDatas"]["height"] = details["height"]
        cache["playerDatas"]["weight"] = details["weight"]
        cache["playerDatas"]["nationality"] = exports['cr_account']:getNationalityByID(details["nationality"])
        cache["playerDatas"]["neme"] = exports['cr_account']:getNemeByID(details["neme"])
    end,
}

function getDatas(e)
    local tbl = {}
    local title = exports['cr_admin']:getAdminTitle(e)

    tbl["avatar"] = tonumber(e:getData("char >> avatar")) or 1
    tbl["crosshair"] = tonumber(e:getData("char >> crosshair")) or 1
    tbl["crosshairColor"] = e:getData("char >> crosshairColor") or {255, 255, 255}
    tbl["skinid"] = e.model
    tbl["charName"] = exports['cr_admin']:getAdminName(e)
    tbl["adminColor"] = exports['cr_core']:RGBToHex(unpack({exports['cr_admin']:getAdminColor(e)}))
    tbl["adminTitle"] = title == "Ideiglenes Adminsegéd" and "Idg. Adminsegéd" or title
    local lvl = tonumber(e:getData("char >> level")) or 1
    local playedtime = tonumber(e:getData("char >> playedtime")) or 1
    tbl["lvl"] = lvl
    tbl["playedtime"] = playedtime
    tbl["playedtime2"] = math.floor((playedtime / 60) + 0.5)
    local lvlTime1 = playedtime
    local lvlTime2 = exports['cr_level']:getLevelTime(lvl + 1)
    if not tonumber(lvlTime2) then 
        lvlTime2 = lvlTime1
    end 
    local lvlUPTime = lvlTime2 - lvlTime1
    tbl["lvlUp"] = lvlUPTime
    tbl["lvlUp2"] = math.floor((lvlUPTime / 60) + 0.5)
    tbl["payTime"] = math.floor(60 - ((playedtime / 60) - math.floor(playedtime / 60)) * 60 + 0.5)
    tbl["mtaserial"] = e:getData("mtaserial")
    tbl["accId"] = e:getData("acc >> id")
    tbl["charId"] = e:getData("char >> id")
    tbl["description"] = e:getData("char >> description")
    local details = e:getData("char >> details")
    tbl["age"] = details["age"]
    tbl["born"] = details["born"]
    tbl["height"] = details["height"]
    tbl["weight"] = details["weight"]
    tbl["nationality"] = exports['cr_account']:getNationalityByID(details["nationality"])
    tbl["neme"] = exports['cr_account']:getNemeByID(details["neme"])
    tbl["job"] = exports['cr_jobpanel']:getJobName(e:getData("char >> job")) or "Ismeretlen"
    tbl["money"] = e:getData("char >> money")
    tbl["pp"] = e:getData("char >> premiumPoints")
    tbl["vehSlots"] = e:getData("char >> vehicleLimit")
    tbl["intSlots"] = e:getData("char >> interiorLimit")
    
    local factions = {}
    if cache["playerDatas"] and cache["playerDatas"]["faction"] then 
        factions = cache["playerDatas"]["faction"]
    end 
        
    --[[
    table.insert(factions, {
        1,
        "Los Santos Police Department",
        {
            [4] = {0, 0, 0, 0, 0, 0, 1},
        },

        {
            [1] = {"Kadét", 100},
        },
    })

    table.insert(factions, {
        2,
        "Los Santos Fire Department",
        {
            [4] = {0, 0, 0, 0, 0, 0, 1},
        },

        {
            [1] = {"Kadét", 100},
        },
    })
    --]]

    tbl["faction"] = factions
    getFactionData(e)
    
    local groups = {}

    if cache["playerDatas"] and cache["playerDatas"]["group"] then 
        groups = cache["playerDatas"]["group"]
    end 
    
    --[[
    table.insert(groups, {
        ["name"] = "Fasza kis brigád"
    })
    ]]
    
    if tonumber(e:getData("char >> group") or 0) > 0 then
        triggerGroupData(e, tonumber(e:getData("char >> group") or 0), "all")
        
        local data = groupCache[tonumber(e:getData("char >> group") or 0)] or {}
        table.insert(groups, {
            ["name"] = data[2] or "Szinkronizálás alatt",
            ["data"] = data,
        })
    end
    tbl["group"] = groups
    
    local vehs = {}

    for k,v in pairs(getElementsByType("vehicle")) do
        if v:getData("veh >> owner") == cache["element"]:getData("acc >> id") then
            table.insert(vehs, v)
        end
    end

    local ints = {}

    for k,v in pairs(getElementsByType("marker")) do
        if v:getData("marker >> data") then 
            if v:getData("marker >> data")["owner"] == cache["element"]:getData("acc >> id") then
                table.insert(ints, v)
            end
        end
    end
    
    tbl["vehs"] = vehs
    tbl["ints"] = ints
    
    cache["playerDatas"] = tbl
end

addEventHandler("onClientElementDestroy", root,
    function()
        if playerVehiclesData and playerVehiclesData[source] then
            for k,v in pairs(playerVehicles) do
                if v == source then
                    table.remove(playerVehicles, k)
                    break
                end
            end
            
            playerVehiclesData[source] = nil
            
            if VehicleMaxLines > #playerVehicles then
                VehicleMinLines = 1
                VehicleMaxLines = 7
            end
        elseif playerInteriorsData and playerInteriorsData[source] then
            for k,v in pairs(playerInterior) do
                if v == source then
                    table.remove(playerInterior, k)
                    break
                end
            end
            
            playerInteriorsData[source] = nil
            
            if InteriorMaxLines > #playerInterior then
                InteriorMinLines = 1
                InteriorMaxLines = 7
            end
        end
    end
)

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue, nValue)
        local source = source
        local dName = dName
        local oValue = oValue
        local nValue = nValue
        
        if state then
            if source == cache["element"] then
                if refreshDatas[dName] then
                    if type(refreshDatas[dName]) == "function" then
                        refreshDatas[dName](dName, oValue, nValue)
                    else
                        cache["playerDatas"][refreshDatas[dName]] = nValue
                    end
                end
            end
            
            if VehicleNeedSync then
                if playerVehiclesData then 
                    if playerVehiclesData[source] then
                        if dName == "veh >> locked" then
                            playerVehiclesData[source]["locked"] = nValue
                        end
                    end
                end

                if playerFactionVehiclesData then 
                    if playerFactionVehiclesData[source] then
                        if dName == "veh >> locked" then
                            playerFactionVehiclesData[source]["locked"] = nValue
                        end
                    end
                end 
            end
            
            if InteriorNeedSync then
                if playerInteriorData[source] then
                    if dName == "marker >> data" then
                        playerInteriorData[source]["locked"] = nValue["locked"]
                    end
                end
            end
            
            if AdminNeedSync then
                if dName == "admin >> level" then
                    local v = source
                    local needLevel = adminPageLevels[adminSelectedMenu]

                    if type(needLevel) == "number" and tonumber(v:getData("admin >> level") or 0) == needLevel then 
                        if not adminCache[v] then
                            adminCache[v] = getAdminDatas(v)
                            table.insert(adminCacheKey, v)
                        end
                    elseif type(needLevel) == "string" then
                        if not adminCache[v] then
                            if tonumber(v:getData("admin >> level") or 0) == 1 or tonumber(v:getData("admin >> level") or 0) == 2 then 
                                adminCache[v] = getAdminDatas(v)
                                table.insert(adminCacheKey, v)
                            end
                        end
                    else 
                        if adminCache[v] then
                            adminCache[v] = nil
                            for k,v in pairs(adminCacheKey) do
                                if v == source then 
                                    table.remove(adminCacheKey, k)
                                end
                            end
                        end
                    end
                elseif adminCache[source] then
                    if dName == "admin >> name" or dName == "admin >> duty" or dName == "char >> id" then
                        adminCache[source] = getAdminDatas(source)
                    end
                end
            end
        end    
    end
)

function getRealFontSize(a)
    local a = a * dxDrawMultipler
    local val = ((a) - math.floor(a))
    if val < 0.5 then
        return math.floor(a)
    elseif val >= 0.5 then
        return math.ceil(a)
    end
end

--scrollBar
function ResetScrollBar()
    factionSelectorMinLines = 1
    factionSelectorMaxLines = 7

    factionInformationsMinLines = 1
    factionInformationsMaxLines = 7

    modPanelInfoMinLines = 1
    modPanelInfoMaxLines = 15
    
    PremiumBuyMinLines = 1
    PremiumBuyMaxLines = 4
    
    modPanelSelected = 1
    selectedFaction = 1
    selectedGroup = 1
    
    PremiumMinLines = 1
    PremiumMaxLines = 5

    optionsSelectMinLines = 1
    optionsSelectMaxLines = 5
    
    AdminMinLines = 1
    AdminMaxLines = 16

    GroupMinLines = 1
    GroupMaxLines = 16

    PetMinLines = 1
    PetMaxLines = 15

    optionsMinLines = 1
    optionsMaxLines = 16
    optionsSelected = 1
    
    VehicleMinLines = 1
    VehicleMaxLines = 7
    
    InteriorMinLines = 1
    InteriorMaxLines = 7
    
    InteriorInfoMinLines = 1
    InteriorInfoMaxLines = 7
    
    VehicleInfoMinLines = 1
    VehicleInfoMaxLines = 7
end

function ScrollBarUP()
    if PetScrollBarHover then
        if PetMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            PetMinLines = PetMinLines - 1
            PetMaxLines = PetMaxLines - 1
        end
    end
    
    if AdminScrollBarHover then
        if AdminMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            AdminMinLines = AdminMinLines - 1
            AdminMaxLines = AdminMaxLines - 1
        end
    end

    if FactionScrollBarHover then
        if factionSelectorMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            factionSelectorMinLines = factionSelectorMinLines - 1
            factionSelectorMaxLines = factionSelectorMaxLines - 1
        end
    end

    if factionMembersScrollBarHover then 
        if factionMembersMinLines - 1 >= 1 then 
            playSound(":cr_scoreboard/files/wheel.wav")
            factionMembersMinLines = factionMembersMinLines - 1 
            factionMembersMaxLines = factionMembersMaxLines - 1
        end 
    end 

    if factionRanksScrollBarHover then 
        if factionRanksMinLines - 1 >= 1 then 
            playSound(":cr_scoreboard/files/wheel.wav")
            factionRanksMinLines = factionRanksMinLines - 1 
            factionRanksMaxLines = factionRanksMaxLines - 1
        end 
    end 

    if FactionInformationsScrollBarHover then
        if factionInformationsMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            factionInformationsMinLines = factionInformationsMinLines - 1
            factionInformationsMaxLines = factionInformationsMaxLines - 1
        end
    end

    if FactionLogsScrollBarHover then 
        if FactionLogsMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            FactionLogsMinLines = FactionLogsMinLines - 1
            FactionLogsMaxLines = FactionLogsMaxLines - 1
        end
    end 

    if GroupScrollBarHover then 
        if GroupMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            GroupMinLines = GroupMinLines - 1
            GroupMaxLines = GroupMaxLines - 1
        end
    end 

    if optionsScrollBarHover then 
        if optionsMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            optionsMinLines = optionsMinLines - 1
            optionsMaxLines = optionsMaxLines - 1
        end
    end 
    
    if VehicleScrollBarHover then
        if VehicleMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            VehicleMinLines = VehicleMinLines - 1
            VehicleMaxLines = VehicleMaxLines - 1
        end
    end

    if FactionVehicleScrollBarHover then
        if FactionVehicleMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            FactionVehicleMinLines = FactionVehicleMinLines - 1
            FactionVehicleMaxLines = FactionVehicleMaxLines - 1
        end
    end
    
    if InteriorScrollBarHover then
        if InteriorMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            InteriorMinLines = InteriorMinLines - 1
            InteriorMaxLines = InteriorMaxLines - 1
        end
    end
    
    if VehicleInfoScrollBarHover then
        if VehicleInfoMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            VehicleInfoMinLines = VehicleInfoMinLines - 1
            VehicleInfoMaxLines = VehicleInfoMaxLines - 1
        end
    end

    if FactionVehicleInfoScrollBarHover then  
        if FactionVehicleInfoMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            FactionVehicleInfoMinLines = FactionVehicleInfoMinLines - 1
            FactionVehicleInfoMaxLines = FactionVehicleInfoMaxLines - 1
        end
    end 
    
    if InteriorInfoScrollBarHover then
        if InteriorInfoMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            InteriorInfoMinLines = InteriorInfoMinLines - 1
            InteriorInfoMaxLines = InteriorInfoMaxLines - 1
        end
    end
    
    if PremiumBuyHover then
        if PremiumBuyMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            PremiumBuyMinLines = PremiumBuyMinLines - 1
            PremiumBuyMaxLines = PremiumBuyMaxLines - 1
        end
    end
    
    if modPanelHover then
        if modPanelInfoMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            modPanelInfoMinLines = modPanelInfoMinLines - 1
            modPanelInfoMaxLines = modPanelInfoMaxLines - 1
        end
    end
end

function ScrollBarDown()
    if PetScrollBarHover then 
        local percent = #petCache
        if PetSearchCache then
            percent = #PetSearchCache
        end
        if PetMaxLines + 1 <= percent then
            playSound(":cr_scoreboard/files/wheel.wav")
            PetMinLines = PetMinLines + 1
            PetMaxLines = PetMaxLines + 1
        end
    end 
    
    if AdminScrollBarHover then
        local percent = #adminCacheKey
        if adminSearchCache then
            percent = #adminSearchCache
        end
        if AdminMaxLines + 1 <= percent then
            playSound(":cr_scoreboard/files/wheel.wav")
            AdminMinLines = AdminMinLines + 1
            AdminMaxLines = AdminMaxLines + 1
        end
    end

    if FactionScrollBarHover then
        if factionSelectorMaxLines + 1 <= #cache["playerDatas"]["faction"] then
            playSound(":cr_scoreboard/files/wheel.wav")
            factionSelectorMinLines = factionSelectorMinLines + 1
            factionSelectorMaxLines = factionSelectorMaxLines + 1
        end
    end

    if factionMembersScrollBarHover then 
        local percent = #cache["playerDatas"]["faction"][selectedFaction]["players"]
        if factionMembersSearchCache then
            percent = #factionMembersSearchCache
        end

        if factionMembersMaxLines + 1 <= percent then
            playSound(":cr_scoreboard/files/wheel.wav")
            factionMembersMinLines = factionMembersMinLines + 1
            factionMembersMaxLines = factionMembersMaxLines + 1
        end
    end

    if factionRanksScrollBarHover then 
        local percent = #cache["playerDatas"]["faction"][selectedFaction][4]
        if factionRanksSearchCache then
            percent = #factionRanksSearchCache
        end

        if factionRanksMaxLines + 1 <= percent then
            playSound(":cr_scoreboard/files/wheel.wav")
            factionRanksMinLines = factionRanksMinLines + 1
            factionRanksMaxLines = factionRanksMaxLines + 1
        end
    end

    if FactionInformationsScrollBarHover then
        if factionInformationsMaxLines + 1 <= #playerFactionInformations then
            playSound(":cr_scoreboard/files/wheel.wav")
            factionInformationsMinLines = factionInformationsMinLines + 1
            factionInformationsMaxLines = factionInformationsMaxLines + 1
        end
    end

    if FactionLogsScrollBarHover then 
        local logs = cache["playerDatas"]["faction"][selectedFaction][8]
        if FactionLogsMaxLines + 1 <= #logs then
            playSound(":cr_scoreboard/files/wheel.wav")
            FactionLogsMinLines = FactionLogsMinLines + 1
            FactionLogsMaxLines = FactionLogsMaxLines + 1
        end
    end 

    if GroupScrollBarHover then 
        local percent = #cache["playerDatas"]["group"][selectedGroup]["data"][3]
        if groupSearchCache then
            percent = #groupSearchCache
        end
        if GroupMaxLines + 1 <= percent then
            playSound(":cr_scoreboard/files/wheel.wav")
            GroupMinLines = GroupMinLines + 1
            GroupMaxLines = GroupMaxLines + 1
        end
    end 

    if optionsScrollBarHover then 
        local percent = #options[optionsSelected]["options"]
        if optionsSearchCache then
            percent = #optionsSearchCache
        end
        if optionsMaxLines + 1 <= percent then
            playSound(":cr_scoreboard/files/wheel.wav")
            optionsMinLines = optionsMinLines + 1
            optionsMaxLines = optionsMaxLines + 1
        end
    end 
    
    if VehicleScrollBarHover then
        if VehicleMaxLines + 1 <= #playerVehicles then
            playSound(":cr_scoreboard/files/wheel.wav")
            VehicleMinLines = VehicleMinLines + 1
            VehicleMaxLines = VehicleMaxLines + 1
        end
    end

    if FactionVehicleScrollBarHover then
        if FactionVehicleMaxLines + 1 <= #playerFactionVehicles then
            playSound(":cr_scoreboard/files/wheel.wav")
            FactionVehicleMinLines = FactionVehicleMinLines + 1
            FactionVehicleMaxLines = FactionVehicleMaxLines + 1
        end
    end
    
    if InteriorScrollBarHover then
        if InteriorMaxLines + 1 <= #playerInterior then
            playSound(":cr_scoreboard/files/wheel.wav")
            InteriorMinLines = InteriorMinLines + 1
            InteriorMaxLines = InteriorMaxLines + 1
        end
    end
    
    if VehicleInfoScrollBarHover then
        if VehicleInfoMaxLines + 1 <= #playerVehicleInfos then
            playSound(":cr_scoreboard/files/wheel.wav")
            VehicleInfoMinLines = VehicleInfoMinLines + 1
            VehicleInfoMaxLines = VehicleInfoMaxLines + 1
        end
    end

    if FactionVehicleInfoScrollBarHover then 
        if FactionVehicleInfoMaxLines + 1 <= #playerFactionVehicleInfos then
            playSound(":cr_scoreboard/files/wheel.wav")
            FactionVehicleInfoMinLines = FactionVehicleInfoMinLines + 1
            FactionVehicleInfoMaxLines = FactionVehicleInfoMaxLines + 1
        end
    end 
    
    if InteriorInfoScrollBarHover then
        if InteriorInfoMaxLines + 1 <= #playerInteriorInfos then
            playSound(":cr_scoreboard/files/wheel.wav")
            InteriorInfoMinLines = InteriorInfoMinLines + 1
            InteriorInfoMaxLines = InteriorInfoMaxLines + 1
        end
    end
    
    if PremiumBuyHover then
        if PremiumBuyMaxLines + 1 <= #PremiumData[premiumSelected]["items"] then
            playSound(":cr_scoreboard/files/wheel.wav")
            PremiumBuyMinLines = PremiumBuyMinLines + 1
            PremiumBuyMaxLines = PremiumBuyMaxLines + 1
        end
    end
    
    if modPanelHover then
        local percent = #modPanelCache
        if modPanelSearchCache then
            percent = #modPanelSearchCache
        end
        
        if modPanelInfoMaxLines + 1 <= percent then
            playSound(":cr_scoreboard/files/wheel.wav")
            modPanelInfoMinLines = modPanelInfoMinLines + 1
            modPanelInfoMaxLines = modPanelInfoMaxLines + 1
        end
    end
end

function BindScrollBarKeys()
    unBindScrollBarKeys()
    
    bindKey("mouse_wheel_up", "down", ScrollBarUP)
    bindKey("mouse_wheel_down", "down", ScrollBarDown)
    scrollKeysBinded = true
end

function unBindScrollBarKeys()
    if scrollKeysBinded then
        unbindKey("mouse_wheel_up", "down", ScrollBarUP)
        unbindKey("mouse_wheel_down", "down", ScrollBarDown)
        scrollKeysBinded = false
    end
end
--

local fontsize = {10, 12, 14, 16, 18}

function openDash(element, page)
    if element:getData("loggedIn") then
        state = not state
        hover = nil
        if state then
            if localPlayer:getData("keysDenied") then
                state = false
                return
            end
            
            if localPlayer:getData("inDeath") then
                state = false
                return
            end

            if dutySelecting then 
                state = false 
                return 
            end 
            
            playSound("assets/sounds/open.mp3")
            
            cache["element"] = element or localPlayer
            cache["page"] = page or 1

            ResetScrollBar()

            if not realFontSize then 
                realFontSize = {}

                for k,v in ipairs(fontsize) do 
                    realFontSize[v] = getRealFontSize(v)
                end 
            end 

            red = exports['cr_core']:getServerColor('red', true)
            yellow = exports['cr_core']:getServerColor('yellow', true)
            green = exports['cr_core']:getServerColor('green', true)
            orange = exports['cr_core']:getServerColor('orange', true)
            
            toggleHud(false)
            getDatas(element)

            if not start then
                --addEventHandler("onClientRender", root, drawnDash, true, "low-5")
                createRender("drawnDash", drawnDash)
                start = true
                startTick = getTickCount()
            end
            
            if cache["page"] ~= 1 then
                menus[cache["page"] - 1][4](cache["page"] - 1, true)
            end
        else
            if isDescEditing or groupRenaming or groupCreating or isPickerRender or factionMessageEditing then
                state = true
                return
            end
            
            playSound("assets/sounds/open.mp3")
            
            state = true
            if start then
                start = false
                startTick = getTickCount()
            end
        end
    end
end    

bindKey("f1", "down", function() openDash(localPlayer, 9) end)
bindKey("f3", "down", function() openDash(localPlayer, 3) end)
bindKey("f6", "down", function() openDash(localPlayer, 6) end)
bindKey("f7", "down", function() openDash(localPlayer, 4) end)

function openDashCMD(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "dash") then
        if not target then
            local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target]", 255,255,255,true)
            return 
        end

        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if target then
            if not target:getData("loggedIn") then
                local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
                outputChatBox(syntax .. "A célpont nincs bejelentkezve!")
                return
            end
            openDash(target, 1)
        else
            local syntax = exports['cr_core']:getServerSyntax(nil, "error")
            outputChatBox(syntax .. "Nincs ilyen játékos",255,255,255,true)
        end
    end
end
addCommandHandler("dash", openDashCMD)
addCommandHandler("dashboard", openDashCMD)
addCommandHandler("stats", openDashCMD)

function closeDash()
    if start or state then
        clearAlerts()
        start = false
        state = false
        if cache["page"] - 1 > 0 then
            menus[cache["page"] - 1][5](i)
        end
        Clear()
        unBindScrollBarKeys()
        VehicleScrolling = false
        InteriorScrolling = false
        VehicleInfoScrolling = false
        InteriorInfoScrolling = false
        PremiumBuyScrolling = false
        factionMembersScrolling = false
        factionRanksScrolling = false 
        FactionVehicleScrolling = false 
        FactionVehicleInfoScrolling = false 
        FactionLogsScrolling = false
        FactionSelectorScrolling = false
        FactionInformationsScrolling = false
        modPanelScrolling = false
        toggleHud(true)
        --removeEventHandler("onClientRender", root, drawnDash)
        destroyRender("drawnDash")
    end
end

addEventHandler("onClientResourceStop", resourceRoot, closeDash)

startAnimationTime = 250
startAnimation = "InOutQuad"
function drawnDash()
    local sx, sy = sx, sy
    hover = nil

    --fontsize1 = math.
    local nowTick = getTickCount()
    local alpha
    if start then
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph, y = interpolateBetween(
            0, -1000, 0,
            255, sx, 0,
            progress, startAnimation
        )
        
        alpha = alph
        sx = y
    else
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph, y = interpolateBetween(
            255, sx, 0,
            0, -1000, 0,
            progress, startAnimation
        )
        
        alpha = alph
        sx = y
        
        if progress >= 1 then
            alpha = 0
            closeDash()
            return
        end
    end

    if localPlayer:getData("inDeath") then
        closeDash()
    end
    
    local datas = cache["playerDatas"]

    --[[
        Fonts
    ]]
    local font = exports['cr_fonts']:getFont('Poppins-Medium', realFontSize[14])
    local font2 = exports['cr_fonts']:getFont('Poppins-SemiBold', realFontSize[18])
    local font3 = exports['cr_fonts']:getFont('Poppins-Medium', realFontSize[16])
    local font4 = exports['cr_fonts']:getFont('Poppins-Regular', realFontSize[12])
    local font5 = exports['cr_fonts']:getFont('Poppins-Medium', realFontSize[12])
    local font6 = exports['cr_fonts']:getFont('Poppins-SemiBold', realFontSize[10])
    local font7 = exports['cr_fonts']:getFont('Poppins-Regular', realFontSize[10])
    local font8 = exports['cr_fonts']:getFont('Poppins-SemiBold', realFontSize[12])
    local font9 = exports['cr_fonts']:getFont('Poppins-SemiBold', realFontSize[16])
    local font10 = exports['cr_fonts']:getFont('Poppins-SemiBold', realFontSize[14])

    --[[
        BG
    ]]
    local w, h = respc(1000), respc(550)
    local x, y = sx/2 - w/2, sy/2 - h/2

    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.9))

    --[[
        Menus
    ]]
    local w2 = respc(50)

    dxDrawRectangle(x, y, w2, h, tocolor(41, 41, 41, alpha * 0.9))

    dxDrawImage(x + w2/2 - respc(34)/2, y + respc(20), respc(34), respc(40), ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

    local startY = y + respc(85)

    local icon = 'overview'
    local iconX, iconY = respc(iconSizes[icon][1]), respc(iconSizes[icon][2])
    local inSlot = isInSlot(x + w2/2 - iconX/2, startY + respc(30)/2 - iconY/2, iconX, iconY)

    if inSlot or cache['page'] == 1 or buttonAnimation[1] then
        if inSlot and cache['page'] ~= 1 then 
            hover = 0
        end 

        local gradientWidth = w2
        local iconAlpha = alpha

        if buttonAnimation[1] then 
            local startTick, type = unpack(buttonAnimation[1])
            local progress = (nowTick - startTick) / 250

            if progress > 1 then 
                buttonAnimation[1] = nil
            end 

            gradientWidth, iconAlpha = interpolateBetween(
                type == 1 and 0 or gradientWidth, type == 1 and alpha * 0.6 or iconAlpha, 0,
                type == 1 and gradientWidth or 0, type == 1 and iconAlpha or alpha * 0.6, 0,
                progress, "InOutQuad"
            )
        end

        if cache['page'] == 1 or buttonAnimation[1] then 
            dxDrawRectangle(x, startY, math.min(gradientWidth, respc(2)), respc(30), tocolor(255, 59, 59, alpha))
            exports['cr_dx']:dxDrawImageAsTexture(x, startY, gradientWidth, respc(30), ':cr_dashboard/assets/images/gradient.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6)) 
        end 

        exports['cr_dx']:dxDrawImageAsTexture(x + w2/2 - iconX/2, startY + respc(30)/2 - iconY/2, iconX, iconY, ':cr_dashboard/assets/images/' .. icon .. '.png', 0, 0, 0, tocolor(242, 242, 242, iconAlpha))

        if inSlot then 
            local name = 'Áttekintés'

            local tWidth = dxGetTextWidth(name, 1, font) + respc(10)
            local tHeight = dxGetFontHeight(1, font)

            dxDrawRectangle(x - tWidth - respc(5), startY + respc(30)/2 - tHeight/2, tWidth, tHeight, tocolor(41, 41, 41, alpha * 0.9))
            dxDrawText(name, x - tWidth - respc(5), startY + respc(30)/2 - tHeight/2, x - respc(5) , startY + respc(30)/2 + tHeight/2 + respc(4), tocolor(242, 242, 242, alpha), 1, font, "center", "center")
        end 
    else
        exports['cr_dx']:dxDrawImageAsTexture(x + w2/2 - iconX/2, startY + respc(30)/2 - iconY/2, iconX, iconY, ':cr_dashboard/assets/images/' .. icon .. '.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
    end 

    startY = startY + respc(30)

    for k,v in ipairs(menus) do 
        local icon = v[3]
        local iconX, iconY = respc(iconSizes[icon][1]), respc(iconSizes[icon][2])
        local inSlot = isInSlot(x + w2/2 - iconX/2, startY + respc(30)/2 - iconY/2, iconX, iconY)

        if inSlot or cache['page'] == (k + 1) or buttonAnimation[k + 1] then
            if inSlot and cache['page'] ~= (k + 1) then 
                hover = k
            end 

            local gradientWidth = w2
            local iconAlpha = alpha

            if buttonAnimation[k + 1] then 
                local startTick, type = unpack(buttonAnimation[k + 1])
                local progress = (nowTick - startTick) / 250

                if progress > 1 then 
                    buttonAnimation[k + 1] = nil
                end 

                gradientWidth, iconAlpha = interpolateBetween(
                    type == 1 and 0 or gradientWidth, type == 1 and alpha * 0.6 or iconAlpha, 0,
                    type == 1 and gradientWidth or 0, type == 1 and iconAlpha or alpha * 0.6, 0,
                    progress, "InOutQuad"
                )
            end
    
            if cache['page'] == (k + 1) or buttonAnimation[k + 1] then 
                dxDrawRectangle(x, startY, math.min(gradientWidth, respc(2)), respc(30), tocolor(255, 59, 59, alpha))
                exports['cr_dx']:dxDrawImageAsTexture(x, startY, gradientWidth, respc(30), ':cr_dashboard/assets/images/gradient.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6)) 
            end 

            exports['cr_dx']:dxDrawImageAsTexture(x + w2/2 - iconX/2, startY + respc(30)/2 - iconY/2, iconX, iconY, ':cr_dashboard/assets/images/' .. icon .. '.png', 0, 0, 0, tocolor(242, 242, 242, iconAlpha))

            if inSlot then 
                local name = v[1]
    
                local tWidth = dxGetTextWidth(name, 1, font) + respc(10)
                local tHeight = dxGetFontHeight(1, font)
    
                dxDrawRectangle(x - tWidth - respc(5), startY + respc(30)/2 - tHeight/2, tWidth, tHeight, tocolor(41, 41, 41, alpha * 0.9))
                dxDrawText(name, x - tWidth - respc(5), startY + respc(30)/2 - tHeight/2, x - respc(5) , startY + respc(30)/2 + tHeight/2 + respc(4), tocolor(242, 242, 242, alpha), 1, font, "center", "center")
            end 
        else
            exports['cr_dx']:dxDrawImageAsTexture(x + w2/2 - iconX/2, startY + respc(30)/2 - iconY/2, iconX, iconY, ':cr_dashboard/assets/images/' .. icon .. '.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
        end 
    
        startY = startY + respc(30)
    end

    --[[
        Close button
    ]]

    closeHover = nil
    if isInSlot(x + w2/2 - respc(15)/2, y + respc(510), respc(15), respc(16)) then 
        closeHover = true

        exports['cr_dx']:dxDrawImageAsTexture(x + w2/2 - respc(15)/2, y + respc(510), respc(15), respc(16), ":cr_bank/assets/images/exit.png", 0, 0, 0, tocolor(242, 242, 242, alpha))
    else 
        exports['cr_dx']:dxDrawImageAsTexture(x + w2/2 - respc(15)/2, y + respc(510), respc(15), respc(16), ":cr_bank/assets/images/exit.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
    end 

    --[[ 
        Pages
    ]]

    if cache['page'] == 1 then
        local x = x + w2

        dxDrawText('Áttekintés', x + respc(20), y + respc(25), x + respc(20), y + respc(25), tocolor(242, 242, 242, alpha), 1, font2, "left", "top")

        --[[
            Def Info
        ]]
        local w3, h3 = respc(300), respc(110)
        dxDrawRectangle(x + respc(28), y + respc(60), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawImage(x + respc(28) + respc(20), y + respc(60) + respc(20), respc(70), respc(70), ":cr_interface/hud/files/avatars/"..datas["avatar"]..".png", 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText(datas['charName'], x + respc(28) + respc(140), y + respc(60) + respc(20), x + respc(28) + respc(140), y + respc(60) + respc(20) + respc(70), tocolor(242, 242, 242, alpha), 1, font3, "left", "top")
        dxDrawText('Szint: ' .. yellow .. datas["lvl"], x + respc(28) + respc(140), y + respc(60) + respc(20) + respc(20), x + respc(28) + respc(140), y + respc(60) + respc(20) + respc(20), tocolor(242, 242, 242, alpha), 1, font4, "left", "top", false, false, false, true)
        dxDrawText('Skin ID: '.. red .. datas["skinid"], x + respc(28) + respc(140), y + respc(60) + respc(20) + respc(35), x + respc(28) + respc(140), y + respc(60) + respc(20) + respc(35), tocolor(242, 242, 242, alpha), 1, font4, "left", "top", false, false, false, true)
        dxDrawText(datas['adminColor'] .. datas['adminTitle'], x + respc(28) + respc(140), y + respc(60) + respc(20), x + respc(28) + respc(140), y + respc(60) + respc(20) + respc(75), tocolor(242, 242, 242, alpha), 1, font, "left", "bottom", false, false, false, true)

        --[[
            Char Data
        ]]
        local w3, h3 = respc(300), respc(335)
        dxDrawRectangle(x + respc(28), y + respc(190), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText('Karakter Információk:', x + respc(28) + respc(20), y + respc(190) + respc(10), x + respc(28) + respc(20), y + respc(190) + respc(10), tocolor(242, 242, 242, alpha), 1, font2, "left", "top")
        dxDrawText("Account ID: "..orange..datas["accId"].."#F2F2F2 ("..orange.."Meghívó#F2F2F2 kódod)\nKarakter ID: "..orange..datas["accId"].."#F2F2F2\nNem: "..yellow..datas["neme"].."#F2F2F2\nSúly: "..yellow..datas["weight"].."#F2F2F2 kg\nMagasság: "..yellow..datas["height"].."#F2F2F2 cm\nSzületési idő: "..yellow..datas["born"].."#F2F2F2 ("..yellow..datas["age"].."#F2F2F2 éves vagy)\nMunka: "..yellow..datas["job"].."#F2F2F2\nSzint lépésig: "..yellow..datas["lvlUp"].."#F2F2F2 perc ("..yellow..datas["lvlUp2"].."#F2F2F2 óra)\nFizetésig: "..yellow..datas["payTime"].."#F2F2F2 perc\nJátszott percek: "..yellow..datas["playedtime"].."#F2F2F2 perc ("..yellow..datas["playedtime2"].."#F2F2F2 óra)\nKészpénz: "..(datas["money"] < 0 and red or green).."$ "..datas["money"].."#F2F2F2\nPremium pontjaid: "..green..datas["pp"].."#F2F2F2 db\nJárműveid: "..yellow..#datas["vehs"].."#F2F2F2 db\nIngatlanjaid: "..yellow..#datas["ints"].."#F2F2F2 db", x + respc(28) + respc(20), y + respc(190) + respc(40), x + respc(28) + respc(20), y + respc(190) + respc(40), tocolor(242, 242, 242, alpha), 1, font4, "left", "top", false, false, false, true)

        --[[
            Char Description
        ]]
        local w3, h3 = respc(522), respc(110)
        dxDrawRectangle(x + respc(378), y + respc(60), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText('Karakter Leírás:', x + respc(378) + respc(20), y + respc(60) + respc(10), x + respc(378) + respc(20), y + respc(60) + respc(10), tocolor(242, 242, 242, alpha), 1, font2, "left", "top")
        local desc = datas["description"]
        if not isDescEditing then
            dxDrawText(desc, x + respc(378) + respc(20), y + respc(60) + respc(40), x + respc(378) + w3 - respc(20), y + respc(60) + h3 - respc(20), tocolor(242, 242, 242, alpha), 1, font4, "left", "top", false, true)
        end
        
        UpdatePos("Desc >> Edit", {x + respc(378) + respc(20), y + respc(60) + respc(40), w3 - respc(40), h3 - respc(40)})

        if isInSlot(x + respc(378) + respc(500), y + respc(60) + respc(8), respc(15), respc(15)) then 
            hover = "Edit"

            exports['cr_dx']:dxDrawImageAsTexture(x + respc(378) + respc(500), y + respc(60) + respc(8), respc(15), respc(15), ":cr_dashboard/assets/images/descEdit.png", 0, 0, 0, tocolor(242, 242, 242, alpha))
        else 
            exports['cr_dx']:dxDrawImageAsTexture(x + respc(378) + respc(500), y + respc(60) + respc(8), respc(15), respc(15), ":cr_dashboard/assets/images/descEdit.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
        end 

        --[[
            Faction Data
        ]]
        local w3, h3 = respc(522), respc(130)
        dxDrawRectangle(x + respc(378), y + respc(190), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText('Frakció Információk:', x + respc(378) + respc(20), y + respc(190) + respc(10), x + respc(378) + respc(20), y + respc(190) + respc(10), tocolor(242, 242, 242, alpha), 1, font2, "left", "top")

        if not datas["faction"] or #datas["faction"] == 0 then
            exports['cr_dx']:dxDrawImageAsTexture(x + respc(378) + respc(20), y + respc(190) + respc(44), respc(53), respc(51), ":cr_dashboard/assets/images/warning.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.7))

            dxDrawText('Jelenleg nem vagy frakcióban!', x + respc(378) + respc(20) + respc(75), y + respc(190) + respc(44), x + respc(378) + respc(20) + respc(75), y + respc(190) + respc(44) + respc(51) + respc(4), tocolor(255, 59, 59, alpha), 1, font, "left", "center")
        else
            local factionName = datas["faction"][selectedFaction][2] or "Ismeretlen"
            local factionRank = datas["faction"][selectedFaction][3][datas["accId"]][7] or 1
            local factionRankName = datas["faction"][selectedFaction][4][factionRank]["name"] or "Ismeretlen"
            local factionRankPayment = datas["faction"][selectedFaction][4][factionRank]["payment"] or 0

            if #datas["faction"] > 1 then 
                if isInSlot(x + respc(378) + respc(500), y + respc(190) + respc(8), respc(12), respc(10)) then 
                    hover = "FactionRight"

                    exports['cr_dx']:dxDrawImageAsTexture(x + respc(378) + respc(500), y + respc(190) + respc(8), respc(12), respc(10), ":cr_carshop/files/imgs/leftArrow.png", 180, 0, 0, tocolor(242, 242, 242, alpha))
                else
                    exports['cr_dx']:dxDrawImageAsTexture(x + respc(378) + respc(500), y + respc(190) + respc(8), respc(12), respc(10), ":cr_carshop/files/imgs/leftArrow.png", 180, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
                end 

                if isInSlot(x + respc(378) + respc(500) - respc(12) - respc(5), y + respc(190) + respc(8), respc(12), respc(10)) then 
                    hover = "FactionLeft"

                    exports['cr_dx']:dxDrawImageAsTexture(x + respc(378) + respc(500) - respc(12) - respc(5), y + respc(190) + respc(8), respc(12), respc(10), ":cr_carshop/files/imgs/leftArrow.png", 0, 0, 0, tocolor(242, 242, 242, alpha))
                else 
                    exports['cr_dx']:dxDrawImageAsTexture(x + respc(378) + respc(500) - respc(12) - respc(5), y + respc(190) + respc(8), respc(12), respc(10), ":cr_carshop/files/imgs/leftArrow.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
                end 
            end 

            dxDrawText("Jelenlegi frakciód: "..red..factionName.."#F2F2F2\nJelenlegi rangod: "..orange..factionRankName.."#F2F2F2\nFizetésed: "..green.."$ "..factionRankPayment, x + respc(378) + respc(20), y + respc(190) + respc(40), x + respc(378) + w3 - respc(20), y + respc(190) + h3 - respc(20), tocolor(242, 242, 242, alpha), 1, font4, "left", "top", false, false, false, true)
        end 

        --[[
            Group Data
        ]]
        local w3, h3 = respc(522), respc(130)
        dxDrawRectangle(x + respc(378), y + respc(340), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText('Csoport Információk:', x + respc(378) + respc(20), y + respc(340) + respc(10), x + respc(378) + respc(20), y + respc(340) + respc(10), tocolor(242, 242, 242, alpha), 1, font2, "left", "top")

        if not datas["group"] or #datas["group"] == 0 then
            exports['cr_dx']:dxDrawImageAsTexture(x + respc(378) + respc(20), y + respc(340) + respc(44), respc(53), respc(51), ":cr_dashboard/assets/images/warning.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.7))

            dxDrawText('Jelenleg nem vagy csoportban!', x + respc(378) + respc(20) + respc(75), y + respc(340) + respc(44), x + respc(378) + respc(20) + respc(75), y + respc(340) + respc(44) + respc(51) + respc(4), tocolor(255, 59, 59, alpha), 1, font, "left", "center")
        else 
            local groupName = datas["group"][selectedGroup].name

            dxDrawText("Jelenlegi csoportod: "..red..groupName, x + respc(378) + respc(20), y + respc(340) + respc(40), x + respc(378) + w3 - respc(20), y + respc(340) + h3 - respc(20), tocolor(242, 242, 242, alpha), 1, font4, "left", "top", false, false, false, true)
        end 

        --[[
            Acc Serial
        ]]
        dxDrawText('Account Serial: ' .. red .. datas["mtaserial"], x + respc(378), y + h - respc(45), x + respc(378) + w3, y + h - respc(45), tocolor(242, 242, 242, alpha), 1, font, "center", "top", false, false, false, true)
    elseif cache['page'] == 2 then
        local x = x + w2

        --[[
            Header
        ]]
        dxDrawText('Vagyon', x + respc(20), y + respc(24), x + respc(20), y + respc(24) + respc(35) + respc(5), tocolor(242, 242, 242, alpha), 1, font2, "left", "center")
        dxDrawImage(x + respc(741), y + respc(24), respc(35), respc(35), ":cr_interface/hud/files/avatars/"..datas["avatar"]..".png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText(datas['charName'], x + respc(741) + respc(35) + respc(20), y + respc(24) - respc(5), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(35), tocolor(242, 242, 242, alpha), 1, font3, "left", "top")
        dxDrawText('Szint: ' .. yellow .. datas['lvl'] .. "#F2F2F2 - ".. datas['adminColor'] .. datas['adminTitle'], x + respc(741) + respc(35) + respc(20), y + respc(24), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(5) + respc(35), tocolor(242, 242, 242, alpha), 1, font4, "left", "bottom", false, false, false, true)

        --[[
            Vehicles
        ]]
        local w3, h3 = respc(430), respc(430)
        dxDrawRectangle(x + respc(28), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawRectangle(x + respc(28) + w3/2 - respc(380)/2, y + respc(95) + respc(210), respc(380), respc(2), tocolor(135, 135, 135, alpha * 0.6))

        dxDrawText('Jármű típus', x + respc(28) + respc(15), y + respc(95) + respc(10), x + respc(28) + respc(15), y + respc(95) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'top')
        dxDrawText('Jármű ID', x + respc(28) + respc(245), y + respc(95) + respc(10), x + respc(28) + respc(245), y + respc(95) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'center', 'top')
        dxDrawText('Állapot', x + respc(28) + respc(415), y + respc(95) + respc(10), x + respc(28) + respc(415), y + respc(95) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'right', 'top')

        --[[ Vehice List ]]
        local startX, startY = x + respc(28) + respc(10), y + respc(95) + respc(30)
        vehHover = nil

        VehicleScrollBarHover = isInSlot(startX, startY, respc(410), ((respc(20) + respc(5)) * 7) - respc(5))

        for i = VehicleMinLines, VehicleMaxLines do
            local w4, h4 = respc(410), respc(20)

            local inSlot = isInSlot(startX,startY,w4,h4)

            if inSlot or vehSelected == i then
                if inSlot then
                    vehHover = i
                end

                dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
            else
                dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
            end
            
            local e = playerVehicles[i]
            if e then
                local data = playerVehiclesData[e]
                if data then
                    if inSlot or vehSelected == i then
                        dxDrawText(data["name"], startX + respc(5),startY, startX + respc(5), startY + h4 + respc(4), tocolor(51,51,51,alpha), 1, font6, "left", "center")
                        dxDrawText(data["id"], startX + respc(235),startY, startX + respc(235), startY + h4 + respc(4), tocolor(51,51,51,alpha), 1, font6, "center", "center")
                        dxDrawText(data["health"] .. "%", startX + respc(405),startY, startX + respc(405), startY + h4 + respc(4), tocolor(51,51,51,alpha), 1, font6, "right", "center")
                    else
                        dxDrawText(data["name"], startX + respc(5),startY, startX + respc(5), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font6, "left", "center")
                        dxDrawText(data["id"], startX + respc(235),startY, startX + respc(235), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font6, "center", "center")
                        dxDrawText(data["health"] .. "%", startX + respc(405),startY, startX + respc(405), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font6, "right", "center")
                    end

                    if not data["locked"] then
                        exports['cr_dx']:dxDrawImageAsTexture(startX + respc(150), startY + h4/2 - respc(14)/2, respc(14), respc(14), ":cr_dashboard/assets/images/key.png", 0, 0, 0, tocolor(97, 177, 90, alpha))
                    else
                        exports['cr_dx']:dxDrawImageAsTexture(startX + respc(150), startY + h4/2 - respc(14)/2, respc(14), respc(14), ":cr_dashboard/assets/images/key.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
                    end

                    if isInSlot(startX + respc(150), startY + h4/2 - respc(14)/2, respc(14), respc(14)) then 
                        exports['cr_dx']:drawTooltip(1, '#F2F2F2' .. (data['locked'] and 'Zárva' or 'Nyitva'))
                    end 
                end
            end
            
            startY = startY + h4 + respc(5)
        end

        --[[ Vehice List Scrollbar ]]

        local scrollx, scrolly = x + respc(28) + w3 - respc(3), y + respc(95) + respc(30)
        local scrollh = ((respc(20) + respc(5)) * 7) - respc(5)

        dxDrawRectangle(scrollx, scrolly, respc(3), scrollh, tocolor(242, 242, 242, alpha * 0.6))
    
        local percent = #playerVehicles

        if percent >= 1  then
            local gW, gH = respc(3), scrollh
            local gX, gY = scrollx, scrolly

            VehicleScrollingHover = isInSlot(gX, gY, gW, gH)

            if VehicleScrolling then
                if isCursorShowing() then
                    if getKeyState("mouse1") then
                        local cx, cy = exports['cr_core']:getCursorPosition()
                        local cy = math.min(math.max(cy, gY), gY + gH)
                        local y = (cy - gY) / (gH)
                        local num = percent * y
                        VehicleMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 7) + 1)))
                        VehicleMaxLines = VehicleMinLines + (7 - 1)
                    end
                else
                    VehicleScrolling = false
                end
            end

            local multiplier = math.min(math.max((VehicleMaxLines - (VehicleMinLines - 1)) / percent, 0), 1)
            local multiplier2 = math.min(math.max((VehicleMinLines - 1) / percent, 0), 1)
            local gY = gY + ((gH) * multiplier2)
            local gH = gH * multiplier

            dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
        end

        --[[ Vehicle Informations ]]
        if tonumber(vehSelected) then
            if playerVehicles[vehSelected] and playerVehiclesData[playerVehicles[vehSelected]] then
                local name = playerVehiclesData[playerVehicles[vehSelected]]['name']
                dxDrawText(name, x + respc(28) + respc(15), y + respc(95) + respc(220), x + respc(28) + respc(15), y + respc(95) + respc(220), tocolor(242, 242, 242, alpha), 1, font8, 'left', 'top')
            end 
        end 

        local startX, startY = x + respc(28) + respc(10), y + respc(95) + respc(240)

        VehicleInfoScrollBarHover = isInSlot(startX, startY, respc(410), ((respc(20) + respc(5)) * 7) - respc(5))

        for i = VehicleInfoMinLines, VehicleInfoMaxLines do
            local w4, h4 = respc(410), respc(20)

            local inSlot = isInSlot(startX,startY,w4,h4)
            if inSlot then
                dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
            else
                dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
            end
            
            if #playerVehicleInfos >= 1 then
                if playerVehicleInfos[i] then
                    local v = playerVehicleInfos[i]

                    if inSlot then
                        dxDrawText(string.gsub(v, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(51, 51, 51,alpha), 1, font7, "left", "center", false, false, false, true)
                    else
                        dxDrawText(v, startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                    end
                end
            end
            
            startY = startY + h4 + respc(5)
        end

        --[[ Vehice Informations Scrollbar ]]
        local scrollx, scrolly = x + respc(28) + w3 - respc(3), y + respc(95) + respc(240)
        local scrollh = ((respc(20) + respc(5)) * 7) - respc(5)
        dxDrawRectangle(scrollx, scrolly, respc(3), scrollh, tocolor(242, 242, 242, alpha * 0.6))
    
        local percent = #playerVehicleInfos

        if percent >= 1  then
            local gW, gH = respc(3), scrollh
            local gX, gY = scrollx, scrolly

            VehicleInfoScrollingHover = isInSlot(gX, gY, gW, gH)

            if VehicleInfoScrolling then
                if isCursorShowing() then
                    if getKeyState("mouse1") then
                        local cx, cy = exports['cr_core']:getCursorPosition()
                        local cy = math.min(math.max(cy, gY), gY + gH)
                        local y = (cy - gY) / (gH)
                        local num = percent * y
                        VehicleInfoMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 7) + 1)))
                        VehicleInfoMaxLines = VehicleInfoMinLines + (7 - 1)
                    end
                else
                    VehicleInfoScrolling = false
                end
            end

            local multiplier = math.min(math.max((VehicleInfoMaxLines - (VehicleInfoMinLines - 1)) / percent, 0), 1)
            local multiplier2 = math.min(math.max((VehicleInfoMinLines - 1) / percent, 0), 1)
            local gY = gY + ((gH) * multiplier2)
            local gH = gH * multiplier

            dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
        end

        --[[
            Vehicle Slots
        ]]
        dxDrawRectangle(x + respc(28) + w3 - respc(100), y + respc(95) - respc(5) - respc(20), respc(100), respc(20), tocolor(41, 41, 41, alpha * 0.9))
        dxDrawRectangle(x + respc(28) + w3 - respc(100) + respc(2), y + respc(95) - respc(5) - respc(20) + respc(2), respc(70), respc(16), tocolor(51, 51, 51, alpha * 0.6))
        buyHover = nil

        if isInSlot(x + respc(28) + w3 - respc(8) - respc(12), y + respc(95) - respc(5) - respc(20) + respc(20)/2 - respc(12)/2, respc(12), respc(12)) then 
            buyHover = "buyVeh"

            exports['cr_dx']:dxDrawImageAsTexture(x + respc(28) + w3 - respc(8) - respc(12), y + respc(95) - respc(5) - respc(20) + respc(20)/2 - respc(12)/2, respc(12), respc(12), ":cr_dashboard/assets/images/add.png", 0, 0, 0, tocolor(97, 177, 90, alpha))
        else 
            exports['cr_dx']:dxDrawImageAsTexture(x + respc(28) + w3 - respc(8) - respc(12), y + respc(95) - respc(5) - respc(20) + respc(20)/2 - respc(12)/2, respc(12), respc(12), ":cr_dashboard/assets/images/add.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
        end 

        UpdatePos("VehSlot >> buy", {x + respc(28) + w3 - respc(100) + respc(2) + respc(5), y + respc(95) - respc(5) - respc(20) + respc(2), respc(70) - respc(10), respc(16) + respc(2)})

        dxDrawText('Jármű Slotjaid: '.. yellow .. datas["vehSlots"] .. '#F2F2F2 db', x + respc(28) + w3 - respc(5), y + respc(95) - respc(45), x + respc(28) + w3 - respc(5), y + respc(95) - respc(45), tocolor(242, 242, 242, alpha), 1, font8, 'right', 'top', false, false, false, true)

        --[[Veh Sell Button]]
        local buttonY = y + respc(95) - respc(5) - respc(20)

        local buttonW, buttonH = respc(100), respc(20)

        vehSellHover = nil
        if tonumber(vehSelected) then
            if playerVehicles[vehSelected] and playerVehiclesData[playerVehicles[vehSelected]] then
                if isInSlot(x + respc(28), buttonY, buttonW, buttonH) then 
                    vehSellHover = true

                    dxDrawRectangle(x + respc(28), buttonY, buttonW, buttonH, tocolor(97, 177, 90, alpha)) 
                    dxDrawText('Eladás', x + respc(28), buttonY, x + respc(28) + buttonW, buttonY + buttonH + respc(4), tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
                else
                    dxDrawRectangle(x + respc(28), buttonY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                    dxDrawText('Eladás', x + respc(28), buttonY, x + respc(28) + buttonW, buttonY + buttonH + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
                end 
            end 
        end

        --[[
            Interiors
        ]]
        dxDrawRectangle(x + respc(488), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawRectangle(x + respc(488) + w3/2 - respc(380)/2, y + respc(95) + respc(210), respc(380), respc(2), tocolor(135, 135, 135, alpha * 0.6))

        dxDrawText('Ingatlan név', x + respc(488) + respc(15), y + respc(95) + respc(10), x + respc(488) + respc(15), y + respc(95) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'top')
        dxDrawText('Ingatlan ID', x + respc(488) + respc(415), y + respc(95) + respc(10), x + respc(488) + respc(415), y + respc(95) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'right', 'top')

        --[[ Interior List ]]
        local startX, startY = x + respc(488) + respc(10), y + respc(95) + respc(30)
        intHover = nil

        InteriorScrollBarHover = isInSlot(startX, startY, respc(410), ((respc(20) + respc(5)) * 7) - respc(5))

        for i = InteriorMinLines, InteriorMaxLines do
            local w4, h4 = respc(410), respc(20)

            local inSlot = isInSlot(startX,startY,w4,h4)

            if inSlot or intSelected == i then
                if inSlot then
                    intHover = i
                end

                dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
            else
                dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
            end
            
            local e = playerInterior[i]
            if e then
                local data = playerInteriorData[e]
                if data then
                    if inSlot or intSelected == i then
                        dxDrawText(data["name"], startX + respc(5),startY, startX + respc(5), startY + h4 + respc(4), tocolor(51,51,51,alpha), 1, font6, "left", "center")
                        dxDrawText(data["id"], startX + respc(405),startY, startX + respc(405), startY + h4 + respc(4), tocolor(51,51,51,alpha), 1, font6, "right", "center")
                    else
                        dxDrawText(data["name"], startX + respc(5),startY, startX + respc(5), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font6, "left", "center")
                        dxDrawText(data["id"], startX + respc(405),startY, startX + respc(405), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font6, "right", "center")
                    end

                    if not data["locked"] then
                        exports['cr_dx']:dxDrawImageAsTexture(startX + w4/2 - respc(14)/2, startY + h4/2 - respc(14)/2, respc(14), respc(14), ":cr_dashboard/assets/images/key.png", 0, 0, 0, tocolor(97, 177, 90, alpha))
                    else
                        exports['cr_dx']:dxDrawImageAsTexture(startX + w4/2 - respc(14)/2, startY + h4/2 - respc(14)/2, respc(14), respc(14), ":cr_dashboard/assets/images/key.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
                    end

                    if isInSlot(startX + w4/2 - respc(14)/2, startY + h4/2 - respc(14)/2, respc(14), respc(14)) then 
                        exports['cr_dx']:drawTooltip(1, '#F2F2F2' .. (data['locked'] and 'Zárva' or 'Nyitva'))
                    end 
                end
            end
            
            startY = startY + h4 + respc(5)
        end

        --[[ Interior List Scrollbar ]]
        local scrollx, scrolly = x + respc(488) + w3 - respc(3), y + respc(95) + respc(30)
        local scrollh = ((respc(20) + respc(5)) * 7) - respc(5)

        dxDrawRectangle(scrollx, scrolly, respc(3), scrollh, tocolor(242, 242, 242, alpha * 0.6))
    
        local percent = #playerInterior

        if percent >= 1  then
            local gW, gH = respc(3), scrollh
            local gX, gY = scrollx, scrolly

            InteriorScrollingHover = isInSlot(gX, gY, gW, gH)

            if InteriorScrolling then
                if isCursorShowing() then
                    if getKeyState("mouse1") then
                        local cx, cy = exports['cr_core']:getCursorPosition()
                        local cy = math.min(math.max(cy, gY), gY + gH)
                        local y = (cy - gY) / (gH)
                        local num = percent * y
                        InteriorMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 7) + 1)))
                        InteriorMaxLines = InteriorMinLines + (7 - 1)
                    end
                else
                    InteriorScrolling = false
                end
            end

            local multiplier = math.min(math.max((InteriorMaxLines - (InteriorMinLines - 1)) / percent, 0), 1)
            local multiplier2 = math.min(math.max((InteriorMinLines - 1) / percent, 0), 1)
            local gY = gY + ((gH) * multiplier2)
            local gH = gH * multiplier

            dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
        end

        --[[ VehicInteriorle Informations ]]
        if tonumber(intSelected) then
            if playerInterior[intSelected] and playerInteriorData[playerInterior[intSelected]] then
                local name = playerInteriorData[playerInterior[intSelected]]['name']
                dxDrawText(name, x + respc(488) + respc(15), y + respc(95) + respc(220), x + respc(488) + respc(15), y + respc(95) + respc(220), tocolor(242, 242, 242, alpha), 1, font8, 'left', 'top')
            end 
        end 

        local startX, startY = x + respc(488) + respc(10), y + respc(95) + respc(240)

        InteriorInfoScrollBarHover = isInSlot(startX, startY, respc(410), ((respc(20) + respc(5)) * 7) - respc(5))

        for i = InteriorInfoMinLines, InteriorInfoMaxLines do
            local w4, h4 = respc(410), respc(20)

            local inSlot = isInSlot(startX,startY,w4,h4)
            if inSlot then
                dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
            else
                dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
            end
            
            if #playerInteriorInfos >= 1 then
                if playerInteriorInfos[i] then
                    local v = playerInteriorInfos[i]

                    if inSlot then
                        dxDrawText(string.gsub(v, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(51, 51, 51,alpha), 1, font7, "left", "center", false, false, false, true)
                    else
                        dxDrawText(v, startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                    end
                end
            end
            
            startY = startY + h4 + respc(5)
        end

        --[[ Interior Informations Scrollbar ]]
        local scrollx, scrolly = x + respc(488) + w3 - respc(3), y + respc(95) + respc(240)
        local scrollh = ((respc(20) + respc(5)) * 7) - respc(5)
        dxDrawRectangle(scrollx, scrolly, respc(3), scrollh, tocolor(242, 242, 242, alpha * 0.6))
    
        local percent = #playerInteriorInfos

        if percent >= 1  then
            local gW, gH = respc(3), scrollh
            local gX, gY = scrollx, scrolly

            InteriorInfoScrollingHover = isInSlot(gX, gY, gW, gH)

            if InteriorInfoScrolling then
                if isCursorShowing() then
                    if getKeyState("mouse1") then
                        local cx, cy = exports['cr_core']:getCursorPosition()
                        local cy = math.min(math.max(cy, gY), gY + gH)
                        local y = (cy - gY) / (gH)
                        local num = percent * y
                        InteriorInfoMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 7) + 1)))
                        InteriorInfoMaxLines = InteriorInfoMinLines + (7 - 1)
                    end
                else
                    InteriorInfoScrolling = false
                end
            end

            local multiplier = math.min(math.max((InteriorInfoMaxLines - (InteriorInfoMinLines - 1)) / percent, 0), 1)
            local multiplier2 = math.min(math.max((InteriorInfoMinLines - 1) / percent, 0), 1)
            local gY = gY + ((gH) * multiplier2)
            local gH = gH * multiplier

            dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
        end

        --[[
            Interior slots
        ]]
        dxDrawRectangle(x + respc(488), y + respc(95) - respc(5) - respc(20), respc(100), respc(20), tocolor(41, 41, 41, alpha * 0.9))
        dxDrawRectangle(x + respc(488) + respc(2), y + respc(95) - respc(5) - respc(20) + respc(2), respc(70), respc(16), tocolor(51, 51, 51, alpha * 0.6))

        if isInSlot(x + respc(488) + respc(100) - respc(8) - respc(12), y + respc(95) - respc(5) - respc(20) + respc(20)/2 - respc(12)/2, respc(12), respc(12)) then 
            buyHover = "buyInt"

            exports['cr_dx']:dxDrawImageAsTexture(x + respc(488) + respc(100) - respc(8) - respc(12), y + respc(95) - respc(5) - respc(20) + respc(20)/2 - respc(12)/2, respc(12), respc(12), ":cr_dashboard/assets/images/add.png", 0, 0, 0, tocolor(97, 177, 90, alpha))
        else 
            exports['cr_dx']:dxDrawImageAsTexture(x + respc(488) + respc(100) - respc(8) - respc(12), y + respc(95) - respc(5) - respc(20) + respc(20)/2 - respc(12)/2, respc(12), respc(12), ":cr_dashboard/assets/images/add.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
        end 

        UpdatePos("IntSlot >> buy", {x + respc(488) + respc(2) + respc(5), y + respc(95) - respc(5) - respc(20) + respc(2), respc(70) - respc(10), respc(16) + respc(2)})

        dxDrawText('Ingatlan Slotjaid: '.. yellow .. datas["intSlots"] .. '#F2F2F2 db', x + respc(488) + respc(5), y + respc(95) - respc(45), x + respc(488) + respc(5), y + respc(95) - respc(45), tocolor(242, 242, 242, alpha), 1, font8, 'left', 'top', false, false, false, true)

        --[[Int Sell Button]]
        local buttonY = y + respc(95) - respc(5) - respc(20)

        local buttonW, buttonH = respc(100), respc(20)

        intSellHover = nil
        if tonumber(intSelected) then
            if playerInterior[intSelected] and playerInteriorData[playerInterior[intSelected]] and playerInteriorData[playerInterior[intSelected]]["type"] ~= 3 and playerInteriorData[playerInterior[intSelected]]["type"] ~= 7 then
                if isInSlot(x + respc(488) + w3 - buttonW, buttonY, buttonW, buttonH) then 
                    intSellHover = true

                    dxDrawRectangle(x + respc(488) + w3 - buttonW, buttonY, buttonW, buttonH, tocolor(97, 177, 90, alpha)) 
                    dxDrawText('Eladás', x + respc(488) + w3 - buttonW, buttonY, x + respc(488) + w3 - buttonW + buttonW, buttonY + buttonH + respc(4), tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
                else
                    dxDrawRectangle(x + respc(488) + w3 - buttonW, buttonY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                    dxDrawText('Eladás', x + respc(488) + w3 - buttonW, buttonY, x + respc(488) + w3 - buttonW + buttonW, buttonY + buttonH + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
                end 
            end 
        end
    elseif cache['page'] == 3 then 
        local x = x + w2

        if not datas["faction"] or #datas["faction"] == 0 then
            --Jelenleg nem vagy frakcióban
            
            local startY = y + h/2 - ((respc(101) + respc(30))/2)
            exports['cr_dx']:dxDrawImageAsTexture(x + (w - w2)/2 - respc(107)/2, startY, respc(107), respc(101), ":cr_dashboard/assets/images/warning.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.7))

            startY = startY + respc(101) + respc(10)

            dxDrawText('Jelenleg nem vagy frakcióban!', x, startY, x + (w - w2), startY, tocolor(255, 59, 59, alpha), 1, font, "center", "top")
        else 

            --[[
                Header
            ]]
            dxDrawText('Frakció', x + respc(20), y + respc(24), x + respc(20), y + respc(24) + respc(35) + respc(5), tocolor(242, 242, 242, alpha), 1, font2, "left", "center")
            dxDrawImage(x + respc(741), y + respc(24), respc(35), respc(35), ":cr_interface/hud/files/avatars/"..datas["avatar"]..".png", 0, 0, 0, tocolor(255, 255, 255, alpha))

            dxDrawText(datas['charName'], x + respc(741) + respc(35) + respc(20), y + respc(24) - respc(5), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(35), tocolor(242, 242, 242, alpha), 1, font3, "left", "top")
            dxDrawText('Szint: ' .. yellow .. datas['lvl'] .. "#F2F2F2 - ".. datas['adminColor'] .. datas['adminTitle'], x + respc(741) + respc(35) + respc(20), y + respc(24), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(5) + respc(35), tocolor(242, 242, 242, alpha), 1, font4, "left", "bottom", false, false, false, true)

            --[[
                Menu
            ]]

            local startX = x + respc(105)

            factionsHover = nil
            for k,v in ipairs(factionButtons) do 
                local textWidth = dxGetTextWidth(v, 1, font9) + respc(10)
                local inSlot = isInSlot(startX, y + respc(24), textWidth, respc(40))

                local gradientHeight = respc(10)

                local textAlpha = alpha
                local lineAlpha = alpha

                if factionButtonAnimation[k] then 
                    local startTick, type = unpack(factionButtonAnimation[k])
                    local progress = (nowTick - startTick) / 250

                    if progress > 1 then 
                        factionButtonAnimation[k] = nil
                    end 

                    gradientHeight, textAlpha, lineAlpha = interpolateBetween(
                        type == 1 and 0 or gradientHeight, type == 1 and alpha * 0.6 or textAlpha, type == 1 and 0 or lineAlpha,
                        type == 1 and gradientHeight or 0, type == 1 and textAlpha or alpha * 0.6, type == 1 and lineAlpha or 0,
                        progress, "InOutQuad"
                    )
                end

                dxDrawRectangle(startX, y + respc(52.5), textWidth, 2, tocolor(51, 51, 51, alpha * 0.3))
                if factionsSelected == k or factionButtonAnimation[k] then 
                    exports['cr_dx']:dxDrawImageAsTexture(startX, y + respc(52.5) - gradientHeight, textWidth, gradientHeight, ':cr_bank/assets/images/gradient.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.6))

                    dxDrawRectangle(startX, y + respc(52.5), textWidth, 2, tocolor(255, 59, 59, lineAlpha))
                end 

                if inSlot or factionsSelected == k or factionButtonAnimation[k] then 
                    if inSlot and factionsSelected ~= k then
                        factionsHover = k
                    end

                    dxDrawText(v, startX, y + respc(24), startX + textWidth, y + respc(24) + respc(35) + respc(5), tocolor(242, 242, 242, textAlpha), 1, font9, "center", "center")
                else 
                    dxDrawText(v, startX, y + respc(24), startX + textWidth, y + respc(24) + respc(35) + respc(5), tocolor(242, 242, 242, alpha * 0.6), 1, font9, "center", "center")
                end 

                startX = startX + textWidth
            end 

            --[[
                Pages
            ]]
            if factionsSelected == 1 then 
                --[[
                    Factions
                ]]
                local w3, h3 = respc(430), respc(430)
                dxDrawRectangle(x + respc(28), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
                dxDrawRectangle(x + respc(28) + w3/2 - respc(380)/2, y + respc(95) + respc(210), respc(380), respc(2), tocolor(135, 135, 135, alpha * 0.6))

                --[[Faction List]]
                dxDrawText('Frakciók:', x + respc(28) + respc(15), y + respc(95) + respc(10), x + respc(28) + respc(15), y + respc(95) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'top')
                local startX, startY = x + respc(28) + respc(10), y + respc(95) + respc(30)

                FactionScrollBarHover = isInSlot(startX, startY, respc(410), ((respc(20) + respc(5)) * 7) - respc(5))

                factionSelectorButton  = nil
                for i = factionSelectorMinLines, factionSelectorMaxLines do 
                    local w4, h4 = respc(410), respc(20)

                    local inSlot = isInSlot(startX,startY,w4,h4)
                    if inSlot or selectedFaction == i then
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
                    else
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
                    end
                    
                    local data = datas["faction"][i]
                    if data then
                        if inSlot or selectedFaction == i then
                            if inSlot then 
                                factionSelectorButton = i
                            end 

                            dxDrawText(string.gsub(data[2], "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(51, 51, 51,alpha), 1, font7, "left", "center", false, false, false, true)
                        else
                            dxDrawText(data[2], startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                        end
                    end
                    
                    startY = startY + h4 + respc(5)
                end

                --[[Faction List Scrollbar]]
                local scrollx, scrolly = x + respc(28) + w3 - respc(3), y + respc(95) + respc(30)
                local scrollh = ((respc(20) + respc(5)) * 7) - respc(5)
                dxDrawRectangle(scrollx, scrolly, respc(3), scrollh, tocolor(242, 242, 242, alpha * 0.6))
            
                local percent = #datas["faction"]

                if percent >= 1  then
                    local gW, gH = respc(3), scrollh
                    local gX, gY = scrollx, scrolly

                    FactionSelectorScrollingHover = isInSlot(gX, gY, gW, gH)

                    if FactionSelectorScrolling then
                        if isCursorShowing() then
                            if getKeyState("mouse1") then
                                local cx, cy = exports['cr_core']:getCursorPosition()
                                local cy = math.min(math.max(cy, gY), gY + gH)
                                local y = (cy - gY) / (gH)
                                local num = percent * y
                                factionSelectorMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 7) + 1)))
                                factionSelectorMaxLines = factionSelectorMinLines + (7 - 1)
                            end
                        else
                            FactionSelectorScrolling = false
                        end
                    end

                    local multiplier = math.min(math.max((factionSelectorMaxLines - (factionSelectorMinLines - 1)) / percent, 0), 1)
                    local multiplier2 = math.min(math.max((factionSelectorMinLines - 1) / percent, 0), 1)
                    local gY = gY + ((gH) * multiplier2)
                    local gH = gH * multiplier

                    dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
                end

                --[[
                    Faction Desc
                ]]
                dxDrawText('Frakció Üzenet:', x + respc(28) + respc(15), y + respc(95) + respc(220), x + respc(28) + respc(15), y + respc(95) + respc(220), tocolor(242, 242, 242, alpha), 1, font8, 'left', 'top')

                local w4, h4 = respc(410), respc(170)
                dxDrawRectangle(x + respc(28) + respc(10), y + respc(95) + respc(240), w4, h4, tocolor(51, 51, 51, alpha * 0.6))

                factionMessageEditHover = nil
                if not factionMessageEditing then 
                    dxDrawText(datas["faction"][selectedFaction][7], x + respc(28) + respc(10) + respc(5), y + respc(95) + respc(240) + respc(5), x + respc(28) + respc(10) + respc(5) + w4 - respc(10), y + respc(95) + respc(240) + respc(5) + h4 - respc(10), tocolor(242, 242, 242, alpha), 1, font4, "left", "top", false, true)
                else
                    UpdatePos("FactionMessage >> Edit", {x + respc(28) + respc(10) + respc(5), y + respc(95) + respc(240) + respc(5), w4 - respc(10), h4 - respc(10)})
                end 

                if datas["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 1 or hasPlayerPermission(cache["element"]:getData("acc >> id"), datas["faction"][selectedFaction][1], "faction.editmessage") then  -- isLeader
                    if isInSlot(x + respc(28) + respc(10) + w4 - respc(15), y + respc(95) + respc(240) - respc(20), respc(15), respc(15)) then 
                        factionMessageEditHover = true
            
                        exports['cr_dx']:dxDrawImageAsTexture(x + respc(28) + respc(10) + w4 - respc(15), y + respc(95) + respc(240) - respc(20), respc(15), respc(15), ":cr_dashboard/assets/images/descEdit.png", 0, 0, 0, tocolor(242, 242, 242, alpha))
                    else 
                        exports['cr_dx']:dxDrawImageAsTexture(x + respc(28) + respc(10) + w4 - respc(15), y + respc(95) + respc(240) - respc(20), respc(15), respc(15), ":cr_dashboard/assets/images/descEdit.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
                    end 
                end 

                --[[
                    Faction Informations
                ]]
                dxDrawRectangle(x + respc(488), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
                dxDrawRectangle(x + respc(488) + w3/2 - respc(380)/2, y + respc(95) + respc(210), respc(380), respc(2), tocolor(135, 135, 135, alpha * 0.6))
                dxDrawText('Frakció Információk:', x + respc(488) + respc(15), y + respc(95) + respc(10), x + respc(488) + respc(15), y + respc(95) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'top')

                --[[Faction Informations List]]
                local startX, startY = x + respc(488) + respc(10), y + respc(95) + respc(30)

                FactionInformationsScrollBarHover = isInSlot(startX, startY, respc(410), ((respc(20) + respc(5)) * 7) - respc(5))

                for i = factionInformationsMinLines, factionInformationsMaxLines do 
                    local w4, h4 = respc(410), respc(20)

                    local inSlot = isInSlot(startX,startY,w4,h4)
                    if inSlot then
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
                    else
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
                    end
                    
                    local data = playerFactionInformations[i]
                    if data then
                        if inSlot then
                            dxDrawText(string.gsub(data, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(51, 51, 51,alpha), 1, font7, "left", "center", false, false, false, true)
                        else
                            dxDrawText(data, startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                        end
                    end
                    
                    startY = startY + h4 + respc(5)
                end

                --[[Faction Informations Scrollbar]]
                local scrollx, scrolly = x + respc(488) + w3 - respc(3), y + respc(95) + respc(30)
                local scrollh = ((respc(20) + respc(5)) * 7) - respc(5)
                dxDrawRectangle(scrollx, scrolly, respc(3), scrollh, tocolor(242, 242, 242, alpha * 0.6))
            
                local percent = #playerFactionInformations

                if percent >= 1  then
                    local gW, gH = respc(3), scrollh
                    local gX, gY = scrollx, scrolly

                    FactionInformationsScrollingHover = isInSlot(gX, gY, gW, gH)

                    if FactionInformationsScrolling then
                        if isCursorShowing() then
                            if getKeyState("mouse1") then
                                local cx, cy = exports['cr_core']:getCursorPosition()
                                local cy = math.min(math.max(cy, gY), gY + gH)
                                local y = (cy - gY) / (gH)
                                local num = percent * y
                                factionInformationsMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 7) + 1)))
                                factionInformationsMaxLines = factionInformationsMinLines + (7 - 1)
                            end
                        else
                            FactionInformationsScrolling = false
                        end
                    end

                    local multiplier = math.min(math.max((factionInformationsMaxLines - (factionInformationsMinLines - 1)) / percent, 0), 1)
                    local multiplier2 = math.min(math.max((factionInformationsMinLines - 1) / percent, 0), 1)
                    local gY = gY + ((gH) * multiplier2)
                    local gH = gH * multiplier

                    dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
                end

                --[[
                    Faction Bank
                ]]
                dxDrawText('Frakció Egyenleg Kezelése:', x + respc(488) + respc(15), y + respc(95) + respc(220), x + respc(488) + respc(15), y + respc(95) + respc(220), tocolor(242, 242, 242, alpha), 1, font8, 'left', 'top')
                exports['cr_dx']:dxDrawImageAsTexture(x + respc(488) + respc(20), y + respc(95) + respc(250), respc(20), respc(20), ":cr_dashboard/assets/images/safe.png", 0, 0, 0, tocolor(242, 242, 242, alpha))
                dxDrawText('Frakció egyenlege: '..green..'$ '..datas["faction"][selectedFaction][6], x + respc(488) + respc(20) + respc(20) + respc(6), y + respc(95) + respc(250), x + respc(488) + respc(20) + respc(20) + respc(6), y + respc(95) + respc(250) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font4, 'left', 'center', false, false, false, true)

                dxDrawText('Összeg: ', x + respc(488) + respc(100) - respc(10), y + respc(95) + respc(292), x + respc(488) + respc(100) - respc(10), y + respc(95) + respc(292) + respc(20) + respc(2), tocolor(242, 242, 242, alpha), 1, font5, 'right', 'center')
                dxDrawRectangle(x + respc(488) + respc(100), y + respc(95) + respc(292), respc(310), respc(20), tocolor(51, 51, 51, alpha * 0.6))
                UpdatePos("FactionBank >> Edit", {x + respc(488) + respc(100) + respc(5), y + respc(95) + respc(292) + respc(5), respc(310) - respc(10), respc(20) - respc(10) + respc(4)})
                UpdateAlpha("FactionBank >> Edit", tocolor(97, 177, 90, alpha))

                --[[Faction Bank Buttons]]
                factionBankHover = nil
                if isInSlot(x + respc(488) + respc(30), y + respc(95) + respc(360), respc(180), respc(22)) then 
                    factionBankHover = 1

                    dxDrawRectangle(x + respc(488) + respc(30), y + respc(95) + respc(360), respc(180), respc(22), tocolor(97, 177, 90, alpha))
                    dxDrawText('Készpénz berakás', x + respc(488) + respc(30), y + respc(95) + respc(360), x + respc(488) + respc(30) + respc(180), y + respc(95) + respc(360) + respc(22) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
                else 
                    dxDrawRectangle(x + respc(488) + respc(30), y + respc(95) + respc(360), respc(180), respc(22), tocolor(23, 23, 23, alpha * 0.9))
                    dxDrawText('Készpénz berakás', x + respc(488) + respc(30), y + respc(95) + respc(360), x + respc(488) + respc(30) + respc(180), y + respc(95) + respc(360) + respc(22) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
                end 

                if isInSlot(x + respc(488) + respc(220), y + respc(95) + respc(360), respc(180), respc(22)) then 
                    factionBankHover = 2
                    
                    dxDrawRectangle(x + respc(488) + respc(220), y + respc(95) + respc(360), respc(180), respc(22), tocolor(255, 59, 59, alpha))
                    dxDrawText('Készpénz kivétel', x + respc(488) + respc(220), y + respc(95) + respc(360), x + respc(488) + respc(220) + respc(180), y + respc(95) + respc(360) + respc(22) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
                else 
                    dxDrawRectangle(x + respc(488) + respc(220), y + respc(95) + respc(360), respc(180), respc(22), tocolor(23, 23, 23, alpha * 0.9))
                    dxDrawText('Készpénz kivétel', x + respc(488) + respc(220), y + respc(95) + respc(360), x + respc(488) + respc(220) + respc(180), y + respc(95) + respc(360) + respc(22) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
                end 
            elseif factionsSelected == 2 then 
                --[[
                    Faction Members
                ]]
                local w3, h3 = respc(430), respc(430)
                dxDrawRectangle(x + respc(28), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
                dxDrawText('Frakció Tagok:', x + respc(28) + respc(15), y + respc(95) + respc(8), x + respc(28) + respc(15), y + respc(95) + respc(8) + respc(18) + respc(4), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'center')

                --[[Faction Members Search]]
                dxDrawRectangle(x + respc(28) + respc(140), y + respc(95) + respc(8), respc(280), respc(18), tocolor(51, 51, 51, alpha * 0.8))
                exports['cr_dx']:dxDrawImageAsTexture(x + respc(28) + respc(140) + respc(280) - respc(10) - respc(5), y + respc(95) + respc(8) + respc(18)/2 - respc(10)/2, respc(10), respc(10), ":cr_scoreboard/files/search.png", 0, 0, 0, tocolor(242, 242, 242, alpha)) 
                UpdatePos("FactionMembers >> search", {x + respc(28) + respc(140) + respc(5), y + respc(95) + respc(8) + respc(5), respc(280) - respc(10), respc(18) - respc(10) + respc(4)})

                --[[Faction Members List]]
                local players = datas["faction"][selectedFaction]["players"]

                local percent = #players

                if factionMembersSearchCache then
                    players = factionMembersSearchCache
                    percent = #factionMembersSearchCache
                end

                if factionMembersMaxLines > percent then
                    factionMembersMinLines = 1
                    factionMembersMaxLines = 16
                end

                local startX, startY = x + respc(28) + respc(10), y + respc(95) + respc(30)

                factionMembersScrollBarHover = isInSlot(startX, startY, respc(410), ((respc(20) + respc(5)) * 16) - respc(5))

                factionMembersHover = nil
                for i = factionMembersMinLines, factionMembersMaxLines do
                    local w4, h4 = respc(410), respc(20)

                    local inSlot = isInSlot(startX,startY,w4,h4)
                    local data = players[i]

                    if inSlot or data and factionMembersSelected == i then
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
                    else
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
                    end
                    
                    if data then
                        local nick = data[2]:gsub("_", " ")
                        local rankName = datas["faction"][selectedFaction][4][data[3]]["name"] or "Ismeretlen"
                        
                        if inSlot or factionMembersSelected == i then
                            if inSlot then
                                factionMembersHover = i
                            end

                            dxDrawText(string.gsub(nick, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(51, 51, 51,alpha), 1, font7, "left", "center", false, false, false, true)
                            dxDrawText(string.gsub(rankName, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(405),startY, startX + respc(405), startY + h4 + respc(4), tocolor(51,51,51,alpha), 1, font7, "right", "center")
                        else
                            dxDrawText(nick, startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                            dxDrawText(rankName, startX + respc(405),startY, startX + respc(405), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "right", "center")
                        end
                    end
                    
                    startY = startY + h4 + respc(5)
                end

                --[[Faction Members Scrollbar]]
                local scrollx, scrolly = x + respc(28) + w3 - respc(3), y + respc(95) + respc(30)
                local scrollh = ((respc(20) + respc(5)) * 16) - respc(5)
                dxDrawRectangle(scrollx, scrolly, respc(3), scrollh, tocolor(242, 242, 242, alpha * 0.6))

                if percent >= 1 then
                    local gW, gH = respc(3), scrollh
                    local gX, gY = scrollx, scrolly

                    factionMembersScrollingHover = isInSlot(gX, gY, gW, gH)

                    if factionMembersScrolling then
                        if isCursorShowing() then
                            if getKeyState("mouse1") then
                                local cx, cy = exports['cr_core']:getCursorPosition()
                                local cy = math.min(math.max(cy, gY), gY + gH)
                                local y = (cy - gY) / (gH)
                                local num = percent * y
                                factionMembersMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 16) + 1)))
                                factionMembersMaxLines = factionMembersMinLines + (16 - 1)
                            end
                        else
                            factionMembersScrolling = false
                        end
                    end

                    local multiplier = math.min(math.max((factionMembersMaxLines - (factionMembersMinLines - 1)) / percent, 0), 1)
                    local multiplier2 = math.min(math.max((factionMembersMinLines - 1) / percent, 0), 1)
                    local gY = gY + ((gH) * multiplier2)
                    local gH = gH * multiplier

                    dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
                end

                --[[
                    Member Informations
                ]]
                dxDrawRectangle(x + respc(488), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
                dxDrawRectangle(x + respc(488) + w3/2 - respc(380)/2, y + respc(95) + respc(210), respc(380), respc(2), tocolor(135, 135, 135, alpha * 0.6))
                dxDrawRectangle(x + respc(488) + w3/2 - respc(380)/2, y + respc(95) + respc(270), respc(380), respc(2), tocolor(135, 135, 135, alpha * 0.6))

                dxDrawText('Tag Információk:', x + respc(488) + respc(15), y + respc(95) + respc(10), x + respc(488) + respc(15), y + respc(95) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'top')

                --[[Member Informations List]]
                
                local startX, startY = x + respc(488) + respc(10), y + respc(95) + respc(30)

                for i = 1, 7 do 
                    local w4, h4 = respc(410), respc(20)

                    local inSlot = isInSlot(startX,startY,w4,h4)
                    if inSlot then
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
                    else
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
                    end
                    
                    if #factionMemberInfos >= 1 then
                        if factionMemberInfos[i] then
                            local v = factionMemberInfos[i]
                            if inSlot then
                                dxDrawText(string.gsub(v, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(51, 51, 51,alpha), 1, font7, "left", "center", false, false, false, true)
                            else
                                dxDrawText(v, startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                            end
                        end
                    end
                    
                    startY = startY + h4 + respc(5)
                end

                --[[
                    Own Informations
                ]]
                dxDrawText('Saját Információk:', x + respc(488) + respc(15), y + respc(95) + respc(280), x + respc(488) + respc(15), y + respc(95) + respc(280), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'top')

                local startX, startY = x + respc(488) + respc(10), y + respc(95) + respc(300)

                factionDutyHover = nil
                for i = 1, 5 do 
                    local w4, h4 = respc(410), respc(20)

                    local inSlot = isInSlot(startX,startY,w4,h4)
                    if inSlot then
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
                    else
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
                    end
                    
                    if #factionMyMemberInfos >= 1 then
                        if factionMyMemberInfos[i] then
                            local v = factionMyMemberInfos[i]
                            if inSlot then
                                dxDrawText(string.gsub(v, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(51, 51, 51,alpha), 1, font7, "left", "center", false, false, false, true)
                            else
                                dxDrawText(v, startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                            end
                        end
                    end

                    if i == 4 then 
                        if factionDutySkinData[datas["faction"][selectedFaction][1]] then 
                            local showPosition = factionDutySkinData[datas["faction"][selectedFaction][1]]["showposition"]
                            local localDimension = getElementDimension(localPlayer)
                            local localInterior = getElementInterior(localPlayer)

                            if getDistanceBetweenPoints3D(localPlayer.position, factionDutySkinData[datas["faction"][selectedFaction][1]]["position"]) <= 5 and showPosition[4] == localDimension and showPosition[5] == localInterior then 
                                local w5, h5 = respc(25), respc(25)

                                if inSlot then 
                                    if isInSlot(startX + w4 - respc(5) - w5 + respc(5), startY + h4/2 - h5/2, w5 - respc(10), h5) then 
                                        factionDutyHover = datas["faction"][selectedFaction][3][datas["accId"]][9]

                                        exports['cr_dx']:dxDrawImageAsTexture(startX + w4 - respc(5) - w5, startY + h4/2 - h5/2, w5, h5, ':cr_dashboard/assets/images/dutyskin.png', 0, 0, 0, tocolor(51, 51, 51, alpha * 0.8))
                                    else 
                                        exports['cr_dx']:dxDrawImageAsTexture(startX + w4 - respc(5) - w5, startY + h4/2 - h5/2, w5, h5, ':cr_dashboard/assets/images/dutyskin.png', 0, 0, 0, tocolor(51, 51, 51, alpha * 0.4))
                                    end 
                                else 
                                    exports['cr_dx']:dxDrawImageAsTexture(startX + w4 - respc(5) - w5, startY + h4/2 - h5/2, w5, h5, ':cr_dashboard/assets/images/dutyskin.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.4))
                                end
                            end
                        end 
                    end 
                    
                    startY = startY + h4 + respc(5)
                end

                --[[
                    Faction Member Buttons
                ]]
                factionMembersButtonHover = nil
                if isInSlot(x + respc(488) + respc(15), y + respc(95) + respc(218), respc(130), respc(20)) then 
                    factionMembersButtonHover = 1

                    dxDrawRectangle(x + respc(488) + respc(15), y + respc(95) + respc(218), respc(130), respc(20), tocolor(97, 177, 90, alpha))
                    dxDrawText('Előléptetés', x + respc(488) + respc(15), y + respc(95) + respc(218), x + respc(488) + respc(15) + respc(130), y + respc(95) + respc(218) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
                else 
                    dxDrawRectangle(x + respc(488) + respc(15), y + respc(95) + respc(218), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                    dxDrawText('Előléptetés', x + respc(488) + respc(15), y + respc(95) + respc(218), x + respc(488) + respc(15) + respc(130), y + respc(95) + respc(218) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
                end 

                if isInSlot(x + respc(488) + respc(150), y + respc(95) + respc(218), respc(130), respc(20)) then 
                    factionMembersButtonHover = 2

                    dxDrawRectangle(x + respc(488) + respc(150), y + respc(95) + respc(218), respc(130), respc(20), tocolor(255, 59, 59, alpha))
                    dxDrawText('Lefokozás', x + respc(488) + respc(150), y + respc(95) + respc(218), x + respc(488) + respc(150) + respc(130), y + respc(95) + respc(218) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
                else 
                    dxDrawRectangle(x + respc(488) + respc(150), y + respc(95) + respc(218), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                    dxDrawText('Lefokozás', x + respc(488) + respc(150), y + respc(95) + respc(218), x + respc(488) + respc(150) + respc(130), y + respc(95) + respc(218) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
                end 

                local buttonName, buttonColor = "Leader adása", {97, 177, 90}
                local data = cache["playerDatas"]["faction"][selectedFaction]["players"][factionMembersSelected]
                if factionMembersSearchCache and #factionMembersSearchCache >= 1 then 
                    data = factionMembersSearchCache[factionMembersSelected]
                end

                if datas["faction"][selectedFaction][3][data[1]][3] == 1 then 
                    buttonName, buttonColor = "Leader elvétele", {255, 59, 59}
                end 
                if isInSlot(x + respc(488) + respc(290), y + respc(95) + respc(218), respc(130), respc(20)) then 
                    factionMembersButtonHover = 3

                    local r,g,b = unpack(buttonColor)
                    dxDrawRectangle(x + respc(488) + respc(290), y + respc(95) + respc(218), respc(130), respc(20), tocolor(r, g, b, alpha))
                    dxDrawText(buttonName, x + respc(488) + respc(290), y + respc(95) + respc(218), x + respc(488) + respc(290) + respc(130), y + respc(95) + respc(218) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
                else 
                    dxDrawRectangle(x + respc(488) + respc(290), y + respc(95) + respc(218), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                    dxDrawText(buttonName, x + respc(488) + respc(290), y + respc(95) + respc(218), x + respc(488) + respc(290) + respc(130), y + respc(95) + respc(218) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
                end 

                if isInSlot(x + respc(488) + respc(15), y + respc(95) + respc(243), respc(130), respc(20)) then 
                    factionMembersButtonHover = 4

                    dxDrawRectangle(x + respc(488) + respc(15), y + respc(95) + respc(243), respc(130), respc(20), tocolor(255, 59, 59, alpha))
                    dxDrawText('Kirúgás', x + respc(488) + respc(15), y + respc(95) + respc(243), x + respc(488) + respc(15) + respc(130), y + respc(95) + respc(243) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
                else 
                    dxDrawRectangle(x + respc(488) + respc(15), y + respc(95) + respc(243), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                    dxDrawText('Kirúgás', x + respc(488) + respc(15), y + respc(95) + respc(243), x + respc(488) + respc(15) + respc(130), y + respc(95) + respc(243) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
                end 

                if isInSlot(x + respc(488) + respc(150), y + respc(95) + respc(243), respc(130), respc(20)) then 
                    factionMembersButtonHover = 5

                    dxDrawRectangle(x + respc(488) + respc(150), y + respc(95) + respc(243), respc(130), respc(20), tocolor(97, 177, 90, alpha))
                    dxDrawText('Új tag hozzáadása', x + respc(488) + respc(150), y + respc(95) + respc(243), x + respc(488) + respc(150) + respc(130), y + respc(95) + respc(243) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
                else 
                    dxDrawRectangle(x + respc(488) + respc(150), y + respc(95) + respc(243), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                    dxDrawText('Új tag hozzáadása', x + respc(488) + respc(150), y + respc(95) + respc(243), x + respc(488) + respc(150) + respc(130), y + respc(95) + respc(243) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
                end 

                if isInSlot(x + respc(488) + respc(290), y + respc(95) + respc(243), respc(130), respc(20)) then 
                    factionMembersButtonHover = 6

                    local r,g,b = exports['cr_core']:getServerColor('orange')
                    dxDrawRectangle(x + respc(488) + respc(290), y + respc(95) + respc(243), respc(130), respc(20), tocolor(r, g, b, alpha))
                    dxDrawText('Jogosultságok', x + respc(488) + respc(290), y + respc(95) + respc(243), x + respc(488) + respc(290) + respc(130), y + respc(95) + respc(243) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
                else 
                    dxDrawRectangle(x + respc(488) + respc(290), y + respc(95) + respc(243), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                    dxDrawText('Jogosultságok', x + respc(488) + respc(290), y + respc(95) + respc(243), x + respc(488) + respc(290) + respc(130), y + respc(95) + respc(243) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
                end 
            elseif factionsSelected == 3 then 
                --[[
                    Faction Ranks
                ]]
                local w3, h3 = respc(430), respc(430)
                dxDrawRectangle(x + respc(28), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
                dxDrawText('Frakció Rangok:', x + respc(28) + respc(15), y + respc(95) + respc(8), x + respc(28) + respc(15), y + respc(95) + respc(8) + respc(18) + respc(4), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'center')

                --[[Faction Ranks Search]]
                dxDrawRectangle(x + respc(28) + respc(140), y + respc(95) + respc(8), respc(280), respc(18), tocolor(51, 51, 51, alpha * 0.8))
                exports['cr_dx']:dxDrawImageAsTexture(x + respc(28) + respc(140) + respc(280) - respc(10) - respc(5), y + respc(95) + respc(8) + respc(18)/2 - respc(10)/2, respc(10), respc(10), ":cr_scoreboard/files/search.png", 0, 0, 0, tocolor(242, 242, 242, alpha)) 
                UpdatePos("FactionRanks >> search", {x + respc(28) + respc(140) + respc(5), y + respc(95) + respc(8) + respc(5), respc(280) - respc(10), respc(18) - respc(10) + respc(4)})

                --[[Faction Ranks List]]
                local ranks = datas["faction"][selectedFaction][4]

                local percent = #ranks

                if factionRanksSearchCache then
                    ranks = factionRanksSearchCache
                    percent = #factionRanksSearchCache
                end

                if factionRanksMaxLines > percent then
                    factionRanksMinLines = 1
                    factionRanksMaxLines = 16
                end

                local startX, startY = x + respc(28) + respc(10), y + respc(95) + respc(30)

                factionRanksScrollBarHover = isInSlot(startX, startY, respc(410), ((respc(20) + respc(5)) * 16) - respc(5))

                factionRanksHover = nil
                for i = factionRanksMinLines, factionRanksMaxLines do
                    local w4, h4 = respc(410), respc(20)

                    local inSlot = isInSlot(startX,startY,w4,h4)
                    local data = ranks[i]

                    if inSlot or data and factionRanksSelected == i then
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
                    else
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
                    end
                    
                    if data then
                        local rankName = data["name"]
                        local rankPayment = green .. "$ " .. data["payment"] 
                        
                        if inSlot or factionRanksSelected == i then
                            if inSlot then
                                factionRanksHover = i
                            end

                            dxDrawText(string.gsub(rankName, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(51, 51, 51,alpha), 1, font7, "left", "center", false, false, false, true)
                            dxDrawText(string.gsub(rankPayment, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(405),startY, startX + respc(405), startY + h4 + respc(4), tocolor(51,51,51,alpha), 1, font7, "right", "center")
                        else
                            dxDrawText(rankName, startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                            dxDrawText(rankPayment, startX + respc(405),startY, startX + respc(405), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "right", "center", false, false, false, true)
                        end
                    end
                    
                    startY = startY + h4 + respc(5)
                end

                --[[Faction Ranks Scrollbar]]
                local scrollx, scrolly = x + respc(28) + w3 - respc(3), y + respc(95) + respc(30)
                local scrollh = ((respc(20) + respc(5)) * 16) - respc(5)
                dxDrawRectangle(scrollx, scrolly, respc(3), scrollh, tocolor(242, 242, 242, alpha * 0.6))

                if percent >= 1 then
                    local gW, gH = respc(3), scrollh
                    local gX, gY = scrollx, scrolly

                    factionRanksScrollingHover = isInSlot(gX, gY, gW, gH)

                    if factionRanksScrolling then
                        if isCursorShowing() then
                            if getKeyState("mouse1") then
                                local cx, cy = exports['cr_core']:getCursorPosition()
                                local cy = math.min(math.max(cy, gY), gY + gH)
                                local y = (cy - gY) / (gH)
                                local num = percent * y
                                factionRanksMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 16) + 1)))
                                factionRanksMaxLines = factionRanksMinLines + (16 - 1)
                            end
                        else
                            factionRanksScrolling = false
                        end
                    end

                    local multiplier = math.min(math.max((factionRanksMaxLines - (factionRanksMinLines - 1)) / percent, 0), 1)
                    local multiplier2 = math.min(math.max((factionRanksMinLines - 1) / percent, 0), 1)
                    local gY = gY + ((gH) * multiplier2)
                    local gH = gH * multiplier

                    dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
                end

                --[[
                    Rank Informations
                ]]
                dxDrawRectangle(x + respc(488), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
                dxDrawRectangle(x + respc(488) + w3/2 - respc(380)/2, y + respc(95) + respc(110), respc(380), respc(2), tocolor(135, 135, 135, alpha * 0.6))

                dxDrawText('Rang Információk:', x + respc(488) + respc(15), y + respc(95) + respc(10), x + respc(488) + respc(15), y + respc(95) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'top')

                --[[Rank Informations List]]
                local startX, startY = x + respc(488) + respc(10), y + respc(95) + respc(30)

                for i = 1, 3 do 
                    local w4, h4 = respc(410), respc(20)

                    local inSlot = isInSlot(startX,startY,w4,h4)
                    if inSlot then
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
                    else
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
                    end
                    
                    if #factionRankInfos >= 1 then
                        if factionRankInfos[i] then
                            local v = factionRankInfos[i]
                            if inSlot then
                                dxDrawText(string.gsub(v, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(51, 51, 51,alpha), 1, font7, "left", "center", false, false, false, true)
                            else
                                dxDrawText(v, startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                            end
                        end
                    end
                    
                    startY = startY + h4 + respc(5)
                end

                --[[
                    Faction Rank Buttons
                ]]
                dxDrawRectangle(x + respc(488) + w3/2 - respc(380)/2, y + respc(95) + respc(360), respc(380), respc(2), tocolor(135, 135, 135, alpha * 0.6))

                factionRanksButtonHover = nil
                if isInSlot(x + respc(488) + respc(15), y + respc(95) + respc(375), respc(130), respc(20)) then 
                    factionRanksButtonHover = 6

                    dxDrawRectangle(x + respc(488) + respc(15), y + respc(95) + respc(375), respc(130), respc(20), tocolor(97, 177, 90, alpha))
                    dxDrawText('Sorrend fel', x + respc(488) + respc(15), y + respc(95) + respc(375), x + respc(488) + respc(15) + respc(130), y + respc(95) + respc(375) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
                else 
                    dxDrawRectangle(x + respc(488) + respc(15), y + respc(95) + respc(375), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                    dxDrawText('Sorrend fel', x + respc(488) + respc(15), y + respc(95) + respc(375), x + respc(488) + respc(15) + respc(130), y + respc(95) + respc(375) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
                end 

                if isInSlot(x + respc(488) + respc(150), y + respc(95) + respc(375), respc(130), respc(20)) then 
                    factionRanksButtonHover = 5

                    dxDrawRectangle(x + respc(488) + respc(150), y + respc(95) + respc(375), respc(130), respc(20), tocolor(255, 59, 59, alpha))
                    dxDrawText('Sorrend le', x + respc(488) + respc(150), y + respc(95) + respc(375), x + respc(488) + respc(150) + respc(130), y + respc(95) + respc(375) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
                else 
                    dxDrawRectangle(x + respc(488) + respc(150), y + respc(95) + respc(375), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                    dxDrawText('Sorrend le', x + respc(488) + respc(150), y + respc(95) + respc(375), x + respc(488) + respc(150) + respc(130), y + respc(95) + respc(375) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
                end 

                if isInSlot(x + respc(488) + respc(290), y + respc(95) + respc(375), respc(130), respc(20)) then 
                    factionRanksButtonHover = 1

                    local r,g,b = exports['cr_core']:getServerColor('yellow')
                    dxDrawRectangle(x + respc(488) + respc(290), y + respc(95) + respc(375), respc(130), respc(20), tocolor(r, g, b, alpha))
                    dxDrawText('Rang átnevezése', x + respc(488) + respc(290), y + respc(95) + respc(375), x + respc(488) + respc(290) + respc(130), y + respc(95) + respc(375) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
                else 
                    dxDrawRectangle(x + respc(488) + respc(290), y + respc(95) + respc(375), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                    dxDrawText('Rang átnevezése', x + respc(488) + respc(290), y + respc(95) + respc(375), x + respc(488) + respc(290) + respc(130), y + respc(95) + respc(375) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
                end 

                if isInSlot(x + respc(488) + respc(15), y + respc(95) + respc(400), respc(130), respc(20)) then 
                    factionRanksButtonHover = 2

                    dxDrawRectangle(x + respc(488) + respc(15), y + respc(95) + respc(400), respc(130), respc(20), tocolor(255, 59, 59, alpha))
                    dxDrawText('Rang törlése', x + respc(488) + respc(15), y + respc(95) + respc(400), x + respc(488) + respc(15) + respc(130), y + respc(95) + respc(400) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
                else 
                    dxDrawRectangle(x + respc(488) + respc(15), y + respc(95) + respc(400), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                    dxDrawText('Rang törlése', x + respc(488) + respc(15), y + respc(95) + respc(400), x + respc(488) + respc(15) + respc(130), y + respc(95) + respc(400) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
                end 

                if isInSlot(x + respc(488) + respc(150), y + respc(95) + respc(400), respc(130), respc(20)) then 
                    factionRanksButtonHover = 3

                    dxDrawRectangle(x + respc(488) + respc(150), y + respc(95) + respc(400), respc(130), respc(20), tocolor(97, 177, 90, alpha))
                    dxDrawText('Fizetés módosítása', x + respc(488) + respc(150), y + respc(95) + respc(400), x + respc(488) + respc(150) + respc(130), y + respc(95) + respc(400) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
                else 
                    dxDrawRectangle(x + respc(488) + respc(150), y + respc(95) + respc(400), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                    dxDrawText('Fizetés módosítása', x + respc(488) + respc(150), y + respc(95) + respc(400), x + respc(488) + respc(150) + respc(130), y + respc(95) + respc(400) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
                end 

                if isInSlot(x + respc(488) + respc(290), y + respc(95) + respc(400), respc(130), respc(20)) then 
                    factionRanksButtonHover = 4

                    local r,g,b = exports['cr_core']:getServerColor('orangeNew')
                    dxDrawRectangle(x + respc(488) + respc(290), y + respc(95) + respc(400), respc(130), respc(20), tocolor(r, g, b, alpha))
                    dxDrawText('Új rang létrehozása', x + respc(488) + respc(290), y + respc(95) + respc(400), x + respc(488) + respc(290) + respc(130), y + respc(95) + respc(400) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
                else 
                    dxDrawRectangle(x + respc(488) + respc(290), y + respc(95) + respc(400), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                    dxDrawText('Új rang létrehozása', x + respc(488) + respc(290), y + respc(95) + respc(400), x + respc(488) + respc(290) + respc(130), y + respc(95) + respc(400) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
                end 
            elseif factionsSelected == 4 then 
                --[[
                    Faction Vehicles
                ]]
                local w3, h3 = respc(430), respc(430)
                dxDrawRectangle(x + respc(28), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
                dxDrawText('Jármű típus', x + respc(28) + respc(15), y + respc(95) + respc(8), x + respc(28) + respc(15), y + respc(95) + respc(8) + respc(18) + respc(4), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'center')
                dxDrawText('Jármű ID', x + respc(28) + respc(245), y + respc(95) + respc(8), x + respc(28) + respc(245), y + respc(95) + respc(8) + respc(18) + respc(4), tocolor(242, 242, 242, alpha), 1, font5, 'center', 'center')
                dxDrawText('Állapot', x + respc(28) + respc(415), y + respc(95) + respc(8), x + respc(28) + respc(415), y + respc(95) + respc(8) + respc(18) + respc(4), tocolor(242, 242, 242, alpha), 1, font5, 'right', 'center')

                --[[Faction Vehicles List]]
                local startX, startY = x + respc(28) + respc(10), y + respc(95) + respc(30)

                FactionVehicleScrollBarHover = isInSlot(startX, startY, respc(410), ((respc(20) + respc(5)) * 16) - respc(5))

                FactionVehHover = nil
                for i = FactionVehicleMinLines, FactionVehicleMaxLines do
                    local w4, h4 = respc(410), respc(20)

                    local inSlot = isInSlot(startX,startY,w4,h4)

                    if inSlot or FactionVehicleSelected == i then
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
                    else
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
                    end
                    
                    local e = playerFactionVehicles[i]
                    if e then
                        local data = playerFactionVehiclesData[e]
                        if data then
                            if inSlot or FactionVehicleSelected == i then
                                if inSlot then
                                    FactionVehHover = i
                                end

                                dxDrawText(data["name"], startX + respc(5),startY, startX + respc(5), startY + h4 + respc(4), tocolor(51,51,51,alpha), 1, font7, "left", "center")
                                dxDrawText(data["id"], startX + respc(235),startY, startX + respc(235), startY + h4 + respc(4), tocolor(51,51,51,alpha), 1, font7, "center", "center")
                                dxDrawText(data["health"] .. "%", startX + respc(405),startY, startX + respc(405), startY + h4 + respc(4), tocolor(51,51,51,alpha), 1, font7, "right", "center")
                            else
                                dxDrawText(data["name"], startX + respc(5),startY, startX + respc(5), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center")
                                dxDrawText(data["id"], startX + respc(235),startY, startX + respc(235), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "center", "center")
                                dxDrawText(data["health"] .. "%", startX + respc(405),startY, startX + respc(405), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "right", "center")
                            end

                            if not data["locked"] then
                                exports['cr_dx']:dxDrawImageAsTexture(startX + respc(150), startY + h4/2 - respc(14)/2, respc(14), respc(14), ":cr_dashboard/assets/images/key.png", 0, 0, 0, tocolor(97, 177, 90, alpha))
                            else
                                exports['cr_dx']:dxDrawImageAsTexture(startX + respc(150), startY + h4/2 - respc(14)/2, respc(14), respc(14), ":cr_dashboard/assets/images/key.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
                            end
        
                            if isInSlot(startX + respc(150), startY + h4/2 - respc(14)/2, respc(14), respc(14)) then 
                                exports['cr_dx']:drawTooltip(1, '#F2F2F2' .. (data['locked'] and 'Zárva' or 'Nyitva'))
                            end 
                        end 
                    end
                    
                    startY = startY + h4 + respc(5)
                end

                --[[Faction Ranks Scrollbar]]
                local scrollx, scrolly = x + respc(28) + w3 - respc(3), y + respc(95) + respc(30)
                local scrollh = ((respc(20) + respc(5)) * 16) - respc(5)
                dxDrawRectangle(scrollx, scrolly, respc(3), scrollh, tocolor(242, 242, 242, alpha * 0.6))

                local percent = #playerFactionVehicles

                if percent >= 1 then
                    local gW, gH = respc(3), scrollh
                    local gX, gY = scrollx, scrolly

                    FactionVehicleScrollingHover = isInSlot(gX, gY, gW, gH)

                    if FactionVehicleScrolling then
                        if isCursorShowing() then
                            if getKeyState("mouse1") then
                                local cx, cy = exports['cr_core']:getCursorPosition()
                                local cy = math.min(math.max(cy, gY), gY + gH)
                                local y = (cy - gY) / (gH)
                                local num = percent * y
                                FactionVehicleMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 16) + 1)))
                                FactionVehicleMaxLines = FactionVehicleMinLines + (16 - 1)
                            end
                        else
                            FactionVehicleScrolling = false
                        end
                    end

                    local multiplier = math.min(math.max((FactionVehicleMaxLines - (FactionVehicleMinLines - 1)) / percent, 0), 1)
                    local multiplier2 = math.min(math.max((FactionVehicleMinLines - 1) / percent, 0), 1)
                    local gY = gY + ((gH) * multiplier2)
                    local gH = gH * multiplier

                    dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
                end

                --[[
                    Vehicle Informations
                ]]
                dxDrawRectangle(x + respc(488), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
                dxDrawText('Jármű Információk:', x + respc(488) + respc(15), y + respc(95) + respc(10), x + respc(488) + respc(15), y + respc(95) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'top')

                --[[Vehicle Informations List]]
                local startX, startY = x + respc(488) + respc(10), y + respc(95) + respc(30)

                FactionVehicleInfoScrollBarHover = isInSlot(startX, startY, respc(410), ((respc(20) + respc(5)) * 16) - respc(5))

                for i = FactionVehicleInfoMinLines, FactionVehicleInfoMaxLines do
                    local w4, h4 = respc(410), respc(20)

                    local inSlot = isInSlot(startX,startY,w4,h4)
                    if inSlot then
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
                    else
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
                    end
                    
                    if #playerFactionVehicleInfos >= 1 then
                        if playerFactionVehicleInfos[i] then
                            local v = playerFactionVehicleInfos[i]
                            if inSlot then    
                                dxDrawText(string.gsub(v, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(51, 51, 51,alpha), 1, font7, "left", "center", false, false, false, true)
                            else
                                dxDrawText(v, startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                            end
                        end
                    end
                    
                    startY = startY + h4 + respc(5)
                end

                --[[Faction Informations Scrollbar]]
                local scrollx, scrolly = x + respc(488) + w3 - respc(3), y + respc(95) + respc(30)
                local scrollh = ((respc(20) + respc(5)) * 16) - respc(5)
                dxDrawRectangle(scrollx, scrolly, respc(3), scrollh, tocolor(242, 242, 242, alpha * 0.6))

                local percent = #playerFactionVehicleInfos

                if percent >= 1 then
                    local gW, gH = respc(3), scrollh
                    local gX, gY = scrollx, scrolly

                    FactionVehicleInfoScrollingHover = isInSlot(gX, gY, gW, gH)

                    if FactionVehicleInfoScrolling then
                        if isCursorShowing() then
                            if getKeyState("mouse1") then
                                local cx, cy = exports['cr_core']:getCursorPosition()
                                local cy = math.min(math.max(cy, gY), gY + gH)
                                local y = (cy - gY) / (gH)
                                local num = percent * y
                                FactionVehicleInfoMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 16) + 1)))
                                FactionVehicleInfoMaxLines = FactionVehicleInfoMinLines + (16 - 1)
                            end
                        else
                            FactionVehicleInfoScrolling = false
                        end
                    end

                    local multiplier = math.min(math.max((FactionVehicleInfoMaxLines - (FactionVehicleInfoMinLines - 1)) / percent, 0), 1)
                    local multiplier2 = math.min(math.max((FactionVehicleInfoMinLines - 1) / percent, 0), 1)
                    local gY = gY + ((gH) * multiplier2)
                    local gH = gH * multiplier

                    dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
                end
            elseif factionsSelected == 5 then 
                --[[
                    Faction Logs
                ]]
                local w3, h3 = respc(890), respc(430)
                dxDrawRectangle(x + respc(28), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
                dxDrawText('Frakció Logok:', x + respc(28) + respc(15), y + respc(95) + respc(8), x + respc(28) + respc(15), y + respc(95) + respc(8) + respc(18) + respc(4), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'center')

                local logs = datas["faction"][selectedFaction][8]

                --[[Faction Logs List]]
                local startX, startY = x + respc(28) + respc(10), y + respc(95) + respc(30)

                FactionLogsScrollBarHover = isInSlot(startX, startY, respc(410), ((respc(20) + respc(5)) * 16) - respc(5))

                for i = FactionLogsMinLines, FactionLogsMaxLines do
                    local w4, h4 = respc(870), respc(20)

                    local inSlot = isInSlot(startX,startY,w4,h4)
                    if inSlot then
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
                    else
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
                    end
                    
                    if #logs >= 1 then
                        if logs[i] then
                            local v = logs[i]
                            if inSlot then    
                                dxDrawText(string.gsub(v, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(51, 51, 51,alpha), 1, font7, "left", "center", false, false, false, true)
                            else
                                dxDrawText(v, startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                            end
                        end
                    end
                    
                    startY = startY + h4 + respc(5)
                end

                --[[Faction Logs Scrollbar]]
                local scrollx, scrolly = x + respc(28) + w3 - respc(3), y + respc(95) + respc(30)
                local scrollh = ((respc(20) + respc(5)) * 16) - respc(5)
                dxDrawRectangle(scrollx, scrolly, respc(3), scrollh, tocolor(242, 242, 242, alpha * 0.6))

                local percent = #logs

                if percent >= 1 then
                    local gW, gH = respc(3), scrollh
                    local gX, gY = scrollx, scrolly

                    FactionLogsScrollingHover = isInSlot(gX, gY, gW, gH)

                    if FactionLogsScrolling then
                        if isCursorShowing() then
                            if getKeyState("mouse1") then
                                local cx, cy = exports['cr_core']:getCursorPosition()
                                local cy = math.min(math.max(cy, gY), gY + gH)
                                local y = (cy - gY) / (gH)
                                local num = percent * y
                                FactionLogsMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 16) + 1)))
                                FactionLogsMaxLines = FactionLogsMinLines + (16 - 1)
                            end
                        else
                            FactionLogsScrolling = false
                        end
                    end

                    local multiplier = math.min(math.max((FactionLogsMaxLines - (FactionLogsMinLines - 1)) / percent, 0), 1)
                    local multiplier2 = math.min(math.max((FactionLogsMinLines - 1) / percent, 0), 1)
                    local gY = gY + ((gH) * multiplier2)
                    local gH = gH * multiplier

                    dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
                end
            end 
        end 
    elseif cache['page'] == 4 then 
        local x = x + w2

        --[[
            Header
        ]]
        dxDrawText('Adminok', x + respc(20), y + respc(24), x + respc(20), y + respc(24) + respc(35) + respc(5), tocolor(242, 242, 242, alpha), 1, font2, "left", "center")
        dxDrawImage(x + respc(741), y + respc(24), respc(35), respc(35), ":cr_interface/hud/files/avatars/"..datas["avatar"]..".png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText(datas['charName'], x + respc(741) + respc(35) + respc(20), y + respc(24) - respc(5), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(35), tocolor(242, 242, 242, alpha), 1, font3, "left", "top")
        dxDrawText('Szint: ' .. yellow .. datas['lvl'] .. "#F2F2F2 - ".. datas['adminColor'] .. datas['adminTitle'], x + respc(741) + respc(35) + respc(20), y + respc(24), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(5) + respc(35), tocolor(242, 242, 242, alpha), 1, font4, "left", "bottom", false, false, false, true)

        --[[
            Menu
        ]]
        local startX, startY = x + respc(20), y + respc(95)

        aHover = nil

        for i = 1, #adminLevels do
            local w4, h4 = respc(150), respc(22)

            local name = adminLevels[i]
            if name then
                if isInSlot(startX, startY, w4, h4) or adminSelectedMenu == i then
                    if adminSelectedMenu ~= i then
                        aHover = i
                    end

                    dxDrawRectangle(startX, startY, w4, h4, tocolor(255, 59, 59, alpha))
                    dxDrawText(name, startX, startY, startX + w4, startY + h4 + respc(4), tocolor(242,242,242, alpha), 1, font10, "center", "center")
                else
                    dxDrawRectangle(startX, startY, w4, h4, tocolor(23, 23, 23, alpha * 0.9))
                    dxDrawText(name, startX, startY, startX + w4, startY + h4 + respc(4), tocolor(242,242,242, alpha * 0.6), 1, font10, "center", "center")
                end
                
                startY = startY + h4 + respc(5)
            end
        end

        --[[
            Search
        ]]
        dxDrawRectangle(x + respc(20), y + respc(315), respc(150), respc(18), tocolor(51, 51, 51, alpha * 0.8))
        exports['cr_dx']:dxDrawImageAsTexture(x + respc(20) + respc(150) - respc(10) - respc(5), y + respc(315) + respc(18)/2 - respc(10)/2, respc(10), respc(10), ":cr_scoreboard/files/search.png", 0, 0, 0, tocolor(242, 242, 242, alpha)) 
        UpdatePos("Admin >> search", {x + respc(20) + respc(5), y + respc(315), respc(150) - respc(10), respc(18) + respc(4)})

        --[[Search Button]]
        searchHover = nil
        if isInSlot(x + respc(20), y + respc(340), respc(150), respc(22)) then
            searchHover = true

            dxDrawRectangle(x + respc(20), y + respc(340), respc(150), respc(22), tocolor(255, 59, 59, alpha))
            dxDrawText('Keresés', x + respc(20), y + respc(340), x + respc(20) + respc(150), y + respc(340) + respc(22) + respc(4), tocolor(242,242,242, alpha), 1, font10, "center", "center")
        else
            dxDrawRectangle(x + respc(20), y + respc(340), respc(150), respc(22), tocolor(23, 23, 23, alpha * 0.9))
            dxDrawText('Keresés', x + respc(20), y + respc(340), x + respc(20) + respc(150), y + respc(340) + respc(22) + respc(4), tocolor(242,242,242, alpha * 0.6), 1, font10, "center", "center")
        end

        --[[
            Admin List
        ]]
        dxDrawRectangle(x + respc(190), y + respc(95), respc(740), respc(430), tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText('ID', x + respc(190) + respc(17.5), y + respc(95) + respc(8), x + respc(190) + respc(17.5), y + respc(95) + respc(8) + respc(18) + respc(4), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'center')
        dxDrawText('Név', x + respc(190) + respc(17.5), y + respc(95) + respc(8), x + respc(190) + respc(720), y + respc(95) + respc(8) + respc(18) + respc(4), tocolor(242, 242, 242, alpha), 1, font5, 'center', 'center')
        dxDrawText('Státusz', x + respc(190) + respc(720), y + respc(95) + respc(8), x + respc(190) + respc(720), y + respc(95) + respc(8) + respc(18) + respc(4), tocolor(242, 242, 242, alpha), 1, font5, 'right', 'center')

        --[[Admin List:]]
        local startX, startY = x + respc(190) + respc(10), y + respc(95) + respc(30)

        AdminScrollBarHover = isInSlot(startX, startY, respc(410), ((respc(20) + respc(5)) * 16) - respc(5))

        local percent = #adminCacheKey
        if adminSearchCache then
            percent = #adminSearchCache
        end
        if AdminMaxLines > percent then
            AdminMinLines = 1
            AdminMaxLines = 16
        end

        for i = AdminMinLines, AdminMaxLines do
            local w4, h4 = respc(720), respc(20)

            local inSlot = isInSlot(startX,startY,w4,h4)

            if inSlot then
                dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
            else
                dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
            end
            
            local e = adminCacheKey[i]
            if adminSearchCache then
                e = adminSearchCache[i]
            end

            if e then
                local data = adminCache[e]
                if data then
                    local id = data["id"]
                    local duty = data["duty"]
                    local nick = data["nick"]
                    local dutyText = red .. "Nincs szolgálatban"
                    local dutyText2 = "Nincs szolgálatban"
                    if duty then
                        dutyText = green .. "Szolgálatban"
                        dutyText2 = "Szolgálatban"
                    end

                    if inSlot then 
                        dxDrawText(id, startX + respc(10),startY, startX + respc(10), startY + h4 + respc(4), tocolor(51,51,51,alpha), 1, font7, "left", "center")
                        dxDrawText(nick, startX + respc(10),startY, startX + respc(710), startY + h4 + respc(4), tocolor(51,51,51,alpha), 1, font7, "center", "center")
                        dxDrawText(dutyText2, startX + respc(710),startY, startX + respc(710), startY + h4 + respc(4), tocolor(51,51,51,alpha), 1, font7, "right", "center")
                    else
                        dxDrawText(id, startX + respc(10),startY, startX + respc(10), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center")
                        dxDrawText(nick, startX + respc(10),startY, startX + respc(710), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "center", "center")
                        dxDrawText(dutyText, startX + respc(710),startY, startX + respc(710), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "right", "center", false, false, false, true)
                    end
                end 
            end
            
            startY = startY + h4 + respc(5)
        end
    elseif cache['page'] == 5 then 
        local x = x + w2

        if not datas["group"] or #datas["group"] == 0 then
            --Jelenleg nem vagy csoportban

            local startY = y + h/2 - ((respc(101) + respc(30) + respc(10) + respc(22))/2)
            exports['cr_dx']:dxDrawImageAsTexture(x + (w - w2)/2 - respc(107)/2, startY, respc(107), respc(101), ":cr_dashboard/assets/images/warning.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.7))

            startY = startY + respc(101) + respc(10)

            dxDrawText('Jelenleg nem vagy csoportban!', x, startY, x + (w - w2), startY, tocolor(255, 59, 59, alpha), 1, font, "center", "top")

            startY = startY + respc(20) + respc(10)

            local buttonW, buttonH = respc(200), respc(22)

            bHover = nil
            if isInSlot(x + (w - w2)/2 - buttonW/2, startY, buttonW, buttonH) then 
                bHover = "create"
                dxDrawRectangle(x + (w - w2)/2 - buttonW/2, startY, buttonW, buttonH, tocolor(97, 177, 90, alpha)) 
                dxDrawText('Új csoport létrehozása', x, startY, x + (w - w2), startY + buttonH + respc(4), tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
            else
                dxDrawRectangle(x + (w - w2)/2 - buttonW/2, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                dxDrawText('Új csoport létrehozása', x, startY, x + (w - w2), startY + buttonH + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
            end 
        else 
            --[[
                Header
            ]]
            dxDrawText('Csoport', x + respc(20), y + respc(24), x + respc(20), y + respc(24) + respc(35) + respc(5), tocolor(242, 242, 242, alpha), 1, font2, "left", "center")
            dxDrawImage(x + respc(741), y + respc(24), respc(35), respc(35), ":cr_interface/hud/files/avatars/"..datas["avatar"]..".png", 0, 0, 0, tocolor(255, 255, 255, alpha))

            dxDrawText(datas['charName'], x + respc(741) + respc(35) + respc(20), y + respc(24) - respc(5), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(35), tocolor(242, 242, 242, alpha), 1, font3, "left", "top")
            dxDrawText('Szint: ' .. yellow .. datas['lvl'] .. "#F2F2F2 - ".. datas['adminColor'] .. datas['adminTitle'], x + respc(741) + respc(35) + respc(20), y + respc(24), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(5) + respc(35), tocolor(242, 242, 242, alpha), 1, font4, "left", "bottom", false, false, false, true)

            --[[
                Group Members
            ]]
            local w3, h3 = respc(430), respc(430)
            dxDrawRectangle(x + respc(28), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
            dxDrawText('Csoport Tagok:', x + respc(28) + respc(15), y + respc(95) + respc(8), x + respc(28) + respc(15), y + respc(95) + respc(8) + respc(18) + respc(4), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'center')

            --[[Group Members Search]]
            dxDrawRectangle(x + respc(28) + respc(140), y + respc(95) + respc(8), respc(280), respc(18), tocolor(51, 51, 51, alpha * 0.8))
            exports['cr_dx']:dxDrawImageAsTexture(x + respc(28) + respc(140) + respc(280) - respc(10) - respc(5), y + respc(95) + respc(8) + respc(18)/2 - respc(10)/2, respc(10), respc(10), ":cr_scoreboard/files/search.png", 0, 0, 0, tocolor(242, 242, 242, alpha)) 
            UpdatePos("Group >> search", {x + respc(28) + respc(140) + respc(5), y + respc(95) + respc(8) + respc(5), respc(280) - respc(10), respc(18) - respc(10) + respc(4)})

            --[[Group Members List]]
            local players = datas["group"][selectedGroup]["data"][3] or {}

            local percent = #players 

            if groupSearchCache then
                players = groupSearchCache
                percent = #groupSearchCache
            end

            if GroupMaxLines > percent then
                GroupMinLines = 1
                GroupMaxLines = 16
            end

            local startX, startY = x + respc(28) + respc(10), y + respc(95) + respc(30)

            GroupScrollBarHover = isInSlot(startX, startY, respc(410), ((respc(20) + respc(5)) * 16) - respc(5))

            groupHover = nil
            for i = GroupMinLines, GroupMaxLines do
                local w4, h4 = respc(410), respc(20)

                local inSlot = isInSlot(startX,startY,w4,h4)
                local data = players[i]

                if inSlot or data and groupSelected == i then
                    dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
                else
                    dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
                end
                
                if data then
                    local id = data[1]
                    local nick = data[2]:gsub("_", " ")
                    local leader = data[3]
                    
                    if inSlot or groupSelected == i then
                        if inSlot then
                            groupHover = i
                        end

                        dxDrawText(string.gsub(id, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(51, 51, 51,alpha), 1, font7, "left", "center", false, false, false, true)
                        dxDrawText(string.gsub(nick, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY, startX + respc(405), startY + h4 + respc(4), tocolor(51,51,51,alpha), 1, font7, "center", "center")
                    else
                        dxDrawText(id, startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                        dxDrawText(nick, startX + respc(5),startY, startX + respc(405), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "center", "center", false, false, false, true)
                    end
                    
                    if tonumber(leader or 0) == 1 then 
                        exports['cr_dx']:dxDrawImageAsTexture(startX + respc(405) - respc(14), startY + h4/2 - respc(11)/2, respc(14), respc(11), ":cr_dashboard/assets/images/leader.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
                    end 
                end
                
                startY = startY + h4 + respc(5)
            end

            --[[
                Group Member Informations
            ]]
            dxDrawRectangle(x + respc(488), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
            dxDrawRectangle(x + respc(488) + w3/2 - respc(380)/2, y + respc(95) + respc(135), respc(380), respc(2), tocolor(135, 135, 135, alpha * 0.6))

            dxDrawText('Tag Információk:', x + respc(488) + respc(15), y + respc(95) + respc(10), x + respc(488) + respc(15), y + respc(95) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'top')

            --[[Group Member List]]
            local startX, startY = x + respc(488) + respc(10), y + respc(95) + respc(30)

            for i = 1, 4 do 
                local w4, h4 = respc(410), respc(20)

                local inSlot = isInSlot(startX,startY,w4,h4)
                if inSlot then
                    dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
                else
                    dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
                end
                
                if #playerGroupInfos >= 1 then
                    if playerGroupInfos[i] then
                        local v = playerGroupInfos[i]
                        if inSlot then
                            dxDrawText(string.gsub(v, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(51, 51, 51,alpha), 1, font7, "left", "center", false, false, false, true)
                        else
                            dxDrawText(v, startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                        end
                    end
                end
                
                startY = startY + h4 + respc(5)
            end

            --[[
                Group Member Buttons
            ]]
            dxDrawRectangle(x + respc(488) + w3/2 - respc(380)/2, y + respc(95) + respc(360), respc(380), respc(2), tocolor(135, 135, 135, alpha * 0.6))

            groupButtonHover = nil
            if isInSlot(x + respc(488) + respc(15), y + respc(95) + respc(375), respc(130), respc(20)) then 
                groupButtonHover = 1

                dxDrawRectangle(x + respc(488) + respc(15), y + respc(95) + respc(375), respc(130), respc(20), tocolor(97, 177, 90, alpha))
                dxDrawText('Csoport átnevezése', x + respc(488) + respc(15), y + respc(95) + respc(375), x + respc(488) + respc(15) + respc(130), y + respc(95) + respc(375) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
            else 
                dxDrawRectangle(x + respc(488) + respc(15), y + respc(95) + respc(375), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                dxDrawText('Csoport átnevezése', x + respc(488) + respc(15), y + respc(95) + respc(375), x + respc(488) + respc(15) + respc(130), y + respc(95) + respc(375) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
            end 

            if isInSlot(x + respc(488) + respc(150), y + respc(95) + respc(375), respc(130), respc(20)) then 
                groupButtonHover = 2

                dxDrawRectangle(x + respc(488) + respc(150), y + respc(95) + respc(375), respc(130), respc(20), tocolor(255, 59, 59, alpha))
                dxDrawText('Csoport törlése', x + respc(488) + respc(150), y + respc(95) + respc(375), x + respc(488) + respc(150) + respc(130), y + respc(95) + respc(375) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
            else 
                dxDrawRectangle(x + respc(488) + respc(150), y + respc(95) + respc(375), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                dxDrawText('Csoport törlése', x + respc(488) + respc(150), y + respc(95) + respc(375), x + respc(488) + respc(150) + respc(130), y + respc(95) + respc(375) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
            end 

            if isInSlot(x + respc(488) + respc(290), y + respc(95) + respc(375), respc(130), respc(20)) then 
                groupButtonHover = 3

                local r,g,b = exports['cr_core']:getServerColor('yellow')
                dxDrawRectangle(x + respc(488) + respc(290), y + respc(95) + respc(375), respc(130), respc(20), tocolor(r, g, b, alpha))
                dxDrawText('Játékos meghívása', x + respc(488) + respc(290), y + respc(95) + respc(375), x + respc(488) + respc(290) + respc(130), y + respc(95) + respc(375) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
            else 
                dxDrawRectangle(x + respc(488) + respc(290), y + respc(95) + respc(375), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                dxDrawText('Játékos meghívása', x + respc(488) + respc(290), y + respc(95) + respc(375), x + respc(488) + respc(290) + respc(130), y + respc(95) + respc(375) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
            end 

            if isInSlot(x + respc(488) + respc(15), y + respc(95) + respc(400), respc(130), respc(20)) then 
                groupButtonHover = 4

                dxDrawRectangle(x + respc(488) + respc(15), y + respc(95) + respc(400), respc(130), respc(20), tocolor(255, 59, 59, alpha))
                dxDrawText('Játékos kirúgása', x + respc(488) + respc(15), y + respc(95) + respc(400), x + respc(488) + respc(15) + respc(130), y + respc(95) + respc(400) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
            else 
                dxDrawRectangle(x + respc(488) + respc(15), y + respc(95) + respc(400), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                dxDrawText('Játékos kirúgása', x + respc(488) + respc(15), y + respc(95) + respc(400), x + respc(488) + respc(15) + respc(130), y + respc(95) + respc(400) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
            end 

            if isInSlot(x + respc(488) + respc(150), y + respc(95) + respc(400), respc(130), respc(20)) then 
                groupButtonHover = 5

                dxDrawRectangle(x + respc(488) + respc(150), y + respc(95) + respc(400), respc(130), respc(20), tocolor(97, 177, 90, alpha))
                dxDrawText('Vezető kinevezése', x + respc(488) + respc(150), y + respc(95) + respc(400), x + respc(488) + respc(150) + respc(130), y + respc(95) + respc(400) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
            else 
                dxDrawRectangle(x + respc(488) + respc(150), y + respc(95) + respc(400), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                dxDrawText('Vezető kinevezése', x + respc(488) + respc(150), y + respc(95) + respc(400), x + respc(488) + respc(150) + respc(130), y + respc(95) + respc(400) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
            end 

            if isInSlot(x + respc(488) + respc(290), y + respc(95) + respc(400), respc(130), respc(20)) then 
                groupButtonHover = 6

                dxDrawRectangle(x + respc(488) + respc(290), y + respc(95) + respc(400), respc(130), respc(20), tocolor(255, 59, 59, alpha))
                dxDrawText('Kilépés', x + respc(488) + respc(290), y + respc(95) + respc(400), x + respc(488) + respc(290) + respc(130), y + respc(95) + respc(400) + respc(20) + respc(4), tocolor(242, 242, 242, alpha), 1, font8, "center", "center")
            else 
                dxDrawRectangle(x + respc(488) + respc(290), y + respc(95) + respc(400), respc(130), respc(20), tocolor(23, 23, 23, alpha * 0.9))
                dxDrawText('Kilépés', x + respc(488) + respc(290), y + respc(95) + respc(400), x + respc(488) + respc(290) + respc(130), y + respc(95) + respc(400) + respc(20) + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font8, "center", "center")
            end 
        end 
    elseif cache['page'] == 6 then 
        local x = x + w2

        --[[
            Header
        ]]
        dxDrawText('Támogatás', x + respc(20), y + respc(24), x + respc(20), y + respc(24) + respc(35) + respc(5), tocolor(242, 242, 242, alpha), 1, font2, "left", "center")
        dxDrawImage(x + respc(741), y + respc(24), respc(35), respc(35), ":cr_interface/hud/files/avatars/"..datas["avatar"]..".png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText(datas['charName'], x + respc(741) + respc(35) + respc(20), y + respc(24) - respc(5), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(35), tocolor(242, 242, 242, alpha), 1, font3, "left", "top")
        dxDrawText('Szint: ' .. yellow .. datas['lvl'] .. "#F2F2F2 - ".. datas['adminColor'] .. datas['adminTitle'], x + respc(741) + respc(35) + respc(20), y + respc(24), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(5) + respc(35), tocolor(242, 242, 242, alpha), 1, font4, "left", "bottom", false, false, false, true)

        --[[
            Donation Informations
        ]]
        local w3, h3 = respc(890), respc(208)
        dxDrawRectangle(x + respc(28), y + respc(85), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText('Támogatási információk:', x + respc(28) + respc(15), y + respc(85) + respc(10), x + respc(28) + respc(15), y + respc(85) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'top')

        --[[
            Premium Code Button
        ]]
        local startY = y + respc(85) + respc(5)

        local buttonW, buttonH = respc(163), respc(22)

        buyHover = nil
        if isInSlot(x + respc(28) + w3 - buttonW - respc(5), startY, buttonW, buttonH) then 
            buyHover = "PPCode"
            dxDrawRectangle(x + respc(28) + w3 - buttonW - respc(5), startY, buttonW, buttonH, tocolor(97, 177, 90, alpha)) 
            dxDrawText('Prémium kód beváltása', x + respc(28) + w3 - buttonW - respc(5), startY, x + respc(28) + w3 - respc(5), startY + buttonH + respc(4), tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
        else
            dxDrawRectangle(x + respc(28) + w3 - buttonW - respc(5), startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
            dxDrawText('Prémium kód beváltása', x + respc(28) + w3 - buttonW - respc(5), startY, x + respc(28) + w3 - respc(5), startY + buttonH + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
        end 

        --[[
            Premium Packages
        ]]

        local startX, startY = x + respc(28) + respc(625), y + respc(85) + respc(40)
        for i = 1, #PremiumInfoData do
            local w4, h4 = respc(215), respc(155)
            
            local data = PremiumInfoData[(4 - i) + 1]
            if data then
                local name = data["name"]
                local r,g,b, hex = unpack(data["color"])
                local text = data["text"]

                exports['cr_dx']:dxDrawImageAsTexture(startX, startY, w4, h4, ":cr_dashboard/assets/images/donate-bg.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

                dxDrawText(name, startX + respc(15), startY + respc(15), startX + respc(15), startY + respc(15), tocolor(r,g,b,alpha), 1, font3, "left", "top")

                dxDrawText(text, startX + respc(15), startY + respc(40), startX + respc(15), startY + respc(40), tocolor(242,242,242,alpha), 1, font5, "left", "top", false, false, false, true)
            end
            
            startX = startX - w4 + respc(20)
        end

        --[[
            Premium Type Menu
        ]]
        local startX = x + respc(55)

        --[[Premium Left Arrow]]
        arrowHover = nil
        if isInSlot(startX - respc(16) - respc(5), y + respc(290) + respc(40)/2 - respc(12)/2, respc(16), respc(12)) then 
            arrowHover = "left"

            exports['cr_dx']:dxDrawImageAsTexture(startX - respc(16) - respc(5), y + respc(290) + respc(40)/2 - respc(12)/2, respc(16), respc(12), ":cr_carshop/files/imgs/leftArrow.png", 0, 0, 0, tocolor(242, 242, 242, alpha))
        else 
            exports['cr_dx']:dxDrawImageAsTexture(startX - respc(16) - respc(5), y + respc(290) + respc(40)/2 - respc(12)/2, respc(16), respc(12), ":cr_carshop/files/imgs/leftArrow.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
        end 
        --[[/Premium Left Arrow]]

        premiumHover = nil
        for i = PremiumMinLines, PremiumMaxLines do
            local data = PremiumData[i]
            if data then
                local v = data['name']

                local textWidth = dxGetTextWidth(v, 1, font9) + respc(10)
                local inSlot = isInSlot(startX, y + respc(290), textWidth, respc(40))

                local gradientHeight = respc(10)

                local textAlpha = alpha
                local lineAlpha = alpha

                if premiumButtonAnimation[i] then 
                    local startTick, type = unpack(premiumButtonAnimation[i])
                    local progress = (nowTick - startTick) / 250

                    if progress > 1 then 
                        premiumButtonAnimation[i] = nil
                    end 

                    gradientHeight, textAlpha, lineAlpha = interpolateBetween(
                        type == 1 and 0 or gradientHeight, type == 1 and alpha * 0.6 or textAlpha, type == 1 and 0 or lineAlpha,
                        type == 1 and gradientHeight or 0, type == 1 and textAlpha or alpha * 0.6, type == 1 and lineAlpha or 0,
                        progress, "InOutQuad"
                    )
                end

                dxDrawRectangle(startX, y + respc(318.5), textWidth, 2, tocolor(51, 51, 51, alpha * 0.3))
                if premiumSelected == i or premiumButtonAnimation[i] then 
                    exports['cr_dx']:dxDrawImageAsTexture(startX, y + respc(318.5) - gradientHeight, textWidth, gradientHeight, ':cr_bank/assets/images/gradient.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.6))

                    dxDrawRectangle(startX, y + respc(318.5), textWidth, 2, tocolor(255, 59, 59, lineAlpha))
                end 

                if inSlot or premiumSelected == i or premiumButtonAnimation[i] then 
                    if inSlot and premiumSelected ~= i then
                        premiumHover = i
                    end

                    dxDrawText(v, startX, y + respc(290), startX + textWidth, y + respc(290) + respc(35) + respc(5), tocolor(242, 242, 242, textAlpha), 1, font9, "center", "center")
                else 
                    dxDrawText(v, startX, y + respc(290), startX + textWidth, y + respc(290) + respc(35) + respc(5), tocolor(242, 242, 242, alpha * 0.6), 1, font9, "center", "center")
                end 

                startX = startX + textWidth
            end 
        end

        --[[Premium Right Arrow]]
        if isInSlot(startX + respc(5), y + respc(290) + respc(40)/2 - respc(12)/2, respc(16), respc(12)) then 
            arrowHover = "right"

            exports['cr_dx']:dxDrawImageAsTexture(startX + respc(5), y + respc(290) + respc(40)/2 - respc(12)/2, respc(16), respc(12), ":cr_carshop/files/imgs/leftArrow.png", 180, 0, 0, tocolor(242, 242, 242, alpha))
        else 
            exports['cr_dx']:dxDrawImageAsTexture(startX + respc(5), y + respc(290) + respc(40)/2 - respc(12)/2, respc(16), respc(12), ":cr_carshop/files/imgs/leftArrow.png", 180, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
        end 
        --[[/Premium Right Arrow]]

        --[[
            Premium Items
        ]]
        local w3, h3 = respc(890), respc(212)
        local descText = premiumSelected == 6 and "Érték" or "Leírás"

        dxDrawRectangle(x + respc(28), y + respc(325), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText('Item', x + respc(28) + respc(35), y + respc(325) + respc(10), x + respc(28) + respc(35), y + respc(325) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'center', 'top')
        dxDrawText('Item név', x + respc(28) + respc(165), y + respc(325) + respc(10), x + respc(28) + respc(165), y + respc(325) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'center', 'top')
        dxDrawText(descText, x + respc(28) + respc(380), y + respc(325) + respc(10), x + respc(28) + respc(380), y + respc(325) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'center', 'top')
        dxDrawText('Ár', x + respc(28) + respc(600), y + respc(325) + respc(10), x + respc(28) + respc(600), y + respc(325) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'center', 'top')

        --[[Premium Items List]]
        local startX, startY = x + respc(28) + respc(10), y + respc(325) + respc(30)

        PremiumBuyHover = isInSlot(startX, startY, respc(860), ((respc(40) + respc(5)) * 4) - respc(5))

        for i = PremiumBuyMinLines, PremiumBuyMaxLines do
            local w4, h4 = respc(860), respc(40)

            local inSlot = isInSlot(startX,startY,w4,h4)
            if inSlot then
                dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
            else
                dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
            end
            
            local data = PremiumData[premiumSelected]["items"][i] 
            if data then
                local id, val, nbt, price = unpack(data)
                local tex = exports['cr_inventory']:getItemPNG(id, val, nbt)
                local desc = exports['cr_inventory']:getItemDescription(id, val, nbt)
                local descValue = premiumSelected == 6 and "$" .. val or desc
                local price = yellow .. tonumber(price) .. ' PP'

                if inSlot then    
                    dxDrawText(string.gsub(exports['cr_inventory']:getItemName(id, val, nbt), "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(155),startY,startX + respc(155), startY + h4 + respc(4), tocolor(51, 51, 51, alpha), 1, font7, "center", "center", false, false, false, true)
                    dxDrawText(string.gsub(descValue, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(370),startY,startX + respc(370), startY + h4 + respc(4), tocolor(51, 51, 51, alpha), 1, font7, "center", "center", false, false, false, true)
                    dxDrawText(string.gsub(price, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(590),startY,startX + respc(590), startY + h4 + respc(4), tocolor(51, 51, 51, alpha), 1, font7, "center", "center", false, false, false, true)
                else
                    dxDrawText(exports['cr_inventory']:getItemName(id, val, nbt), startX + respc(155),startY,startX + respc(155), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "center", "center", false, false, false, true)
                    dxDrawText(descValue, startX + respc(370),startY,startX + respc(370), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "center", "center", false, false, false, true)
                    dxDrawText(price, startX + respc(590),startY,startX + respc(590), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "center", "center", false, false, false, true)
                end

                dxDrawRectangle(startX + respc(10), startY + h4/2 - respc(30)/2, respc(30), respc(30), tocolor(23, 23, 23, alpha * 0.8))
                dxDrawImage(startX + respc(10) + respc(1), startY + h4/2 - respc(30)/2 + respc(1), respc(30) - respc(2), respc(30) - respc(2), tex, 0, 0, 0, tocolor(255, 255, 255, alpha))

                if isInSlot(startX + respc(10), startY + h4/2 - respc(30)/2, respc(30), respc(30)) then 
                    exports['cr_dx']:drawTooltip(1, '#F2F2F2ItemID: ' .. id)
                end 

                local buttonW, buttonH = respc(125), respc(25)
                if isInSlot(startX + respc(710), startY + h4/2 - buttonH/2, buttonW, buttonH) then 
                    buyHover = i
                    dxDrawRectangle(startX + respc(710), startY + h4/2 - buttonH/2, buttonW, buttonH, tocolor(97, 177, 90, alpha)) 
                    dxDrawText('Vásárlás', startX + respc(710), startY + h4/2 - buttonH/2, startX + respc(710) + buttonW, startY + h4/2 - buttonH/2 + buttonH + respc(4), tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
                else
                    dxDrawRectangle(startX + respc(710), startY + h4/2 - buttonH/2, buttonW, buttonH, tocolor(97, 177, 90, alpha * 0.5)) 
                    dxDrawText('Vásárlás', startX + respc(710), startY + h4/2 - buttonH/2, startX + respc(710) + buttonW, startY + h4/2 - buttonH/2 + buttonH + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
                end 
            end
            
            startY = startY + h4 + respc(5)
        end

        --[[Premium Items Scrollbar]]
        local scrollx, scrolly = x + respc(28) + w3 - respc(3), y + respc(325) + respc(30)
        local scrollh = ((respc(40) + respc(5)) * 4) - respc(5)
        dxDrawRectangle(scrollx, scrolly, respc(3), scrollh, tocolor(242, 242, 242, alpha * 0.6))

        local percent = #PremiumData[premiumSelected]["items"]

        if percent >= 1 then
            local gW, gH = respc(3), scrollh
            local gX, gY = scrollx, scrolly

            PremiumBuyScrollingHover = isInSlot(gX, gY, gW, gH)

            if PremiumBuyScrolling then
                if isCursorShowing() then
                    if getKeyState("mouse1") then
                        local cx, cy = exports['cr_core']:getCursorPosition()
                        local cy = math.min(math.max(cy, gY), gY + gH)
                        local y = (cy - gY) / (gH)
                        local num = percent * y
                        PremiumBuyMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 4) + 1)))
                        PremiumBuyMaxLines = PremiumBuyMinLines + (4 - 1)
                    end
                else
                    PremiumBuyScrolling = false
                end
            end

            local multiplier = math.min(math.max((PremiumBuyMaxLines - (PremiumBuyMinLines - 1)) / percent, 0), 1)
            local multiplier2 = math.min(math.max((PremiumBuyMinLines - 1) / percent, 0), 1)
            local gY = gY + ((gH) * multiplier2)
            local gH = gH * multiplier

            dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
        end
    elseif cache['page'] == 7 then 
        local x = x + w2

        --[[
            Header
        ]]
        dxDrawText('Állatok', x + respc(20), y + respc(24), x + respc(20), y + respc(24) + respc(35) + respc(5), tocolor(242, 242, 242, alpha), 1, font2, "left", "center")
        dxDrawImage(x + respc(741), y + respc(24), respc(35), respc(35), ":cr_interface/hud/files/avatars/"..datas["avatar"]..".png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText(datas['charName'], x + respc(741) + respc(35) + respc(20), y + respc(24) - respc(5), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(35), tocolor(242, 242, 242, alpha), 1, font3, "left", "top")
        dxDrawText('Szint: ' .. yellow .. datas['lvl'] .. "#F2F2F2 - ".. datas['adminColor'] .. datas['adminTitle'], x + respc(741) + respc(35) + respc(20), y + respc(24), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(5) + respc(35), tocolor(242, 242, 242, alpha), 1, font4, "left", "bottom", false, false, false, true)

        --[[
            Pets
        ]]
        local w3, h3 = respc(430), respc(430)
        dxDrawRectangle(x + respc(28), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))

        --[[Pets Search]]
        dxDrawRectangle(x + respc(28) + respc(140), y + respc(95) + respc(8), respc(280), respc(18), tocolor(51, 51, 51, alpha * 0.8))
        exports['cr_dx']:dxDrawImageAsTexture(x + respc(28) + respc(140) + respc(280) - respc(10) - respc(5), y + respc(95) + respc(8) + respc(18)/2 - respc(10)/2, respc(10), respc(10), ":cr_scoreboard/files/search.png", 0, 0, 0, tocolor(242, 242, 242, alpha)) 
        UpdatePos("Pet >> search", {x + respc(28) + respc(140) + respc(5), y + respc(95) + respc(8) + respc(5), respc(280) - respc(10), respc(18) - respc(10) + respc(4)})

        --[[Pets List]]
        dxDrawText('ID', x + respc(28) + respc(20), y + respc(95) + respc(30), x + respc(28) + respc(20), y + respc(95) + respc(30), tocolor(242, 242, 242, alpha), 1, font5, 'center', 'top')
        dxDrawText('Név', x + respc(28) + respc(100), y + respc(95) + respc(30), x + respc(28) + respc(100), y + respc(95) + respc(30), tocolor(242, 242, 242, alpha), 1, font5, 'center', 'top')
        dxDrawText('Típus', x + respc(28) + respc(390), y + respc(95) + respc(30), x + respc(28) + respc(390), y + respc(95) + respc(30), tocolor(242, 242, 242, alpha), 1, font5, 'center', 'top')

        local startX, startY = x + respc(28) + respc(10), y + respc(95) + respc(50)

        local data = petCache

        local percent = #data

        if PetSearchCache then
            data = PetSearchCache
            percent = #PetSearchCache
        end
        
        if PetMaxLines > percent then
            PetMinLines = 1
            PetMaxLines = 15
        end

        PetScrollBarHover = isInSlot(startX, startY, respc(410), ((respc(20) + respc(5)) * 15) - respc(5))

        PetHover = nil
        PetRenameHover = nil
        for i = PetMinLines, PetMaxLines do
            local w4, h4 = respc(410), respc(20)

            local inSlot = isInSlot(startX,startY,w4,h4)
            local data = data[i]

            if inSlot or data and PetSelected == i then
                dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
            else
                dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
            end
            
            if data then
                local id = data[1]
                local nick = data[4]
                local type = petTypeNames[data[2]]

                if inSlot or PetSelected == i then    
                    if inSlot then 
                        PetHover = i
                    end 

                    dxDrawText(string.gsub(id, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(10),startY,startX + respc(10), startY + h4 + respc(4), tocolor(51, 51, 51, alpha), 1, font7, "center", "center", false, false, false, true)
                    dxDrawText(string.gsub(nick, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(90),startY,startX + respc(90), startY + h4 + respc(4), tocolor(51, 51, 51, alpha), 1, font7, "center", "center", false, false, false, true)
                    dxDrawText(string.gsub(type, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX,startY,startX + w4 - respc(5), startY + h4 + respc(4), tocolor(51, 51, 51, alpha), 1, font7, "right", "center", false, false, false, true)

                    if inSlot then 
                        local tWidth = dxGetTextWidth(string.gsub(nick, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), 1, font7)

                        if isInSlot(startX + respc(90) + tWidth/2 + respc(5), startY + h4/2 - respc(20)/2, respc(20), respc(20)) then 
                            PetRenameHover = i

                            exports['cr_dx']:dxDrawImageAsTexture(startX + respc(90) + tWidth/2 + respc(5), startY + h4/2 - respc(20)/2, respc(20), respc(20), ":cr_dashboard/assets/images/pencil.png", 0, 0, 0, tocolor(51, 51, 51, alpha))
                        else 
                            exports['cr_dx']:dxDrawImageAsTexture(startX + respc(90) + tWidth/2 + respc(5), startY + h4/2 - respc(20)/2, respc(20), respc(20), ":cr_dashboard/assets/images/pencil.png", 0, 0, 0, tocolor(51, 51, 51, alpha * 0.6))
                        end 
                    end 
                else
                    dxDrawText(id, startX + respc(10),startY,startX + respc(10), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "center", "center", false, false, false, true)
                    dxDrawText(nick, startX + respc(90),startY,startX + respc(90), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "center", "center", false, false, false, true)
                    dxDrawText(type, startX,startY,startX + w4 - respc(5), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "right", "center", false, false, false, true)
                end
            end
            
            startY = startY + h4 + respc(5)
        end

        --[[
            Pet Informations
        ]]
        dxDrawRectangle(x + respc(488), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawRectangle(x + respc(488) + w3/2 - respc(380)/2, y + respc(95) + respc(110), respc(380), respc(2), tocolor(135, 135, 135, alpha * 0.6))

        dxDrawText('Állat Információk:', x + respc(488) + respc(15), y + respc(95) + respc(10), x + respc(488) + respc(15), y + respc(95) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'top')

        --[[Pet Informations List]]
        local startX, startY = x + respc(488) + respc(10), y + respc(95) + respc(30)

        for i = 1, 3 do 
            local w4, h4 = respc(410), respc(20)

            local inSlot = isInSlot(startX,startY,w4,h4)
            if inSlot then
                dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
            else
                dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
            end
            
            if #playerPetInfos >= 1 and #playerPetInfos[6] >= 1 then
                if playerPetInfos[6][i] then
                    local v = playerPetInfos[6][i]
                    if inSlot then
                        dxDrawText(string.gsub(v, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(51, 51, 51,alpha), 1, font7, "left", "center", false, false, false, true)
                    else
                        dxDrawText(v, startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                    end
                end
            end
            
            startY = startY + h4 + respc(5)
        end

        --[[
            Pet Specific Informations
        ]]
        petButtonHover = nil
        if PetSelected and playerPetInfos and #playerPetInfos >= 1 then 
            --[[Pet Preview]]
            dxDrawRectangle(x + respc(488) + respc(30), y + respc(95) + respc(125), respc(125), respc(150), tocolor(23, 23, 23, alpha * 0.8))
            exports['cr_dx']:dxDrawImageAsTexture(x + respc(488) + respc(30), y + respc(95) + respc(125), respc(125), respc(150), ':cr_dashboard/assets/pets/'..playerPetInfos[1]..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

            --[[
                Pet Statistic
            ]]
            local startX, startY = x + respc(488) + respc(195), y + respc(95) + respc(140)

            --[[>> Love]]
            dxDrawRectangle(startX, startY, respc(225), respc(5), tocolor(242, 242, 242, alpha * 0.6))

            local percent = playerPetInfos[5][4] / 100
            if localPlayer:getData("pet") and localPlayer:getData("pet"):getData("pet >> id") == playerPetInfos[3] then 
                percent = localPlayer:getData("pet"):getData("pet >> data")[4] / 100
            end 

            dxDrawRectangle(startX, startY, respc(225) * percent, respc(5), tocolor(97, 177, 90, alpha))

            exports['cr_dx']:dxDrawImageAsTexture(startX - respc(16) - respc(5), startY + respc(5)/2 - respc(14)/2, respc(16), respc(14), ':cr_dashboard/assets/images/pet-love.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.8))

            if isInSlot(startX, startY, respc(225), respc(5)) then 
                exports['cr_dx']:drawTooltip(1, "#F2F2F2Szeretet: " .. math.ceil(percent * 100) .. "/100")
            end 

            startY = startY + respc(5) + respc(10)

            --[[>> HP]]
            dxDrawRectangle(startX, startY, respc(225), respc(5), tocolor(242, 242, 242, alpha * 0.6))

            local percent = playerPetInfos[5][1] / 200
            if localPlayer:getData("pet") and localPlayer:getData("pet"):getData("pet >> id") == playerPetInfos[3] then 
                percent = localPlayer:getData("pet").health / 200
            end 

            dxDrawRectangle(startX, startY, respc(225) * percent, respc(5), tocolor(255, 59, 59, alpha))

            exports['cr_dx']:dxDrawImageAsTexture(startX - respc(14.5) - respc(5), startY + respc(5)/2 - respc(12)/2, respc(13), respc(12), ':cr_dashboard/assets/images/pet-hp.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.8))

            if isInSlot(startX, startY, respc(225), respc(5)) then 
                exports['cr_dx']:drawTooltip(1, "#F2F2F2Élet: " .. math.ceil(percent * 100) .. "/100")
            end 

            startY = startY + respc(5) + respc(10)

            --[[>> Food]]
            dxDrawRectangle(startX, startY, respc(225), respc(5), tocolor(242, 242, 242, alpha * 0.6))

            local percent = playerPetInfos[5][2] / 100
            if localPlayer:getData("pet") and localPlayer:getData("pet"):getData("pet >> id") == playerPetInfos[3] then 
                percent = localPlayer:getData("pet"):getData("pet >> data")[2] / 100
            end 

            dxDrawRectangle(startX, startY, respc(225) * percent, respc(5), tocolor(242, 153, 74, alpha))

            exports['cr_dx']:dxDrawImageAsTexture(startX - respc(16) - respc(5), startY + respc(5)/2 - respc(11)/2, respc(16), respc(11), ':cr_dashboard/assets/images/pet-food.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.8))

            if isInSlot(startX, startY, respc(225), respc(5)) then 
                exports['cr_dx']:drawTooltip(1, "#F2F2F2Éhség: " .. math.ceil(percent * 100) .. "/100")
            end 

            startY = startY + respc(5) + respc(10)

            --[[>> Water]]
            dxDrawRectangle(startX, startY, respc(225), respc(5), tocolor(242, 242, 242, alpha * 0.6))

            local percent = playerPetInfos[5][3] / 100
            if localPlayer:getData("pet") and localPlayer:getData("pet"):getData("pet >> id") == playerPetInfos[3] then 
                percent = localPlayer:getData("pet"):getData("pet >> data")[3] / 100
            end 

            dxDrawRectangle(startX, startY, respc(225) * percent, respc(5), tocolor(47, 128, 237, alpha))

            exports['cr_dx']:dxDrawImageAsTexture(startX - respc(16) - respc(5), startY + respc(5)/2 - respc(10)/2, respc(16), respc(10), ':cr_dashboard/assets/images/pet-water.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.8))

            if isInSlot(startX, startY, respc(225), respc(5)) then 
                exports['cr_dx']:drawTooltip(1, "#F2F2F2Szomjúság: " .. math.ceil(percent * 100) .. "/100")
            end 

            --[[
                Pet Interaction Buttons
            ]]
            local startX, startY = x + respc(488) + respc(228), y + respc(95) + respc(205)

            local buttonW, buttonH = respc(130), respc(20)

            --[[>> Pet Spawn / DeSpawn]]
            if not localPlayer:getData("pet") or localPlayer:getData("pet"):getData("pet >> id") == playerPetInfos[3] then 
                if playerPetInfos[4] > 0 then
                    local r,g,b = 97, 177, 90
                    local text = "Pet spawnolása"
                    if localPlayer:getData("pet") then 
                        text = "Pet despawnolása"
                        r, g, b = 255, 59, 59
                    end 

                    if isInSlot(startX, startY, buttonW, buttonH) then 
                        petButtonHover = 1

                        dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(r, g, b, alpha)) 
                        dxDrawText(text, startX, startY, startX + buttonW, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
                    else
                        dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                        dxDrawText(text, startX, startY, startX + buttonW, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
                    end 

                    startY = startY + buttonH + respc(5)
                end 
            end

            --[[>> Pet Respawn]]
            if playerPetInfos[4] <= 0 then 
                local text = "Pet felélesztése" 

                if isInSlot(startX, startY, buttonW, buttonH) then 
                    petButtonHover = 2

                    local r,g,b = exports['cr_core']:getServerColor('orange')
                    dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(r, g, b, alpha)) 
                    dxDrawText(text, startX, startY, startX + buttonW, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
                else
                    dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                    dxDrawText(text, startX, startY, startX + buttonW, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
                end 

                startY = startY + buttonH + respc(5)
            end

            --[[>> Pet Sell]]
            if not localPlayer:getData("pet") or localPlayer:getData("pet"):getData("pet >> id") ~= playerPetInfos[3] then
                local text = "Pet eladása"

                if isInSlot(startX, startY, buttonW, buttonH) then 
                    petButtonHover = 3

                    dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(255, 59, 59, alpha)) 
                    dxDrawText(text, startX, startY, startX + buttonW, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
                else
                    dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                    dxDrawText(text, startX, startY, startX + buttonW, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
                end 

                startY = startY + buttonH + respc(5)
            end

            --[[>> Pet Buy]]
            local text = "Pet vásárlása"

            if isInSlot(startX, startY, buttonW, buttonH) then 
                petButtonHover = 4

                dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(97, 177, 90, alpha)) 
                dxDrawText(text, startX, startY, startX + buttonW, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
            else
                dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                dxDrawText(text, startX, startY, startX + buttonW, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
            end 

        else
            --[[Pet Buy]] 
            local startX, startY = x + respc(488), y + respc(95) + respc(110) + (h3 - respc(110))/2 - ((respc(101) + respc(30) + respc(10) + respc(22))/2)
            exports['cr_dx']:dxDrawImageAsTexture(startX + w3/2 - respc(107)/2, startY, respc(107), respc(101), ":cr_dashboard/assets/images/warning.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.7))

            startY = startY + respc(101) + respc(10)

            dxDrawText('Ha petet szeretnél vásárolni kattints az alábbi gombra!', startX, startY, startX + w3, startY, tocolor(255, 59, 59, alpha), 1, font, "center", "top")

            startY = startY + respc(20) + respc(10)

            local buttonW, buttonH = respc(200), respc(22)

            if isInSlot(startX + w3/2 - buttonW/2, startY, buttonW, buttonH) then 
                petButtonHover = 4

                dxDrawRectangle(startX + w3/2 - buttonW/2, startY, buttonW, buttonH, tocolor(97, 177, 90, alpha)) 
                dxDrawText('Pet vásárlása', startX, startY, startX + w3, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
            else
                dxDrawRectangle(startX + w3/2 - buttonW/2, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                dxDrawText('Pet vásárlása', startX, startY, startX + w3, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
            end 
        end 
    elseif cache['page'] == 8 then 
        local x = x + w2

        --[[
            Header
        ]]
        dxDrawText('Beállítások', x + respc(20), y + respc(24), x + respc(20), y + respc(24) + respc(35) + respc(5), tocolor(242, 242, 242, alpha), 1, font2, "left", "center")
        dxDrawImage(x + respc(741), y + respc(24), respc(35), respc(35), ":cr_interface/hud/files/avatars/"..datas["avatar"]..".png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText(datas['charName'], x + respc(741) + respc(35) + respc(20), y + respc(24) - respc(5), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(35), tocolor(242, 242, 242, alpha), 1, font3, "left", "top")
        dxDrawText('Szint: ' .. yellow .. datas['lvl'] .. "#F2F2F2 - ".. datas['adminColor'] .. datas['adminTitle'], x + respc(741) + respc(35) + respc(20), y + respc(24), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(5) + respc(35), tocolor(242, 242, 242, alpha), 1, font4, "left", "bottom", false, false, false, true)

        --[[
            Menu
        ]]
        local startX = x + respc(180)

        --[[Options Left Arrow]]
        arrowHover = nil
        if isInSlot(startX - respc(16) - respc(5), y + respc(24) + respc(40)/2 - respc(12)/2, respc(16), respc(12)) then 
            arrowHover = "left"

            exports['cr_dx']:dxDrawImageAsTexture(startX - respc(16) - respc(5), y + respc(24) + respc(40)/2 - respc(12)/2, respc(16), respc(12), ":cr_carshop/files/imgs/leftArrow.png", 0, 0, 0, tocolor(242, 242, 242, alpha))
        else 
            exports['cr_dx']:dxDrawImageAsTexture(startX - respc(16) - respc(5), y + respc(24) + respc(40)/2 - respc(12)/2, respc(16), respc(12), ":cr_carshop/files/imgs/leftArrow.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
        end 
        --[[/Options Left Arrow]]

        optionsHover = nil
        for i = optionsSelectMinLines, optionsSelectMaxLines do
            if options[i] then 
                local v = options[i]['name']

                local textWidth = dxGetTextWidth(v, 1, font9) + respc(10)
                local inSlot = isInSlot(startX, y + respc(24), textWidth, respc(40))

                local gradientHeight = respc(10)

                local textAlpha = alpha
                local lineAlpha = alpha

                if optionsButtonAnimation[i] then 
                    local startTick, type = unpack(optionsButtonAnimation[i])
                    local progress = (nowTick - startTick) / 250

                    if progress > 1 then 
                        optionsButtonAnimation[i] = nil
                    end 

                    gradientHeight, textAlpha, lineAlpha = interpolateBetween(
                        type == 1 and 0 or gradientHeight, type == 1 and alpha * 0.6 or textAlpha, type == 1 and 0 or lineAlpha,
                        type == 1 and gradientHeight or 0, type == 1 and textAlpha or alpha * 0.6, type == 1 and lineAlpha or 0,
                        progress, "InOutQuad"
                    )
                end

                dxDrawRectangle(startX, y + respc(52.5), textWidth, 2, tocolor(51, 51, 51, alpha * 0.3))
                if optionsSelected == i or optionsButtonAnimation[i] then 
                    exports['cr_dx']:dxDrawImageAsTexture(startX, y + respc(52.5) - gradientHeight, textWidth, gradientHeight, ':cr_bank/assets/images/gradient.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.6))

                    dxDrawRectangle(startX, y + respc(52.5), textWidth, 2, tocolor(255, 59, 59, lineAlpha))
                end 

                if inSlot or optionsSelected == i or optionsButtonAnimation[i] then 
                    if inSlot and optionsSelected ~= i then
                        optionsHover = i
                    end

                    dxDrawText(v, startX, y + respc(24), startX + textWidth, y + respc(24) + respc(35) + respc(5), tocolor(242, 242, 242, textAlpha), 1, font9, "center", "center")
                else 
                    dxDrawText(v, startX, y + respc(24), startX + textWidth, y + respc(24) + respc(35) + respc(5), tocolor(242, 242, 242, alpha * 0.6), 1, font9, "center", "center")
                end 

                startX = startX + textWidth
            end 
        end 

        --[[Options Right Arrow]]
        if isInSlot(startX + respc(5), y + respc(24) + respc(40)/2 - respc(12)/2, respc(16), respc(12)) then 
            arrowHover = "right"

            exports['cr_dx']:dxDrawImageAsTexture(startX + respc(5), y + respc(24) + respc(40)/2 - respc(12)/2, respc(16), respc(12), ":cr_carshop/files/imgs/leftArrow.png", 180, 0, 0, tocolor(242, 242, 242, alpha))
        else 
            exports['cr_dx']:dxDrawImageAsTexture(startX + respc(5), y + respc(24) + respc(40)/2 - respc(12)/2, respc(16), respc(12), ":cr_carshop/files/imgs/leftArrow.png", 180, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
        end 
        --[[/Options Right Arrow]]

        --[[
            Avatar / Crosshair selector
        ]]

        local w3, h3 = respc(150), respc(220)
        dxDrawRectangle(x + respc(20), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawRectangle(x + respc(20) + w3/2 - respc(130)/2, y + respc(95) + respc(115), respc(130), respc(2), tocolor(135, 135, 135, alpha * 0.6))

        --[[Crosshair Selection]]
        dxDrawText('Célkereszt szerkesztés', x + respc(20) + respc(10), y + respc(95) + respc(15), x + respc(20) + respc(10), y + respc(95) + respc(15), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'center')
        dxDrawRectangle(x + respc(20) + w3/2 - respc(45)/2, y + respc(95) + respc(38), respc(45), respc(45), tocolor(23, 23, 23, alpha * 0.8))

        local r,g,b = unpack(datas["crosshairColor"])
        exports['cr_dx']:dxDrawImageAsTexture(x + respc(20) + w3/2 - respc(45)/2 + respc(45)/2 - respc(30)/2, y + respc(95) + respc(38) + respc(45)/2 - respc(30)/2, respc(30), respc(30), ":cr_crosshair/files/"..datas["crosshair"]..".png", 0, 0, 0, tocolor(r, g, b, alpha))

        --[[Crosshair Arrow Left]]
        if isInSlot(x + respc(20) + w3/2 - respc(45)/2 - respc(6) - respc(10), y + respc(95) + respc(38) + respc(45)/2 - respc(12)/2, respc(6), respc(12)) then 
            arrowHover = "crosshairLeft"

            exports['cr_dx']:dxDrawImageAsTexture(x + respc(20) + w3/2 - respc(45)/2 - respc(6) - respc(10), y + respc(95) + respc(38) + respc(45)/2 - respc(12)/2, respc(6), respc(12), ':cr_dashboard/assets/images/arrow.png', 180, 0, 0, tocolor(242, 242, 242, alpha))
        else 
            exports['cr_dx']:dxDrawImageAsTexture(x + respc(20) + w3/2 - respc(45)/2 - respc(6) - respc(10), y + respc(95) + respc(38) + respc(45)/2 - respc(12)/2, respc(6), respc(12), ':cr_dashboard/assets/images/arrow.png', 180, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
        end 

        --[[Crosshair Arrow Right]]
        if isInSlot(x + respc(20) + w3/2 + respc(45)/2 + respc(10), y + respc(95) + respc(38) + respc(45)/2 - respc(12)/2, respc(6), respc(12)) then 
            arrowHover = "crosshairRight"

            exports['cr_dx']:dxDrawImageAsTexture(x + respc(20) + w3/2 + respc(45)/2 + respc(10), y + respc(95) + respc(38) + respc(45)/2 - respc(12)/2, respc(6), respc(12), ':cr_dashboard/assets/images/arrow.png', 0, 0, 0, tocolor(242, 242, 242, alpha))
        else 
            exports['cr_dx']:dxDrawImageAsTexture(x + respc(20) + w3/2 + respc(45)/2 + respc(10), y + respc(95) + respc(38) + respc(45)/2 - respc(12)/2, respc(6), respc(12), ':cr_dashboard/assets/images/arrow.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
        end 

        --[[Crosshair Color Button]]
        local startY = y + respc(95) + respc(90)

        local buttonW, buttonH = respc(100), respc(15)

        if isInSlot(x + respc(20) + w3/2 - buttonW/2, startY, buttonW, buttonH) then 
            arrowHover = "crosshairColor"

            dxDrawRectangle(x + respc(20) + w3/2 - buttonW/2, startY, buttonW, buttonH, tocolor(97, 177, 90, alpha)) 
            dxDrawText('Színezés', x + respc(20), startY, x + respc(20) + w3, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
        else
            dxDrawRectangle(x + respc(20) + w3/2 - buttonW/2, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
            dxDrawText('Színezés', x + respc(20), startY, x + respc(20) + w3, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
        end 

        --[[Avatar Selection]]
        dxDrawText('Avatár szerkesztés', x + respc(20) + respc(10), y + respc(95) + respc(130), x + respc(20) + respc(10), y + respc(95) + respc(130), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'center')

        dxDrawRectangle(x + respc(20) + w3/2 - respc(45)/2, y + respc(95) + respc(155), respc(45), respc(45), tocolor(23, 23, 23, alpha * 0.8))
        exports['cr_dx']:dxDrawImageAsTexture(x + respc(20) + w3/2 - respc(45)/2 + respc(1), y + respc(95) + respc(155) + respc(1), respc(45) - respc(2), respc(45) - respc(2), ":cr_interface/hud/files/avatars/"..datas["avatar"]..".png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        --[[Avatar Arrow Left]]
        if isInSlot(x + respc(20) + w3/2 - respc(45)/2 - respc(6) - respc(10), y + respc(95) + respc(155) + respc(45)/2 - respc(12)/2, respc(6), respc(12)) then 
            arrowHover = "avatarLeft"

            exports['cr_dx']:dxDrawImageAsTexture(x + respc(20) + w3/2 - respc(45)/2 - respc(6) - respc(10), y + respc(95) + respc(155) + respc(45)/2 - respc(12)/2, respc(6), respc(12), ':cr_dashboard/assets/images/arrow.png', 180, 0, 0, tocolor(242, 242, 242, alpha))
        else 
            exports['cr_dx']:dxDrawImageAsTexture(x + respc(20) + w3/2 - respc(45)/2 - respc(6) - respc(10), y + respc(95) + respc(155) + respc(45)/2 - respc(12)/2, respc(6), respc(12), ':cr_dashboard/assets/images/arrow.png', 180, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
        end 

        --[[Avatar Arrow Right]]
        if isInSlot(x + respc(20) + w3/2 + respc(45)/2 + respc(10), y + respc(95) + respc(155) + respc(45)/2 - respc(12)/2, respc(6), respc(12)) then 
            arrowHover = "avatarRight"

            exports['cr_dx']:dxDrawImageAsTexture(x + respc(20) + w3/2 + respc(45)/2 + respc(10), y + respc(95) + respc(155) + respc(45)/2 - respc(12)/2, respc(6), respc(12), ':cr_dashboard/assets/images/arrow.png', 0, 0, 0, tocolor(242, 242, 242, alpha))
        else 
            exports['cr_dx']:dxDrawImageAsTexture(x + respc(20) + w3/2 + respc(45)/2 + respc(10), y + respc(95) + respc(155) + respc(45)/2 - respc(12)/2, respc(6), respc(12), ':cr_dashboard/assets/images/arrow.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
        end 

        --[[
            Search
        ]]
        dxDrawRectangle(x + respc(20), y + respc(335), respc(150), respc(18), tocolor(51, 51, 51, alpha * 0.8))
        exports['cr_dx']:dxDrawImageAsTexture(x + respc(20) + respc(150) - respc(10) - respc(5), y + respc(335) + respc(18)/2 - respc(10)/2, respc(10), respc(10), ":cr_scoreboard/files/search.png", 0, 0, 0, tocolor(242, 242, 242, alpha)) 
        UpdatePos("Options >> search", {x + respc(20) + respc(5), y + respc(335), respc(150) - respc(10), respc(18) + respc(4)})

        --[[Search Button]]
        searchHover = nil
        if isInSlot(x + respc(20), y + respc(360), respc(150), respc(22)) then
            searchHover = true

            dxDrawRectangle(x + respc(20), y + respc(360), respc(150), respc(22), tocolor(255, 59, 59, alpha))
            dxDrawText('Keresés', x + respc(20), y + respc(360), x + respc(20) + respc(150), y + respc(360) + respc(22) + respc(4), tocolor(242,242,242, alpha), 1, font10, "center", "center")
        else
            dxDrawRectangle(x + respc(20), y + respc(360), respc(150), respc(22), tocolor(23, 23, 23, alpha * 0.9))
            dxDrawText('Keresés', x + respc(20), y + respc(360), x + respc(20) + respc(150), y + respc(360) + respc(22) + respc(4), tocolor(242,242,242, alpha * 0.6), 1, font10, "center", "center")
        end

        --[[
            Options
        ]]
        local w3, h3 = respc(740), respc(430)
        dxDrawRectangle(x + respc(190), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))

        dxDrawText('Megnevezés', x + respc(190) + respc(15), y + respc(95) + respc(10), x + respc(190) + respc(15), y + respc(95) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'top')
        dxDrawText('Kezelés', x + respc(190) + respc(725), y + respc(95) + respc(10), x + respc(190) + respc(725), y + respc(95) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'right', 'top')

        --[[Options List]]
        local data = options[optionsSelected]["options"]

        local percent = #data
        if optionsSearchCache then
            percent = #optionsSearchCache
        end

        if optionsMaxLines > percent then
            optionsMinLines = 1
            optionsMaxLines = 16
        end
        
        local startX, startY = x + respc(190) + respc(10), y + respc(95) + respc(30)

        optionsScrollBarHover = isInSlot(startX, startY, respc(720), ((respc(20) + respc(5)) * 16) - respc(5))

        optionsFunctionHover = nil
        for i = optionsMinLines, optionsMaxLines do
            local w4, h4 = respc(720), respc(20)

            local inSlot = not optionsButtonScrolled and isInSlot(startX,startY,w4,h4)

            if inSlot then
                dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
            else
                dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
            end
            
            if optionsSearchCache then
                if optionsSearchCache[i] then
                    i = optionsSearchCache[i]["id"]
                else
                    i = -1 
                end 
            end

            local data = data[i]
            if data then
                local name = data["name"]
                local type = data["type"]
                local nowValue = data["nowValue"]
                local minValue = data["minValue"]
                local maxValue = data["maxValue"]

                if inSlot then
                    dxDrawText(data["name"], startX + respc(5),startY, startX + respc(5), startY + h4 + respc(4), tocolor(51,51,51,alpha), 1, font6, "left", "center")
                else
                    dxDrawText(data["name"], startX + respc(5),startY, startX + respc(5), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font6, "left", "center")
                end

                if type == 1 then 
                    if nowValue == 1 then 
                        exports['cr_dx']:dxDrawImageAsTexture(startX + w4 - respc(25) - respc(5), startY + h4/2 - respc(12)/2, respc(25), respc(12), ':cr_vehicle/assets/images/slider-on.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
                    else
                        exports['cr_dx']:dxDrawImageAsTexture(startX + w4 - respc(25) - respc(5), startY + h4/2 - respc(12)/2, respc(25), respc(12), ':cr_vehicle/assets/images/slider-off.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
                    end
                    
                    if isInSlot(startX + w4 - respc(25) - respc(5), startY + h4/2 - respc(12)/2, respc(25), respc(12)) then
                        optionsFunctionHover = i
                    end
                elseif type == 2 then 
                    dxDrawImage(startX + w4 - respc(14) - respc(5), startY + h4/2 - respc(14)/2, respc(14), respc(14), "assets/images/checkbox-off.png", 0, 0, 0, tocolor(255, 255, 255, alpha * 0.25))

                    if nowValue == 1 then 
                        dxDrawImage(startX + w4 - respc(14) - respc(5), startY + h4/2 - respc(14)/2, respc(14), respc(14), "assets/images/checkbox-on.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
                    end 

                    if isInSlot(startX + w4 - respc(14) - respc(5), startY + h4/2 - respc(14)/2, respc(14), respc(14)) then
                        optionsFunctionHover = i
                    end
                elseif type == 3 then 
                    dxDrawRectangle(startX + w4 - respc(220) - respc(5), startY + h4/2 - respc(18)/2, respc(220), respc(18), tocolor(23, 23, 23, alpha * 0.8))
                    
                    if now == i .. ">>inputBar" then 
                        if isInSlot(startX + w4 - respc(5) - respc(5) - respc(8), startY + h4/2 - respc(6)/2, respc(8), respc(6)) then 
                            optionsFunctionHover = i

                            exports['cr_dx']:dxDrawImageAsTexture(startX + w4 - respc(5) - respc(5) - respc(8), startY + h4/2 - respc(6)/2, respc(8), respc(6), ':cr_dashboard/assets/images/check.png', 0, 0, 0, tocolor(97, 177, 90, alpha))
                        else
                            exports['cr_dx']:dxDrawImageAsTexture(startX + w4 - respc(5) - respc(5) - respc(8), startY + h4/2 - respc(6)/2, respc(8), respc(6), ':cr_dashboard/assets/images/check.png', 0, 0, 0, tocolor(97, 177, 90, alpha * 0.6))
                        end 
                    end

                    UpdatePos(i .. ">>inputBar", {startX + w4 - respc(220) - respc(5) + respc(5), startY + h4/2 - respc(18)/2, respc(220) - respc(10), respc(18) + respc(4)})
                elseif type == 4 then 
                    local inSlot = isInSlot(startX + w4 - respc(150) - respc(5), startY + h4/2 - respc(5)/2, respc(150), respc(5))

                    dxDrawRectangle(startX + w4 - respc(150) - respc(5), startY + h4/2 - respc(5)/2, respc(150), respc(5), tocolor(242, 242, 242, alpha * 0.6))
                    local percent = (nowValue - minValue) / (maxValue - minValue)
                    dxDrawRectangle(startX + w4 - respc(150) - respc(5), startY + h4/2 - respc(5)/2, respc(150) * percent, respc(5), tocolor(255, 59, 59, inSlot and alpha or alpha * 0.7))

                    if inSlot then 
                        if data["tooltipRound"] then 
                            exports['cr_dx']:drawTooltip(1, math.round(nowValue, 3) .. "/" .. maxValue)
                        else 
                            exports['cr_dx']:drawTooltip(1, math.ceil(nowValue) .. "/" .. maxValue)
                        end 
                        
                        optionsFunctionHover = i
                    end 

                    if moving and movingNum == i then
                        if isCursorShowing() then
                            if getKeyState("mouse1") then
                                local cx, cy = exports['cr_core']:getCursorPosition()
                                local a = (cx - (startX + w4 - respc(150) - respc(5))) / respc(150)
                                if a ~= options[optionsSelected]["options"][movingNum]["nowValue"] then
                                    options[optionsSelected]["options"][movingNum]["nowValue"] = options[optionsSelected]["options"][movingNum]["minValue"] + ((options[optionsSelected]["options"][movingNum]["maxValue"] - options[optionsSelected]["options"][movingNum]["minValue"]) * math.max(math.min(a, 1), 0))
                                    
                                    if isTimer(updateTimer) then killTimer(updateTimer) end
                                    updateTimer = setTimer(
                                        function()
                                            if options[optionsSelected]["options"][movingNum]["onChange"] then 
                                                options[optionsSelected]["options"][movingNum]["onChange"](options[optionsSelected]["options"][movingNum]["minValue"], options[optionsSelected]["options"][movingNum]["nowValue"], options[optionsSelected]["options"][movingNum]["maxValue"])
                                            end 
                                        end, 250, 1
                                    )
                                end
                            end
                        else
                            moving = false
                        end
                    end
                elseif type == 5 then
                    local w5, h5 = respc(100), respc(16)
                    local nowX, nowY = startX + w4 - respc(5) - w5, startY + h4/2 - h5/2

                    if optionsButtonScrolled and optionsButtonScrolled == i then  
                        scrollX, scrollY, scrollW, scrollH = nowX, nowY, w5, h5
                    else 
                        if data["boxShowNowValue"] then 
                            name = ""
                        end 

                        if isInSlot(nowX, nowY, w5, h5) then 
                            dxDrawRectangle(nowX, nowY, w5, h5, tocolor(23, 23, 23, alpha * 0.8))
                            dxDrawText(name, nowX + respc(5), nowY, nowX + w5, nowY + h5 + respc(4), tocolor(242,242,242), 1, font5, "left", "center", false, false, false, true)

                            if isInSlot(nowX + w5 - respc(5) - respc(14), startY + h4/2 - respc(8)/2, respc(14), respc(8)) then 
                                optionsFunctionHover = i

                                dxDrawImage(nowX + w5 - respc(5) - respc(14), startY + h4/2 - respc(8)/2, respc(14), respc(8), ":cr_payday/assets/images/icon.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
                            else 
                                dxDrawImage(nowX + w5 - respc(5) - respc(14), startY + h4/2 - respc(8)/2, respc(14), respc(8), ":cr_payday/assets/images/icon.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.8))
                            end 
                        else 
                            dxDrawRectangle(nowX, nowY, w5, h5, tocolor(23, 23, 23, alpha * 0.6))
                            dxDrawText(name, nowX + respc(5), nowY, nowX + w5, nowY + h5 + respc(4), tocolor(242,242,242,alpha * 0.7), 1, font5, "left", "center", false, false, false, true)
                            dxDrawImage(nowX + w5 - respc(5) - respc(14), startY + h4/2 - respc(8)/2, respc(14), respc(8), ":cr_payday/assets/images/icon.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
                        end
                    end 
                end 
            end
            
            startY = startY + h4 + respc(5)
        end

        --[[UnScrolled Type 5]]
        if optionsButtonScrolled then 
            local data = options[optionsSelected]["options"][optionsButtonScrolled]
            local name = data["name"]
            if data["boxShowNowValue"] then 
                name = ""
            end 
            local nowValue = data["nowValue"]

            local w4, h4 = respc(720), respc(20)
            local w5, h5 = respc(100), respc(16)

            local h3 = scrollH + (#data["options"] * h5)

            dxDrawRectangle(scrollX, scrollY, scrollW, h3, tocolor(23, 23, 23, alpha))

            optionsFunctionHover = nil 

            if isInSlot(scrollX, scrollY, w5, h5) then 
                dxDrawText(name, scrollX + respc(5), scrollY, scrollX + w5, scrollY + h5 + respc(4), tocolor(242,242,242), 1, font5, "left", "center", false, false, false, true)

                if isInSlot(scrollX + w5 - respc(5) - respc(14), (scrollY + h5/2 - h4/2) + h4/2 - respc(8)/2, respc(14), respc(8)) then 
                    optionsFunctionHover = optionsButtonScrolled

                    dxDrawImage(scrollX + w5 - respc(5) - respc(14), (scrollY + h5/2 - h4/2) + h4/2 - respc(8)/2, respc(14), respc(8), ":cr_payday/assets/images/icon.png", 180 or 0, 0, 0, tocolor(255, 59, 59, alpha))
                else 
                    dxDrawImage(scrollX + w5 - respc(5) - respc(14), (scrollY + h5/2 - h4/2) + h4/2 - respc(8)/2, respc(14), respc(8), ":cr_payday/assets/images/icon.png", 180 or 0, 0, 0, tocolor(255, 59, 59, alpha * 0.8))
                end 
            else 
                dxDrawText(name, scrollX + respc(5), scrollY, scrollX + w5, scrollY + h5 + respc(4), tocolor(242,242,242,alpha * 0.7), 1, font5, "left", "center", false, false, false, true)
                dxDrawImage(scrollX + w5 - respc(5) - respc(14), (scrollY + h5/2 - h4/2) + h4/2 - respc(8)/2, respc(14), respc(8), ":cr_payday/assets/images/icon.png", 180 or 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
            end

            optionsScrollHover = nil
            local startY = scrollY + scrollH

            for k,v in ipairs(data["options"]) do 
                local name = v

                local h = h5

                if isInSlot(scrollX, startY, scrollW, h) or nowValue == k then
                    if isInSlot(scrollX, startY, scrollW, h) then
                        optionsScrollHover = k
                    end 

                    dxDrawText(name, scrollX, startY, scrollX + scrollW, startY + h + 4, tocolor(242, 242, 242,alpha), 1, font5, "center", "center", false, false, false, true)
                else 
                    dxDrawText(name, scrollX, startY, scrollX + scrollW, startY + h + 4, tocolor(242, 242, 242,alpha * 0.7), 1, font5, "center", "center", false, false, false, true)
                end 

                local barW, barH = scrollW - respc(4), respc(2)
                dxDrawRectangle(scrollX + scrollW/2 - barW/2, startY - respc(2) + barH/2, barW, barH, tocolor(135, 135, 135, alpha * 0.6))

                startY = startY + h
            end 
        end 
    elseif cache['page'] == 9 then 
        local x = x + w2

        --[[
            Header
        ]]
        dxDrawText('Mod Beállítások', x + respc(20), y + respc(24), x + respc(20), y + respc(24) + respc(35) + respc(5), tocolor(242, 242, 242, alpha), 1, font2, "left", "center")
        dxDrawImage(x + respc(741), y + respc(24), respc(35), respc(35), ":cr_interface/hud/files/avatars/"..datas["avatar"]..".png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText(datas['charName'], x + respc(741) + respc(35) + respc(20), y + respc(24) - respc(5), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(35), tocolor(242, 242, 242, alpha), 1, font3, "left", "top")
        dxDrawText('Szint: ' .. yellow .. datas['lvl'] .. "#F2F2F2 - ".. datas['adminColor'] .. datas['adminTitle'], x + respc(741) + respc(35) + respc(20), y + respc(24), x + respc(741) + respc(35) + respc(20), y + respc(24) + respc(5) + respc(35), tocolor(242, 242, 242, alpha), 1, font4, "left", "bottom", false, false, false, true)

        --[[
            Modmenu
        ]]
        local w3, h3 = respc(430), respc(430)
        dxDrawRectangle(x + respc(28), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))

        --[[Modmenu Search]]
        dxDrawRectangle(x + respc(28) + respc(140), y + respc(95) + respc(8), respc(280), respc(18), tocolor(51, 51, 51, alpha * 0.8))
        exports['cr_dx']:dxDrawImageAsTexture(x + respc(28) + respc(140) + respc(280) - respc(10) - respc(5), y + respc(95) + respc(8) + respc(18)/2 - respc(10)/2, respc(10), respc(10), ":cr_scoreboard/files/search.png", 0, 0, 0, tocolor(242, 242, 242, alpha)) 
        UpdatePos("ModPanel >> search", {x + respc(28) + respc(140) + respc(5), y + respc(95) + respc(8) + respc(5), respc(280) - respc(10), respc(18) - respc(10) + respc(4)})

        --[[ModPanel List]]
        dxDrawText('Jármű név', x + respc(28) + respc(50), y + respc(95) + respc(30), x + respc(28) + respc(50), y + respc(95) + respc(30), tocolor(242, 242, 242, alpha), 1, font5, 'center', 'top')
        dxDrawText('Modell név', x + respc(28) + respc(180), y + respc(95) + respc(30), x + respc(28) + respc(180), y + respc(95) + respc(30), tocolor(242, 242, 242, alpha), 1, font5, 'center', 'top')
        dxDrawText('ID', x + respc(28) + respc(260), y + respc(95) + respc(30), x + respc(28) + respc(260), y + respc(95) + respc(30), tocolor(242, 242, 242, alpha), 1, font5, 'center', 'top')
        dxDrawText('Méret', x + respc(28) + respc(320), y + respc(95) + respc(30), x + respc(28) + respc(320), y + respc(95) + respc(30), tocolor(242, 242, 242, alpha), 1, font5, 'center', 'top')
        dxDrawText('Állapot', x + respc(28) + respc(385), y + respc(95) + respc(30), x + respc(28) + respc(385), y + respc(95) + respc(30), tocolor(242, 242, 242, alpha), 1, font5, 'center', 'top')

        local startX, startY = x + respc(28) + respc(10), y + respc(95) + respc(50)

        modPanelHover = isInSlot(startX, startY, respc(410), ((respc(20) + respc(5)) * 15) - respc(5))

        clickHover = nil
        selectedHover = nil
        for i = modPanelInfoMinLines, modPanelInfoMaxLines do
            local w4, h4 = respc(410), respc(20)

            local inSlot = isInSlot(startX,startY,w4,h4)
            
            local data = modPanelCache[i]
            if modPanelSearchCache then
                data = modPanelSearchCache[i]
            end

            if inSlot or data and modPanelSelected == i then
                dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
            else
                dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
            end
            
            if data then
                if inSlot or modPanelSelected == i then    
                    if inSlot then 
                        selectedHover = i
                    end 

                    dxDrawText(string.gsub(data["name"], "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + respc(5), startY + h4 + respc(4), tocolor(51, 51, 51, alpha), 1, font7, "left", "center", false, false, false, true)
                    dxDrawText(string.gsub(data["defname"], "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(170),startY,startX + respc(170), startY + h4 + respc(4), tocolor(51, 51, 51, alpha), 1, font7, "center", "center", false, false, false, true)
                    dxDrawText(string.gsub(data["id"], "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(250),startY,startX + respc(250), startY + h4 + respc(4), tocolor(51, 51, 51, alpha), 1, font7, "center", "center", false, false, false, true)
                    dxDrawText(string.gsub(data["size"] .. ' MB', "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(310),startY,startX + respc(310), startY + h4 + respc(4), tocolor(51, 51, 51, alpha), 1, font7, "center", "center", false, false, false, true)
                else
                    dxDrawText(data["name"], startX + respc(5),startY,startX + respc(5), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                    dxDrawText(data["defname"], startX + respc(170),startY,startX + respc(170), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "center", "center", false, false, false, true)
                    dxDrawText(data["id"], startX + respc(250),startY,startX + respc(250), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "center", "center", false, false, false, true)
                    dxDrawText(data["size"] .. ' MB', startX + respc(310),startY,startX + respc(310), startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "center", "center", false, false, false, true)
                end

                dxDrawImage(startX + respc(375) - respc(14)/2, startY + h4/2 - respc(14)/2, respc(14), respc(14), "assets/images/checkbox-off.png", 0, 0, 0, tocolor(255, 255, 255, alpha * 0.25))

                if data['state'] then 
                    dxDrawImage(startX + respc(375) - respc(14)/2, startY + h4/2 - respc(14)/2, respc(14), respc(14), "assets/images/checkbox-on.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
                end 

                if isInSlot(startX + respc(375) - respc(14)/2, startY + h4/2 - respc(14)/2, respc(14), respc(14)) then
                    clickHover = i
                end
            end
            
            startY = startY + h4 + respc(5)
        end

        --[[ModPanel Scrollbar]]
        local scrollx, scrolly = x + respc(28) + w3 - respc(3), y + respc(95) + respc(50)
        local scrollh = ((respc(20) + respc(5)) * 15) - respc(5)
        dxDrawRectangle(scrollx, scrolly, respc(3), scrollh, tocolor(242, 242, 242, alpha * 0.6))

        local percent = #modPanelCache
        if modPanelSearchCache then
            percent = #modPanelSearchCache
        end
        
        if modPanelInfoMaxLines > percent then
            modPanelInfoMinLines = 1
            modPanelInfoMaxLines = 15
        end

        if percent >= 1 then
            local gW, gH = respc(3), scrollh
            local gX, gY = scrollx, scrolly

            modPanelScrollingHover = isInSlot(gX, gY, gW, gH)

            if modPanelScrolling then
                if isCursorShowing() then
                    if getKeyState("mouse1") then
                        local cx, cy = exports['cr_core']:getCursorPosition()
                        local cy = math.min(math.max(cy, gY), gY + gH)
                        local y = (cy - gY) / (gH)
                        local num = percent * y
                        modPanelInfoMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 15) + 1)))
                        modPanelInfoMaxLines = modPanelInfoMinLines + (15 - 1)
                    end
                else
                    modPanelScrolling = false
                end
            end

            local multiplier = math.min(math.max((modPanelInfoMaxLines - (modPanelInfoMinLines - 1)) / percent, 0), 1)
            local multiplier2 = math.min(math.max((modPanelInfoMinLines - 1) / percent, 0), 1)
            local gY = gY + ((gH) * multiplier2)
            local gH = gH * multiplier

            dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
        end

        --[[
            ModPanel - Mod Informations
        ]]
        if tonumber(modPanelSelected) then
            local data = modPanelCache[tonumber(modPanelSelected)]
            if modPanelSearchCache then
                data = modPanelSearchCache[tonumber(modPanelSelected)]
            end
            
            if data then
                dxDrawRectangle(x + respc(488), y + respc(95), w3, h3, tocolor(41, 41, 41, alpha * 0.9))
                dxDrawRectangle(x + respc(488) + w3/2 - respc(380)/2, y + respc(95) + respc(190), respc(380), respc(2), tocolor(135, 135, 135, alpha * 0.6))

                dxDrawText('Modell Információk:', x + respc(488) + respc(15), y + respc(95) + respc(10), x + respc(488) + respc(15), y + respc(95) + respc(10), tocolor(242, 242, 242, alpha), 1, font5, 'left', 'top')

                --[[ModPanel - ModInfo List]]
                local id = data['id']

                local data = {
                    "Modell neve: ".. yellow .. data["name"],
                    'Modell id: '.. orange .. data['id'],
                    'TXD Méret: '.. red .. data['txd'] .. ' MB',
                    'DFF Méret: '.. red .. data['dff'] .. ' MB',
                    'Teljes Méret: '.. red .. data['size'] .. ' MB',
                    'Állapot: '.. (data['state'] and green .. 'Bekapcsolva' or red .. 'Kikapcsolva'),
                }

                local startX, startY = x + respc(488) + respc(10), y + respc(95) + respc(30)

                for i = 1, 6 do 
                    local w4, h4 = respc(410), respc(20)

                    local inSlot = isInSlot(startX,startY,w4,h4)
                    if inSlot then
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(242, 242, 242, alpha * 0.8))
                    else
                        dxDrawRectangle(startX,startY,w4,h4, tocolor(51, 51, 51, alpha * 0.6))
                    end
                    
                    if data then
                        if data[i] then
                            local v = data[i]
                            if inSlot then
                                dxDrawText(string.gsub(v, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(51, 51, 51,alpha), 1, font7, "left", "center", false, false, false, true)
                            else
                                dxDrawText(v, startX + respc(5),startY,startX + w4, startY + h4 + respc(4), tocolor(242,242,242,alpha), 1, font7, "left", "center", false, false, false, true)
                            end
                        end
                    end
                    
                    startY = startY + h4 + respc(5)
                end

                dxDrawRectangle(x + respc(488) + respc(40), y + respc(95) + respc(205), respc(350), respc(150), tocolor(23, 23, 23, alpha * 0.8))
                exports['cr_dx']:dxDrawImageAsTexture(x + respc(488) + respc(40) + respc(1), y + respc(95) + respc(205) + respc(1), respc(350) - respc(2), respc(150) - respc(2), ":cr_dashboard/assets/vehicles/"..id..".png", 0, 0, 0, tocolor(255, 255, 255, alpha))

                --[[Modpanel - All Mod buttons]]
                local startY = y + respc(95) + respc(370)

                local buttonW, buttonH = respc(200), respc(20)

                if isInSlot(x + respc(488) + w3/2 - buttonW/2, startY, buttonW, buttonH) then 
                    clickHover = "allIn"

                    dxDrawRectangle(x + respc(488) + w3/2 - buttonW/2, startY, buttonW, buttonH, tocolor(97, 177, 90, alpha)) 
                    dxDrawText('Összes mod bekapcsolása', x + respc(488), startY, x + respc(488) + w3, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
                else
                    dxDrawRectangle(x + respc(488) + w3/2 - buttonW/2, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                    dxDrawText('Összes mod bekapcsolása', x + respc(488), startY, x + respc(488) + w3, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
                end 

                startY = startY + buttonH + respc(5)

                if isInSlot(x + respc(488) + w3/2 - buttonW/2, startY, buttonW, buttonH) then 
                    clickHover = "allOff"

                    dxDrawRectangle(x + respc(488) + w3/2 - buttonW/2, startY, buttonW, buttonH, tocolor(255, 59, 59, alpha)) 
                    dxDrawText('Összes mod kikapcsolása', x + respc(488), startY, x + respc(488) + w3, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
                else
                    dxDrawRectangle(x + respc(488) + w3/2 - buttonW/2, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                    dxDrawText('Összes mod kikapcsolása', x + respc(488), startY, x + respc(488) + w3, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
                end 
            end 
        end 
    end 
end

lastClickTick = -500
lastClickHoverTick = -500

addEventHandler("onClientClick", root,
    function(b, s)
        if b == "middle" and s == "down" then
            if state then
                if cache['page'] == 2 then
                    if vehHover then
                        local e = playerVehicles[vehHover]
                        if e then
                            local data = playerVehiclesData[e]
                            if data then
                                local id = data["id"]
                                local blue = exports['cr_core']:getServerColor("yellow", true)
                                local white = "#F2F2F2"
                                local oneSlotPrice = 20
                                
                                local r,g,b = exports['cr_core']:getServerColor("green")
                                local r2,g2,b2 = exports['cr_core']:getServerColor("red")
                                createAlert(
                                    {
                                        ['headerText'] = 'Jármű GPS',
                                        ["title"] = {white .. "Biztosan megszeretnéd jelölni a(z) "..blue..id..white.." idjű járművet a térképen?", 1},
                                        ["buttons"] = {
                                            {
                                                ["name"] = "Igen", 
                                                ["pressFunc"] = function()
                                                    executeCommandHandler("gpskocsi", id)
                                                end,
                                                ["color"] = {r, g, b},
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
                        end
                        vehHover = nil
                    end
                    
                    if intHover then
                        local e = playerInterior[intHover]
                        if e then
                            local data = playerInteriorData[e]
                            if data then
                                local id = data["id"]
                                local blue = exports['cr_core']:getServerColor("yellow", true)
                                local white = "#F2F2F2"
                                local oneSlotPrice = 20
                                
                                local r,g,b = exports['cr_core']:getServerColor("green")
                                local r2,g2,b2 = exports['cr_core']:getServerColor("red")
                                createAlert(
                                    {
                                        ['headerText'] = 'Ingatlan GPS',
                                        ["title"] = {white .. "Biztosan megszeretnéd jelölni a(z) "..blue..id..white.." idjű ingatlant a térképen?", 1},
                                        ["buttons"] = {
                                            {
                                                ["name"] = "Igen", 
                                                ["pressFunc"] = function()
                                                    executeCommandHandler("gpsinterior", id)
                                                end,
                                                ["color"] = {r, g, b},
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
                        end
                        intHover = nil
                    end
                elseif cache["page"] == 8 then 
                    if tonumber(optionsFunctionHover) then 
                        local data = options[optionsSelected]["options"]
                        if data[optionsFunctionHover] then 
                            local now = getTickCount()
                            if now <= lastClickTick + 250 then
                                return
                            end
                                
                            if isDescEditing or groupRenaming or groupCreating or isPickerRender or factionMessageEditing then
                                return
                            end
                            
                            local val = data[optionsFunctionHover] 
                            if val["nowValue"] ~= defaultOptions[val["optionName"]] then 
                                playSound("assets/sounds/click.mp3")
                                lastClickTick = now
                            
                                local optionsSelected, optionsFunctionHover = optionsSelected, optionsFunctionHover -- mta hotfix
                                local blue = exports['cr_core']:getServerColor("yellow", true)
                                local white = "#F2F2F2"
                                local oneSlotPrice = 20
                                
                                local r,g,b = exports['cr_core']:getServerColor("green")
                                local r2,g2,b2 = exports['cr_core']:getServerColor("red")
                                createAlert(
                                    {
                                        ['headerText'] = 'Beállítások',
                                        ["title"] = {white .. "Biztosan alapértékre szeretnéd állítani a következő beállítást: "..blue..val["name"]..white.."?", 1},
                                        ["buttons"] = {
                                            {
                                                ["name"] = "Igen", 
                                                ["pressFunc"] = function()
                                                    options[optionsSelected]["options"][optionsFunctionHover]["nowValue"] = defaultOptions[val["optionName"]]
                                                    if options[optionsSelected]["options"][optionsFunctionHover]["onChange"] then 
                                                        options[optionsSelected]["options"][optionsFunctionHover]["onChange"](oldValue, options[optionsSelected]["options"][optionsFunctionHover]["nowValue"])
                                                    end 
                                                end,
                                                ["color"] = {r, g, b},
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
                        end 
                        optionsFunctionHover = nil 
                    end
                end
            end
        elseif b == "left" and s == "down" then
            if state then
                if tonumber(hover) then
                    local now = getTickCount()
                    if now <= lastClickTick + 250 then
                        return
                    end
                        
                    if isDescEditing or groupRenaming or groupCreating or isPickerRender or factionMessageEditing then
                        return
                    end
                    
                    local i = tonumber(hover)
                    buttonAnimation[cache['page']] = {getTickCount(), 2}
                    buttonAnimation[i + 1] = {getTickCount(), 1}

                    if (cache['page'] - 1) > 0 then 
                        menus[cache["page"] - 1][5](i)
                    end 

                    if i > 0 then
                        menus[i][4](i)
                    else 
                        cache['page'] = 1
                    end 
                    
                    playSound("assets/sounds/click.mp3")
                    lastClickTick = now
                elseif closeHover then 
                    if start then 
                        openDash(cache['element'], cache['page'])
                    end

                    closeHover = nil
                elseif cache['page'] == 1 then
                    if hover == "FactionLeft" then
                        selectedFaction = selectedFaction - 1
                        
                        if selectedFaction <= 0 then
                            selectedFaction = #cache["playerDatas"]["faction"]
                        end
                    elseif hover == "FactionRight" then
                        selectedFaction = selectedFaction + 1
                        
                        if selectedFaction > #cache["playerDatas"]["faction"] then
                            selectedFaction = 1
                        end    
                    elseif hover == "Edit" and cache["element"] == localPlayer then
                        local now = getTickCount()
                        if now <= lastClickTick + 250 then
                            return
                        end
                        
                        if not isDescEditing then
                            --Karakter leírás szerkesztése
                            startDescriptionEdit()
                        else
                            endDescriptionEdit()
                        end
                        
                        playSound("assets/sounds/click.mp3")
                        lastClickTick = now
                    end
                elseif cache['page'] == 2 then
                    if VehicleScrollingHover then
                        VehicleScrolling = true
                        VehicleScrollingHover = false
                    elseif InteriorScrollingHover then
                        InteriorScrolling = true
                        InteriorScrollingHover = false
                    elseif VehicleInfoScrollingHover then
                        VehicleInfoScrolling = true
                        VehicleInfoScrollingHover = false
                    elseif InteriorInfoScrollingHover then
                        InteriorInfoScrolling = true
                        InteriorInfoScrollingHover = false
                    end

                    if intSellHover then 
                        local now = getTickCount()
                        if now <= lastClickTick + 1000 then
                            return
                        end
                        lastClickTick = getTickCount()

                        if exports['cr_network']:getNetworkStatus() then
                            return
                        end
                        
                        if tonumber(intSelected) then
                            if playerInterior[intSelected] and playerInteriorData[playerInterior[intSelected]] then
                                local blue = exports['cr_core']:getServerColor('yellow', true)
                                local white = "#F2F2F2"
                                
                                local r,g,b = exports['cr_core']:getServerColor("green")
                                local r2,g2,b2 = exports['cr_core']:getServerColor("red")

                                local intName = playerInteriorData[playerInterior[intSelected]]['name'] or 'Ismeretlen'
                                
                                createAlert(
                                    {
                                        ['headerText'] = 'Ingatlan Eladás',
                                        ["title"] = {white .. "Szeretnéd eladni a következő ingatlant: "..blue..intName..white.."?", 1},
                                        ["buttons"] = {
                                            {
                                                ["name"] = "Igen", 
                                                ["onCreate"] = function()
                                                    intSelected = intSelected
                                                end,
                                                ["pressFunc"] = function()
                                                    createAlert(
                                                        {
                                                            ['headerText'] = 'Ingatlan Eladás',
                                                            ['title'] = {white .. "Gépeld be "..blue.. "kinek" ..white.." szeretnéd illetve "..blue.. "mennyiért" ..white.." szeretnéd eladni az ingatlant?", 1},
                                                            ['buttons'] = {
                                                                {
                                                                    ["type"] = "outputBox",
                                                                    ["color"] = {r, g, b},
                                                                    ["boxName"] = "targetPlayer",
                                                                    ["onCreate"] = function()
                                                                        CreateNewBar("targetPlayer", {0, 0, 0, 0}, {30, "", false, tocolor(242, 242, 242, 255), {'Poppins-Bold', 12}, 1, "center", "center", false, true}, 1, true)
                                                                    end,
                                                                },

                                                                {
                                                                    ["type"] = "outputBox",
                                                                    ["color"] = {r, g, b},
                                                                    ["boxName"] = "targetPrice",
                                                                    ["onCreate"] = function()
                                                                        CreateNewBar("targetPrice", {0, 0, 0, 0}, {10, "", true, tocolor(242, 242, 242, 255), {'Poppins-Bold', 12}, 1, "center", "center", false, true}, 1, true)
                                                                    end,
                                                                },
                                            
                                                                {
                                                                    ["name"] = "Tovább", 
                                                                    ["pressFunc"] = function()
                                                                        local targetPlayerName = GetText("targetPlayer")
                                                                        local targetPlayer = exports['cr_core']:findPlayer(localPlayer, targetPlayerName)
                                                                        local targetPrice = tonumber(GetText('targetPrice'))

                                                                        if targetPlayerName and targetPlayer and targetPrice then 
                                                                            if targetPlayer == localPlayer then 
                                                                                resetStartTickAlert()
                                                                                exports['cr_infobox']:addBox("error", "Nem adhatod meg saját magad!")

                                                                                return
                                                                            end 

                                                                            if not targetPlayer:getData('loggedIn') then 
                                                                                resetStartTickAlert()
                                                                                exports['cr_infobox']:addBox("error", "A célpont be kell hogy legyen jelentkezve!")

                                                                                return
                                                                            end 

                                                                            if getDistanceBetweenPoints3D(targetPlayer.position, localPlayer.position) > 25 then 
                                                                                resetStartTickAlert()
                                                                                exports['cr_infobox']:addBox("error", "A célpont túl messze van!")

                                                                                return 
                                                                            end 

                                                                            if targetPrice <= 0 then 
                                                                                resetStartTickAlert()
                                                                                exports['cr_infobox']:addBox("error", "Az árnak nagyobbnak kell lennie mint 0!")

                                                                                return
                                                                            end 

                                                                            RemoveBar("targetPlayer")
                                                                            RemoveBar("targetPrice")
                                            
                                                                            local targetPlayerName = exports['cr_admin']:getAdminName(targetPlayer)
                                                                            local intName = playerInteriorData[playerInterior[intSelected]]['name'] or 'Ismeretlen'

                                                                            local green = exports['cr_core']:getServerColor('green', true)

                                                                            createAlert(
                                                                                {
                                                                                    ['headerText'] = 'Ingatlan Eladás',
                                                                                    ["title"] = {white .. "Biztosan elszeretnéd adni a(z) "..blue..intName..white.." nevű ingatlant "..blue..targetPlayerName..white.."-nak/nek "..green.."$ "..targetPrice..white.."-ért?", 1},
                                                                                    ["buttons"] = {
                                                                                        {
                                                                                            ["name"] = "Igen", 
                                                                                            ["onCreate"] = function()
                                                                                                targetPlayer = targetPlayer
                                                                                                targetPrice = targetPrice
                                                                                            end,
                                                                                            ["pressFunc"] = function()
                                                                                                exports.cr_propertytransfer:showPropertyTransfer(playerInterior[intSelected], targetPlayer, targetPrice)
                                                                                            end,
                                                                                            ["color"] = {r, g, b},
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
                                                                        else
                                                                            resetStartTickAlert()
                                                                            exports['cr_infobox']:addBox("error", "Nincs találat "..targetPlayerName.."-ra/re!")
                                                                        end
                                                                    end,
                                                                    ["color"] = {r, g, b},
                                                                },
                                            
                                                                {
                                                                    ["name"] = "Mégse", 
                                                                    ["onClear"] = true,
                                                                    ["pressFunc"] = function()
                                                                        RemoveBar("targetPlayer")
                                                                        RemoveBar("targetPrice")
                                                                    end,
                                                                    ["color"] = {r2, g2, b2},
                                                                },
                                                            }
                                                        }
                                                    )
                                                end,
                                                ["color"] = {r, g, b},
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
                        end 
                        
                        intSellHover = nil 
                        return 
                    end 

                    if vehSellHover then 
                        local now = getTickCount()
                        if now <= lastClickTick + 1000 then
                            return
                        end
                        lastClickTick = getTickCount()

                        if exports['cr_network']:getNetworkStatus() then
                            return
                        end

                        if tonumber(vehSelected) then
                            if playerVehicles[vehSelected] and playerVehiclesData[playerVehicles[vehSelected]] then
                                local blue = exports['cr_core']:getServerColor('yellow', true)
                                local white = "#F2F2F2"
                                
                                local r,g,b = exports['cr_core']:getServerColor("green")
                                local r2,g2,b2 = exports['cr_core']:getServerColor("red")

                                local vehName = playerVehiclesData[playerVehicles[vehSelected]]['name'] or 'Ismeretlen'
                                
                                createAlert(
                                    {
                                        ['headerText'] = 'Jármű Eladás',
                                        ["title"] = {white .. "Szeretnéd eladni a következő járművet: "..blue..vehName..white.."?", 1},
                                        ["buttons"] = {
                                            {
                                                ["name"] = "Igen", 
                                                ["onCreate"] = function()
                                                    vehSelected = vehSelected
                                                end,
                                                ["pressFunc"] = function()
                                                    createAlert(
                                                        {
                                                            ['headerText'] = 'Jármű Eladás',
                                                            ['title'] = {white .. "Gépeld be "..blue.. "kinek" ..white.." szeretnéd illetve "..blue.. "mennyiért" ..white.." szeretnéd eladni a járművet?", 1},
                                                            ['buttons'] = {
                                                                {
                                                                    ["type"] = "outputBox",
                                                                    ["color"] = {r, g, b},
                                                                    ["boxName"] = "targetPlayer",
                                                                    ["onCreate"] = function()
                                                                        CreateNewBar("targetPlayer", {0, 0, 0, 0}, {30, "", false, tocolor(242, 242, 242, 255), {'Poppins-Bold', 12}, 1, "center", "center", false, true}, 1, true)
                                                                    end,
                                                                },

                                                                {
                                                                    ["type"] = "outputBox",
                                                                    ["color"] = {r, g, b},
                                                                    ["boxName"] = "targetPrice",
                                                                    ["onCreate"] = function()
                                                                        CreateNewBar("targetPrice", {0, 0, 0, 0}, {10, "", true, tocolor(242, 242, 242, 255), {'Poppins-Bold', 12}, 1, "center", "center", false, true}, 1, true)
                                                                    end,
                                                                },
                                            
                                                                {
                                                                    ["name"] = "Tovább", 
                                                                    ["pressFunc"] = function()
                                                                        local targetPlayerName = GetText("targetPlayer")
                                                                        local targetPlayer = exports['cr_core']:findPlayer(localPlayer, targetPlayerName)
                                                                        local targetPrice = tonumber(GetText('targetPrice'))

                                                                        if targetPlayerName and targetPlayer and targetPrice then 
                                                                            if targetPlayer == localPlayer then 
                                                                                resetStartTickAlert()
                                                                                exports['cr_infobox']:addBox("error", "Nem adhatod meg saját magad!")

                                                                                return
                                                                            end 

                                                                            if not targetPlayer:getData('loggedIn') then 
                                                                                resetStartTickAlert()
                                                                                exports['cr_infobox']:addBox("error", "A célpont be kell hogy legyen jelentkezve!")

                                                                                return
                                                                            end 

                                                                            if getDistanceBetweenPoints3D(targetPlayer.position, localPlayer.position) > 25 then 
                                                                                resetStartTickAlert()
                                                                                exports['cr_infobox']:addBox("error", "A célpont túl messze van!")

                                                                                return 
                                                                            end 

                                                                            if targetPrice <= 0 then 
                                                                                resetStartTickAlert()
                                                                                exports['cr_infobox']:addBox("error", "Az árnak nagyobbnak kell lennie mint 0!")

                                                                                return
                                                                            end 

                                                                            RemoveBar("targetPlayer")
                                                                            RemoveBar("targetPrice")
                                            
                                                                            local targetPlayerName = exports['cr_admin']:getAdminName(targetPlayer)
                                                                            local vehName = playerVehiclesData[playerVehicles[vehSelected]]['name'] or 'Ismeretlen'

                                                                            local green = exports['cr_core']:getServerColor('green', true)

                                                                            createAlert(
                                                                                {
                                                                                    ['headerText'] = 'Jármű Eladás',
                                                                                    ["title"] = {white .. "Biztosan elszeretnéd adni a(z) "..blue..vehName..white.." nevű járművet "..blue..targetPlayerName..white.."-nak/nek "..green.."$ "..targetPrice..white.."-ért?", 1},
                                                                                    ["buttons"] = {
                                                                                        {
                                                                                            ["name"] = "Igen", 
                                                                                            ["onCreate"] = function()
                                                                                                targetPlayer = targetPlayer
                                                                                                targetPrice = targetPrice
                                                                                            end,
                                                                                            ["pressFunc"] = function()
                                                                                                exports.cr_propertytransfer:showPropertyTransfer(playerVehicles[vehSelected], targetPlayer, targetPrice)
                                                                                            end,
                                                                                            ["color"] = {r, g, b},
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
                                                                        else
                                                                            resetStartTickAlert()
                                                                            exports['cr_infobox']:addBox("error", "Nincs találat "..targetPlayerName.."-ra/re!")
                                                                        end
                                                                    end,
                                                                    ["color"] = {r, g, b},
                                                                },
                                            
                                                                {
                                                                    ["name"] = "Mégse", 
                                                                    ["onClear"] = true,
                                                                    ["pressFunc"] = function()
                                                                        RemoveBar("targetPlayer")
                                                                        RemoveBar("targetPrice")
                                                                    end,
                                                                    ["color"] = {r2, g2, b2},
                                                                },
                                                            }
                                                        }
                                                    )
                                                end,
                                                ["color"] = {r, g, b},
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
                        end 

                        vehSellHover = nil 
                        return
                    end 
                    
                    if buyHover then 
                        local now = getTickCount()
                        if now <= lastClickTick + 1000 then
                            return
                        end
                        lastClickTick = getTickCount()

                        if exports['cr_network']:getNetworkStatus() then
                            return
                        end
                        
                        if buyHover == "buyInt" then
                            if (tonumber(GetText("IntSlot >> buy")) or 0) >= 1 then
                                local slots = tonumber(GetText("IntSlot >> buy"))
                                local blue = exports['cr_core']:getServerColor('yellow', true)
                                local white = "#F2F2F2"
                                local oneSlotPrice = 20
                                
                                local r,g,b = exports['cr_core']:getServerColor("green")
                                local r2,g2,b2 = exports['cr_core']:getServerColor("red")
                                createAlert(
                                    {
                                        ['headerText'] = 'Ingatlan Slot',
                                        ["title"] = {white .. "Szeretnél vásárolni "..blue..slots..white.." ingatlan slotot "..blue..(slots * oneSlotPrice)..white.." prémiumpontért cserébe?", 1},
                                        ["buttons"] = {
                                            {
                                                ["name"] = "Igen", 
                                                ["pressFunc"] = function()
                                                    menus[cache["page"] - 1][5](i)
                                                    menus[cache["page"] - 1][4](i)

                                                    local pp = tonumber(localPlayer:getData("char >> premiumPoints")) or 0
                                                    local intLimit = tonumber(localPlayer:getData("char >> interiorLimit")) or 0
                                                    if pp >= (slots * oneSlotPrice) then
                                                        localPlayer:setData("char >> premiumPoints", pp - (slots * oneSlotPrice))
                                                        localPlayer:setData("char >> interiorLimit", intLimit + (slots))
                                                        exports['cr_infobox']:addBox("success", "Sikeresen vásároltál "..slots.." ingatlan slotot!")
                                                    else
                                                        exports['cr_infobox']:addBox("error", "Nincs elengedő PP-d ahhoz, hogy "..slots.." ingatlan slotot vásárolj ("..(slots * oneSlotPrice).." PP)")
                                                    end
                                                end,
                                                ["color"] = {r, g, b},
                                            },
                                            {
                                                ["name"] = "Nem", 
                                                ["onClear"] = true,
                                                ["pressFunc"] = function()
                                                    menus[cache["page"] - 1][5](i)
                                                    menus[cache["page"] - 1][4](i)
                                                end,
                                                ["color"] = {r2, g2, b2},
                                            },
                                        },
                                    }
                                )
                                Clear()
                            end
                        elseif buyHover == "buyVeh" then
                            if (tonumber(GetText("VehSlot >> buy")) or 0) >= 1 then
                                local slots = tonumber(GetText("VehSlot >> buy"))
                                local blue = exports['cr_core']:getServerColor('yellow', true)
                                local white = "#F2F2F2"
                                local oneSlotPrice = 50
                                
                                local r,g,b = exports['cr_core']:getServerColor("green")
                                local r2,g2,b2 = exports['cr_core']:getServerColor("red")
                                createAlert(
                                    {
                                        ['headerText'] = 'Jármű Slot',
                                        ["title"] = {white .. "Szeretnél vásárolni "..blue..slots..white.." jármű slotot "..blue..(slots * oneSlotPrice)..white.." prémiumpontért cserébe?", 1},
                                        ["buttons"] = {
                                            {
                                                ["name"] = "Igen", 
                                                ["pressFunc"] = function()
                                                    menus[cache["page"] - 1][5](i)
                                                    menus[cache["page"] - 1][4](i)

                                                    local pp = tonumber(localPlayer:getData("char >> premiumPoints")) or 0
                                                    local intLimit = tonumber(localPlayer:getData("char >> vehicleLimit")) or 0
                                                    if pp >= (slots * oneSlotPrice) then
                                                        localPlayer:setData("char >> premiumPoints", pp - (slots * oneSlotPrice))
                                                        localPlayer:setData("char >> vehicleLimit", intLimit + (slots))
                                                        exports['cr_infobox']:addBox("success", "Sikeresen vásároltál "..slots.." jármű slotot!")
                                                    else
                                                        exports['cr_infobox']:addBox("error", "Nincs elengedő PP-d ahhoz, hogy "..slots.." jármű slotot vásárolj ("..(slots * oneSlotPrice).." PP)")
                                                    end
                                                end,
                                                ["color"] = {r, g, b},
                                            },
                                            {
                                                ["name"] = "Nem", 
                                                ["onClear"] = true,
                                                ["pressFunc"] = function()
                                                    menus[cache["page"] - 1][5](i)
                                                    menus[cache["page"] - 1][4](i)
                                                end,
                                                ["color"] = {r2, g2, b2},
                                            },
                                        },
                                    }
                                )
                                Clear()
                            end
                        end
                        buyHover = nil
                    end
                        
                    if vehHover then
                        local e = playerVehicles[vehHover]
                        if e then 
                            if vehSelected ~= vehHover then
                                vehSelected = vehHover
                                if e then
                                    generateVehicleInformations(e)
                                end
                            else
                                vehSelected = nil
                                playerVehicleInfos = {}
                            end
                        end
                        vehHover = nil
                    end
                    
                    if intHover then
                        local e = playerInterior[intHover]
                        if e then 
                            if intSelected ~= intHover then
                                intSelected = intHover
                                local e = playerInterior[intHover]
                                if e then
                                    generateInteriorInformations(e)
                                end
                            else
                                intSelected = nil
                                playerInteriorInfos = {}
                            end
                        end
                        intHover = nil
                    end
                elseif cache["page"] == 3 then
                    if tonumber(factionRanksButtonHover) then 
                        local now = getTickCount()
                        if now <= lastClickTick + 1000 then
                            return
                        end

                        lastClickTick = getTickCount()
                        playSound("assets/sounds/click.mp3")

                        if exports['cr_network']:getNetworkStatus() then
                            return
                        end

                        if cache["element"] ~= localPlayer then 
                            return 
                        end 
                            
                        if isDescEditing or groupRenaming or groupCreating or isPickerRender or factionMessageEditing then
                            return
                        end
                        

                        if factionRanksButtonHover == 1 then -- Rang átnevezése
                            if cache["playerDatas"]["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 0 and not hasPlayerPermission(cache["element"]:getData("acc >> id"), cache["playerDatas"]["faction"][selectedFaction][1], "faction.renamerank") then 
                                exports['cr_infobox']:addBox("warning", "Neked ehhez nincs jogosultságod")
                                return 
                            end 

                            local data = cache["playerDatas"]["faction"][selectedFaction][4][factionRanksSelected]
                            if factionMembersSearchCache and #factionMembersSearchCache >= 1 then 
                                data = factionMembersSearchCache[factionRanksSelected]
                            end 

                            local rankID = -1
                            for k,v in pairs(cache["playerDatas"]["faction"][selectedFaction][4]) do 
                                if v["name"]:lower() == data["name"]:lower() then 
                                    rankID = k
                                end 
                            end 

                            if rankID >= 1 then 
                                local blue = exports['cr_core']:getServerColor("yellow", true)
                                local white = "#F2F2F2"
                                local r,g,b = exports['cr_core']:getServerColor("green")
                                local r2,g2,b2 = exports['cr_core']:getServerColor("red")
    
                                createAlert(
                                    {
                                        ['headerText'] = 'Rangok',
                                        ["title"] = {white .. "Gépeld be a "..blue.."rang"..white.." új nevét!", 1},
                                        ["buttons"] = {
                                            {
                                                ["type"] = "outputBox",
                                                ["color"] = {r, g, b},
                                                ["boxName"] = "RankNameBox",
                                                ["onCreate"] = function()
                                                    rankID = rankID
                                                    CreateNewBar("RankNameBox", {0, 0, 0, 0}, {20, "", false, tocolor(242, 242, 242, 255), {"Poppins-Medium", 12}, 1, "center", "center", false, true}, 1, true)
                                                end,
                                            },
    
                                            {
                                                ["name"] = "Tovább", 
                                                ["pressFunc"] = function()
                                                    text = GetText("RankNameBox")
                                                    if #text < 2 then
                                                        resetStartTickAlert()
                                                        exports['cr_infobox']:addBox("warning", "A rang nevének 2 karakternek kell legyen minimum!")
                                                    else
                                                        RemoveBar("RankNameBox")
                                                        triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(localPlayer) .. " #F2F2F2átnevezte a ".. exports['cr_core']:getServerColor('yellow', true) .. cache["playerDatas"]["faction"][selectedFaction][4][rankID]["name"] .. " #F2F2F2nevű rangot ".. exports['cr_core']:getServerColor('yellow', true) .. text .. "#F2F2F2-ra/re !")
                                                        triggerLatentServerEvent("updateRankName", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], rankID, text)
                                                        exports['cr_infobox']:addBox("success", "Sikeresen átnevezted a rangot!")
                                                    end
                                                end,
                                                ["color"] = {r, g, b},
                                            },
    
                                            {
                                                ["name"] = "Mégse", 
                                                ["onClear"] = true,
                                                ["pressFunc"] = function()
                                                    RemoveBar("RankNameBox")
                                                end,
                                                ["color"] = {r2, g2, b2},
                                            },
                                        },
                                    }
                                )
                            end 

                            factionRanksButtonHover = nil 
                        elseif factionRanksButtonHover == 2 then -- Rang törlése
                            if cache["playerDatas"]["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 0 and not hasPlayerPermission(cache["element"]:getData("acc >> id"), cache["playerDatas"]["faction"][selectedFaction][1], "faction.removerank") then 
                                exports['cr_infobox']:addBox("warning", "Neked ehhez nincs jogosultságod")
                                return 
                            end 

                            local data = cache["playerDatas"]["faction"][selectedFaction][4][factionRanksSelected]
                            if factionMembersSearchCache and #factionMembersSearchCache >= 1 then 
                                data = factionMembersSearchCache[factionRanksSelected]
                            end 

                            local rankID = -1
                            for k,v in pairs(cache["playerDatas"]["faction"][selectedFaction][4]) do 
                                if v["name"]:lower() == data["name"]:lower() then 
                                    rankID = k
                                end 
                            end 

                            if rankID >= 1 then 
                                if #cache["playerDatas"]["faction"][selectedFaction][4] >= 2 then 
                                    local blue = exports['cr_core']:getServerColor("yellow", true)
                                    local red = exports['cr_core']:getServerColor("red", true)
                                    local white = "#F2F2F2"
                                    local r,g,b = exports['cr_core']:getServerColor("green")
                                    local r2,g2,b2 = exports['cr_core']:getServerColor("red")

                                    createAlert(
                                        {
                                            ['headerText'] = 'Rangok',
                                            ["title"] = {white .. "Biztosan kiszeretnéd törölni a "..blue..data["name"]..white.." nevű rangot?"},
                                            ["buttons"] = {
                                                {
                                                    ["name"] = "Igen", 
                                                    ["pressFunc"] = function()
                                                        exports['cr_infobox']:addBox("success", "Sikeresen törölted a kijelölt rangot!")
                                                        triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(localPlayer) .. " #F2F2F2kitörölte a ".. exports['cr_core']:getServerColor('yellow', true) .. cache["playerDatas"]["faction"][selectedFaction][4][rankID]["name"] .. " #F2F2F2nevű rangot!")
                                                        triggerLatentServerEvent("factionRemoveRank", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], rankID)
                                                    end,
                                                    ["onCreate"] = function()
                                                        rankID = rankID
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
                                else 
                                    exports['cr_infobox']:addBox("error", "Minimum 1 rangnak kell lennie!")
                                end 
                            end 

                            factionRanksButtonHover = nil 
                        elseif factionRanksButtonHover == 3 then -- Fizetés módosítása
                            if cache["playerDatas"]["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 0 and not hasPlayerPermission(cache["element"]:getData("acc >> id"), cache["playerDatas"]["faction"][selectedFaction][1], "faction.editrankpayment") then 
                                exports['cr_infobox']:addBox("warning", "Neked ehhez nincs jogosultságod")
                                return 
                            end 

                            local data = cache["playerDatas"]["faction"][selectedFaction][4][factionRanksSelected]
                            if factionMembersSearchCache and #factionMembersSearchCache >= 1 then 
                                data = factionMembersSearchCache[factionRanksSelected]
                            end 

                            local rankID = -1
                            for k,v in pairs(cache["playerDatas"]["faction"][selectedFaction][4]) do 
                                if v["name"]:lower() == data["name"]:lower() then 
                                    rankID = k
                                end 
                            end 

                            if rankID >= 1 then 
                                local blue = exports['cr_core']:getServerColor("yellow", true)
                                local white = "#F2F2F2"
                                local r,g,b = exports['cr_core']:getServerColor("green")
                                local r2,g2,b2 = exports['cr_core']:getServerColor("red")
    
                                createAlert(
                                    {
                                        ['headerText'] = 'Rangok',
                                        ["title"] = {white .. "Gépeld be a "..blue.."rang"..white.." új fizetését!", 1},
                                        ["buttons"] = {
                                            {
                                                ["type"] = "outputBox",
                                                ["color"] = {r, g, b},
                                                ["boxName"] = "RankMoneyBox",
                                                ["specIcon"] = "cash",
                                                ["onCreate"] = function()
                                                    rankID = rankID
                                                    CreateNewBar("RankMoneyBox", {0, 0, 0, 0}, {14, "0", true, tocolor(242, 242, 242, 255), {"Poppins-Medium", 12}, 1, "center", "center", false, true}, 1, true)
                                                end,
                                            },
    
                                            {
                                                ["name"] = "Tovább", 
                                                ["pressFunc"] = function()
                                                    text = GetText("RankMoneyBox")
                                                    if not tonumber(text) or tonumber(text) < 0 then
                                                        resetStartTickAlert()
                                                        exports['cr_infobox']:addBox("warning", "A fizetésnek egy számnak kell lennie mely nagyobb vagy egyenlő mint 0!")
                                                    else
                                                        RemoveBar("RankMoneyBox")
                                                        triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(localPlayer) .. " #F2F2F2megváltoztatta a ".. exports['cr_core']:getServerColor('yellow', true) .. cache["playerDatas"]["faction"][selectedFaction][4][rankID]["name"] .. " #F2F2F2nevű rang fizetését ".. exports['cr_core']:getServerColor("green", true) .. cache["playerDatas"]["faction"][selectedFaction][4][rankID]["payment"] .. " $#F2F2F2-ról " .. exports['cr_core']:getServerColor("green", true) .. tonumber(text) .. " $#F2F2F2-ra!")
                                                        triggerLatentServerEvent("updateRankPayment", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], rankID, tonumber(text))
                                                        exports['cr_infobox']:addBox("success", "Sikeresen megváltoztattad a rang fizetését!")
                                                    end
                                                end,
                                                ["color"] = {r, g, b},
                                            },
    
                                            {
                                                ["name"] = "Mégse", 
                                                ["onClear"] = true,
                                                ["pressFunc"] = function()
                                                    RemoveBar("RankMoneyBox")
                                                end,
                                                ["color"] = {r2, g2, b2},
                                            },
                                        },
                                    }
                                )
                            end 

                            factionRanksButtonHover = nil 
                        elseif factionRanksButtonHover == 4 then -- Új rang hozzáadása
                            if cache["playerDatas"]["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 0 and not hasPlayerPermission(cache["element"]:getData("acc >> id"), cache["playerDatas"]["faction"][selectedFaction][1], "faction.addrank") then 
                                exports['cr_infobox']:addBox("warning", "Neked ehhez nincs jogosultságod")
                                return 
                            end 

                            local blue = exports['cr_core']:getServerColor("yellow", true)
                            local white = "#F2F2F2"
                            local r,g,b = exports['cr_core']:getServerColor("green")
                            local r2,g2,b2 = exports['cr_core']:getServerColor("red")
                            
                            if #cache["playerDatas"]["faction"][selectedFaction][4] + 1 <= 50 then 
                                createAlert(
                                    {
                                        ['headerText'] = 'Rangok',
                                        ["title"] = {white .. "Gépeld be az "..blue.."új rang"..white.." adatait!", 1},
                                        ["buttons"] = {
                                            {
                                                ["type"] = "outputBox",
                                                ["color"] = {r, g, b},
                                                ["boxName"] = "RankNameBox",
                                                ["onCreate"] = function()
                                                    CreateNewBar("RankNameBox", {0, 0, 0, 0}, {20, "", false, tocolor(242, 242, 242, 255), {"Poppins-Medium", 12}, 1, "center", "center", false, true}, 1, true)
                                                end,
                                            },

                                            {
                                                ["type"] = "outputBox",
                                                ["color"] = {r, g, b},
                                                ["boxName"] = "RankMoneyBox",
                                                ["specIcon"] = "cash",
                                                ["onCreate"] = function()
                                                    CreateNewBar("RankMoneyBox", {0, 0, 0, 0}, {14, "0", true, tocolor(242, 242, 242, 255), {"Poppins-Medium", 12}, 1, "center", "center", false, true}, 1, true)
                                                end,
                                            },

                                            {
                                                ["name"] = "Tovább", 
                                                ["pressFunc"] = function()
                                                    name = GetText("RankNameBox")
                                                    if #name < 2 then
                                                        resetStartTickAlert()
                                                        exports['cr_infobox']:addBox("warning", "A rang nevének 2 karakternek kell legyen minimum!")
                                                    else
                                                        payment = GetText("RankMoneyBox")
                                                        if not tonumber(payment) or tonumber(payment) < 0 then
                                                            resetStartTickAlert()
                                                            exports['cr_infobox']:addBox("warning", "A fizetésnek egy számnak kell lennie mely nagyobb vagy egyenlő mint 0!")
                                                        else
                                                            RemoveBar("RankNameBox")
                                                            RemoveBar("RankMoneyBox")
                                                            triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(localPlayer) .. " #F2F2F2létrehozott egy új rangot (Név: " .. exports['cr_core']:getServerColor('yellow', true) .. name .. "#F2F2F2, Fizetés: " .. exports['cr_core']:getServerColor("green", true) .. tonumber(payment) .. " $#F2F2F2)")
                                                            triggerLatentServerEvent("factionAddRank", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], name, tonumber(payment))
                                                            exports['cr_infobox']:addBox("success", "Sikeresen létrehoztad a rangot!")
                                                        end
                                                    end 
                                                end,
                                                ["color"] = {r, g, b},
                                            },

                                            {
                                                ["name"] = "Mégse", 
                                                ["onClear"] = true,
                                                ["pressFunc"] = function()
                                                    RemoveBar("RankNameBox")
                                                    RemoveBar("RankMoneyBox")
                                                end,
                                                ["color"] = {r2, g2, b2},
                                            },
                                        },
                                    }
                                )
                            else
                                exports['cr_infobox']:addBox("error", "Maximum 50 rang!")
                            end 

                            factionRanksButtonHover = nil 
                        elseif factionRanksButtonHover == 5 then -- sorrend le
                            if cache["playerDatas"]["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 0 and not hasPlayerPermission(cache["element"]:getData("acc >> id"), cache["playerDatas"]["faction"][selectedFaction][1], "faction.sortdown") then 
                                exports['cr_infobox']:addBox("warning", "Neked ehhez nincs jogosultságod")
                                return 
                            end 

                            local data = cache["playerDatas"]["faction"][selectedFaction][4][factionRanksSelected]
                            if factionMembersSearchCache and #factionMembersSearchCache >= 1 then 
                                data = factionMembersSearchCache[factionRanksSelected]
                            end 

                            local rankID = -1
                            for k,v in pairs(cache["playerDatas"]["faction"][selectedFaction][4]) do 
                                if v["name"]:lower() == data["name"]:lower() then 
                                    rankID = k
                                end 
                            end 

                            if rankID >= 1 then 
                                if rankID + 1 <= #cache["playerDatas"]["faction"][selectedFaction][4] then 
                                    factionRanksUpdated = rankID + 1
                                    triggerLatentServerEvent("sortRankDown", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], rankID)
                                else 
                                    exports['cr_infobox']:addBox("error", "Ez a funkció nem használható mert a kijelölt rang alatt nem található másik rang!")
                                end 
                            end 

                            factionRanksButtonHover = nil 
                        elseif factionRanksButtonHover == 6 then -- sorrend fel
                            if cache["playerDatas"]["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 0 and not hasPlayerPermission(cache["element"]:getData("acc >> id"), cache["playerDatas"]["faction"][selectedFaction][1], "faction.sortup") then 
                                exports['cr_infobox']:addBox("warning", "Neked ehhez nincs jogosultságod")
                                return 
                            end 

                            local data = cache["playerDatas"]["faction"][selectedFaction][4][factionRanksSelected]
                            if factionMembersSearchCache and #factionMembersSearchCache >= 1 then 
                                data = factionMembersSearchCache[factionRanksSelected]
                            end 

                            local rankID = -1
                            for k,v in pairs(cache["playerDatas"]["faction"][selectedFaction][4]) do 
                                if v["name"]:lower() == data["name"]:lower() then 
                                    rankID = k
                                end 
                            end 

                            if rankID >= 1 then 
                                if rankID - 1 >= 1 then 
                                    factionRanksUpdated = rankID - 1
                                    triggerLatentServerEvent("sortRankUP", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], rankID)
                                else 
                                    exports['cr_infobox']:addBox("error", "Ez a funkció nem használható mert a kijelölt rang felett nem található másik rang!")
                                end 
                            end 

                            factionRanksButtonHover = nil 
                        end 
                    elseif tonumber(factionMembersButtonHover) then 
                        local now = getTickCount()
                        if now <= lastClickTick + 1000 then
                            return
                        end

                        lastClickTick = getTickCount()
                        playSound("assets/sounds/click.mp3")

                        if exports['cr_network']:getNetworkStatus() then
                            return
                        end

                        if cache["element"] ~= localPlayer then 
                            return 
                        end 
                            
                        if isDescEditing or groupRenaming or groupCreating or isPickerRender or factionMessageEditing then
                            return
                        end

                        if factionMembersButtonHover == 1 then -- előléptetés
                            if cache["playerDatas"]["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 0 and not hasPlayerPermission(cache["element"]:getData("acc >> id"), cache["playerDatas"]["faction"][selectedFaction][1], "faction.rankUp") then 
                                exports['cr_infobox']:addBox("warning", "Neked ehhez nincs jogosultságod")
                                return 
                            end 

                            local data = cache["playerDatas"]["faction"][selectedFaction]["players"][factionMembersSelected]
                            if factionMembersSearchCache and #factionMembersSearchCache >= 1 then 
                                data = factionMembersSearchCache[factionMembersSelected]
                            end 
                            if data then 
                                local attachData = cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])] 
                                if attachData then 
                                    local rank = attachData[7] + 1
                                    if cache["playerDatas"]["faction"][selectedFaction][4][rank] then 
                                        cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])][7] = rank
                                        getFactionMemberInfos(factionMembersSelected)
                                        factionRankUpdated = tonumber(data[1])
                                        exports['cr_infobox']:addBox("success", "Sikeresen előléptetted a kijelölt játékost!")
                                        triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(localPlayer) .. " #F2F2F2előléptette " .. exports['cr_core']:getServerColor('yellow', true) .. cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])][2]:gsub("_", " ").. "#F2F2F2-ot/et (Új rang: ".. exports['cr_core']:getServerColor('yellow', true) .. cache["playerDatas"]["faction"][selectedFaction][4][rank]["name"] .. "#F2F2F2)")
                                        triggerLatentServerEvent("sendNotificationToAccID", 5000, false, localPlayer, tonumber(data[1]), "info", "Előléptettek a " .. cache["playerDatas"]["faction"][selectedFaction][2] .. " nevű frakcióban!")
                                        triggerLatentServerEvent("updatePlayerRank", 5000, false, localPlayer, localPlayer, tonumber(data[1]), cache["playerDatas"]["faction"][selectedFaction][1], cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])][7])
                                    else 
                                        exports['cr_infobox']:addBox("error", "Nem tudod nagyobb rangra előléptetni a kijelölt játékost!")
                                    end 
                                end 
                            end
                        elseif factionMembersButtonHover == 2 then -- lefokozás
                            if cache["playerDatas"]["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 0 and not hasPlayerPermission(cache["element"]:getData("acc >> id"), cache["playerDatas"]["faction"][selectedFaction][1], "faction.rankDown") then 
                                exports['cr_infobox']:addBox("warning", "Neked ehhez nincs jogosultságod")
                                return 
                            end 

                            local data = cache["playerDatas"]["faction"][selectedFaction]["players"][factionMembersSelected]
                            if factionMembersSearchCache and #factionMembersSearchCache >= 1 then 
                                data = factionMembersSearchCache[factionMembersSelected]
                            end 
                            if data then 
                                local attachData = cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])] 
                                if attachData then 
                                    local rank = attachData[7] - 1
                                    if cache["playerDatas"]["faction"][selectedFaction][4][rank] then 
                                        cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])][7] = rank
                                        getFactionMemberInfos(factionMembersSelected)
                                        factionRankUpdated = tonumber(data[1])
                                        exports['cr_infobox']:addBox("success", "Sikeresen lefokoztad a kijelölt játékost!")
                                        triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(localPlayer) .. " #F2F2F2lefokozta " .. exports['cr_core']:getServerColor('yellow', true) .. cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])][2]:gsub("_", " ").. "#F2F2F2-ot/et (Új rang: ".. exports['cr_core']:getServerColor('yellow', true) .. cache["playerDatas"]["faction"][selectedFaction][4][rank]["name"] .. "#F2F2F2)")
                                        triggerLatentServerEvent("sendNotificationToAccID", 5000, false, localPlayer, tonumber(data[1]), "info", "Lefokoztak a " .. cache["playerDatas"]["faction"][selectedFaction][2] .. " nevű frakcióban!")
                                        triggerLatentServerEvent("updatePlayerRank", 5000, false, localPlayer, localPlayer, tonumber(data[1]), cache["playerDatas"]["faction"][selectedFaction][1], cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])][7])
                                    else 
                                        exports['cr_infobox']:addBox("error", "Nem tudod kisebb rangra lefokozni a kijelölt játékost!")
                                    end 
                                end 
                            end
                        elseif factionMembersButtonHover == 3 then  -- leader szarság
                            if cache["playerDatas"]["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 0 and not hasPlayerPermission(cache["element"]:getData("acc >> id"), cache["playerDatas"]["faction"][selectedFaction][1], "faction.leaderInteractions") then 
                                exports['cr_infobox']:addBox("warning", "Neked ehhez nincs jogosultságod")
                                return 
                            end 

                            local data = cache["playerDatas"]["faction"][selectedFaction]["players"][factionMembersSelected]
                            if factionMembersSearchCache and #factionMembersSearchCache >= 1 then 
                                data = factionMembersSearchCache[factionMembersSelected]
                            end 
                            if data then 
                                if tonumber(data[1]) == cache["playerDatas"]["accId"] then 
                                    exports['cr_infobox']:addBox("warning", "Saját magaddal ez az interakció nem végezhető!")
                                    return 
                                end 

                                local attachData = cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])] 
                                if attachData then 
                                    if attachData[3] == 1 then -- elvevés
                                        cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])][3] = 0
                                        getFactionMemberInfos(factionMembersSelected)
                                        exports['cr_infobox']:addBox("success", "Sikeresen elvetted a leadert a kijelölt játékostól!")
                                        triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(localPlayer) .. " #F2F2F2elvette " .. exports['cr_core']:getServerColor('yellow', true) .. cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])][2]:gsub("_", " ").. "#F2F2F2 leader jogosultságait!")
                                        triggerLatentServerEvent("sendNotificationToAccID", 5000, false, localPlayer, tonumber(data[1]), "info", "Elvették a leader jogosultságodat a " .. cache["playerDatas"]["faction"][selectedFaction][2] .. " nevű frakcióban!")
                                        triggerLatentServerEvent("updatePlayerLeader", 5000, false, localPlayer, localPlayer, tonumber(data[1]), cache["playerDatas"]["faction"][selectedFaction][1], cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])][3])
                                    else -- adás
                                        cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])][3] = 1
                                        getFactionMemberInfos(factionMembersSelected)
                                        exports['cr_infobox']:addBox("success", "Sikeresen leadert adtál a kijelölt játékosnak!")
                                        triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(localPlayer) .. " #F2F2F2leader jogosultságokat adott " .. exports['cr_core']:getServerColor('yellow', true) .. cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])][2]:gsub("_", " ").. "#F2F2F2-nak/nek!")
                                        triggerLatentServerEvent("sendNotificationToAccID", 5000, false, localPlayer, tonumber(data[1]), "info", "Leader jogosultságokat kaptál a " .. cache["playerDatas"]["faction"][selectedFaction][2] .. " nevű frakcióban!")
                                        triggerLatentServerEvent("updatePlayerLeader", 5000, false, localPlayer, localPlayer, tonumber(data[1]), cache["playerDatas"]["faction"][selectedFaction][1], cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])][3])
                                    end 
                                end 
                            end
                        elseif factionMembersButtonHover == 4 then  -- kirúgás
                            if cache["playerDatas"]["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 0 and not hasPlayerPermission(cache["element"]:getData("acc >> id"), cache["playerDatas"]["faction"][selectedFaction][1], "faction.kick") then 
                                exports['cr_infobox']:addBox("warning", "Neked ehhez nincs jogosultságod")
                                return 
                            end 

                            local data = cache["playerDatas"]["faction"][selectedFaction]["players"][factionMembersSelected]
                            if factionMembersSearchCache and #factionMembersSearchCache >= 1 then 
                                data = factionMembersSearchCache[factionMembersSelected]
                            end 
                            if data then 
                                if tonumber(data[1]) == cache["playerDatas"]["accId"] then 
                                    exports['cr_infobox']:addBox("warning", "Saját magaddal ez az interakció nem végezhető!")
                                    return 
                                end 

                                local attachData = cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])] 
                                if attachData then 
                                    local blue = exports['cr_core']:getServerColor("yellow", true)
                                    local red = exports['cr_core']:getServerColor("red", true)
                                    local white = "#F2F2F2"
                                    local r,g,b = exports['cr_core']:getServerColor("green")
                                    local r2,g2,b2 = exports['cr_core']:getServerColor("red")

                                    createAlert(
                                        {
                                            ['headerText'] = 'Rangok',
                                            ["title"] = {white .. "Biztosan kiszeretnéd rúgni a csoportból "..blue..data[2]:gsub("_", " ")..white.."-ot/et?"},
                                            ["buttons"] = {
                                                {
                                                    ["name"] = "Igen", 
                                                    ["pressFunc"] = function()
                                                        exports['cr_infobox']:addBox("success", "Sikeresen kirúgtad a kijelölt játékost!")
                                                        triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(localPlayer) .. " #F2F2F2kirúgta " .. exports['cr_core']:getServerColor('yellow', true) .. cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])][2]:gsub("_", " ").. "#F2F2F2-ot/et a frakcióból!")
                                                        triggerLatentServerEvent("sendNotificationToAccID", 5000, false, localPlayer, tonumber(data[1]), "info", "Kirúgtak a " .. cache["playerDatas"]["faction"][selectedFaction][2] .. " nevű frakcióból!")
                                                        triggerLatentServerEvent("removePlayerFromFaction", 5000, false, localPlayer, tonumber(data[1]), cache["playerDatas"]["faction"][selectedFaction][1])
                                                        factionMembersSelected = 1
                                                        getFactionMemberInfos(factionMembersSelected)
                                                    end,
                                                    ["onCreate"] = function()
                                                        data = data
                                                        selectedFaction = selectedFaction
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
                            end
                        elseif factionMembersButtonHover == 5 then  -- új tag
                            if cache["playerDatas"]["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 0 and not hasPlayerPermission(cache["element"]:getData("acc >> id"), cache["playerDatas"]["faction"][selectedFaction][1], "faction.addmember") then 
                                exports['cr_infobox']:addBox("warning", "Neked ehhez nincs jogosultságod")
                                return 
                            end 

                            local blue = exports['cr_core']:getServerColor("yellow", true)
                            local red = exports['cr_core']:getServerColor("red", true)
                            local white = "#F2F2F2"
                            local r,g,b = exports['cr_core']:getServerColor("green")
                            local r2,g2,b2 = exports['cr_core']:getServerColor("red")

                            createAlert(
                                {
                                    ['headerText'] = 'Frakció',
                                    ["title"] = {white .. "Gépeld be a felvenni kivánt játékos nevét!", 1},
                                    ["buttons"] = {
                                        {
                                            ["type"] = "outputBox",
                                            ["color"] = {r, g, b},
                                            ["boxName"] = "FactionNameBox",
                                            ["onCreate"] = function()
                                                CreateNewBar("FactionNameBox", {0, 0, 0, 0}, {20, "", false, tocolor(242, 242, 242, 255), {"Poppins-Medium", 12}, 1, "center", "center", false, true}, 1, true)
                                            end,
                                        },

                                        {
                                            ["name"] = "Tovább", 
                                            ["pressFunc"] = function()
                                                local playerName = GetText("FactionNameBox")
                                                local player = exports['cr_core']:findPlayer(localPlayer, playerName, true)

                                                if player and isElement(player) then 
                                                    if player == localPlayer then 
                                                        exports['cr_infobox']:addBox("error", "Magad nem hívhatod meg!")
                                                        return 
                                                    end 

                                                    if not player:getData("loggedIn") then 
                                                        exports['cr_infobox']:addBox("error", exports['cr_admin']:getAdminName(player) .. " nincs bejelentkezve!")
                                                        return 
                                                    end 

                                                    if cache["playerDatas"]["faction"][selectedFaction][3][tonumber(player:getData("acc >> id"))] then 
                                                        exports['cr_infobox']:addBox("error", exports['cr_admin']:getAdminName(player) .. " már tagja a frakciónak!")
                                                        return 
                                                    end 

                                                    RemoveBar("FactionNameBox")
                                                    createAlert(
                                                        {
                                                            ['headerText'] = 'Frakció',
                                                            ["title"] = {white .. "Biztosan megszeretnéd hívni a frakcióba "..blue..exports['cr_admin']:getAdminName(player)..white.."-ot/et?"},
                                                            ["buttons"] = {
                                                                {
                                                                    ["name"] = "Igen", 
                                                                    ["pressFunc"] = function()
                                                                        triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(localPlayer) .. " #F2F2F2meghívta " .. exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(player) .. "#F2F2F2-ot/et a frakcióba!")
                                                                        triggerLatentServerEvent("inviteToFaction", 5000, false, localPlayer, localPlayer, player, cache["playerDatas"]["faction"][selectedFaction][1])

                                                                        exports['cr_infobox']:addBox("success", "Sikeresen meghívtad "..exports['cr_admin']:getAdminName(player).."-ot/et a frakcióba!")
                                                                    end,
                                                                    ["onCreate"] = function()
                                                                        player = player
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
                                                else 
                                                    resetStartTickAlert()
                                                    exports['cr_infobox']:addBox("error", "Nincs találat "..playerName.."-ra/re!")
                                                end 
                                            end,
                                            ["color"] = {r, g, b},
                                        },

                                        {
                                            ["name"] = "Mégse", 
                                            ["onClear"] = true,
                                            ["pressFunc"] = function()
                                                RemoveBar("FactionNameBox")
                                            end,
                                            ["color"] = {r2, g2, b2},
                                        },
                                    },
                                }
                            )
                        elseif factionMembersButtonHover == 6 then  -- jogosultság
                            if cache["playerDatas"]["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 0 and not hasPlayerPermission(cache["element"]:getData("acc >> id"), cache["playerDatas"]["faction"][selectedFaction][1], "faction.editperms") then 
                                exports['cr_infobox']:addBox("warning", "Neked ehhez nincs jogosultságod")
                                return 
                            end 

                            local alerts = {
                                ["isPermSelector"] = true, 
                                ["buttons"] = {}
                            }
                            
                            local data = cache["playerDatas"]["faction"][selectedFaction]["players"][factionMembersSelected]
                            if factionMembersSearchCache and #factionMembersSearchCache >= 1 then 
                                data = factionMembersSearchCache[factionMembersSelected]
                            end 

                            if cache["playerDatas"]["faction"][selectedFaction][3][data[1]][3] == 1 then 
                                exports['cr_infobox']:addBox("warning", "Leadernek a jogosultságai nem változtathatóak")
                                return 
                            end 

                            alerts["playerID"] = data[1]
                            alerts["factionID"] = cache["playerDatas"]["faction"][selectedFaction][1]

                            local perms = cache["playerDatas"]["faction"][selectedFaction][3][data[1]][8]
                            for k,v in ipairs(getFactionPermissions(cache["playerDatas"]["faction"][selectedFaction][1], cache["playerDatas"]["faction"][selectedFaction][5])) do 
                                table.insert(alerts["buttons"], {v, perms[v[1]]})
                            end
                            createAlert(alerts)
                        end 
                        factionMembersButtonHover = nil 
                    elseif factionDutyHover then 
                        local now = getTickCount()
                        if now <= lastClickTick + 1000 then
                            return
                        end

                        lastClickTick = getTickCount()

                        if exports['cr_network']:getNetworkStatus() then
                            return
                        end

                        if cache["element"] ~= localPlayer then 
                            return 
                        end 
                            
                        if isDescEditing or groupRenaming or groupCreating or isPickerRender or factionMessageEditing then
                            return
                        end

                        if not dutySelecting then 
                            closeDash()

                            local x,y,z,dim,int,rot = unpack(factionDutySkinData[cache["playerDatas"]["faction"][selectedFaction][1]]["showposition"])

                            local skinid 
                            dutySelectorNow = 0 
                            defaultPlayerAlpha = localPlayer.alpha
                            defaultPlayerDimension = dim

                            for k,v in pairs(factionDutySkinData[cache["playerDatas"]["faction"][selectedFaction][1]]["skins"]) do 
                                if factionDutyHover == v then 
                                    dutySelectorNow = k
                                end 
                            end 

                            if not skinid or not tonumber(skinid) or skinid == 0 then 
                                dutySelectorNow = 1
                            end 

                            skinid = factionDutySkinData[cache["playerDatas"]["faction"][selectedFaction][1]]["skins"][dutySelectorNow]

                            if skinid then 
                                local accId = localPlayer:getData("acc >> id") or dim

                                gPed = Ped(1, x,y,z,rot)
                                gPed:setData("ped >> skin", skinid)

                                gPed.dimension = accId
                                gPed.interior = int

                                localPlayer.alpha = 0
                                localPlayer.dimension = accId

                                setCameraMatrix(unpack(factionDutySkinData[cache["playerDatas"]["faction"][selectedFaction][1]]["cameraposition"]))

                                dutySelecting = true 

                                bindKey("arrow_l", "down", dutySelectorLeft)
                                bindKey("arrow_r", "down", dutySelectorRight)
                                bindKey("backspace", "down", dutySelectorCancel)
                                bindKey("enter", "down", dutySelectorFinish)

                                exports['cr_controls']:toggleAllControls(false, "instant")
                            end
                        end 

                        factionDutyHover = nil 
                    elseif factionMembersScrollingHover then
                        factionMembersScrollingHover = false
                        factionMembersScrolling = true
                    elseif factionRanksScrollingHover then
                        factionRanksScrollingHover = false
                        factionRanksScrolling = true 
                    elseif FactionVehicleScrollingHover then 
                        FactionVehicleScrollingHover = false 
                        FactionVehicleScrolling = true 
                    elseif FactionVehicleInfoScrollingHover then 
                        FactionVehicleInfoScrollingHover = false 
                        FactionVehicleInfoScrolling = true
                    elseif FactionLogsScrollingHover then 
                        FactionLogsScrollingHover = false 
                        FactionLogsScrolling = true 
                    elseif tonumber(factionMembersHover) then 
                        factionMembersSelected = factionMembersHover
                        getFactionMemberInfos(factionMembersSelected)

                        factionMembersHover = nil 
                    elseif tonumber(factionRanksHover) then 
                        factionRanksSelected = factionRanksHover
                        getFactionRankInfos(factionRanksSelected)

                        factionRanksHover = nil  
                    elseif tonumber(factionBankHover) then 
                        local now = getTickCount()
                        if now <= lastClickTick + 1000 then
                            return
                        end

                        lastClickTick = getTickCount()

                        if exports['cr_network']:getNetworkStatus() then
                            return
                        end

                        if cache["element"] ~= localPlayer then 
                            return 
                        end 
                            
                        if isDescEditing or groupRenaming or groupCreating or isPickerRender or factionMessageEditing then
                            return
                        end

                        if factionBankHover == 1 then 
                            if cache["playerDatas"]["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 0 and not hasPlayerPermission(cache["element"]:getData("acc >> id"), cache["playerDatas"]["faction"][selectedFaction][1], "faction.addmoney") then 
                                exports['cr_infobox']:addBox("warning", "Neked ehhez nincs jogosultságod")
                                return 
                            end 

                            local money = tonumber(GetText("FactionBank >> Edit"))
                            if money < 1 then 
                                exports['cr_infobox']:addBox("error", "A számnak minimum 1nek kell lennie!")
                                return 
                            end 

                            if exports['cr_core']:takeMoney(localPlayer, money) then 
                                local factionID = cache["playerDatas"]["faction"][selectedFaction][1]
                                triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, factionID, exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(localPlayer) .. " #F2F2F2berakott " .. exports['cr_core']:getServerColor("green", true) .. money .. " $#F2F2F2 a frakcióba!")
                                triggerLatentServerEvent("giveFactionMoney", 5000, false, localPlayer, localPlayer, factionID, money)
                                SetText("FactionBank >> Edit", "0")
                            else
                                exports['cr_infobox']:addBox("error", "Nincs elég pénzed!")
                            end 
                        elseif factionBankHover == 2 then 
                            if cache["playerDatas"]["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 0 and not hasPlayerPermission(cache["element"]:getData("acc >> id"), cache["playerDatas"]["faction"][selectedFaction][1], "faction.getmoney") then 
                                exports['cr_infobox']:addBox("warning", "Neked ehhez nincs jogosultságod")
                                return 
                            end 

                            local money = tonumber(GetText("FactionBank >> Edit"))
                            if money < 1 then 
                                exports['cr_infobox']:addBox("error", "A számnak minimum 1nek kell lennie!")
                                return 
                            end 

                            if cache["playerDatas"]["faction"][selectedFaction][6] >= money then 
                                cache["playerDatas"]["faction"][selectedFaction][6] = cache["playerDatas"]["faction"][selectedFaction][6] - money
                                local factionID = cache["playerDatas"]["faction"][selectedFaction][1]
                                triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, factionID, exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(localPlayer) .. " #F2F2F2kivett " .. exports['cr_core']:getServerColor("green", true) .. money .. " $#F2F2F2 a frakcióból!")
                                triggerLatentServerEvent("getFactionMoney", 5000, false, localPlayer, localPlayer, factionID, money)
                                SetText("FactionBank >> Edit", "0")
                            else
                                exports['cr_infobox']:addBox("error", "Nincs elég pénz a frakció számláján!")
                            end 
                        end 
                    elseif factionMessageEditHover then 
                        if not factionMessageEditing then 
                            factionMessageEditing = true
                            local msg = cache["playerDatas"]["faction"][selectedFaction][7] or ""
                            CreateNewBar("FactionMessage >> Edit", {0, 0, 0, 0}, {399, msg, false, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "top", false, false, true}, 1, true)
                        else 
                            factionMessageEditing = false
                            local factionID = cache["playerDatas"]["faction"][selectedFaction][1]
                            local val = exports['cr_chat']:findSwear(GetText("FactionMessage >> Edit")) or GetText("FactionMessage >> Edit")
                            
                            triggerLatentServerEvent("updateFactionMessage", 5000, false, localPlayer, localPlayer, factionID, val)
                            RemoveBar("FactionMessage >> Edit") --Clear()
                        end 

                        factionMessageEditHover = nil 
                    elseif FactionInformationsScrollingHover then 
                        FactionInformationsScrollingHover = false
                        FactionInformationsScrolling = true
                    elseif FactionSelectorScrollingHover then
                        FactionSelectorScrollingHover = false
                        FactionSelectorScrolling = true
                    elseif tonumber(factionSelectorButton) then 
                        local now = getTickCount()
                        if now <= lastClickTick + 250 then
                            return
                        end

                        lastClickTick = getTickCount()
                            
                        if isDescEditing or groupRenaming or groupCreating or isPickerRender or factionMessageEditing then
                            return
                        end

                        if cache["playerDatas"]["faction"][selectedFaction] and cache["playerDatas"]["faction"][selectedFaction][1] then 
                            triggerLatentServerEvent("closeFactionPanel", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], localPlayer)
                        end

                        selectedFaction = tonumber(factionSelectorButton)

                        if cache["playerDatas"]["faction"][selectedFaction] and cache["playerDatas"]["faction"][selectedFaction][1] then 
                            getFactionData(cache["element"], cache["playerDatas"]["faction"][selectedFaction][1])
                            triggerLatentServerEvent("openFactionPanel", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], localPlayer)
                        end 

                        generateFactionInformations(cache["playerDatas"]["faction"][selectedFaction])
                        getFactionVehicles(cache["playerDatas"]["faction"][selectedFaction][1])
                         
                        factionSelectorButton = nil
                    elseif tonumber(FactionVehHover) then 
                        if FactionVehHover then
                            local e = playerFactionVehicles[FactionVehHover]
                            if e then 
                                if FactionVehicleSelected ~= FactionVehHover then
                                    FactionVehicleSelected = FactionVehHover
                                    if e then
                                        generateFactionVehicleInformations(e)
                                    end
                                else
                                    FactionVehicleSelected = nil
                                    playerFactionVehicleInfos = {}
                                end
                            end
                            FactionVehHover = nil
                        end
                    elseif tonumber(factionsHover) then
                        local now = getTickCount()
                        if now <= lastClickTick + 250 then
                            return
                        end

                        if not cache["playerDatas"]["faction"] or #cache["playerDatas"]["faction"] == 0 then
                            return 
                        end 

                        lastClickTick = getTickCount()
                            
                        if isDescEditing or groupRenaming or groupCreating or isPickerRender or factionMessageEditing then
                            return
                        end

                        if tonumber(factionsHover) == 5 then 
                            if cache["playerDatas"]["faction"][selectedFaction][3][cache["playerDatas"]["accId"]][3] == 0 and not hasPlayerPermission(cache["element"]:getData("acc >> id"), cache["playerDatas"]["faction"][selectedFaction][1], "faction.openlogs") then 
                                exports['cr_infobox']:addBox("warning", "Neked ehhez nincs jogosultságod")
                                return 
                            end 
                        end 

                        factionButtonAnimation[factionsSelected] = {getTickCount(), 2}
                        factionButtonAnimation[tonumber(factionsHover)] = {getTickCount(), 1}
                        factionsSelected = tonumber(factionsHover)

                        Clear()
                        if factionsSelected == 1 then 
                            CreateNewBar("FactionBank >> Edit", {0, 0, 0, 0}, {10, "0", true, tocolor(242, 242, 242, 255), {"Poppins-Medium", realFontSize[12]}, 1, "left", "center", false, true}, 1)
                        elseif factionsSelected == 2 then 
                            CreateNewBar("FactionMembers >> search", {0, 0, 0, 0}, {30, "", false, tocolor(242, 242, 242, 255), {"Poppins-Medium", realFontSize[12]}, 1, "left", "center", false, true}, 1)
                            factionMembersSearchCache = nil
                            factionMembersMinLines = 1
                            factionMembersMaxLines = 16
                            factionMembersSelected = 1 
                            factionMemberInfos = {}
                            getFactionMemberInfos(factionMembersSelected)
                            getMyFactionMemberInfos(cache["playerDatas"]["accId"])
                        elseif factionsSelected == 3 then 
                            CreateNewBar("FactionRanks >> search", {0, 0, 0, 0}, {30, "", false, tocolor(242, 242, 242, 255), {"Poppins-Medium", realFontSize[12]}, 1, "left", "center", false, true}, 1)
                            factionRanksSearchCache = nil
                            factionRanksMinLines = 1
                            factionRanksMaxLines = 16
                            factionRanksSelected = 1 
                            factionRankInfos = {}
                            getFactionRankInfos(factionRanksSelected)
                        elseif factionsSelected == 4 then 
                            playerFactionVehicleInfos = {}
                            FactionVehicleSelected = nil 
                            FactionVehicleMinLines = 1
                            FactionVehicleMaxLines = 16
                            FactionVehicleInfoMinLines = 1
                            FactionVehicleInfoMaxLines = 16
                        elseif factionsSelected == 5 then 
                            FactionLogsMinLines = 1 
                            FactionLogsMaxLines = 16
                        end 

                        factionsHover = nil
                    end
                elseif cache["page"] == 4 then
                    if searchHover then 
                        if GetText("Admin >> search"):gsub(" ", "") ~= "" then
                            adminSearchCache = {}
                            local text = string.lower(GetText("Admin >> search"))
                            for k, v in ipairs(adminCacheKey) do
                                if adminCache[v] then
                                    local data = adminCache[v]
                                    local text2 = string.lower(data["nick"])
                                    local text3 = string.lower(tostring(data["id"]))
                                    local e = v["element"]
                
                                    if string.lower(tostring(text2)):find(text) or string.lower(text3):find(text) then
                                        table.insert(adminSearchCache, v)
                                    end
                                end
                            end
                        else
                            adminSearchCache = nil
                        end

                        searchHover = nil 
                    elseif tonumber(aHover) then
                        local now = getTickCount()
                        if now <= lastClickTick + 250 then
                            return
                        end
                           
                        textbars["Admin >> search"][2][2] = ""
                        adminSearchCache = nil
                        adminSelectedMenu = aHover
                        generateAdminCache(adminSelectedMenu)
                        
                        playSound("assets/sounds/click.mp3")
                        lastClickTick = now
                        
                        aHover = nil
                    end
                elseif cache["page"] == 5 then
                    if groupButtonHover then 
                        if groupButtonHover == 1 then 
                            local now = getTickCount()
                            if now <= lastClickTick + 1000 then
                                return
                            end
                            
                            if exports['cr_network']:getNetworkStatus() then
                                return
                            end

                            if cache["element"] ~= localPlayer then 
                                return 
                            end 
                                
                            if localPlayer:getData("char >> groupLeader") then 
                                if not groupRenaming then
                                    playSound("assets/sounds/click.mp3")
                                    lastClickTick = now
                                    groupRenaming = true
                                    
                                    local blue = exports['cr_core']:getServerColor("yellow", true)
                                    local white = "#F2F2F2"
                                    local r,g,b = exports['cr_core']:getServerColor("green")
                                    local r2,g2,b2 = exports['cr_core']:getServerColor("red")
        
                                    createAlert(
                                        {
                                            ['headerText'] = 'Csoport',
                                            ["title"] = {white .. "Gépeld be a csoport új nevét!", 1},
                                            ["buttons"] = {
                                                {
                                                    ["type"] = "outputBox",
                                                    ["color"] = {r, g, b},
                                                    ["boxName"] = "GroupNameBox",
                                                    ["onCreate"] = function()
                                                        CreateNewBar("GroupNameBox", {0, 0, 0, 0}, {20, "", false, tocolor(242, 242, 242, 255), {"Poppins-Medium", 12}, 1, "center", "center", false, true}, 1, true)
                                                    end,
                                                },
        
                                                {
                                                    ["name"] = "Tovább", 
                                                    ["pressFunc"] = function()
                                                        text = GetText("GroupNameBox")
                                                        if #text < 6 then
                                                            resetStartTickAlert()
                                                            exports['cr_infobox']:addBox("warning", "A névnek 6 karakternek kell legyen minimum!")
                                                        else
                                                            RemoveBar("GroupNameBox")
                                                            groupRenaming = false
                                                            triggerLatentServerEvent("changeGroupName", 5000, false, localPlayer, localPlayer, tonumber(localPlayer:getData("char >> group")), text)
                                                            exports['cr_infobox']:addBox("success", "Sikeresen átnevezted a csoportot!")
                                                        end
                                                    end,
                                                    ["color"] = {r, g, b},
                                                },
        
                                                {
                                                    ["name"] = "Mégse", 
                                                    ["onClear"] = true,
                                                    ["pressFunc"] = function()
                                                        RemoveBar("GroupNameBox")
                                                        groupRenaming = false
                                                    end,
                                                    ["color"] = {r2, g2, b2},
                                                },
                                            },
                                        }
                                    )
                                end
                            else 
                                exports['cr_infobox']:addBox("warning", "Ehhez nincs jogosultságod!")
                            end
                        elseif groupButtonHover == 2 then 
                            if exports['cr_network']:getNetworkStatus() then
                                return
                            end

                            if cache["element"] ~= localPlayer then 
                                return 
                            end 

                            local now = getTickCount()
                            if now <= lastClickTick + 1000 then
                                return
                            end

                            playSound("assets/sounds/click.mp3")
                            lastClickTick = now

                            if localPlayer:getData("char >> groupLeader") then 
                                local blue = exports['cr_core']:getServerColor("yellow", true)
                                local red = exports['cr_core']:getServerColor("red", true)
                                local white = "#F2F2F2"
                                local r,g,b = exports['cr_core']:getServerColor("green")
                                local r2,g2,b2 = exports['cr_core']:getServerColor("red")

                                createAlert(
                                    {
                                        ['headerText'] = 'Csoport',
                                        ["title"] = {white .. "Biztosan kiszeretnéd "..red.."törölni"..white.." a csoportot?", 1},
                                        ["buttons"] = {
                                            {
                                                ["name"] = "Igen", 
                                                ["pressFunc"] = function()
                                                    triggerLatentServerEvent("deleteGroup", 5000, false, localPlayer, tonumber(localPlayer:getData("char >> group")))

                                                    exports['cr_infobox']:addBox("success", "Sikeresen kitörölted a csoportot!")
                                                end,
                                                ["color"] = {r, g, b},
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
                            else 
                                exports['cr_infobox']:addBox("warning", "Ehhez nincs jogosultságod!")
                            end
                        elseif groupButtonHover == 3 then 
                            if exports['cr_network']:getNetworkStatus() then
                                return
                            end

                            if cache["element"] ~= localPlayer then 
                                return 
                            end 

                            local now = getTickCount()
                            if now <= lastClickTick + 1000 then
                                return
                            end

                            playSound("assets/sounds/click.mp3")
                            lastClickTick = now

                            if localPlayer:getData("char >> groupLeader") then 
                                local blue = exports['cr_core']:getServerColor("yellow", true)
                                local red = exports['cr_core']:getServerColor("red", true)
                                local white = "#F2F2F2"
                                local r,g,b = exports['cr_core']:getServerColor("green")
                                local r2,g2,b2 = exports['cr_core']:getServerColor("red")

                                createAlert(
                                    {
                                        ['headerText'] = 'Csoport',
                                        ["title"] = {white .. "Gépeld be a meghívni kivánt játékos nevét!", 1},
                                        ["buttons"] = {
                                            {
                                                ["type"] = "outputBox",
                                                ["color"] = {r, g, b},
                                                ["boxName"] = "GroupNameBox",
                                                ["onCreate"] = function()
                                                    CreateNewBar("GroupNameBox", {0, 0, 0, 0}, {20, "", false, tocolor(242, 242, 242, 255), {"Poppins-Medium", 12}, 1, "center", "center", false, true}, 1, true)
                                                end,
                                            },

                                            {
                                                ["name"] = "Tovább", 
                                                ["pressFunc"] = function()
                                                    local playerName = GetText("GroupNameBox")
                                                    local player = exports['cr_core']:findPlayer(localPlayer, playerName, true)

                                                    if player and isElement(player) then 
                                                        if player == localPlayer then 
                                                            exports['cr_infobox']:addBox("error", "Magad nem hívhatod meg!")
                                                            return 
                                                        end 

                                                        if tonumber(player:getData("char >> group") or 0) > 0 then 
                                                            exports['cr_infobox']:addBox("error", exports['cr_admin']:getAdminName(player) .. " már egy másik csoport tagja!")
                                                            return 
                                                        end 

                                                        RemoveBar("GroupNameBox")
                                                        createAlert(
                                                            {
                                                                ['headerText'] = 'Csoport',
                                                                ["title"] = {white .. "Biztosan megszeretnéd hívni a csoportba "..blue..exports['cr_admin']:getAdminName(player)..white.."-ot/et?"},
                                                                ["buttons"] = {
                                                                    {
                                                                        ["name"] = "Igen", 
                                                                        ["pressFunc"] = function()
                                                                            triggerLatentServerEvent("inviteToGroup", 5000, false, localPlayer, localPlayer, player, tonumber(localPlayer:getData("char >> group")))

                                                                            exports['cr_infobox']:addBox("success", "Sikeresen meghívtad "..exports['cr_admin']:getAdminName(player).."-ot/et a csoportba!")
                                                                        end,
                                                                        ["onCreate"] = function()
                                                                            player = player
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
                                                    else 
                                                        resetStartTickAlert()
                                                        exports['cr_infobox']:addBox("error", "Nincs találat "..playerName.."-ra/re!")
                                                    end 
                                                end,
                                                ["color"] = {r, g, b},
                                            },

                                            {
                                                ["name"] = "Mégse", 
                                                ["onClear"] = true,
                                                ["pressFunc"] = function()
                                                    RemoveBar("GroupNameBox")
                                                end,
                                                ["color"] = {r2, g2, b2},
                                            },
                                        },
                                    }
                                )
                            else 
                                exports['cr_infobox']:addBox("warning", "Ehhez nincs jogosultságod!")
                            end
                        elseif groupButtonHover == 4 then 
                            if exports['cr_network']:getNetworkStatus() then
                                return
                            end

                            if cache["element"] ~= localPlayer then 
                                return 
                            end 

                            local now = getTickCount()
                            if now <= lastClickTick + 1000 then
                                return
                            end

                            playSound("assets/sounds/click.mp3")
                            lastClickTick = now

                            if tonumber(groupSelected) then 
                                if localPlayer:getData("char >> groupLeader") then 
                                    local playerData = cache["playerDatas"]["group"][selectedGroup]["data"][3][groupSelected]
                                    if playerData then 
                                        if playerData[3] == 1 then 
                                            exports['cr_infobox']:addBox("warning", "Magad nem rúghatod ki!")
                                            return 
                                        end 

                                        local blue = exports['cr_core']:getServerColor("yellow", true)
                                        local red = exports['cr_core']:getServerColor("red", true)
                                        local white = "#F2F2F2"
                                        local r,g,b = exports['cr_core']:getServerColor("green")
                                        local r2,g2,b2 = exports['cr_core']:getServerColor("red")

                                        createAlert(
                                            {
                                                ['headerText'] = 'Csoport',
                                                ["title"] = {white .. "Biztosan kiszeretnéd rúgni a csoportból "..blue..playerData[2]:gsub("_", " ")..white.."-ot/et?"},
                                                ["buttons"] = {
                                                    {
                                                        ["name"] = "Igen", 
                                                        ["pressFunc"] = function()
                                                            triggerLatentServerEvent("kickPlayerFromGroup", 5000, false, localPlayer, localPlayer, playerData, tonumber(localPlayer:getData("char >> group")))

                                                            groupSelected = nil
                                                            playerGroupInfos = {}
                                                            exports['cr_infobox']:addBox("success", "Sikeresen kirúgtad "..playerData[2]:gsub("_", " ").."-ot/et a csoportból!")
                                                        end,
                                                        ["onCreate"] = function()
                                                            playerData = playerData
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
                                    exports['cr_infobox']:addBox("warning", "Ehhez nincs jogosultságod!")
                                end 
                            else 
                                exports['cr_infobox']:addBox("warning", "Válasz ki egy játékost!")
                            end 
                        elseif groupButtonHover == 5 then 
                            if exports['cr_network']:getNetworkStatus() then
                                return
                            end

                            if cache["element"] ~= localPlayer then 
                                return 
                            end 

                            local now = getTickCount()
                            if now <= lastClickTick + 1000 then
                                return
                            end

                            playSound("assets/sounds/click.mp3")
                            lastClickTick = now

                            if tonumber(groupSelected) then 
                                if localPlayer:getData("char >> groupLeader") then 
                                    local playerData = cache["playerDatas"]["group"][selectedGroup]["data"][3][groupSelected]
                                    if playerData then 
                                        if playerData[3] == 1 then 
                                            exports['cr_infobox']:addBox("warning", "Magad nem nevezheted ki!")
                                            return 
                                        end 

                                        local blue = exports['cr_core']:getServerColor("yellow", true)
                                        local red = exports['cr_core']:getServerColor("red", true)
                                        local white = "#F2F2F2"
                                        local r,g,b = exports['cr_core']:getServerColor("green")
                                        local r2,g2,b2 = exports['cr_core']:getServerColor("red")

                                        createAlert(
                                            {
                                                ['headerText'] = 'Csoport',
                                                ["title"] = {white .. "Biztosan kiszeretnéd nevezni a csoport vezetőjévé "..blue..playerData[2]:gsub("_", " ")..white.."-ot/et?"},
                                                ["buttons"] = {
                                                    {
                                                        ["name"] = "Igen", 
                                                        ["pressFunc"] = function()
                                                            triggerLatentServerEvent("setPlayerGroupLeader", 5000, false, localPlayer, localPlayer, playerData, tonumber(localPlayer:getData("char >> group")))

                                                            groupSelected = nil
                                                            playerGroupInfos = {}
                                                            exports['cr_infobox']:addBox("success", "Sikeresen kinevezted "..playerData[2]:gsub("_", " ").."-ot/et a csoport vezetőjének!")
                                                        end,
                                                        ["onCreate"] = function()
                                                            playerData = playerData
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
                                    exports['cr_infobox']:addBox("warning", "Ehhez nincs jogosultságod!")
                                end 
                            else 
                                exports['cr_infobox']:addBox("warning", "Válasz ki egy játékost!")
                            end 
                        elseif groupButtonHover == 6 then 
                            if exports['cr_network']:getNetworkStatus() then
                                return
                            end

                            if cache["element"] ~= localPlayer then 
                                return 
                            end 

                            local now = getTickCount()
                            if now <= lastClickTick + 1000 then
                                return
                            end

                            playSound("assets/sounds/click.mp3")
                            lastClickTick = now

                            local blue = exports['cr_core']:getServerColor("yellow", true)
                            local red = exports['cr_core']:getServerColor("red", true)
                            local white = "#F2F2F2"
                            local r,g,b = exports['cr_core']:getServerColor("green")
                            local r2,g2,b2 = exports['cr_core']:getServerColor("red")

                            createAlert(
                                {
                                    ['headerText'] = 'Csoport',
                                    ["title"] = {white .. "Biztosan " .. red .. "elszeretnéd" .. white .. " hagyni a csoportot?", 1},
                                    ["buttons"] = {
                                        {
                                            ["name"] = "Igen", 
                                            ["pressFunc"] = function()
                                                triggerLatentServerEvent("removePlayerFromGroup", 5000, false, localPlayer, "ByScript", localPlayer, tonumber(localPlayer:getData("char >> group")))

                                                exports['cr_infobox']:addBox("success", "Sikeresen kiléptél a csoportból!")
                                            end,
                                            ["color"] = {r, g, b},
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
                        groupButtonHover = nil 
                    elseif groupHover then
                        local e = cache["playerDatas"]["group"][selectedGroup]["data"][3][groupHover]
                        if groupSearchCache then 
                            e = groupSearchCache[groupHover]
                        end 

                        if e then
                            if groupSelected ~= groupHover then
                                groupSelected = groupHover
                                if e then 
                                    generateGroupInformations(groupSelected)
                                end
                            else
                                groupSelected = nil
                                playerGroupInfos = {}
                            end
                        end

                        groupHover = nil
                    elseif bHover == "create" then
                        local now = getTickCount()
                        if now <= lastClickTick + 1000 then
                            return
                        end
                        
                        if exports['cr_network']:getNetworkStatus() then
                            return
                        end

                        if cache["element"] ~= localPlayer then 
                            return 
                        end 
                        
                        if not groupCreating then
                            playSound("assets/sounds/click.mp3")
                            lastClickTick = now
                            groupCreating = true
                            
                            local blue = exports['cr_core']:getServerColor("yellow", true)
                            local white = "#F2F2F2"
                            local r,g,b = exports['cr_core']:getServerColor("green")
                            local r2,g2,b2 = exports['cr_core']:getServerColor("red")

                            createAlert(
                                {
                                    ['headerText'] = 'Csoport',
                                    ["title"] = {white .. "Gépeld be a létrehozni kívánt csoport nevét!", 1},
                                    ["buttons"] = {
                                        {
                                            ["type"] = "outputBox",
                                            ["color"] = {r, g, b},
                                            ["boxName"] = "GroupNameBox",
                                            ["onCreate"] = function()
                                                CreateNewBar("GroupNameBox", {0, 0, 0, 0}, {32, "", false, tocolor(242, 242, 242, 255), {"Poppins-Medium", 12}, 1, "center", "center", false, true}, 1, true)
                                            end,
                                        },

                                        {
                                            ["name"] = "Tovább", 
                                            ["pressFunc"] = function()
                                                text = GetText("GroupNameBox")
                                                if #text < 6 then
                                                    resetStartTickAlert()
                                                    exports['cr_infobox']:addBox("warning", "A névnek 6 karakternek kell legyen minimum!")
                                                else
                                                    RemoveBar("GroupNameBox")
                                                    groupCreating = false
                                                    triggerLatentServerEvent("createGroup", 5000, false, localPlayer, localPlayer, text)
                                                end
                                            end,
                                            ["color"] = {r, g, b},
                                        },

                                        {
                                            ["name"] = "Mégse", 
                                            ["onClear"] = true,
                                            ["pressFunc"] = function()
                                                RemoveBar("GroupNameBox")
                                                groupCreating = false
                                            end,
                                            ["color"] = {r2, g2, b2},
                                        },
                                    },
                                }
                            )
                        end

                        bHover = nil
                    end
                elseif cache["page"] == 6 then
                    if PremiumBuyScrollingHover then
                        PremiumBuyScrollingHover = false
                        PremiumBuyScrolling = true
                    end
                    
                    if buyHover == "PPCode" then
                        local blue = exports['cr_core']:getServerColor("yellow", true)
                        local white = "#F2F2F2"
                        local r,g,b = exports['cr_core']:getServerColor("green")
                        local r2,g2,b2 = exports['cr_core']:getServerColor("red")
                        
                        createAlert(
                            {
                                ['headerText'] = 'Prémium',
                                ["title"] = {white .. "Gépeld be a jóváirandó prémiumkódot!", 1},
                                ["buttons"] = {
                                    {
                                        ["type"] = "outputBox",
                                        ["color"] = {r, g, b},
                                        ["boxName"] = "PPCodeBox",
                                        ["onCreate"] = function()
                                            CreateNewBar("PPCodeBox", {0, 0, 0, 0}, {10, "0", false, tocolor(242, 242, 242, 255), {"Poppins-Medium", 12}, 1, "center", "center", false, true}, 1)
                                        end,
                                    },

                                    {
                                        ["name"] = "Tovább", 
                                        ["pressFunc"] = function()
                                            text = GetText("PPCodeBox")
                                            if #text < 10 then
                                                resetStartTickAlert()
                                                exports['cr_infobox']:addBox("warning", "A kódnak 10 karakternek kell legyen!")
                                            else
                                                RemoveBar("PPCodeBox")
                                                triggerLatentServerEvent("checkCode", 5000, false, localPlayer, localPlayer, text)
                                            end
                                        end,
                                        ["color"] = {r, g, b},
                                    },

                                    {
                                        ["name"] = "Mégse", 
                                        ["onClear"] = true,
                                        ["pressFunc"] = function()
                                            RemoveBar("PPCodeBox")
                                        end,
                                        ["color"] = {r2, g2, b2},
                                    },
                                },
                            }
                        )
                    elseif tonumber(buyHover) then
                        local data = PremiumData[premiumSelected]["items"][tonumber(buyHover)]
                        if data then
                            local blue = exports['cr_core']:getServerColor("yellow", true)
                            local white = "#F2F2F2"

                            local r,g,b = exports['cr_core']:getServerColor("green")
                            local r2,g2,b2 = exports['cr_core']:getServerColor("red")
                            local id, val, nbt, price = unpack(data)
                            createAlert(
                                {
                                    ['headerText'] = 'Prémium',
                                    ["title"] = {white .. "Gépeld be hány darab "..blue..exports['cr_inventory']:getItemName(id, val, nbt)..white.."-ot(et) szeretnél vásárolni!", 1},
                                    ["buttons"] = {
                                        {
                                            ["type"] = "outputBox",
                                            ["color"] = {r, g, b},
                                            ["boxName"] = "ppBuyBox",
                                            ["onCreate"] = function()
                                                data = data
                                                id, val, nbt, price = unpack(data)
                                                CreateNewBar("ppBuyBox", {0, 0, 0, 0}, {3, "0", true, tocolor(242, 242, 242, 255), {"Poppins-Medium", 12}, 1, "center", "center", false, true}, 1)
                                            end,
                                        },

                                        {
                                            ["name"] = "Tovább", 
                                            ["pressFunc"] = function()
                                                count = GetText("ppBuyBox")
                                                if tonumber(count) and tonumber(count) >= 1 then
                                                    local maxStack = exports['cr_inventory']:GetData(id, val, nbt, "maxStack") or 1
                                                    if tonumber(count) > maxStack then
                                                        resetStartTickAlert()
                                                        exports['cr_infobox']:addBox("warning", "Ebből maximum "..maxStack.." db-t vásárolhatsz!")
                                                    else    
                                                        RemoveBar("ppBuyBox")
                                                        createAlert(
                                                            {
                                                                ['headerText'] = 'Prémium',
                                                                ["title"] = {white .. "Szeretnél vásárolni "..blue..count..white.." darab "..blue..exports['cr_inventory']:getItemName(id, val, nbt)..white.."-ot(et) "..blue..(count * price)..white.." prémiumpontért?", 1},
                                                                ["buttons"] = {
                                                                    {
                                                                        ["name"] = "Igen", 
                                                                        ["pressFunc"] = function()
                                                                            local name = exports['cr_inventory']:getItemName(id, val, nbt)

                                                                            local pp = tonumber(localPlayer:getData("char >> premiumPoints")) or 0
                                                                            if pp >= (count * price) then
                                                                                if exports['cr_inventory']:isElementHasSpace(localPlayer, nil, id, val, nbt, count) then
                                                                                    localPlayer:setData("char >> premiumPoints", pp - (count * price))
                                                                                    exports['cr_inventory']:giveItem(localPlayer, id, val, count, 100, 0, localPlayer:getData('acc >> id'), nbt)
                                                                                    exports['cr_infobox']:addBox("success", "Sikeres vásárlás!")
                                                                                else
                                                                                    exports['cr_infobox']:addBox("error", "Nincs elég hely az inventorydban!")
                                                                                end
                                                                            else
                                                                                exports['cr_infobox']:addBox("error", "Nincs elengedő PP-d ahhoz, hogy "..name.."-ot(et) vásárolj ("..(count * price).." PP)")
                                                                            end
                                                                            --outputChatBox(name, 255, 255, 255, true)
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
                                                    resetStartTickAlert()
                                                    exports['cr_infobox']:addBox("error", "Minimum 1 db!")
                                                end
                                            end,
                                            ["color"] = {r, g, b},
                                        },

                                        {
                                            ["name"] = "Mégse", 
                                            ["onClear"] = true,
                                            ["pressFunc"] = function()
                                                RemoveBar("ppBuyBox")
                                            end,
                                            ["color"] = {r2, g2, b2},
                                        },
                                    },
                                }
                            )
                        end
                        buyHover = nil
                    end
                    
                    if arrowHover then
                        if arrowHover == "left" then
                            if PremiumMinLines - 1 >= 1 then
                                PremiumMinLines = PremiumMinLines - 1
                                PremiumMaxLines = PremiumMaxLines - 1
                            end
                        elseif arrowHover == "right" then
                            if PremiumMaxLines + 1 <= #PremiumData then
                                PremiumMinLines = PremiumMinLines + 1
                                PremiumMaxLines = PremiumMaxLines + 1
                            end
                        end
                        
                        arrowHover = nil
                    end
                    
                    if tonumber(premiumHover) then
                        premiumButtonAnimation[premiumSelected] = {getTickCount(), 2}
                        premiumButtonAnimation[tonumber(premiumHover)] = {getTickCount(), 1}
                        premiumSelected = tonumber(premiumHover)
                        
                        if PremiumBuyMaxLines > #PremiumData[premiumSelected]["items"] then
                            PremiumBuyMinLines = 1
                            PremiumBuyMaxLines = 4
                        end
                        
                        premiumHover = nil
                    end
                elseif cache["page"] == 7 then
                    if petButtonHover then 
                        if petButtonHover == 1 then 
                            local now = getTickCount()
                            if now <= lastClickTick + 500 then
                                return
                            end
                                
                            if isDescEditing or groupRenaming or groupCreating or isPickerRender or factionMessageEditing then
                                return
                            end
                            
                            playSound("assets/sounds/click.mp3")
                            lastClickTick = now

                            if localPlayer:getData("pet") then 
                                local id = playerPetInfos[3]
                                triggerLatentServerEvent("deSpawnPet", 5000, false, localPlayer, localPlayer, localPlayer:getData("pet").health)
                            else 
                                local id = playerPetInfos[3]
                                triggerLatentServerEvent("spawnPet", 5000, false, localPlayer, localPlayer, id)
                            end 
                        elseif petButtonHover == 2 then 
                            local blue = exports['cr_core']:getServerColor("yellow", true)
                            local white = "#F2F2F2"
                            
                            local r,g,b = exports['cr_core']:getServerColor("green")
                            local r2,g2,b2 = exports['cr_core']:getServerColor("red")
                            createAlert(
                                {
                                    ['headerText'] = 'Pet',
                                    ["title"] = {white .. "Biztosan "..blue.."felszeretnéd"..white.." éleszteni a petet? ("..blue.."500"..white.." PP)", 1},
                                    ["buttons"] = {
                                        {
                                            ["name"] = "Igen", 
                                            ["pressFunc"] = function()
                                                local pp = tonumber(localPlayer:getData("char >> premiumPoints")) or 0
                                                if pp >= 500 then
                                                    playerPetInfos[4] = 100
                                                    localPlayer:setData("char >> premiumPoints", pp - 500)
                                                    local id = playerPetInfos[3]
                                                    triggerLatentServerEvent("revivePet", 5000, false, localPlayer, localPlayer, id)
                                                else
                                                    exports['cr_infobox']:addBox("error", "Nincs elegendő PP-d ahhoz, hogy feléleszd a petet (500 PP)")
                                                end
                                            end,
                                            ["color"] = {r, g, b},
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
                        elseif petButtonHover == 3 then 
                            local blue = exports['cr_core']:getServerColor("yellow", true)
                            local red = exports['cr_core']:getServerColor("red", true)
                            local white = "#F2F2F2"
                            local r,g,b = exports['cr_core']:getServerColor("green")
                            local r2,g2,b2 = exports['cr_core']:getServerColor("red")

                            createAlert(
                                {
                                    ['headerText'] = 'Pet',
                                    ["title"] = {white .. "Gépeld be a kinek szeretnéd eladni a petet!", 1},
                                    ["buttons"] = {
                                        {
                                            ["type"] = "outputBox",
                                            ["color"] = {r, g, b},
                                            ["boxName"] = "PetNameBox",
                                            ["onCreate"] = function()
                                                CreateNewBar("PetNameBox", {0, 0, 0, 0}, {20, "", false, tocolor(242, 242, 242, 255), {"Poppins-Medium", 12}, 1, "center", "center", false, true}, 1, true)
                                            end,
                                        },

                                        {
                                            ["name"] = "Tovább", 
                                            ["pressFunc"] = function()
                                                local playerName = GetText("PetNameBox")
                                                player = exports['cr_core']:findPlayer(localPlayer, playerName, true)

                                                if player and isElement(player) then 
                                                    if player == localPlayer then 
                                                        exports['cr_infobox']:addBox("error", "Magadnak nem adhatod el!")
                                                        return 
                                                    end 

                                                    if getDistanceBetweenPoints3D(player.position, localPlayer.position) > 10 then 
                                                        exports['cr_infobox']:addBox("error", "A célpont túl messze van!")
                                                        return 
                                                    end 

                                                    RemoveBar("PetNameBox")
                                                    
                                                    createAlert(
                                                        {
                                                            ['headerText'] = 'Pet',
                                                            ["title"] = {white .. "Gépeld be mennyiért szeretnéd eladni petet!", 1},
                                                            ["buttons"] = {
                                                                {
                                                                    ["type"] = "outputBox",
                                                                    ["color"] = {r, g, b},
                                                                    ["boxName"] = "PetNumberBox",
                                                                    ["onCreate"] = function()
                                                                        CreateNewBar("PetNumberBox", {0, 0, 0, 0}, {20, "0", true, tocolor(242, 242, 242, 255), {"Poppins-Medium", 12}, 1, "center", "center", false, true}, 1, true)
                                                                    end,
                                                                },

                                                                {
                                                                    ["name"] = "Tovább", 
                                                                    ["pressFunc"] = function()
                                                                        price = tonumber(GetText("PetNumberBox"))
                                                                        if price and price >= 1 then 
                                                                            if player and isElement(player) then 
                                                                                RemoveBar("PetNumberBox")
                                                                                createAlert(
                                                                                    {
                                                                                        ['headerText'] = 'Pet',
                                                                                        ["title"] = {white .. "Biztosan elszeretnéd adni a petet "..blue..exports['cr_admin']:getAdminName(player)..white.."-nak/nek "..blue..price..white.."$ ért?"},
                                                                                        ["buttons"] = {
                                                                                            {
                                                                                                ["name"] = "Igen", 
                                                                                                ["pressFunc"] = function()
                                                                                                    triggerLatentServerEvent("inviteToTradePet", 5000, false, localPlayer, localPlayer, player, playerPetInfos[3], price)

                                                                                                    exports['cr_infobox']:addBox("success", "Sikeresen elküldted "..exports['cr_admin']:getAdminName(player).."-nak/nek az ajánlatot!")
                                                                                                end,
                                                                                                ["onCreate"] = function()
                                                                                                    player = player
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
                                                                            resetStartTickAlert()
                                                                            exports['cr_infobox']:addBox("error", "Az árnak egy számnak kell lennie mely nagyobb mint 0!")
                                                                        end 
                                                                    end,
                                                                    ["color"] = {r, g, b},
                                                                },

                                                                {
                                                                    ["name"] = "Mégse", 
                                                                    ["onClear"] = true,
                                                                    ["pressFunc"] = function()
                                                                        RemoveBar("PetNumberBox")
                                                                    end,
                                                                    ["color"] = {r2, g2, b2},
                                                                },
                                                            },
                                                        }
                                                    )
                                                else 
                                                    resetStartTickAlert()
                                                    exports['cr_infobox']:addBox("error", "Nincs találat "..playerName.."-ra/re!")
                                                end 
                                            end,
                                            ["color"] = {r, g, b},
                                        },

                                        {
                                            ["name"] = "Mégse", 
                                            ["onClear"] = true,
                                            ["pressFunc"] = function()
                                                RemoveBar("PetNameBox")
                                            end,
                                            ["color"] = {r2, g2, b2},
                                        },
                                    },
                                }
                            )
                        elseif petButtonHover == 4 then 
                            local blue = exports['cr_core']:getServerColor("yellow", true)
                            local red = exports['cr_core']:getServerColor("red", true)
                            local white = "#F2F2F2"
                            local r,g,b = exports['cr_core']:getServerColor("green")
                            local r2,g2,b2 = exports['cr_core']:getServerColor("red")
                            local price = petTypePrices[1]
                            local pets = {}
                            for k,v in pairs(petTypeNames) do 
                                table.insert(pets, tonumber(k))
                            end 

                            createAlert(
                                {
                                    ['headerText'] = 'Pet',
                                    ["isPetSelector"] = true,
                                    ["title"] = {white .. "Pet "..blue.."vásárlása", 1},
                                    ["buttons"] = {
                                        {
                                            ["type"] = "outputBox",
                                            ["color"] = {r, g, b},
                                            ["boxName"] = "PetNameBox",
                                            ["onCreate"] = function()
                                                CreateNewBar("PetNameBox", {0, 0, 0, 0}, {12, "Név", false, tocolor(242, 242, 242, 255), {"Poppins-Medium", 12}, 1, "center", "center", false, true}, 1, true)
                                            end,
                                        },

                                        {
                                            ["type"] = "showBox",
                                            ["specIcon"] = "cash",
                                            ["color"] = {r, g, b},
                                            ["text"] = yellow .. price .. " PP"
                                        },

                                        {
                                            ["type"] = "petSelector",
                                            ["name"] = "Vásárlás",
                                            ["now"] = 1,
                                            ["specData"] = pets,
                                            ["pressFunc"] = function()
                                                local name, price, modelid, typeName = GetText("PetNameBox"), petTypePrices[alerts["buttons"][3]["now"]], alerts["buttons"][3]["specData"][alerts["buttons"][3]["now"]], petTypeNames[alerts["buttons"][3]["specData"][alerts["buttons"][3]["now"]]]
                                                if name and tonumber(price) then 
                                                    RemoveBar("PetNameBox")
                                                    createAlert(
                                                        {
                                                            ['headerText'] = 'Pet',
                                                            ["title"] = {white .. "Biztosan "..blue.."megszeretnéd"..white.." venni a petet? (Név: "..blue..name..white..", Ár: "..blue..price.." PP "..white..", Típus: "..blue..typeName..white..")"},
                                                            ["buttons"] = {
                                                                {
                                                                    ["name"] = "Igen", 
                                                                    ["pressFunc"] = function()
                                                                        local pp = tonumber(localPlayer:getData("char >> premiumPoints")) or 0
                                                                        if pp >= price then
                                                                            localPlayer:setData("char >> premiumPoints", pp - price)
                                                                            triggerLatentServerEvent("createPet", 5000, false, localPlayer, localPlayer, modelid, name)
                                                                            exports['cr_infobox']:addBox("success", "Sikeresen megvásároltad a petet!")
                                                                        else
                                                                            exports['cr_infobox']:addBox("error", "Nincs elegendő PP-d ahhoz, hogy megvedd a petet ("..price.." PP)")
                                                                        end
                                                                    end,
                                                                    ["onCreate"] = function()
                                                                        name = name 
                                                                        price = price
                                                                        modelid = modelid
                                                                        typeName = typeName
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
                                                else 
                                                    resetStartTickAlert()
                                                    exports['cr_infobox']:addBox("error", "A név !")
                                                end 
                                            end,
                                            ["color"] = {r, g, b},
                                        },

                                        {
                                            ["name"] = "Mégse", 
                                            ["onClear"] = true,
                                            ["pressFunc"] = function()
                                                RemoveBar("PetNameBox")
                                            end,
                                            ["color"] = {r2, g2, b2},
                                        },
                                    },
                                }
                            )
                        end 

                        petButtonHover = nil 
                    elseif PetRenameHover then 
                        local e = petCache[PetHover]
                        if PetSearchCache then 
                            e = PetSearchCache[PetHover]
                        end 
                        if e then
                            local blue = exports['cr_core']:getServerColor("yellow", true)
                            local red = exports['cr_core']:getServerColor("red", true)
                            local white = "#F2F2F2"
                            local r,g,b = exports['cr_core']:getServerColor("green")
                            local r2,g2,b2 = exports['cr_core']:getServerColor("red")

                            createAlert(
                                {
                                    ['headerText'] = 'Pet',
                                    ["title"] = {white .. "Gépeld be mire szeretnéd átnevezni "..blue..(e[4])..white.." nevét ("..blue.."1000"..white.."ppbe fog kerülni)!", 1},
                                    ["buttons"] = {
                                        {
                                            ["type"] = "outputBox",
                                            ["color"] = {r, g, b},
                                            ["boxName"] = "PetNameBox",
                                            ["onCreate"] = function()
                                                petData = e
                                                CreateNewBar("PetNameBox", {0, 0, 0, 0}, {20, "", false, tocolor(242, 242, 242, 255), {"Poppins-Medium", 12}, 1, "center", "center", false, true}, 1, true)
                                            end,
                                        },

                                        {
                                            ["name"] = "Tovább", 
                                            ["pressFunc"] = function()
                                                local petName = GetText("PetNameBox")

                                                if petName and #petName >= 2 then 
                                                    if petName:lower() == petData[4]:lower() then 
                                                        exports['cr_infobox']:addBox("error", "A pet neve nem lehet ugyanaz mint azelőtt!")
                                                        return
                                                    end 

                                                    RemoveBar("PetNameBox")
                                                    createAlert(
                                                        {
                                                            ['headerText'] = 'Pet',
                                                            ["title"] = {white .. "Biztosan átszeretnéd nevezni a petet "..blue..petName..white.."-ra/re?!"},
                                                            ["buttons"] = {
                                                                {
                                                                    ["name"] = "Igen", 
                                                                    ["pressFunc"] = function()
                                                                        local pp = tonumber(localPlayer:getData("char >> premiumPoints")) or 0
                                                                        if pp >= 1000 then
                                                                            localPlayer:setData("char >> premiumPoints", pp - 1000)
                                                                            triggerLatentServerEvent("renamePet", 5000, false, localPlayer, localPlayer, petData, petName)
                                                                        else
                                                                            exports['cr_infobox']:addBox("error", "Nincs elegendő PP-d ahhoz, hogy átnevezd a petet (1000 PP)")
                                                                        end
                                                                    end,
                                                                    ["onCreate"] = function()
                                                                        petName = petName
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
                                                else 
                                                    resetStartTickAlert()
                                                    exports['cr_infobox']:addBox("error", "Minimum 2 karakterből kell álljon a pet új neve!")
                                                end 
                                            end,
                                            ["color"] = {r, g, b},
                                        },

                                        {
                                            ["name"] = "Mégse", 
                                            ["onClear"] = true,
                                            ["pressFunc"] = function()
                                                RemoveBar("PetNameBox")
                                            end,
                                            ["color"] = {r2, g2, b2},
                                        },
                                    },
                                }
                            )
                        end 
                    elseif PetHover then
                        local e = petCache[PetHover]
                        if PetSearchCache then 
                            e = PetSearchCache[PetHover]
                        end 
                        if e then
                            if PetSelected ~= PetHover then
                                PetSelected = PetHover
                                if e then 
                                    generatePetInformations(PetSelected)
                                end
                            else
                                PetSelected = nil
                                playerPetInfos = {}
                            end
                        end

                        PetHover = nil
                    end
                elseif cache["page"] == 8 then
                    if tonumber(optionsScrollHover) then 
                        local data = options[optionsSelected]["options"][optionsButtonScrolled]
                        if data then 
                            local oldValue = options[optionsSelected]["options"][optionsButtonScrolled]["nowValue"]
                            options[optionsSelected]["options"][optionsButtonScrolled]["nowValue"] = optionsScrollHover
                            if options[optionsSelected]["options"][optionsButtonScrolled]["onChange"] then 
                                options[optionsSelected]["options"][optionsButtonScrolled]["onChange"](oldValue, optionsScrollHover)
                            end 

                            optionsButtonScrolled = nil 
                            optionsScrollHover = nil 
                        end 
                    elseif tonumber(optionsFunctionHover) then 
                        local data = options[optionsSelected]["options"]
                        if data[optionsFunctionHover] then 
                            local now = getTickCount()
                            if now <= lastClickTick + 250 then
                                return
                            end
                                
                            if isDescEditing or groupRenaming or groupCreating or isPickerRender or factionMessageEditing then
                                return
                            end
                            
                            playSound("assets/sounds/click.mp3")
                            lastClickTick = now
                            
                            local val = data[optionsFunctionHover] 
                            if val["type"] == 1 or val["type"] == 2 then 
                                local oldValue = options[optionsSelected]["options"][optionsFunctionHover]["nowValue"]
                                options[optionsSelected]["options"][optionsFunctionHover]["nowValue"] = val["nowValue"] == 1 and 0 or 1
                                if options[optionsSelected]["options"][optionsFunctionHover]["onChange"] then 
                                    options[optionsSelected]["options"][optionsFunctionHover]["onChange"](oldValue, options[optionsSelected]["options"][optionsFunctionHover]["nowValue"])
                                end 
                            elseif val["type"] == 3 then 
                                local text = GetText(optionsFunctionHover .. ">>inputBar")
                                local oldValue = options[optionsSelected]["options"][optionsFunctionHover]["nowValue"]
                                options[optionsSelected]["options"][optionsFunctionHover]["nowValue"] = text
                                if options[optionsSelected]["options"][optionsFunctionHover]["onChange"] then 
                                    options[optionsSelected]["options"][optionsFunctionHover]["onChange"](oldValue, text)
                                end 
                            elseif val["type"] == 4 then 
                                moving = true 
                                movingNum = optionsFunctionHover
                            elseif val["type"] == 5 then 
                                if optionsButtonScrolled then 
                                    optionsButtonScrolled = nil 
                                else 
                                    optionsButtonScrolled = optionsFunctionHover
                                end 
                            end 
                        end 
                        optionsFunctionHover = nil 
                    elseif tonumber(optionsHover) then
                        optionsButtonAnimation[optionsSelected] = {getTickCount(), 2}
                        optionsButtonAnimation[tonumber(optionsHover)] = {getTickCount(), 1}

                        optionsSelected = tonumber(optionsHover)
                        optionsButtonScrolled = nil 

                        Clear()
                        local val = 2
                        for k,v in pairs(options[optionsSelected]["options"]) do 
                            if v["type"] == 3 then 
                                local text = ""
                                if v["getDefaultValue"] then 
                                    text = v["getDefaultValue"]()
                                end 
                                CreateNewBar(k .. ">>inputBar", {0, 0, 0, 0}, {25, text, false, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "center", false, true}, val)
                                val = val + 1
                            end 
                        end 
                        CreateNewBar("Options >> search", {0, 0, 0, 0}, {16, "", false, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "center", false, true}, 1)

                        optionsHover = nil
                    elseif arrowHover then
                        if arrowHover == "crosshairLeft" then 
                            if localPlayer:getData("char >> crosshair") - 1 > 0 then 
                                localPlayer:setData("char >> crosshair", localPlayer:getData("char >> crosshair") - 1)
                            end 
                        elseif arrowHover == "crosshairRight" then 
                            if fileExists(":cr_crosshair/files/"..(localPlayer:getData("char >> crosshair") + 1)..".png") then 
                                localPlayer:setData("char >> crosshair", localPlayer:getData("char >> crosshair") + 1)
                            end 
                        elseif arrowHover == "crosshairColor" then 
                            createPicker(
                                {
                                    ["old"] = {
                                        ["color"] = localPlayer:getData("char >> crosshairColor") or {255, 255, 255},
                                    },

                                    ["onEnter"] = function()
                                        destroyPicker()
                                        localPlayer:setData("char >> crosshairColor", pickerData["color"])
                                        --exports['cr_infobox']:addBox("success", "Sikeresen megváltoztattad a célkereszted színét!")
                                    end
                                }
                            )
                        elseif arrowHover == "avatarLeft" then 
                            if localPlayer:getData("char >> avatar") - 1 > 0 then 
                                localPlayer:setData("char >> avatar", localPlayer:getData("char >> avatar") - 1)
                            end 
                        elseif arrowHover == "avatarRight" then 
                            if fileExists(":cr_interface/hud/files/avatars/"..(localPlayer:getData("char >> avatar") + 1)..".png") then 
                                localPlayer:setData("char >> avatar", localPlayer:getData("char >> avatar") + 1)
                            end 
                        elseif arrowHover == "left" then
                            if optionsSelectMinLines - 1 >= 1 then
                                optionsSelectMinLines = optionsSelectMinLines - 1
                                optionsSelectMaxLines = optionsSelectMaxLines - 1
                            end
                        elseif arrowHover == "right" then
                            if optionsSelectMaxLines + 1 <= #options then
                                optionsSelectMinLines = optionsSelectMinLines + 1
                                optionsSelectMaxLines = optionsSelectMaxLines + 1
                            end
                        end
                        
                        arrowHover = nil
                    elseif searchHover then 
                        if GetText("Options >> search"):gsub(" ", "") ~= "" then
                            local text = string.lower(GetText("Options >> search"))

                            Clear()

                            optionsSearchCache = {}
                            for k, v in ipairs(options[optionsSelected]["options"]) do
                                local text2 = string.lower(v["name"])
            
                                if string.lower(tostring(text2)):find(text) then
                                    table.insert(optionsSearchCache, {
                                        ["id"] = k,
                                    })
                                end
                            end

                            if optionsSearchCache then
                                local val = 2
                                for k,v in pairs(optionsSearchCache) do 
                                    local id = v["id"]
                                    local v = options[optionsSelected]["options"][id]
                                    if v["type"] == 3 then 
                                        local text = ""
                                        if v["getDefaultValue"] then 
                                            text = v["getDefaultValue"]()
                                        end 
                                        CreateNewBar(id .. ">>inputBar", {0, 0, 0, 0}, {25, text, false, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "center", false, true}, val)
                                        val = val + 1
                                    end 
                                end 
                            end
                            CreateNewBar("Options >> search", {0, 0, 0, 0}, {16, "", false, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "center", false, true}, 1)
                        else
                            Clear()
                            local val = 2
                            for k,v in pairs(options[optionsSelected]["options"]) do 
                                if v["type"] == 3 then 
                                    local text = ""
                                    if v["getDefaultValue"] then 
                                        text = v["getDefaultValue"]()
                                    end 
                                    CreateNewBar(k .. ">>inputBar", {0, 0, 0, 0}, {25, text, false, tocolor(242, 242, 242, 255), {"Poppins-Medium", realFontSize[12]}, 1, "left", "center", false, true}, val)
                                    val = val + 1
                                end 
                            end 
                            CreateNewBar("Options >> search", {0, 0, 0, 0}, {16, "", false, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "center", false, true}, 1)
                        end

                        optionsButtonScrolled = nil
                        searchHover = nil 
                    end
                elseif cache["page"] == 9 then
                    if modPanelScrollingHover then
                        modPanelScrollingHover = false
                        modPanelScrolling = true
                    end
                    
                    if tonumber(clickHover) then
                        local now = getTickCount()
                        if now <= lastClickHoverTick + 500 then
                            return
                        end
                        
                        lastClickHoverTick = getTickCount()
                        
                        local turnableCache = exports['cr_json']:jsonGET("modpanel/turnabled", true, {}) or {}
                        local data = modPanelCache[tonumber(clickHover)]
                        if modPanelSearchCache then
                            data = modPanelSearchCache[tonumber(clickHover)]
                        end
                        
                        if data then
                            local id = data["id"]
                            if localPlayer.vehicle and localPlayer.vehicle.model == id then
                                return    
                            end
                            
                            if not turnableCache[tostring(id)] then -- bevan kapcsolva
                                if not exports['cr_vehicles']:isVirtualVehicle(tonumber(id)) then 
                                    turnableCache[tostring(id)] = true
                                    engineRestoreModel(id)
                                    data["state"] = false
                                else 
                                    exports['cr_infobox']:addBox('error', 'Ez a funkció virtuális kocsiknál nem elérhető!')
                                end 
                            else 
                                turnableCache[tostring(id)] = false
                                exports['cr_vehicles']:loadModel(id)
                                data["state"] = true
                            end
                        end
                        
                        exports['cr_json']:jsonSAVE("modpanel/turnabled", turnableCache, true)
                        clickHover = nil
                            
                        return
                    elseif clickHover == "allOff" then
                        local now = getTickCount()
                        if now <= lastClickHoverTick + 1500 then
                            return
                        end
                        
                        lastClickHoverTick = getTickCount()
                        
                        local turnableCache = exports['cr_json']:jsonGET("modpanel/turnabled", true, {}) or {}
                        
                        for i = 1, #modPanelCache do
                            local data = modPanelCache[i]
                            if data then
                                if data["state"] then
                                    local id = data["id"]
                                    if localPlayer.vehicle and localPlayer.vehicle.model == id then
                                        return    
                                    end

                                    if not exports['cr_vehicles']:isVirtualVehicle(tonumber(id)) then 
                                        turnableCache[tostring(id)] = true
                                        engineRestoreModel(id)
                                        modPanelCache[i]["state"] = false
                                    end 
                                end
                            end
                        end
                        
                        exports['cr_json']:jsonSAVE("modpanel/turnabled", turnableCache, true)
                        clickHover = nil
                            
                        return
                    elseif clickHover == "allIn" then
                        local now = getTickCount()
                        if now <= lastClickHoverTick + 1500 then
                            return
                        end
                        
                        lastClickHoverTick = getTickCount()
                        
                        local turnableCache = exports['cr_json']:jsonGET("modpanel/turnabled", true, {}) or {}
                        
                        for i = 1, #modPanelCache do
                            local data = modPanelCache[i]
                            if data then
                                if not data["state"] then
                                    local id = data["id"]
                                    if localPlayer.vehicle and localPlayer.vehicle.model == id then
                                        return    
                                    end

                                    turnableCache[tostring(id)] = false
                                    exports['cr_vehicles']:loadModel(id)
                                    modPanelCache[i]["state"] = true
                                end
                            end
                        end
                        
                        exports['cr_json']:jsonSAVE("modpanel/turnabled", turnableCache, true)
                        clickHover = nil
                            
                        return
                    end
                    
                    if tonumber(selectedHover) then
                        modPanelSelected = tonumber(selectedHover)
                        selectedHover = nil
                    end
                end
            end
        elseif b == "left" and s == "up" then
            if moving then
                moving = false
            end

            if VehicleScrolling then
                VehicleScrolling = false
            end
            
            if InteriorScrolling then
                InteriorScrolling = false
            end
            
            if VehicleInfoScrolling then
                VehicleInfoScrolling = false
            end
            
            if InteriorInfoScrolling then
                InteriorInfoScrolling = false
            end
            
            if PremiumBuyScrolling then
                PremiumBuyScrolling = false
            end

            if factionMembersScrolling then 
                factionMembersScrolling = false
            end 

            if factionRanksScrolling then 
                factionRanksScrolling = false
            end 

            if FactionVehicleScrolling then 
                FactionVehicleScrolling = false 
            end 

            if FactionVehicleInfoScrolling then 
                FactionVehicleInfoScrolling = false 
            end 

            if FactionLogsScrolling then 
                FactionLogsScrolling = false
            end 

            if FactionSelectorScrolling then 
                FactionSelectorScrolling = false
            end 

            if FactionInformationsScrolling then 
                FactionInformationsScrolling = false
            end 
            
            if modPanelScrolling then
                modPanelScrolling = false
            end
        end
    end
)

function startDescriptionEdit()
    --closeDash()
    local desc = cache["playerDatas"]["description"] or ""
    CreateNewBar("Desc >> Edit", {0, 0, 0, 0}, {179, desc, false, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "top", false, false, true}, 1, true)
    isDescEditing = true
    cache["playerDatas"]["description"] = ""
    --bindKey("enter", "down", endDescriptionEdit)
end

function nationalityNumToString(e)
    e = tonumber(e)
    if e == 1 then
        return "európai"
    elseif e == 2 then
        return "amerikai"
    elseif e == 3 then
        return "ázsiai"
    else
        return "afrikai"
    end
end

function endDescriptionEdit()
    --unbindKey("enter", "down", endDescriptionEdit)
    isDescEditing = false
    local val = exports['cr_chat']:findSwear(GetText("Desc >> Edit")) or GetText("Desc >> Edit")

    if #val == 0 or val == "" or val == " " then
        local details = localPlayer:getData("char >> details")
        local a = "Ő egy XX cm magas, XY kg súlyú, XZ éves, XO nemzetiségű ember!"
        a = a:gsub("XX", details["height"])
        a = a:gsub("XY", details["weight"])
        a = a:gsub("XZ", details["age"])
        a = a:gsub("XO", nationalityNumToString(details["nationality"]))
        val = a
    end
    cache["playerDatas"]["description"] = val
    RemoveBar("Desc >> Edit") --Clear()
    localPlayer:setData("char >> description", val)
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function dutySelectorLeft()
    if dutySelectorNow - 1 >= 1 then 
        dutySelectorNow = dutySelectorNow - 1
        skinid = factionDutySkinData[cache["playerDatas"]["faction"][selectedFaction][1]]["skins"][dutySelectorNow]

        gPed:setData("ped >> skin", skinid)
    end 
end 

function dutySelectorRight()
    if dutySelectorNow + 1 <= #factionDutySkinData[cache["playerDatas"]["faction"][selectedFaction][1]]["skins"] then 
        dutySelectorNow = dutySelectorNow + 1
        skinid = factionDutySkinData[cache["playerDatas"]["faction"][selectedFaction][1]]["skins"][dutySelectorNow]
        
        gPed:setData("ped >> skin", skinid)
    end 
end 

function dutySelectorFinish()
    if factionDutySkinData[cache["playerDatas"]["faction"][selectedFaction][1]]["skins"][dutySelectorNow] then 
        triggerLatentServerEvent("updatePlayerDutySkin", 5000, false, localPlayer, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], factionDutySkinData[cache["playerDatas"]["faction"][selectedFaction][1]]["skins"][dutySelectorNow], factionDutySkinData[cache["playerDatas"]["faction"][selectedFaction][1]]["instantset"])
        dutySelectorCancel()
    end 
end 

function dutySelectorCancel()
    gPed:destroy()
    dutySelectorNow = nil 
    dutySelecting = nil
    setCameraTarget(localPlayer, localPlayer)
    exports['cr_controls']:toggleAllControls(true, "instant")

    localPlayer.dimension = defaultPlayerDimension
    localPlayer.alpha = defaultPlayerAlpha

    defaultPlayerAlpha = false
    defaultPlayerDimension = false

    unbindKey("arrow_l", "down", dutySelectorLeft)
    unbindKey("arrow_r", "down", dutySelectorRight)
    unbindKey("backspace", "down", dutySelectorCancel)
    unbindKey("enter", "down", dutySelectorFinish)

    openDash(localPlayer, 3)
end 