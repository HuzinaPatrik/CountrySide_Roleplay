-- main variables
local screenWidth, screenHeight = guiGetScreenSize()

-- settings
local pencilStrength = 2

-- functional variables
local myScreenSource = dxCreateScreenSource(screenWidth, screenHeight)

function enablePencilShader()
    pencilShader, pencilTec = dxCreateShader("shaders/pencil/shaders/PencilShader.fx")
    addEventHandler("onClientPreRender", root, drawnPencilShader)
end

function disablePencilShader()
	if (pencilShader) then
		destroyElement(pencilShader)
        pencilShader = nil
        removeEventHandler("onClientPreRender", root, drawnPencilShader)
	end
end

function drawnPencilShader()
    if (pencilShader) then
        dxUpdateScreenSource(myScreenSource)
        
        dxSetShaderValue(pencilShader, "ScreenSource", myScreenSource);
        dxSetShaderValue(pencilShader, "pencilStrength", pencilStrength);
		dxSetShaderValue(pencilShader, "UVSize", screenWidth, screenHeight);

        dxDrawImage(0, 0, screenWidth, screenHeight, pencilShader)
    end
end