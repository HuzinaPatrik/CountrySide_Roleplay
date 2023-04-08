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

function encryptModels(resource, model, paths, glassLoad, virtualSkin)
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

	local buildPath = ":cr_weapons/";
    
    local file = loadFile(resourcePath .. paths.src)

    local outputFileData = file
    --iprint(outputFileData
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
    
    table.insert(cache, {model, outputFileName, paths.type, glassLoad, virtualSkin, #randomHeader, #file})
    
    return true;
end

addCommandHandler("encryptWeapons", function(localPlayer)
    if not exports['cr_core']:getPlayerDeveloper(localPlayer) then return end
    cache = {}
	local count = {};
	count["fail"] = 0;
	count["success"] = 0;

    local resource = getResourceFromName("cr_weaponpanel");
    resource:stop()    
    
    local resourcePath = ":" .. resource.name .. "/"
	local resourceMeta = XML.load(resourcePath .. "meta.xml")
    if not resourceMeta then
        outputDebugString("Failed to open resource '" .. tostring(resource.name) .. "'");
        return;
    end
        
    --underscore.each(resourceMeta.children, 
        --function (child)

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
                --paths.name = pathName
                --outputChatBox(pathName)
                --outputChatBox("asd2")    
                local modelid = child:getAttribute("modelid") or tonumber(pathName)
                local glassLoad = child:getAttribute("glassLoad")
                if glassLoad and tostring(glassLoad) == "true" or tonumber(glassLoad) == 1 then
                    glassLoad = true
                else
                    glassLoad = false
                end

                local virtualSkin = child:getAttribute("virtualSkin")
                if virtualSkin and tostring(virtualSkin) == "true" or tonumber(virtualSkin) == 1 then
                    virtualSkin = true
                else
                    virtualSkin = false
                end
                --outputChatBox(pathName)
                --outputChatBox(modelid)
                
                if string.find(path, "dff") then
                    paths.type = "dff"
                elseif string.find(path, "txd") then
                    paths.type = "txd"
                elseif string.find(path, "col") then
                    paths.type = "col"
                end
                if modelid then
                    paths.src = pathName .. "."..paths.type;

                    --outputChatBox("asd")
                    if encryptModels(resource, modelid, paths, glassLoad, virtualSkin) then
                        count["success"] = count["success"] + 1;
                    else
                        count["fail"] = count["fail"] + 1;
                    end    
                end      

                outputDebugString("Building state: (" .. tostring(count["success"]) .. "/" .. tostring(count["fail"] + count["success"]) .. ")");
            else 
                if isTimer(encryptTimer) then killTimer(encryptTimer) end 
                local buildPath = ":cr_weapons/";
                local meta =  XML(buildPath .. "meta.xml", "meta");

                local resource = getResourceFromName("cr_weapons");
                if resource then
                    local state = exports['cr_builder']:unbuildResource(localPlayer, resource);
                end

                local vehiclesArrayString = "{\n";
                for i, info in ipairs(cache) do
                    --iprint(info)
                    --iprint(i)
                    local fileChild = meta:createChild("file");
                    fileChild:setAttribute("src", info[2]);
                    --vehiclesArrayString = vehiclesArrayString .. "\t" .. arrayToString(info) .. ",\n";
                    if tonumber(info[1]) then  
                        vehiclesArrayString = vehiclesArrayString .. "    {"..tostring(info[1])..", \""..tostring(info[2]).."\", \""..tostring(info[3]).."\", "..tostring(info[4])..", "..tostring(info[5])..", "..tostring(info[6])..", "..tostring(info[7]).."},\n";
                    else 
                        vehiclesArrayString = vehiclesArrayString .. "    {\""..tostring(info[1]).."\", \""..tostring(info[2]).."\", \""..tostring(info[3]).."\", "..tostring(info[4])..", "..tostring(info[5])..", "..tostring(info[6])..", "..tostring(info[7]).."},\n";
                    end 
                end

                vehiclesArrayString = vehiclesArrayString .. "};\n\n";
                    
                local scriptChild = meta:createChild("script");
                local loaderFile = "";

                loaderFile = "\ncache = " .. vehiclesArrayString;
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

                meta:saveFile();
                meta:unload();
                exports['cr_builder']:processResource(resource);

                outputDebugString("Done building (" .. tostring(count["success"]) .. "/" .. tostring(count["fail"] + count["success"]) .. ")");
            end 
        end, 250, 0
    )
end);