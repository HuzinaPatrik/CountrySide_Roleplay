local path = "";
local cache = {};

function copyFile(path1, path2)
    return fileCopy(path1, path2, true);
end

function randomBytes(count, seed)
	if seed then
		math.randomseed(seed)
	end
	local str = ""
	for i = 1, count do
		str = str .. string.char(math.random(0, 255))
	end
	return str
end

function encryptModels(resource, model, paths, glassLoad, virtualVehicle)
	local resourcePath = ":" .. resource.name .. "/"
	local resourceMeta = XML.load(resourcePath .. "meta.xml")
    if not resourceMeta then
        outputDebugString("Failed to open resource '" .. tostring(resource.name) .. "'");
        return;
    end

    if not paths.src then 
		outputDebugString("Missing SRC for '" .. filename .. "'")
		return false;
	end

	local buildPath = ":cr_vehicles/";
    
    local file = loadFile(resourcePath .. paths.src)

    local outputFileData = file
    local pathName = paths.src
    local path = pathName:gsub(".txd", ""):gsub(".dff", ""):gsub(".col", "")
    local outputFileName = path .. "." .. paths.type;
    local randomHeader = ""

    if paths.type == "dff" then 
        local seed = #file
        randomHeader = randomBytes(8, seed) .. "COUNTRYSIDE_ASSETS" .. randomBytes(math.random(1024, 1024 * 4), seed)
        outputFileData = randomHeader .. file --exports['cr_builder']:compileData(file);
        outputFileName = path .. ".country" .. paths.type;
    end 

    saveFile(buildPath .. outputFileName, outputFileData);
    
    if not tonumber(model) then
        if fromJSON(tostring(model)) then
            model = tostring(model)
        else
            outputDebugString("Bad modelid for '" .. filename .. "'")
            return false
        end
    else
        model = tonumber(model)
    end
    
    table.insert(cache, {model, outputFileName, paths.type, glassLoad, virtualVehicle, #randomHeader, #file})
    
    return true;
end

preDatas = [[
vehicleIds = {
    400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415,
	416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433,
	434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451,
	452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469,
	470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487,
	488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505,
	506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523,
	524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541,
	542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559,
	560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577,
	578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595,
	596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 610, 611
}

validVehicleIds = {}
for k,v in pairs(vehicleIds) do 
    validVehicleIds[v] = true
end 

function isVehicleValid(model)
    assert(type(model) == "number", 1);
    return validVehicleIds[model] or virtualToAllocatedVehicleID[model];
end

function isVirtualVehicle(model)
    assert(type(model) == "number", 1);
    return virtualToAllocatedVehicleID[model];
end
]]

getFunction = [[
fullCache = cache

function getLoadCache()
    return fullCache
end
]]

addCommandHandler("encryptVehicles", function(localPlayer)
    if not exports['cr_core']:getPlayerDeveloper(localPlayer) then return end
    cache = {}
	local count = {};
	count["fail"] = 0;
	count["success"] = 0;

    local resource = getResourceFromName("cr_vehiclepanel");
    resource:stop()    
    
    local resourcePath = ":" .. resource.name .. "/"
	local resourceMeta = XML.load(resourcePath .. "meta.xml")
    if not resourceMeta then
        outputDebugString("Failed to open resource '" .. tostring(resource.name) .. "'");
        return;
    end
        

    index = 0 
    if isTimer(encryptTimer) then killTimer(encryptTimer)  end 
    encryptTimer = setTimer(
        function()
            index = index + 1 

            local k = index 
            local child = resourceMeta.children[index] 
            if child then 
                local paths = {};    
                if child.name ~= "file" then
                    return;
                end

                local path = child:getAttribute("src");
                if not path then
                    return;
                end

                if not string.find(path, "dff") and not string.find(path, "txd") and not string.find(path, "col") then
                    return
                end

                local pathName = path:gsub(".txd", ""):gsub(".dff", ""):gsub(".col", "")
                local modelid = child:getAttribute("modelid") or tonumber(pathName)
                local glassLoad = child:getAttribute("glassLoad")
                if glassLoad and tostring(glassLoad) == "true" or tonumber(glassLoad) == 1 then
                    glassLoad = true
                else
                    glassLoad = false
                end

                local virtualVehicle = child:getAttribute("virtualVehicle")
                if virtualVehicle and tostring(virtualVehicle) == "true" or tonumber(virtualVehicle) == 1 then
                    virtualVehicle = true
                else
                    virtualVehicle = false
                end
                
                if string.find(path, "dff") then
                    paths.type = "dff"
                elseif string.find(path, "txd") then
                    paths.type = "txd"
                elseif string.find(path, "col") then
                    paths.type = "col"
                end
                if modelid then
                    paths.src = pathName .. "."..paths.type;
                    if encryptModels(resource, modelid, paths, glassLoad, virtualVehicle) then
                        count["success"] = count["success"] + 1;
                    else
                        count["fail"] = count["fail"] + 1;
                    end    
                end      

                outputDebugString("Building state: (" .. tostring(count["success"]) .. "/" .. tostring(count["fail"] + count["success"]) .. ")");
            else 
                if isTimer(encryptTimer) then killTimer(encryptTimer) end 
                local buildPath = ":cr_vehicles/";
                local meta =  XML(buildPath .. "meta.xml", "meta");

                local resource = getResourceFromName("cr_vehicles");
                if resource then
                    local state = exports['cr_builder']:unbuildResource(localPlayer, resource);
                end

                local vehiclesArrayString = "{\n";
                for i, info in ipairs(cache) do
                    local fileChild = meta:createChild("file");
                    fileChild:setAttribute("src", info[2]);
                    if tonumber(info[1]) then  
                        vehiclesArrayString = vehiclesArrayString .. "    {"..tostring(info[1])..", \""..tostring(info[2]).."\", \""..tostring(info[3]).."\", "..tostring(info[4])..", "..tostring(info[5])..", "..tostring(info[6])..", "..tostring(info[7]).."},\n";
                    else 
                        vehiclesArrayString = vehiclesArrayString .. "    {\""..tostring(info[1]).."\", \""..tostring(info[2]).."\", \""..tostring(info[3]).."\", "..tostring(info[4])..", "..tostring(info[5])..", "..tostring(info[6])..", "..tostring(info[7]).."},\n";
                    end 
                end

                vehiclesArrayString = vehiclesArrayString .. "};\n\n";
                    
                local scriptChild = meta:createChild("script");
                local loaderFile = "";

                loaderFile = preDatas .. "\ncache = " .. vehiclesArrayString .. getFunction;
                local loaderFilePath = "global.lua";

                saveFile(buildPath .. loaderFilePath, loaderFile);
                    
                scriptChild:setAttribute("src", loaderFilePath);
                scriptChild:setAttribute("type", "shared");
                scriptChild:setAttribute("cache", "false");
                    
                copyFile("files/client.lua", buildPath .. "client.lua");
                local scriptChild = meta:createChild("script");
                scriptChild:setAttribute("src", "client.lua");
                scriptChild:setAttribute("type", "client");
                scriptChild:setAttribute("cache", "false");
                    
                local scriptChild = meta:createChild("export");
                scriptChild:setAttribute("function", "getLoadCache");
                scriptChild:setAttribute("type", "shared");
                    
                local scriptChild = meta:createChild("export");
                scriptChild:setAttribute("function", "loadModel");
                scriptChild:setAttribute("type", "client");
                    
                local scriptChild = meta:createChild("export");
                scriptChild:setAttribute("function", "getModelSize");
                scriptChild:setAttribute("type", "client");   
                    
                local scriptChild = meta:createChild("export");
                scriptChild:setAttribute("function", "getModelTypSize");
                scriptChild:setAttribute("type", "client");   

                local scriptChild = meta:createChild("export");
                scriptChild:setAttribute("function", "isVehicleValid");
                scriptChild:setAttribute("type", "shared");   

                local scriptChild = meta:createChild("export");
                scriptChild:setAttribute("function", "isVirtualVehicle");
                scriptChild:setAttribute("type", "shared");   

                meta:saveFile();
                meta:unload();
                exports['cr_builder']:processResource(resource);

                outputDebugString("Done building (" .. tostring(count["success"]) .. "/" .. tostring(count["fail"] + count["success"]) .. ")");
            end 
        end, 250, 0
    )
end);