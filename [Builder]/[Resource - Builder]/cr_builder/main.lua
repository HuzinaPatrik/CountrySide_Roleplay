local LUAC_URL = "http://luac.mtasa.com/?compile=1&debug=0&obfuscate=3";
local config = {};
local compileDone = 0;
local path = "";
local salt = "~>>ˇ~^˘°˛`_CountrySide"
local ignoredResource = {
    ["cr_starter"] = true,
    ['cr_skins'] = true,
    ['cr_maps'] = true, 
    ['cr_models'] = true,
    ['cr_tuningparts'] = true,
    ['cr_vehicles'] = true,
    ['cr_weapons'] = true,
    ['cr_maploader'] = true,
}
local scriptSyntax = "countryscript"
local mapSyntax = "countrymap"
local decompilerFunction = [[
local function decompileData(val)
    local hash = base64Decode(val)
    return hash
end

local decompiledScriptDetails = decompileData(scriptDetails)
pcall(loadstring(decompiledScriptDetails))
]]

local configJSON = loadFile("config.json");
if not configJSON then
    outputDebugString("Failed to open config.json");
    return;
end

config = fromJSON(configJSON);
if not config then
    outputDebugString("Failed to read config.json");
    return;
end

config.only = config.only or {};
config.include = config.include or {};
config.pathEncryptExclude = config.pathEncryptExclude or {};

local timers = {}
local function compileScript(path, res)
    local data = loadFile(path);
    local resource = res
    
    if isTimer(timers[resource]) then
        killTimer(timers[resource])
    end

    fetchRemote(LUAC_URL, function (data, err)
        if not data or err > 0 then
            return;
        end

        saveFile(path, data);
        compileDone = compileDone + 1;
            
        if isTimer(timers[resource]) then
            killTimer(timers[resource])
        end    
        timers[resource] = setTimer(
            function()
                restartResource(getResourceFromName(resource.name));
            end, 1000, 1
        )
    end, data, true);
end

function compileData(val)
    local hash = base64Encode(val)
    return hash
end

function decompileData(val)
    local hash = base64Decode(val)
    return hash
end

