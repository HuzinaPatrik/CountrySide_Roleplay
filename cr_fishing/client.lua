local screenX, screenY = guiGetScreenSize()

local rods = {}
local floats = {}

local doingMinigame = false

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        localPlayer:setData("char >> fishing", false)

        rods = {}
        floats = {}

        local txd = engineLoadTXD("bot.txd") -- ezek átmenetien vannak betöltve
        local col = engineLoadCOL("bot.col")
        local dff = engineLoadDFF("bot.dff")

        engineImportTXD(txd, 16258)
        engineReplaceCOL(col, 16258)
        engineReplaceModel(dff, 16258)
    end
)

function createFishingRod()
    if not localPlayer:isInVehicle() then 
        triggerLatentServerEvent("fishing.createFishingRod", 5000, false, localPlayer, localPlayer)

        if isTimer(fishTimer) then 
            killTimer(fishTimer)
        end

        if isTimer(fishStartTimer) then 
            killTimer(fishStartTimer)
        end

        exports["cr_chat"]:createMessage(localPlayer, (localPlayer:getData("char >> fishing") and "elrak" or "elővesz").." egy horgászbotot", 1)

        return not localPlayer:getData("char >> fishing")
    else 
        return exports["cr_infobox"]:addBox("error", "Járműben ülve nem veheted elő a horgászbotot.")
    end
end

local spamTick = 0
local playerX, playerY, playerZ = 0, 0, 0
local returned = false
local fishTimer = false

