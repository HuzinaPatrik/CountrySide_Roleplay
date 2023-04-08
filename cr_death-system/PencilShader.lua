local screenWidth, screenHeight = guiGetScreenSize()
local pencilStrength = 2
local myScreenSource = dxCreateScreenSource(screenWidth, screenHeight)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        if getVersion().sortable < "1.3.1" then
            return
        else
            pencilShader, pencilTec = dxCreateShader("shaders/PencilShader.fx")
        end
    end
)

function startWhiteShader()
    addEventHandler("onClientPreRender", root, drawnWhiteShader, true, "low-5")
end

function stopWhiteShader()
    removeEventHandler("onClientPreRender", root, drawnWhiteShader)
end

function drawnWhiteShader()
    if (pencilShader) then
        dxUpdateScreenSource(myScreenSource)
        
        dxSetShaderValue(pencilShader, "ScreenSource", myScreenSource);
        dxSetShaderValue(pencilShader, "pencilStrength", pencilStrength);
		dxSetShaderValue(pencilShader, "UVSize", screenWidth, screenHeight);

        dxDrawImage(0, 0, screenWidth, screenHeight, pencilShader)
    end
end

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        if (pencilShader) then
            destroyElement(pencilShader)
            pencilShader = nil
        end
    end
)