function processResource(resource, onlyInsert, ignoreInsert, player)
    local color = exports['cr_core']:getServerColor('yellow', true)
    local white = "#ffffff"
    
    if isElement(player) and player.type == "player" then
        local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
        outputChatBox(syntax .. "Compiling: "..color..tostring(resource.name), player, 255,255,255,true);
    end

    local resourcePath = ":" .. resource.name .. "/";
    local resourceMeta = XML.load(resourcePath .. "meta.xml");

    if not resourceMeta then
        if isElement(player) and player.type == "player" then
            local syntax = exports['cr_core']:getServerSyntax(nil, "error")
            outputChatBox(syntax .. "Failed to open resource '" .. color .. tostring(resource.name) .. white .."'", player, 255,255,255,true);
        end
        return;
    end
    
    local concatScripts = {};

    local buildPath = resourcePath;

    local compiled = false;

    local files = {};
    local _exports = exports
    local exports = {};
    local priorityGroups = {}

    underscore.each(resourceMeta.children, function (child)
    	if child.name == "compiled" then
            if isElement(player) and player.type == "player" then
                local syntax = _exports['cr_core']:getServerSyntax(nil, "error")    
                outputChatBox(syntax..color..resource.name..white.." already compiled!", player, 255,255,255,true);
            end
        	compiled = true;
        	return false;
    	else
	        if child.name == "script" then    
	            local scriptType = child:getAttribute("type") or "server";
	            local scriptPath = child:getAttribute("src");
                    
                if not scriptPath:find("triggerHack") and not scriptPath:find("renderC") then
                    local scriptData = loadFile(resourcePath .. scriptPath);
                    table.insert(concatScripts, {scriptType, scriptPath, scriptData});
                end
            elseif child.name == "file" then
                local scriptPath = child:getAttribute("src");
                table.insert(files, scriptPath);
            elseif child.name == "export" then
                local funcName = child:getAttribute("function");
                local scriptType = child:getAttribute("type");
                table.insert(exports, {funcName, scriptType});       
            elseif child.name == "download_priority_group" then
                local val = child.value

                table.insert(priorityGroups, val)
	        end
        end
    end);

    local scripts = {};

    for i, k in ipairs(concatScripts) do
    	if k[1] == "shared" then
    		table.insert(scripts, 1, k);
    	else
			table.insert(scripts, k);
    	end
    end
    
    if config.enablePathEncrypt then
        if not ignoredResource[resource.name] and not ignoreInsert then
            table.insert(scripts, 1, {"client", "renderC.lua", "".. loadFile("files/renderC.lua") .. "\n\n"});
            --table.insert(scripts, 1, {"shared", "triggerHack.lua", "".. loadFile("files/triggerHack.lua") .. "\n\n"});
        end
    end

    resourceMeta:unload();

    if compiled then return; end

    saveFile(buildPath .. "meta.xml-old", loadFile(buildPath .. "meta.xml")) -- Biztonsági mentés
    
    local buildMeta = XML(buildPath .. "meta.xml", "meta")
    if not buildMeta then
        return;
    end

    if not onlyInsert then
        buildMeta:createChild("compiled").value = "true";
    end
    buildMeta:createChild("oop").value = "true";

    for i, k in ipairs(scripts) do
    	local data = k[3];
    	local type = k[1];
        if #data > 0 then
            local filename = tostring(k[2]) .. ".lua";
            
            local child = buildMeta:createChild("script");

            if not onlyInsert then
                if config.enablePathEncrypt then
                    --filename = sha256(math.random(1, 999999).."" .. tostring(type)) .. ".bin";
                    filename =  tostring(k[2]):gsub(".lua", ""):gsub(".luac", "").. ".countryscript";
                end
            else
                local string1 = tostring(k[2]):gsub(".lua", ""):gsub(".luac", "")
                filename = string1 .. ".lua"
            end

            child:setAttribute("src", filename);
            child:setAttribute("type", type);
            child:setAttribute("cache", tostring(not not config.enableScriptCache));

            if not onlyInsert then
                local save = saveFile(buildPath .. filename, data);

                if save then
                    if config.enableCompilation then
                        compileScript(buildPath .. filename, resource);
                    end
                end
            end
        end
    end

    local child = buildMeta:createChild("min_mta_version");
    local k = getVersion()["mta"] --"1.5.7"
    child:setAttribute("client", k);
    child:setAttribute("server", k);
    
    for i, k in pairs(files) do
        if k and not utf8.find(k, "readme") then
            local child = buildMeta:createChild("file");
            child:setAttribute("src", k);
        end
    end
    
    for i, k in pairs(exports) do
        local child = buildMeta:createChild("export");
        child:setAttribute("function", k[1]);
        child:setAttribute("type", k[2]);
    end

    for k, v in pairs(priorityGroups) do 
        local child = buildMeta:createChild("download_priority_group")
        
        child:setValue(v)
    end

    if not ignoredResource[resource.name] and not ignoreInsert then
        --copyFile("files/triggerHack.lua", buildPath .. "triggerHack.lua");
        copyFile("files/renderC.lua", buildPath .. "renderC.lua");
    end
    if config.enableReadmeFiles then
        copyFile("files/readme.txt", buildPath .. "readme.txt");
        
        local file = fileOpen(buildPath .. "readme.txt");
        if file then
            fileWrite(file, "\n"..resource.name);
            fileFlush(file);
            fileClose(file);
        else
            local syntax = _exports['cr_core']:getServerSyntax(nil, "error")
            if isElement(player) and player.type == "player" then
                outputChatBox(syntax .. color .. resource.name .. white .." readme.txt can't read", player, 255,255,255,true);
            end
        end
        
        local child = buildMeta:createChild("file");
        child:setAttribute("src", "readme.txt");
        child:setAttribute("readme", "true");
    end
    
    buildMeta:saveFile();
    buildMeta:unload();
    local syntax = _exports['cr_core']:getServerSyntax(nil, "success")
    if isElement(player) and player.type == "player" then
        outputChatBox(syntax .. color .. resource.name.. white .." has been compiled and restarted.", player, 255,255,255,true)
    end
    
    if isElement(player) and player.type == "player" then
        local time = _exports['cr_core']:getTime() .. " "
        local aName = _exports['cr_admin']:getAdminName(player, true)
        local syntax = _exports['cr_core']:getServerSyntax("Builder", "warning")
        local color = _exports['cr_core']:getServerColor('yellow', true)
        local white = "#ffffff"
        _exports['cr_core']:sendMessageToAdmin(player, syntax ..""..color..aName..white.." has been compiled and restarted resource: "..color..tostring(resource.name), 10)
        _exports['cr_logs']:addLog(player, "Developer", "build", time .. aName.." has been compiled and restarted resource: "..tostring(resource.name))
    end    
    
    if onlyInsert then
        restartResource(getResourceFromName(resource.name));
    end
