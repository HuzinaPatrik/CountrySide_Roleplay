white = "#ffffff"
gray = "#f2f2f2"
keyItem = 16

function stringToBoolean(a)
    if a:lower() == "true" then
        return true
    else
        return false
    end
end

function booelanToString(a)
    return tostring(a)
end

function getVehicleSpeed(element)
    local vx, vy, vz = getElementVelocity(element)
    return math.sqrt(vx^2 + vy^2 + vz^2) * 180      
end

allowed = { { 48, 57 }, { 65, 90 }, { 97, 122 } }; -- numbers/lowercase chars/uppercase chars
function generateString(len, onlyNumber, onlyString)
    if tonumber(len) then
        math.randomseed(getTickCount());
        local str = "";
        for i = 1, len do
            local charlist = allowed[math.random(1,3)];
            if onlyNumber then
                charlist = allowed[math.random(1,1)];
            end
            if onlyString then
                charlist = allowed[math.random(3,3)];
            end
            str = str .. string.upper(string.char(math.random(charlist[1], charlist[2])));
        end
        return str;
    end
    return false;
end

function findVehicle(id)
	id = tonumber(id)
    
    if type(triggerServerEvent) == "function" then
        for i, v in pairs(getElementsByType("vehicle")) do 
            if(v:getData("veh >> id") == id) then
                return v
            end
        end 
    else
        return exports['cr_elements']:getVehicleByID(id)
    end
    
	return false
end

function getClosestVehicle(dist, needKey)
	local a, veh = 9999, false
    
	for k, v in pairs(getElementsByType("vehicle", _, true)) do
        if v:getData("veh >> id") then
            local dist = getDistanceBetweenPoints3D(v.position, localPlayer.position)
            if dist <= a then
                local enabled = true
                if needKey then
                    enabled = exports["cr_inventory"]:hasItem(localPlayer, 16, tonumber(v:getData("veh >> id"))) or localPlayer:getData("admin >> duty") and tonumber(localPlayer:getData("admin >> level")) > 5 or exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen")

                    if v:getData('veh >> id') < 0 then 
                        if localPlayer then 
                            if getElementData(v, "veh >> owner") == getElementData(localPlayer, "acc >> id") then 
                                enabled = true
                            end 
                        end 
                    end 
                end
                
                if enabled then
                    veh = v
                    a = dist
                end
            end
        end
	end
    
	if a <= dist then
		return veh
	end
    
	return false
end

disabledType = {
    ["BMX"] = true,
};

