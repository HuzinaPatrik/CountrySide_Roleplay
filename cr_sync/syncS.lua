addEventHandler("onResourceStart", resourceRoot, function()
	updateTime();
end);

function updateTime()
	local realTime = getRealTime();
	hour = realTime.hour;

	if hour >= 24 then
		hour = hour - 24;
	elseif hour < 0 then
		hour = hour + 24;
	end

	setTime(hour, realTime.minute);
	setMinuteDuration(60000);

	outputDebugString("Real time: " .. ("%02d"):format(realTime.hour) .. ":" .. ("%02d"):format(realTime.minute));
	outputDebugString("Server time: " .. ("%02d"):format(hour) .. ":" .. ("%02d"):format(realTime.minute));

	changeTrafficControl();
	fetchWeather();
end
setTimer(updateTime, 1000 * 60 * 10, 0);

function changeTrafficControl()
	if (hour >= 22 and #getElementsByType("player") < 20) or (hour < 9 and #getElementsByType("player") < 20) then
		if not isTimer(trafficTimer) then
			trafficTimer = setTimer(function()
                setTrafficLightState((getTrafficLightState() == 9) and 6 or 9);
			end, 500, 0);
		end
	else
		if isTimer(trafficTimer) then
			killTimer(trafficTimer);
			setTrafficLightState("auto");
		end
	end
end

addEventHandler("onPlayerJoin", root, function()
	changeTrafficControl();
end);

addEventHandler("onPlayerQuit", root, function()
	changeTrafficControl();
end);

local temperature = 0;
function fetchWeather()
    local gtaNames = {
        ["Haze"] = math.random(12, 15),
        ["Mostly Cloudy"] = 2,
        ["Clear"] = 10,
        ["Cloudy"] = math.random(0, 7),
        ["Clouds"] = 2,
        ["Flurries"] = 32,
        ["Fog"] = math.random(0, 7),
        ["Moderate or heavy rain with thunder"] = 15,
        ["Moderate or heavy rain shower"] = 15,
        ["Patchy light rain with thunder"] = 15,
        ["Patchy rain possible"] = 15,
        ["Mostly Sunny"] = math.random(0, 7),
        ["Partly Cloudy"] = math.random(0, 7),
        ["Light rain"] = 15,
        ["Partly Sunny"] = math.random(0, 7),
        ["Freezing Rain"] = 15,
        ["Rain"] = 15,
        ["Sleet"] = 15,
        ["Snow"] = 31,
        ["Sunny"] = 11,
        ["Thunderstorms"] = 8,
        ["Thunderstorm"] = 8,
        ["Unknown"] = 0,
        ["Overcast"] = 7,
        ["Scattered Clouds"] = 7,
    }
    
    setRainLevel(0);
    setWindVelocity(0,0,0)
    setWaveHeight(0)
 
    fetchRemote("http://api.weatherapi.com/v1/current.json?key=2ce9bf01a4d64347bb1193326202705&q=New_York", function(data)
        local new = fromJSON(data);
        local wind = tonumber(new["current"]["wind_mph"]) / 10 or 0;
        local weather = tostring(new["current"]["condition"]["text"]);
		temperature = tonumber(new["current"]["temp_c"]) or 0;

        if wind > 3 then
            wind = 3;
        end
 
        setWindVelocity(wind, 0, 0);
        setWaveHeight(math.min(wind, 2));
 
        --weather = "Thunderstorm"
        if gtaNames[weather] then
            setWeather(gtaNames[weather]);
            if gtaNames[weather] == 15 then 
                --setRainLevel(math.random(1, 20) / 10);
            end
        else
            setWeather(1);
        end
 
        outputDebugString("weather - " .. weather .. "  | wind - " .. wind);
    end, nil, true);
end

local armors = {};

addEvent("sync->Armor", true);
addEventHandler("sync->Armor", root, function(player)
    if player.armor < 40 then
        if isElement(armors[player]) then
            destroyElement(armors[player]);
            armors[player] = nil
            collectgarbage("collect")
        end
    else
        if not isElement(armors[player]) then
            armors[player] = Object(1242, 0, 0, 0);
            armors[player].collisions = false
            armors[player].scale = 1.85;
            exports.cr_bone_attach:attachElementToBone(armors[player], player, 3, 0, 0.035, 0.025, 0, 0, 0);
        end
    end
end);

addEventHandler("onPlayerQuit", root, function()
    if isElement(armors[source]) then
        destroyElement(armors[source]);
    end
end);

function getTemperature()
	return temperature;
end