function onClick(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
    if localPlayer:getData("loggedIn") then 
        if button == "left" then 
            if state == "down" then 
                if localPlayer:getData("char >> fishing") then 
                    if spamTick + 1000 > getTickCount() then 
                        return 
                    end

                    if exports["cr_network"]:getNetworkStatus() then 
                        return 
                    end

                    if doingMinigame then 
                        return
                    end

                    if testLineAgainstWater(worldX, worldY, worldZ, worldX, worldY, worldZ + 500) then 
                        worldX, worldY, worldZ = getWorldFromScreenPosition(absX, absY, 20)

                        if isLineOfSightClear(worldX, worldY, worldZ, worldX, worldY, worldZ + 500) then 
                            if isElementInWater(localPlayer) then 
                                return
                            end

                            if getDistanceBetweenPoints3D(localPlayer.position, worldX, worldY, worldZ) > 19 then 
                                exports.cr_infobox:addBox("error", "Ilyen messziről nem tudod bedobni az úszót!")
                                return
                            end

                            local z = getWaterLevel(worldX, worldY, worldZ, false) or -0.55

                            triggerLatentServerEvent("fishing.createFloat", 5000, false, localPlayer, localPlayer, worldX, worldY, z)

                            if not floats[localPlayer] then 
                                exports["cr_chat"]:createMessage(localPlayer, "bedobja az úszót a vízbe", 1)

                                if isTimer(fishTimer) then 
                                    killTimer(fishTimer)
                                end

                                if isTimer(fishStartTimer) then 
                                    killTimer(fishStartTimer)
                                end

                                fishStartTimer = setTimer(
                                    function()
                                        doingMinigame = true
                                        localPlayer:setData("forceAnimation", {"SWORD", "sword_IDLE"})

                                        exports["cr_infobox"]:addBox("warning", "Figyelj mert kapásod van")
                                        fishTimer = setTimer(
                                            function()
                                                exports["cr_minigame"]:createMinigame(localPlayer, math.random(1, 3), "cr_fishing")
                                            end, 2000, 1
                                        )
                                    end, math.random(25000, 50000), 1
                                )
                            else 
                                exports["cr_chat"]:createMessage(localPlayer, "kihúzza az úszót a vízből", 1)

                                if isTimer(fishTimer) then 
                                    killTimer(fishTimer)
                                end

                                if isTimer(fishStartTimer) then 
                                    killTimer(fishStartTimer)
                                end
                            end

                            playerX, playerY, playerZ = getElementPosition(localPlayer)
                        else 
                            exports["cr_infobox"]:addBox("error", "Nem dobhatod ilyen közelre az úszót.")
                        end
                    end

                    spamTick = getTickCount()
                end
            end
        end
    end
end
addEventHandler("onClientClick", root, onClick)

addEvent("fishing.sync", true)
addEventHandler("fishing.sync", root,
    function(table1, table2)
        rods = table1 
        floats = table2

        returned = true
    end
)

function renderFishingLines()
    for key, value in pairs(floats) do 
        local playerRealX, playerRealY, playerRealZ = getElementPosition(localPlayer)

        if returned and key == localPlayer and getDistanceBetweenPoints3D(playerX, playerY, playerZ, playerRealX, playerRealY, playerRealZ) > fishingDistance then 
            if isTimer(fishTimer) then 
                killTimer(fishTimer)
            end

            if isTimer(fishStartTimer) then 
                killTimer(fishStartTimer)
            end

            triggerLatentServerEvent("fishing.createFloat", 5000, false, localPlayer, localPlayer, false, false)

            exports["cr_chat"]:createMessage(localPlayer, "kihúzza az úszót a vízből", 1)

            returned = false
        end

        if isElement(value) and isElementStreamedIn(value) then 
            local rodX, rodY, rodZ = getElementPosition(value)
            local rodStartX, rodStartY, rodStartZ = getPositionFromElementOffset(rods[key], 0.02, 0, 0.3)
            local rodEndX, rodEndY, rodEndZ = getPositionFromElementOffset(rods[key], 0.01, 0, 2.2)
            local floatX, floatY, floatZ = getPositionFromElementOffset(rods[key], 0.01, 0, 2.15)

            dxDrawLine3D(rodStartX, rodStartY, rodStartZ, rodEndX, rodEndY, rodEndZ, tocolor(130, 130, 130, 200), 0.5)
            dxDrawLine3D(rodX, rodY, rodZ, floatX, floatY, floatZ, tocolor(130, 130, 130, 200), 0.5)
        end
    end
end
addEventHandler("onClientRender", root, renderFishingLines)

addEvent("[Minigame - StopMinigame]", true)
addEventHandler("[Minigame - StopMinigame]", root,
    function(thePlayer, array)
        if thePlayer == localPlayer and array[2] == "cr_fishing" then 
            if array[3] >= array[5] then 
                local random = math.random(1, #items["id"])
                local randomFish = items["id"][random]
                
                local playerItems = exports.cr_inventory:getItems(localPlayer, 1)

                for k, v in pairs(playerItems) do 
                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(v)

                    if itemid == 85 then 
                        exports.cr_inventory:deleteItem(localPlayer, k, itemid)
                        exports.cr_inventory:giveItem(localPlayer, 152, 1, 1, 100)

                        break
                    end
                end
                
                exports["cr_inventory"]:giveItem(localPlayer, randomFish, 1, 1, 100)
                exports["cr_inventory"]:showItem({-5000, randomFish, 1, 1, 100, 0, 0})

                exports["cr_infobox"]:addBox("success", "Sikeresen kifogtad ezt a tárgyat: "..exports["cr_inventory"]:getItemName(randomFish))
                exports["cr_chat"]:createMessage(localPlayer, "Kifogott valamit. ("..exports["cr_inventory"]:getItemName(randomFish)..")", "do")
            else 
                exports["cr_infobox"]:addBox("error", "Nem sikerült kifognod a halat.")
                exports["cr_chat"]:createMessage(localPlayer, "A hal elúszott", "do")
            end

            triggerLatentServerEvent("fishing.createFloat", 5000, false, localPlayer, localPlayer, false, false)
            exports["cr_chat"]:createMessage(localPlayer, "kihúzza az úszót a vízből", 1)

            localPlayer:setData("forceAnimation", {"", ""})
            doingMinigame = false
        end
    end
)

local fishPed = Ped(fishPedSkinId, fishPedPoint)
fishPed:setRotation(fishPedRotation)
fishPed:setFrozen(true)
fishPed:setData("ped.name", "Peter Griffin")
fishPed:setData("ped.type", "Hal felvásárló")
fishPed:setData("fishing >> collectorPed", true)
fishPed:setData("char >> noDamage", true)

local fishPed = Ped(17, Vector3(2136.560546875, -88.160049438477, 2.8697571754456))
fishPed:setRotation(Vector3(0, 0, 25))
fishPed:setFrozen(true)
fishPed:setData("ped.name", "Joe Morgan")
fishPed:setData("ped.type", "Hal felvásárló")
fishPed:setData("fishing >> collectorPed", true)
fishPed:setData("char >> noDamage", true)

function getPositionFromElementOffset(element, offX, offY, offZ)
	if element and isElement(element) then
		local m = getElementMatrix(element)

		local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
		local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
		local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]

		return x, y, z
	end
end