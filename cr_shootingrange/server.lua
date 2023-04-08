local pedCache = {}

function createPeds()
    for key, value in pairs(pedDatas) do 
        local x, y, z, rot = unpack(value["position"])

        local ped = Ped(value["model"], x, y, z, rot)
        ped:setFrozen(true)
        ped:setInterior(value["interior"])
        ped:setDimension(value["dimension"])
        ped:setData("ped.name", value["name"])
        ped:setData("ped.type", value["tag"])
        ped:setData("ped >> priceMultipler", value["priceMultipler"])
        ped:setData("ped >> id", value["id"])

        if not value["decreasePed"] then 
            ped:setData("ped >> shootingRange", true)
        else 
            ped:setData("ped >> decreasePed", true)
        end

        ped:setData("char >> noDamage", true)

        pedCache[key] = ped
    end

    changeMultipler(math.random(1, 2))
end
addEventHandler("onResourceStart", resourceRoot, createPeds)

addEvent("changePlayerDimension", true)
addEventHandler("changePlayerDimension", root,
    function(thePlayer, newDimension)
        if client and client == thePlayer and newDimension then 
            thePlayer.dimension = newDimension
        end
    end
)

addEvent("changePlayerStats", true)
addEventHandler("changePlayerStats", root,
    function(thePlayer, statId, statValue, type)
        if not type then 
            setPedStat(thePlayer, statId, math.min(1000, statValue))
        else 
            setPedStat(thePlayer, statId, math.max(0, statValue))
        end
    end
)

mpS = math.random(1, 10) / 8
randomType = math.random(1, 2)
function changeMultipler()
    mpS = math.random(1, 10) / 8
    randomType = math.random(1, 2)
    local serverHex = exports["cr_core"]:getServerColor('yellow', true)

    outputChatBox(exports["cr_core"]:getServerSyntax("Shooting range", "info").."A(z) "..serverHex..pedDatas[randomType]["location"].."#ffffff-i lőtér árai megváltoztak!", root, 255, 255, 255, true)

    if pedCache[randomType] then 
        pedCache[randomType]:setData("ped >> priceMultipler", mpS)
    end
end
setTimer(changeMultipler, 60 * 60000, 0)