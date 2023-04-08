connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

local premiumCodes = {}
local isValidCode = {}
local spam = {}

Async:setPriority("high")
Async:setDebug(true)

function loadPremiumCodes()
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local code = tostring(row["code"])
                        local count = tonumber(row["count"])    
                        local dontDelete = tonumber(row["dontDelete"])
                        local userCache = fromJSON(tostring(row["userCache"]))
                        isValidCode[code] = id
                        premiumCodes[id] = {code, count, dontDelete, userCache}
                    end
                )
            end
            outputDebugString("Loading premiumcodes finished. Loaded #"..query_lines.." premiumcodes!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM `premiumcodes`")
end
addEventHandler("onResourceStart", resourceRoot, loadPremiumCodes)

function loadPremiumCode(id)
    if tonumber(id) then
        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    Async:foreach(query, 
                        function(row)
                            local id = tonumber(row["id"])
                            local code = tostring(row["code"])
                            local count = tonumber(row["count"])    
                            local dontDelete = tonumber(row["dontDelete"])
                            local userCache = fromJSON(tostring(row["userCache"]))
                            isValidCode[code] = id
                            premiumCodes[id] = {code, count, dontDelete, userCache}
                        end
                    )
                end
            end, 
        connection, "SELECT * FROM `premiumcodes` WHERE `id`=?", id)
    end
end
addEvent("loadPremiumCode", true)
addEventHandler("loadPremiumCode", root, loadPremiumCode)

function createPremiumCode(amount, code)
    if tonumber(amount) and code and #code == 10 then 
        dbExec(connection, 'INSERT INTO premiumcodes SET code=?, count=?', code, amount)

        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    Async:foreach(query, 
                        function(row)
                            local id = tonumber(row["id"])
                            local code = tostring(row["code"])
                            local count = tonumber(row["count"])    
                            local dontDelete = tonumber(row["dontDelete"])
                            local userCache = fromJSON(tostring(row["userCache"]))
                            isValidCode[code] = id
                            premiumCodes[id] = {code, count, dontDelete, userCache}
                        end
                    )
                end
            end, 
        connection, "SELECT * FROM `premiumcodes` WHERE `code`=?", code)
    end 
end 

function checkCode(sourceElement, code)
    local lastClickTick = spam[sourceElement] or 0
    if lastClickTick + 2500 > getTickCount() then
        return
    end
    spam[sourceElement] = getTickCount()
    
    local id = isValidCode[code]
    if id then -- jóváírás
        local code, count, dontDelete, userCache = unpack(premiumCodes[id])
        if tonumber(count) then
            if tonumber(dontDelete) == 0 then
                local blue = exports['cr_core']:getServerColor('yellow', true)
                local white = "#F2F2F2"
                sourceElement:setData("char >> premiumPoints", sourceElement:getData("char >> premiumPoints") + tonumber(count))
                premiumCodes[id] = nil
                isValidCode[code] = nil
                dbExec(connection, "DELETE FROM `premiumcodes` WHERE `id`=?", id)
                exports['cr_infobox']:addBox(sourceElement, "success", "Köszönjük a támogatást! "..blue..count..white.." PrémiumPont jóváírva!") 
            elseif tonumber(dontDelete) == 1 then
                if not userCache[tostring(sourceElement:getData("acc >> id"))] then
                    userCache[tostring(sourceElement:getData("acc >> id"))] = true
                    dbExec(connection, "UPDATE `premiumcodes` SET `userCache`=? WHERE `id`=?", toJSON(userCache), id)
                    local blue = exports['cr_core']:getServerColor('yellow', true)
                    local white = "#F2F2F2"
                    sourceElement:setData("char >> premiumPoints", sourceElement:getData("char >> premiumPoints") + tonumber(count))
                    exports['cr_infobox']:addBox(sourceElement, "success", blue..count..white.." PrémiumPont jóváírva!") 
                else
                    exports['cr_infobox']:addBox(sourceElement, "error", "Ezt a kódot már jóváírtad!") 
                end
            end
        end
    else -- error
        exports['cr_infobox']:addBox(sourceElement, "error", "Ez a kód nem jóváírható!") 
    end
end
addEvent("checkCode", true)
addEventHandler("checkCode", root, checkCode)