vehicleDamageMultiplier = {
    --[modelid] = multiplier
	[560] =  1, --sultan	
    [411] =  1, --infernus	
    [451] =  1, --turismo	
    [436] =  1.15, --previon	-- kész
    [429] =  1, --banshee	
    [480] =  1, --comet	
    [541] =  1, --bullet	
    [475] =  1, --sabre	
    [602] =  1, --alpha		
    [483] =  1, --camper	
    [527] =  1, --cadrona
    [481] =  1, --BMX
    [509] =  1, --BMX
    [510] =  1, --BMX
    [494] =  1, --hotring racer 1	
    [596] =  0.85, --police ls	
    [597] =  0.85, --police sf	
    [598] =  0.85, --police lv	
	[490] =  0.85, --police lv	
    [416] =  0.85, --ambulance	
    [589] =  1.09, --club	
    [410] =  1.15, --manana	
    [503] =  1, --hotring racer 3	
    [402] =  1, --buffalo	
    [551] =  1, --merit	
    [587] =  1, --euros	
    [533] =  1, --feltzer	
    [421] =  1, --washington	
    [506] =  1, --supergt		
    [604] =  1.1, --glenshit	
    [466] =  1.1, --glenshit	
    [401] =  1, --bravura	
    [525] =  0.89, --towtruck	
    [555] =  1.1, --windsor	
    [445] =  1, --admiral	
    [415] =  1, --cheetah	
    [502] =  1.1, --hotring racer 2	
    [566] =  1.1, --tahmoma	
    [518] =  1.1, --buccaneer	
    [419] =  1.1, --esperanto	
    [562] =  1, --elegy	
    [580] =  1.1, --stafford	
    [426] =  1.1, --premier	
    [529] =  1, --willard	
    [474] =  1.15, --hermes	
    [545] =  1.15, --hustler	
    [517] =  1.15, --majestic		
    [439] =  1.15, --stallion
	[458] =  1, --solair
    [491] =  1.15, --virgo	
    [546] =  1, --intruder	
    [550] =  1, --sunrise	
    [507] =  1.15, --elegant
    [477] =  1, --zr350	
    [413] =  1.15, --pony	
    [482] =  1.15, --burrito	
    [579] =  1.1, --huntley	
    [400] =  1, --landstalker	
    [489] =  0.89, --rancher 1	
    [505] =  0.89, --rancher 2	
    [500] =  0.89, --mesa	
    [543] =  1.1, --sadler	
    [554] =  1, --yosemite	
    [585] =  1.15, --emperor	
    [516] =  1.15, --nebula	
	[565] =  1.15, --flash
	[559] =  1, --jester
	[558] =  1.15, --uranus
	[561] =  1.15, --stratum
	[575] =  1.15, --broadway
	[534] =  1.15, --remington
	[479] =  1, --regina
	[467] =  1.15, --oceanic
	[405] =  1, --sentinel
	[492] =  1.1, --greenwood
	[599] =  0.85, --policeranger
	[478] =  1.1, --walton
	[422] =  1.1, --bobcat
	[540] =  1.1, --vincent
	[549] =  1.1, --tampa
	[536] =  1.1, --Declasse Vamos
	[418] =  1.1, --Dodge Caravan
	[463] =  1.3, --Freeway
	[508] =  1, --Journey
	[461] =  1.3, --PCJ-600
	[547] =  1, --primo
	[586] =  1.3, --Wayfarer
	[471] =  1.3, --Quadbike
	[531] =  1.2, --Tractor
	[581] =  1, --bf-400
	[437] =  1.5, --BUS
	[431] =  1.4, --BUS
	[499] =  1.4, --BENSON
	[528] =  0.5, --528
};

vehicleNames = {
    --[modelID] = name,
    [581] = "BF-400", --bf-400
    [422] = "Bobcat", --bobcat
	[507] = "Buick Regal GSX", --elegant
	[458] = "Cadillac Escalade 2002", --solair
	[529] = "Chevrolet Caprice 19", --willard
	[585] = "Chrysler 300C", --emperor
	[536] = "Declasse Vamos", --blade
	[418] = "Dodge Caravan", --moonbeam
	[551] = "Ford Crown Victoria", --merit
	[479] = "Ford Explorer", --regina
	[463] = "Freeway", --freeway
	[579] = "Jeep CherokeeSRT 2012", --huntley
	[508] = "Journey", --journey
	[461] = "PCJ-600", --PCJ600
	[401] = "Plymouth GTX 426", --bravura
	[518] = "Pontiac GTO", --buccaneer
	[547] = "Toyota Camry", --primo
	[559] = "Toyota Supra", --jester
	[586] = "Wayfarer", --Wayfarer
    [405] = "BMW M5 (F10)", --Sentinel
    [436] = "Chevrolet Bell Air", -- Previon
    [402] = "Chevrolet Camaro'10", --Buffalo
    [429] = "Chevrolet Corvette zr1 c6", --Banshee
    [467] = "Dodge RAM1500", --Oceanic
    [413] = "Ford E 250", --Pony
    [505] = "Ford F150 Raptor", --Slamvan
    [475] = "Ford Mustang", --Sabre
    [502] = "Ford Mustang 68", --Hotring Racer 2
    [404] = "Ford Taurus", --Perennial
    [491] = "Ford Torino", --Virgo
    [456] = "GMC C5500", --Yankee
    [554] = "GMC Sierra'98", --Yosemite
    [500] = "Jeep Wrangler", --Mesa
    [546] = "Lexus GS350", --Intruder
    [602] = "Mercedes Benz CL600", --Alpha
    [506] = "Mercedes SLS AMG", --Super GT
    [516] = "Toyota Mark II", --Nebula
	[565] = "Nissan Skyline r33", --Flash
	
	-- [FK Vehicles] = modpanel --
	[416] = "Ford Rescue Ambulance", --ambulance
	[596] = "Ford Crown Victoria(Sheriff)", --police LS
	[597] = "Dodge Charger(Sheriff)", --police SF
	[598] = "Ford Explorer(Sheriff)", --police LV
	[490] = "Chevrolet Suburban LTZ", --FBI rancher
	[528] = "Lenco BearCat", --528
};

