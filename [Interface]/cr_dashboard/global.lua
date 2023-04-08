if type(triggerServerEvent) == "function" then -- Client
    textures = {}
    
    buttonAnimation = {}
    factionButtonAnimation = {}
    premiumButtonAnimation = {}
    optionsButtonAnimation = {}

    menus = {
        --{name, description, iconPath, pressFunction, swithFunction}
        {"Vagyon", "Ezen a felületen tudod megnézni milyen vagyontárgyaid vannak. Ilyen vagyon tárgyak: a járművek, az ingatlanok, valamint a garázsok Mindezek mellett plusz slotot is tudsz vásárolni.", "property", 
            function(i)
                CreateNewBar("VehSlot >> buy", {0, 0, 0, 0}, {3, "", true, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "center", false, true}, 1)
                CreateNewBar("IntSlot >> buy", {0, 0, 0, 0}, {3, "", true, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "center", false, true}, 1)
                getPlayerVehicles()
                getPlayerInterior()
                cache["page"] = 2
                BindScrollBarKeys()
            end,

            function(i)
                Clear()
                destroyPlayerVehicles()
                destroyPlayerInterior()
                unBindScrollBarKeys()
            end,
        },

        {"Frakció", "Ezen a felületen tudod megnézni milyen frakcióhoz tartozol illetve ha leader vagy akkor a teljes frakciót tudod módositani mint például tagokat felvenni, kirúgni vagy esetleg fel/lefokozni.", "faction", 
            function(i)
                if cache["element"] == localPlayer then 
                    CreateNewBar("FactionBank >> Edit", {0, 0, 0, 0}, {10, "0", true, tocolor(242, 242, 242, 255), {"Poppins-Medium", realFontSize[12]}, 1, "left", "center", false, true}, 1)
                    factionsSelected = 1
                    cache["page"] = 3
                    BindScrollBarKeys()
                    if cache["playerDatas"]["faction"][selectedFaction] then 
                        generateFactionInformations(cache["playerDatas"]["faction"][selectedFaction])
                        getFactionVehicles(cache["playerDatas"]["faction"][selectedFaction][1])
                    end

                    if cache["playerDatas"]["faction"][selectedFaction] and cache["playerDatas"]["faction"][selectedFaction][1] then 
                        triggerLatentServerEvent("openFactionPanel", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], localPlayer)
                    end 
                end
            end,

            function(i)
                Clear()
                unBindScrollBarKeys()
                destroyFactionVehicles()
                if cache["playerDatas"]["faction"][selectedFaction] and cache["playerDatas"]["faction"][selectedFaction][1] then 
                    triggerLatentServerEvent("closeFactionPanel", 5000, false, localPlayer, cache["playerDatas"]["faction"][selectedFaction][1], localPlayer)
                end
            end,
        },

        {"Adminok", "Ezen a felületen tudod megnézni milyen szintű adminok vannak fent a szerveren illetve szolgálatban vannak-e, ha igen akkor nincs más dolgod mint /pm id parancsal írni neki.", "admins", 
            function(i)
                if cache["element"] == localPlayer then 
                    cache["page"] = 4
                    BindScrollBarKeys()
                    generateAdminCache(adminSelectedMenu)
                    CreateNewBar("Admin >> search", {0, 0, 0, 0}, {16, "", false, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "center", false, true}, 1)
                end
            end,

            function(i)
                Clear()
                destroyAdminCache()
                unBindScrollBarKeys()
            end,
        },

        {"Csoport", "Ezen a felületen tudod megnézni milyen csoportban vagy, illetve kezelni. Megtudod nézni mikor voltak a tagok utoljára fent és hol léptek ki. Valamint vezetőt is tudsz kinevezni.", "group", 
            function(i)
                if cache["element"] == localPlayer then 
                    cache["page"] = 5
                    BindScrollBarKeys()
                    CreateNewBar("Group >> search", {0, 0, 0, 0}, {30, "", false, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "center", false, true}, 1)
                    if tonumber(cache["element"]:getData("char >> group")) then 
                        triggerLatentServerEvent("openPanel", 5000, false, localPlayer, tonumber(cache["element"]:getData("char >> group")), localPlayer)
                    end 
                end
            end,

            function(i)
                Clear()
                unBindScrollBarKeys()
                if tonumber(cache["element"]:getData("char >> group")) then 
                    triggerLatentServerEvent("closePanel", 5000, false, localPlayer, tonumber(cache["element"]:getData("char >> group")), localPlayer)
                end 
            end,
        },

        {"Támogatás", "Ezen a felületen tudod megnézni milyen itemeket tudsz prémium pontért venni. Illetve egy kisebb információt is tartalmaz a panel a támogatásról.", "donate", 
            function(i)
                if cache["element"] == localPlayer then 
                    premiumSelected = 1
                    cache["page"] = 6
                    BindScrollBarKeys()
                end
            end,

            function(i)
                unBindScrollBarKeys()
            end,
        },

        {"Állatok", "Ezen a felületen tudod megnézni milyen kutyáid vannak, valamint ezeket tudod kezelni vagy esetleg venni még többet.", "pet", 
            function(i)
                if cache["element"] == localPlayer then 
                    cache["page"] = 7
                    PetSelected = nil
                    playerPetInfos = {}
                    BindScrollBarKeys()
                    CreateNewBar("Pet >> search", {0, 0, 0, 0}, {30, "", false, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "center", false, true}, 1)
                    getPlayerPetData(cache["element"])
                end
            end,

            function(i)
                Clear()
                unBindScrollBarKeys()
            end,
        },

        {"Beállítások", "Ezen a felületen találhatod a szerver beállításait. Lehetőséged van sok beállítás típus közül válogatni és testreszabni azokat.", "options", 
            function(i)
                if cache["element"] == localPlayer then 
                    optionsButtonScrolled = nil 
                    cache["page"] = 8
                    local val = 2
                    optionsSelected = 1
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
                    BindScrollBarKeys()
                    CreateNewBar("Options >> search", {0, 0, 0, 0}, {16, "", false, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "center", false, true}, 1)
                end
            end,

            function(i)
                Clear()
                unBindScrollBarKeys()
            end,
        },

        {"Modpanel", "Ezen a felületen tudod megnézni milyen autókon vannak modok és azokat kikapcsolni egyesével vagy az összeset.", "modpanel", 
            function(i)
                if cache["element"] == localPlayer then 
                    CreateNewBar("ModPanel >> search", {0, 0, 0, 0}, {25, "", false, tocolor(242, 242, 242, 255), {"Poppins-Regular", realFontSize[12]}, 1, "left", "center", false, true}, 1)
                    getModPanelCache()
                    cache["page"] = 9
                    BindScrollBarKeys()
                end
            end,

            function(i)
                Clear()
                unBindScrollBarKeys()
            end,
        },
    }

    iconSizes = {
        ['overview'] = {20, 20},
        ['property'] = {12, 20},
        ['faction'] = {20, 13},
        ['admins'] = {20, 14},
        ['group'] = {20, 21},
        ['donate'] = {20, 20},
        ['pet'] = {20, 20},
        ['options'] = {20, 20},
        ['modpanel'] = {20, 20},
    }
    
    VehicleMinLines = 1
    VehicleMaxLines = 7
    VehicleNeedSync = false  
    
    function getVehicleDatas(v)
        local tbl = {}
        tbl["model"] = v.model
        tbl["name"] = exports['cr_vehicle']:getVehicleName(v.model)
        tbl["id"] = v:getData("veh >> id")
        tbl["health"] = math.floor(v.health / 10)
        tbl["locked"] = v:getData("veh >> locked")
        return tbl
    end
    
    function updateHealth()
        if playerVehiclesData then 
            for k,v in pairs(playerVehiclesData) do
                if isElement(k) then 
                    if math.floor(k.health / 10) ~= v["health"] then
                        playerVehiclesData[k]["health"] = math.floor(k.health / 10)
                    end
                end
            end
        end 

        if playerFactionVehiclesData then 
            for k,v in pairs(playerFactionVehiclesData) do
                if isElement(k) then 
                    if math.floor(k.health / 10) ~= v["health"] then
                        playerFactionVehiclesData[k]["health"] = math.floor(k.health / 10)
                    end
                end
            end
        end 
    end
    
    modPanelSelected = 1
    modPanelInfoMinLines = 1
    modPanelInfoMaxLines = 15
    modPanelCache = {}
    
    function getModData(e)
        local tbl = {}
        tbl["name"] = exports['cr_vehicle']:getVehicleName(e)
        tbl["defname"] = getVehicleNameFromModel(e)
        tbl["id"] = e
        tbl["size"] = exports['cr_vehicles']:getModelSize(e) or 0
        tbl["dff"] = exports['cr_vehicles']:getModelTypSize(e, "dff") or 0
        tbl["txd"] = exports['cr_vehicles']:getModelTypSize(e, "txd") or 0
        tbl["state"] = not turnableCache[tostring(e)]
        
        return tbl
    end
    
    function getModPanelCache()
        turnableCache = exports['cr_json']:jsonGET("modpanel/turnabled", true, {}) or {}
        modPanelCache = {}
        local cache = exports['cr_vehicles']:getLoadCache()
        
        for k,v in pairs(cache) do
            local model, fileSrc, typ, isGlass = unpack(v)
            if typ == "dff" then
                if tonumber(model) then
                    if exports['cr_vehicle']:getVehicleName(model) then
                        local data = getModData(model)
                        table.insert(modPanelCache, data)
                    end
                end
            end
        end
        
        table.sort(modPanelCache, function(a, b)
            if a["id"] and b["id"] then
                return tonumber(a["id"]) < tonumber(b["id"])
            end
        end);
    end
    
    function getPlayerVehicles()
        vehSelected = nil
        playerVehicleInfos = {}
        VehicleNeedSync = true
        playerVehicles = {}
        playerVehiclesData = {}
        
        for k,v in pairs(getElementsByType("vehicle")) do
            if v:getData("veh >> owner") == cache["element"]:getData("acc >> id") then
                --if v:getData("veh >> id") > 0 then 
                    if tonumber(v:getData("veh >> faction") or 0) <= 0 then 
                        playerVehiclesData[v] = getVehicleDatas(v)
                        table.insert(playerVehicles, v)
                    end
                --end
            end
        end
        
        table.sort(playerVehicles, function(a, b)
            if a:getData("veh >> id") and b:getData("veh >> id") then
                return tonumber(a:getData("veh >> id")) < tonumber(b:getData("veh >> id"))
            end
        end);
        
        healthUpdateTimer = setTimer(updateHealth, 20 * 1000, 0)

        return playerVehicles
    end
    
    function destroyPlayerVehicles()
        vehSelected = nil
        playerVehicleInfos = {}
        if isTimer(healthUpdateTimer) then killTimer(healthUpdateTimer) end
        VehicleNeedSync = false
        playerVehicles = {}
        playerVehiclesData = {}
    end
    
    playerVehicleInfos = {}
    playerInteriorInfos = {}
    
    function generateVehicleInformations(e)
        local green = exports['cr_core']:getServerColor("green", true)
        local red = exports['cr_core']:getServerColor("red", true)
        local orange = exports['cr_core']:getServerColor("orangeNew", true)
        local yellow = exports['cr_core']:getServerColor("yellow", true)
        local blue = exports['cr_core']:getServerColor('yellow', true)

        local tuningData = e:getData("veh >> tuningData") or {}

        playerVehicleInfos = {}
        table.insert(playerVehicleInfos, "ID: ".. blue .. e:getData("veh >> id"))

        if e:getData("veh >> id") < 0 then 
            table.insert(playerVehicleInfos, "Típus: ".. orange .. exports['cr_vehicle']:convertTemporaryType(tonumber(e:getData("veh >> temporaryType") or 1)))
            table.insert(playerVehicleInfos, "Létrehozás dátum: ".. blue .. (e:getData("veh >> createTime") or ''):gsub('[[]', ''):gsub('[]]', ''))
        end 

        local healthColor = green
        if (e.health / 10) <= 75 then 
            healthColor = yellow
        elseif (e.health / 10) <= 50 then 
            healthColor = red 
        end 
        local healthText = "Állapot: " .. healthColor .. math.ceil(e.health / 10) .. "%"
        table.insert(playerVehicleInfos, healthText)

        local healthColor = green
        if ((e:getData("veh >> fuel") / tonumber(exports['cr_vehicle']:getVehicleMaxFuel(e.model) or 100)) * 100) <= 25 then 
            healthColor = red 
        elseif ((e:getData("veh >> fuel") / tonumber(exports['cr_vehicle']:getVehicleMaxFuel(e.model) or 100)) * 100) <= 75 then 
            healthColor = yellow
        end 
        local healthText = "Üzemanyag: " .. healthColor .. math.ceil((e:getData("veh >> fuel") / tonumber(exports['cr_vehicle']:getVehicleMaxFuel(e.model) or 100) * 100))  .. "%" .. " (" .. math.ceil(e:getData("veh >> fuel")) .. "/" .. tonumber(exports['cr_vehicle']:getVehicleMaxFuel(e.model) or 100) .. " l)"
        table.insert(playerVehicleInfos, healthText)

        table.insert(playerVehicleInfos, "Kilóméterszámláló állása: " .. blue .. math.round(e:getData("veh >> odometer"), 1) .. " KM")

        table.insert(playerVehicleInfos, "Rendszám: " .. blue .. e.plateText)
        table.insert(playerVehicleInfos, "Alvázszám: " .. orange .. e:getData("veh >> chassis"))

        table.insert(playerVehicleInfos, "Motor: "..(e:getData("veh >> engine") and green .. "Elindítva" or red .. "Leállítva"))
        table.insert(playerVehicleInfos, "Lámpa: "..(e:getData("veh >> light") and green .. "Felkapcsolva" or red .. "Lekapcsolva"))
        table.insert(playerVehicleInfos, "Kézifék: "..(e:getData("veh >> handbrake") and green .. "Behúzva" or red .. "Kiengedve"))
        table.insert(playerVehicleInfos, "Motor: ".. orange .. tonumber(tuningData["engine"] or 0))
        table.insert(playerVehicleInfos, "Turbó: ".. orange .. tonumber(tuningData["turbo"] or 0))
        table.insert(playerVehicleInfos, "ECU: ".. orange .. tonumber(tuningData["ecu"] or 0))
        table.insert(playerVehicleInfos, "Váltó: ".. orange .. tonumber(tuningData["gearbox"] or 0))
        table.insert(playerVehicleInfos, "Felfüggesztés: ".. orange .. tonumber(tuningData["suspension"] or 0))
        table.insert(playerVehicleInfos, "Fékek: ".. orange .. tonumber(tuningData["brakes"] or 0))
        table.insert(playerVehicleInfos, "Súlycsökkentés: ".. orange .. tonumber(tuningData["weight"] or 0))
        table.insert(playerVehicleInfos, "Nitró: ".. ((tonumber(tuningData["nitro"] or 0) == 1) and green .. "Van " .. "(" .. tonumber(tuningData["nitroLevel"] or 1) * 100 .. "%)" or red .. "Nincs"))
        table.insert(playerVehicleInfos, "AirRide: ".. ((tonumber(tuningData["airride"] or 0) == 1) and green .. "Van" or red .. "Nincs"))
        table.insert(playerVehicleInfos, "Hidraulika: ".. ((tonumber(tuningData["optical.9"] or 0) == 1) and green .. "Van" or red .. "Nincs"))
        table.insert(playerVehicleInfos, "Backfire: ".. ((tonumber(tuningData["backfire"] or 0) == 1) and green .. "Van" or red .. "Nincs"))
        table.insert(playerVehicleInfos, "Traffi radar: ".. ((tonumber(tuningData["traffiradar"] or 0) == 1) and green .. "Van" or red .. "Nincs"))
        table.insert(playerVehicleInfos, "AntiSteal: ".. ((tonumber(tuningData["stealwarning"] or 0) == 1) and green .. "Van" or red .. "Nincs"))
        table.insert(playerVehicleInfos, "GPS: ".. ((tonumber(tuningData["gps"] or 0) == 1) and green .. "Van" or red .. "Nincs"))

        local neonNames = exports['cr_tuning']:getNeonNames()
        table.insert(playerVehicleInfos, "Neon: ".. ((tonumber(tuningData["neon"] or 0) >= 1) and green .. "Van " .. "(" .. neonNames[tonumber(tuningData["neon"] or 0)][2] .. ")" or red .. "Nincs"))
    end    
        
    function generateInteriorInformations(e)
        local green = exports['cr_core']:getServerColor("green", true)
        local red = exports['cr_core']:getServerColor("red", true)
        local orange = exports['cr_core']:getServerColor("orangeNew", true)
        local yellow = exports['cr_core']:getServerColor("yellow", true)
        local blue = exports['cr_core']:getServerColor('yellow', true)

        playerInteriorInfos = {}

        local markerData = e:getData("marker >> data") or {}
        table.insert(playerInteriorInfos, "ID: ".. blue .. markerData["id"])
        table.insert(playerInteriorInfos, "Név: ".. orange .. markerData["name"])
        table.insert(playerInteriorInfos, "Típus: ".. blue .. exports['cr_interior']:convertInteriorType(markerData["type"]))
        table.insert(playerInteriorInfos, "Zárva: ".. (markerData["locked"] and green .. "Igen" or red .. "Nem"))
    end
    
    intSelected = nil
    vehSelected = nil
    
    InteriorInfoMinLines = 1
    InteriorInfoMaxLines = 7
    
    VehicleInfoMinLines = 1
    VehicleInfoMaxLines = 7
    
    InteriorMinLines = 1
    InteriorMaxLines = 7
    InteriorNeedSync = false  
    
    function getInteriorDatas(v)
        local tbl = {}
        local markerData = v:getData("marker >> data")
        tbl["name"] = markerData["name"]
        tbl["id"] = markerData["id"]
        tbl["locked"] = markerData["locked"]
        tbl["type"] = markerData["type"]
        return tbl
    end
    
    function getPlayerInterior()
        intSelected = nil
        playerInteriorInfos = {}
        InteriorNeedSync = true
        playerInterior = {}
        playerInteriorData = {}
        
        for k,v in pairs(getElementsByType("marker")) do
            if v:getData("marker >> data") then 
                if v:getData("marker >> data")["owner"] == cache["element"]:getData("acc >> id") then
                    playerInteriorData[v] = getInteriorDatas(v)
                    table.insert(playerInterior, v)
                end
            end
        end
        
        table.sort(playerInterior, function(a, b)
            if a:getData("marker >> data")["id"] and b:getData("marker >> data")["id"] then
                return tonumber(a:getData("marker >> data")["id"]) < tonumber(b:getData("marker >> data")["id"])
            end
        end);

        return playerInterior
    end
    
    function destroyPlayerInterior()
        intSelected = nil
        playerInteriorInfos = {}
        InteriorNeedSync = false
        playerInterior = {}
        playerInteriorData = {}
    end

    cache = {
        ["playerDatas"] = {},
        ["element"] = localPlayer,
    }
    sx, sy = guiGetScreenSize()

    dxDrawMultipler = math.min(1.25, sx / 1280)

    function respc(a)
        return a * dxDrawMultipler
    end 
    
    selectedFaction = 1
    selectedGroup = 1
    
    PremiumMinLines = 1
    PremiumMaxLines = 5
    
    PremiumBuyMinLines = 1
    PremiumBuyMaxLines = 4
    
    premiumSelected = 1
    
    local accountId = "Account ID"

    if localPlayer then 
        accountId = localPlayer:getData("acc >> id") or "Account ID"
    end

    PremiumInfoData = {
        {
            ["name"] = "Bronz csomag",
            ["color"] = {183, 135, 0, "#B78700"},
            ["text"] = "csrp.hu/premium\nPrefix: CSRP - #B78700" .. accountId .. "\n#ffffffPayPal Ár: #B787001000#ffffff HUF\nPrémiumPont: #B787001000#ffffff PP\n#B787000%#ffffff MEGTAKARÍTÁS"
        },
        {
            ["name"] = "Ezüst csomag",
            ["color"] = {100, 100, 100, "#646464"},
            ["text"] = "csrp.hu/premium\nPrefix: CSRP - #646464" .. accountId .. "\n#ffffffPayPal Ár: #6464642500#ffffff HUF\nPrémiumPont: #6464643000#ffffff PP\n#64646425%#ffffff MEGTAKARÍTÁS"
        },
        {
            ["name"] = "Arany csomag",
            ["color"] = {255, 209, 26, "#ffd11a"},
            ["text"] = "csrp.hu/premium\nPrefix: CSRP - #ffd11a" .. accountId .. "\n#ffffffPayPal Ár: #ffd11a5000#ffffff HUF\nPrémiumPont: #ffd11a7500#ffffff PP\n#ffd11a66%#ffffff MEGTAKARÍTÁS"
        },
        {
            ["name"] = "Gyémánt csomag",
            ["color"] = {36, 109, 208, "#246dd0"},
            ["text"] = "csrp.hu/premium\nPrefix: CSRP - #246dd0" .. accountId .. "\n#ffffffPayPal Ár: #246dd08500#ffffff HUF\nPrémiumPont: #246dd010000#ffffff PP\n#246dd085%#ffffff MEGTAKARÍTÁS"
        },
    }
    
    PremiumData = {
        {
            ["name"] = "Fegyverek",
            ["icon"] = "",
            ["items"] = {
				{31, 1, 1, 500},
                {32, 1, 1, 500},
				{48, 1, 1, 700},
				{38, 1, 1, 500},
				{44, 1, 1, 15000},
                {41, 1, 1, 1500},
                {49, 1, 1, 2200},
				{50, 1, 1, 2500},
                {51, 1, 1, 3000},
                {52, 1, 1, 4500},
				{53, 1, 1, 4500},
				{54, 1, 1, 6000},
                {55, 1, 1, 4000},
                {56, 1, 1, 5500},
                {57, 1, 1, 5000},
                {58, 1, 1, 6000},
                {59, 1, 1, 3000},
                {60, 1, 1, 6000},
                {61, 1, 1, 9000},
				{65, 1, 1, 3000},
				{66, 1, 1, 5},
				{67, 1, 1, 7},
				{69, 1, 1, 15},
				{68, 1, 1, 10},
				{71, 1, 1, 10},
				{70, 1, 1, 20},
            },
        },
        
        {
            ["name"] = "Skines fegyverek",
            ["icon"] = "",
            ["items"] = {
                {44, 2, 1, 20000},--Katana
                {41, 2, 1, 4500},--Kés
				{41, 3, 1, 3000},--Kés
                {49, 2, 1, 7000},--Glock
				{49, 3, 1, 5000},--Glock
				{49, 4, 1, 4000},--Glock
                {50, 2, 1, 7000},--Silenced
				{50, 3, 1, 6500},--Silenced
                {51, 2, 1, 8500},--Deagle
				{51, 3, 1, 7500},--Deagle
				{51, 4, 1, 7000},--Deagle
				{51, 5, 1, 7500},--Deagle
                {52, 2, 1, 6000},--Sörétes
                {53, 2, 1, 9500},--Lefűrészelt
				{53, 3, 1, 8500},--Lefűrészelt
                --{54, 1, 1, 6000},--Spaz
                {55, 2, 1, 6000},--Uzi
                {56, 2, 1, 8000},--Mp5
				{57, 2, 1, 8500},--AK
				{57, 3, 1, 8000},--AK
				{57, 4, 1, 7500},--AK
				{58, 2, 1, 10000},--M4
				{58, 3, 1, 9000},--M4
				{58, 4, 1, 8500},--M4
				{58, 5, 1, 8300},--M4
				{58, 6, 1, 8000},--M4
				{58, 7, 1, 8500},--M4
				{59, 2, 1, 6600},--TEC
				{61, 2, 1, 12000},--SNIPER
            },
        },
        
        {
            ["name"] = "Itemek/kártyák",
            ["icon"] = "",
            ["items"] = {
				{109, 1, 1, 10},
				{139, 1, 1, 150},
				{140, 1, 1, 150},
				{141, 1, 1, 100},
				{143, 1, 1, 100},
				{155, 1, 1, 100},
				{156, 1, 1, 100},
				{158, 1, 1, 100},
				{72, 1, 1, 1500},
				{82, 1, 1, 2500},
            },
        },
        
        {
            ["name"] = "Mester könyvek",
            ["icon"] = "",
            ["items"] = {
				{160, 1, 1, 1000},
                {161, 1, 1, 1500},
                {162, 1, 1, 2000},
				{163, 1, 1, 2500},
				{164, 1, 1, 3000},
				{165, 1, 1, 3000},
				{166, 1, 1, 2000},
				{167, 1, 1, 2500},
				{168, 1, 1, 3000},
				{169, 1, 1, 3000},
                {170, 1, 1, 4000},
            },
        },
        {
            ["name"] = "Drogok",
            ["icon"] = "",
            ["items"] = {
				{14, 1, 1, 80},
                {13, 1, 1, 90},
				{199, 1, 1, 100},
            },
        },
        {
            ["name"] = "Pénz vásárlás",
            ["icon"] = "",
            ["items"] = {
                {159, 10000, 1, 3000},
                {159, 50000, 1, 10000},
                {159, 100000, 1, 30000},
                {159, 500000, 1, 50000},
            },
        },
		--[[{
            ["name"] = "Blueprintek",
            ["icon"] = "",
            ["items"] = {
                {172, 1, 1, 500},
                {173, 1, 1, 500},
                {174, 1, 1, 500},
                {175, 1, 1, 500},
				{176, 1, 1, 500},
				{177, 1, 1, 500},
				{178, 1, 1, 500},
				{179, 1, 1, 500},
				{180, 1, 1, 500},
            },
        },]]
    }
    
    adminSelectedMenu = 1
    AdminMinLines = 1
    AdminMaxLines = 16
    AdminNeedSync = false
    
    adminLevels = {
        "AdminSegéd",
        "Admin(1)",
        "Admin(2)",
        "Admin(3)",
        "Admin(4)",
        "Admin(5)",
        "FőAdmin",
        "SuperAdmin",
    }
    
    adminCache = {}
    adminCacheKey = {}
    
    function getAdminDatas(e)
        local tbl = {}
        tbl["nick"] = exports['cr_admin']:getAdminName(e, true)
        tbl["duty"] = exports['cr_admin']:getAdminDuty(e)
        tbl["id"] = e:getData("char >> id")
        
        return tbl
    end
    
    function generateAdminCache(page)
        destroyAdminCache()
        AdminNeedSync = true
        local needLevel = adminPageLevels[page]
        
        for k,v in pairs(getElementsByType("player")) do
            if type(needLevel) == "number" and tonumber(v:getData("admin >> level") or 0) == needLevel then 
                adminCache[v] = getAdminDatas(v)
                table.insert(adminCacheKey, v)
            elseif type(needLevel) == "string" then
                if tonumber(v:getData("admin >> level") or 0) == 1 or tonumber(v:getData("admin >> level") or 0) == 2 then 
                    adminCache[v] = getAdminDatas(v)
                    table.insert(adminCacheKey, v)
                end
            end
        end
        
        table.sort(adminCacheKey, function(a, b)
            if a:getData("acc >> id") and b:getData("acc >> id") then
                return tonumber(a:getData("acc >> id")) < tonumber(b:getData("acc >> id"))
            end
        end);
    end
    
    function destroyAdminCache()
        AdminNeedSync = false
        adminCache = {}
        adminCacheKey = {}
    end
    
    adminLevelsData = {
        1, -- idg as
        2, -- as
        3, -- admin 1
        4, -- admin 2
        5, -- admin 3
        6, -- admin 4
        7, -- admin 5
        8, -- fa
        9, -- sa
    }
    
    adminPageLevels = {
        "1,2", -- as, idg as
        3, -- admin 1
        4, -- admin 2
        5, -- admin 3
        6, -- admin 4
        7, -- admin 5
        8, -- fa
        9, -- sa
    }

    --
    GroupMinLines = 1
    GroupMaxLines = 16

    playerGroupInfos = {}

    function generateGroupInformations(id)
        local data = cache["playerDatas"]["group"][selectedGroup]["data"][3][id]
        if groupSearchCache and #groupSearchCache >= 1 then 
            data = groupSearchCache[id]
        end 

        if data then 
            local green = exports['cr_core']:getServerColor("green", true)
            local red = exports['cr_core']:getServerColor("red", true)
            local orange = exports['cr_core']:getServerColor("orangeNew", true)
            local yellow = exports['cr_core']:getServerColor("yellow", true)
            local blue = exports['cr_core']:getServerColor('yellow', true)

            playerGroupInfos = {}

            local leader = data[3]
            local online = data[4]
            local lastOnline = data[5]
            local lastOnlinePlace = data[6]
            table.insert(playerGroupInfos, "Vezető: " .. (leader == 1 and green .. "Igen" or red .. "Nem"))
            table.insert(playerGroupInfos, "Online: " .. (online and green .. "Igen" or red .. "Nem"))
            table.insert(playerGroupInfos, "Legutoljára online: " .. blue .. lastOnline)
            table.insert(playerGroupInfos, "Legutoljára itt volt látható: " .. blue .. lastOnlinePlace)
        end 
    end

    groupButtons = {
        "Csoport átnevezése",
        "Csoport törlése",
        "Játékos meghívása",
        "Játékos kirúgása",
        "Vezető kinevezése",
        "Kilépés",
    }

    --
    optionsButtonScrolled = nil 
    
    optionsSelectMinLines = 1
    optionsSelectMaxLines = 5

    optionsMinLines = 1
    optionsMaxLines = 16

    optionsSelected = 1

    --
    petCache = {}
    petTypePrices = {
        2500,
        2500, 
        2500,
        2500,
    }

    function getPlayerPetData(e)
        triggerLatentServerEvent("getPlayerPets", 5000, false, localPlayer, e)
    end 

    playerPetInfos = {}

    function generatePetInformations(id)
        local data = petCache[id]
        if PetSearchCache then 
            data = PetSearchCache[id]
        end 

        if data then 
            local green = exports['cr_core']:getServerColor("green", true)
            local red = exports['cr_core']:getServerColor("red", true)
            local orange = exports['cr_core']:getServerColor("orangeNew", true)
            local yellow = exports['cr_core']:getServerColor("yellow", true)
            local blue = exports['cr_core']:getServerColor('yellow', true)

            playerPetInfos = {}

            table.insert(playerPetInfos, data[2])
            table.insert(playerPetInfos, data[4])
            table.insert(playerPetInfos, data[1])
            table.insert(playerPetInfos, data[5][1])
            table.insert(playerPetInfos, data[5])

            table.insert(playerPetInfos, 
                {
                    'ID: ' .. red .. data[1],
                    "Név: " .. yellow .. data[4],
                    'Típus: ' .. orange .. petTypeNames[data[2]],
                }
            )
        end 
    end

    --
    factionButtons = {
        "Áttekintés",
        "Tagok",
        "Rangok",
        "Járművek",
        "Logok",
    }

    factionsSelectMinLines = 1
    factionsSelectMaxLines = 4
    factionsSelected = 1

    playerFactionInformations = {}
    playerFactionVehicles = {}

    function getFactionVehicles(factionID)
        if tonumber(factionID) then 
            playerFactionVehicles = {}
            playerFactionVehiclesData = {}
            playerFactionVehicleInfos = {}
            VehicleNeedSync = true

            for k,v in pairs(getElementsByType("vehicle")) do 
                if tonumber(v:getData("veh >> faction") or 0) == factionID then 
                    if v:getData("veh >> id") > 0 then 
                        playerFactionVehiclesData[v] = getVehicleDatas(v)
                        table.insert(playerFactionVehicles, v)
                    end 
                end 
            end 

            table.sort(playerFactionVehicles, function(a, b)
                if a:getData("veh >> id") and b:getData("veh >> id") then
                    return tonumber(a:getData("veh >> id")) < tonumber(b:getData("veh >> id"))
                end
            end);
            
            healthUpdateTimer = setTimer(updateHealth, 20 * 1000, 0)
        end 
    end 

    function destroyFactionVehicles()
        if isTimer(healthUpdateTimer) then killTimer(healthUpdateTimer) end
        playerFactionVehicles = {}
        playerFactionVehiclesData = {}
        playerFactionVehicleInfos = {}
        VehicleNeedSync = false
    end

    function generateFactionInformations(data)
        if data then 
            local green = exports['cr_core']:getServerColor("green", true)
            local red = exports['cr_core']:getServerColor("red", true)
            local orange = exports['cr_core']:getServerColor("orangeNew", true)
            local yellow = exports['cr_core']:getServerColor("yellow", true)
            local blue = exports['cr_core']:getServerColor('yellow', true)

            playerFactionInformations = {}

            local players, onlinePlayers, leaders = 0, 0, 0
            for k,v in pairs(data[3]) do 
                players = players + 1
                if v[4] then 
                    onlinePlayers = onlinePlayers + 1
                end 

                if v[3] == 1 then 
                    leaders = leaders + 1
                end 
            end 

            table.insert(playerFactionInformations, "Név: " .. blue .. data[2])
            table.insert(playerFactionInformations, "ID: " .. blue .. data[1])
            table.insert(playerFactionInformations, "Típus: " .. yellow .. factionTypes[data[5]])
            table.insert(playerFactionInformations, "Rangok száma: " .. blue .. #data[4])
            table.insert(playerFactionInformations, "Tagok száma: " .. blue .. players)
            table.insert(playerFactionInformations, "Online tagok száma: " .. green .. onlinePlayers)
            table.insert(playerFactionInformations, "Leaderek száma: " .. blue .. leaders)
            table.insert(playerFactionInformations, "Járművek száma: " .. blue .. #playerFactionVehicles)
        end
    end

    function getFactionMemberInfos(id)
        local data = cache["playerDatas"]["faction"][selectedFaction]["players"][id]
        if factionMembersSearchCache and #factionMembersSearchCache >= 1 then 
            data = factionMembersSearchCache[id]
        end 
        if data then 
            local attachData = cache["playerDatas"]["faction"][selectedFaction][3][tonumber(data[1])] 
            if attachData then 
                local rankName = cache["playerDatas"]["faction"][selectedFaction][4][attachData[7]]["name"] or "Ismeretlen"
                local factionRankPayment = cache["playerDatas"]["faction"][selectedFaction][4][attachData[7]]["payment"] or 0

                local green = exports['cr_core']:getServerColor("green", true)
                local red = exports['cr_core']:getServerColor("red", true)
                local orange = exports['cr_core']:getServerColor("orangeNew", true)
                local yellow = exports['cr_core']:getServerColor("yellow", true)
                local blue = exports['cr_core']:getServerColor('yellow', true)

                factionMemberInfos = {}

                table.insert(factionMemberInfos, "Név: " .. blue .. attachData[2]:gsub("_", " "))
                table.insert(factionMemberInfos, "Rang: " .. green .. rankName)
                table.insert(factionMemberInfos, "Fizetés: " .. yellow .. factionRankPayment .. " $")

                local dutyskin = attachData[9]
                if not dutyskin or not tonumber(dutyskin) or tonumber(dutyskin) == 0 then 
                    dutyskin = red .. "Nincs beállítva"
                end 
                table.insert(factionMemberInfos, "Duty skin: " .. green .. dutyskin)

                table.insert(factionMemberInfos, "Utoljára online: " .. blue .. attachData[5])
                table.insert(factionMemberInfos, "Leader: " .. (attachData[3] == 1 and green .. "Igen" or red .. "Nem"))
                table.insert(factionMemberInfos, "Online: " .. (attachData[4] and green .. "Igen" or red .. "Nem"))
            end 
        end
    end 

    function getFactionRankInfos(id)
        local data = cache["playerDatas"]["faction"][selectedFaction][4][id]
        if factionMembersSearchCache and #factionMembersSearchCache >= 1 then 
            data = factionMembersSearchCache[id]
        end 
        if data then 
            local name = data["name"]
            local payment = data["payment"]
            local members = 0
            local rankID = -1
            for k,v in pairs(cache["playerDatas"]["faction"][selectedFaction][4]) do 
                if v["name"]:lower() == data["name"]:lower() then 
                    rankID = k
                end 
            end 

            for k,v in pairs(cache["playerDatas"]["faction"][selectedFaction][3]) do 
                if v[7] == rankID then 
                    members = members + 1
                end 
            end 

            local green = exports['cr_core']:getServerColor("green", true)
            local red = exports['cr_core']:getServerColor("red", true)
            local orange = exports['cr_core']:getServerColor("orangeNew", true)
            local yellow = exports['cr_core']:getServerColor("yellow", true)
            local blue = exports['cr_core']:getServerColor('yellow', true)

            factionRankInfos = {}

            table.insert(factionRankInfos, "Név: " .. blue .. name)
            table.insert(factionRankInfos, "Fizetés: " .. green .. payment .. " $")
            table.insert(factionRankInfos, "Tagok száma: " .. yellow .. members .. " db")
        end
    end 

    function getMyFactionMemberInfos(id)
        local attachData = cache["playerDatas"]["faction"][selectedFaction][3][tonumber(id)] 
        if attachData then 
            local rankName = cache["playerDatas"]["faction"][selectedFaction][4][attachData[7]]["name"] or "Ismeretlen"
            local factionRankPayment = cache["playerDatas"]["faction"][selectedFaction][4][attachData[7]]["payment"] or 0

            local green = exports['cr_core']:getServerColor("green", true)
            local red = exports['cr_core']:getServerColor("red", true)
            local orange = exports['cr_core']:getServerColor("orangeNew", true)
            local yellow = exports['cr_core']:getServerColor("yellow", true)
            local blue = exports['cr_core']:getServerColor('yellow', true)

            factionMyMemberInfos = {}

            table.insert(factionMyMemberInfos, "Név: " .. blue .. attachData[2]:gsub("_", " "))
            table.insert(factionMyMemberInfos, "Rang: " .. green .. rankName)
            table.insert(factionMyMemberInfos, "Fizetés: " .. yellow .. factionRankPayment .. " $")

            local dutyskin = attachData[9]
            if not dutyskin or not tonumber(dutyskin) or tonumber(dutyskin) == 0 then 
                dutyskin = red .. "Nincs beállítva"
            end 
            table.insert(factionMyMemberInfos, "Duty skin: " .. green .. dutyskin)

            table.insert(factionMyMemberInfos, "Leader: " .. (attachData[3] == 1 and green .. "Igen" or red .. "Nem"))
        end 
    end 

    function generateFactionVehicleInformations(e)
        local green = exports['cr_core']:getServerColor("green", true)
        local red = exports['cr_core']:getServerColor("red", true)
        local orange = exports['cr_core']:getServerColor("orangeNew", true)
        local yellow = exports['cr_core']:getServerColor("yellow", true)
        local blue = exports['cr_core']:getServerColor('yellow', true)

        local tuningData = e:getData("veh >> tuningData") or {}

        playerFactionVehicleInfos = {}
        table.insert(playerFactionVehicleInfos, "ID: ".. blue .. e:getData("veh >> id"))

        local healthColor = green
        if (e.health / 10) <= 75 then 
            healthColor = yellow
        elseif (e.health / 10) <= 50 then 
            healthColor = red 
        end 
        local healthText = "Állapot: " .. healthColor .. math.ceil(e.health / 10) .. "%"
        table.insert(playerFactionVehicleInfos, healthText)

        local healthColor = green
        if ((e:getData("veh >> fuel") / tonumber(exports['cr_vehicle']:getVehicleMaxFuel(e.model) or 100)) * 100) <= 25 then 
            healthColor = red 
        elseif ((e:getData("veh >> fuel") / tonumber(exports['cr_vehicle']:getVehicleMaxFuel(e.model) or 100)) * 100) <= 75 then 
            healthColor = yellow
        end 
        local healthText = "Üzemanyag: " .. healthColor .. math.ceil((e:getData("veh >> fuel") / tonumber(exports['cr_vehicle']:getVehicleMaxFuel(e.model) or 100) * 100))  .. "%" .. " (" .. math.ceil(e:getData("veh >> fuel")) .. "/" .. tonumber(exports['cr_vehicle']:getVehicleMaxFuel(e.model) or 100) .. " l)"
        table.insert(playerFactionVehicleInfos, healthText)

        table.insert(playerFactionVehicleInfos, "Kilóméterszámláló állása: " .. blue .. math.round(e:getData("veh >> odometer"), 1) .. " KM")

        table.insert(playerFactionVehicleInfos, "Rendszám: " .. blue .. e.plateText)
        table.insert(playerFactionVehicleInfos, "Alvázszám: " .. orange .. e:getData("veh >> chassis"))

        table.insert(playerFactionVehicleInfos, "Motor: "..(e:getData("veh >> engine") and green .. "Elindítva" or red .. "Leállítva"))
        table.insert(playerFactionVehicleInfos, "Lámpa: "..(e:getData("veh >> light") and green .. "Felkapcsolva" or red .. "Lekapcsolva"))
        table.insert(playerFactionVehicleInfos, "Kézifék: "..(e:getData("veh >> handbrake") and green .. "Behúzva" or red .. "Kiengedve"))
        table.insert(playerFactionVehicleInfos, "Motor: ".. orange .. tonumber(tuningData["engine"] or 0))
        table.insert(playerFactionVehicleInfos, "Turbó: ".. orange .. tonumber(tuningData["turbo"] or 0))
        table.insert(playerFactionVehicleInfos, "ECU: ".. orange .. tonumber(tuningData["ecu"] or 0))
        table.insert(playerFactionVehicleInfos, "Váltó: ".. orange .. tonumber(tuningData["gearbox"] or 0))
        table.insert(playerFactionVehicleInfos, "Felfüggesztés: ".. orange .. tonumber(tuningData["suspension"] or 0))
        table.insert(playerFactionVehicleInfos, "Fékek: ".. orange .. tonumber(tuningData["brakes"] or 0))
        table.insert(playerFactionVehicleInfos, "Súlycsökkentés: ".. orange .. tonumber(tuningData["weight"] or 0))
        table.insert(playerFactionVehicleInfos, "Nitró: ".. ((tonumber(tuningData["nitro"] or 0) == 1) and green .. "Van " .. "(" .. tonumber(tuningData["nitroLevel"] or 1) * 100 .. "%)" or red .. "Nincs"))
        table.insert(playerFactionVehicleInfos, "AirRide: ".. ((tonumber(tuningData["airride"] or 0) == 1) and green .. "Van" or red .. "Nincs"))
        table.insert(playerFactionVehicleInfos, "Hidraulika: ".. ((tonumber(tuningData["optical.9"] or 0) == 1) and green .. "Van" or red .. "Nincs"))
        table.insert(playerFactionVehicleInfos, "Backfire: ".. ((tonumber(tuningData["backfire"] or 0) == 1) and green .. "Van" or red .. "Nincs"))
        table.insert(playerFactionVehicleInfos, "Traffi radar: ".. ((tonumber(tuningData["traffiradar"] or 0) == 1) and green .. "Van" or red .. "Nincs"))
        table.insert(playerFactionVehicleInfos, "AntiSteal: ".. ((tonumber(tuningData["stealwarning"] or 0) == 1) and green .. "Van" or red .. "Nincs"))
        table.insert(playerFactionVehicleInfos, "GPS: ".. ((tonumber(tuningData["gps"] or 0) == 1) and green .. "Van" or red .. "Nincs"))

        local neonNames = exports['cr_tuning']:getNeonNames()
        table.insert(playerFactionVehicleInfos, "Neon: ".. ((tonumber(tuningData["neon"] or 0) >= 1) and green .. "Van " .. "(" .. neonNames[tonumber(tuningData["neon"] or 0)][2] .. ")" or red .. "Nincs"))
    end    

    factionDutySkinData = {
        --[[
            [factionID] = {
                ["skins"] = {1,2,3,4,5},
                ["position"] = {x,y,z,dim,int},
            },
        ]]
        [1] = {
            ["skins"] = {280, 281, 282, 283, 284, 285, 286, 287, 288, 265, 264, 266, 267}, -- SHERIFF
            ["position"] = Vector3(254.77557373047, 74.210838317871, 1003.640625),
            ["showposition"] = {255.01493835449, 73.700157165527, 1003.640625, 33, 6, 2},
            ["cameraposition"] = {254.66259765625, 78.112396240234, 1004.7880859375, 254.68341064453, 77.124908447266, 1004.6317749023, 0, 70},
        },
		
		[2] = {
            ["skins"] = {274, 275, 276, 271, 256, 257, 343, 344, 345, 346, 347}, -- MD
            ["position"] = Vector3(217.35635375977, -98.646324157715, 1005.2578125),
            ["showposition"] = {217.35635375977, -98.646324157715, 1005.2578125, 13, 15, 85.3},
            ["cameraposition"] = {213.70584106445, -98.549713134766, 1005.9367675781, 313.22729492188, -98.638191223145, 996.16552734375, 0, 70},
        },

        [3] = {
            ["skins"] = {50}, -- Mechanic
            ["position"] = Vector3(217.35635375977, -98.646324157715, 1005.2578125),
            ["showposition"] = {217.35635375977, -98.646324157715, 1005.2578125, 13, 15, 85.3},
            ["cameraposition"] = {213.70584106445, -98.549713134766, 1005.9367675781, 313.22729492188, -98.638191223145, 996.16552734375, 0, 70},
        },
		
		[4] = {
            ["skins"] = {246, 272 }, -- GOV
            ["position"] = Vector3(217.35635375977, -98.646324157715, 1005.2578125),
            ["showposition"] = {217.35635375977, -98.646324157715, 1005.2578125, 13, 15, 85.3},
            ["cameraposition"] = {213.70584106445, -98.549713134766, 1005.9367675781, 313.22729492188, -98.638191223145, 996.16552734375, 0, 70},
        },
		
		[6] = {
            ["skins"] = {227, 228, 236, 248, 181, 138, 95, 153}, --HDMC
            ["position"] = Vector3(217.35635375977, -98.646324157715, 1005.2578125),
            ["showposition"] = {217.35635375977, -98.646324157715, 1005.2578125, 13, 15, 85.3},
            ["cameraposition"] = {213.70584106445, -98.549713134766, 1005.9367675781, 313.22729492188, -98.638191223145, 996.16552734375, 0, 70},
			["instantset"] = true, -- ezzel az illegál frakcióknak azonnal beállítja a skinüket, miután entereztek
		},
		
		[10] = {
            ["skins"] = {64, 249, 251, 252, 253, 255, 260, 331, 332, 333, 334}, -- BBOAKS
            ["position"] = Vector3(217.35635375977, -98.646324157715, 1005.2578125),
            ["showposition"] = {217.35635375977, -98.646324157715, 1005.2578125, 13, 15, 85.3},
            ["cameraposition"] = {213.70584106445, -98.549713134766, 1005.9367675781, 313.22729492188, -98.638191223145, 996.16552734375, 0, 70},
            ["instantset"] = true, -- ezzel az illegál frakcióknak azonnal beállítja a skinüket, miután entereztek
        },
		
		[11] = {
            ["skins"] = {67, 75, 77, 80, 83, 82, 81, 76, 71}, -- Palomino Crime
            ["position"] = Vector3(217.35635375977, -98.646324157715, 1005.2578125),
            ["showposition"] = {217.35635375977, -98.646324157715, 1005.2578125, 13, 15, 85.3},
            ["cameraposition"] = {213.70584106445, -98.549713134766, 1005.9367675781, 313.22729492188, -98.638191223145, 996.16552734375, 0, 70},
            ["instantset"] = true, -- ezzel az illegál frakcióknak azonnal beállítja a skinüket, miután entereztek
        },
		
		[12] = {
            ["skins"] = {206, 199, 162, 160, 73, 135, 133}, -- RedNeck (12)
            ["position"] = Vector3(217.35635375977, -98.646324157715, 1005.2578125),
            ["showposition"] = {217.35635375977, -98.646324157715, 1005.2578125, 13, 15, 85.3},
            ["cameraposition"] = {213.70584106445, -98.549713134766, 1005.9367675781, 313.22729492188, -98.638191223145, 996.16552734375, 0, 70},
            ["instantset"] = true, -- ezzel az illegál frakcióknak azonnal beállítja a skinüket, miután entereztek
        },
		
		[13] = {
            ["skins"] = {325, 326, 327, 328, 329, 330}, -- Aryan Brotherhood (13)
            ["position"] = Vector3(217.35635375977, -98.646324157715, 1005.2578125),
            ["showposition"] = {217.35635375977, -98.646324157715, 1005.2578125, 13, 15, 85.3},
            ["cameraposition"] = {213.70584106445, -98.549713134766, 1005.9367675781, 313.22729492188, -98.638191223145, 996.16552734375, 0, 70},
            ["instantset"] = true, -- ezzel az illegál frakcióknak azonnal beállítja a skinüket, miután entereztek
        },
		
		[14] = {
            ["skins"] = {335, 336, 337, 338, 339, 340, 341, 342}, -- Jay Park Gang (14)
            ["position"] = Vector3(217.35635375977, -98.646324157715, 1005.2578125),
            ["showposition"] = {217.35635375977, -98.646324157715, 1005.2578125, 13, 15, 85.3},
            ["cameraposition"] = {213.70584106445, -98.549713134766, 1005.9367675781, 313.22729492188, -98.638191223145, 996.16552734375, 0, 70},
            ["instantset"] = true, -- ezzel az illegál frakcióknak azonnal beállítja a skinüket, miután entereztek
        },
    }
else -- server
    
end

-- global

petTypeNames = {
    [314] = "Rottweiler",
    [315] = "Golden Retriever",
    [316] = "Siba inu",
    [317] = "Német juhász",
}

factionTypes = {
    "Rendvédelem",
	"Egészségügy",
    "Cartel",
	"Banda",
	"Egyéb",
}

factionDefaultPermissions = {
    {"faction.editmessage", "Frakció üzenet szerkesztése"},
    {"faction.rankUp", "Rang előléptetés"},
    {"faction.rankDown", "Rang lefokozás"},
    {"faction.leaderInteractions", "Leader interakciók"},
    {"faction.kick", "Kirúgás"},
    {"faction.getmoney", "Frakció pénz kivétel"},
    {"faction.addmoney", "Frakció pénz berakása"},
    {"faction.addmember", "Új tag hozzáadása"},
    {"faction.editperms", "Jogosultságok szerkesztése"},
    {"faction.sortup", "Sorrend módosítása: fel"},
    {"faction.sortdown", "Sorrend módosítása: le"},
    {"faction.addrank", "Új rang hozzáadása"},
    {"faction.removerank", "Rang törlése"},
    {"faction.renamerank", "Rang átnevezése"},
    {"faction.editrankpayment", "Rang fizetésének módosítása"},
    {"faction.openlogs", "Frakció logok megtekintése"},
	{"faction.changelock", "Frakció jármű: Kulcsmásolás"},
    {'faction.tuning', 'Frakció jármű: Tuningolás'},
}

factionSpecialPermissions = {
    --[[
        [factionID] = {
            {"permname", "hungarian text"},
        },
    ]]
    --[[
	[1] = {
        {"test1", "Teszt 1 jogosultság"},
    },
	]]
	
    [2] = {
        {"medic.giveHealthCard", "Egészségügyi kártya kiállítása"}
    },

	[3] = {
        {"mechanic.canRepair", "Autójavítás"},
        {"mechanic.canUseLifter", "Emelő használata"},
    },

    [4] = {
        {"gov.getFactionData", "Frakció adatok lekérése"},
        {"gov.giveLicense", "Engedélyek kiállítása"},
        {"gov.giveGovCard", "Önkormányzati azonosító kiállítása"},
        {"gov.manageCinema", "Autósmozi kezelése"},
        {"gov.advertiseMovie", "Film hirdetése"},
    },

    [9] = {
        {"atmRob", "ATM rablás"}
    },

    ['factionType.1'] = {
        {'mdc.login', 'MDC: Bejelentkezés'},
        {'mdc.admin', 'MDC: Adminisztrátori Felület'},
        {'mdc.logs', 'MDC: Logok megnézése'},
        {'mdc.addWantedVehicle', 'MDC: Új körözött kocsi hozzáadása'},
        {'mdc.deleteWantedVehicle', 'MDC: Körözött kocsi törlés'},
        {'mdc.addWantedPerson', 'MDC: Új körözött személy hozzáadása'},
        {'mdc.deleteWantedPerson', 'MDC: Körözött személy törlés'},
        {'mdc.addNewTicket', 'MDC: Új büntetés'},
        {'mdc.deleteTicket', 'MDC: Büntetés törlés'},
        {'mdc.addWantedWeapon', 'MDC: Új körözött fegyver'},
        {'mdc.deleteWantedWeapon', 'MDC: Körözött fegyver törlés'},
        {'mdc.addRegisteredWeapon', 'MDC: Fegyver nyilvántartás hozzáadás'},
        {'mdc.deleteRegisteredWeapon', 'MDC: Fegyver nyilvántartás törlés'},
        {'mdc.addRegisteredVehicle', 'MDC: Jármű nyilvántartás hozzáadás'},
        {'mdc.deleteRegisteredVehicle', 'MDC: Jármű nyilvántartás törlés'},
        {'mdc.addRegisteredAddress', 'MDC: Lakcím nyilvántartás hozzáadás'},
        {'mdc.deleteRegisteredAddress', 'MDC: Lakcím nyilvántartás törlés'},
        {'mdc.addRegisteredTraffic', 'MDC: Forgalmi nyilvántartás hozzáadás'},
        {'mdc.deleteRegisteredTraffic', 'MDC: Forgalmi nyilvántartás törlés'},
		{"interior.customization", "Frakció interior berendezése"},
    },
	
	['factionType.2'] = {
		{"interior.customization", "Frakció interior berendezése"},
    },

    ["factionType.3"] = {
		{"interior.customization", "Frakció interior berendezése"},
        {"atmRob", "ATM rablás"}
    },

    ["factionType.4"] = {
		{"interior.customization", "Frakció interior berendezése"},
        {"atmRob", "ATM rablás"}
    },
	
	["factionType.5"] = {
		{"interior.customization", "Frakció interior berendezése"},
 
    },
}

function getFactionPermissions(factionID, factionType)
    local tbl = {}
    for k,v in pairs(factionDefaultPermissions) do 
        table.insert(tbl, v)
    end 

    if factionSpecialPermissions[factionID] then 
        for k,v in pairs(factionSpecialPermissions[factionID]) do 
            table.insert(tbl, v)
        end 
    end 

    if factionSpecialPermissions['factionType.' .. tostring(factionType)] then 
        for k,v in pairs(factionSpecialPermissions['factionType.' .. tostring(factionType)]) do 
            table.insert(tbl, v)
        end 
    end 

    return tbl 
end 
