connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

shops = {};

addEventHandler("onResourceStart", resourceRoot, function() 
	dbQuery(function(query) 
		local query, query_lines = dbPoll(query, 0)
		if(query_lines > 0) then
			for i, v in pairs(query) do
				local data = fromJSON(v["data"]) or {}
				local npcs = fromJSON(v["npcs"]) or {}
				local carts = fromJSON(v["carts"]) or {}
				local objects = fromJSON(v["objects"]) or {}
				loadShop(tonumber(v["id"]), data, objects, carts, npcs)
			end
		end
	end, connection, "SELECT * FROM shop")
end)

function loadShop(id, d, o, c, n)
	local x, y, z = unpack(d["pos"])
	local col = createColSphere(x, y, z, global.radius)
	col.interior = tonumber(d["interior"])
	col.dimension = tonumber(d["dimension"])
	col:setData("shop >> id", id)
	col:setData("shop >> radius", true)
	local otbl = {}
	for i, v in pairs(o) do
		x, y, z = unpack(v["pos"])
		local rx, ry, rz = unpack(v["rot"])
		local obj = createObject(v["model"], x, y, z)
		obj.rotation = Vector3(rx, ry, rz)
		obj.interior = tonumber(d["interior"])
		obj.dimension = tonumber(d["dimension"])
		obj:setData("shop >> id", id)
		obj:setData("shop >> object", true)
		obj:setData("shop >> objectid", tonumber(v["id"]))
		obj:setData("shop >> items", v["items"])
		otbl[tonumber(v["id"])] = obj
	end
	local ctbl = {}
	for i, v in pairs(c) do
		x, y, z = unpack(v["pos"])
		local rx, ry, rz = unpack(v["rot"])
		local cart = createObject(global.basket, x, y, z)
		cart.rotation = Vector3(rx, ry, rz)
		cart.interior = tonumber(d["interior"])
		cart.dimension = tonumber(d["dimension"])
		cart:setData("shop >> id", id)
		cart:setData("shop >> cart", true)
		ctbl[tonumber(v["id"])] = cart
	end
	local ntbl = {}
	for i, v in pairs(n) do
		x, y, z = unpack(v["pos"])
		local rx, ry, rz = unpack(v["rot"])
		local npc = createPed(global.skin, x, y, z)
		npc.interior = tonumber(d["interior"])
		npc.dimension = tonumber(d["dimension"])
		npc.rotation = Vector3(rx, ry, rz)
		npc:setData("shop >> id", id)
		npc:setData("shop >> npc", true)
		npc:setData("ped.name", tostring(v["name"]))
		npc:setData("ped.type", "Pénztáros")
		npc:setData("char >> noDamage", true)
		npc.frozen = true
		ntbl[tonumber(v["id"])] = npc
	end
	shops[id] = {radius = col, objects = otbl, carts = ctbl, npcs = ntbl}
end

addCommandHandler("createshop", function(e, cmd) 
	if(exports['cr_permission']:hasPermission(e, cmd)) then
		local pos = e.position
		local data = toJSON({["pos"] = {pos.x, pos.y, pos.z}, ["interior"] = e.interior, ["dimension"] = e.dimension})
		dbExec(connection, "INSERT INTO shop SET data = ?", data)
		dbQuery(function(query)
			local query, query_lines = dbPoll(query, 100)
			if(query_lines > 0) then
				for i, v in pairs(query) do
					local d = fromJSON(v["data"])
					local x, y, z = unpack(d["pos"])
					local col = createColSphere(x, y, z, global.radius)
					col:setData("shop >> id", tonumber(v["id"]))
					col:setData("shop >> radius", true)
					shops[tonumber(v["id"])] = {radius = col}
					exports["cr_infobox"]:addBox(e, "success", "Bolti terület létrehozva! ID: "..v["id"])
					triggerClientEvent(root, "receiveShops", root, shops)
					break
				end
			end
		end, connection, "SELECT * FROM shop WHERE data = ?", data)
	end
end)