TwoDoorVehicles = {
    --[modelID] = true,
    [605] = true, -- tanuló törött kocsi/sadshit
    [436] = true, -- previon
    [451] = true, -- turismo
    [429] = true, -- banshee
    [480] = true, -- comet
    [541] = true, -- bullet
    [411] = true, -- infernus
    [451] = true, -- turismo
    [475] = true, -- sabre
    [602] = true, -- alpha
    [542] = true, -- clover
    [483] = true, -- camper
    [527] = true, -- cadrona
    [494] = true, -- hotring racer 1
    [416] = true, -- ambulance
    [496] = true, -- blistacompact
    [589] = true, -- club
    [410] = true, -- manana
    [503] = true, -- hotring racer 3
    [402] = true, -- buffalo
    [533] = true, -- feltzer
    [506] = true, -- supergt
    [401] = true, -- bravura
    [525] = true, -- towtruck
    [555] = true, -- windsor
    [415] = true, -- cheetah
    [502] = true, -- hotring racer 2
    [518] = true, -- buccaneer
    [419] = true, -- esperanto
    [562] = true, -- elegy
    [526] = true, -- fortune
    [474] = true, -- hermes
    [545] = true, -- hustler
    [600] = true, -- picador
    [439] = true, -- stallion
    [491] = true, -- virgo
    [603] = true, -- phoenix
    [466] = true, -- zr350
    [489] = true, -- rancher
    [500] = true, -- mesa
    [543] = true, -- sadler
    [554] = true, -- yosemite
	[565] = true, -- flash
	[558] = true, --uranus
	[505] = true, --slamvan
	[536] = true, --blade
	[575] = true, --broadway
	[576] = true, --tornado
	[534] = true, --remington
	[567] = true, --savana
	[578] = true, --dft30
	[599] = true, --policeranger
	[478] = true, --policeranger
	[422] = true, --bobcat
	[528] = true, --bearcat
};

function getVehicleName(model)
    if isElement(model) then
        model = model:getData('veh >> virtuaModellID') or getElementModel(model);
    end
    
    local vehName = vehicleNames[model];
    if not vehName or vehName == tostring(model) then
        vehName = getVehicleNameFromModel(model);
    end
    
    return vehName;
end

DisableWindowableVehs = {
    --[modelID] = true,
    [555] = true,
};

