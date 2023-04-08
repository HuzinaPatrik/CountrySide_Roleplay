local maxPercentage = {
    [1] = 5,
    [2] = 10,
    [3] = 30,
    [4] = 10,
}

function start()
    if localPlayer:getData("loggedIn") then
        --
        startTime = getTime()
        --outputChatBox(startTime)
        datas = {0, {}, {}, {}, {}}
        
        setTimer(
            function()
                datas[1] = datas[1] + 1 -- Másodperc mentés, /60 = perc /60 = óra
            end, 1000, 0
        )
        
        local oMoney = tonumber(localPlayer:getData("char >> money")) or 0
        --if oMoney == 0 then oMoney = 1 end
        local oMoney4 = tonumber(localPlayer:getData("char >> money")) or 0
        --if oMoney4 == 0 then oMoney4 = 1 end
        local warningMoney = 500000
        biggestMoney = oMoney
        smalestMoney = oMoney
        
        addEventHandler("onClientElementDataChange", localPlayer,
            function(dName, oValue)
                if dName == "char >> money" then
                    if source:getData(dName) and oValue then
                        --local money = tonumber(source:getData(dName))
                        local money = tonumber(localPlayer:getData("char >> money")) or 0
                        --if money == 0 then money = 1 end
                
                        if money >= biggestMoney then
                            biggestMoney = money
                        end

                        if money <= smalestMoney then
                            smalestMoney = money
                        end
                        
                        if money >= warningMoney then
                            report(localPlayer, "Feltűnő pénzzel rendelkezik: "..money, "MoneyCheat")
                        end

                        --[[
                        if money < 0 then
                            report(localPlayer, "Feltűnő pénzzel rendelkezik: "..money, "MoneyCheat")
                        end]]


                        local data = {oMoney4, money, tostring(money / oMoney4) .. "%", tonumber(money / oMoney4), getTime()}

                        if tonumber(money / oMoney4) >= maxPercentage[4] then
                            report(localPlayer, "(1 huzasmra) Túl gyorsan növekedett a pénze! ("..tonumber(oMoney4).." ról "..tonumber(money).."-ra(re) ("..tonumber(money / oMoney4).."%))", "MoneyCheat")
                        end
                        oMoney4 = money
                        table.insert(datas[5], #datas[5] + 1, data)
                    end
                end
            end
        )
        
        if oMoney >= warningMoney then
            report(localPlayer, "Feltűnő pénzzel rendelkezik: "..oMoney, "MoneyCheat")
        end

        if oMoney < 0 then
            report(localPlayer, "Feltűnő pénzzel rendelkezik: "..oMoney, "MoneyCheat")
        end
        
        setTimer(
            function()
                local money = tonumber(localPlayer:getData("char >> money")) or 0
                --if money == 0 then money = 1 end
                
                if money >= biggestMoney then
                    biggestMoney = money
                end
                
                if money <= smalestMoney then
                    smalestMoney = money
                end
                
                local data = {oMoney, money, tostring(money / oMoney) .. "%", tonumber(money / oMoney), getTime()}
                
                if tonumber(money / oMoney) >= maxPercentage[1] then
                    report(localPlayer, "(1 perc alatt) Túl gyorsan növekedett a pénze! ("..tonumber(oMoney).." ról "..tonumber(money).."-ra(re) ("..tonumber(money / oMoney).."%))", "MoneyCheat")
                end
                oMoney = money
                table.insert(datas[2], #datas[2] + 1, data)
            end, 1 * 60 * 1000, 0
        )
        
        local oMoney2 = tonumber(localPlayer:getData("char >> money")) or 0
        --if oMoney2 == 0 then oMoney2 = 1 end
        setTimer(
            function()
                local money = tonumber(localPlayer:getData("char >> money")) or 0
                --if money == 0 then money = 1 end
                
                if money >= biggestMoney then
                    biggestMoney = money
                end
                
                if money <= smalestMoney then
                    smalestMoney = money
                end
                
                if money >= warningMoney then
                    report(localPlayer, "Feltűnő pénzzel rendelkezik: "..money, "MoneyCheat")
                end
                
                if money < 0 then
                    report(localPlayer, "Feltűnő pénzzel rendelkezik: "..money, "MoneyCheat")
                end
                
                local data = {oMoney2, money, tostring(money / oMoney2) .. "%", tonumber(money / oMoney2), getTime()}
                
                if tonumber(money / oMoney) >= maxPercentage[2] then
                    report(localPlayer, "(10 perc alatt) Túl gyorsan növekedett a pénze! ("..tonumber(oMoney).." ról "..tonumber(money).."-ra(re) ("..tonumber(money / oMoney).."%))", "MoneyCheat")
                end
                oMoney2 = money
                table.insert(datas[3], #datas[3] + 1, data)
            end, 10 * 60 * 1000, 0
        )
        
        local oMoney3 = tonumber(localPlayer:getData("char >> money")) or 0
        --if oMoney3 == 0 then oMoney3 = 1 end
        setTimer(
            function()
                local money = tonumber(localPlayer:getData("char >> money")) or 0
                --if money == 0 then money = 1 end
                
                if money >= biggestMoney then
                    biggestMoney = money
                end
                
                if money <= smalestMoney then
                    smalestMoney = money
                end
                
                local data = {oMoney2, money, tostring(money / oMoney2) .. "%", tonumber(money / oMoney2), getTime()}
                
                if tonumber(money / oMoney) >= maxPercentage[3] then
                    report(localPlayer, "(1 óra alatt) Túl gyorsan növekedett a pénze! ("..tonumber(oMoney).." ról "..tonumber(money).."-ra(re) ("..tonumber(money / oMoney).."%))", "MoneyCheat")
                end
                oMoney2 = money
                table.insert(datas[3], #datas[3] + 1, data)
            end, 10 * 60 * 1000, 0
        )
    end
end
addEventHandler("onClientResourceStart", resourceRoot, start)

function stop()
    if localPlayer:getData("loggedIn") then
        --Statisztika feltöltés
        
        local sec, min, hour, day = convertSec(datas[1])
        sec = math.round(sec, 3, "floor")
        min = math.round(min, 3, "floor")
        hour = math.round(hour, 3, "floor")
        day = math.round(day, 3, "floor")
        local playedTime = toJSON({day, hour, min, sec, startTime, endTime}) -- nap, óra, min, sec, mikorKezdte, Mikorvégzett
        local endTime = getTime()
        

        outputDebugString("Játékidő: "..day.." nap, "..hour.." óra, "..min.." perc, "..sec.." másodperc", 0, 255, 255, 255)
        outputDebugString("Kezdés: "..startTime, 0, 255, 255, 255)
        outputDebugString("Vége: "..endTime, 0, 255, 255, 255)
        outputDebugString("Legmagasabb pénzérték a játékidő alatt: "..biggestMoney, 0, 255, 255, 255)
        outputDebugString("Legkisebb pénzérték a játékidő alatt: "..smalestMoney, 0, 255, 255, 255)
        
        local avgPercentage = 0
        local max = 0
        local num = 0
        for k,v in pairs(datas[2]) do
            local oMoney2, money, changeInString, changeInNum, time = unpack(v)
            max = max + changeInNum
            num = num + 1
        end
        --if max == 0 then max = 1 end
        if num == 0 then num = 1 end
        avgPercentage = max / num
        if avgPercentage == 1 then 
            avgPercentage = 0
        end
        
        outputDebugString("Percenként átlagos ennyitan változott a pénz: "..avgPercentage.."%", 0, 255, 255, 255)
        
        local avgPercentage = 0
        local max = 0
        local num = 0
        for k,v in pairs(datas[3]) do
            local oMoney2, money, changeInString, changeInNum, time = unpack(v)
            max = max + changeInNum
            num = num + 1
        end
        --if max == 0 then max = 1 end
        if num == 0 then num = 1 end
        avgPercentage = max / num
        if avgPercentage == 1 then 
            avgPercentage = 0
        end
        
        outputDebugString("10 Percenként átlagosan ennyit változott a pénz: "..avgPercentage.."%", 0, 255, 255, 255)
        
        local avgPercentage = 0
        local max = 0
        local num = 0
        for k,v in pairs(datas[4]) do
            local oMoney2, money, changeInString, changeInNum, time = unpack(v)
            max = max + changeInNum
            num = num + 1
        end
        --if max == 0 then max = 1 end
        if num == 0 then num = 1 end
        avgPercentage = max / num
        if avgPercentage == 1 then 
            avgPercentage = 0
        end
        
        outputDebugString("Óránként átlagosan ennyit változott a pénz: "..avgPercentage.."%", 0, 255, 255, 255)
        
        local avgPercentage = 0
        local max = 0
        local num = 0
        for k,v in pairs(datas[5]) do
            local oMoney2, money, changeInString, changeInNum, time = unpack(v)
            max = max + changeInNum
            num = num + 1
        end
        --if max == 0 then max = 1 end
        if num == 0 then num = 1 end
        avgPercentage = max / num
        if avgPercentage == 1 then 
            avgPercentage = 0
        end
        
        outputDebugString("Egyhuzamra átlagosan ennyit változott a pénz: "..avgPercentage.."%", 0, 255, 255, 255)
        
        saveStats()
    end
end
addEventHandler("onClientResourceStop", resourceRoot, stop)

function saveStats()
    return true
end

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName)
        if dName == "loggedIn" then
            if source:getData(dName) then
                return start()
            end
        end
    end
)

--
function getTime()
    local time = getRealTime()
	local hours = time.hour
	local minutes = time.minute
	local seconds = time.second
	-- Make sure to add a 0 to the front of single digits.
	if (hours < 10) then
		hours = "0"..hours
	end
	if (minutes < 10) then
		minutes = "0"..minutes
	end
	if (seconds < 10) then
		seconds = "0"..seconds
	end
    
    return tostring(hours) .. ":" .. tostring(minutes) .. ":" .. tostring(seconds)
end

function convertSec(d)
    local sec = d
    local min = d / 60
    local hour = d / 60 / 60
    local day = d / 60 / 60 / 24
    
    return sec, min, hour, day
end

function report(e, text, type)
    local syntax = exports['cr_core']:getServerSyntax("Anticheat", "warning")
    local text = text .. " (".. exports['cr_admin']:getAdminName(e) .. ")"
    exports['cr_core']:sendMessageToAdmin(e, syntax .. text, 8)
    --outputDebugString("[Warn] "..text, 0, 200, 200, 30)
    exports['cr_logs']:addLog(e, "sql", type, text)
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end