end

function unbuildResource(resource, player)
    local color = exports['cr_core']:getServerColor('yellow', true)
    local white = "#ffffff"
    
    if isElement(player) and player.type == "player" then
        local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
        outputChatBox(syntax .. "Uncompiling: ".. color .. tostring(resource.name), player, 255,255,255,true);
    end

    local resourcePath = ":" .. resource.name .. "/";
    local resourceMeta = XML.load(resourcePath .. "meta.xml");

    if not resourceMeta then
        if isElement(player) and player.type == "player" then
            local syntax = exports['cr_core']:getServerSyntax(nil, "error")
            outputChatBox(syntax .. "Failed to open resource '" .. color .. tostring(resource.name) .. white .. "'", player, 255,255,255,true)
        end
        return;
    end

    local notcompiled = true;

    underscore.each(resourceMeta.children, function (child)
    	if child.name == "compiled" then
    		notcompiled = false;
    		child:destroy();
    	end

    	if not notcompiled then
    		if child and child.name == "script" then
	            local scriptType = child:getAttribute("type") or "server";
	            local scriptPath = child:getAttribute("src");

                local srcPath = resourcePath..scriptPath
                srcPath = srcPath:gsub(".countryscript", "")   
                srcPath = srcPath:gsub(".countrymap", "")   
                if srcPath:find("renderC") then
                    child:destroy();
	        		fileDelete(resourcePath..scriptPath);    
	        	elseif fileExists(srcPath..".lua") then
	        		child:setAttribute("src", scriptPath:gsub(".countryscript", ".lua"));
	        		fileDelete(resourcePath..scriptPath);
	        	elseif fileExists(srcPath) then
                    child:setAttribute("src", scriptPath:gsub(".countrymap", ""));
                    
                    fileDelete(resourcePath..scriptPath);
                else
	        		child:destroy();
	        		fileDelete(resourcePath..scriptPath);
	        	end
	        elseif child and child.name == "file" then
	        	if child:getAttribute("readme") then
	        		local scriptPath = child:getAttribute("src");
	        		fileDelete(resourcePath..scriptPath);
	        		child:destroy();
	        	end
	        end
    	end
    end);

    if notcompiled then
        if isElement(player) and player.type == "player" then
            local syntax = exports['cr_core']:getServerSyntax(nil, "error")
            outputChatBox(syntax..color..resource.name..white.." not compiled.", player, 255,255,255,true);
        end
    	return false;
    end
    
    resourceMeta:saveFile();
    resourceMeta:unload();
    restartResource(getResourceFromName(resource.name));
    if isElement(player) and player.type == "player" then
        local syntax = exports['cr_core']:getServerSyntax(nil, "success")
        outputChatBox(syntax..color..resource.name..white.." has been uncompiled and restarted.", player, 255,255,255,true);

        local time = exports['cr_core']:getTime() .. " "
        local aName = exports['cr_admin']:getAdminName(player, true)
        local syntax = exports['cr_core']:getServerSyntax("Builder", "warning")
        local color = exports['cr_core']:getServerColor('yellow', true)
        local white = "#ffffff"
        exports['cr_core']:sendMessageToAdmin(player, syntax ..""..color..aName..white.." has been uncompiled and restarted resource: "..color..tostring(resource.name), 10)
        exports['cr_logs']:addLog(player, "Developer", "unbuild", time .. aName.." has been uncompiled and restarted resource: "..tostring(resource.name))
    end    

    return true;
