local promptActive = false
local currentVehicle = false

local protectPrice = 500
local lastProtectTick = 0
local white = "#ffffff"

function protectCommand(cmd)
    if localPlayer:getData("loggedIn") then 
        local vehicle = localPlayer.vehicle

        if isElement(vehicle) then 
            local vehOwner = vehicle:getData("veh >> owner")
            local accountId = localPlayer:getData("acc >> id")
            local vehId = vehicle:getData("veh >> id")

            if vehId > 0 then 
                if not promptActive then 
                    local hexColor = exports.cr_core:getServerColor("yellow", true)

                    if not vehicle:getData("veh >> protect") then 
                        currentVehicle = vehicle
                        promptActive = true

                        exports.cr_dashboard:createAlert(
                            {
                                title = {"Biztosan szeretnél protectet vásárolni erre a járműre " .. hexColor .. protectPrice .. white .. " PP-ért?"},
                                headerText = "Protect vásárlás",

                                buttons = {
                                    {
                                        name = "Igen", 
                                        pressFunc = "vehicle.buyProtect",
                                        color = {exports.cr_core:getServerColor("green", false)},
                                    },

                                    {
                                        name = "Nem", 
                                        onClear = true,
                                        pressFunc = "vehicle.declineProtect",
                                        color = {exports.cr_core:getServerColor("red", false)},
                                    },
                                },
                            }
                        )
                    else
                        if vehOwner == accountId or exports.cr_permission:hasPermission(localPlayer, "forceProtect") then 
                            currentVehicle = vehicle
                            promptActive = true

                            exports.cr_dashboard:createAlert(
                                {
                                    title = {"Biztosan leszeretnéd venni a protectet a járművedről? Ez a művelet " .. hexColor .. "ingyenes" .. white .. "."},
                                    headerText = "Protect leszerelés",

                                    buttons = {
                                        {
                                            name = "Igen", 
                                            pressFunc = "vehicle.removeProtect",
                                            color = {exports.cr_core:getServerColor("green", false)},
                                        },

                                        {
                                            name = "Nem", 
                                            onClear = true,
                                            pressFunc = "vehicle.declineProtect",
                                            color = {exports.cr_core:getServerColor("red", false)},
                                        },
                                    },
                                }
                            )
                        else 
                            local syntax = exports.cr_core:getServerSyntax("Protect", "error")

                            outputChatBox(syntax .. "Csak a jármű tulajdonosa tudja levenni a protectet.", 255, 0, 0, true)
                        end
                    end
                end
            end
        else
            local syntax = exports.cr_core:getServerSyntax("Protect", "error")

            outputChatBox(syntax .. "Nem ülsz járműben.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("protect", protectCommand, false, false)

function buyProtect()
    if exports.cr_network:getNetworkStatus() then 
        return
    end

    if localPlayer:getData("char >> premiumPoints") >= protectPrice then 
        promptActive = false

        local nowTick = getTickCount()
        local a = 10

        if nowTick <= lastProtectTick + a * 1000 then
            return
        end

        lastProtectTick = getTickCount()

        local premiumPoints = localPlayer:getData("char >> premiumPoints")

        localPlayer:setData("char >> premiumPoints", math.max(0, premiumPoints - protectPrice))

        if isElement(currentVehicle) then 
            triggerLatentServerEvent("vehicle.buyProtectForVehicle", 5000, false, localPlayer, currentVehicle)

            promptActive = false
            currentVehicle = false
        end
    else 
        local syntax = exports.cr_core:getServerSyntax("Protect", "error")

        outputChatBox(syntax .. "Nincs elég prémiumpontod a protect megvásárlásához!", 255, 0, 0, true)
    end

    promptActive = false
    currentVehicle = false
end
addEvent("vehicle.buyProtect", true)
addEventHandler("vehicle.buyProtect", root, buyProtect)

function removeProtect()
    if exports.cr_network:getNetworkStatus() then 
        return
    end

    if isElement(currentVehicle) then 
        promptActive = false

        local nowTick = getTickCount()
        local a = 10

        if nowTick <= lastProtectTick + a * 1000 then
            return
        end

        lastProtectTick = getTickCount()

        triggerLatentServerEvent("vehicle.removeProtectFromVehicle", 5000, false, localPlayer, currentVehicle)

        currentVehicle = false
    else
        promptActive = false
        currentVehicle = false
    end
end
addEvent("vehicle.removeProtect", true)
addEventHandler("vehicle.removeProtect", root, removeProtect)

function declineProtect()
    promptActive = false
    currentVehicle = false
end
addEvent("vehicle.declineProtect", true)
addEventHandler("vehicle.declineProtect", root, declineProtect)

local function onVehicleExit(thePlayer)
    if thePlayer == localPlayer then 
        if currentVehicle == source then 
            promptActive = false
            currentVehicle = false

            exports.cr_dashboard:clearAlerts()
        end
    end
end
addEventHandler("onClientVehicleExit", root, onVehicleExit)