local cache = {}

function loadNPC(row)
    local id = tonumber(row["id"])
    local name = tostring(row["name"])
    local items = fromJSON(tostring(row["items"]))
    local position = fromJSON(tostring(row["position"]))
    local x,y,z,dim,int,rot = unpack(position)
    local skinID = tonumber(row["skinid"])
    local type = tonumber(row["type"])
    local static = tonumber(row['static'])

    local ped = createPed(skinID, x, y, z)
    ped.rotation = Vector3(0, 0, rot)
    ped.dimension = dim
    ped.interior = int 
    ped.frozen = true
    ped:setData("shop >> id", id)
    ped:setData("shop >> items", items)
    ped:setData("shop >> type", type)
    ped:setData('shop >> static', tonumber(static or 0) == 0)

    ped:setData("ped.name", name)
    ped:setData("ped.type", type == 2 and 'Okmányiroda' or "Eladó")			
    ped:setData("char >> noDamage", true)

    cache[id] = ped
end 

function loadNPCS()
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    loadNPC
                )
            end
            outputDebugString("Loading shop_npcs finished. Loaded #"..query_lines.." shop_npcs!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM shop_npc")
end
addEventHandler("onResourceStart", resourceRoot, loadNPCS)

function createShopNPC(sourcePlayer, cmd, name, type, skinID, static)
    if exports['cr_permission']:hasPermission(sourcePlayer, "createshopnpc") then 
        type = tonumber(type)
        skinID = tonumber(skinID)
        static = tonumber(static) or 0

        if name and tonumber(type) and tonumber(skinID) then 
            if not shopTypes[type] then 
                local syntax = exports["cr_core"]:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Ez a frakció típus nem létezik!", sourcePlayer, 255, 255, 255, true)
                return 
            elseif not exports['cr_skins']:isSkinValid(skinID) then 
                local syntax = exports["cr_core"]:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Ez a skin nem létezik!", sourcePlayer, 255, 255, 255, true)
                return 
            end 

            name = name:gsub("_", " ")
            local items = toJSON(shopTypes[type])
            local position = toJSON({sourcePlayer.position.x, sourcePlayer.position.y, sourcePlayer.position.z, sourcePlayer.dimension, sourcePlayer.interior, sourcePlayer.rotation.z})
            dbExec(connection, "INSERT INTO shop_npc SET name=?, items=?, position=?, type=?, skinid=?, static=?", name, items, position, type, skinID, static)
            dbQuery(
                function(query)
                    local query, query_lines = dbPoll(query, 0)
                    if query_lines > 0 then
                        Async:foreach(query, 
                            function(row)
                                loadNPC(row)

                                local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                                local blue = exports['cr_core']:getServerColor('orange', true)
                                local white = "#ffffff"
                                outputChatBox(syntax .. "Sikeresen létrehoztad a shop npc-t! (ID: "..blue..tonumber(row["id"])..white..", Név: "..blue..tostring(row["name"])..white..")", sourcePlayer, 255, 255, 255, true)

                                local green = exports['cr_core']:getServerColor("orange", true)
                                local white = "#ffffff"
                                local syntax = exports['cr_admin']:getAdminSyntax()
                                local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                                exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." létrehozott egy shop npc-t! (ID: "..blue..tonumber(row["id"])..white..", Név: "..blue..tostring(row["name"])..white..")", 6)
                                exports['cr_logs']:addLog(sourcePlayer, "Shop", "createshop", syntax..aName.." létrehozott egy shop npc-t! (ID: "..tonumber(row["id"])..", Név: "..tostring(row["name"])..")")
                            end 
                        )
                    end
                    outputDebugString("Loading shop_npc finished. Loaded #"..query_lines.." shop_npc!", 0, 255, 50, 255)
                end, 
            connection, "SELECT * FROM `shop_npc` WHERE name=? AND items=? AND position=? AND skinid=?", name, items, position, skinID)
            
        else 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [név (Space-t _ illusztráld!)] [típus ID] [skinID] [Statikus (Biznisz/Frissülő = 0, Sima = 1)]", sourcePlayer, 255, 255, 255, true)
        end 
    end
end
addCommandHandler("createshopnpc", createShopNPC)
addCommandHandler("addshopnpc", createShopNPC)
addCommandHandler("makeshopnpc", createShopNPC)

