import("*"):from("cr_core")

local white = "#ffffff"
local anims = {}

addEventHandler("onClientResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_core" then
            import("*"):from("cr_core")
        end
    end
)

function getFont(a, b)
    return exports['cr_fonts']:getFont(a, b)
end

local size = Vector2(200, 165)
local size2 = Vector2(size.x - 20, 25)
lastClickTick = getTickCount()
local saveJSON = {}

local oldWalk = false

function handleInteriorChange(oldInterior, newInterior)
    if source.type == "player" then 
        if localPlayer:getData("char >> follow") and localPlayer:getData("char >> follow") == source then 
            local playerX, playerY, playerZ = getElementPosition(source)

            setTimer(
                function(thePlayer)
                    local newDimension = getElementDimension(thePlayer)
                    local customInterior = thePlayer:getData("customInterior")

                    triggerServerEvent("setElementPosition", localPlayer, localPlayer, playerX, playerY, playerZ, newDimension, newInterior, customInterior)
                end, 250, 1, source
            )
        end
    end
end
addEventHandler("onClientElementInteriorChange", root, handleInteriorChange)

local gButtons = {
    --["type"] = {}
    ["player"] = {
        --{"Név" ({Név ha true, Név ha false, EData}), funcOnPress, checkFunc},
        
        {"Bemutatkozás", {255,153,51,255/100*75},
            function()
                local debutTable = localPlayer:getData("debuts") or {}
                local id2 = tostring(getElementData(e, "acc >> id") or 0)
                local id = tostring(getElementData(localPlayer, "acc >> id") or 0)
                debutTable[tonumber(id2)] = true
                local green = exports['cr_core']:getServerColor('yellow', true)
                local aName = exports['cr_admin']:getAdminName(e, false)
                local syntax = getServerSyntax("Friend", "success")
                outputChatBox(syntax .. "Bemutatkoztál "..green..aName..white.." -nak/nek", 255,255,255,true)
                triggerServerEvent("nametag->goToServer", localPlayer, e, id, localPlayer)
                localPlayer:setData("debuts", debutTable)
            end,
            function()
                local id = tostring(getElementData(localPlayer, "acc >> id") or 0)
                local id2 = tostring(getElementData(e, "acc >> id") or 0)
                local debutTable = localPlayer:getData("debuts") or {}
                if not debutTable[tonumber(id2)] then
                    return true
                
                else
                    return false
                end
            end,
        },
        {"Megmotozás", {255,153,51,255/100*75},
            function()
                local name2 = exports['cr_admin']:getAdminName(e) --e:getData("char >> name")
                exports['cr_chat']:createMessage(localPlayer, "megmotozott egy közelében lévő embert ("..name2..")", 1)
                exports['cr_inventory']:openInventory(e, true, true)
                
                closePanel()
                return
            end,
            function()
                local anim1, anim2 = getPedAnimation(e)
                if anim1 == "ped" and anim2 == "FLOOR_hit" or anim1 == "ped" and anim2 == "FLOOR_hit_f" or anim1 == "ped" and anim2 == "handsup" or e:getData("char >> cuffed") then
                    return true
                else
                    return false
                end
            end,
        },
        {"Vizsgálat", {255,153,51,255/100*75},
            function()
                exports['cr_ambulance']:getBullets(e)
                
                closePanel()
                return
            end,
            function()
                if exports['cr_dashboard']:isPlayerInFaction(localPlayer, 2) then
                    return true
                else
                    return false
                end
            end,
        },
        {{"Követés abbahagyása", "Követés elkezdése", "char >> follow"}, {255,153,51,255/100*75},
            function()
                if not e:getData("char >> follow") then
                    e:setData("char >> follow", localPlayer)

                    oldWalk = exports.cr_dashboard:getOption("defaultwalk")
                    exports.cr_interface:changeWalkingStatus(1)
                    exports.cr_controls:toggleControl("jump", false, "instant")
                    exports.cr_controls:toggleControl("fire", false, "instant")
                    exports.cr_controls:toggleControl("crouch", false, "instant")
                    exports.cr_controls:toggleControl("sprint", false, "instant")
                    exports.cr_controls:toggleControl("action", false, "instant")
                    --exports.cr_controls:toggleControl("enter_exit", false, "instant")
                    exports.cr_controls:toggleControl("walk", false, "instant")
                else
                    e:setData("char >> follow", nil) 

                    if oldWalk then 
                        exports.cr_interface:changeWalkingStatus(oldWalk == 1)
                        oldWalk = false
                    end

                    exports.cr_controls:toggleControl("jump", true, "instant")
                    exports.cr_controls:toggleControl("fire", true, "instant")
                    exports.cr_controls:toggleControl("crouch", true, "instant")
                    exports.cr_controls:toggleControl("sprint", true, "instant")
                    exports.cr_controls:toggleControl("action", true, "instant")
                    --exports.cr_controls:toggleControl("enter_exit", true, "instant")
                    exports.cr_controls:toggleControl("walk", true, "instant")
                end 
            end,
            function()
                if e:getData("char >> bondage") or e:getData("char >> cuffed") then 
                    return true 
                else 
                    return false
                end 
            end,
        },
        {{"Bilincs levétele", "Megbilincselés", "char >> cuffed"}, {255,153,51,255/100*75},
            function()
                if e:getData("char >> bondage") then return end
                if e:getData("char >> follow") then return end
                if not e:getData("char >> cuffed") then
                    local hasItem, slot, data = exports['cr_inventory']:hasItem(localPlayer, 34)
                    if hasItem then
                        e:setData("char >> cuffed", {itemData = data, cuffedBy = localPlayer})
                        e:setData("char >> cuffedID", data[1])
                        exports['cr_inventory']:removeItemFromSlot(1, slot)
                        exports['cr_inventory']:giveItem(localPlayer, 35, data[1])
                        local aName = exports['cr_admin']:getAdminName(e)
                        exports['cr_chat']:createMessage(localPlayer, "megbilincsel egy közelében lévő embert ("..aName..")", 1)
                    end
                else
                    if e:getData("char >> cuffed") then 
                        local num = tonumber(e:getData("char >> cuffedID") or 1)
                        local hasItem, slot, data = exports['cr_inventory']:hasItem(localPlayer, 35, num)

                        if hasItem or exports['cr_permission']:hasPermission(localPlayer, "auncuff") then
                            local cuffData = e:getData("char >> cuffed")
                            local handcuffData = cuffData.itemData
                            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(handcuffData)

                            e:setData("char >> cuffed", false)
                            e:setData("char >> cuffedID", false)

                            if hasItem then 
                                exports['cr_inventory']:removeItemFromSlot(1, slot)
                                exports['cr_inventory']:giveItem(localPlayer, 34, value, count, status, dutyitem, premium, nbt)
                            end 
                            
                            local aName = exports['cr_admin']:getAdminName(e)
                            exports['cr_chat']:createMessage(localPlayer, "leveszi a bilincset egy közelében lévő emberről ("..aName..")", 1)

                            localPlayer.frozen = true
                            setTimer(setElementFrozen, 500, 1, localPlayer, false)
                        end 
                    end 
                end 
            end,
            function()
                if e:getData("char >> bondage") then return end
                if e:getData("char >> follow") then return end
                if not e:getData("char >> cuffed") and not e:getData("inAnim") then
                    if exports['cr_inventory']:hasItem(localPlayer, 34) then
                        return true 
                    else
                        return false
                    end
                elseif e:getData("char >> cuffed") then
                    local num = tonumber(e:getData("char >> cuffedID") or 1)
                    if exports['cr_inventory']:hasItem(localPlayer, 35, num) or exports['cr_permission']:hasPermission(localPlayer, "auncuff") then
                        return true 
                    else
                        return false
                    end
                end
            end,
        },
        {{"Kötél levétele", "Megkötözés", "char >> bondage"}, {255,153,51,255/100*75},
            function()
                if not e:getData("char >> bondage") then
                    local hasItem, slot, data = exports['cr_inventory']:hasItem(localPlayer, 135)
                    if hasItem then
                        e:setData("char >> bondage", true)
                        exports['cr_inventory']:removeItemFromSlot(1, slot)
                        local aName = exports['cr_admin']:getAdminName(e)
                        exports['cr_chat']:createMessage(localPlayer, "megkötöz egy közelében lévő embert ("..aName..")", 1)
                    end
                else 
                    e:setData("char >> bondage", false)
                    exports['cr_inventory']:giveItem(localPlayer, 135)
                    local aName = exports['cr_admin']:getAdminName(e)
                    exports['cr_chat']:createMessage(localPlayer, "leveszi a kötelet egy közelében lévő emberről ("..aName..")", 1)
                end 
            end,
            function()
                if e:getData("char >> cuffed") then return end
                if e:getData("char >> follow") then return end
                if not e:getData("char >> bondage") then
                    if exports['cr_inventory']:hasItem(localPlayer, 135) then
                        return true 
                    else
                        return false
                    end
                else
                    return true
                end
            end,
        },
        {{"Szemkötő levétele", "Szemkötő felrakása", "char >> blinded"}, {255,153,51,255/100*75},
            function()
                if not e:getData("char >> blinded") then
                    local hasItem, slot, data = exports['cr_inventory']:hasItem(localPlayer, 136)
                    if hasItem then
                        e:setData("char >> blinded", true)
                        exports['cr_inventory']:removeItemFromSlot(1, slot)
                        local aName = exports['cr_admin']:getAdminName(e)
                        exports['cr_chat']:createMessage(localPlayer, "felteszi a szemfedőt egy közelében lévő emberre ("..aName..")", 1)
                    end
                else 
                    e:setData("char >> blinded", false)
                    exports['cr_inventory']:giveItem(localPlayer, 136)
                    local aName = exports['cr_admin']:getAdminName(e)
                    exports['cr_chat']:createMessage(localPlayer, "leveszi a szemfedőt egy közelében lévő emberről ("..aName..")", 1)
                end 
            end,
            function()
                if not e:getData("char >> blinded") then
                    if exports['cr_inventory']:hasItem(localPlayer, 136) then
                        return true 
                    else
                        return false
                    end
                else
                    return true
                end
            end,
        },
        -- {{"Levétel a hordágyról", "Hordágyra helyezés", "char >> inAmbulanceBed"}, {255,153,51,255/100*75},
        --     function()
        --         exports['cr_ambulance']:doAmbulanceBedPlacePlayer(e)
                
        --         closePanel()
        --         return
        --     end,
        --     function()
        --         if exports['cr_ambulance']:hasPermissionToDoAmbulanceBedPlacePlayer(e) then
        --             return true
        --         end
        --         return false
        --     end,
        -- },
        {"Átvizsgálás", {255,153,51,255/100*75},
            function()
                exports['cr_ambulance']:syncPlayerBrokenParts(e)
                
                closePanel()
                return
            end,
            function()
                if exports['cr_ambulance']:hasPermissionToSyncPlayerBrokenParts(e) then
                    return true
                else
                    return false
                end
            end,
        },
        {"Nyomókötés felhelyezése", {255,153,51,255/100*75},
            function()
                exports.cr_ambulance:startBleedingMinigame(e)
                
                closePanel()
                return
            end,
            function()
                local bloodData = e:getData("bloodData") or {}

                if #bloodData > 0 and exports.cr_dashboard:isPlayerInFaction(localPlayer, 2) and exports.cr_inventory:hasItem(localPlayer, 130) then
                    return true
                else
                    return false
                end
            end,
        },
        {"Felélesztés", {255,153,51,255/100*75},
            function()
                --outputChatBox("Majd ide a felélesztés cucc")
                local currentItem = 73

                if exports.cr_inventory:hasItem(localPlayer, 130) then 
                    currentItem = 130
                end

                exports['cr_ambulance']:doRespawn(e, currentItem)
                closePanel()
                
                return
            end,
            function()
                if e.health <= 15 then 
                    local dutyFaction = localPlayer:getData("char >> duty")

                    if dutyFaction and dutyFaction == 3 then 
                        if exports.cr_inventory:hasItem(localPlayer, 130) then 
                            return true
                        else
                            return false
                        end
                    else
                        if exports.cr_inventory:hasItem(localPlayer, 73) then
                            return true
                        else 
                            return false 
                        end
                    end
                end 
            end,
        },
        {"Bezárás", {255,153,51,255/100*75},
            function()
                closePanel()
                return
            end,
            function()
                return true
            end,
        },
    },
    ["vehicle"] = {
        {"chanelName", {255,153,51,0},
            function()
                return
            end,
            function()
                if e.model == 448 then 
                    if localPlayer:getData('char >> job') == 7 then 
                        if e == localPlayer:getData('char >> jobVehicle') or tonumber(e:getData('veh >> group') or -1) == tonumber(localPlayer:getData('char >> group') or -2) then 
                            local pizzas = tonumber(e:getData("pizza >> pizza") or 0)
                            chanelName = pizzas .. '/8 db pizza'
                            return true
                        end 
                    end
                end

                return false
            end,
        },

        {"Információk", {255,153,51,255/100*75},
            function()
                local white = "#f2f2f2"
                local green = exports['cr_core']:getServerColor("green", true)
                local red = exports['cr_core']:getServerColor("red", true)
                local orange = exports['cr_core']:getServerColor("orangeNew", true)
                local yellow = exports['cr_core']:getServerColor("yellow", true)
                local blue = exports['cr_core']:getServerColor("yellow", true)

                local tuningData = e:getData("veh >> tuningData") or {}

                local playerVehicleInfos = {
                    ["hoverText"] = 'Jármű Statisztika',
                    ["altText"] = white .. "ID ".. blue .. e:getData("veh >> id") .. white .. " ("..green..exports['cr_vehicle']:getVehicleName(e)..white..") Statisztikái",
                    ["minLines"] = 1,
                    ["maxLines"] = 10,
                    ["texts"] = {},
                }
                table.insert(playerVehicleInfos["texts"], {"ID: ", blue .. e:getData("veh >> id")})

                if e:getData("veh >> id") < 0 then 
                    table.insert(playerVehicleInfos["texts"], "Típus: ".. orange .. exports['cr_vehicle']:convertTemporaryType(tonumber(e:getData("veh >> temporaryType") or 1)))
                    table.insert(playerVehicleInfos["texts"], "Létrehozás dátum: ".. blue .. (e:getData("veh >> createTime") or ''):gsub('[[]', ''):gsub('[]]', ''))
                end 

                local healthColor = green
                if (e.health / 10) <= 75 then 
                    healthColor = yellow
                elseif (e.health / 10) <= 50 then 
                    healthColor = red 
                end 
                local healthText = {white .. "Állapot: ", healthColor .. math.ceil(e.health / 10) .. "%"}
                table.insert(playerVehicleInfos["texts"], healthText)

                local healthColor = green
                if ((e:getData("veh >> fuel") / tonumber(exports['cr_vehicle']:getVehicleMaxFuel(e.model) or 100)) * 100) <= 25 then 
                    healthColor = red 
                elseif ((e:getData("veh >> fuel") / tonumber(exports['cr_vehicle']:getVehicleMaxFuel(e.model) or 100)) * 100) <= 75 then 
                    healthColor = yellow
                end 
                local healthText = {white .. "Üzemanyag: ", healthColor .. math.ceil((e:getData("veh >> fuel") / tonumber(exports['cr_vehicle']:getVehicleMaxFuel(e.model) or 100) * 100))  .. "%" .. " (" .. math.ceil(e:getData("veh >> fuel")) .. "/" .. tonumber(exports['cr_vehicle']:getVehicleMaxFuel(e.model) or 100) .. " l)"}
                table.insert(playerVehicleInfos["texts"], healthText)

                table.insert(playerVehicleInfos["texts"], {white .. "Kilóméterszámláló állása: ", blue .. math.round(e:getData("veh >> odometer"), 1) .. " KM"})

                table.insert(playerVehicleInfos["texts"], {white .. "Rendszám: ", blue .. e.plateText})
                table.insert(playerVehicleInfos["texts"], {white .. "Alvázszám: ", orange .. e:getData("veh >> chassis")})

                table.insert(playerVehicleInfos["texts"], {white .. "Motor: ",(e:getData("veh >> engine") and green .. "Elindítva" or red .. "Leállítva")})
                table.insert(playerVehicleInfos["texts"], {white .. "Lámpa: ",(e:getData("veh >> light") and green .. "Felkapcsolva" or red .. "Lekapcsolva")})
                table.insert(playerVehicleInfos["texts"], {white .. "Kézifék: ",(e:getData("veh >> handbrake") and green .. "Behúzva" or red .. "Kiengedve")})
                table.insert(playerVehicleInfos["texts"], {white .. "Motor: ", orange .. tonumber(tuningData["engine"] or 0)})
                table.insert(playerVehicleInfos["texts"], {white .. "Turbó: ", orange .. tonumber(tuningData["turbo"] or 0)})
                table.insert(playerVehicleInfos["texts"], {white .. "ECU: ", orange .. tonumber(tuningData["ecu"] or 0)})
                table.insert(playerVehicleInfos["texts"], {white .. "Váltó: ", orange .. tonumber(tuningData["gearbox"] or 0)})
                table.insert(playerVehicleInfos["texts"], {white .. "Felfüggesztés: ", orange .. tonumber(tuningData["suspension"] or 0)})
                table.insert(playerVehicleInfos["texts"], {white .. "Fékek: ", orange .. tonumber(tuningData["brakes"] or 0)})
                table.insert(playerVehicleInfos["texts"], {white .. "Súlycsökkentés: ", orange .. tonumber(tuningData["weight"] or 0)})
                table.insert(playerVehicleInfos["texts"], {white .. "Nitró: ", ((tonumber(tuningData["nitro"] or 0) == 1) and green .. "Van " .. "(" .. tonumber(tuningData["nitroLevel"] or 1) * 100 .. "%)" or red .. "Nincs")})
                table.insert(playerVehicleInfos["texts"], {white .. "AirRide: ", ((tonumber(tuningData["airride"] or 0) == 1) and green .. "Van" or red .. "Nincs")})
                table.insert(playerVehicleInfos["texts"], {white .. "Hidraulika: ", ((tonumber(tuningData["optical.9"] or 0) == 1) and green .. "Van" or red .. "Nincs")})
                table.insert(playerVehicleInfos["texts"], {white .. "Backfire: ", ((tonumber(tuningData["backfire"] or 0) == 1) and green .. "Van" or red .. "Nincs")})
                table.insert(playerVehicleInfos["texts"], {white .. "Traffi radar: ", ((tonumber(tuningData["traffiradar"] or 0) == 1) and green .. "Van" or red .. "Nincs")})
                table.insert(playerVehicleInfos["texts"], {white .. "AntiSteal: ", ((tonumber(tuningData["stealwarning"] or 0) == 1) and green .. "Van" or red .. "Nincs")})
                table.insert(playerVehicleInfos["texts"], {white .. "GPS: ", ((tonumber(tuningData["gps"] or 0) == 1) and green .. "Van" or red .. "Nincs")})

                local neonNames = exports['cr_tuning']:getNeonNames()
                table.insert(playerVehicleInfos["texts"], {"Neon: ", ((tonumber(tuningData["neon"] or 0) >= 1) and green .. "Van " .. "(" .. neonNames[tonumber(tuningData["neon"] or 0)][2] .. ")" or red .. "Nincs")})

                exports['cr_dx']:openInformationsPanel(playerVehicleInfos)
                
                closePanel()
                return
            end,
            function()
                if getDistanceBetweenPoints3D(e.position, localPlayer.position) <= 4 then
                    return true
                else
                    return false
                end
            end,
        },
        
        {"Taxi tábla levétele", {255,153,51,255/100*75},
            function()
                exports['cr_inventory']:giveItem(localPlayer, 75)
                exports['cr_chat']:createMessage(localPlayer, "levesz egy taxi táblát", 1) -- // ?!
                exports['cr_infobox']:addBox('success', 'Sikeresen levetted a taxi táblát!')

                exports['cr_taxipanel']:destroyTaxiLamp(e)
                
                closePanel()
                return
            end,
            function()
                if tonumber(e:getData('veh >> owner') or -1) == tonumber(localPlayer:getData("acc >> id") or -2) or tonumber(e:getData('veh >> faction') or 0) > 0 and exports['cr_dashboard']:isPlayerInFaction(localPlayer, tonumber(e:getData('veh >> faction') or 0)) then
                    if not e:getData('veh >> locked') then 
                        if e:getData('veh >> taxiPlate') then
                            return true
                        end
                    end 
                end 

                return false 
            end,
        },

        {{"Pizza berakása", "Pizza kivétele", {localPlayer, "pizza >> objInHand"}}, {255,153,51,255/100*75},
            function()    
                if localPlayer:getData("pizza >> objInHand") then 
                    local pizzas = tonumber(e:getData("pizza >> pizza") or 0)
                    
                    if pizzas + 1 <= 8 then 
                        triggerLatentServerEvent("addPizzaToVeh", 5000, false, localPlayer, e, localPlayer)

                        localPlayer:setData("forceAnimation", {"carry", "putdwn",-1,false, false, false, false, 250, true})
                        if isTimer(animationTimer) then 
                            killTimer(animationTimer) 
                            animationTimer = nil 
                        end 

                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("forceAnimation", nil)
                            end, 275, 1
                        )
                    else
                        exports['cr_infobox']:addBox('error', 'Csak 8 pizza fér a motorba!')
                    end 
                else 
                    local pizzas = tonumber(e:getData("pizza >> pizza") or 0)
                    
                    if pizzas - 1 > 0 then 
                        triggerLatentServerEvent("takePizzaFromVeh", 5000, false, localPlayer, e, localPlayer)

                        localPlayer:setData("forceAnimation", {"carry", "liftup",-1,false, false, false, false, 250, true})
                        if isTimer(animationTimer) then 
                            killTimer(animationTimer) 
                            animationTimer = nil 
                        end 

                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("forceAnimation", {"CARRY", "crry_prtial", 0, true, false, true, true})
                            end, 275, 1
                        )
                    end
                end 

                closePanel()
                return
            end,
            function()
                if e.model == 448 then 
                    if localPlayer:getData('char >> job') == 7 then 
                        if e == localPlayer:getData('char >> jobVehicle') or tonumber(e:getData('veh >> group') or -1) == tonumber(localPlayer:getData('char >> group') or -2) then 
                            local pizzas = tonumber(e:getData("pizza >> pizza") or 0)

                            if localPlayer:getData('pizza >> objInHand') then 
                                if pizzas + 1 <= 8 then 
                                    return true 
                                end 
                            else 
                                if pizzas - 1 >= 0 then 
                                    return true
                                end 
                            end 
                        end 
                    end 
                end 

                return false
            end,
        },

        {{"Csomagtartó bezárása", "Csomagtartó kinyitása", "veh >> boot"}, {255,153,51,255/100*75},
            function()
                --outputChatBox(e:getData("veh >> id"))
                if exports['cr_inventory']:hasItem(localPlayer, 16, e:getData("veh >> id")) or exports.cr_permission:hasPermission(localPlayer, "vehBoot") then
                    --outputChatBox(tostring(e:getData("veh >> boot")))
                    if not e:getData("veh >> boot") then
                        exports['cr_chat']:createMessage(localPlayer, "kinyitja a jármű csomagtartóját ("..exports['cr_vehicle']:getVehicleName(e)..")", 1)

                        if not exports.cr_inventory:hasItem(localPlayer, 16, e:getData("veh >> id")) then 
                            local localName = exports.cr_admin:getAdminName(localPlayer, true)
                            local vehId = e:getData("veh >> id")
    
                            local adminSyntax = exports.cr_admin:getAdminSyntax()
                            local hexColor = exports.cr_core:getServerColor("yellow", true)
                            local white = "#ffffff"
    
                            exports.cr_logs:addLog(localPlayer, "VehBoot", "VehBootOpen", localName .. " kulcs nélkül kinyitotta egy jármű csomagtartóját. Jármű id: " .. vehId)
                            exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. hexColor .. localName .. white .. " kulcs nélkül kinyitotta egy jármű csomagtartóját. " .. hexColor .. "(" .. vehId .. ")", 8)
                        end
                    else
                        exports['cr_chat']:createMessage(localPlayer, "bezárja a jármű csomagtartóját ("..exports['cr_vehicle']:getVehicleName(e)..")", 1)
                    end
                    e:setData("veh >> boot", not e:getData("veh >> boot"))
                    triggerServerEvent("vehBoot", localPlayer, e, e:getData("veh >> boot"))
                    
                    if not e:getData("veh >> boot") then
                        e:setData("inventory.open", nil)
                    end
                else
                    local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                    outputChatBox(syntax .. "Nincs kulcsod a járműhöz!", 255,255,255,true)
                end
                return
            end,
            function()
                local x, y, z = getVehicleComponentPosition(e, "boot_dummy", "world")
                local enabled = false
                if x and y and z then
                    local dist = getDistanceBetweenPoints3D(localPlayer.position, x,y,z)
                    if dist <= 1.5 then
                        enabled = true
                    end
                end

                if enabled then
                    return true
                else
                    return false
                end
            end,
        },

        {"Csomagtartó", {255,153,51,255/100*75},
            function()
                exports['cr_inventory']:openBoot(e)
                
                closePanel()
                return
            end,
            function()
                local x, y, z = getVehicleComponentPosition(e, "boot_dummy", "world")
                local enabled = false
                if x and y and z then
                    local dist = getDistanceBetweenPoints3D(localPlayer.position, x,y,z)
                    if dist <= 1.5 then
                        enabled = true
                    end
                end

                if enabled then
                    return true
                else
                    return false
                end
            end,
        },

        {"Kulcsmásolás", {255,153,51,255/100*75},
            function()
                exports.cr_faction_scripts:changeVehicleLock(false, e)
                
                closePanel()
                return
            end,
            function()
                if exports.cr_faction_scripts:hasPlayerPermission(localPlayer, "changelock", "faction.changelock") then 
                    return true
                else
                    return false
                end
            end,
        },

        {{"Hordágy kivétele", "Hordágy berakása", "veh >> ambulanceBed"}, {255,153,51,255/100*75},
            function()
                --exports['cr_inventory']:openBoot(e)
                exports['cr_ambulance']:interactAmbulanceBed(e)
                
                closePanel()
                return
            end,
            function()
                if e.model == 416 then
                    local x, y, z = getVehicleComponentPosition(e, "door_lr_dummy", "world")
                    local enabled = false
                    if x and y and z then
                        local dist = getDistanceBetweenPoints3D(localPlayer.position, x,y,z)
                        if dist <= 1.5 then
                            enabled = true
                        end
                    end
            
                    if enabled then
                        if exports.cr_dashboard:isPlayerInFaction(localPlayer, 2) then
                            return true
                        else
                            return false
                        end
                    else
                        return false
                    end
                end
            end,
        },
        
        {"Bezárás", {255,153,51,255/100*75},
            function()
                closePanel()
                return
            end,
            function()
                local x, y, z = getVehicleComponentPosition(e, "boot_dummy", "world")
                local enabled = false
                if x and y and z then
                    local dist = getDistanceBetweenPoints3D(localPlayer.position, x,y,z)
                    if dist <= 1.5 then
                        enabled = true
                    end
                end
            
                if getDistanceBetweenPoints3D(e.position, localPlayer.position) <= 4 or enabled then
                    return true
                else
                    closePanel()
                    return false
                end
            end,
        },
    },
    ["ped"] = {
        {"Megnyúzás", {255,153,51,255/100*75},
            {
                ["type"] = "bgTransfer",
                ["func"] = function()
                    e:setData("hunter >> doingInteraction", {1, localPlayer}) 
                    
                    closePanel()
                    return
                end,
            },
                    
            function()
                if e:getData("hunter >> id") then
                    if e:getData("hunter >> health") <= 0 then 
                        if not e:getData("hunter >> doingInteraction") then 
                            if exports['cr_inventory']:hasItem(localPlayer, 41) then 
                                return true
                            end 
                        end 
                    end 
                end

                return false    
            end,
        },
        {"Trófea készítése", {255,153,51,255/100*75},
            {
                ["type"] = "bgTransfer",
                ["func"] = function()
                    e:setData("hunter >> doingInteraction", {1, localPlayer}) 
                    
                    closePanel()
                    return
                end,
            },

            function()
                if e:getData("hunter >> id") then
                    if e:getData("hunter >> health") <= 0 then 
                        if not e:getData("hunter >> doingInteraction") then 
                            if exports['cr_inventory']:hasItem(localPlayer, 41) then 
                                return true
                            end 
                        end 
                    end 
                end

                return false    
            end,
        },
        {"Megsimogatás", {255,153,51,255/100*75},
            function()
                if not isTimer(petInteractionTimer) then
                    localPlayer.rotation = Vector3(0, 0, findRotation(localPlayer.position.x, localPlayer.position.y, e.position.x, e.position.y))
                    localPlayer:setData("forceAnimation", {"bomber", "bom_plant"})

                    local players = exports['cr_core']:getNearbyPlayers("medium")
                    if #players >= 1 then 
                        triggerLatentServerEvent("playSound3D", 5000, false, localPlayer, localPlayer, e, players, ":cr_dashboard/assets/sounds/caress.mp3")
                    end 

                    local sound = Sound3D(":cr_dashboard/assets/sounds/caress.mp3", e.position)
                    sound.dimension = e.dimension 
                    sound.interior = e.interior 
                    sound:attach(e)
                    
                    local e = e 
                    petInteractionTimer = setTimer(
                        function()
                            local data = e:getData("pet >> data") or {200, 100, 100, 100}
                            data[4] = math.min(100, math.max(0, data[4] + 5))
                            e:setData("pet >> data", data)
                            localPlayer:setData("forceAnimation", {"", ""})
                        end, 8250, 1
                    )
                end
                
                closePanel()
                return
            end,
            function()
                if e:getData("pet >> id") then
                    return true
                else
                    return false    
                end
            end,
        },
        {"Etetés", {255,153,51,255/100*75},
            function()
                if not isTimer(petInteractionTimer) then
                    local data = e:getData("pet >> data") or {200, 100, 100, 100}
                    if data[2] >= 85 then 
                        exports['cr_infobox']:addBox("error", "Ez a kutya nem éhes!")
                        closePanel()
                        return 
                    end 

                    local has, slot, data = exports['cr_inventory']:hasItem(localPlayer, 109)
                    if has then 
                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                        if count - 1 <= 0 then
                            exports['cr_inventory']:deleteItem(localPlayer, slot, itemid)
                        else
                            triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
                        end

                        localPlayer:setData("forceAnimation", {"bomber", "bom_plant"})

                        local e = e 
                        petInteractionTimer = setTimer(
                            function()
                                local data = e:getData("pet >> data") or {200, 100, 100, 100}
                                data[2] = 100
                                e:setData("pet >> data", data)

                                localPlayer:setData("forceAnimation", {"", ""})
                                exports['cr_infobox']:addBox("success", "Sikeres megetetted a kutyát (PP Snack elhasználva)!")
                            end, 1500, 1
                        )

                        return
                    end

                    local has, slot, data = exports['cr_inventory']:hasItem(localPlayer, 100)
                    if has then 
                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                        if count - 1 <= 0 then
                            exports['cr_inventory']:deleteItem(localPlayer, slot, itemid)
                        else
                            triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
                        end

                        localPlayer:setData("forceAnimation", {"bomber", "bom_plant"})

                        local e = e 
                        petInteractionTimer = setTimer(
                            function()
                                local data = e:getData("pet >> data") or {200, 100, 100, 100}
                                data[2] = math.min(100, math.max(0, data[2] + 15))
                                e:setData("pet >> data", data)

                                localPlayer:setData("forceAnimation", {"", ""})
                                exports['cr_infobox']:addBox("success", "Sikeres megetetted a kutyát!")
                            end, 1500, 1
                        )

                        return
                    else 
                        exports['cr_infobox']:addBox("error", "Nincs nálad "..exports['cr_inventory']:getItemName(100, value, nbt).."!")
                    end
                end
                
                closePanel()
                return
            end,
            function()
                if e:getData("pet >> id") then
                    return true
                else
                    return false
                end
            end,
        },
        {"Itatás", {255,153,51,255/100*75},
            function()
                if not isTimer(petInteractionTimer) then
                    local data = e:getData("pet >> data") or {200, 100, 100, 100}
                    if data[3] >= 85 then 
                        exports['cr_infobox']:addBox("error", "Ez a kutya nem szomjas!")
                        closePanel()
                        return 
                    end 

                    local has, slot, data = exports['cr_inventory']:hasItem(localPlayer, 101)
                    if has then 
                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                        if count - 1 <= 0 then
                            exports['cr_inventory']:deleteItem(localPlayer, slot, itemid)
                        else
                            triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
                        end

                        localPlayer:setData("forceAnimation", {"bomber", "bom_plant"})

                        local e = e 
                        petInteractionTimer = setTimer(
                            function()
                                local data = e:getData("pet >> data") or {200, 100, 100, 100}
                                data[3] = math.min(100, math.max(0, data[3] + 15))
                                e:setData("pet >> data", data)

                                localPlayer:setData("forceAnimation", {"", ""})
                                exports['cr_infobox']:addBox("success", "Sikeres megitattad a kutyát!")
                            end, 1500, 1
                        )
                    else 
                        exports['cr_infobox']:addBox("error", "Nincs nálad "..exports['cr_inventory']:getItemName(101, value, nbt).."!")
                    end 
                end
                
                closePanel()
                return
            end,
            function()
                if e:getData("pet >> id") then
                    return true
                else
                    return false
                end
            end,
        },
        {{"Ugatás abbahagyása", "Ugatás", "pet >> barking"}, {255,153,51,255/100*75},
            function()
                e:setData("pet >> barking", not e:getData("pet >> barking"))
                
                closePanel()
                return
            end,
            function()
                if e:getData("pet >> id") and e:getData("pet >> owner") == localPlayer:getData("acc >> id") then
                    return true
                else
                    return false
                end
            end,
        },
        {"Despawn", {255,153,51,255/100*75},
            function()
                triggerLatentServerEvent("deSpawnPet", 5000, false, localPlayer, localPlayer, e.health)
                
                closePanel()
                return
            end,
            function()
                if e:getData("pet >> id") and e:getData("pet >> owner") == localPlayer:getData("acc >> id") then
                    return true
                else
                    return false
                end
            end,
        },
        
        {"Vizsgálat", {255,153,51,255/100*75},
            function()
                local parent = e:getData("parent")

                if isElement(parent) then 
                    exports['cr_ambulance']:getBullets(parent)
                end
                
                closePanel()
                return
            end,
            function()
                if exports.cr_dashboard:isPlayerInFaction(localPlayer, 2) then
                    return true
                else
                    return false
                end
            end,
        },
        -- {"Megmotozás", {255,153,51,255/100*75},
        --     function()
        --         local e = e:getData("parent")
        --         local name2 = e:getData("char >> name")
        --         exports['cr_chat']:createMessage(localPlayer, "megmotozott egy közelében lévő embert ("..name2:gsub("_", " ")..")", 1)
        --         exports['cr_inventory']:openInventory(e, true, true)
                
        --         closePanel()
        --         return
        --     end,
        --     function()
        --         local parent = e:getData("parent")

        --         if isElement(parent) then 
        --             return parent:getData("inDeath")
        --         else
        --             return false
        --         end
        --     end,
        -- },
        {"Bezárás", {255,153,51,255/100*75},
            function()
                closePanel()
                return
            end,
            function()
                return true
            end,
        },
    },
    ["object"] = {
        {"chanelName", {255,153,51,0},
            function()
                return
            end,
            function()
                if e.model == 2102 then
                    --return true
                    if e:getData("hifi >> state") then
                        local channel = exports['cr_radio']:getChannels()
                        chanelName = channel[e:getData("hifi >> channel") or 1][1]
                        return true
                    else
                        return false
                    end
                end
            end,
        },
        
        {{"Kikapcsolás", "Bekapcsolás", "hifi >> state"}, {255,153,51,255/100*75},
            function()
                --outputChatBox("Majd ide a felvétel cucc")
                e:setData("hifi >> state", not e:getData("hifi >> state"))
                local channel = exports['cr_radio']:getChannels()
                if not e:getData("hifi >> channel") or not channel[e:getData("hifi >> channel")] then
                    e:setData("hifi >> channel", 1)
                end
                
                --[[
                closePanel()
                ]]
                
                return
            end,
            function()
                if e.model == 2102 then
                    return true
                else
                    return false
                end
            end,
        },
        
        {"Következő állomás", {255,153,51,255/100*75},
            function()
                --outputChatBox("Következő állomás")
                local num = e:getData("hifi >> channel") or 1
                local num = num + 1
                local channel = exports['cr_radio']:getChannels()
                if not channel[num] then
                    num = 1
                end
                e:setData("hifi >> channel", num)
                --e:setData("hifi >> state", not e:getData("hifi >> state"))
                
                --[[
                closePanel()
                ]]
                
                return
            end,
            function()
                if e.model == 2102 then
                    --return true
                    if e:getData("hifi >> state") then
                        return true
                    else
                        return false
                    end
                end
            end,
        },
        
        {"Előző állomás", {255,153,51,255/100*75},
            function()
                --outputChatBox("Következő állomás")
                local num = e:getData("hifi >> channel") or 1
                local num = num - 1
                local channel = exports['cr_radio']:getChannels()
                if num <= 0 then
                    num = #channel
                end
                e:setData("hifi >> channel", num)
                --e:setData("hifi >> state", not e:getData("hifi >> state"))
                
                --[[
                closePanel()
                ]]
                
                return
            end,
            function()
                if e.model == 2102 then
                    --return true
                    if e:getData("hifi >> state") then
                        if not e:getData("hifi >> movedBy") then
                            return true
                        else
                            return false
                        end
                    else
                        return false
                    end
                end
            end,
        },
        
        {"Mozgatás", {255,153,51,255/100*75},
            function()
                --outputChatBox("Következő állomás")
                --e:setData("hifi >> state", not e:getData("hifi >> state"))
                
                --triggerServerEvent("destroyHifi", localPlayer, localPlayer, e)
                if not e:getData("hifi >> movedBy") then
                    exports["cr_elementeditor"]:toggleEditor(e, "onSaveHifiPositionEditor", "onSaveHifiDeleteEditor")
                    exports['cr_chat']:createMessage(localPlayer, "elkezd mozgatni egy hifit", 1)
                    e:setData("hifi >> movedBy", localPlayer)
                    triggerServerEvent("hifiChangeState", localPlayer, e, 180)
                    closePanel()
                end
                
                return
            end,
            function()
                if e.model == 2102 then
                    if not e:getData("hifi >> state") then
                        if not e:getData("hifi >> movedBy") then
                            return true
                        else
                            return false
                        end
                    else
                        return false
                    end
                else
                    return false
                end
            end,
        },

        {"Mozgatás", {255,153,51,255/100*75},
            function()
                --outputChatBox("Következő állomás")
                --e:setData("hifi >> state", not e:getData("hifi >> state"))
                
                --triggerServerEvent("destroyHifi", localPlayer, localPlayer, e)
                if not e:getData("furniture >> movedBy") then
                    e:setData("furniture >> movedBy", localPlayer)
                    closePanel()
                end
                
                return
            end,
            function()
                if localPlayer:getData("inInterior") then 
                    if e:getData("furniture >> id") then
                        local markerData = localPlayer:getData("inInterior"):getData("marker >> data")
                        local canEditFurniture = false

                        if markerData.faction and markerData.faction > 0 then 
                            if exports.cr_dashboard:hasPlayerPermission(localPlayer, markerData.faction, "interior.customization") or exports.cr_dashboard:isPlayerFactionLeader(localPlayer, markerData.faction) then 
                                canEditFurniture = true
                            end
                        elseif markerData.owner == localPlayer:getData("acc >> id") then
                            canEditFurniture = true
                        end

                        if canEditFurniture then 
                            if not e:getData("furniture >> movedBy") then
                                return true
                            else
                                return false
                            end
                        else 
                            return false
                        end 
                    else
                        return false
                    end
                else 
                    return false
                end 
            end,
        },
        
        {"Felvétel", {255,153,51,255/100*75},
            function()
                --outputChatBox("Következő állomás")
                --e:setData("hifi >> state", not e:getData("hifi >> state"))
                
                triggerServerEvent("destroyHifi", localPlayer, localPlayer, e)
                exports['cr_chat']:createMessage(localPlayer, "felvesz egy hifit", 1)
                closePanel()
                return
            end,
            function()
                if e.model == 2102 then
                    if not e:getData("hifi >> state") then
                        return true
                    else
                        return false
                    end
                else
                    return false
                end
            end,
        },

        {"Felvétel", {255,153,51,255/100*75},
            function()
                --outputChatBox("Következő állomás")
                --e:setData("hifi >> state", not e:getData("hifi >> state"))
                
                exports['cr_chat']:createMessage(localPlayer, "felvesz egy bútort", 1)
                triggerServerEvent("destroyFurniture", localPlayer, localPlayer, e)

                closePanel()
                return
            end,
            function()
                if localPlayer:getData("inInterior") then 
                    if e:getData("furniture >> id") then
                        local markerData = localPlayer:getData("inInterior"):getData("marker >> data")
                        local canEditFurniture = false
                        local needLog = false

                        if markerData.faction and markerData.faction > 0 then 
                            if exports.cr_dashboard:hasPlayerPermission(localPlayer, markerData.faction, "interior.customization") or exports.cr_dashboard:isPlayerFactionLeader(localPlayer, markerData.faction) then 
                                canEditFurniture = true
                                needLog = true
                            end
                        elseif markerData.owner == localPlayer:getData("acc >> id") then
                            canEditFurniture = true
                        end

                        if needLog then 
                            local localName = exports.cr_admin:getAdminName(localPlayer)
                            local hexColor = exports.cr_core:getServerColor("yellow", true)
                            local white = "#ffffff"

                            triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, markerData.faction, hexColor .. localName .. white .. " felvett egy bútort.")
                        end

                        if canEditFurniture then 
                            return true
                        else 
                            return false
                        end 
                    else
                        return false
                    end
                else 
                    return false
                end 
            end,
        },
        
        {"Hordágy felvétele", {255,153,51,255/100*75},
            function()
                --outputChatBox("Majd ide a felvétel cucc")
                exports['cr_ambulance']:interactAmbulanceBed2(e)
                closePanel()
                return
            end,
            function()
                if e.model == 11625 then
                    --return true
                    if exports['cr_faction']:isPlayerInFaction(localPlayer, 2) then
                        return true
                    else
                        return false
                    end
                end
            end,
        },
        {"Ember lesegítése", {255,153,51,255/100*75},
            function()
                --outputChatBox("Majd ide a felvétel cucc")
                local p = e:getData("isPlayerInBed")
                exports['cr_ambulance']:doAmbulanceBedPlacePlayer(p)
                closePanel()
                return
            end,
            function()
                if e.model == 11625 then
                    if e:getData("isPlayerInBed") then
                        return true
                    else
                        return false
                    end
                end
            end,
        },
        {"Megnyitás", {255,153,51,255/100*75},
            function()
                --outputChatBox("Majd ide a felvétel cucc")
                
                exports['cr_inventory']:openSafe(e)
                
--                exports["cr_elementeditor"]:toggleEditor(e, "onSaveHifiPositionEditor", "onSaveHifiDeleteEditor")
                closePanel()
                return
            end,
            function()
                if e.model == 2332 and tonumber(e:getData("safe.id")) then
                    return true
                else
                    return false
                end
            end,
        },
        {"Felvétel", {255,153,51,255/100*75},
            function()
                --outputChatBox("Majd ide a felvétel cucc")
                local isFactionSafe = false

                if localPlayer:getData("inInterior") then 
                    local markerData = localPlayer:getData("inInterior"):getData("marker >> data")

                    if markerData.faction and markerData.faction > 0 then 
                        if e.interior == localPlayer.interior and e.dimension == localPlayer.dimension then 
                            isFactionSafe = true
                        end
                    end
                end

                if not isFactionSafe or exports.cr_permission:hasPermission(localPlayer, "forceSafeOpen") then 
                    if exports['cr_inventory']:hasItem(localPlayer, 29, tonumber(e:getData("safe.id"))) then
                        local safeItems = exports.cr_inventory:getItems(e, 7)
                        local hasAnyItem = false

                        for k, v in pairs(safeItems) do 
                            hasAnyItem = true
                            break
                        end

                        if hasAnyItem then 
                            exports.cr_infobox:addBox("error", "Ameddig a széfben van valami, addig nem tudod felvenni.")
                            return
                        end

                        exports['cr_inventory']:destroySafe(e)
                    else
                        exports['cr_infobox']:addBox("error", "Ehhez a széfhez nincs kulcsod")
                    end
                    
                    closePanel()
                else 
                    exports.cr_infobox:addBox("error", "Frakció széfet nem tudsz felvenni.")
                end

                return
            end,
            function()
                if e.model == 2332 and tonumber(e:getData("safe.id")) then
                    return true
                else
                    return false
                end
            end,
        },
        {"Mozgatás", {255,153,51,255/100*75},
            function()
                --outputChatBox("Következő állomás")
                --e:setData("hifi >> state", not e:getData("hifi >> state"))
                
                --triggerServerEvent("destroyHifi", localPlayer, localPlayer, e)
                if not e:getData("safe >> movedBy") then
                    if exports['cr_inventory']:hasItem(localPlayer, 29, tonumber(e:getData("safe.id"))) then
                        exports["cr_elementeditor"]:toggleEditor(e, "onSaveSafePositionEditor", "onSaveSafeDeleteEditor")
                        exports['cr_chat']:createMessage(localPlayer, "elkezd mozgatni egy széfet", 1)
                        e:setData("safe >> movedBy", localPlayer)
                        triggerServerEvent("safeChangeState", localPlayer, e, 180)
                        closePanel()
                    else
                        exports['cr_infobox']:addBox("error", "Ehhez a széfhez nincs kulcsod")
                    end
                end
                
                return
            end,
            function()
                if e.model == 2332 and tonumber(e:getData("safe.id")) then
                    if not e:getData("safe >> movedBy") then
                        return true
                    else
                        return false
                    end
                else
                    return false
                end
            end,
        },
        {"Terminálhoz rendelés", {255,153,51,255/100*75},
            function()
                exports.cr_cctv:manageCameraAssignPanel("init", e)

                closePanel()
                return
            end,

            function()
                if e.model == 2921 and (e:getData("camera >> terminalId") or 0) <= 0 then 
                    return true
                else
                    return false
                end
            end,
        },
        {"Eltávolítás a terminálból", {255,153,51,255/100*75},
            function()
                exports.cr_cctv:manageCameraAssignPanel("init", e, true)

                closePanel()
                return
            end,

            function()
                if e.model == 2921 and (e:getData("camera >> terminalId") or 0) > 0 and exports.cr_permission:hasPermission(localPlayer, "deletecamera") then 
                    return true
                else
                    return false
                end
            end,
        },
        {"Bezárás", {255,153,51,255/100*75},
            function()
                closePanel()
                return
            end,
            function()
                return true
            end,
        },
    },
}

