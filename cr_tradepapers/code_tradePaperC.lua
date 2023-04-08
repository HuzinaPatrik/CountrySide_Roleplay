
local cache = {
  screen = Vector2(guiGetScreenSize()),
  alpha = 0,
  font = exports['cr_fonts']:getFont("Roboto", 13),
  font2 = exports['cr_fonts']:getFont("Roboto", 8),
  signature = dxCreateFont("files/signature.ttf", 22),
  shown = false,
  signed = {false, alpha=0},
  side = false,
  data = {},
}
cache.pos = Vector2({cache.screen.x/2-387/2, cache.screen.y/2-485/2})

function showTradePaper(data, side)
  if not shown then
    cache.shown = true
    cache.side = side
    cache.data = data
    addEventHandler("onClientRender", root, drawTradePaper)
    animate(cache.alpha, 255, "InOutQuad", 500, function(anim) cache.alpha = anim end, function() addEventHandler("onClientClick", root, signTradePaper) end)
  end
end
addEvent("showTradePaper", true)
addEventHandler("showTradePaper", root, showTradePaper)

function drawTradePaper()
  dxDrawImage(cache.pos.x, cache.pos.y, 387, 485, "files/tradepaper.png", 0, 0, 0, tocolor(255, 255, 255, cache.alpha))
  dxDrawText("Kilépéshez nyomj 'Backspace'-t.", cache.screen.x/2 - 1, cache.pos.y + 485 + 10, _, _, tocolor(0, 0, 0, cache.alpha), 1, cache.font, "center", _, _, _, _, true)
  dxDrawText("Kilépéshez nyomj 'Backspace'-t.", cache.screen.x/2 + 1, cache.pos.y + 485 + 10, _, _, tocolor(0, 0, 0, cache.alpha), 1, cache.font, "center", _, _, _, _, true)
  dxDrawText("Kilépéshez nyomj 'Backspace'-t.", cache.screen.x/2, cache.pos.y + 485 + 10 - 1, _, _, tocolor(0, 0, 0, cache.alpha), 1, cache.font, "center", _, _, _, _, true)
  dxDrawText("Kilépéshez nyomj 'Backspace'-t.", cache.screen.x/2, cache.pos.y + 485 + 10 + 1, _, _, tocolor(0, 0, 0, cache.alpha), 1, cache.font, "center", _, _, _, _, true)
  dxDrawText("#FFFFFFKilépéshez nyomj '#427bbcBackspace#FFFFFF'-t.", cache.screen.x/2, cache.pos.y + 485 + 10, _, _, tocolor(255, 255, 255, cache.alpha), 1, cache.font, "center", _, _, _, _, true)

  dxDrawText(cache.data.name, cache.pos.x + 109, cache.pos.y + 294, _, _, tocolor(54, 89, 201, cache.alpha), 1, cache.font2, "left", "center")
  dxDrawText(cache.data.inttype, cache.pos.x + 115, cache.pos.y + 308, _, _, tocolor(54, 89, 201, cache.alpha), 1, cache.font2, "left", "center")
  dxDrawText("$".. cache.data.price, cache.pos.x + 96, cache.pos.y + 321.5, _, _, tocolor(54, 89, 201, cache.alpha), 1, cache.font2, "left", "center")
  dxDrawText(cache.data.type, cache.pos.x + 121, cache.pos.y + 335, _, _, tocolor(54, 89, 201, cache.alpha), 1, cache.font2, "left", "center")
  dxDrawText(returnRealTime(), cache.pos.x + 355, cache.pos.y + 388, _, _, tocolor(54, 89, 201, cache.alpha), 1, cache.font2, "right", "center")
  if cache.side == "seller" then
    if cache.signed[1] then
      dxDrawText(string.gsub(getElementData(cache.data.seller, "char >> name"), "_", " "), cache.pos.x + 28 + 158/2, cache.pos.y + 404 + 32/2, _, _, tocolor(54, 89, 201, cache.alpha), 1, cache.signature, "center", "center")
      dxDrawRectangle(cache.pos.x + 206, cache.pos.y + 404, cache.signed.w, 32, tocolor(255, 255, 255, 255))
    end
  elseif cache.side == "buyer" then
    dxDrawText(string.gsub(getElementData(cache.data.seller, "char >> name"), "_", " "), cache.pos.x + 28 + 158/2, cache.pos.y + 404 + 32/2, _, _, tocolor(54, 89, 201, cache.alpha), 1, cache.signature, "center", "center")
    if cache.signed[1] then
      dxDrawText(string.gsub(getElementData(cache.data.buyer, "char >> name"), "_", " "), cache.pos.x + 206 + 158/2, cache.pos.y + 404 + 32/2, _, _, tocolor(54, 89, 201, cache.alpha), 1, cache.signature, "center", "center")
      dxDrawRectangle(cache.pos.x + 387, cache.pos.y + 404, cache.signed.w, 32, tocolor(255, 255, 255, cache.alpha))
    end
  elseif cache.side == "view" then
    dxDrawText(string.gsub(getElementData(cache.data.seller, "char >> name"), "_", " "), cache.pos.x + 28 + 158/2, cache.pos.y + 404 + 32/2, _, _, tocolor(54, 89, 201, cache.alpha), 1, cache.signature, "center", "center")
    dxDrawText(string.gsub(getElementData(cache.data.buyer, "char >> name"), "_", " "), cache.pos.x + 206 + 158/2, cache.pos.y + 404 + 32/2, _, _, tocolor(54, 89, 201, cache.alpha), 1, cache.signature, "center", "center")
  end
