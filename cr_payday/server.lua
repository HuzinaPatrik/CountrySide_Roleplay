local spamTimers = {};
local pendingSalaries = {};

addEvent("payDay", true)
function payDay(e, vehs, interiors, factions, playTime, bankmoney)
	local factionPayment = factions['total']

	local summary = {
		{name = 'Adó', value = 0},
		{name = 'Járműadó', value = math.floor((#vehs * 75) * -1), list = {}},
		{name = 'Ingatlanadó', value = math.floor((#interiors * 150) * -1), list = {}},
		{name = 'Frakció fizetés', value = math.floor(factionPayment), list = {}},
		{name = 'Jövedelem adó', value = math.floor((factionPayment * 0.05) * -1)}, -- MÉG 1 HELYEN VAN SZÓVAL HA EDITELED FIGYELJ ODA!!!
		{name = 'Kamat', value = math.floor(math.min(100000, bankmoney * 0.02))}, 

		['total'] = 0,
	}

	if factions['total'] <= 0 then 
		local aid = 0 
		if playTime < 300 then 
			aid = 300
		elseif playTime < 500 then 
			aid = 200
		else
			aid = 150
		end 

		table.insert(summary, 6, {name = 'Segély', value = aid})
	else 
		table.insert(summary, 6, {name = 'Segély', value = 0})
	end 
	
	for k,v in ipairs(vehs) do 
		table.insert(summary[2]['list'], {id = v:getData("veh >> id"), name = exports['cr_vehicle']:getVehicleName(v.model), value = -75})
	end 

	for k,v in ipairs(interiors) do 
		local markerData = v:getData("marker >> data") or {}

		table.insert(summary[3]['list'], {id = markerData['id'], name = markerData['name'], value = -150})
	end 

	for k,v in pairs(factions) do 
		if k ~= "total" then 
			local payed = false 

			if exports['cr_dashboard']:requestFactionMoney(v['id']) >= v['value'] then 
				if exports['cr_dashboard']:takeFactionMoney(e, v['id'], v['value']) then 
					payed = true 

					table.insert(summary[4]['list'], {id = v['id'], name = v['name'], value = v['value']})
				end 
			end 

			if not payed then 
				table.insert(summary[4]['list'], {id = v['id'], name = v['name'], value = 0})

				factions['total'] = factions['total'] - v['value']

				factionPayment = factions['total']

				summary[4]['value'] = math.floor(factionPayment)
				summary[5]['value'] = math.floor((factionPayment * 0.05) * -1)
			end 
		end
	end 

	for k, v in pairs(summary) do
		if k ~= "total" then
			summary['total'] = summary['total'] + v.value
		end
	end

	local tax = math.abs((summary[2]['value'] * -1) + (summary[3]['value'] * -1) + (summary[5]['value'] * -1))
	exports['cr_dashboard']:giveMoneyToFaction(e, 4, tax) -- GOVERMENT TAX Giving

	if(pendingSalaries[e:getData("acc >> id")]) then
		for i, v in pairs(pendingSalaries[e:getData("acc >> id")]) do
			local found = false
			for i2, v2 in pairs(summary) do
				if(v.name and v2.name and v2.name == v.name) then
					v2.value = v2.value+v.value
					local notInTable = {}
					for ind, val in pairs(v.list) do
						if(v2.list[ind].id == val.id) then
							pendingSalaries[e:getData("acc >> id")][i].value = v2.list[ind].value+val.value 
						else
							table.insert(notInTable, val)
						end
					end
					if(#notInTable > 0) then
						v2.list = {unpack(v2.list), unpack(notInTable)}
					end
					found = true
				end
			end
			if(not found) then
				table.insert(summary, v)
			end
		end
	end

	triggerClientEvent(e, "showSummary", e, summary)
	pendingSalaries[e:getData("acc >> id")] = summary
end
addEventHandler("payDay", root, payDay)

addEvent("checkPending", true)
addEventHandler("checkPending", root, function(e) 
	local id = e:getData("acc >> id")
	if(pendingSalaries[id]) then
		local summary = pendingSalaries[id]
		triggerClientEvent(e, "showSummary", e, summary)
	end
end)

addEvent("payTotal", true)
addEventHandler("payTotal", root, function(e) 
	if(not isTimer(spamTimers[e:getData("acc >> id")])) then
		if(pendingSalaries[e:getData("acc >> id")]) then
			exports['cr_infobox']:addBox(e, 'info', 'Megkaptad a fizetésed!')
			exports['cr_core']:giveMoney(e, pendingSalaries[e:getData("acc >> id")].total, true)
			pendingSalaries[e:getData("acc >> id")] = false
		end
		
		spamTimers[e:getData("acc >> id")] = setTimer(function() end, 30000, 1)
	end
end)