local screenWidth, screenHeight = guiGetScreenSize()
local blurShaders = {}
local indexByName = {}
local myScreenSource = dxCreateScreenSource(screenWidth, screenHeight)

function createBlur(name, strenght, extra)
    if indexByName[name] then
        removeBlur(name)
    end
    local x,y,w,h
    if extra and type(extra) == "table" and #extra >= 1 then
        local x,y,w,h = unpack(extra)
        table.insert(blurShaders, {s_name = name, shader = dxCreateShader("shaders/BlurShader.fx"), strenght_s = strenght, x = x, y = y, w = w, h = h})
        indexByName[name] = #blurShaders
    else
        table.insert(blurShaders, {s_name = name, shader = dxCreateShader("shaders/BlurShader.fx"), strenght_s = strenght})
        indexByName[name] = #blurShaders
    end
	--if strenght > 15 then strenght = 15 end
    
    if #blurShaders >= 1 then
        if not isRenderingShader then
            isRenderingShader = true
            --addEventHandler("onClientRender", root, renderBlur, true, "low-5")
            createRender("renderBlur", renderBlur)
        end
    end
end

function updateBlurPosition(name, pos)
    --outputChatBox(name)
    if indexByName[name] then
        local k = indexByName[name]
        local x,y,w,h = unpack(pos)
        blurShaders[k].x = x
        blurShaders[k].y = y
        blurShaders[k].w = w
        blurShaders[k].h = h
    end
end

function updateBlurStrength(name, num)
    if indexByName[name] then
        local k = indexByName[name]
        blurShaders[k].strenght_s = num
    end
end

function removeBlur(name)
	for k, v in ipairs(blurShaders) do
		if v.s_name == name then
            if isElement(v.shader) then
                destroyElement(v.shader)
            end
            indexByName[name] = nil
			table.remove(blurShaders, k)
            collectgarbage("collect")
            
            if #blurShaders <= 0 then
                if isRenderingShader then
                    isRenderingShader = false
                    --removeEventHandler("onClientRender", root, renderBlur)
                    destroyRender("renderBlur")
                end
            end
			return
		end
	end
end

function renderBlur()
    for k, v in ipairs(blurShaders) do
        if v.shader then
            dxUpdateScreenSource(myScreenSource)

            dxSetShaderValue(v.shader, "ScreenSource", myScreenSource);
            dxSetShaderValue(v.shader, "BlurStrength", v.strenght_s);
            dxSetShaderValue(v.shader, "UVSize", screenWidth, screenHeight);

            local x = v.x or 0
            local y = v.y or 0
            local w = v.w or screenWidth
            local h = v.h or screenHeight
            dxDrawImageSection(x, y, w, h, x, y, w, h, v.shader)
        end
    end
end