local screenWidth, screenHeight = guiGetScreenSize()
local screenSource	= dxCreateScreenSource(screenWidth, screenHeight)
local darkness		= 0.5
local radius		= 5

function enableVignette()
	vignetteShader = dxCreateShader("shaders/vignette/vignette.fx")
	addEventHandler("onClientPreRender", root, drawnVignette)
end 

function disableVignette()
	if isElement(vignetteShader) then 
		destroyElement(vignetteShader)
	end 
	removeEventHandler("onClientPreRender", root, drawnVignette)
end 

function drawnVignette()
	if vignetteShader then
		dxUpdateScreenSource(screenSource)
		dxSetShaderValue(vignetteShader, "ScreenSource", screenSource);
		dxSetShaderValue(vignetteShader, "radius", radius);
		dxSetShaderValue(vignetteShader, "darkness", darkness);
		dxDrawImage(0, 0, screenWidth, screenHeight, vignetteShader)
	end
end