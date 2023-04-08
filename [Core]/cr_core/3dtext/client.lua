--[[
    TO:DO: 
    Nézze-e a lineot vagy nem kell; DONE [checkSightLine]
    minDist a betöltésre; DONE [maxDistance]
    alpházódjon-e ha távolodik vagy csak tűnjön el; DONE [fadeWithDistance]
    border: legyen-e körvonala; DONE [border]
    background: Legyen-e háttere r,g,b színkóddal, alpha percenttel; DONE [background]
    font,fontsize,realFontSize; DONE [fontDetails]
]]

local cache = {}
local elements = {}

function add3DText(id, data)
    if not cache[id] then 
        if not data['checkSightLine'] then 
            data['sightLine'] = true
        end 

        cache[id] = data

        if data['checkSightLine'] then 
            local x,y,z,dim,int = unpack(data['position'])
            local obj = Object(1328, x,y,z)
            obj.dimension = dim 
            obj.interior = int
            obj.alpha = 0
            obj.collisions = false
            elements[id] = obj
        end 
    end 
end 

--[[
add3DText('test', 
    {
        ['text'] = 'TESZT',
        ['color'] = {255, 59, 59},
        ['position'] = {1200.3771972656, -1342.6519775391, 13.399575233459, 0, 0},
        ['maxDistance'] = 24,
        ['fadeWithDistance'] = true, 
        ['checkSightLine'] = true,
        ['fontDetails'] = {'Poppins-Medium', 12, 1},
        ['background'] = {51, 51, 51, 0.8},
    }
)]]

function set3DText(id, text)
    if cache[id] then 
        cache[id]['text'] = text
    end 
end 

function set3DTextData(id, data)
    if cache[id] then 
        cache[id] = data
    end 
end 

function delete3DText(id)
    if cache[id] then 
        cache[id] = nil

        if isElement(elements[id]) then 
            elements[id]:destroy()
        end 

        elements[id] = nil
        renderCache[id] = nil 
    
        collectgarbage("collect")
    end 
end 

setTimer(
    function()
        cameraX, cameraY, cameraZ = getCameraMatrix()
        for k,v in pairs(cache) do
            if v['checkSightLine'] then 
                if elements[k] and elements[k].onScreen then
                    local x, y, z, dim, int = unpack(v['position'])

                    cache[k]["sightLine"] = isLineOfSightClear(cameraX, cameraY, cameraZ, x, y, z, true, false, false, true, false, false, false, localPlayer)
                    cache[k]["distance"] = math.sqrt((cameraX - x) ^ 2 + (cameraY - y) ^ 2 + (cameraZ - z) ^ 2)
                end
            end 
        end
    end, 200, 0
)

renderCache = {}

setTimer(
    function()
        local cache = cache

        local num = 0
        for k,v in pairs(cache) do 
            num = num + 1

            break 
        end 

        renderCache = {}

        if num == 1 then 
            if not checkRender("render3DText") then 
                createRender("render3DText", render3DText)
            end 

            for k,v in pairs(cache) do
                if isElement(elements[k]) and isElementStreamedIn(elements[k]) or not v['checkSightLine'] then
                    if v["sightLine"] then
                        renderCache[k] = v
                    end
                end
            end
        else 
            if checkRender("render3DText") then 
                destroyRender("render3DText")
            end 
        end 
    end, 100, 0
)

local maxDist = 32
function render3DText()
    for k, v in pairs(renderCache) do
        if not isElement(elements[k]) then 
            cache[k] = nil
            elements[k] = nil 
            renderCache[k] = nil 

            collectgarbage("collect")

            return
        end 

        local x, y, z, dim, int = unpack(v['position'])
        local maxDistance = v['maxDistance'] or maxDist
        local distance = v["distance"]
        local text = v['text'] or ''

        if distance <= maxDistance then
            local size = 1 - (distance / maxDistance)
            local screenX, screenY = getScreenFromWorldPosition(x, y, z)

            if screenX and screenY then
                local alpha = 255
                if v['fadeWithDistance'] then 
                    alpha = alpha * size
                end 

                local font, fontsize, realFontSize = unpack(v['fontDetails'])

                local r,g,b = unpack(v['color'] or {255, 255, 255})

                local font = exports['cr_fonts']:getFont(font, fontsize)

                if not realFontSize then 
                    realFontSize = 1
                end 

                local realFontSize = realFontSize * size

                if v['background'] then 
                    local r,g,b,alphaPercentage = unpack(v['background'])
                    if not alphaPercentage then 
                        alphaPercentage = 1
                    end 
                    local alpha = alpha * alphaPercentage

                    local tWidth = dxGetTextWidth(text, realFontSize, font, true) + (10 * size)
                    local tHeight = dxGetFontHeight(realFontSize, font)

                    dxDrawRectangle(screenX - tWidth/2, screenY - tHeight, tWidth, tHeight, tocolor(r,g,b,alpha))
                end 

                if v['border'] then 
                    shadowedText(string.gsub(text, "#%x%x%x%x%x%x", ""),screenX, 0, screenX, screenY, tocolor(r, g, b, alpha), realFontSize, font, 'center', 'bottom', true, alpha)
                end 

                dxDrawText(text, screenX, 0, screenX, screenY, tocolor(r, g, b, alpha), realFontSize, font, "center", "bottom", false, false, false, true, true)
            end
        end 
    end
end 