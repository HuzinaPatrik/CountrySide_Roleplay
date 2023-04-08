local exportPath = ":cr_maps/";
local buildPath = ":cr_maploader/";

local mapdatas = {
	["create"] = {"posX", "posY", "posZ", "rotX", "rotY", "rotZ", "alpha", "model", "scale", "interior", "dimension", "collisions", "breakable", "doublesided"},
	["remove"] = {"posX", "posY", "posZ", "interior", "dimension", "radius", "model", "lodModel"},
};

addCommandHandler("compilemap", function(thePlayer)
    if not exports['cr_core']:getPlayerDeveloper(thePlayer) then return end
	compileMap();
end);

function compileMap()
	local resource = getResourceFromName("cr_maploader");
	if resource then
		local state = exports.cr_builder:unbuildResource(resource);
	end

	local resourceMeta = XML.load(exportPath .. "meta.xml");

	local datas = {};

	underscore.each(resourceMeta.children, function (child)
    	if child.name ~= "file" then
        	return;
        end

		local filePath = child:getAttribute("src");     
        if filePath:find(".map") then

            local xml = XML.load(exportPath .. filePath);
        	for i, k in pairs(xml:getChildren()) do
        		local xmlname = string.lower(k:getName());
        		if xmlname == "object" then
        			local temp = "	{\"create\", ";
        			for _, data in pairs(mapdatas["create"]) do
        				if xmlNodeGetAttribute(k, data) then
        					if temp == "	{\"create\", " then
        						temp = temp..""..data.." = \""..xmlNodeGetAttribute(k, data).."\"";
        					else
        						temp = temp..", "..data.." = \""..xmlNodeGetAttribute(k, data).."\"";
        					end
        				end
        			end
        			temp = temp.."},"
 
        			table.insert(datas, {"create", filePath, temp});
        		elseif xmlname == "removeworldobject" then
        			local temp = "	{\"remove\", ";
        			for _, data in pairs(mapdatas["remove"]) do
        				if xmlNodeGetAttribute(k, data) then
        					if temp == "	{\"create\", " or temp == "	{\"remove\", " then
        						temp = temp..""..data.." = \""..xmlNodeGetAttribute(k, data).."\"";
        					else
        						temp = temp..", "..data.." = \""..xmlNodeGetAttribute(k, data).."\"";
        					end
        				end
        			end
        			temp = temp.."},"

        			table.insert(datas, {"remove", filePath, temp});
        		end
        	end
        end
    end);

    local buildMeta = XML(buildPath .. "meta.xml", "meta")
    if not buildMeta then
    	outputDebugString("ERROR: buildMeta")
        return;
    end

    buildMeta:createChild("oop").value = "true";
    
    local string = "mapdatas = {\n	[\"create\"] = {\"posX\", \"posY\", \"posZ\", \"rotX\", \"rotY\", \"rotZ\", \"alpha\", \"model\", \"scale\", \"interior\", \"dimension\", \"collisions\", \"breakable\", \"doublesided\"},\n	[\"remove\"] = {\"posX\", \"posY\", \"posZ\", \"rotX\", \"rotY\", \"rotZ\", \"interior\", \"dimension\", \"radius\", \"model\", \"lodmodel\"},\n};\n\n";
    string = string.."mapsdatas = {\n";

    for i, k in ipairs(datas) do
    	--if i < 10 then
			string = string..""..k[3].."\n";
		--end
    end

    string = string.."}"

    saveFile(buildPath.."builtmap.lua", string);

    copyFile("files/loader.lua", buildPath .. "loader.lua");
    copyFile("files/loaderC.lua", buildPath .. "loaderC.lua");

    local child = buildMeta:createChild("script");
    child:setAttribute("src", "builtmap.lua");
    child:setAttribute("download", "false");
    child:setAttribute("type", "server");

	local child = buildMeta:createChild("script");
    child:setAttribute("src", "loader.lua");
    child:setAttribute("type", "server");
    
    local child = buildMeta:createChild("script");
    child:setAttribute("src", "loaderC.lua");
    child:setAttribute("type", "client");

    buildMeta:saveFile();
    buildMeta:unload();
    outputDebugString("MAPBUILDER: Successfully created "..#datas.." lines. Compiling...");
    exports.cr_builder:processResource(resource);
end

function print(...)
    local args = {...};
    local output = "";

    for i, v in ipairs(args) do
        output = output .. tostring(v);
        if i < #args then
            output = output .. "\t";
        end
    end

    outputDebugString(output);
    outputChatBox(output);
end

_xmlNodeGetAttribute = xmlNodeGetAttribute
function xmlNodeGetAttribute(...)
    local val = _xmlNodeGetAttribute(...)
    
    if tonumber(val) then
        return tonumber(val)
    else
        return val
    end
end

function arrayToString(array)
    local str = "{";
    for i, v in ipairs(array) do
        if type(v) == "number" or type(v) == "boolean" then
            str = str .. tostring(v);
        else
            str = str .. "\"" .. tostring(v) .. "\"";
        end
        if i < #array then
            str = str .. ",";
        end
    end
    return str .. "}";
end

function defaultValue(value, default)
    if value == nil then
        return default;
    else
        return value;
    end
end

function loadFile(path, count)
    local file = fileOpen(path);
    if not file then
        return false;
    end

    if not count then
        count = fileGetSize(file);
    end

    local data = fileRead(file, count);
    fileClose(file);

    return data;
end

function saveFile(path, data)
    if not path then
        return false;
    end

    if fileExists(path) then
        fileDelete(path);
    end

    local file = fileCreate(path);
    fileWrite(file, data);
    fileClose(file);

    return true;
end

function copyFile(path1, path2)
    return fileCopy(path1, path2, true);
end