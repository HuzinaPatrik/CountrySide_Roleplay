local screenX, screenY = guiGetScreenSize()
local screenSource = dxCreateScreenSource(screenX, screenY)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
		blackWhiteShader, blackWhiteTec = dxCreateShader("shaders/blackwhite/fx/blackwhite.fx")
    end
)

function startBlackWhite()
    addEventHandler("onClientPreRender", root, renderBlackWhite)
end 

function stopBlackWhite()
    removeEventHandler("onClientPreRender", root, renderBlackWhite)
end 

function renderBlackWhite()
    if (blackWhiteShader) then
        dxUpdateScreenSource(screenSource)     
        dxSetShaderValue(blackWhiteShader, "screenSource", screenSource)
        dxDrawImage(0, 0, screenX, screenY, blackWhiteShader)
    end
end