end

function rebuildResource(resource, ignoreInsert, player)
    local color = exports['cr_core']:getServerColor('yellow', true)
    local white = "#ffffff"
    
    local resourcePath = ":" .. resource.name .. "/";
    local resourceMeta = XML.load(resourcePath .. "meta.xml");

    if not resourceMeta then
        return;
    end

    local notcompiled = true;

    underscore.each(resourceMeta.children, function (child)
    	if child.name == "compiled" then
    		notcompiled = false;
    		child:destroy();
    	end

    	if not notcompiled then
    		if child and child.name == "script" then
	            local scriptType = child:getAttribute("type") or "server";
	            local scriptPath = child:getAttribute("src");

                local srcPath = resourcePath..scriptPath
                srcPath = srcPath:gsub(".countryscript", "")   
                srcPath = srcPath:gsub(".countrymap", "")   
                if srcPath:find("renderC") then
                    child:destroy();
	        		fileDelete(resourcePath..scriptPath);    
	        	elseif fileExists(srcPath..".lua") then
	        		child:setAttribute("src", scriptPath:gsub(".countryscript", ".lua"));
	        		fileDelete(resourcePath..scriptPath);
	        	elseif fileExists(srcPath) then
                    child:setAttribute("src", scriptPath:gsub(".countrymap", ""));
                    
                    fileDelete(resourcePath..scriptPath);
                else
	        		child:destroy();
	        		fileDelete(resourcePath..scriptPath);
	        	end
	        elseif child and child.name == "file" then
	        	if child:getAttribute("readme") then
	        		local scriptPath = child:getAttribute("src");
	        		fileDelete(resourcePath..scriptPath);
	        		child:destroy();
	        	end
	        end
    	end
    end);

    if notcompiled then 
        return
    end 

    resourceMeta:saveFile();
    
    local concatScripts = {};

    local buildPath = resourcePath;

    local compiled = false;

    local files = {};
    local _exports = exports
    local exports = {};
    local priorityGroups = {}

    underscore.each(resourceMeta.children, function (child)
    	if child.name == "compiled" then
        	compiled = true;
        	return false;
    	else
	        if child.name == "script" then    
	            local scriptType = child:getAttribute("type") or "server";
	            local scriptPath = child:getAttribute("src");
                    
                if not scriptPath:find("triggerHack") and not scriptPath:find("renderC") then
                    local scriptData = loadFile(resourcePath .. scriptPath);
                    table.insert(concatScripts, {scriptType, scriptPath, scriptData});
                end
            elseif child.name == "file" then
                local scriptPath = child:getAttribute("src");
                table.insert(files, scriptPath);
            elseif child.name == "export" then
                local funcName = child:getAttribute("function");
                local scriptType = child:getAttribute("type");
                table.insert(exports, {funcName, scriptType});    
            elseif child.name == "download_priority_group" then
                local val = child.value

                table.insert(priorityGroups, val)
	        end
        end
    end);

    local scripts = {};

    for i, k in ipairs(concatScripts) do
    	if k[1] == "shared" then
    		table.insert(scripts, 1, k);
    	else
			table.insert(scripts, k);
    	end
    end
    
    if config.enablePathEncrypt then
        if not ignoredResource[resource.name] and not ignoreInsert then
            table.insert(scripts, 1, {"client", "renderC.lua", "".. loadFile("files/renderC.lua") .. "\n\n"});
            --table.insert(scripts, 1, {"shared", "triggerHack.lua", "".. loadFile("files/triggerHack.lua") .. "\n\n"});
        end
    end

    resourceMeta:unload();

    if compiled then return; end

    saveFile(buildPath .. "meta.xml-old", loadFile(buildPath .. "meta.xml")) -- Biztonsági mentés
    
    local buildMeta = XML(buildPath .. "meta.xml", "meta")
    if not buildMeta then
        return;
    end

    buildMeta:createChild("compiled").value = "true";
    buildMeta:createChild("oop").value = "true";

    for i, k in ipairs(scripts) do
    	local data = k[3];
    	local type = k[1];
        if #data > 0 then
            local filename = tostring(k[2]) .. ".lua";
            
            local child = buildMeta:createChild("script");

            if config.enablePathEncrypt then
                --filename = sha256(math.random(1, 999999).."" .. tostring(type)) .. ".bin";
                filename =  tostring(k[2]):gsub(".lua", ""):gsub(".luac", "").. ".countryscript";
            end

            child:setAttribute("src", filename);
            child:setAttribute("type", type);
            child:setAttribute("cache", tostring(not not config.enableScriptCache));

            local save = saveFile(buildPath .. filename, data);

            if save then
                if config.enableCompilation then
                    compileScript(buildPath .. filename, resource);
                end
            end
        end
    end

    local child = buildMeta:createChild("min_mta_version");
    local k = getVersion()["mta"] --"1.5.7"
    child:setAttribute("client", k);
    child:setAttribute("server", k);
    
    for i, k in pairs(files) do
        if k and not utf8.find(k, "readme") then
            local child = buildMeta:createChild("file");
            child:setAttribute("src", k);
        end
    end
    
    for i, k in pairs(exports) do
        local child = buildMeta:createChild("export");
        child:setAttribute("function", k[1]);
        child:setAttribute("type", k[2]);
    end

    for k, v in pairs(priorityGroups) do 
        local child = buildMeta:createChild("download_priority_group")

        child:setValue(v)
    end

    if not ignoredResource[resource.name] and not ignoreInsert then
        --copyFile("files/triggerHack.lua", buildPath .. "triggerHack.lua");
        copyFile("files/renderC.lua", buildPath .. "renderC.lua");
    end
    if config.enableReadmeFiles then
        copyFile("files/readme.txt", buildPath .. "readme.txt");
        
        local file = fileOpen(buildPath .. "readme.txt");
        if file then
            fileWrite(file, "\n"..resource.name);
            fileFlush(file);
            fileClose(file);
        end
        
        local child = buildMeta:createChild("file");
        child:setAttribute("src", "readme.txt");
        child:setAttribute("readme", "true");
    end
    
    buildMeta:saveFile();
    buildMeta:unload();
