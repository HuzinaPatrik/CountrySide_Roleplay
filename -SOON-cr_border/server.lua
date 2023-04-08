--Tömbök
local gates = {
    --{group,x,y,z}
    {1,36.33, -1534.92285,4.2},
    {1,36.26, -1535.92285,4.2},
    {1,36.19, -1536.92285,4.2},
    {1,36.12, -1537.92285,4.2},
    {1,36.05, -1538.92285,4.2},
    {1,35.98, -1539.92285,4.2},
    
    {2,66.401733398438, -1528.6788330078, 3.9},
    {2,66.401733398438, -1527.6788330078, 3.9},
    {2,66.401733398438, -1526.6788330078, 3.9},
    {2,66.401733398438, -1525.6788330078, 3.9},
    {2,66.401733398438, -1524.6788330078, 3.9},
    {2,66.401733398438, -1523.6788330078, 3.9},
    
    {3,-5.36, -1363.13, 9.5},
    {3,-4.76, -1363.93, 9.5},
    {3,-4.16, -1364.73, 9.5},
    {3,-3.56, -1365.53, 9.5},
    {3,-2.96, -1366.33, 9.5},
    {3,-2.46, -1367.13, 9.5},
    
    {4,-16.83, -1335.33, 9.9},
    {4,-17.43, -1334.53, 9.9},
    {4,-18.03, -1333.73, 9.9},
    {4,-18.63, -1332.93, 9.9},
    {4,-19.23, -1332.13, 9.9},
    
    {5,-88.5, -930.51, 18.3},
    {5,-89.5, -930.01, 18.3},
    {5,-90.5, -929.51, 18.3},
    {5,-91.2, -929.11, 18.3},
    
    {6,-78.403945922852, -889.09796142578, 14.6},
    {6,-77.35359954834, -889.55187988281, 14.6},
    {6,-76.346771240234, -890.14538574219, 14.6},
    
    {7,-954.60894775391, -264.36624145508, 35.55},
    {7,-955.578125, -264.20498657227, 35.55},
    {7,-956.65283203125, -264.06387329102, 35.55},
    
    {8,-962.58636474609, -341.64291381836, 35.1},
    {8,-964.77, -341.15, 35.1},
    {8,-963.77, -341.35, 35.1},
}

local ped = {
    {281,41.136089324951, -1531.6193847656, 5.3880877494812,176},
    {282,60.446559906006, -1531.3486328125, 5.1940851211548,351},
    {280,-2.3327085971832, -1358.2434082031, 10.630624771118,223},
    {266,-19.56300163269, -1340.7509765625, 10.98525428772,42},
    {265,-92.923820495605, -929.08935546875, 19.352470397949,241},
    {283,-74.186828613281, -890.22357177734, 15.682782173157,68},
    {281, -952.55383300781, -264.26315307617, 36.641986846924,80},
    {266,-966.83715820313, -340.6989440918, 36.278842926025,256},
}

local weapon = {
    24,
    25,
    29,
    31
}

local names = {
	"Jack_Gordon",
	"Aaron_White",
    "Jason_Gates",
    "Bill_Fox",
    "Manuel_Johns",
    "Craig_Johnson",
    "Walter_Mahone",
    "Diego_Specter",
}

--Üres tömbök
local placed_gates = {}
local placed_peds = {}

local gates_state = {}
local gates_nowmoving = {}
local gates_manual = {false,false,false,false,false,false,false,false}

