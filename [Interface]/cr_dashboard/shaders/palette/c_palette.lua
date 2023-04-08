--
-- c_palette.lua
--

local screenTex, chromaticShader, paletteShader, chosenPalette, lumTemp, effectParts, bAllValid
local paletteTable = {}

local Settings = {}
Settings.var = {}

---------------------------------
-- Settings for effect
---------------------------------
local function setEffectVariables()
    local v = Settings.var
    -- Palette
    v.PaletteEnabled = true
    v.lumLerp = 0.96 -- the closer to 1 the slower the transition
-- Chromatic Abberation
    v.ChromaticEnabled = paletteTable.chromaticEnabled
    v.ChromaticAmount = 0.009
    v.LensSize = 0.515
    v.LensDistortion = 0.05
    v.LensDistortionCubic = 0.05
end

----------------------------------------------------------------
-- post process items
----------------------------------------------------------------
local function applyResize( src, tx, ty )
	if not src then return nil end
	local newRT = RTPool3.GetUnused(tx, ty)
	if not newRT then return nil end
	dxSetRenderTarget( newRT )
	dxDrawImage( 0,  0, tx, ty, src )
	return newRT
end

local function applyDownsample( src )
	if not src then return nil end
	local mx,my = dxGetMaterialSize( src )
	mx = mx / 2
	my = my / 2
	local newRT = RTPool3.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT )
	dxDrawImage( 0, 0, mx, my, src )
	return newRT
end

local function applyPalette( src, lumPixel )
	if not src then return nil end
	local mx,my = dxGetMaterialSize( src )
	local newRT = RTPool3.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( paletteShader, "sBaseTexture", src )
	dxSetShaderValue( paletteShader, "sLumPixel", lumPixel )
	dxDrawImage( 0, 0, mx,my, paletteShader )
	return newRT
end

local function countMedianPixelColor(daTable)
	local sum_r,sum_g,sum_b=0,0,0
	for _,tValue in ipairs(daTable) do
	local r,g,b,a = dxGetPixelColor( tValue, 0, 0 )
		sum_r=sum_r+r
		sum_g=sum_g+g
		sum_b=sum_b+b
	end
	return {(sum_r/#daTable)/255,(sum_g/#daTable)/255,(sum_b/#daTable)/255}
end

local lastPix={1,1,1}
local lastTickCount=0
local lumSamples = {}
local currLumSample=0
local function countLuminanceForPalette(luminance,lumPause,maxLumSamples)
	if getTickCount() > lastTickCount then
		local mx,my = dxGetMaterialSize( luminance );
		local size = 1
		while ( size < mx / 2 or size < my / 2 ) do
			size = size * 2
		end
		luminance = applyResize( luminance, size, size )
		while ( size > 1 ) do
			size = size / 2
			luminance = applyDownsample( luminance, 2 )
		end
		if (currLumSample>maxLumSamples) then 
			currLumSample=0 
		end
		lumSamples[currLumSample]=dxGetTexturePixels(luminance)
		local pix=countMedianPixelColor(lumSamples)
		currLumSample=currLumSample+1
		lastPix=pix
		lastTickCount=getTickCount()+lumPause
		return pix
	else
		return lastPix
	end
end

----------------------------------------------------------------
-- Render
----------------------------------------------------------------
local function drawnPalette()
	if not bAllValid or not Settings.var then return end
	local v = Settings.var

	RTPool3.frameStart()

	dxUpdateScreenSource( screenTex, true )
	dxUpdateScreenSource( lumTemp, true )
	local current = screenTex
	
	if v.PaletteEnabled then
		local lumPixel = countLuminanceForPalette(lumTemp, v.lumLerp, 50)
		current = applyPalette( current, lumPixel )
	end
	dxSetRenderTarget()
	if current then 
		dxDrawImage( 0, 0, scx, scy, current, 0, 0, 0, tocolor(255,255,255,255) ) 
	end
end

local isRender
--------------------------------
-- Switch effect on
--------------------------------
function enablePalette(id)
	if paletteTable.palEffectEnabled then 
		disablePalette()
	end

	-- Input texture
    screenTex = dxCreateScreenSource( scx, scy )

	-- Shaders
	chromaticShader = dxCreateShader( "shaders/palette/fx/chromatic.fx" )
	paletteShader = dxCreateShader( "shaders/palette/fx/palette.fx" )
	chosenPalette = dxCreateTexture("shaders/palette/palette/enbpalette"..id..".png")
	
	-- A table to store the results of scene luminance calculations
	lumTemp = dxCreateScreenSource( 512, 512 )

	-- Get list of all elements used
	effectParts = {
						screenTex,
						paletteShader,
						chromaticShader,
						chosenPalette,
						lumTemp
					}

	-- Check list of all elements used
	bAllValid = true
	for _,part in ipairs(effectParts) do
		bAllValid = part and bAllValid
	end

	setEffectVariables ()
	paletteTable.palEffectEnabled = true

	if not bAllValid then
		disablePalette()
	else
		dxSetShaderValue( paletteShader, "sPaletteTexture", chosenPalette )
	end

	if not isRender then 
		isRender = true 
		addEventHandler("onClientHUDRender", root, drawnPalette, true, "low-10000")
	end 
end


--------------------------------
-- Switch effect off
--------------------------------
function disablePalette()
	if not paletteTable.palEffectEnabled then 
		return 
	end

	if isRender then 
		isRender = false
		removeEventHandler("onClientHUDRender", root, drawnPalette)
	end 

	-- Destroy all shaders
	for _,part in ipairs(effectParts) do
		if part then
			if isElement(part) then
				destroyElement( part )
			end
		end
	end
	effectParts = {}
	bAllValid = false
	RTPool3.clear()

	-- Flag effect as stopped
	paletteTable.palEffectEnabled = false
end