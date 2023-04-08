function jsonGET(file, private, defData)
	if private then
		file = "@JSON_FILES/"..file:gsub(".json", ""):gsub("@", "")..".json"
	else
		file = "JSON_FILES/"..file:gsub(".json", ""):gsub("@", "")..".json"
	end
	local fileHandle
	local jsonDATA = {}
	if not fileExists(file) then
		return defData or {}
	else
		fileHandle = fileOpen(file)
	end
	if fileHandle then
		local buffer
		local allBuffer = ""
		while not fileIsEOF(fileHandle) do
			buffer = fileRead(fileHandle, 500)
			allBuffer = allBuffer..buffer
		end
		jsonDATA = fromJSON(allBuffer)
		fileClose(fileHandle)
	end

	return jsonDATA or {}
end

function jsonSAVE(file, data, private)
	if private then
		file = "@JSON_FILES/"..file:gsub(".json", ""):gsub("@", "")..".json"
	else
		file = "JSON_FILES/"..file:gsub(".json", ""):gsub("@", "")..".json"
	end
	if fileExists(file) then
		fileDelete(file)
	end
	local fileHandle = fileCreate(file)
	fileWrite(fileHandle, toJSON(data or {}))
	fileFlush(fileHandle)
	fileClose(fileHandle)
	return true
end