local minSx, minSy = 1024, 720
local sx, sy = guiGetScreenSize()

addEventHandler("onClientResourceStart", resourceRoot,
    function()
		if sx < minSx or sy < minSy then
		    triggerServerEvent("acheat:kick", localPlayer, localPlayer, "Túl kicsi a képernyő felbontásod! (Minimális: "..minSx.."x"..minSy..")")
		end
	end
)