function showShopNPCTypes(sourcePlayer, cmd)
    if exports['cr_permission']:hasPermission(sourcePlayer, "showshopnpctypes") then 
        local syntax = exports['cr_core']:getServerSyntax(nil, "info")
        local blue = exports['cr_core']:getServerColor('orange', true)
        local white = "#ffffff"
        outputChatBox(syntax .. "Bolt típusok:", sourcePlayer, 255, 255, 255, true)
        for k,v in ipairs(shopTypes) do 
            outputChatBox(blue .. k, sourcePlayer, 255, 255, 255, true)
        end 
    end 
end 
addCommandHandler("showshopnpctypes", showShopNPCTypes)

function deleteShopNPC(sourcePlayer, cmd, id)
    if exports['cr_permission']:hasPermission(sourcePlayer, "deleteshopnpc") then 
        id = tonumber(id)

        if tonumber(id) then 
            local data = cache[id]
            if data then
                cache[id]:destroy()
                cache[id] = nil

                dbExec(connection, "DELETE FROM shop_npc WHERE ID=?", id)

                collectgarbage("collect")

                local blue = exports['cr_core']:getServerColor('orange', true)
                local white = "#ffffff"
                local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                outputChatBox(syntax .. "Sikeresen törölted a shop npc-t! (ID: "..blue..id..white..")", sourcePlayer, 255, 255, 255, true)

                local green = exports['cr_core']:getServerColor("orange", true)
                local white = "#ffffff"
                local syntax = exports['cr_admin']:getAdminSyntax()
                local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." törölt egy shop npc-t! (ID: "..blue..id..white..")", 6)
                exports['cr_logs']:addLog(sourcePlayer, "Shop", "deleteshopnpc", syntax..aName.." törölt egy shop npc-t! (ID: "..id..")")
            else
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Nem létezik ilyen shop npc!", sourcePlayer, 255, 255, 255, true)
            end 
        else 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [id]", sourcePlayer, 255, 255, 255, true)
        end 
    end
end 
addCommandHandler("deleteshopnpc", deleteShopNPC)
addCommandHandler("removeshopnpc", deleteShopNPC)

function setShopNPCStaticStatus(sourcePlayer, cmd, id, static)
    if exports['cr_permission']:hasPermission(sourcePlayer, "setshopnpcstatic") then 
        id = tonumber(id)
        static = tonumber(static)

        if tonumber(id) and tonumber(static) then 
            local data = cache[id]
            if data then
                cache[id]:setData('shop >> static', tonumber(static) == 0)

                connection:exec('UPDATE shop_npc SET static=? WHERE ID=?', tonumber(static), id)

                collectgarbage("collect")

                local blue = exports['cr_core']:getServerColor('orange', true)
                local white = "#ffffff"
                local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                outputChatBox(syntax .. "Sikeresen frissítetted a shop npc statikus állapotát! (ID: "..blue..id..white..", Új állapot: "..blue..static..white..")", sourcePlayer, 255, 255, 255, true)

                local green = exports['cr_core']:getServerColor("orange", true)
                local white = "#ffffff"
                local syntax = exports['cr_admin']:getAdminSyntax()
                local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." frissítette egy shop npc statikus állapotát! (ID: "..blue..id..white..", Új állapot: "..blue..static..white..")", 6)
                exports['cr_logs']:addLog(sourcePlayer, "Shop", "setshopnpcstatic", syntax..aName.." frissítette egy shop npc statikus állapotát! (ID: "..id.."), Új állapot: "..static..")")
            else
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Nem létezik ilyen shop npc!", sourcePlayer, 255, 255, 255, true)
            end 
        else 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [id] [új állapot (Biznisz/Frissülő = 0, Sima = 1)]", sourcePlayer, 255, 255, 255, true)
        end 
    end
end 
addCommandHandler("setshopnpcstatic", setShopNPCStaticStatus)
addCommandHandler("setshopnpcstaticstatus", setShopNPCStaticStatus)

