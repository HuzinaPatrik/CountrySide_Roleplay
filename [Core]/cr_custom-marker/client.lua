local cache = {}
local iconCache = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(getElementsByType("marker", _, true)) do
            if v:getData("marker >> customMarker") then
                createCache(v)
            end
        end
    end
)

function createCache(v)
    if not cache[v] then
        v.alpha = 0
        cache[v] = getDetails(v)
    end
end

function getIcon(path)
    if not iconCache[path] then
        if fileExists(path) then 
            iconCache[path] = dxCreateTexture(path, "argb")
        end 
    end
    
    return iconCache[path]
end

function getDetails(v)
    local tbl = {}
    tbl["size"] = v.size * 0.6
    tbl["width"] = tonumber(v:getData("marker >> width")) or 2
    tbl["type"] = tonumber(v:getData("marker >> type")) or 1
    tbl["icon"] = v:getData("marker >> customIconPath")
    return tbl
end

function destroyCache(v)
    if cache[v] then
        cache[v] = nil
        collectgarbage("collect")
    end
end

addEventHandler("onClientElementStreamIn", root,
    function()
        if source.type == "marker" then
            if source:getData("marker >> customMarker") then
                createCache(source)
            end
        end
    end
)

addEventHandler("onClientElementStreamOut", root,
    function()
        if source.type == "marker" then
            if source:getData("marker >> customMarker") then
                destroyCache(source)
            end
        end
    end
)

function drawnOctagon()
    for gMarker, v in pairs(renderCache) do 
        local typ = v["type"]
        if typ == 1 then -- "Octagon"
            local x,y,z = getElementPosition(gMarker)
            if not isElement(gMarker) then
                renderCache[gMarker] = nil
            end
            cx, cy, cz = x,y,z + 3
            ----outputChatBox("asd")
            ----outputChatBox(x)
            z = z + 0.2
            local now = getTickCount()
            local multipler, alpha, radiusPlus = interpolateBetween(-0.5, 0, -0.25, 0.1, 255, 0.25, now / 3000, "CosineCurve")
            local r,g,b = gMarker:getColor()
            dxDrawOctagon3D(x,y,z, v["size"] + radiusPlus, v["width"], tocolor(math.max(0, r - 15),math.max(0, g - 15),math.max(0, b - 15),alpha))
            z = z + multipler
            dxDrawImage3D(x, y, z+2, 1, 1, getIcon(v["icon"]),tocolor(r,g,b,alpha))
        else -- "Interior"
            
        end
    end
end

setTimer(
    function()
        renderCache = {}
        last = nil
        local localInt, localDim = getElementInterior(localPlayer), getElementDimension(localPlayer)
        for element, value in pairs(cache) do
            if isElement(element) and isElementStreamedIn(element) then
                local int, dim = element.interior, element.dimension
                if int == localInt and dim == localDim then
                    local maxDistance = 50
                    local distance = getDistanceBetweenPoints3D(localPlayer.position, element.position)
                    if distance <= maxDistance then
                        renderCache[element] = value
                        last = element

                        if not state then
                            state = true
                            --addEventHandler("onClientRender", root, drawnOctagon, true, "low-5")
                            createRender("drawnOctagon", drawnOctagon)
                        end
                    end
                end
            end
        end
        
        if not last and state then
            state = false
            --removeEventHandler("onClientRender", root, drawnOctagon)
            destroyRender("drawnOctagon")
        end
    end, 300, 0
)

function dxDrawImage3D( x, y, z, width, height, material, color, rotation, ... )
    return dxDrawMaterialLine3D( x, y, z, x, y, z - width, material, height, color or 0xFFFFFFFF, ... )
end

function dxDrawOctagon3D(x, y, z, radius, width, color)
	if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
		return false
	end

	local radius = radius or 1
	local radius2 = radius/math.sqrt(2)
	local width = width or 1
	local color = color or tocolor(255,255,255,150)

	point = {}

		for i=1,8 do
			point[i] = {}
		end

		point[1].x = x
		point[1].y = y-radius
		point[2].x = x+radius2
		point[2].y = y-radius2
		point[3].x = x+radius
		point[3].y = y
		point[4].x = x+radius2
		point[4].y = y+radius2
		point[5].x = x
		point[5].y = y+radius
		point[6].x = x-radius2
		point[6].y = y+radius2
		point[7].x = x-radius
		point[7].y = y
		point[8].x = x-radius2
		point[8].y = y-radius2
		
	for i=1,8 do
		if i ~= 8 then
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[i+1].x,point[i+1].y,z
		else
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[1].x,point[1].y,z
		end
		dxDrawLine3D(x, y, z, x2, y2, z2, color, width)
	end
	return true
end

function onClientElementDestroy()
    if renderCache[source] then 
        renderCache[source] = nil
    end
end
addEventHandler("onClientElementDestroy", root, onClientElementDestroy)