function toggleMoveControls(value)
    if value then 
        if localPlayer:getData("char >> cuffed") or localPlayer:getData("char >> bondage") then
            return
        end 
    else 
        if not localPlayer:getData("char >> cuffed") and not localPlayer:getData("char >> bondage") then
            return
        end 
    end 
    exports['cr_controls']:toggleControl("forwards", value, "instant")
    exports['cr_controls']:toggleControl("backwards", value, "instant")
    exports['cr_controls']:toggleControl("left", value, "instant")
    exports['cr_controls']:toggleControl("right", value, "instant")
    exports['cr_controls']:toggleControl("jump", value, "instant")
    exports['cr_controls']:toggleControl("fire", value, "instant")
    exports['cr_controls']:toggleControl("aim_weapon", value, "instant")
    exports['cr_controls']:toggleControl("enter_exit", value, "instant")
    exports['cr_controls']:toggleControl("action", false, "instant")
end

function toggleOnlyMoveControls(value)
    if value then 
        if localPlayer:getData("char >> cuffed") or localPlayer:getData("char >> bondage") then
            return
        end 
    else 
        if not localPlayer:getData("char >> cuffed") and not localPlayer:getData("char >> bondage") then
            return
        end 
    end 
    exports['cr_controls']:toggleControl("forwards", value, "instant")
    exports['cr_controls']:toggleControl("backwards", value, "instant")
    exports['cr_controls']:toggleControl("left", value, "instant")
    exports['cr_controls']:toggleControl("right", value, "instant")
