--
-- c_contrast.lua
--

local bEffectEnabled, myScreenSourceFull, contrastShader, bloomCombineShader, bloomExtractShader, blurHShader, blurVShader, modulationShader, lumTarget, nextLumSampleTime, textureVignette, effectParts, bAllValid, bEffectEnabled

local Settings = {}
Settings.var = {}

---------------------------------
-- Settings for effect
---------------------------------
local function setEffectType1()
    local v = Settings.var
    v.Brightness=0.32
    v.Contrast=2.24

    v.ExtractThreshold=0.72

    v.DownSampleSteps=2
    v.GBlurHBloom=1.68
    v.GBlurVBloom=1.52

    v.BloomIntensity=0.94
    v.BloomSaturation=1.66
    v.BaseIntensity=0.94
    v.BaseSaturation=-0.38

    v.LumSpeed=51
    v.LumChangeAlpha=27

    v.MultAmount=0.46
    v.Mult=0.70
    v.Add=0.10
    v.ModExtraFrom=0.11
    v.ModExtraTo=0.58
    v.ModExtraMult=4

    v.MulBlend=0.82
    v.BloomBlend=0.25

    v.Vignette=0.47

	-- Debugging
    v.PreviewEnable=0
    v.PreviewPosY=0
    v.PreviewPosX=100
    v.PreviewSize=70
end

----------------------------------------------------------------
-- post process items
----------------------------------------------------------------

local function applyBloomCombine( src, base, sBloomIntensity, sBloomSaturation, sBaseIntensity, sBaseSaturation )
	if not src or not base then return nil end
	local mx,my = dxGetMaterialSize( base )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( bloomCombineShader, "sBloomTexture", src )
	dxSetShaderValue( bloomCombineShader, "sBaseTexture", base )
	dxSetShaderValue( bloomCombineShader, "sBloomIntensity", sBloomIntensity )
	dxSetShaderValue( bloomCombineShader, "sBloomSaturation", sBloomSaturation )
	dxSetShaderValue( bloomCombineShader, "sBaseIntensity", sBaseIntensity )
	dxSetShaderValue( bloomCombineShader, "sBaseSaturation", sBaseSaturation )
	dxDrawImage( 0, 0, mx,my, bloomCombineShader )
	DebugResults.addItem( newRT, "BloomCombine" )
	return newRT
end

local function applyBloomExtract( src, sceneLuminance, sBloomThreshold )
	if not src or not sceneLuminance then return nil end
	local mx,my = dxGetMaterialSize( src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( bloomExtractShader, "sBaseTexture", src )
	dxSetShaderValue( bloomExtractShader, "sBloomThreshold", sBloomThreshold )
	dxSetShaderValue( bloomExtractShader, "sLumTexture", sceneLuminance )
	dxDrawImage( 0, 0, mx,my, bloomExtractShader )
	DebugResults.addItem( newRT, "BloomExtract" )
	return newRT
end

local function applyContrast( src, Brightness, Contrast  )
	if not src then return nil end
	local mx,my = dxGetMaterialSize( src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT )
	dxSetShaderValue( contrastShader, "sBaseTexture", src )
	dxSetShaderValue( contrastShader, "sBrightness", Brightness )
	dxSetShaderValue( contrastShader, "sContrast", Contrast )
	dxDrawImage( 0, 0, mx, my, contrastShader )
	DebugResults.addItem( newRT, "Contrast" )
	return newRT
end

local function applyModulation( src, sceneLuminance, MultAmount, Mult, Add, ExtraFrom, ExtraTo, ExtraMult )
	if not src or not sceneLuminance then return nil end
	local mx,my = dxGetMaterialSize( src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT )
	dxSetShaderValue( modulationShader, "sBaseTexture", src )
	dxSetShaderValue( modulationShader, "sMultAmount", MultAmount )
	dxSetShaderValue( modulationShader, "sMult", Mult )
	dxSetShaderValue( modulationShader, "sAdd", Add )
	dxSetShaderValue( modulationShader, "sLumTexture", sceneLuminance )
	dxSetShaderValue( modulationShader, "sExtraFrom", ExtraFrom )
	dxSetShaderValue( modulationShader, "sExtraTo", ExtraTo )
	dxSetShaderValue( modulationShader, "sExtraMult", ExtraMult )
	dxDrawImage( 0, 0, mx, my, modulationShader )
	DebugResults.addItem( newRT, "Modulation" )
	return newRT
end

local function applyResize( src, tx, ty )
	if not src then return nil end
	local newRT = RTPool.GetUnused(tx, ty)
	if not newRT then return nil end
	dxSetRenderTarget( newRT )
	dxDrawImage( 0,  0, tx, ty, src )
	DebugResults.addItem( newRT, "Resize" )
	return newRT
end

local function applyDownsample( src )
	if not src then return nil end
	local mx,my = dxGetMaterialSize( src )
	mx = mx / 2
	my = my / 2
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT )
	dxDrawImage( 0, 0, mx, my, src )
	DebugResults.addItem( newRT, "Downsample" )
	return newRT
end

local function applyDownsampleSteps( src, steps )
	if not src then return nil end
	for i=1,steps do
		src = applyDownsample ( src )
	end
	return src
end

local function applyGBlurH( src, bloom )
	if not src then return nil end
	local mx,my = dxGetMaterialSize( src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurHShader, "tex0", src )
	dxSetShaderValue( blurHShader, "tex0size", mx,my )
	dxSetShaderValue( blurHShader, "bloom", bloom )
	dxDrawImage( 0, 0, mx,my, blurHShader )
	DebugResults.addItem( newRT, "GBlurH" )
	return newRT