function getShopNPC(sourcePlayer, cmd, id)
    if exports['cr_permission']:hasPermission(sourcePlayer, "getshopnpc") then 
        id = tonumber(id)

        if tonumber(id) then 
            local data = cache[id]
            if data then
                cache[id].position = sourcePlayer.position
                cache[id].rotation = sourcePlayer.rotation
                cache[id].dimension = sourcePlayer.dimension
                cache[id].interior = sourcePlayer.interior

                local position = toJSON({cache[id].position.x, cache[id].position.y, cache[id].position.z, cache[id].dimension, cache[id].interior, cache[id].rotation.z})

                dbExec(connection, "UPDATE shop_npc SET position=? WHERE ID=?", position, id)

                collectgarbage("collect")

                local blue = exports['cr_core']:getServerColor('orange', true)
                local white = "#ffffff"
                local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                outputChatBox(syntax .. "Sikeresen áthelyezted a shop npc-t! (ID: "..blue..id..white..")", sourcePlayer, 255, 255, 255, true)

                local green = exports['cr_core']:getServerColor("orange", true)
                local white = "#ffffff"
                local syntax = exports['cr_admin']:getAdminSyntax()
                local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." áthelyezett egy shop npc-t! (ID: "..blue..id..white..")", 6)
                exports['cr_logs']:addLog(sourcePlayer, "Shop", "getshopnpc", syntax..aName.." áthelyezett egy shop npc-t! (ID: "..id..")")
            else
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Nem létezik ilyen shop npc!", sourcePlayer, 255, 255, 255, true)
            end 
        else 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [id]", sourcePlayer, 255, 255, 255, true)
        end 
    end
end 
addCommandHandler("getshopnpc", getShopNPC)
addCommandHandler("moveshopnpc", getShopNPC)

function renameShopNPC(sourcePlayer, cmd, id, newName)
    if exports['cr_permission']:hasPermission(sourcePlayer, "renameshopnpc") then 
        id = tonumber(id)

        if tonumber(id) and newName then 
            local data = cache[id]
            if data then
                cache[id]:setData('ped.name', newName:gsub('_', ' '))

                dbExec(connection, "UPDATE shop_npc SET name=? WHERE ID=?", newName:gsub('_', ' '), id)

                collectgarbage("collect")

                local blue = exports['cr_core']:getServerColor('orange', true)
                local white = "#ffffff"
                local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                outputChatBox(syntax .. "Sikeresen átnevezted a shop npc-t! (ID: "..blue..id..white..", Név: "..blue..(newName:gsub('_', ' '))..white..")", sourcePlayer, 255, 255, 255, true)

                local green = exports['cr_core']:getServerColor("orange", true)
                local white = "#ffffff"
                local syntax = exports['cr_admin']:getAdminSyntax()
                local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." átnevezett egy shop npc-t! (ID: "..blue..id..white..", Név: "..blue..(newName:gsub('_', ' '))..white..")", 6)
                exports['cr_logs']:addLog(sourcePlayer, "Shop", "renameshopnpc", syntax..aName.." átnevezett egy shop npc-t! (ID: "..id..", Név: "..(newName:gsub('_', ' '))..")")
            else
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Nem létezik ilyen shop npc!", sourcePlayer, 255, 255, 255, true)
            end 
        else 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [id]", sourcePlayer, 255, 255, 255, true)
        end 
    end
end 
addCommandHandler("setnameshopnpc", renameShopNPC)
addCommandHandler("renameshopnpc", renameShopNPC)

function addShopNPCItem(id, itemid, value, nbt, price)
    if tonumber(id) and tonumber(itemid) and tonumber(price) and tonumber(price) >= 1 then 
        if cache[tonumber(id)] then
            local ped = cache[tonumber(id)] 
            local items = ped:getData("shop >> items") or {}

            if not value then value = 1 end
            if not nbt then nbt = 1 end

            table.insert(items, {itemid, value, nbt, price})

            ped:setData("shop >> items", items)

            dbExec(connection, "UPDATE shop_npc SET items=? WHERE ID=?", toJSON(items), id)
        end 
    end 
end 

function removeShopNPCItem(id, itemID)
    if tonumber(id) and tonumber(itemID) then 
        if cache[tonumber(id)] then
            local ped = cache[tonumber(id)] 
            local items = ped:getData("shop >> items") or {}
            if items then 
                table.remove(items, itemID)

                ped:setData("shop >> items", items)

                dbExec(connection, "UPDATE shop_npc SET items=? WHERE ID=?", toJSON(items), id)
            end 
        end 
    end 
end 

