
local connection = exports.cr_mysql:getConnection()

local tradepapers = {}
local _tmp = {}
local selected = -1

addEventHandler("onClientResourceStart", root,
  function()
    loadTradePapers()
  end
)

function testprer(thePlayer, cmdName, buyer, price, name, inttype, type, dbid)
  local buyer = exports.cr_core:findPlayer(thePlayer, buyer, true)
  createTradePaper(thePlayer, buyer, price, name, inttype, type, dbid)
end
addCommandHandler("ttp", testprer)

function loadTradePapers()
  local qh, row, error = dbPoll(dbQuery(connection, "SELECT * FROM tradepapers"), 30000)
  for k, v in pairs(qh) do
    tradepapers[v["dbid"]] = v
  end
end

function createTradePaper(seller, buyer, price, name, inttype, type, dbid)
  local id = highestIndex(_tmp)
  _tmp[id+1] = {buyer=buyer, seller=seller, price=price, name=name, inttype=inttype, type=type, element_id=dbid}
  triggerClientEvent(seller, "showTradePaper", seller, _tmp[id+1], "seller")
end

function sellerSigned(data)
  triggerClientEvent(data.buyer, "showTradePaper", data.buyer, data, "buyer")
end
addEvent("sellerSigned", true)
addEventHandler("sellerSigned", root, sellerSigned)

function buyerSigned(data)
  exports.cr_interior:transferOwnerShip(data.dbid, data.buyer)
  local id = highestIndex(tradepapers)+1
  tradepapers[id] = data
  insertTradePaper(id)
end
addEvent("buyerSigned", true)
addEventHandler("buyerSigned", root, buyerSigned)

function insertTradePaper(index)
  local exec = dbExec(connection, "INSERT INTO tradepapers SET seller = ?, buyer = ?, name = ?, type = ?, inttype = ?, element_id = ?, price = ?, createdat = ?", tradepapers[index].seller, tradepapers[index].buyer, tradepapers[index].name, tradepapers[index].type, tradepapers[index].inttype, tradepapers[index].element_id, tradepapers[index].price, returnRealTime())
end

local lastHighIndex = 0
function highestIndex(table)
  for i, v in pairs(table) do
    if lastHighIndex < i then
      lastHighIndex = i
    end
  end
  return lastHighIndex
end

function returnRealTime()
	local time = getRealTime()
  local monthday = time.monthday
	local month = time.month
	local year = time.year

  local formattedTime = string.format("%04d. %02d. %02d.", 1900+year, month + 1, monthday)
	return formattedTime
end
