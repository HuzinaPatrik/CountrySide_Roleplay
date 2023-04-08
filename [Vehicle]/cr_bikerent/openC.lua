function setCameraToPed()
	local p1, p2, p3, p4, p5, p6 = getCameraMatrix()	
	smoothMoveCamera(p1,p2,p3,p4,p5,p6,c1,c2,c3,c4,c5,c6,1000)	
	setElementFrozen(localPlayer, true)
	toggleAllControls(false)
end



function createPedChat()
	local alpha, progress = exports['cr_dx']:getFade("bikeRent.ped")

	local font = exports['cr_fonts']:getFont("Poppins-SemiBold", 14)
	local green = "#61b15a"
	local white = "#f2f2f2"

	if not pedChatState then 
		if progress >= 1 then 
			destroyRender("createPedChat")
		end 
	end 
	
	local pedMessages = {
		"Üdvözöllek a Bob&Ray biciklibérlőnél. Ha biciklit szeretnél bérelni, nyomd meg az ".. green .."'enter' ".. white .."gombot, ha pedig folytatnád az utad tovább, nyomd meg a ".. green .."'backspace' ".. white .."billentyűt!"
	}	
	
	dxDrawRectangle(0, sy - 80, sx, 80, tocolor(51, 51, 51, alpha))
	dxDrawText(pedMessages[1], 0, sy, sx + 0, 80 + (sy - 150), tocolor(242, 242, 242, alpha), 1, font, "center", "center", false, false, false, true, false)
end



function createVehicleToPos()
	veh = createVehicle(vehicle_list[selected_veh][1],car_pos[1], car_pos[2], car_pos[3])
	setElementFrozen(veh, true)
end

local rot = 0
function vehicleAnimationAndShow()
	if rot > 360 then
		rot = 0
	end
	rot = rot + 0.5
	setElementRotation(veh, 0 , 0, rot)	
end

function setCameraToVeh()
	local p1, p2, p3, p4, p5, p6 = getCameraMatrix()
	smoothMoveCamera(c1,c2,c3,c4,c5,c6,v1,v2,v3,v4,v5,v6,1000)
end