kmMultipler = {
    --[ModelID] = KM kénti minusz
    [560] = 0.5,
    [605] = 0.2, -- Tanulókocsi törött/sadshit
    [543] = 1.0, -- Tanulókocsi v2
    [451] = 1.0, -- turismo
    [411] = 1.2, -- infernus
    [420] = 1.0, -- taxi 
    [556] = 2.0, -- monster 2
    [436] = 0.2, -- previon
    [429] = 0.4, -- banshee
    [480] = 0.3, -- comet
    [541] = 0.6, -- bullet
    [475] = 0.7, -- sabre
    [602] = 0.9, -- alpha
    [542] = 0.2, -- clover
    [483] = 0.2, -- camper
    [527] = 0.4, -- cadrona
    [494] = 1.1, -- hotring racer 1
    [596] = 0.3, -- police ls
    [597] = 0.6, -- police sf
    [598] = 0.8, -- police lv
	[528] = 1.0, -- police FBI
	[490] = 0.8, -- FBI rancher
    [416] = 0.8, -- ambulance
    [496] = 0.3, -- blistacompact
    [589] = 0.2, -- club
    [410] = 0.2, -- manana
    [503] = 1.0, -- hotring racer 3
    [402] = 0.7, -- buffalo
    [551] = 0.2, -- merit
    [587] = 0.6, -- euros
    [533] = 0.9, -- feltzer
    [421] = 0.7, -- washington
    [506] = 1.0, -- supergt
    [604] = 0.4, -- glenshit
    [466] = 0.5, -- willard
    [401] = 0.1, -- bravura
    [525] = 0.5, -- towtruck
    [555] = 1.5, -- windsor
    [445] = 0.8, -- admiral
    [415] = 1.3, -- cheetah
    [502] = 1, -- hotring racer 2
    [566] = 0.2, -- tahoma
    [518] = 0.2, -- buccaneer
    [419] = 0.5, -- esperanto
    [562] = 0.6, -- elegy
    [526] = 0.7, -- fortune
    [580] = 0.4, -- stafford
    [426] = 0.6, -- premier
    [529] = 0.2, -- willard
    [474] = 0.3, -- hermes
    [545] = 0.2, -- huster
    [517] = 0.5, -- majestic
    [600] = 0.5, -- picador
    [439] = 0.6, -- stallion
    [491] = 0.5, -- virgo
    [546] = 0.2, -- intruder
    [550] = 0.4, -- sunrise
    [507] = 0.5, -- elegant
    [603] = 0.7, -- elegant
    [477] = 0.8, -- zr350
    [413] = 0.4, -- pony
    [482] = 0.6, -- burrito
    [400] = 0.6, -- landstalker
    [579] = 0.5, -- huntley
    [489] = 0.5, -- rancher
    [505] = 0.7, -- rancher 2
    [500] = 0.3, -- mesa
    [543] = 0.3, -- sadler
    [554] = 0.6, -- yosemite
    [585] = 0.3, -- emperor
    [516] = 0.4, -- nebula
    [468] = 0.1, -- sanchez
    [462] = 0.05, -- faggio
    [581] = 0.1, -- bf-400
    [521] = 0.2, -- fcr-900
    [463] = 0.1, -- freeway
    [461] = 0.1, -- pcj-600
    [586] = 0.1, -- wayfarer
    [522] = 0.3, -- nrg-500
	[565] = 0.4, -- flash
	[559] = 0.3, -- jester
	[558] = 0.6, -- uranus
	[561] = 0.7, -- stratum
	[505] = 0.9, -- slamvan
	[536] = 0.4, -- blade
	[575] = 1.0, -- broadway
	[576] = 1.0, -- tornado
	[534] = 1.0, -- remington
	[567] = 1.0, -- savana
	[578] = 2.0, -- dft30
	[479] = 0.3, -- regina
	[467] = 0.5, -- oceanic
	[405] = 0.8, -- sentinel
	[492] = 0.5, -- greenwood
	[599] = 0.7, -- police ranger
	[478] = 0.5, -- walton
	[422] = 0.4, -- bobcat
	[487] = 1,   -- maverick
	[408] = 0.5, -- trashmaster
	[540] = 0.5, -- vincent
	[404] = 0.5, -- perenniel
	[549] = 0.4, -- tampa
	[458] = 1, -- solair
    [418] = 0.5, --Dodge Caravan
    [508] = 0.5, --Journey
    [547] = 0.4, --toyota
    [471] = 0.3, --Quadbike
    [531] = 0.3, --Tractor
	[437] = 0.1, --BUS
	[431] = 0.1, --BUS
	[499] = 0.1, --BENSON
};

for i = 300, 700 do
    if not kmMultipler[i] then
        kmMultipler[i] = 0.3
    end
end