addCommandHandler("addshopcashier", function(e, cmd)
	if(exports['cr_permission']:hasPermission(e, cmd)) then
		local col = getElementColShape(e)
		if(isElement(col) and col:getData("shop >> radius")) then
			id = tonumber(col:getData("shop >> id"))
			if(shops[id]) then
				local name = exports["cr_core"]:createRandomMaleName()
				local pos = e.position
				local rot = e.rotation
				local data = {}
				if(shops[id].npcs) then
					for i, v in pairs(shops[id].npcs) do
						table.insert(data, {["pos"] = {v.position.x, v.position.y, v.position.z}, ["rot"] = {v.rotation.x, v.rotation.y, v.rotation.z}, ["name"] = v:getData("ped.name"), ["id"] = i})
					end
				end
				if(not shops[id].npcs) then
					shops[id].npcs = {}
				end
				local npcid = #shops[id].npcs+1
				table.insert(data, {["pos"] = {pos.x, pos.y, pos.z}, ["rot"] = {rot.x, rot.y, rot.z}, ["name"] = name, ["id"] = npcid})
				dbExec(connection, "UPDATE shop SET npcs = ? WHERE id = ?", toJSON(data), id)
				dbQuery(function(query)
					local query, query_lines = dbPoll(query, 0)
					if(query_lines > 0) then
						for i, v in pairs(query) do
							local npc = createPed(global.skin, pos)
							npc.rotation = rot
							npc:setData("shop >> id", id)
							npc:setData("shop >> npc", true)
							npc:setData("ped.name", tostring(name))
							npc:setData("ped.type", "Pénztáros")
							npc:setData("char >> noDamage", true)
							npc.frozen = true
							shops[id].npcs[npcid] = npc
							exports["cr_infobox"]:addBox(e, "success", "Pénztáros hozzáadva a bolti területhez.")
							break
						end
					end
				end, connection, "SELECT * FROM shop WHERE npcs = ?", toJSON(data))
			end
		else
			exports["cr_infobox"]:addBox(e, "error", "Nem tartózkodsz bolti területen belül.")
		end
	end
end)

addCommandHandler("addshopbasket", function(e, cmd)
	if(exports['cr_permission']:hasPermission(e, cmd)) then
		local col = getElementColShape(e)
		if(isElement(col) and col:getData("shop >> radius")) then
			id = tonumber(col:getData("shop >> id"))
			if(shops[id]) then
				local pos = e.position
				local rot = e.rotation
				local data = {}
				if(shops[id].carts) then
					for i, v in pairs(shops[id].carts) do
						table.insert(data, {["pos"] = {v.position.x, v.position.y, v.position.z}, ["rot"] = {v.rotation.x, v.rotation.y, v.rotation.z}, ["id"] = i})
					end
				end
				if(not shops[id].carts) then
					shops[id].carts = {}
				end
				local cartid = #shops[id].carts+1
				table.insert(data, {["pos"] = {pos.x, pos.y, pos.z-1}, ["rot"] = {rot.x, rot.y, rot.z}, ["id"] = cartid})
				dbExec(connection, "UPDATE shop SET carts = ? WHERE id = ?", toJSON(data), id)
				dbQuery(function(query)
					local query, query_lines = dbPoll(query, 0)
					if(query_lines > 0) then
						for i, v in pairs(query) do
							local cart = createObject(global.basket, pos.x, pos.y, pos.z-1)
							cart.rotation = rot
							cart:setData("shop >> id", id)
							cart:setData("shop >> cart", true)
							shops[id].carts[cartid] = cart
							exports["cr_infobox"]:addBox(e, "success", "Kosár hozzáadva a bolti területhez.")
							break
						end
					end
				end, connection, "SELECT * FROM shop WHERE carts = ?", toJSON(data))
			end
		else
			exports["cr_infobox"]:addBox(e, "error", "Nem tartózkodsz bolti területen belül.")
		end
	end
end)

addCommandHandler("deleteshop", function(e, cmd)
	if(exports['cr_permission']:hasPermission(e, cmd)) then
		local col = getElementColShape(e)
		if(isElement(col) and col:getData("shop >> radius")) then
			id = tonumber(col:getData("shop >> id"))
			if(shops[id]) then
				shops[id].radius:destroy()
				for i, v in pairs(shops[id].objects) do
					v:destroy()
				end
				for i, v in pairs(shops[id].npcs) do
					v:destroy()
				end
				for i, v in pairs(shops[id].carts) do
					v:destroy()
				end
				dbExec(connection, "DELETE FROM shop WHERE id = ?", id)
				exports["cr_infobox"]:addBox(e, "success", "Bolt törölve.")
				triggerClientEvent(root, "receiveShops", root, shops)
			end
		else
			exports["cr_infobox"]:addBox(e, "error", "Nem tartózkodsz bolti területen belül.")
		end
	end
end)

