local fonts = {}
local fontsSource = {
    --["fontName"] = "source"
	["Rubik-Black"] = "files/Rubik-Bold.ttf",
    ["Rubik-Regular"] = "files/Rubik-Regular.ttf",
    ["Rubik"] = "files/Rubik-Regular.ttf",
    ["Rubik-Light"] = "files/Rubik-Light.ttf",
	["gotham_light"] = "files/gotham_light.ttf",
    ["Roboto"] = "files/Roboto.ttf",
    ["RobotoB"] = "files/RobotoB.ttf", 
    ["RobotoL"] = "files/RobotoL.ttf",
    ["OpenSans"] = "files/OpenSans.ttf",
    ["AwesomeFont"] = "files/FontAwesomeSolid.ttf",
    ["BoldFont"] = "files/BoldFont.ttf",
    ["gtaFont"] = "files/gtaFont.ttf",
    ["LoginFont"] = "files/loginfont.ttf",
	["Yantramanav-Black"] = "files/Yantramanav-Black.ttf",
	["Yantramanav-Regular"] = "files/Yantramanav-Regular.ttf",
    ["Azzardo-Regular"] = "files/Azzardo-Regular.ttf",
    ["ArtegraSans-Black"] = "files/ArtegraSans-Black.otf",
    ["ArtegraSans-Bold"] = "files/ArtegraSans-Bold.otf",
    ["ArtegraSans-Thin"] = "files/ArtegraSans-Thin.otf",
    ["ArtegraSans-ExtraBold"] = "files/ArtegraSans-ExtraBold.otf",
    ["DeansGateB"] = "files/DeansGateB.ttf",
    ["FontAwesomeBrand"] = "files/FontAwesomeBrand.ttf",
    ["FontAwesomeLight"] = "files/FontAwesomeLight.ttf",
    ["FontAwesomeRegular"] = "files/FontAwesomeRegular.ttf",
    ["SFUIDisplay-Light"] = "files/SFUIDisplay-Light.ttf",
    ["SFUIDisplay-Regular"] = "files/SFUIDisplay-Regular.ttf",
    ["SFUIDisplay-Semibold"] = "files/SFUIDisplay-Semibold.ttf",
    ["SFUIDisplay-Thin"] = "files/SFUIDisplay-Thin.ttf",
    ["DS-DIGI"] = "files/DS-DIGIB.ttf",
    ["SWEET-PURPLE"] = "files/SWEET-PURPLE.ttf",
    ['Poppins-Medium'] = 'files/Poppins-Medium.ttf',
    ['Poppins-Regular'] = 'files/Poppins-Regular.ttf',
    ['Poppins-SemiBold'] = 'files/Poppins-SemiBold.ttf',
    ['Poppins-Bold'] = 'files/Poppins-Bold.ttf',
    ['Anton-Regular'] = 'files/Anton-Regular.ttf',
    ['PricedownBL'] = 'files/pricedown_bl.otf',
    ['DanielsSignature'] = 'files/DanielsSignature.ttf',
    ['FREESCPT'] = 'files/FREESCPT.ttf',
    ['ChauPhilomeneOne'] = 'files/ChauPhilomeneOne-Regular.ttf',
    ['BrushScriptMT'] = 'files/BrushScriptMT.ttf',
    ["ArchitectsDaughter-Regular"] = "files/ArchitectsDaughter-Regular.ttf",
}

local ticks = {}

function getFont(font, size, bold, quality)
    if not font then return end
    if not size then return end
    --local size = math.floor(size)
    local fontE = false
    local _font = font

    if font == "FontAwesome" then 
        _font = "AwesomeFont"
    end
    
    if bold then
        font = font .. "-bold"
    end
    
    if quality then
        font = font .. "-" .. quality 
    end
    
    if font and size then
	    local subText = font .. size
	    local value = fonts[subText]
	    if value then
		    fontE = value
            ticks[subText][2] = getTickCount()
		end
	end
    
    if not fontE then
        local v = fontsSource[_font]
        fontE = DxFont(v, size, bold, quality)
        local subText = font .. size
        fonts[subText] = fontE
        ticks[subText] = {fontE, getTickCount()}
        --outputDebugString("Font:" ..font.. ", Size: "..size.." created!", 0, 255, 255, 255)
    end
    
	return fontE
end

setTimer(
    function()
        for k,v in pairs(ticks) do
            if v[2] + 500 <= getTickCount() then
                v[1]:destroy()

                fonts[k] = nil
                ticks[k] = nil
                
                collectgarbage("collect")
                --outputDebugString("Font:" ..k.. " deleted!", 0, 255, 87, 87)
            end
        end
    end, 500, 0
)