maxFuel = {
    --[modelid] = max tank méret,
	[514] = 100, --Tanker
	[547] = 90, --toyota
	[515] = 100, --Roadtrain
    [560] = 80, --Sultan
    [605] = 40, -- Tanulókocsi törött
    [411] = 80, -- infernus
    [451] = 80, -- turismo
    [533] = 100, -- Feltzer
    [420] = 50, -- taxi
    [556] = 500, -- monster 2
    [436] = 70, -- previon
    [429] = 72, -- banshee
    [480] = 64, -- comet
    [541] = 74, -- bullet
    [475] = 68, -- sabre
    [602] = 72, -- alpha
    [542] = 52, -- clover
    [483] = 42, -- camper
    [527] = 71, -- cadrona
    [494] = 89, -- hotring racer 1
    [596] = 62, -- police ls
    [597] = 80, -- police sf
    [598] = 70, -- police lv
	[528] = 100, -- police FBI
	[490] = 80, -- FBI rancher
    [416] = 100, -- ambulance
    [496] = 48, -- blicstacompact
    [589] = 44, -- club
    [410] = 36, -- manana
    [503] = 85, -- hotring racer 3
    [402] = 60, -- buffalo
    [551] = 75, -- merit
    [587] = 70, -- euros
    [533] = 79, -- feltzer
    [421] = 90, -- washington
    [506] = 74, -- supergt
    [604] = 94, -- glenshit
    [466] = 95, -- willard
    [401] = 45, -- bravura
    [525] = 94, -- towtruck
    [555] = 97, -- windsor
    [445] = 74, -- admiral
    [415] = 100, -- cheetah
    [502] = 100, -- hotring racer 2
    [566] = 68, -- tahoma
    [518] = 56, -- buccaneer
    [419] = 72, -- esperanto
    [562] = 70, -- elegy
    [526] = 60, -- fortune
    [580] = 63, -- stafford
    [426] = 64, -- premier
    [529] = 55, -- willard
    [474] = 75, -- hermes
    [545] = 39, -- hustler
    [517] = 88, -- majestic
    [600] = 100, -- majestic
    [439] = 75, -- stallion
    [491] = 55, -- virgo
    [546] = 87, -- intruder
    [550] = 85, -- sunrise
    [507] = 80, -- elegant
    [603] = 64, -- phoenix
    [477] = 82, -- zr350
    [413] = 83, -- pony
    [482] = 100, -- burrito
    [400] = 93, -- landstalker
    [579] = 100, -- huntley
    [489] = 85, -- rancher
    [505] = 100, -- rancher 2
    [500] = 50, -- mesa
    [543] = 100, -- sadler
    [554] = 100, -- yosemite
    [585] = 70, -- emperor
    [516] = 60, -- nebula
    [468] = 10, -- sanchez
    [462] = 8, -- faggio
    [581] = 18, -- bf-400
    [521] = 15, -- fcr-900
    [463] = 19, -- freeway
    [461] = 16, -- pcj-600
    [586] = 19, -- wayfarer
    [522] = 25, -- nrg-500
	[565] = 85, --flash
	[559] = 85, --jester
	[558] = 75, --uranus
	[561] = 85, --stratum
	[505] = 90, --slamvan
	[536] = 90, --blade
	[575] = 90, --broadway
	[576] = 95, --tornado
	[534] = 100, --remington
	[478] = 100, --remington
	[567] = 85, --savana
	[578] = 100, --dft30
	[479] = 60, --regina
	[467] = 55, --oceanic
	[405] = 90, --sentinel
	[492] = 60, --greenwood
	[599] = 65, --policeranger
	[422] = 100, --bobcat
	[487] = 100, --maverick
	[408] = 70, --Trashmaster
	[540] = 88, --vincent
	[404] = 56, -- Perenniel
	[549] = 70, -- tampa
	[458] = 100, --solair
	[418] = 100, --Dodge Caravan
    [508] = 100, --Journey
    [471] = 50, --Quadbike
    [531] = 50, --Tractor
	[437] = 100, --BUS
	[431] = 100, --BUS
	[499] = 100, --BENSON
	[581] = 30, -- bf-400
};

windowNames = {
    [2] = "jobb első",
    [4] = "bal első",
    [3] = "jobb hátsó",
    [5] = "bal hátsó",
};

windowNames2 = {
    [2] = "Jobb első ablak",
    [4] = "Bal első ablak",
    [3] = "Jobb hátsó ablak",
    [5] = "Bal hátsó ablak",
};

