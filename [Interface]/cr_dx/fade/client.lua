local cache = {}

function startFade(id, data) 
    if not data then 
        data = {
            ["startTick"] = getTickCount(),
            ["lastUpdateTick"] = getTickCount(),
            ["time"] = 250,
            ["animation"] = "InOutQuad",
            ["from"] = 0,
            ["to"] = 255,
            ["alpha"] = 0,
            ["progress"] = 0,
        }
    end 

    cache[id] = data

    if not fadeRenderActive then 
        fadeRenderActive = true 
        createRender("renderFade", renderFade)
    end 
end 

function getFade(id)
    if cache[id] then 
        cache[id]["lastUpdateTick"] = getTickCount()
        return cache[id]["alpha"], cache[id]["progress"]
    end

    return false
end 

function renderFade()
    local nowTick = getTickCount()

    for k,v in pairs(cache) do
        local progress = (nowTick - v["startTick"]) / v["time"]

        if progress < 1 then 
            local alph = interpolateBetween(
                v["from"], 0, 0,
                v["to"], 0, 0,
                progress, v["animation"]
            )

            cache[k]["alpha"] = alph
            cache[k]["progress"] = progress
        else 
            cache[k]["alpha"] = v["to"]
            cache[k]["progress"] = 1
        end 

    end 
end 

setTimer(
    function()
        for k,v in pairs(cache) do
            if v["lastUpdateTick"] + 5000 <= getTickCount() then
                cache[k] = nil
                collectgarbage("collect")
            end
        end
    end, 5000, 0
)