addEvent("requestShops", true)
addEventHandler("requestShops", root, function(e) 
	triggerClientEvent(e, "receiveShops", e, shops)
end)

addEvent("moveObject", true)
addEventHandler("moveObject", root, function(e, shopid, id, pos, rot)
	shops[shopid].objects[id].position = Vector3(unpack(pos))
	shops[shopid].objects[id].rotation = Vector3(unpack(rot))
	local data = {};
	for i, v in pairs(shops[shopid].objects) do
		table.insert(data, {["model"] = v.model, ["pos"] = {v.position.x, v.position.y, v.position.z}, ["rot"] = {v.rotation.x, v.rotation.y, v.rotation.z}, ["id"] = i, ["items"] = v:getData("shop >> items")})
	end
	dbExec(connection, "UPDATE shop SET objects = ? WHERE id = ?", toJSON(data), shopid)
	exports["cr_infobox"]:addBox(e, "success", "Polc áthelyezve.")
	triggerClientEvent(root, "receiveShops", root, shops)
end)

addEvent("addObject", true)
addEventHandler("addObject", root, function(e, id, pos, rot, globalid)
	local data = {}
	if(shops[id].objects) then
		for i, v in pairs(shops[id].objects) do
			table.insert(data, {["model"] = v.model, ["pos"] = {v.position.x, v.position.y, v.position.z}, ["rot"] = {v.rotation.x, v.rotation.y, v.rotation.z}, ["id"] = i})
		end
	end
	if(not shops[id].objects) then
		shops[id].objects = {}
	end
	local objectid = #shops[id].objects+1
	table.insert(data, {["model"] = global.object[tonumber(globalid)], ["pos"] = pos, ["rot"] = rot, ["id"] = objectid, ["items"] = {}})
	dbExec(connection, "UPDATE shop SET objects = ? WHERE id = ?", toJSON(data), id)
	dbQuery(function(query)
		local query, query_lines = dbPoll(query, 0)
		if(query_lines > 0) then
			for i, r in pairs(query) do
				local x, y, z = unpack(pos)
				local rx, ry, rz = unpack(rot)
				local obj = createObject(global.object[tonumber(globalid)], x, y, z)
				obj.rotation = Vector3(rx, ry, rz)
				obj:setData("shop >> id", id)
				obj:setData("shop >> object", true)
				obj:setData("shop >> objectid", tonumber(objectid))
				obj:setData("shop >> items", {})
				shops[id].objects[objectid] = obj
				exports["cr_infobox"]:addBox(e, "success", "Polc hozzáadva a bolti területhez.")
				triggerClientEvent(root, "receiveShops", root, shops)
				break
			end
		end
	end, connection, "SELECT * FROM shop WHERE objects = ?", toJSON(data))
end)

addEvent("deleteShopElement", true)
addEventHandler("deleteShopElement", root, function(e, element)
	local id = tonumber(element:getData("shop >> id"))
	if(element.type == "ped") then
		local data = {};
		local removed = false
		for i, v in pairs(shops[id].npcs) do
			if(v == element) then
				table.remove(shops[id].npcs, i)
				removed = true
			end
			if(not removed) then
				table.insert(data, {["model"] = v.model, ["pos"] = {v.position.x, v.position.y, v.position.z}, ["rot"] = {v.rotation.x, v.rotation.y, v.rotation.z}, ["id"] = i, ["name"] = v:getData("ped.name")})
			else
				removed = false
			end
		end
		dbExec(connection, "UPDATE shop SET npcs = ? WHERE id = ?", toJSON(data), id)
	else
		if(element.model == global.basket) then
			local data = {};
			local removed = false
			for i, v in pairs(shops[id].carts) do
				if(v == element) then
					table.remove(shops[id].carts, i)
					removed = true
				end
				if(not removed) then
					table.insert(data, {["model"] = v.model, ["pos"] = {v.position.x, v.position.y, v.position.z}, ["rot"] = {v.rotation.x, v.rotation.y, v.rotation.z}, ["id"] = i})
				else
					removed = false
				end
			end
			dbExec(connection, "UPDATE shop SET carts = ? WHERE id = ?", toJSON(data), id)
		else
			local data = {};
			local removed = false
			for i, v in pairs(shops[id].objects) do
				if(v == element) then
					table.remove(shops[id].objects, i)
					removed = true
				end
				if(not removed) then
					table.insert(data, {["model"] = v.model, ["pos"] = {v.position.x, v.position.y, v.position.z}, ["rot"] = {v.rotation.x, v.rotation.y, v.rotation.z}, ["id"] = i, ["items"] = v:getData("shop >> items")})
				else
					removed = false
				end
			end
			dbExec(connection, "UPDATE shop SET objects = ? WHERE id = ?", toJSON(data), id)
		end
	end
	element:destroy()
	exports["cr_infobox"]:addBox(e, "success", "Törölve.")
end)

