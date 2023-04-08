statistic = {}
statisticDetails = {}
statisticText = {
    ["maxVelocity"] = "Végsebesség",
    ["engineAcceleration"] = "Gyorsulás",
    ["tractionLoss"] = "Tapadás",
    ["brakeDeceleration"] = "Fékek",
}

function getVehicleStatistic(vehicle)
    statistic = {
        ["maxVelocity"] = {exports['cr_handling']:getVehicleMinimumHandlingData(vehicle, "maxVelocity"), exports['cr_handling']:getVehicleMaximumHandlingData(vehicle, "maxVelocity")},
        ["engineAcceleration"] = {exports['cr_handling']:getVehicleMinimumHandlingData(vehicle, "engineAcceleration"), exports['cr_handling']:getVehicleMaximumHandlingData(vehicle, "engineAcceleration")},
        ["tractionLoss"] = {exports['cr_handling']:getVehicleMinimumHandlingData(vehicle, "tractionLoss"), exports['cr_handling']:getVehicleMaximumHandlingData(vehicle, "tractionLoss")},
        ["brakeDeceleration"] = {exports['cr_handling']:getVehicleMinimumHandlingData(vehicle, "brakeDeceleration"), exports['cr_handling']:getVehicleMaximumHandlingData(vehicle, "brakeDeceleration")},
    }

    statisticDetails = {}
    for k,v in pairs(statistic) do 
        statisticDetails[k] = 0
        statisticDetails["real"..k] = 0
    end 

    if isTimer(statisticTimer) then 
        killTimer(statisticTimer) 
    end 

    statisticTimer = setTimer(updateStatisticDetails, 250, 0)
end 

function destroyVehicleStatisticData()
    statistic = {}
    statisticDetails = {}

    if isTimer(statisticTimer) then 
        killTimer(statisticTimer) 
    end 
end 

function updateStatisticDetails()
    for k,v in pairs(statistic) do 
        local val = math.max(0 , math.min(1, (getVehicleHandling(localPlayer.vehicle)[k] - v[1]) / (v[2] - v[1])))
        if statisticDetails[k] ~= val then 
            statisticDetails[k] = val
            statisticDetails[k.."Animation"] = true
            statisticDetails[k.."AnimationTick"] = getTickCount()
        end 
    end 
end