function addShopNPCItemCMD(sourcePlayer, cmd, id, itemid, value, nbt, price)
    if exports['cr_permission']:hasPermission(sourcePlayer, "additemtoshopnpc") then 
        if not tonumber(id) or not tonumber(itemid) or not tonumber(price) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [id] [itemID] [érték (Nem muszáj!)] [nbt (Nem muszáj!)] [Ár]", sourcePlayer, 255, 255, 255, true)
            return 
        else 
            if cache[tonumber(id)] then
                if tonumber(itemid) >= 1 and tonumber(price) >= 1 then 
                    local green = exports['cr_core']:getServerColor("orange", true)
                    local white = "#ffffff"
                    local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                    outputChatBox(syntax .. "Sikeresen hozzáadott egy tárgyat a shop nchez! (ID: "..green..id..white..", Item ID: "..green..itemid..white..")", sourcePlayer, 255, 255, 255, true)
                    addShopNPCItem(tonumber(id), tonumber(itemid), value, nbt, price)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                    exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." hozzáadott egy tárgyat a shop npchez! (ID: "..green..id..white..", Item ID: "..green..itemid..white..")", 9)
                    exports['cr_logs']:addLog(sourcePlayer, "Shop", "additemtoshopnpc", syntax..aName.." hozzáadott egy tárgyat a shop npchez! (ID: "..id..", Item ID: "..itemid..")")
                else
                    local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                    outputChatBox(syntax .. "Az itemidnek / darabnak / árnak egy számnak kell lennie mely nagyobb mint 0!", sourcePlayer, 255, 255, 255, true) 
                end 
            else 
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Ez a duty nem létezik!", sourcePlayer, 255, 255, 255, true)
            end 
        end 
    end 
end 
addCommandHandler("additemtoshopnpc", addShopNPCItemCMD)
addCommandHandler("createitemtoshopnpc", addShopNPCItemCMD)

function getShopNPCItems(sourcePlayer, cmd, id)
    if exports['cr_permission']:hasPermission(sourcePlayer, "getshopnpcitems") then 
        if not tonumber(id) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ID]", sourcePlayer, 255, 255, 255, true)
            return 
        else 
            if cache[tonumber(id)] then
                local ped = cache[tonumber(id)] 
                local items = ped:getData("shop >> items") or {}
                if #items >= 1 then 
                    local white = "#ffffff"
                    local green = exports['cr_core']:getServerColor("orange", true)
                    local syntax = exports['cr_core']:getServerSyntax(nil, "info")
                    for k,v in pairs(items) do
                        local id = k 
                        local itemid, value, nbt, price = unpack(v)
                        if id > 0 then
                            outputChatBox(syntax.."ID: "..green..id..white..", ItemID: "..green..itemid..white..", Érték: "..green..value..white..", NBT: "..green..nbt..white..", Ár: "..green..price, sourcePlayer, 255,255,255,true)
                        end
                    end
                else 
                    local green = exports['cr_core']:getServerColor("orange", true)
                    local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                    outputChatBox(syntax .. "Ehhez a shop npchez nincs hozzáadva item!", sourcePlayer, 255,255,255,true)
                end 
            else
                local green = exports['cr_core']:getServerColor("orange", true)
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Nincs ilyen shop npc!", sourcePlayer, 255,255,255,true)
            end
        end 
    end 
end 
addCommandHandler("getshopnpcitems", getShopNPCItems)

function deleteShopNPCItemCMD(sourcePlayer, cmd, shopID, id)
    if exports['cr_permission']:hasPermission(sourcePlayer, "removeitemshopnpc") then 
        if not tonumber(shopID) or not tonumber(id) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [Shop NPC ID] [ID]", sourcePlayer, 255, 255, 255, true)
            return
        else 
            if cache[tonumber(shopID)] then
                local ped = cache[tonumber(shopID)] 
                local items = ped:getData("shop >> items") or {}
                if items[tonumber(id)] then 
                    local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                    local green = exports['cr_core']:getServerColor("orange", true)
                    local white = "#ffffff"
                    outputChatBox(syntax .. "Sikeresen törölted a shop npc itemet! (Shop ID: "..green..shopID..white..", ID: "..green..id..white..")", sourcePlayer, 255, 255, 255, true)
                    removeShopNPCItem(tonumber(shopID), tonumber(id))
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                    exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." törölt egy shop npc itemet! (Shop ID: "..green..shopID..white..", ID: "..green..id..white..")", 9)
                    exports['cr_logs']:addLog(sourcePlayer, "Shop", "removeitemshopnpc", syntax..aName.." törölt egy shop npc itemet! (Shop ID: "..shopID..", ID: "..id..")")
                else 
                    local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                    outputChatBox(syntax .. "Ez a shop npc item nem létezik!", sourcePlayer, 255, 255, 255, true)
                end 
            else 
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Ez a shop npc nem létezik!", sourcePlayer, 255, 255, 255, true)
            end 
        end 
    end 
end 
addCommandHandler("removeitemshopnpc", deleteShopNPCItemCMD)
addCommandHandler("delitemshopnpc", deleteShopNPCItemCMD)
addCommandHandler("deleteitemshopnpc", deleteShopNPCItemCMD)