addCommandHandler("additemtoshelf", function(e, cmd, id, side, item, price)
	if(exports['cr_permission']:hasPermission(e, cmd)) then
		if(id and side and item and price) then
			local col = getElementColShape(e)
			if(isElement(col) and col:getData("shop >> radius")) then
				local shopid = tonumber(col:getData("shop >> id"))
				local items = shops[shopid].objects[tonumber(id)]:getData("shop >> items") or {}
				if(not items[side]) then
					items[side] = {}
				end
				if(#items[side] < 22) then
					table.insert(items[side], {["item"] = tonumber(item), ["price"] = tonumber(price)})
					shops[shopid].objects[tonumber(id)]:setData("shop >> items", items)
					local data = {};
					for i, v in pairs(shops[shopid].objects) do
						table.insert(data, {["model"] = v.model, ["pos"] = {v.position.x, v.position.y, v.position.z}, ["rot"] = {v.rotation.x, v.rotation.y, v.rotation.z}, ["id"] = i, ["items"] = v:getData("shop >> items")})
					end
					dbExec(connection, "UPDATE shop SET objects = ? WHERE id = ?", toJSON(data), shopid)
					triggerClientEvent(root, "receiveShops", root, shops)
					exports["cr_infobox"]:addBox(e, "success", "Tárgy hozzaadva a polc oldalához.")
				else
					exports["cr_infobox"]:addBox(e, "error", "A polc ezen oldala tele van.")
				end
			end
		else
			e:outputChat(exports['cr_core']:getServerSyntax(nil, "error").."Használat: /"..cmd.." [ID] [SIDE] [ITEM] [PRICE]")
		end
	end
end)

addCommandHandler("removeitemfromshelf", function(e, cmd, id, side, index)
	if(exports['cr_permission']:hasPermission(e, cmd)) then
		if(id and side and index) then
			local col = getElementColShape(e)
			if(isElement(col) and col:getData("shop >> radius")) then
				local shopid = tonumber(col:getData("shop >> id"))
				local items = shops[shopid].objects[tonumber(id)]:getData("shop >> items") or {}
				id, index = tonumber(id), tonumber(index)
				if(items[side] and items[side][index]) then
					table.remove(items[side], index)
					shops[shopid].objects[tonumber(id)]:setData("shop >> items", items)
					local data = {};
					for i, v in pairs(shops[shopid].objects) do
						table.insert(data, {["model"] = v.model, ["pos"] = {v.position.x, v.position.y, v.position.z}, ["rot"] = {v.rotation.x, v.rotation.y, v.rotation.z}, ["id"] = i, ["items"] = v:getData("shop >> items")})
					end
					dbExec(connection, "UPDATE shop SET objects = ? WHERE id = ?", toJSON(data), shopid)
					triggerClientEvent(root, "receiveShops", root, shops)
					exports["cr_infobox"]:addBox(e, "success", "Tárgy törölve a polc oldaláról.")
				else
					exports["cr_infobox"]:addBox(e, "error", "Tárgy nem található ezen a sloton.")
				end
			end
		end
	end
end)

addEvent("pickupBasket", true)
addEventHandler("pickupBasket", root, function(e)
	local pos = e:getPosition()
	local element = createObject(324, pos)
	element:setDoubleSided(true)
	local attach = exports['cr_bone_attach']:attachElementToBone(element, e, 12, 0, 0, 0.05, 180, 0, 0)
	e:setData("shop >> basketInHand", element)
	if(attach)then
		exports['cr_chat']:createMessage(e, "kézhez vesz egy bevásárló kosarat.", 1)
	else
		element:destroy()
	end
end)

addEvent("putdownBasket", true)
addEventHandler("putdownBasket", root, function(e) 
	local element = e:getData("shop >> basketInHand")
	exports['cr_bone_attach']:detachElementFromBone(element)
	element:destroy()
	exports['cr_chat']:createMessage(e, "elrak egy bevásárló kosarat.", 1)
	e:setData("shop >> basketInHand", false)
end)