convert = {
    [0] = 4,
    [1] = 2,
    [2] = 5,
    [3] = 3,
};

doorNames = {
    [0] = "Motorháztető",
    [1] = "Bal első",
    [2] = "Jobb első",
    [3] = "Bal hátsó",
    [4] = "Jobb hátsó",
};

doorNames2 = {
    [0] = {["open"] = "felnyitja a motorháztetőt", ["close"] = "lecsukja a motorháztetőt"},
    [1] = {["open"] = "kinyitja a bal első ajtót", ["close"] = "becsukja a bal első ajtót"},
    [2] = {["open"] = "kinyitja a jobb első ajtót", ["close"] = "becsukja a jobb első ajtót"},
    [3] = {["open"] = "kinyitja a bal hátsó ajtót", ["close"] = "becsukja a bal hátsó ajtót"},
    [4] = {["open"] = "kinyitja a jobb hátsó ajtót", ["close"] = "becsukja a jobb hátsó ajtót"},
};

for i = 300, 700 do
    if not maxFuel[i] then
        maxFuel[i] = 30
    end
end

function getMaxFuel()
    return maxFuel
end

function getVehicleMaxFuel(model)
    if isElement(model) then
        model = model:getData('veh >> virtuaModellID') or getElementModel(model);
    end

    local num = maxFuel[model];
    if not num then
        num = maxFuel[model];
    end

    return num or 100;
end

function isWindowableVeh(model)
    if isElement(model) then
        model = model:getData('veh >> virtuaModellID') or getElementModel(model);
    end

    return not DisableWindowableVehs[model];
end

function getHandlingProperty(element, property)
    if isElement(element) and getElementType(element) == "vehicle" and type(property) == "string" then -- Make sure there's a valid vehicle and a property string
        local handlingTable = getVehicleHandling(element);
        local value = handlingTable[property];
        
        if value then
            return value;
        end
    end
    
    return false;
end

function getVehicleConsumption(model, km)
	if(kmMultipler[model] and tonumber(km)) then
		return kmMultipler[model]*km
	end
	return false
end

hasBelt = {	
    [560] = "true", --sultan	
    [411] = "true", --infernus	
    [451] = "true", --turismo		
    [429] = "true", --banshee	
    [480] = "true", --comet	
    [541] = "true", --bullet	
    [475] = "true", --sabre	
    [602] = "true", --alpha		
    [527] = "true", --cadrona	
    [494] = "true", --hotring racer 1	
    [596] = "true", --police ls	
    [597] = "true", --police sf	
    [598] = "true", --police lv	
    [416] = "true", --ambulance	
    [418] = "true", --moonbeam
    [402] = "true", --buffalo	
    [404] = "true", --perennial
    [587] = "true", --euros	
    [533] = "true", --feltzer	
    [421] = "true", --washington	
    [445] = "true", --admiral	
    [415] = "true", --cheetah	
    [502] = "true", --hotring racer 2		
    [562] = "true", --elegy	
    [580] = "true", --stafford	
    [426] = "true", --premier		
    [546] = "true", --intruder	
    [477] = "true", --zr350	
    [413] = "true", --pony	
    [482] = "true", --burrito	
    [579] = "true", --huntley	
    [400] = "true", --landstalker	
    [489] = "true", --rancher 1	
    [505] = "true", --rancher 2	
    [585] = "true", --emperor	
	[565] = "true", --flash
	[559] = "true", --jester
	[558] = "true", --uranus
	[561] = "true", --stratum
	[479] = "true", --regina
	[405] = "true", --sentinel
	[599] = "true", --policeranger
	[422] = "true", --bobcat
	[540] = "true", --vincent
	[458] = "true", --solair
    [456] = "true", --Yankee
    [420] = "true", -- taxi
	[490] = "true", -- FBI Ranch
};

temporaryTitles = {
    "Munkajármű", -- 1,
    "Bérelt jármű", -- 2,
    "Ideiglenes létrehozott jármű", -- 3
}