end

local val = false
addCommandHandler("build", function(player, cmd, name, onlyInsert, ignoreInsert)
    if val or exports['cr_core']:getPlayerDeveloper(player) then
        if tonumber(onlyInsert) and tonumber(onlyInsert) == 1 then
            onlyInsert = true
        else
            onlyInsert = false
        end

        if tonumber(ignoreInsert) and tonumber(ignoreInsert) == 1 then
            ignoreInsert = true
        else
            ignoreInsert = false
        end

        if not name then
            outputChatBox(exports['cr_core']:getServerSyntax(nil, "warning") .. "/"..cmd.." [resName (all)] [onlyInsert 0/1] [ignoreInsert 0/1]", player, 255, 0, 0, true);    
        else
            local resources = getResources();
                
            name = tostring(name);
                
            if name == "all" then
                resources = underscore.filter(resources, function (resource)
                    if utf8.sub(resource.name, 1, 3) == "cr_" and resource.name ~= "cr_builder" and not resource.name:find('builder') and resource.name ~= "cr_modpanel" and resource.name ~= "cr_maps" and resource.name ~= "cr_starter" and resource.name ~= "cr_protect" then
                        return resource.name;
                    end
                end)
            else
                if getResourceFromName(name) then
                    resources = underscore.filter(resources, function (resource)
                        if resource.name == name then
                            path = ":"..resource.name.."/";
                            return resource.name;
                        end
                    end)
                else
                	return;
                end
            end
                
            local color = exports['cr_core']:getServerColor('yellow', true)
            local white = "#ffffff"                
            local syntax = exports['cr_core']:getServerSyntax(nil, "info")
            outputChatBox(syntax.."Found " .. color .. #resources .. white .. " resource(s) to build", player, 255,255,255,true);    
            --underscore.each(resources, processResource);
            if isTimer(globalTimer) then killTimer(globalTimer) end
            --iprint(resources)
            local num = 0
            num = num + 1
            local res = resources[num]
            if res then
                processResource(res, onlyInsert, ignoreInsert, player)
            else
                return
            end        
            globalTimer = setTimer(
                function()
                    --procces  
                    num = num + 1
                    local res = resources[num]
                    if res then
                        processResource(res, onlyInsert, ignoreInsert, player)
                    else
                        if isTimer(globalTimer) then
                            killTimer(globalTimer)
                        end
                    end    
                end, 500, 0
            )
                --[[
            if config.enableCompilation then
                local syntax = exports['cr_core']:getServerSyntax(nil, "info")
    	        outputChatBox(syntax.."Compiling " .. color .. compileDone .. white .. " scripts...", player, 255,255,255,true);
            end]]
        end
    end
end);

addCommandHandler("unbuild", function(player, cmd, res)
	if val or exports['cr_core']:getPlayerDeveloper(player) then
		if not res then
			outputChatBox(exports['cr_core']:getServerSyntax(nil, "warning") .. "/"..cmd.." [resName (all)]", player, 255, 0, 0, true);    
		else
			local resources = getResources();
			name = tostring(res);

			if name == "all" then
                resources = underscore.filter(resources, function (resource)
                    if utf8.sub(resource.name, 1, 3) == "cr_" and resource.name ~= "cr_builder" and not resource.name:find('builder') and resource.name ~= "cr_modpanel" and resource.name ~= "cr_maps" and resource.name ~= "cr_starter" and resource.name ~= "cr_protect" then
                        return resource.name;
                    end
                end)
            else
                if getResourceFromName(name) then
                    resources = underscore.filter(resources, function (resource)
                        if resource.name == name then
                            return resource.name;
                        end
                    end)
                else
                	return;
                end
            end

            local syntax = exports['cr_core']:getServerSyntax(nil, "info")
            local color = exports['cr_core']:getServerColor('yellow', true)
            local white = "#ffffff"         
            outputChatBox(syntax.."Found " .. color .. #resources .. white .. " resource(s) to unbuild", player, 255,255,255,true);
                
            if isTimer(globalTimer) then killTimer(globalTimer) end
            --iprint(resources)
            local num = 0
            num = num + 1
            local res = resources[num]
            if res then
                unbuildResource(res, player)
            else
                return
            end        
            globalTimer = setTimer(
                function()
                    --procces  
                    num = num + 1
                    local res = resources[num]
                    if res then
                        unbuildResource(res, player)
                    else
                        if isTimer(globalTimer) then
                            killTimer(globalTimer)
                        end
                    end    
                end, 500, 0
            )    
            --underscore.each(resources, unbuildResource);
		end
	end
end);

addCommandHandler("rebuild", function(player, cmd, res)
	if exports['cr_core']:getPlayerDeveloper(player)  then
        if tonumber(ignoreInsert) and tonumber(ignoreInsert) == 1 then
            ignoreInsert = true
        else
            ignoreInsert = false
        end

		if not res then
			outputChatBox(exports['cr_core']:getServerSyntax(nil, "warning") .. "/"..cmd.." [resName] [ignoreInsert 0/1]", player, 255, 0, 0, true);    
		else
			local resources = getResources();
			name = tostring(res);

            if getResourceFromName(name) then
                resources = underscore.filter(resources, function (resource)
                    if resource.name == name then
                        return resource.name;
                    end
                end)
            else
                return;
            end

            local syntax = exports['cr_core']:getServerSyntax(nil, "info")
            local color = exports['cr_core']:getServerColor('yellow', true)
            local white = "#ffffff"         
            outputChatBox(syntax.."Found " .. color .. #resources .. white .. " resource(s) to rebuild", player, 255,255,255,true);
                
            if isTimer(globalTimer) then killTimer(globalTimer) end
            --iprint(resources)
            local num = 0
            num = num + 1
            local res = resources[num]
            if res then
                rebuildResource(res, ignoreInsert, player)
            else
                return
            end        
            globalTimer = setTimer(
                function()
                    --procces  
                    num = num + 1
                    local res = resources[num]
                    if res then
                        rebuildResource(res, ignoreInsert, player)
                    else
                        if isTimer(globalTimer) then
                            killTimer(globalTimer)
                        end
                    end    
                end, 500, 0
            )    
            --underscore.each(resources, unbuildResource);
		end
	end
end);