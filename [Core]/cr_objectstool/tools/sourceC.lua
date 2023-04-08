local func = {};
local objectCache = {	
	--[[
	{	
		model = 7950, 
		position = {1117.58984, -1490.00977, 32.7188},
		rotation = {0, 0, 0},
		distance = 300,
        lodObject = true,
		doubleSide = false,
		collision = true,
		interior = 0, 
		dimension = -1,
	};]]

	{	
		model = 16199, 
		position = {261.7002, 638.40039, 0.5},
		rotation = {0,0,123.997},
		distance = 1000,
        lodObject = true,
		doubleSide = true,
		collision = true,
		interior = 0, 
		dimension = -1,
	};
	{	
		model = 16205, 
		position = {468.79004, 778.09961, 0.509},
		rotation = {0,0,123.997},
		distance = 1000,
        lodObject = true,
		doubleSide = true,
		collision = true,
		interior = 0, 
		dimension = -1,
	};
	{	
		model = 16198, 
		position = {329.09961, 985.2002, 0.5},
		rotation = {0,0,124},
		distance = 1000,
        lodObject = true,
		doubleSide = true,
		collision = true,
		interior = 0, 
		dimension = -1,
	};
	{	
		model = 16102, 
		position = {121.90039, 845.59961, 0.5},
		rotation = {0,0,123.997},
		distance = 1000,
        lodObject = true,
		doubleSide = true,
		collision = true,
		interior = 0, 
		dimension = -1,
	};
};

func.start = function()
	for k,v in ipairs(objectCache) do
		--outputChatBox(v.model)
		local objNormal = createObject (v.model, v.position[1], v.position[2], v.position[3],v.rotation[1],v.rotation[2],v.rotation[3])
        local objLowLOD = createObject (v.model, v.position[1], v.position[2], v.position[3],v.rotation[1],v.rotation[2],v.rotation[3],v.lodObject)  
		setLowLODElement (objNormal, objLowLOD)
		engineSetModelLODDistance (v.model, v.distance)
		setElementDoubleSided (objNormal,v.doubleSide)
		setElementDoubleSided (objLowLOD,v.doubleSide)
		setElementCollisionsEnabled(objNormal,v.collision)
		setElementCollisionsEnabled(objLowLOD,v.collision)
		setElementInterior(objNormal,v.interior)
		setElementInterior(objLowLOD,v.interior)
		setElementDimension(objNormal,v.dimension)
		setElementDimension(objLowLOD,v.dimension)
	end  
end
addEventHandler("onClientResourceStart",resourceRoot,func.start) 

function cam()
    if exports['cr_core']:getPlayerDeveloper(localPlayer) then
        local cx,cy,cz,lx,ly,lz = getCameraMatrix(localPlayer) 
        outputChatBox("Camera matrix: " .. cx .. ", " .. cy .. ", " .. cz .. ", " .. lx .. ", " .. ly .. ", " .. lz .. " ")
    end
end    
addCommandHandler("campos", cam)

function checkTheObjects ( cmd )
    if exports['cr_core']:getPlayerDeveloper(localPlayer) then
        local amount = 0 -- When starting the command, we don't have any objects looped.
        for k,v in ipairs ( getElementsByType ( "object" ) ) do -- Looping all the objects in the server
            if isElementStreamedIn ( v ) then -- If the object is streamed in
                amount = amount + 1 -- It's an object more streamed in
            end
        end
        outputChatBox ( "You have currently " ..amount.. " objects streamed in." ) -- Send the player the amount of objects that are streamed in
    end
end
addCommandHandler ( "checkobjects", checkTheObjects )