end

function signTradePaper(b, s)
  if b == "left" and s == "up" then
    if exports.cr_core:isInSlot(cache.pos.x + 28, cache.pos.y + 410, 158, 32) and cache.side == "seller" then
      if not cache.signed[1] then
        cache.signed[1] = true
        cache.signed.w = -((dxGetTextWidth(getElementData(cache.data.seller, "char >> name"), 1, cache.signature)) + 205-158)
        local sound = playSound("files/writing.mp3")
        animate(cache.signed.w, 0, "InQuad", 3000, function(anim) cache.signed.w = anim end, function() animate(cache.alpha, 0, "InOutQuad", 500, function(anim) cache.alpha = anim end, function() stopSound(sound) removeEventHandler("onClientClick", root, signTradePaper) cache.shown = false cache.side = false triggerServerEvent("sellerSigned", root, cache.data) cache.data = {} removeEventHandler("onClientRender", root, drawTradePaper) end) end)
      end
    elseif exports.cr_core:isInSlot(cache.pos.x + 186 + 20, cache.pos.y + 410, 158, 32) and cache.side == "buyer" then
      if not cache.signed[1] then
        cache.signed[1] = true
        cache.signed.w = -((dxGetTextWidth(getElementData(cache.data.buyer, "char >> name"), 1, cache.signature)) + 205-158)
        local sound = playSound("files/writing.mp3")
        animate(cache.signed.w, 0, "InQuad", 3000, function(anim) cache.signed.w = anim end, function() animate(cache.alpha, 0, "InOutQuad", 500, function(anim) cache.alpha = anim end, function() stopSound(sound) removeEventHandler("onClientClick", root, signTradePaper) cache.shown = false cache.side = false triggerServerEvent("buyerSigned", root, cache.data) cache.data = {} removeEventHandler("onClientRender", root, drawTradePaper) end) end)
      end
    end
  end
end

function returnRealTime()
	local time = getRealTime()
  local monthday = time.monthday
	local month = time.month
	local year = time.year

  local formattedTime = string.format("%04d. %02d. %02d.", 1900+year, month + 1, monthday)
	return formattedTime
end

------------------------------------

-- // Animation // --

local anims, builtins = {}, {"Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve"}

function table.find(t, v)
	for k, a in ipairs(t) do
		if a == v then
			return k
		end
	end
	return false
end

function animate(f, t, easing, duration, onChange, onEnd)
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