end

addEventHandler("onClientElementDataChange", localPlayer, 
    function(dName, oValue, nValue)
        if dName == "char >> cuffed" or dName == "char >> bondage" then 
            if nValue then 
                toggleMoveControls(false)
            else 
                toggleMoveControls(true)
            end 
        elseif dName == "char >> follow" then 
            if nValue then 
                toggleOnlyMoveControls(true)
            else
                toggleOnlyMoveControls(false)
            end 
        elseif dName == "char >> blinded" then 
            if nValue then 
                createRender("renderDarkScreen", renderDarkScreen)
            else 
                destroyRender("renderDarkScreen")
            end 
        end 
    end 
)

local sx, sy = guiGetScreenSize()
function renderDarkScreen()
    dxDrawRectangle(0, 0, sx, sy, tocolor(0,0,0,255))
end 

local maxDist = {
    ["player"] = 2,
    ["vehicle"] = 8,
    ["ped"] = 2,
    ["object"] = 2,
    ["vehicle416"] = 5,
    ["object2921"] = 4,
}

addEventHandler("onClientClick", root,
    function(b, s, _,_,_,_,_, worldElement)
        if localPlayer.vehicle then return end
        if not state and isElement(worldElement) and gButtons[worldElement.type] and worldElement ~= localPlayer and b == "right" and s == "down" then
            if worldElement.type == "ped" and not worldElement:getData("pet >> id") and not worldElement:getData("hunter >> id") and not worldElement:getData("parent") then return end
            --if worldElement.type == "player" and worldElement:getData("timedout") then return end
            --if worldElement.type == "object" and not worldElement:getData("placed") and not worldElement:getData("safe.id") then return end
            if worldElement.type == "object" and not worldElement:getData("placed") and not worldElement:getData("safe.id") and not worldElement:getData("hifi >> creator") and not worldElement:getData("furniture >> id") and not worldElement:getData("camera >> terminalId") then return end
            if localPlayer:getData("keysDenied") then return end
            if localPlayer:getData("inAnim") then return end
            local pos = localPlayer:getPosition()
            local pos2 = worldElement:getPosition()
            local dist = getDistanceBetweenPoints3D(pos, pos2)
            --outputChatBox(dist)
            --outputChatBox(tostring(maxDist[worldElement.type .. "" .. worldElement.model] and dist <= maxDist[worldElement.type .. "" .. worldElement.model]))
            if maxDist[worldElement.type .. "" .. worldElement.model] and dist <= maxDist[worldElement.type .. "" .. worldElement.model] or dist <= maxDist[worldElement.type] then
                --outputChatBox("asd")
                font = getFont("Rubik-Regular", 10)
                m = Marker(0,0,-2, "arrow", 0.4, 255, 59, 59, 0)
                e = worldElement
                state = true
                pos2.z = pos2.z + 0.5
                multipler = 5
                multipler2 = 3.5
                alpha = 0
                alpha2 = 0
                activateAnimationID = 0
                animationProgress = 0
                startTick2 = nil
                x, y = getScreenFromWorldPosition(pos2)
                --addEventHandler("onClientRender", root, drawnPanel, true, "low-5")
                createRender("drawnPanel", drawnPanel)
                start = true
                createElementOutlineEffect(worldElement, true)
                startTick = getTickCount()
                
                checkWidth()

                local num = 0
                for k,v in pairs(gButtons[e.type]) do 
                    if v[4]() then
                        num = num + 1 
                    end
                end
                if num <= 1 then
                    closePanel()
                    return
                end

                m.alpha = 255
                m:attach(e, 0, -0.08, 1.8)
            end
        elseif state and b == "left" and s == "down" then
            if lastClickTick + 600 > getTickCount() then
                return
            end
            lastClickTick = getTickCount()
            
            if e.type == "player" and e:getData("timedout") then 
                exports['cr_infobox']:addBox("warning", "Az interakció nem végezhető el mert a célpont internetkapcsolata nem megfelelő!")
                return 
            end
            
            local pos2 = e:getPosition()
            local x, y = getScreenFromWorldPosition(pos2) 
            if x and y then
                local y = y - 30

                y = y + 10
                for k, v in pairs(gButtons[e.type]) do
                    local name = v[1]
                    --[[
                    if type(name) == "table" then
                        local name1, name2, eData = unpack(name)
                         RÉGI FOS HA ESETLEG VISSZAJÖN CSERÉLD KI
                        local value = e and isElement(e) and e:getData(eData)
                        if tonumber(value) then
                            if value == 1 then value = true else value = false end
                        end
                        
                        if value then
                            name = name1
                        else
                            name = name2
                        end
                    end]]
                    local r,g,b,a = unpack(v[2])
                    local func = v[3]
                    local func2 = v[4]
                    if func2() then
                        if isInSlot(x - size2.x/2, y, size2.x, size2.y) then
                            if exports['cr_network']:getNetworkStatus() then 
                                closePanel()
                                return
                            end

                            if type(func) == "table" then 
                                local type = func["type"]
                                local realFunc = func["func"]
                                if type == "bgTransfer" then 
                                    if activateAnimationID <= 0 then
                                        activateAnimationID = k
                                        createAnimate(0,1,4,1000,function(value) animationProgress = value end, realFunc) 
                                    end 
                                end 
                            else 
                                return func()
                            end 
                        end

                        y = y + size2.y + 5
                    end
                end
            end
        elseif state and b == "left" and s == "up" then 
            if (activateAnimationID > 0) then
                destroyAnimation(#anims)
                createAnimate(animationProgress,0,4,400,function(value) animationProgress = value end, function()
                    activateAnimationID = 0
                end)
            end
        end
    end
)

function dxDrawOuterBorder(x, y, w, h, borderSize, borderColor, postGUI)
	borderSize = borderSize or 2
	borderColor = borderColor or tocolor(0, 0, 0, 255)
	
	dxDrawRectangle(x - borderSize, y - borderSize, w + (borderSize * 2), borderSize, borderColor, postGUI)
	dxDrawRectangle(x, y + h, w, borderSize, borderColor, postGUI)
	dxDrawRectangle(x - borderSize, y, borderSize, h + borderSize, borderColor, postGUI)
	dxDrawRectangle(x + w, y, borderSize, h + borderSize, borderColor, postGUI)
end

function closePanel()
    if start or start then
        state = false
        startTick = getTickCount()
        start = false
        destroyElementOutlineEffect(e)
    end
end

function checkWidth()
    if start and state then
        local font = exports["cr_fonts"]:getFont("Poppins-Medium", 12)
        local tWidth = 0
        for k, v in pairs(gButtons[e.type]) do
            local name = v[1]
            local left = false
            if name == "chanelName" then 
                name = chanelName 
                left = true
            end
            if type(name) == "table" then
                local name1, name2, eData = unpack(name)

                local e = e
                if type(eData) == 'table' then 
                    e, eData = unpack(eData)
                end 

                if not isElement(e) then return end

                local value = e:getData(eData)
                if tonumber(value) then
                    if value <= 1 and value >= 0 then 
                        if value == 1 then 
                            value = true 
                        else 
                            value = false 
                        end
                    else 
                        value = true
                    end 
                end

                if value then
                    name = name1
                else
                    name = name2
                end
            end

            if name then 
                if dxGetTextWidth(name, 1, font, true) + 40 >= tWidth then
                    tWidth = dxGetTextWidth(name, 1, font, true) + 40
                end
            end 
        end

        size = Vector2(tWidth, 165)
        size2 = Vector2(size.x - 20, 25)
    end    
end
setTimer(checkWidth, 1000, 0)

startAnimation = "InOutQuad"
startAnimationTime = 250 -- / 1000 = 0.2 másodperc
function drawnPanel()
    local nowTick = getTickCount()
    if start then
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            0, 0, 0,
            255, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph
    else
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            255, 0, 0,
            0, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph
        
        if progress >= 1 then
            --removeEventHandler("onClientRender", root, drawnPanel)
            destroyRender("drawnPanel")
            alpha = 0
            e = nil
            m:destroy()
            return
        end
    end
    
    local font = exports["cr_fonts"]:getFont("Poppins-Medium", 12)
    local pos = localPlayer:getPosition()

    if not isElement(e) then 
        closePanel()
        return
    end

    local pos2 = e:getPosition()
    local dist = getDistanceBetweenPoints3D(pos, pos2)

    --outputChatBox(tostring(maxDist[e.type .. "" .. e.model] and dist > maxDist[e.type .. "" .. e.model] ))
    if not e or not isElement(e) or maxDist[e.type .. "" .. e.model] and dist > maxDist[e.type .. "" .. e.model] or not maxDist[e.type .. "" .. e.model] and dist > maxDist[e.type] then
        closePanel()
        return
    end
    
    if localPlayer.vehicle then
        closePanel()
    end
    
    local x, y = getScreenFromWorldPosition(pos2) 
    if x and y then
        local y = y - 30
        local num = 0
        for k,v in pairs(gButtons[e.type]) do 
            if v[4]() then
                num = num + 1 
            end
        end
        if num <= 1 then
            closePanel()
            return
        end
        size.y = num * (size2.y + 5) + 15
		dxDrawRectangle(x - size.x/2, y, size.x, size.y, tocolor(51,51,51,alpha * 0.8))
        y = y + 10
        
        for k, v in pairs(gButtons[e.type]) do
            local name = v[1]
            local left = false
            if name == "chanelName" then 
                name = chanelName 
                left = true
            end
            if type(name) == "table" then
                local name1, name2, eData = unpack(name)

                local e = e

                if type(eData) == 'table' then 
                    e, eData = unpack(eData)
                end 

                if not isElement(e) then return end

                local value = e:getData(eData)
                if tonumber(value) then
                    if value <= 1 and value >= 0 then 
                        if value == 1 then 
                            value = true 
                        else 
                            value = false 
                        end
                    else 
                        value = true
                    end 
                end

                if value then
                    name = name1
                else
                    name = name2
                end
            end
            local r,g,b,a = unpack(v[2])
            local func = v[3]
            local func2 = v[4]
            if func2() then
                if not left then
                    if isInSlot(x - size2.x/2, y, size2.x, size2.y) then
                        if not startTick2 then
                            startTick2 = getTickCount()
                        end
                        
                        local elapsedTime = nowTick - startTick2
                        local duration = (startTick2 + startAnimationTime) - startTick2
                        local progress = elapsedTime / duration
                        local alph = interpolateBetween(
                            0, 0, 0,
                            255, 0, 0,
                            progress, startAnimation
                        )

                        alpha2 = alph
                        dxDrawRectangle(x - size2.x/2, y, size2.x, size2.y, tocolor(51, 51, 51, alpha * 0.9))
                        dxDrawOuterBorder(x - size2.x/2, y, size2.x, size2.y, 1, tocolor(255,59,59,math.min(alpha, alpha2)))
                    else
                        dxDrawRectangle(x - size2.x/2, y, size2.x, size2.y, tocolor(51, 51, 51, alpha * 0.9))
                    end

                    if activateAnimationID == k then
                        local r,g,b = 255, 59, 59
                        dxDrawRectangle(x - size2.x/2, y, size2.x * animationProgress, size2.y,tocolor(r,g,b,alpha * 0.5))
                    end
                end
                
                dxDrawText(name, x - size2.x/2, y, x - size2.x/2 + size2.x, y + size2.y + 2, tocolor(242,242,242,alpha), 1, font, left and "left" or "center", "center")

                y = y + size2.y + 5
            end
        end
    end
end

addEventHandler("onClientCursorMove", root,
    function()
        if state then
            local pos2 = e:getPosition()
            local x, y = getScreenFromWorldPosition(pos2) 
            if x and y then
                local y = y - 30

                y = y + 10
                local breaked = false
                
                for k, v in pairs(gButtons[e.type]) do
                    local name = v[1]
                    if type(name) == "table" then
                        local name1, name2, eData = unpack(name)
                        
                        local e = e
                        if type(eData) == 'table' then 
                            e, eData = unpack(eData)
                        end 

                        if not isElement(e) then return end

                        local value = e:getData(eData)
                        if tonumber(value) then
                            if value <= 1 and value >= 0 then 
                                if value == 1 then 
                                    value = true 
                                else 
                                    value = false 
                                end
                            else 
                                value = true
                            end 
                        end

                        if value then
                            name = name1
                        else
                            name = name2
                        end
                    end
                    local r,g,b,a = unpack(v[2])
                    local func = v[3]
                    local func2 = v[4]
                    --outputChatBox(k)
                    if func2() then
                        --outputChatBox(k .. "a")
                        --dxDrawRectangle(x - size2.x/2, y, size2.x, size2.y)
                        if isInSlot(x - size2.x/2, y, size2.x, size2.y) then
                            breaked = true
                            break
                        end
                        
                        y = y + size2.y + 5
                    end
                end
                
                if not breaked then
                    startTick2 = nil
                    alpha2 = 0
                end
            end
        end
    end
)

addEvent("nametag->goToClient", true)
addEventHandler("nametag->goToClient", root, 
    function(id, e2)
        local friendTable = localPlayer:getData("friends") or {}
        if not friendTable[tonumber(id)] then
            friendTable[tonumber(id)] = true
            local syntax = getServerSyntax("Friend", "success")
            local aName = exports['cr_admin']:getAdminName(e2, false)
            local id = getElementData(localPlayer, "acc >> id")
            local green = exports['cr_core']:getServerColor('yellow', true)
            outputChatBox(syntax .. "Bemutatkozott neked "..green..aName..white.."!", 255,255,255,true)
            localPlayer:setData("friends", friendTable)
        end
    end
)

function isKnow(who, id)
    local friendTable = who:getData("friends") or {}
    if friendTable[tonumber(id)] then
        return true
    else
        return false
    end
end

function findRotation(x1, y1, x2, y2) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

local builtins = {"Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve"}

function table.find(t, v)
	for k, a in ipairs(t) do
		if a == v then
			return k
		end
	end
	return false
end

function createAnimate(f, t, easing, duration, onChange, onEnd)
	assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
	assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
	assert(type(easing) == "string" or (type(easing) == "number" and (easing >= 1 or easing <= #builtins)), "Bad argument @ 'animate' [Invalid easing at argument 3]")
	assert(type(duration) == "number", "Bad argument @ 'animate' [expected function at argument 4, got "..type(duration).."]")
	assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
	table.insert(anims, {from = f, to = t, easing = table.find(builtins, easing) and easing or builtins[easing], duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})
	return #anims
end

function destroyAnimation(a)
	if anims[a] then
		table.remove(anims, a)
	end
end

addEventHandler("onClientRender", root, function( )
	local now = getTickCount( )
	for k,v in ipairs(anims) do
		v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
		if now >= v.start+v.duration then
			if type(v.onEnd) == "function" then
				v.onEnd( )
			end
			table.remove(anims, k)
		end
	end
end)