end

local function applyGBlurV( src, bloom )
	if not src then return nil end
	local mx,my = dxGetMaterialSize( src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurVShader, "tex0", src )
	dxSetShaderValue( blurVShader, "tex0size", mx,my )
	dxSetShaderValue( blurVShader, "bloom", bloom )
	dxDrawImage( 0, 0, mx,my, blurVShader )
	DebugResults.addItem( newRT, "GBlurV" )
	return newRT
end


local function updateLumSource( current, changeRate, changeAlpha )
	if not current then return nil end
	changeRate = changeRate or 50

	local mx,my = dxGetMaterialSize( current );

	local size = 1
	while ( size < mx / 2 or size < my / 2 ) do
		size = size * 2
	end

	current = applyResize( current, size, size )
	while ( size > 1 ) do
		size = size / 2
		current = applyDownsample( current, 2 )
	end

	if getTickCount() > nextLumSampleTime then
		nextLumSampleTime = getTickCount() + changeRate
		dxSetRenderTarget( lumTarget )
		dxDrawImage( 0,  0, 1, 1, current, 0,0,0, tocolor(255,255,255,changeAlpha) )
	end

	current = applyResize( lumTarget, 1, 1 )

	return lumTarget
end

----------------------------------------------------------------
-- Render
----------------------------------------------------------------
local function drawnContrast()
	if not bAllValid or not Settings.var then return end
	local v = Settings.var

	RTPool.frameStart()
	DebugResults.frameStart()

	dxUpdateScreenSource( myScreenSourceFull )

	-- Get source textures
	local current1 = myScreenSourceFull
	local current2 = myScreenSourceFull
	local sceneLuminance = lumTarget

	-- Effect path 1 (contrast)
	current1 = applyModulation( current1, sceneLuminance, v.MultAmount, v.Mult, v.Add, v.ModExtraFrom, v.ModExtraTo, v.ModExtraMult )
	current1 = applyContrast( current1, v.Brightness, v.Contrast )

	-- Effect path 2 (bloom)
	current2 = applyBloomExtract( current2, sceneLuminance, v.ExtractThreshold )
	current2 = applyDownsampleSteps( current2, v.DownSampleSteps )
	current2 = applyGBlurH( current2, v.GBlurHBloom )
	current2 = applyGBlurV( current2, v.GBlurVBloom )
	current2 = applyBloomCombine( current2, current1, v.BloomIntensity, v.BloomSaturation, v.BaseIntensity, v.BaseSaturation )

	-- Update texture used to calculate the scene luminance level
	updateLumSource( current1, v.LumSpeed, v.LumChangeAlpha )

	-- Final output
	dxSetRenderTarget()
	dxDrawImage( 0, 0, scx, scy, current1, 0, 0, 0, tocolor(255,255,255,v.MulBlend*255) )
	dxDrawImage( 0, 0, scx, scy, current2, 0, 0, 0, tocolor(255,255,255,v.BloomBlend*255) )

	-- Draw border texture
	dxDrawImage( 0, 0, scx, scy, textureVignette, 0, 0, 0, tocolor(255,255,255,v.Vignette*255) )

	-- Debug stuff
	if v.PreviewEnable > 0.5 then
		DebugResults.drawItems ( v.PreviewSize, v.PreviewPosX, v.PreviewPosY )
	end
end

--------------------------------
-- Switch effect on
--------------------------------
function enableContrast()
	if bEffectEnabled then return end

	-- Input texture
    myScreenSourceFull = dxCreateScreenSource( scx, scy )

	-- Shaders
	contrastShader = dxCreateShader( "shaders/hdr/fx/contrast.fx" )
	bloomCombineShader = dxCreateShader( "shaders/hdr/fx/bloom_combine.fx" )
	bloomExtractShader = dxCreateShader( "shaders/hdr/fx/bloom_extract.fx" )
	blurHShader = dxCreateShader( "shaders/hdr/fx/blurH.fx" )
	blurVShader = dxCreateShader( "shaders/hdr/fx/blurV.fx" )
	modulationShader = dxCreateShader( "shaders/hdr/fx/modulation.fx" )

	-- 1 pixel render target to store the result of scene luminance calculations
	lumTarget = dxCreateRenderTarget( 1, 1 )
	nextLumSampleTime = 0

	-- Overlay texture
	textureVignette = dxCreateTexture ( "shaders/hdr/images/vignette1.dds" );

	-- Get list of all elements used
	effectParts = {
						myScreenSourceFull,
						contrastShader,
						bloomCombineShader,
						bloomExtractShader,
						blurHShader,
						blurVShader,
						modulationShader,
						lumTarget,
						textureVignette
					}

	-- Check list of all elements used
	bAllValid = true
	for _,part in ipairs(effectParts) do
		bAllValid = part and bAllValid
	end

	setEffectType1 ()
	bEffectEnabled = true

	if not bAllValid then
		disableContrast()
	end

	addEventHandler("onClientHUDRender", root, drawnContrast, true)
end


--------------------------------
-- Switch effect off
--------------------------------
function disableContrast()
	if not bEffectEnabled then return end

	-- Destroy all shaders
	for _,part in ipairs(effectParts) do
		if part then
			destroyElement( part )
		end
	end
	effectParts = {}
	bAllValid = false
	RTPool.clear()

	-- Flag effect as stopped
	bEffectEnabled = false

	removeEventHandler("onClientHUDRender", root, drawnContrast)
end