--For ciklusok
for k,v in pairs(gates) do
    placed_gates[#placed_gates + 1] = {v[1],createObject(1214,v[2],v[3],v[4])}
    setElementFrozen(placed_gates[#placed_gates][2],true)
end

for k,v in pairs(ped) do --placed_peds[#placed_peds]
    placed_peds[#placed_peds + 1] = createPed(v[1],v[2],v[3],v[4])
    setElementRotation(placed_peds[#placed_peds],0,0,v[5])
    setElementFrozen(placed_peds[#placed_peds],true)
    setElementData(placed_peds[#placed_peds],"ped.name", names[#placed_peds])
    setElementData(placed_peds[#placed_peds],"ped.type","Határőr")
    setElementData(placed_peds[#placed_peds],"ped.id","DriverLicense")
    setElementData(placed_peds[#placed_peds],"char >> noDamage",true)
    giveWeapon(placed_peds[#placed_peds],weapon[math.random(1,4)],10000,true)
end

--Egyéb funkciók
addEvent("toggleManual",true)
addEventHandler("toggleManual",root,
	function(element)
		for k,v in pairs(placed_gates) do
	        if v[2] == element then
	            local x,y,z = getElementPosition(element)
	            local px,py,pz = getElementPosition(source)
	            local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
	            if dist > 5 then return end
	            gates_manual[v[1]] = not gates_manual[v[1]]
	            if gates_manual[v[1]] == true then
	                triggerClientEvent(source,"writeInChat",source,"outputChatBox","Sikeresen bekapcsoltad a manuális határt! Használat(/hatarmanage)","success")
                    triggerClientEvent(source,"writeInChat",source,"me","átállítja a határ működési módját")
	            else
	            	triggerClientEvent(source,"writeInChat",source,"outputChatBox","Sikeresen kikapcsoltad a manuális határt!","success")
                    triggerClientEvent(source,"writeInChat",source,"me","átállítja a határ működési módját")
	            end
	            break
	        end
    	end
	end
)

addEvent("refreshManual",true)
addEventHandler("refreshManual",root,
    function ()
        triggerClientEvent(source,"sendManuals",source,gates_manual)
    end
)

addEvent("checkManualEnable",true)
addEventHandler("checkManualEnable",root,
	function(key)
		if gates_manual[key] then
			triggerClientEvent(source,"toggleHatar",source,1)
		end
	end
)

--Mozgási funkció
function moveGate(key,value,two,pl)
	local key = tonumber(key)
	if gates_nowmoving[key] then return end
    if value then -- lefele
    	if gates_state[key] then return end
        if gates_manual[key] and two then return end
    	gates_nowmoving[key] = true
    	gates_state[key] = true
    	for k,v in pairs(placed_gates) do
            if key == v[1] then
                local x,y,z = getElementPosition(v[2])
                moveObject(v[2],1000,x,y,z-1.4,0,0,0)
            end
        end
        for k,v in pairs(placed_gates) do
            if v[1] == key then
                triggerClientEvent(root,"playSound",source,v[2])
                break
            end
        end
        if two then
        	triggerClientEvent(source,"money",source,source)
        	triggerClientEvent(source,"writeInChat",source,"outputChatBox","Sikeresen kifizetted a határdíjat!","success")
        	triggerClientEvent(source,"writeInChat",source,"me","kifizeti a határdíjat")
            local syntax = exports['cr_core']:getServerSyntax("Határ", "info")
            local color = exports['cr_core']:getServerColor(nil, true)
            local white = "#ffffff"
            local r1,g1,b1,r2,g2,b2,r3,g3,b3,r4,g4,b4 = source.vehicle:getColor(true)
            local hex1 = RGBToHex(r1,g1,b1)
            local hex2 = RGBToHex(r2,g2,b2)
            local hex3 = RGBToHex(r3,g3,b3)
            local hex4 = RGBToHex(r4,g4,b4)
            local wanted = false
            local reason = ""
            --triggerClientEvent(root,"writeInChat",source,"faction",{syntax .. "Egy jármű átlépte a határt ("..color..getZoneName(source.vehicle.position)..white..") | "..white.."Típus:"..color.." "..exports['cr_vehicle']:getVehicleName(source.vehicle.model), syntax .. "Rendszám: "..color..source.vehicle.plateText..white.." | "..hex1.."Szín1"..white.." - "..hex2.."Szín2"..white.." - "..hex3.."Szín3"..white.." - "..hex4.."Szín4", syntax .. "Körözés: ".. (wanted and ("#ff3333Van#ffffff, Indok: "..color..reason) or "#33ff33Nincs")})
            for k,v in pairs(factions) do 
                exports['cr_dashboard']:sendMessageToFaction(tonumber(v), syntax .. "Egy jármű átlépte a határt ("..color..getZoneName(source.vehicle.position)..white..") | "..white.."Típus:"..color.." "..exports['cr_vehicle']:getVehicleName(source.vehicle.model))
                exports['cr_dashboard']:sendMessageToFaction(tonumber(v), syntax .. "Rendszám: "..color..source.vehicle.plateText..white.." | "..hex1.."Szín1"..white.." - "..hex2.."Szín2"..white.." - "..hex3.."Szín3"..white.." - "..hex4.."Szín4")
                exports['cr_dashboard']:sendMessageToFaction(tonumber(v), syntax .. "Körözés: ".. (wanted and ("#ff3333Van#ffffff, Indok: "..color..reason) or "#33ff33Nincs"))
            end 
        	setTimer(
        		function(key,pl)
        			gates_nowmoving[key] = false
        			moveGate(key,false,true,pl)
        		end
        	,3000,1,key,source,true)
        else
            triggerClientEvent(source,"writeInChat",source,"me","megnyom egy gombot a határkezelőn")
        	setTimer(
        		function(key)
        			gates_nowmoving[key] = false
        		end
        	,1200,1,key)
        end
    elseif not value then -- felfele
    	if not gates_state[key] then return end
    	gates_nowmoving[key] = true
    	gates_state[key] = false
    	for k,v in pairs(placed_gates) do
            if key == v[1] then
                local x,y,z = getElementPosition(v[2])
                moveObject(v[2],1000,x,y,z+1.4,0,0,0)
            end
        end
        for k,v in pairs(placed_gates) do
            if v[1] == key then
                triggerClientEvent(root,"playSound",pl,v[2])
                break
            end
        end
        if not two then
            triggerClientEvent(source,"writeInChat",source,"me","megnyom egy gombot a határkezelőn")
        end
        setTimer(
        	function(key)
        		gates_nowmoving[key] = false
        	end
        ,1200,1,key)
    end
end
addEvent("moveSync",true)
addEventHandler("moveSync",root,moveGate)
    
function RGBToHex(red, green, blue, alpha)

	-- Make sure RGB values passed to this function are correct
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end

	-- Alpha check
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end

end